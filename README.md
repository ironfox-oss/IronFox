IronFox
------------

IronFox is a fork of DivestOS's [Mull Browser](https://github.com/Divested-Mobile/Mull-Fenix) based on Firefox. Our goal is to continue the legacy of Mull to provide a secure, hardened and privacy-oriented browser for daily use.

Known Issues
------------
Please see the list of known issues and workarounds before opening an issue!

<details>
<summary>Issues inherited from <a href="https://divestos.org/index.php?page=broken#mull)">Mull</a> that still apply to IronFox *(contents adapted from DivestOS's website)* </summary>

*   uBlock Origin is the only recommended and supported content blocker.
*   Some fonts, particularly ones used for displaying Korean text, [may not display correctly](https://bugzilla.mozilla.org/show_bug.cgi?id=1881993) due the font restrictions by resist fingerprinting. Please do not disable RFP. This should be hopefully fixed in future versions such as v126.
*   Dark Reader is known to be incompatible with IronFox's changes and will cause significant breakage/slowdowns.
*   Dark mode for websites is disabled due to resist fingerprinting. Please do not disable RFP.
*   Refresh rate is capped to 60hz due to resist fingerprinting. Please do not disable RFP.
*   Multitouch gestures will not work due to resist fingerprinting. Please do not disable RFP.
*   If audio/video content fails to play in private tabs navigate to `about:config` and change `browser.privatebrowsing.forceMediaMemoryCache` to false, this is however a privacy risk.
*   IronFox disables the JavaScript JIT to increase security at the cost of slowing down webapps, complex websites, and the PDF viewer. Navigate to `about:config` and change `javascript.options.ion` and `javascript.options.baselinejit` to `true` to restore their performance, though this is not recommended.
*   IronFox has strict certificate revocation checks. The CA revocation servers are occasionally down/blocked/inaccessible, so you may see a "Secure Connection Failed" error from time to time. Navigate to `about:config` and change `security.OCSP.require` to `false`, this is however a security and privacy risk.
*   IronFox requires safe renegotiation for connections. Certain websites do not support this and will result in a "Secure Connection Failed" error. **Please report these errors to the impacted websites.** You can navigate to `about:config` and set `security.ssl.require_safe_negotiation` to `false` to disable the requirement for safe renegotiations, this is however a security and privacy risk.
*   IronFox has strict certificate pinning. If you are using a proxy or VPN that does HTTPS manipulation, you may encounter a "Secure Connection Failed" error. Navigate to `about:config` and change `security.cert_pinning.enforcement_level` from `2` to `1` to disable strict certificate pinning; this is however a security and privacy risk.
*   IronFox does not trust user-added CA certificates, you can optionally enable them at your own extreme risk: Settings > About IronFox > Tap IronFox logo until debug settings are enabled > back a menu > Secret Settings > Use third party CA certificates > Enabled, this is however a security and privacy risk.
*   IronFox has stripped referrers. This often breaks loading of images on websites with hotlink protection. Navigate to `about:config` and change `network.http.referer.XOriginPolicy` from `2` to `1` *(or `0` if you're still having issues)*, this is however a privacy risk.
*   IronFox has visited link highlighting disabled by default. Navigate to `about:config` and change `layout.css.visited_links_enabled` to `true` if needed, this is however a privacy risk.
*   IronFox has WebAssembly disabled by default. This is often used for web apps. Navigate to `about:config` and change `javascript.options.wasm` to `true` if needed, this is however a security risk.
*   IronFox has WebGL disabled by default. This is often used for games and maps. Navigate to `about:config` and change `webgl.disabled` to `false` if needed, this is however a privacy risk.
*   IronFox forcibly excludes private IP addresses from being leaked over WebRTC. This may cause issues with audio/video calls. Navigate to `about:config` and change `media.peerconnection.ice.no_host` to `false` if needed, this is however a privacy risk. If you still have issues, you should also set `media.peerconnection.ice.default_address_only` to `false`.
*   If you want to access Onions using IronFox and Orbot: navigate to `about:config` and change `network.dns.blockDotOnion` to `false`. Tor Browser for Android however should be preferred.
*   If you have issues playing some videos: navigate to `about:config` and change `media.android-media-codec.preferred` from `true` to `false`. This may reduce battery life.
*   When adding a custom search engine that contains a \`:\` you must replace it with \`%3A\` to workaround an upstream substitution bug.
*   Upstream issues: [background timers](https://github.com/mozilla-mobile/fenix/issues/26220), [bookmark import/export](https://bugzilla.mozilla.org/show_bug.cgi?id=1806482), [disable images](https://bugzilla.mozilla.org/show_bug.cgi?id=1807116), [download location](https://bugzilla.mozilla.org/show_bug.cgi?id=1812815), [duplicate tab](https://bugzilla.mozilla.org/show_bug.cgi?id=1812931), [FIDO](https://gitlab.com/relan/fennecbuild/-/issues/34), [Fission](https://bugzilla.mozilla.org/show_bug.cgi?id=1610822), [isolatedProcess](https://bugzilla.mozilla.org/show_bug.cgi?id=1565196), [language issues](https://bugzilla.mozilla.org/show_bug.cgi?id=1765375), [open .html file](https://bugzilla.mozilla.org/show_bug.cgi?id=1809954), [RFP canvas exception](https://bugzilla.mozilla.org/show_bug.cgi?id=1801733), [Sync broken by RFP](https://bugzilla.mozilla.org/show_bug.cgi?id=1810741), [touch gestures](https://bugzilla.mozilla.org/show_bug.cgi?id=1800567)

</details>

<details>
<summary>Issues originating in IronFox</summary>

_None yet._

</details>

You should also see [here](https://phoenix.celenity.dev/compat) for a list of websites with known issues due to hardening, and what you may need to do to fix them. This list is maintained by [Phoenix](https://phoenix.celenity.dev/) - so while it isn't specific to IronFox or Mull, many of these problems do still apply.

Building
--------

IronFox makes it easier (and faster) to build the project locally.
For example, prebuilt versions of wasi-sdk sysroot and llvm-project are used instead
of building them locally. F-Droid builds still build those from source.

### Build environment

You need to install a few packages on your machine to be able to build IronFox.
Follow the below instructions based on the OS you're using.

<details>
<summary>When building on Ubuntu</summary>

```
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

```
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

- Setup F-Droid's `gradle` script to be available in your `PATH` :

    ```
    mkdir -p $HOME/bin
    wget https://gitlab.com/fdroid/fdroidserver/-/raw/master/gradlew-fdroid -O "$HOME/bin/gradle"
    chmod +x "$HOME/bin/gradle"

    export PATH=$HOME/bin:$PATH
    ```

- Disable Gradle Daemons and configuration cache :

    ```
    mkdir -p ~/.gradle
    echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
    echo "org.gradle.configuration-cache=false" >> ~/.gradle/gradle.properties
    ```

- Create a new Python 3.9 virtual environment, then activate it :
    ```
    python3.9 -m venv env
    source env/bin/activate
    ```

- Ensure JDK 17 is the default JDK. You can check the current JDK version by running `java --version` in the terminal. Otherwise, you can temporarily set JDK 17 as the default by running :
    ```bash
    export JAVA_HOME=/path/to/jdk-17
    export PATH=$JAVA_HOME/bin:$PATH
    ```

- Ensure that `ANDROID_HOME` variable is set to point to a valid Android SDK installation. Otherwise, you can execute the following to install and set up the SDK :
    ```bash
    source ./scripts/setup-android-sdk.sh
    ```

### Get & patch sources

Next, you need to download the source files to build. The `scripts/get_sources.sh` file can be used to download/clone the source files.

```bash
# This may take some time depending on your network speed
./scripts/get_sources.sh
```

If you need to fetch sources for other versions of Firefox, you'll have to modify the
script directly.

Once the source files are downloaded and extracted, you need to source the
`scripts/paths_local.sh` script (generated by `get_sources.sh`) to set up the required 
environment variables :

```bash
source scripts/paths_local.sh
```

Next, you need to patch the files with :

```bash
# Required to run once, after getting sources
./scripts/prebuild.sh <version-name> <version-code>
```

Here `<version-name>` is the display name of the version (e.g. `v133.0.3`) and
`<version-code>` is the numeric identifier of the version you want to build. We follow
version code convention similar to Mull. See [version code convention](#version-code-convention).

### Build

Finally you can start the build process with :

```bash
./scripts/build.sh
```

Version code convention
-----------------------

Version codes are prepended with `3`, followed by the actual version code, the CPU ABI
identifier and the revision number :

```
3<actual-version><abi-identifier><revision>
```

CPU ABI identifier is one of the following :

| Identifier | CPU ABI       |
| ---------- | ------------- |
| 0          | `armeabi-v7a` |
| 1          | `x86_64`      |
| 2          | `arm64-v8a`   |

Revision numbers start from 0 for each major release and are updated when we apply fixes 
to existing releases.

<details>
<summary>Example</summary>

```
Version code : 31330320

3       - version code prefix
13303   - version code for v133.0.3
2       - arm64-v8a
0       - initial build
```

</details>

Licenses
--------

The scripts are licensed under the GNU Affero General Public License version 3 or later.

Changes in the patch are licensed according to the header in the files this patch adds 
or modifies (Apache 2.0 or MPL 2.0).

The userjs-00-arkenfox.js file is licensed under MIT.

Notices
-------

Mozilla Firefox is a trademark of The Mozilla Foundation

This is not an officially supported Mozilla product. IronFox is in no way affiliated with Mozilla.

IronFox is not sponsored or endorsed by Mozilla.

IronFox is not associated with DivestOS or Divested Computing Group in any manner.

Firefox source code is available at https://hg.mozilla.org
