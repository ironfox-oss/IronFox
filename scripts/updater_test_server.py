#!/usr/bin/env python3
r"""Fake IronFox release server for exercising every code path of the in-app updater.

It serves the update feed and an APK, and can misbehave on demand: malformed feeds, bad hashes, redirects to other
hosts, truncated or reset downloads, and so on. Every request is logged with its time, path, host and user agent.

Connecting to it:
  - The updater only talks to the host of the build-time `IRONFOX_UPDATE_MANIFEST_URL` option, so build the app under
    test with that variable pointing at this server's address.
  - Over HTTPS, put a TLS terminator (Caddy, cloudflared, nginx) in front of this plain-HTTP server.
  - On nightly builds, turn on "Allow insecure HTTP connections" in the Updates settings and use a plain
    `--base http://<host>:<port>` instead. "HTTPS-Only Mode" is Firefox settings must be set to "On in private tabs"
    for this to work.

Example:

    scripts/updater_test_server.py --new-apk new.apk --new-code 2016187770 --installed-code 2016187754 \
        --base http://10.0.2.2:8000 --variant arm64-v8a --package org.ironfoxoss.ironfox.nightly

The scenario is re-read from a file on every request, so you can change it without restarting:

    echo "feed=good apk=slow" > scenario.txt

Sequence mode runs a different scenario for each update check, so a whole batch can be driven from the device
without touching the server. Entries are separated by "|"; the next entry is used whenever a feed request
arrives more than two seconds after the previous one (redirect hops are not new checks). The APK routes use
the entry chosen by the latest feed request. After the last entry the scenario is "feed=good apk=good".

    echo "seq feed=html | feed=empty | feed=good apk=hash-mismatch" > scenario.txt

Feed scenarios: good uptodate older other-variant missing-package missing-variant missing-code string-code
    fractional-code html empty array bad-json error500 notmodified redirect-ok redirect-evil redirect-http
    redirect-relative redirect-loop redirect-noloc slow-feed
APK scenarios: good hash-mismatch wrong-pkg code-mismatch evil-host http-url redirect redirect-evil slow
    truncated nolength reset error404 wrong-key flaky
    http-url advertises a plain-HTTP APK URL, which the updater must refuse unless insecure HTTP is enabled.
    wrong-key serves --wrong-key-apk (same package and version code, other signing key) with a matching hash.
    flaky resets the connection the first time an advertised URL is fetched and serves it correctly afterwards,
    so "Try again" can be tested without touching the server.
Other entry keys: pkg=<package> replaces the feed's package key, notes=<url> replaces the release notes URL.
"""

import argparse
import hashlib
import json
import os
import socket
import struct
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

CHUNK = 64 * 1024


def sha512(path):
    digest = hashlib.sha512()
    with open(path, "rb") as handle:
        for block in iter(lambda: handle.read(CHUNK), b""):
            digest.update(block)
    return digest.hexdigest()


class Server(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, args):
        super().__init__((args.bind, args.port), Handler)
        self.args = args
        self.flaky_seen = set()
        self.seq_text = None
        self.seq_index = -1
        self.seq_last_feed = 0.0
        self.seq_current = {"feed": "good", "apk": "good"}

    @staticmethod
    def parse_words(text):
        values = {"feed": "good", "apk": "good"}
        for word in text.split():
            key, _, value = word.partition("=")
            values[key] = value
        return values

    def scenario(self, new_check=False):
        try:
            with open(self.args.scenario_file, encoding="utf-8") as handle:
                text = handle.read().strip()
        except FileNotFoundError:
            text = ""
        if not text.startswith("seq"):
            self.seq_text = None
            return self.parse_words(text)
        if text != self.seq_text:
            self.seq_text = text
            self.seq_index = -1
            self.seq_last_feed = 0.0
            self.seq_current = {"feed": "good", "apk": "good"}
        if new_check and time.time() - self.seq_last_feed > 2.0:
            entries = [entry for entry in text[3:].split("|") if entry.strip()]
            self.seq_index += 1
            self.seq_current = (self.parse_words(entries[self.seq_index])
                                if self.seq_index < len(entries) else {"feed": "good", "apk": "good"})
            sys.stdout.write("%s SEQ #%d -> %s\n" % (time.strftime("%H:%M:%S"), self.seq_index + 1, self.seq_current))
            sys.stdout.flush()
        if new_check:
            self.seq_last_feed = time.time()
        return dict(self.seq_current)

    def feed(self, scenario):
        a = self.args
        code = a.new_code
        # A CDN in front of the server (Cloudflare caches *.apk by default) would answer repeat requests for the
        # same URL itself, hiding every APK scenario, so each feed response advertises URLs nobody has fetched yet.
        buster = "?n=%d" % int(time.time() * 1000)
        entry = {"version-code": code, "sha512sum": sha512(a.new_apk), "url": a.base + "/apk/new.apk" + buster}
        apk = scenario["apk"]
        if apk == "hash-mismatch":
            entry["sha512sum"] = "0" * 128
        elif apk == "wrong-pkg":
            entry["url"] = a.base + "/apk/other.apk" + buster
            entry["sha512sum"] = sha512(a.other_apk)
        elif apk == "code-mismatch":
            entry["version-code"] = code + 8
        elif apk == "wrong-key":
            entry["url"] = a.base + "/apk/wrong-key.apk" + buster
            entry["sha512sum"] = sha512(a.wrong_key_apk)
        elif apk == "evil-host":
            entry["url"] = "https://evil.example/apk/new.apk"
        elif apk == "http-url":
            entry["url"] = "http://" + a.base.split("://", 1)[1] + "/apk/new.apk" + buster
        elif apk == "redirect":
            entry["url"] = a.base + "/apk/redirect" + buster
        elif apk == "redirect-evil":
            entry["url"] = a.base + "/apk/redirect-evil" + buster

        feed_sc = scenario["feed"]
        if feed_sc == "uptodate":
            entry["version-code"] = a.installed_code
        elif feed_sc == "older":
            entry["version-code"] = a.installed_code - 8
        elif feed_sc == "other-variant":
            entry["version-code"] = (code & ~7) | 0b111
        elif feed_sc == "missing-code":
            del entry["version-code"]
        elif feed_sc == "string-code":
            entry["version-code"] = str(code)
        elif feed_sc == "fractional-code":
            entry["version-code"] = code + 0.5

        package = {
            "version": a.version,
            "release-notes": scenario.get("notes", a.release_notes),
            a.variant: entry,
            "bundle": {"sha512sum": "0" * 128, "url": a.base + "/apk/bundle.apks"},
        }
        if feed_sc == "missing-variant":
            del package[a.variant]
        root = {scenario.get("pkg", a.package): package}
        if feed_sc == "missing-package":
            root = {"org.example.other": package}
        if feed_sc == "array":
            root = [root]
        return json.dumps(root).encode()


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        sys.stdout.write("%s %s Host=%s UA=%s\n" % (time.strftime("%H:%M:%S"), self.requestline,
                                                      self.headers.get("Host"), self.headers.get("User-Agent")))
        sys.stdout.flush()

    def send_bytes(self, status, body, ctype="application/json", declare_length=True, extra=()):
        self.send_response(status)
        self.send_header("Content-Type", ctype)
        self.send_header("Cache-Control", "no-store")
        if declare_length:
            self.send_header("Content-Length", str(len(body)))
        else:
            self.send_header("Connection", "close")
            self.close_connection = True
        for name, value in extra:
            self.send_header(name, value)
        self.end_headers()
        self.wfile.write(body)

    def redirect(self, location, status=302):
        self.send_response(status)
        self.send_header("Location", location)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", "0")
        self.end_headers()

    def do_GET(self):
        server = self.server
        path = self.path.split("?", 1)[0]
        scenario = server.scenario(new_check=path == "/updates.json")
        base = server.args.base
        feed_sc = scenario["feed"]

        if path == "/updates.json":
            self.serve_feed(server, scenario, feed_sc, base)
        elif path == "/updates-real.json":
            self.send_bytes(200, server.feed({"feed": "good", "apk": scenario["apk"]}))
        elif path == "/other/updates.json":
            self.send_bytes(200, server.feed({"feed": "good", "apk": scenario["apk"]}))
        elif path == "/apk/new.apk":
            apk_sc = scenario["apk"]
            if apk_sc == "flaky":
                token = self.path.partition("?")[2]
                apk_sc = "good" if token in server.flaky_seen else "reset"
                server.flaky_seen.add(token)
            self.serve_apk(server, apk_sc, server.args.new_apk)
        elif path == "/apk/wrong-key.apk":
            self.serve_apk(server, "good", server.args.wrong_key_apk)
        elif path == "/apk/other.apk":
            self.serve_apk(server, "good", server.args.other_apk)
        elif path == "/apk/redirect":
            query = self.path.partition("?")[2]
            self.redirect(base + "/apk/new.apk" + ("?" + query if query else ""))
        elif path == "/apk/redirect-evil":
            self.redirect("https://evil.example/apk/new.apk")
        else:
            self.send_bytes(404, b"not found", "text/plain")

    def serve_feed(self, server, scenario, feed_sc, base):
        if feed_sc == "html":
            self.send_bytes(200, b"<html><body>502 Bad Gateway</body></html>", "text/html")
        elif feed_sc == "empty":
            self.send_bytes(200, b"")
        elif feed_sc == "bad-json":
            self.send_bytes(200, b'{"org.ironfoxoss.ironfox": {')
        elif feed_sc == "error500":
            self.send_bytes(500, b"boom", "text/plain")
        elif feed_sc == "notmodified":
            self.send_response(304)
            self.send_header("Content-Length", "0")
            self.end_headers()
        elif feed_sc == "redirect-ok":
            self.redirect(base + "/updates-real.json")
        elif feed_sc == "redirect-relative":
            self.redirect("/updates-real.json")
        elif feed_sc == "redirect-evil":
            self.redirect("https://evil.example/updates.json")
        elif feed_sc == "redirect-http":
            self.redirect("http://" + base.split("://", 1)[1] + "/updates-real.json")
        elif feed_sc == "redirect-loop":
            self.redirect(base + "/updates.json")
        elif feed_sc == "redirect-noloc":
            self.send_response(302)
            self.send_header("Content-Length", "0")
            self.end_headers()
        elif feed_sc == "slow-feed":
            time.sleep(server.args.slow_feed_seconds)
            self.send_bytes(200, server.feed(scenario))
        else:
            self.send_bytes(200, server.feed(scenario))

    def serve_apk(self, server, apk_sc, path):
        if apk_sc == "error404":
            self.send_bytes(404, b"missing", "text/plain")
            return
        size = os.path.getsize(path)
        mime = "application/vnd.android.package-archive"
        self.send_response(200)
        self.send_header("Content-Type", mime)
        self.send_header("Cache-Control", "no-store")
        if apk_sc == "nolength":
            self.send_header("Connection", "close")
            self.close_connection = True
        else:
            self.send_header("Content-Length", str(size))
        self.end_headers()
        limit = {"truncated": size // 2, "reset": size // 3}.get(apk_sc, size)
        sent = 0
        with open(path, "rb") as handle:
            while sent < limit:
                block = handle.read(min(CHUNK, limit - sent))
                if not block:
                    break
                self.wfile.write(block)
                sent += len(block)
                if apk_sc == "slow":
                    time.sleep(len(block) / server.args.rate)
        if apk_sc == "reset":
            self.connection.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack("ii", 1, 0))
        if apk_sc in ("truncated", "reset"):
            self.close_connection = True
            self.connection.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--new-apk", required=True, help="signed APK with the higher version code")
    parser.add_argument("--new-code", required=True, type=int, help="its version code")
    parser.add_argument("--installed-code", required=True, type=int, help="version code of the installed build")
    parser.add_argument("--other-apk", help="any other signed APK (for the wrong-pkg scenario)")
    parser.add_argument("--wrong-key-apk", help="the new APK re-signed with another key (for the wrong-key scenario)")
    parser.add_argument("--base", required=True, help="public HTTP(S) base URL, e.g. https://updates.test.example")
    parser.add_argument("--package", default="org.ironfoxoss.ironfox")
    parser.add_argument("--variant", default="arm64-v8a", help="feed key of the installed variant")
    parser.add_argument("--version", default="99.0.0")
    parser.add_argument("--release-notes", default="https://ironfoxoss.org/releases/")
    parser.add_argument("--scenario-file", default="scenario.txt")
    parser.add_argument("--rate", type=int, default=256 * 1024, help="bytes/second for the slow scenario")
    parser.add_argument("--slow-feed-seconds", type=int, default=30)
    parser.add_argument("--bind", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()
    args.base = args.base.rstrip("/")
    args.other_apk = args.other_apk or args.new_apk
    args.wrong_key_apk = args.wrong_key_apk or args.new_apk
    print("Serving on %s:%d as %s (scenario file: %s)" % (args.bind, args.port, args.base, args.scenario_file))
    if args.base.startswith("http://"):
      print("You may need to set HTTPS-Only mode to 'On in private tabs' and enable 'Allow insecure HTTP connections' in IronFox settings.")
    Server(args).serve_forever()


if __name__ == "__main__":
    main()
