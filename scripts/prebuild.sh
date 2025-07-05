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

# Include version info
source "$rootdir/scripts/versions.sh"

function localize_maven {
    # Replace custom Maven repositories with mavenLocal()
    find ./* -name '*.gradle' -type f -exec python3 "$rootdir/scripts/localize_maven.py" {} \;
    # Make gradlew scripts call our Gradle wrapper
    find ./* -name gradlew -type f | while read -r gradlew; do
        echo -e '#!/bin/sh\ngradle "$@"' >"$gradlew"
        chmod 755 "$gradlew"
    done
}

function remove_glean_telemetry() {
    local dir="$1"
    local telemetry_url="incoming.telemetry.mozilla.org"

    # Set telemetry URL to an invalid localhost address
    grep -rnlI "${dir}" -e "${telemetry_url}" | xargs -L1 sed -i -r -e "s|${telemetry_url}|localhost:70000|g"
}

if [ -z "$1" ]; then
    echo "Usage: $0 arm|arm64|x86_64|bundle" >&1
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
[ "$JAVA_VER" -ge 15 ] || {
    echo "Java 17 or newer must be set as default JDK"
    exit 1
}

if [[ -z "$FIREFOX_VERSION" ]]; then
    echo "\$FIREFOX_VERSION is not set! Aborting..."]
    exit 1
fi

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
mkdir -vp "$rootdir/build"

# Check patch files
source "$rootdir/scripts/patches.sh"

pushd "$mozilla_release"
if ! check_patches; then
    echo "Patch validation failed. Please check the patch files and try again."
    exit 1
fi
popd

if [[ -n ${FDROID_BUILD+x} ]]; then
    # Set up Rust
    # shellcheck disable=SC2154
    "$rustup"/rustup-init.sh -y --no-update-default-toolchain
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-update-default-toolchain
fi

libclang="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/musl/lib"
echo "...libclang dir set to ${libclang}"

# shellcheck disable=SC1090,SC1091
source "$CARGO_HOME/env"
rustup default "$RUST_VERSION"
rustup target add thumbv7neon-linux-androideabi
rustup target add armv7-linux-androideabi
rustup target add aarch64-linux-android
rustup target add x86_64-linux-android
cargo install --vers "$CBINDGEN_VERSION" cbindgen

# Fenix
# shellcheck disable=SC2154
pushd "$fenix"

# Set up the app ID, version name and version code
sed -i \
    -e 's|applicationId "org.mozilla"|applicationId "org.ironfoxoss"|' \
    -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' \
    -e 's|"sharedUserId": "org.mozilla.firefox.sharedID"|"sharedUserId": "org.ironfoxoss.ironfox.sharedID"|' \
    -e "s/Config.releaseVersionName(project)/'${IRONFOX_VERSION}'/" \
    app/build.gradle
sed -i \
    -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox/' \
    app/src/release/res/xml/shortcuts.xml

# Set flag for 'official' builds to ensure we're not enabling debug/dev settings
# https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/27623
# We're also setting the "MOZILLA_OFFICIAL" env variable below
sed -i -e '/MOZILLA_OFFICIAL/s/false/true/' app/build.gradle
echo "official=true" >>local.properties

# Ensure we enable the about:config
# Should be unnecessary since we enforce the 'general.aboutConfig.enable' pref, but doesn't hurt to set anyways...
sed -i -e 's/aboutConfigEnabled(.*)/aboutConfigEnabled(true)/' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt

# No-op Glean
# https://searchfox.org/mozilla-central/rev/31123021/mobile/android/fenix/app/build.gradle#443
echo 'glean.custom.server.url="data;"' >>local.properties

# Let it be IronFox
sed -i \
    -e 's/Notifications help you stay safer with Firefox/Enable notifications/' \
    -e 's/Securely send tabs between your devices and discover other privacy features in Firefox./IronFox can remind you when private tabs are open and show you the progress of file downloads./' \
    -e 's/Agree and continue/Continue/' \
    -e 's/Firefox Daylight/IronFox/; s/Firefox Fenix/IronFox/; s/Mozilla Firefox/IronFox/; s/Firefox/IronFox/g' \
    -e 's/Fast and secure web browsing/The private and secure Firefox-based web browser for Android/' \
    -e '/about_content/s/Mozilla/IronFox OSS/' \
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
rm -vf app/src/release/res/drawable/ic_launcher_foreground.xml
rm -vf app/src/release/res/mipmap-*/ic_launcher.webp
rm -vf app/src/release/res/values/colors.xml
rm -vf app/src/main/res/values-v24/styles.xml
sed -i -e '/android:roundIcon/d' app/src/main/AndroidManifest.xml
sed -i -e '/SplashScreen/,+5d' app/src/main/res/values-v27/styles.xml
mkdir -vp app/src/release/res/mipmap-anydpi-v26
sed -i \
    -e 's/googleg_standard_color_18/ic_download/' \
    app/src/main/java/org/mozilla/fenix/components/menu/compose/ExtensionsSubmenu.kt \
    app/src/main/java/org/mozilla/fenix/components/menu/compose/MenuItem.kt \
    app/src/main/java/org/mozilla/fenix/compose/list/ListItem.kt

# Remove default built-in search engines
rm -vrf app/src/main/assets/searchplugins/*

# Set up target parameters
case "$1" in
arm)
    # APK for armeabi-v7a
    abi='"armeabi-v7a"'
    target=arm-linux-androideabi
    llvmtarget="ARM"
    rusttarget=arm
    ;;
x86_64)
    # APK for x86_64
    abi='"x86_64"'
    target=x86_64-linux-android
    llvmtarget="X86_64"
    rusttarget=x86_64
    ;;
arm64)
    # APK for arm64-v8a
    abi='"arm64-v8a"'
    target=aarch64-linux-android
    llvmtarget="AArch64"
    rusttarget=arm64
    ;;
bundle)
    # AAB for both armeabi-v7a and arm64-v8a
    abi='"arm64-v8a", "armeabi-v7a", "x86_64"'
    target=''
    llvmtarget="AArch64;ARM;X86_64"
    rusttarget='arm64,arm,x86_64'
    ;;
*)
    echo "Unknown build variant: '$1'" >&2
    exit 1
    ;;
esac

sed -i -e "s/include \".*\"/include $abi/" app/build.gradle
echo "$llvmtarget" >"$builddir/targets_to_build"

# Enable the auto-publication workflow
# shellcheck disable=SC2154
echo "autoPublish.application-services.dir=$application_services" >>local.properties

# Disable FUS Service or we'll get errors like:
# Exception while loading configuration for :app: Could not load the value of field `__buildFusService__` of task `:app:compileFenixReleaseKotlin` of type `org.jetbrains.kotlin.gradle.tasks.KotlinCompile`.
echo "kotlin.internal.collectFUSMetrics=false" >> local.properties

find "$patches/fenix-overlay" -type f | while read -r src; do
    cp -vrf "$src" "${src#"$patches/fenix-overlay/"}"
done

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

# Remove default built-in search engines
rm -vrf components/feature/search/src/main/assets/searchplugins/*

# Nuke the "Mozilla Android Components - Ads Telemetry" & "Mozilla Android Components - Search Telemetry" extensions
# We don't install these with fenix-disable-telemetry.patch - so no need to keep the files around...
rm -vrf components/feature/search/src/main/assets/extensions/ads
rm -vrf components/feature/search/src/main/assets/extensions/search

# Remove the 'search telemetry' config...
rm -vf components/feature/search/src/main/assets/search/search_telemetry_v2.json

find "$patches/a-c-overlay" -type f | while read -r src; do
    cp -vrf "$src" "${src#"$patches/a-c-overlay/"}"
done

popd

# Application Services

pushd "$application_services"
# Break the dependency on older A-C
sed -i -e "/^android-components = \"/c\\android-components = \"${FIREFOX_VERSION}\"" gradle/libs.versions.toml
echo "rust.targets=linux-x86-64,$rusttarget" >>local.properties
sed -i -e '/NDK ez-install/,/^$/d' libs/verify-android-ci-environment.sh
sed -i -e '/content {/,/}/d' build.gradle
localize_maven
# Fix stray
sed -i -e '/^    mavenLocal/{n;d}' tools/nimbus-gradle-plugin/build.gradle
# Fail on use of prebuilt binary
sed -i 's|https://|hxxps://|' tools/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy
patch -p1 --no-backup-if-mismatch --quiet < "$patches/ac-disable-nimbus.patch"
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

# Let it be IronFox (part 2...)
mkdir -vp mobile/android/branding/ironfox/content
mkdir -vp mobile/android/branding/ironfox/locales/en-US
sed -i -e 's/Fennec/IronFox/; s/Firefox/IronFox/g' build/moz.configure/init.configure

# Apply patches
apply_patches

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

# Remove glean telemetry URL
remove_glean_telemetry "${glean}"
remove_glean_telemetry "${application_services}"
remove_glean_telemetry "${mozilla_release}/browser"
remove_glean_telemetry "${mozilla_release}/modules"
remove_glean_telemetry "${mozilla_release}/toolkit"
remove_glean_telemetry "${mozilla_release}/netwerk"

# Take back control of preferences
## This prevents GeckoView from overriding the follow prefs at runtime, which also means we don't have to worry about Nimbus overriding them, etc...
## The prefs will instead take the values we specify in the phoenix/ironfox .js files, and users will also be able to override them via the `about:config`
## This is ideal for features that aren't exposed by the UI, it gives more freedom/control back to users, and it's great to ensure things are always configured how we want them...
sed -i \
    -e 's|"browser.safebrowsing.malware.enabled"|"z99.ignore.browser.safebrowsing.malware.enabled"|' \
    -e 's|"browser.safebrowsing.phishing.enabled"|"z99.ignore.browser.safebrowsing.phishing.enabled"|' \
    -e 's|"browser.safebrowsing.provider."|"z99.ignore.browser.safebrowsing.provider."|' \
    -e 's|"cookiebanners.service.enableGlobalRules"|"z99.ignore.cookiebanners.service.enableGlobalRules"|' \
    -e 's|"cookiebanners.service.enableGlobalRules.subFrames"|"z99.ignore.cookiebanners.service.enableGlobalRules.subFrames"|' \
    -e 's|"cookiebanners.service.mode"|"z99.ignore.cookiebanners.service.mode"|' \
    -e 's|"privacy.query_stripping.allow_list"|"z99.ignore.privacy.query_stripping.allow_list"|' \
    -e 's|"privacy.query_stripping.enabled"|"z99.ignore.privacy.query_stripping.enabled"|' \
    -e 's|"privacy.query_stripping.enabled.pbmode"|"z99.ignore.privacy.query_stripping.enabled.pbmode"|' \
    -e 's|"privacy.query_stripping.strip_list"|"z99.ignore.privacy.query_stripping.strip_list"|' \
    mobile/android/geckoview/src/main/java/org/mozilla/geckoview/ContentBlocking.java

sed -i \
    -e 's|"apz.allow_double_tap_zooming"|"z99.ignore.apz.allow_double_tap_zooming"|' \
    -e 's|"browser.display.use_document_fonts"|"z99.ignore.browser.display.use_document_fonts"|' \
    -e 's|"docshell.shistory.sameDocumentNavigationOverridesLoadType"|"z99.ignore.docshell.shistory.sameDocumentNavigationOverridesLoadType"|' \
    -e 's|"docshell.shistory.sameDocumentNavigationOverridesLoadType.forceDisable"|"z99.ignore.docshell.shistory.sameDocumentNavigationOverridesLoadType.forceDisable"|' \
    -e 's|"dom.ipc.processCount"|"z99.ignore.dom.ipc.processCount"|' \
    -e 's|"dom.manifest.enabled"|"z99.ignore.dom.manifest.enabled"|' \
    -e 's|"extensions.webapi.enabled"|"z99.ignore.extensions.webapi.enabled"|' \
    -e 's|"extensions.webextensions.crash.threshold"|"z99.ignore.extensions.webextensions.crash.threshold"|' \
    -e 's|"extensions.webextensions.crash.timeframe"|"z99.ignore.extensions.webextensions.crash.timeframe"|' \
    -e 's|"extensions.webextensions.remote"|"z99.ignore.extensions.webextensions.remote"|' \
    -e 's|"fission.autostart"|"z99.ignore.fission.autostart"|' \
    -e 's|"fission.disableSessionHistoryInParent"|"z99.ignore.fission.disableSessionHistoryInParent"|' \
    -e 's|"fission.webContentIsolationStrategy"|"z99.ignore.fission.webContentIsolationStrategy"|' \
    -e 's|"formhelper.autozoom"|"z99.ignore.formhelper.autozoom"|' \
    -e 's|"general.aboutConfig.enable"|"z99.ignore.general.aboutConfig.enable"|' \
    -e 's|"javascript.options.mem.gc_parallel_marking"|"z99.ignore.javascript.options.mem.gc_parallel_marking"|' \
    -e 's|"javascript.options.use_fdlibm_for_sin_cos_tan"|"z99.ignore.javascript.options.use_fdlibm_for_sin_cos_tan"|' \
    -e 's|"network.cookie.cookieBehavior.optInPartitioning"|"z99.ignore.network.cookie.cookieBehavior.optInPartitioning"|' \
    -e 's|"network.cookie.cookieBehavior.optInPartitioning.pbmode"|"z99.ignore.network.cookie.cookieBehavior.optInPartitioning.pbmode"|' \
    -e 's|"network.android_doh.autoselect_enabled"|"z99.ignore.network.android_doh.autoselect_enabled"|' \
    -e 's|"network.fetchpriority.enabled"|"z99.ignore.network.fetchpriority.enabled"|' \
    -e 's|"network.http.http3.enable_kyber"|"z99.ignore.network.http.http3.enable_kyber"|' \
    -e 's|"network.http.largeKeepaliveFactor"|"z99.ignore.network.http.largeKeepaliveFactor"|' \
    -e 's|"network.security.ports.banned"|"z99.ignore.network.security.ports.banned"|' \
    -e 's|"privacy.fingerprintingProtection"|"z99.ignore.privacy.fingerprintingProtection"|' \
    -e 's|"privacy.fingerprintingProtection.overrides"|"z99.ignore.privacy.fingerprintingProtection.overrides"|' \
    -e 's|"privacy.fingerprintingProtection.pbmode"|"z99.ignore.privacy.fingerprintingProtection.pbmode"|' \
    -e 's|"privacy.globalprivacycontrol.enabled"|"z99.ignore.privacy.globalprivacycontrol.enabled"|' \
    -e 's|"privacy.globalprivacycontrol.functionality.enabled"|"z99.ignore.privacy.globalprivacycontrol.functionality.enabled"|' \
    -e 's|"privacy.globalprivacycontrol.pbmode.enabled"|"z99.ignore.privacy.globalprivacycontrol.pbmode.enabled"|' \
    -e 's|"security.pki.certificate_transparency.mode"|"z99.ignore.security.pki.certificate_transparency.mode"|' \
    -e 's|"security.tls.enable_kyber"|"z99.ignore.security.tls.enable_kyber"|' \
    -e 's|"toolkit.telemetry.user_characteristics_ping.current_version"|"z99.ignore.toolkit.telemetry.user_characteristics_ping.current_version"|' \
    -e 's|"webgl.msaa-samples"|"z99.ignore.webgl.msaa-samples"|' \
    mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntimeSettings.java

# shellcheck disable=SC2154
if [[ -n ${FDROID_BUILD+x} ]]; then

    # Patch the LLVM source code
    # Search clang- in https://android.googlesource.com/platform/ndk/+/refs/tags/ndk-r27/ndk/toolchains.py
    LLVM_SVN='522817'
    python3 "$toolchain_utils/llvm_tools/patch_manager.py" \
        --svn_version $LLVM_SVN \
        --patch_metadata_file "$llvm_android/patches/PATCHES.json" \
        --src_path "$llvm"

    # Bundletool
    pushd "$bundletool"
    localize_maven
    popd
fi
{
    echo 'ac_add_options --disable-address-sanitizer-reporter'
    echo 'ac_add_options --disable-android-debuggable'
    echo 'ac_add_options --disable-artifact-builds'
    echo 'ac_add_options --disable-backgroundtasks'
    echo 'ac_add_options --disable-callgrind'
    echo 'ac_add_options --disable-crashreporter'
    echo 'ac_add_options --disable-debug'
    echo 'ac_add_options --disable-debug-js-modules'
    echo 'ac_add_options --disable-debug-symbols'
    echo 'ac_add_options --disable-default-browser-agent'
    echo 'ac_add_options --disable-dmd'
    echo 'ac_add_options --disable-dtrace'
    echo 'ac_add_options --disable-dump-painting'
    echo 'ac_add_options --disable-execution-tracing'
    echo 'ac_add_options --disable-ffmpeg'
    echo 'ac_add_options --disable-gecko-profiler'
    echo 'ac_add_options --disable-geckodriver'
    echo 'ac_add_options --disable-instruments'
    echo 'ac_add_options --disable-js-shell'
    echo 'ac_add_options --disable-layout-debugger'
    echo 'ac_add_options --disable-logrefcnt'
    echo 'ac_add_options --disable-negotiateauth'
    echo 'ac_add_options --disable-nodejs'
    echo 'ac_add_options --disable-parental-controls'
    echo 'ac_add_options --disable-phc'
    echo 'ac_add_options --disable-pref-extensions'
    echo 'ac_add_options --disable-profiling'
    echo 'ac_add_options --disable-real-time-tracing'
    echo 'ac_add_options --disable-reflow-perf'
    echo 'ac_add_options --disable-rust-debug'
    echo 'ac_add_options --disable-simulator'
    echo 'ac_add_options --disable-spidermonkey-telemetry'
    echo 'ac_add_options --disable-system-extension-dirs'
    echo 'ac_add_options --disable-system-policies'
    echo 'ac_add_options --disable-tests'
    echo 'ac_add_options --disable-uniffi-fixtures'
    echo 'ac_add_options --disable-unverified-updates'
    echo 'ac_add_options --disable-updater'
    echo 'ac_add_options --disable-vtune'
    echo 'ac_add_options --disable-wasm-codegen-debug'
    echo 'ac_add_options --disable-webdriver'
    echo 'ac_add_options --disable-webrender-debugger'
    echo 'ac_add_options --disable-webspeechtestbackend'
    echo 'ac_add_options --disable-wmf'
    echo 'ac_add_options --enable-application=mobile/android'
    echo 'ac_add_options --enable-disk-remnant-avoidance'
    echo 'ac_add_options --enable-hardening'
    echo 'ac_add_options --enable-install-strip'
    echo 'ac_add_options --enable-minify=properties'
    echo 'ac_add_options --enable-mobile-optimize'
    echo 'ac_add_options --enable-optimize'
    echo 'ac_add_options --enable-proxy-bypass-protection'
    echo 'ac_add_options --enable-release'
    echo 'ac_add_options --enable-replace-malloc'
    echo 'ac_add_options --enable-rust-simd'
    echo 'ac_add_options --enable-strip'
    echo 'ac_add_options --enable-update-channel=release'
    echo 'ac_add_options --with-app-basename=IronFox'
    echo 'ac_add_options --with-app-name=ironfox'
    echo 'ac_add_options --with-branding=mobile/android/branding/ironfox'
    echo 'ac_add_options --with-crashreporter-url=data;'
    echo 'ac_add_options --with-distribution-id=org.ironfoxoss'
    echo "ac_add_options --with-java-bin-path=\"$JAVA_HOME/bin\""

    if [[ -n "${target}" ]]; then
        echo "ac_add_options --target=$target"
    fi

    echo "ac_add_options --with-android-ndk=\"$ANDROID_NDK\""
    echo "ac_add_options --with-android-sdk=\"$ANDROID_HOME\""
    echo "ac_add_options --with-gradle=$(command -v gradle)"
    echo "ac_add_options --with-libclang-path=\"$libclang\""
    echo "ac_add_options --with-wasi-sysroot=\"$wasi_install/share/wasi-sysroot\""
    echo "ac_add_options --without-google-location-service-api-keyfile"

    if [[ -n ${SB_GAPI_KEY_FILE+x} ]]; then
        echo "ac_add_options --with-google-safebrowsing-api-keyfile=${SB_GAPI_KEY_FILE}"
    fi

    echo "ac_add_options WASM_CC=\"$wasi_install/bin/clang\""
    echo "ac_add_options WASM_CXX=\"$wasi_install/bin/clang++\""
    echo "ac_add_options CC=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang\""
    echo "ac_add_options CXX=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++\""
    echo "ac_add_options STRIP=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip\""
    echo 'mk_add_options MOZ_APP_DISPLAYNAME=IronFox'
    echo 'mk_add_options MOZ_APP_VENDOR="IronFox OSS"'
    echo 'mk_add_options MOZ_NORMANDY=0'
    echo 'mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj'
    echo 'mk_add_options MOZ_SERVICES_HEALTHREPORT=0'
    echo 'export MOZ_APP_BASENAME=IronFox'
    echo 'export MOZ_APP_DISPLAYNAME=IronFox'
    echo 'export MOZ_APP_NAME=ironfox'
    echo 'export MOZ_APP_REMOTINGNAME=ironfox'
    echo 'export MOZ_APP_UA_NAME=Firefox'
    echo 'export MOZ_CRASHREPORTER='
    echo 'export MOZ_CRASHREPORTER_URL=data;'
    echo 'export MOZ_DATA_REPORTING='
    echo 'export MOZ_DISTRIBUTION_ID=org.ironfoxoss'
    echo 'export MOZ_INCLUDE_SOURCE_INFO=1'
    echo 'export MOZ_LTO=1'
    echo 'export MOZ_PGO=1'
    echo 'export MOZ_REQUIRE_SIGNING='
    echo 'export MOZ_TELEMETRY_REPORTING='
    echo 'export MOZILLA_OFFICIAL=1'
    echo 'export RUSTC_OPT_LEVEL=2'
} >>mozconfig

# Point to our build of Bundletool
sed -i \
    -e "/bundletool_path = /s|toolchains_base_dir|\"$BUILDDIR\"|" \
    build/moz.configure/android-sdk.configure

# Fail on use of prebuilt binary
sed -i 's|https://github.com|hxxps://github.com|' python/mozboot/mozboot/android.py

# Make the build system think we installed the emulator and an AVD
mkdir -vp "$ANDROID_HOME/emulator"
mkdir -vp "$HOME/.mozbuild/android-device/avd"

# Do not check the "emulator" utility which is obviously absent in the empty directory we created above
sed -i -e '/check_android_tools("emulator"/d' build/moz.configure/android-sdk.configure

# Do not define `browser.safebrowsing.features.` prefs by default
## These are unnecessary, add extra confusion and complexity, and don't appear to interact well with our other prefs/settings
sed -i \
    -e 's|"browser.safebrowsing.features.cryptomining.update"|"z99.ignore.browser.safebrowsing.features.cryptomining.update"|' \
    -e 's|"browser.safebrowsing.features.fingerprinting.update"|"z99.ignore.browser.safebrowsing.features.fingerprinting.update"|' \
    -e 's|"browser.safebrowsing.features.malware.update"|"z99.ignore.browser.safebrowsing.features.malware.update"|' \
    -e 's|"browser.safebrowsing.features.phishing.update"|"z99.ignore.browser.safebrowsing.features.phishing.update"|' \
    -e 's|"browser.safebrowsing.features.trackingAnnotation.update"|"z99.ignore.browser.safebrowsing.features.trackingAnnotation.update"|' \
    -e 's|"browser.safebrowsing.features.trackingProtection.update"|"z99.ignore.browser.safebrowsing.features.trackingProtection.update"|' \
    mobile/android/app/geckoview-prefs.js

{
    cat "$patches/preferences/phoenix.js"
    cat "$patches/preferences/phoenix-extended.js"
    cat "$patches/preferences/ironfox.js"

    if [[ -n ${IRONFOX_UBO_ASSETS_URL+x} ]]; then
        # Set uBlock Origin to use our custom/enhanced config by default
        echo "pref(\"browser.ironfox.uBO.assetsBootstrapLocation\", \"${IRONFOX_UBO_ASSETS_URL}\");"
    fi
} >>mobile/android/app/geckoview-prefs.js

{
    cat "$patches/preferences/pdf.js"
} >>toolkit/components/pdfjs/PdfJsOverridePrefs.js

find "$patches/gecko-overlay" -type f | while read -r src; do
    cp -vrf "$src" "${src#"$patches/gecko-overlay/"}"
done

popd
