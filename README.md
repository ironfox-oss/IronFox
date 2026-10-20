# IronFox

<div align="center">

<img src="assets/ironfox.png"
  alt="IronFox"
  height="200">

</div>

<div align="center">

[<img src="assets/accrescent.png"
  alt="Get it on Accrescent"
  height="80">](https://accrescent.app/app/org.ironfoxoss.ironfox)
[<img src="assets/f-droid.png"
  alt="Get it on F-Droid"
  height="80">](fdroidrepos://fdroid.ironfoxoss.org/fdroid/repo?fingerprint=C5E291B5A571F9C8CD9A9799C2C94E02EC9703948893F2CA756D67B94204F904)
[<img src="assets/obtainium.png"
  alt="Get it on Obtainium"
  height="80">](obtainium://app/%7B%22id%22%3A%22org.ironfoxoss.ironfox%22%2C%22url%22%3A%22https%3A%2F%2Freleases.ironfoxoss.org%2Fironfox%2Freleases%2Fupdates.json%22%2C%22author%22%3A%22releases.ironfoxoss.org%22%2C%22name%22%3A%22App%22%2C%22preferredApkIndex%22%3A0%2C%22additionalSettings%22%3A%22%7B%5C%22intermediateLink%5C%22%3A%5B%5D%2C%5C%22customLinkFilterRegex%5C%22%3A%5C%22%5C%22%2C%5C%22filterByLinkText%5C%22%3Afalse%2C%5C%22matchLinksOutsideATags%5C%22%3Afalse%2C%5C%22skipSort%5C%22%3Afalse%2C%5C%22reverseSort%5C%22%3Afalse%2C%5C%22sortByLastLinkSegment%5C%22%3Afalse%2C%5C%22versionExtractWholePage%5C%22%3Atrue%2C%5C%22requestHeader%5C%22%3A%5B%7B%5C%22requestHeader%5C%22%3A%5C%22User-Agent%3A%20Mozilla%2F5.0%20(Linux%3B%20Android%2010%3B%20K)%20AppleWebKit%2F537.36%20(KHTML%2C%20like%20Gecko)%20Chrome%2F114.0.0.0%20Mobile%20Safari%2F537.36%5C%22%7D%5D%2C%5C%22defaultPseudoVersioningMethod%5C%22%3A%5C%22partialAPKHash%5C%22%2C%5C%22trackOnly%5C%22%3Afalse%2C%5C%22versionExtractionRegEx%5C%22%3A%5C%22%5C%5C%5C%22org%5C%5C%5C%5C.ironfoxoss%5C%5C%5C%5C.ironfox%5C%5C%5C%22%5C%5C%5C%5Cs*%3A%5C%5C%5C%5Cs*%5C%5C%5C%5C%7B.*%3F%5C%5C%5C%22version%5C%5C%5C%22%5C%5C%5C%5Cs*%3A%5C%5C%5C%5Cs*%5C%5C%5C%22(%5B%5E%5C%5C%5C%22%5D%2B)%5C%5C%5C%22%5C%22%2C%5C%22matchGroupToUse%5C%22%3A%5C%221%5C%22%2C%5C%22versionDetection%5C%22%3Atrue%2C%5C%22useVersionCodeAsOSVersion%5C%22%3Afalse%2C%5C%22apkFilterRegEx%5C%22%3A%5C%22universal%5C%22%2C%5C%22invertAPKFilter%5C%22%3Afalse%2C%5C%22autoApkFilterByArch%5C%22%3Atrue%2C%5C%22appName%5C%22%3A%5C%22IronFox%5C%22%2C%5C%22appAuthor%5C%22%3A%5C%22IronFox%20OSS%5C%22%2C%5C%22shizukuPretendToBeGooglePlay%5C%22%3Afalse%2C%5C%22allowInsecure%5C%22%3Afalse%2C%5C%22exemptFromBackgroundUpdates%5C%22%3Afalse%2C%5C%22skipUpdateNotifications%5C%22%3Afalse%2C%5C%22about%5C%22%3A%5C%22Private%2C%20secure%2C%20user%20first%20web%20browser%20for%20Android.%5C%22%2C%5C%22refreshBeforeDownload%5C%22%3Atrue%7D%22%2C%22overrideSource%22%3A%22HTML%22%7D)

</div>

<div align="center"><b>F-Droid QR Code:</b></div>

<div align="center">

[<img src="assets/f-droid_qr.png"
  alt="Get it on F-Droid"
  height="300">](fdroidrepos://fdroid.ironfoxoss.org/fdroid/repo?fingerprint=C5E291B5A571F9C8CD9A9799C2C94E02EC9703948893F2CA756D67B94204F904)

</div>

---

IronFox is a fork of [Divested Computing Group](https://divested.dev/)'s [Mull
Browser][mull], based on [Mozilla Firefox](https://www.firefox.com/). **Our goal
is to continue the legacy of Mull by providing a free and open source, privacy
and security-oriented web browser for daily use.**

> [!TIP]
> Find a bug? Encounter an annoying problem? Have a tip, idea, or suggestion
> you'd like to share? **Please file any issues, bug reports, and suggestions
> over at [our unified issue
> tracker](https://codeberg.org/ironfox-oss/bugs/issues)!**

> [!IMPORTANT]
> **All users are HIGHLY recommended to take a look at our
> [documentation](https://ironfoxoss.org/docs/), ESPECIALLY the
> [Limitations](https://ironfoxoss.org/docs/limitations/) and [Frequently Asked
> Questions](https://ironfoxoss.org/docs/faq/) pages!**

## Features

IronFox hardens Firefox for Android and removes parts of it that work against
privacy. Highlights:

- **Privacy:** clears history, cache, downloads and open tabs on exit, uses
  DNS over HTTPS (Quad9, max protection), enables Strict Enhanced Tracking
  Protection, bundles uBlock Origin, and blocks geolocation, local network and
  external-app prompts by default.
- **Fingerprinting resistance:** enables Suspected Fingerprinters Protection,
  defaults to the light theme, and requests English (`en-US`) pages by default.
- **Security:** HTTPS-Only Mode, per-site process isolation (Fission), memory
  tagging on supported devices, a hardened PDF viewer, and JavaScript JIT,
  add-on installation, autofill and the built-in password manager off by
  default.
- **User control:** toggles for JavaScript, WebGL, WebRTC, WebAssembly, SVG,
  IPv6 and the referer policy, plus `about:config`.
- **Less Mozilla:** no sponsored tiles, Firefox Suggest, surveys or crash
  reporting, and no Adjust, Sentry or Google Play libraries. Push
  notifications use UnifiedPush.
- **Sensible defaults:** DuckDuckGo as the default search engine, and media
  autoplay and web notifications blocked.

See the full list on the
[features page](https://ironfoxoss.org/docs/features/), and read the
[limitations](https://ironfoxoss.org/docs/limitations/) to understand what
IronFox can and can't protect against.

## Install and Verify

For details and step-by-step instructions on how to install IronFox, see our
[Download](https://ironfoxoss.org/download/) page.

IronFox supports the same minimum Android version as Firefox for Android, on
`arm64`, `arm` and `x86_64` devices, including Android TV and Fire TV.

**Release** builds are the stable channel. **Nightly** builds come from CI, use
a different package ID, and differ slightly in branding and developer options.
See [Nightly vs. Release](https://ironfoxoss.org/docs/nightly-vs-release/).

The [changelog](CHANGELOG.md) has the notes for the latest release. Notes for
every release are on the
[releases page](https://gitlab.com/ironfox-oss/IronFox/-/releases).

**Package ID**: `org.ironfoxoss.ironfox`

**Package ID (Nightly)**: `org.ironfoxoss.ironfox.nightly`

**SHA-256 Hash of Signing Certificate**:

```text
C5:E2:91:B5:A5:71:F9:C8:CD:9A:97:99:C2:C9:4E:02:EC:97:03:94:88:93:F2:CA:75:6D:67:B9:42:04:F9:04
```

## Get Involved

Want to join the IronFox Community? We'd love to see you over on
[Matrix](https://matrix.to/#/#ironfox:unredacted.org) _(Recommended)_ and
[Discord](https://discord.gg/zbdzfRVyVh)!

Report bugs and suggestions on the
[issue tracker](https://codeberg.org/ironfox-oss/bugs/issues). Code and merge
requests go to [GitLab](https://gitlab.com/ironfox-oss/IronFox), which is
IronFox's home. The repository is also mirrored to
[Codeberg](https://codeberg.org/ironfox-oss/IronFox) and
[GitHub](https://github.com/ironfox-oss/IronFox).

Bug reports, translations, and code changes are welcome. See
[CONTRIBUTING.md](CONTRIBUTING.md) for how to build IronFox, run the linters,
and submit changes, and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for a map
of the repository.

## Licensing

The scripts are licensed under the [GNU Affero General Public License, version 3
or later](COPYING.txt). Patches follow the license of the files they modify. See
[LICENSES.md](LICENSES.md) for details and attributions.

## Notices

- Mozilla Firefox is a trademark of The Mozilla Foundation.
- This is not an officially supported Mozilla product. IronFox is in no way
  affiliated with Mozilla.
- IronFox is not sponsored or endorsed by Mozilla.
- IronFox is not associated with DivestOS, Divested Computing Group, or Mull in
  any manner.
- Firefox source code is available at
  <https://github.com/mozilla-firefox/firefox>.

[mull]: https://web.archive.org/web/20250113132510/https://divestos.org/pages/our_apps#mull
