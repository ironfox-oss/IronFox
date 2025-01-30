#!/bin/bash
#
#    Fennec build scripts
#    Copyright (C) 2020-2024  Matías Zúñiga, Andrew Nayenko, Tavi
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

set -e

function localize_maven {
    # Replace custom Maven repositories with mavenLocal()
    find ./* -name '*.gradle' -type f -print0 | xargs -0 \
        sed -n -i \
        -e '/maven {/{:loop;N;/}$/!b loop;/plugins.gradle.org/!s/maven .*/mavenLocal()/};p'
    # Make gradlew scripts call our Gradle wrapper
    find ./* -name gradlew -type f | while read -r gradlew; do
        echo -e '#!/bin/sh\ngradle "$@"' >"$gradlew"
        chmod 755 "$gradlew"
    done
}

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 versionName versionCode" >&1
    exit 1
fi

if [[ -n ${FDROID_BUILD+x} ]]; then
    source "$(dirname "$0")/setup-android-sdk.sh"
    source "$(dirname "$0")/env_fdroid.sh"
fi

# shellcheck disable=SC2154
if [[ "$env_source" != "true" ]]; then
    echo "Use 'source scripts/env_local.sh' before calling prebuild or build"
    exit 1
fi

if [ ! -d "$ANDROID_HOME" ]; then
    echo "\$ANDROID_HOME($ANDROID_HOME) does not exist."
    exit 1
fi

if [ ! -d "$ANDROID_NDK" ]; then
    echo "\$ANDROID_NDK($ANDROID_NDK) does not exist."
    exit 1
fi

JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{sub("^$", "0", $2); print $1$2}')
[ "$JAVA_VER" -ge 15 ] || { echo "Java 17 or newer must be set as default JDK"; exit 1; };

if [[ -z "${SB_GAPI_KEY_FILE}" ]]; then
    echo "SB_GAPI_KEY_FILE environment variable has not been specified! Safe Browsing will not be supported in this build."
    read -p "Do you want to continue [y/N] " -n 1 -r
    echo ""
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting..."
        exit 1
    fi
fi

# Create build directory
mkdir -p "$rootdir/build"

if [[ -n ${FDROID_BUILD+x} ]]; then
    # Set up Rust
    # shellcheck disable=SC2154
    "$rustup"/rustup-init.sh -y --no-update-default-toolchain
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-update-default-toolchain
fi

if grep -q "Fedora" /etc/os-release; then
    export libclang=/usr/lib64
else
    # shellcheck disable=SC2154
    export libclang="${builddir}/libclang"
    mkdir -p "$libclang"

    # TODO: Maybe find a way to not hardcode this?
    ln -sf "/usr/lib/x86_64-linux-gnu/libclang-18.so.1" "$libclang/libclang.so"
fi

echo "...libclang dir set to ${libclang}"

# shellcheck disable=SC1090,SC1091
source "$HOME/.cargo/env"
rustup default 1.82.0
rustup target add thumbv7neon-linux-androideabi
rustup target add armv7-linux-androideabi
rustup target add aarch64-linux-android
rustup target add x86_64-linux-android
cargo install --vers 0.26.0 cbindgen

# Fenix
# shellcheck disable=SC2154
pushd "$fenix"

# Set up the app ID, version name and version code
sed -i \
    -e 's|applicationId "org.mozilla"|applicationId "org.ironfoxoss"|' \
    -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' \
    -e 's|"sharedUserId": "org.mozilla.firefox.sharedID"|"sharedUserId": "org.ironfoxoss.ironfox.sharedID"|' \
    -e "s/Config.releaseVersionName(project)/'$1'/" \
    -e "s/Config.generateFennecVersionCode(arch, aab)/$2/" \
    app/build.gradle
sed -i \
    -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox/' \
    app/src/release/res/xml/shortcuts.xml

# Disable crash reporting
sed -i -e '/CRASH_REPORTING/s/true/false/' app/build.gradle

# Disable MetricController
sed -i -e '/TELEMETRY/s/true/false/' app/build.gradle

# Let it be IronFox
sed -i \
    -e 's/Firefox Daylight/IronFox/; s/Firefox/IronFox/g' \
    -e '/about_content/s/Mozilla/the IronFox Developers/' \
    app/src/*/res/values*/*strings.xml

# Fenix uses reflection to create a instance of profile based on the text of
# the label, see
# app/src/main/java/org/mozilla/fenix/perf/ProfilerStartDialogFragment.kt#185
sed -i \
    -e '/Firefox(.*, .*)/s/Firefox/IronFox/' \
    -e 's/firefox_threads/ironfox_threads/' \
    -e 's/firefox_features/ironfox_features/' \
    app/src/main/java/org/mozilla/fenix/perf/ProfilerUtils.kt

# Replace proprietary artwork
rm app/src/release/res/drawable/ic_launcher_foreground.xml
rm app/src/release/res/mipmap-*/ic_launcher.webp
rm app/src/release/res/values/colors.xml
rm app/src/main/res/values-v24/styles.xml
sed -i -e '/android:roundIcon/d' app/src/main/AndroidManifest.xml
sed -i -e '/SplashScreen/,+5d' app/src/main/res/values-v27/styles.xml
# shellcheck disable=SC2154
find "$patches/fenix-overlay" -type f | while read -r src; do
    dst=app/src/release/${src#"$patches/fenix-overlay/"}
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
done
sed -i \
    -e 's/googleg_standard_color_18/ic_download/' \
    app/src/main/java/org/mozilla/fenix/components/menu/compose/ExtensionsSubmenu.kt \
    app/src/main/java/org/mozilla/fenix/components/menu/compose/MenuItem.kt \
    app/src/main/java/org/mozilla/fenix/compose/list/ListItem.kt

# Enable about:config
sed -i \
    -e 's/aboutConfigEnabled(.*)/aboutConfigEnabled(true)/' \
    app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt

# Enable cookie banner handling
sed -i \
    -e '168s/channel: developer/channel: release/' app/nimbus.fml.yaml

# Set up target parameters
case $(echo "$2" | cut -c 7) in
0)
    # APK for armeabi-v7a
    abi='"armeabi-v7a"'
    target=arm-linux-androideabi
    llvmtarget="ARM"
    rusttarget=arm
    ;;
1)
    # APK for x86_64
    abi='"x86_64"'
    target=x86_64-linux-android
    llvmtarget="X86_64"
    rusttarget=x86_64
    ;;
2)
    # APK for arm64-v8a
    abi='"arm64-v8a"'
    target=aarch64-linux-android
    llvmtarget="AArch64"
    rusttarget=arm64
    ;;
3)
    # AAB for both armeabi-v7a and arm64-v8a
    abi='"arm64-v8a", "armeabi-v7a", "x86_64"'
    target=''
    llvmtarget="AArch64;ARM;X86_64"
    rusttarget='arm64,arm,x86_64'
    ;;
*)
    echo "Unknown target code in $2." >&2
    exit 1
    ;;
esac

sed -i -e "s/include \".*\"/include $abi/" app/build.gradle
echo "$llvmtarget" >"$builddir/targets_to_build"

# Enable the auto-publication workflow
# shellcheck disable=SC2154
echo "autoPublish.application-services.dir=$application_services" >>local.properties
popd

#
# Glean
#

# shellcheck disable=SC2154
pushd "$glean"
echo "rust.targets=linux-x86-64,$rusttarget" >>local.properties
localize_maven
popd

#
# Android Components
#

# shellcheck disable=SC2154
pushd "$android_components"
find "$patches/a-c-overlay" -type f | while read -r src; do
    cp "$src" "${src#"$patches/a-c-overlay/"}"
done
# Add the added search engines as `general` engines
sed -i \
    -e '41i \ \ \ \ "brave",\n\ \ \ \ "ddghtml",\n\ \ \ \ "ddglite",\n\ \ \ \ "metager",\n\ \ \ \ "mojeek",\n\ \ \ \ "qwantlite",\n\ \ \ \ "startpage",' \
    components/feature/search/src/main/java/mozilla/components/feature/search/storage/SearchEngineReader.kt
# Hack to prevent too long string from breaking build
sed -i '/val statusCmd/,+3d' plugins/config/src/main/java/ConfigPlugin.kt
sed -i '/\/\/ Append "+"/a \        val statusSuffix = "+"' plugins/config/src/main/java/ConfigPlugin.kt
popd

# Application Services

pushd "$application_services"
# Break the dependency on older A-C
sed -i -e '/android-components = /s/132\.0/134.0.2/' gradle/libs.versions.toml
echo "rust.targets=linux-x86-64,$rusttarget" >>local.properties
sed -i -e '/NDK ez-install/,/^$/d' libs/verify-android-ci-environment.sh
sed -i -e '/content {/,/}/d' build.gradle
localize_maven
# Fix stray
sed -i -e '/^    mavenLocal/{n;d}' tools/nimbus-gradle-plugin/build.gradle
# Fail on use of prebuilt binary
sed -i 's|https://|hxxps://|' tools/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy
popd

# WASI SDK
# shellcheck disable=SC2154
if [[ -n ${FDROID_BUILD+x} ]]; then
    pushd "$wasi"
    patch -p1 --no-backup-if-mismatch --quiet <"$mozilla_release/taskcluster/scripts/misc/wasi-sdk.patch"
    popd

    export wasi_install=$wasi/build/install/wasi
else
    export wasi_install=$wasi
fi

# GeckoView
pushd "$mozilla_release"

# Remove Mozilla repositories substitution and explicitly add the required ones
patch -p1 --no-backup-if-mismatch --quiet <"$patches/gecko-localize_maven.patch"

# Replace GMS with microG client library
patch -p1 --no-backup-if-mismatch --quiet <"$patches/gecko-liberate.patch"

# Patch the use of proprietary and tracking libraries
patch -p1 --no-backup-if-mismatch --quiet <"$patches/fenix-liberate.patch"

# Support spoofing locale to 'en-US'
patch -p1 --no-backup-if-mismatch --quiet <"$patches/tor-spoof-english.patch"

# Add a toggle in settings for spoofing locale to 'en-US'
patch -p1 --no-backup-if-mismatch --quiet <"$patches/tor-spoof-english-switch.patch"

# Set strict ETP by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/strict_etp.patch"

# Enable HTTPS only mode by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/https_only.patch"

# Enable Global Privacy Control by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/global-privacy-control.patch"

# Disable search suggestions by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-search-suggestions.patch"

# Disable autocomplete by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-autocomplete.patch"

# Disable shipped domains - These haven't been updated in several years, posing security concerns - and are also just annoying...
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-shipped-domains.patch"

# Disable password manager/autofill for login info by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-login-autofill.patch"

# Disable credit card/address autofill by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-autofill.patch"

# Clear open tabs, browsing history, cache, & download list on exit by default
#patch -p1 --no-backup-if-mismatch --quiet <"$patches/sanitize-on-exit.patch"

# Disable 'Meta Attribution' - just more telemetry - used to track referrals
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-meta-attribution.patch"

# Disable Campaign Growth Data Measurement - more telemetry :/
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-campaign-growth-data-measurement.patch"

# Disable Firefox Suggest
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-firefox-suggest.patch"

# Enable "Zoom on all websites" by default - allows always zooming into websites, even if they try to block it...
patch -p1 --no-backup-if-mismatch --quiet <"$patches/force-enable-zoom.patch"

# Disable Contextual Feature Recommendations
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-cfrs.patch"

# Disable more Pocket crap not already covered...
patch -p1 --no-backup-if-mismatch --quiet <"$patches/kill-pocket.patch"

# Disable Mozilla Feedback Surveys (Microsurveys)
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-microsurveys.patch"

# Enable per-site process isolation (Fission)
patch -p1 --no-backup-if-mismatch --quiet <"$patches/enable-fission.patch"

# Expose UI option to toggle Fission, only available in Nightly by default...
patch -p1 --no-backup-if-mismatch --quiet <"$patches/control-fission.patch"

# Enable FPP (Fingerprinting Protection)
patch -p1 --no-backup-if-mismatch --quiet <"$patches/enable-fingerprinting-protection.patch"

# Disable Fakespot ("Shopping Experience"...)
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-shopping-experience.patch"

# Remove tracking parameters from URLs
patch -p1 --no-backup-if-mismatch --quiet <"$patches/remove-tracking-params.patch"

# Block cookie banners by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/block-cookie-banners.patch"

# Block third party cookies by default (Ex. how ETP Strict on desktop behaves...)
patch -p1 --no-backup-if-mismatch --quiet <"$patches/block-third-party-cookies.patch"

# Switch the built-in extension recommendations page to use our collection instead of Mozilla's...
patch -p1 --no-backup-if-mismatch --quiet <"$patches/extension-recommendations.patch"

# Switch Firefox's onboarding to recommend our extension(s) instead of Mozilla's...
patch -p1 --no-backup-if-mismatch --quiet <"$patches/extension-onboarding.patch"

# Disable menu item to report issues with websites to Mozilla...
patch -p1 --no-backup-if-mismatch --quiet <"$patches/disable-reporting-site-issues.patch"

# Tweak Safe Browsing (See '009 SAFE BROWSING' in Phoenix for more details...)
patch -p1 --no-backup-if-mismatch --quiet <"$patches/configure-safe-browsing.patch"

# Tweak PDF.js (We currently disable JavaScript & XFA + enable sidebar by default)
patch -p1 --no-backup-if-mismatch --quiet <"$patches/configure-pdfjs.patch"

# Remove default top sites/shortcuts
patch -p1 --no-backup-if-mismatch --quiet <"$patches/remove-default-sites.patch"

# Enable preference to toggle default desktop mode
patch -p1 --no-backup-if-mismatch --quiet <"$patches/enable-default-desktop-mode.patch"

# Enable preference to toggle tap strip https://gitlab.com/ironfox-oss/IronFox/-/issues/27
patch -p1 --no-backup-if-mismatch --quiet <"$patches/enable-tap-strip.patch"

# Ensure we're disabling telemetry at buildtime...
patch -p1 --no-backup-if-mismatch --quiet <"$patches/buildtime-disable-telemetry.patch"

# Enable Firefox's newer 'Felt privacy' design for Private Browsing by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/enable-felt-privacy.patch"

# Fix v125 compile error
patch -p1 --no-backup-if-mismatch --quiet <"$patches/gecko-fix-125-compile.patch"

# Fix v125 aar output not including native libraries
sed -i \
    -e 's/singleVariant("debug")/singleVariant("release")/' \
    mobile/android/exoplayer2/build.gradle
sed -i \
    -e "s/singleVariant('debug')/singleVariant('release')/" \
    mobile/android/geckoview/build.gradle

# Hack the timeout for
# geckoview:generateJNIWrappersForGeneratedWithGeckoBinariesDebug
sed -i \
    -e 's/max_wait_seconds=600/max_wait_seconds=1800/' \
    mobile/android/gradle.py

# Set the Safe Browsing API URL to our proxy
sed -i "s|safebrowsing.googleapis.com/v4/|safebrowsing.ironfoxoss.org/v4/|g" \
    mobile/android/geckoview/src/main/java/org/mozilla/geckoview/ContentBlocking.java

# shellcheck disable=SC2154
if [[ -n ${FDROID_BUILD+x} ]]; then
    # Patch the LLVM source code
    # Search clang- in https://android.googlesource.com/platform/ndk/+/refs/tags/ndk-r27/ndk/toolchains.py
    LLVM_SVN='522817'
    python3 "$toolchain_utils/llvm_tools/patch_manager.py" \
        --svn_version $LLVM_SVN \
        --patch_metadata_file "$llvm_android/patches/PATCHES.json" \
        --src_path "$llvm"
fi
{
    echo 'ac_add_options --disable-crashreporter'
    echo 'ac_add_options --disable-debug'
    echo 'ac_add_options --disable-nodejs'
    echo 'ac_add_options --disable-profiling'
    echo 'ac_add_options --disable-rust-debug'
    echo 'ac_add_options --disable-tests'
    echo 'ac_add_options --disable-updater'
    echo 'ac_add_options --enable-application=mobile/android'
    echo 'ac_add_options --enable-hardening'
    echo 'ac_add_options --enable-optimize'
    echo 'ac_add_options --enable-release'
    echo 'ac_add_options --enable-minify=properties'
    echo 'ac_add_options --enable-update-channel=release'
    echo 'ac_add_options --enable-rust-simd'
    echo 'ac_add_options --enable-strip'
    echo "ac_add_options --with-java-bin-path=\"$JAVA_HOME/bin\""

    if [[ -n "${target}" ]]; then
        echo "ac_add_options --target=$target"
    fi

    echo "ac_add_options --with-android-ndk=\"$ANDROID_NDK\""
    echo "ac_add_options --with-android-sdk=\"$ANDROID_HOME\""
    echo "ac_add_options --with-gradle=$(command -v gradle)"
    echo "ac_add_options --with-libclang-path=\"$libclang\""
    echo "ac_add_options --with-wasi-sysroot=\"$wasi_install/share/wasi-sysroot\""

    if [[ -n ${SB_GAPI_KEY_FILE+x} ]]; then
        echo "ac_add_options --with-google-safebrowsing-api-keyfile=${SB_GAPI_KEY_FILE}"
    fi

    echo "ac_add_options WASM_CC=\"$wasi_install/bin/clang\""
    echo "ac_add_options WASM_CXX=\"$wasi_install/bin/clang++\""
    echo "ac_add_options CC=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang\""
    echo "ac_add_options CXX=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++\""
    echo "ac_add_options STRIP=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip\""
    echo 'mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj'
} >> mozconfig

# Configure
sed -i -e '/check_android_tools("emulator"/d' build/moz.configure/android-sdk.configure

# Disable Gecko Media Plugins and casting
sed -i -e '/gmp-provider/d; /casting.enabled/d' mobile/android/app/geckoview-prefs.js
# shellcheck disable=SC2129
cat <<EOF >>mobile/android/app/geckoview-prefs.js

// Disable Gecko Media Plugins
pref("media.gmp-provider.enabled", false);

// Avoid openh264 being downloaded
pref("media.gmp-manager.url.override", "data:text/plain,");

// Disable openh264 if it is already downloaded
pref("media.gmp-gmpopenh264.enabled", false);
EOF

cat "$patches/preferences/phoenix-android.js" >>mobile/android/app/geckoview-prefs.js
cat "$patches/preferences/phoenix-extended-android.js" >>mobile/android/app/geckoview-prefs.js
cat "$patches/preferences/ironfox.js" >>mobile/android/app/geckoview-prefs.js

popd
