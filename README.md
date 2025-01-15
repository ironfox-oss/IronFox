# IronFox

<p align="center">
    <img src="assets/ironfox.png"
        alt="IronFox"
        height="200">
</p>

<a href="fdroidrepos://fdroid.ironfoxoss.org/fdroid/repo?fingerprint=C5E291B5A571F9C8CD9A9799C2C94E02EC9703948893F2CA756D67B94204F904" target="_blank"><img src="assets/f-droid.png" alt="Get it on F-Droid" height="80"/></a>

<a href="obtainium://app/%7B%22id%22%3A%22org.ironfoxoss.ironfox%22%2C%22url%22%3A%22https%3A%2F%2Ffdroid.ironfoxoss.org%2Ffdroid%2Frepo%2F%22%2C%22author%22%3A%22IronFox%20OSS%22%2C%22name%22%3A%22IronFox%22%2C%22additionalSettings%22%3A%22%7B%5C%22appIdOrName%5C%22%3A%5C%22org.ironfoxoss.ironfox%5C%22%2C%5C%22pickHighestVersionCode%5C%22%3Afalse%2C%5C%22trackOnly%5C%22%3Afalse%2C%5C%22versionExtractionRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22matchGroupToUse%5C%22%3A%5C%22%5C%22%2C%5C%22versionDetection%5C%22%3Atrue%2C%5C%22releaseDateAsVersion%5C%22%3Afalse%2C%5C%22useVersionCodeAsOSVersion%5C%22%3Afalse%2C%5C%22apkFilterRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22invertAPKFilter%5C%22%3Afalse%2C%5C%22autoApkFilterByArch%5C%22%3Atrue%2C%5C%22appName%5C%22%3A%5C%22%5C%22%2C%5C%22shizukuPretendToBeGooglePlay%5C%22%3Afalse%2C%5C%22exemptFromBackgroundUpdates%5C%22%3Afalse%2C%5C%22skipUpdateNotifications%5C%22%3Afalse%2C%5C%22about%5C%22%3A%5C%22IronFox%20is%20a%20secure%2C%20hardened%20and%20privacy-oriented%20web%20browser%20for%20Android%2C%20based%20on%20Firefox.%5C%22%7D%22%2C%22overrideSource%22%3A%22FDroidRepo%22%7D" target="_blank"><img src="assets/obtainium.png" alt="Get it on Obtainium" height="80"/></a>

------------

IronFox is a fork of [Divested Computing Group](https://divested.dev/)'s [Mull Browser](https://divestos.org/pages/our_apps#mull), based on [Mozilla Firefox](https://www.mozilla.org/firefox/). **Our goal is to continue the legacy of Mull by providing a free and open source, privacy and security-oriented web browser for daily use.**

> While IronFox's home is [GitLab](https://gitlab.com/ironfox-oss/IronFox), this repo is also mirrored to both [Codeberg](https://codeberg.org/ironfox-oss/IronFox) & [GitHub](https://github.com/ironfox-oss/IronFox).

### Want to join the IronFox Community?

We'd love to see you over on [Matrix](https://matrix.to/#/#ironfox:unredacted.org) *(Recommended)* and [Discord](https://discord.gg/zbdzfRVyVh)!

## App Verification

**Package ID**: `org.ironfoxoss.ironfox`

**SHA-256 Hash of Signing Certificate**:

```sh
C5:E2:91:B5:A5:71:F9:C8:CD:9A:97:99:C2:C9:4E:02:EC:97:03:94:88:93:F2:CA:75:6D:67:B9:42:04:F9:04
```

## Known Issues

Please see the list of known issues and workarounds before opening an issue!

<details>
<summary>Issues inherited from Mull that still apply to IronFox - (contents adapted from <a href="https://divestos.org/index.php?page=broken#mull)">the DivestOS website</a>) </summary>

* **GrapheneOS** users may encounter a crash with the error `IronFox tried to perform DCL via memory`. Unfortunately, Firefox is incompatible with this hardening feature, so it's not just limited to IronFox. You can fix this issue by navigating to IronFox's app info, scrolling down to the `Exploit protection` section, and setting `Dynamic code loading via memory` to `Allowed`. You can then navigate to `Dynamic code loading via storage`, and set that to `Restricted` - as this hardening feature **is** compatible with Firefox.
* uBlock Origin is the only recommended and supported content blocker.
* Some fonts, particularly ones used for displaying Korean text, [may not display correctly](https://bugzilla.mozilla.org/show_bug.cgi?id=1881993) due the font restrictions by resist fingerprinting. Please do not disable RFP. This should be hopefully fixed in future versions such as v126.
* Dark Reader is known to be incompatible with IronFox's changes and will cause significant breakage/slowdowns.
* Dark mode for websites is disabled due to resist fingerprinting. Please do not disable RFP.
* Refresh rate is capped to 60hz due to resist fingerprinting. Please do not disable RFP.
* Multitouch gestures will not work due to resist fingerprinting. Please do not disable RFP.
* If audio/video content fails to play in private tabs navigate to `about:config` and change `browser.privatebrowsing.forceMediaMemoryCache` to false, this is however a privacy risk.
* IronFox disables the JavaScript JIT to increase security at the cost of slowing down webapps, complex websites, and the PDF viewer. Navigate to `about:config` and change `javascript.options.ion` and `javascript.options.baselinejit` to `true` to restore their performance, though this is not recommended.
* IronFox has strict certificate revocation checks. The CA revocation servers are occasionally down/blocked/inaccessible, so you may see a "Secure Connection Failed" error from time to time. Navigate to `about:config` and change `security.OCSP.require` to `false`, this is however a security and privacy risk.
* IronFox requires safe renegotiation for connections. Certain websites do not support this and will result in a "Secure Connection Failed" error. **Please report these errors to the impacted websites.** You can navigate to `about:config` and set `security.ssl.require_safe_negotiation` to `false` to disable the requirement for safe renegotiations, this is however a security and privacy risk.
* IronFox has strict certificate pinning. If you are using a proxy or VPN that does HTTPS manipulation, you may encounter a "Secure Connection Failed" error. Navigate to `about:config` and change `security.cert_pinning.enforcement_level` from `2` to `1` to disable strict certificate pinning; this is however a security and privacy risk.
* IronFox does not trust user-added CA certificates, you can optionally enable them at your own extreme risk: Settings > About IronFox > Tap IronFox logo until debug settings are enabled > back a menu > Secret Settings > Use third party CA certificates > Enabled, this is however a security and privacy risk.
* IronFox has stripped referrers. This often breaks loading of images on websites with hotlink protection. Navigate to `about:config` and change `network.http.referer.XOriginPolicy` from `2` to `1` *(or `0` if you're still having issues)*, this is however a privacy risk.
* IronFox has visited link highlighting disabled by default. Navigate to `about:config` and change `layout.css.visited_links_enabled` to `true` if needed, this is however a privacy risk.
* IronFox has WebAssembly disabled by default. This is often used for web apps. Navigate to `about:config` and change `javascript.options.wasm` to `true` if needed, this is however a security risk.
* IronFox has WebGL disabled by default. This is often used for games and maps. Navigate to `about:config` and change `webgl.disabled` to `false` if needed, this is however a privacy risk.
* IronFox forcibly excludes private IP addresses from being leaked over WebRTC. This may cause issues with audio/video calls. Navigate to `about:config` and change `media.peerconnection.ice.no_host` to `false` if needed, this is however a privacy risk. If you still have issues, you should also set `media.peerconnection.ice.default_address_only` to `false`.
* If you want to access Onions using IronFox and Orbot: navigate to `about:config` and change `network.dns.blockDotOnion` to `false`. Tor Browser for Android however should be preferred.
* If you have issues playing some videos: navigate to `about:config` and change `media.android-media-codec.preferred` from `true` to `false`. This may reduce battery life.
* When adding a custom search engine that contains a \`:\` you must replace it with \`%3A\` to workaround an upstream substitution bug.
* Upstream issues: [background timers](https://github.com/mozilla-mobile/fenix/issues/26220), [bookmark import/export](https://bugzilla.mozilla.org/show_bug.cgi?id=1806482), [disable images](https://bugzilla.mozilla.org/show_bug.cgi?id=1807116), [download location](https://bugzilla.mozilla.org/show_bug.cgi?id=1812815), [duplicate tab](https://bugzilla.mozilla.org/show_bug.cgi?id=1812931), [FIDO](https://gitlab.com/relan/fennecbuild/-/issues/34), [Fission](https://bugzilla.mozilla.org/show_bug.cgi?id=1610822), [isolatedProcess](https://bugzilla.mozilla.org/show_bug.cgi?id=1565196), [language issues](https://bugzilla.mozilla.org/show_bug.cgi?id=1765375), [open .html file](https://bugzilla.mozilla.org/show_bug.cgi?id=1809954), [RFP canvas exception](https://bugzilla.mozilla.org/show_bug.cgi?id=1801733), [Sync broken by RFP](https://bugzilla.mozilla.org/show_bug.cgi?id=1810741), [touch gestures](https://bugzilla.mozilla.org/show_bug.cgi?id=1800567)

</details>

<details>
<summary>Issues originating in IronFox</summary>

*None yet.* :)

</details>

<br>

You should also see [here](https://phoenix.celenity.dev/compat) for a list of websites with known issues due to hardening, and what you may need to do to fix them. This list is maintained by [Phoenix](https://phoenix.celenity.dev/) - so while it isn't specific to IronFox or Mull, many of these problems do still apply.

## Building

IronFox makes it easier (and faster) to build the project locally.
For example, prebuilt versions of wasi-sdk sysroot and llvm-project are used instead
of building them locally. F-Droid builds still build those from source.

### Build environment

You need to install a few packages on your machine to be able to build IronFox.
Follow the below instructions based on the OS you're using.

<details>
<summary>When building on Ubuntu</summary>

```sh
sudo apt update
sudo apt install -y make \
        cmake \
        clang-18 \
        gyp \
        ninja-build \
        patch \
        perl \
        wget \
        tar \
        unzip \
        xz-utils \
        zlib1g-dev
```

Apart from the above packages, you need to install Python 3.9. You can use [PPA from the `deadsnakes` team](https://launchpad.net/%7Edeadsnakes/+archive/ubuntu/ppa).

You also need to install JDK 8 AND JDK 17. JDK 17 should be set as the
default JDK.

</details>

<details>
<summary>When building on Fedora 41</summary>

```sh
sudo dnf install -y \
    cmake \
    clang \
    gyp \
    java-1.8.0-openjdk-devel \
    java-17-openjdk-devel \
    m4 \
    make \
    ninja-build \
    patch \
    perl \
    python3.9 \
    shasum \
    xz \
    zlib-devel \
    wget \
    git
```

The above command installs all packages (including `python3.9`) that are required
to build IronFox.

</details>

### Build setup

* Setup F-Droid's `gradle` script to be available in your `PATH`:

    ```sh
    mkdir -p $HOME/bin
    wget https://gitlab.com/fdroid/fdroidserver/-/raw/master/gradlew-fdroid -O "$HOME/bin/gradle"
    chmod +x "$HOME/bin/gradle"

    export PATH=$HOME/bin:$PATH
    ```

* Disable Gradle Daemons and configuration cache:

    ```sh
    mkdir -p ~/.gradle
    echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
    echo "org.gradle.configuration-cache=false" >> ~/.gradle/gradle.properties
    ```

* Create a new Python 3.9 virtual environment, then activate it:

    ```sh
    python3.9 -m venv env
    source env/bin/activate
    ```

* Ensure JDK 17 is the default JDK. You can check the current JDK version by running `java --version` in the terminal. Otherwise, you can temporarily set JDK 17 as the default by running:

    **Don't forget to replace `/path/to/jdk-17` below with the actual path of your JDK 17 installation!**

    ```sh
    export JAVA_HOME=/path/to/jdk-17
    export PATH=$JAVA_HOME/bin:$PATH
    ```

    For instance, on **Fedora 41**, the default location of JDK 17 is `/usr/lib/jvm/java-17-openjdk`:

    ```sh
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
    export PATH=$JAVA_HOME/bin:$PATH
    ```

* Ensure that the `ANDROID_HOME` variable points to a valid Android SDK installation. Otherwise, you can execute the following to install and set up the SDK:

    ```sh
    source ./scripts/setup-android-sdk.sh
    ```

### Get & patch sources

Next, you need to download the source files to build. The `scripts/get_sources.sh` file can be used to download/clone the source files.

*This may take some time depending on your network speed...*

```sh
./scripts/get_sources.sh
```

If you need to fetch sources for a different version of Firefox than the one IronFox is currently based on, you'll have to modify the script directly.

Once the source files are downloaded and extracted, you need to source the
`scripts/env_local.sh` script *(generated by `get_sources.sh`)* to set up the required environment variables:

```sh
source scripts/env_local.sh
```

Next, you need to patch the files with:

*This must be run once after getting your sources.*

```sh
./scripts/prebuild.sh <version-name> <version-code>
```

Here `<version-name>` is the display name of the version (e.g. `v133.0.3`) and
`<version-code>` is the numeric identifier of the version you want to build. We follow version code convention similar to Mull. See [version code convention](#version-code-convention).

### Build

Finally, you can start the build process with:

```sh
./scripts/build.sh
```

### Version code convention

Version codes are prepended with `3`, followed by the actual version code, the CPU ABI
identifier and the revision number:

```sh
3<actual-version><abi-identifier><revision>
```

CPU ABI identifier is one of the following:

| Identifier | CPU ABI       |
| ---------- | ------------- |
| 0          | `armeabi-v7a` |
| 1          | `x86_64`      |
| 2          | `arm64-v8a`   |

Revision numbers start from 0 for each major release and are updated when we apply fixes to existing releases.

<details>
<summary>Example</summary>

```sh
Version code : 31330320

3       - version code prefix
13303   - version code for v133.0.3
2       - arm64-v8a
0       - initial build
```

</details>

## Licenses

The scripts are licensed under the [GNU Affero General Public License, version 3 or later](COPYING).

Changes to patches are licensed according to the header in the files this patch adds or modifies ([Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) or [MPL 2.0](https://www.mozilla.org/MPL/)).

[Phoenix](https://phoenix.celenity.dev/) is licensed under the [GNU General Public License, version 3 or later](https://phoenix.celenity.dev/LICENSE).

## Notices

Mozilla Firefox is a trademark of The Mozilla Foundation.

This is not an officially supported Mozilla product. IronFox is in no way affiliated with Mozilla.

IronFox is not sponsored or endorsed by Mozilla.

IronFox is not associated with DivestOS or Divested Computing Group in any manner.

Firefox source code is available at [https://hg.mozilla.org](https://hg.mozilla.org).
