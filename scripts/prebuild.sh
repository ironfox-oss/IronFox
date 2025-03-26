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
    local telemetry_url="https://incoming.telemetry.mozilla.org"

    # Set telemetry URL to an invalid localhost address
    grep -rnlI "${dir}" -e "${telemetry_url}" | xargs -L1 sed -i -e "s|${telemetry_url}|http://localhost:70000|g"
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
[ "$JAVA_VER" -ge 15 ] || {
    echo "Java 17 or newer must be set as default JDK"
    exit 1
}

if [[ -z "$FIREFOX_TAG" ]]; then
    echo "\$FIREFOX_TAG is not set! Aborting..."]
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
mkdir -p "$rootdir/build"

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
source "$CARGO_HOME/env"
rustup default 1.83.0
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

# Remove Reddit & YouTube as built-in search engines (due to poor privacy practices)
rm app/src/main/assets/searchplugins/reddit.xml
rm app/src/main/assets/searchplugins/youtube.xml

# Enable about:config
sed -i \
    -e 's/aboutConfigEnabled(.*)/aboutConfigEnabled(true)/' \
    app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt

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

# Remove questionable built-in search engines (due to poor privacy practices)
rm components/feature/search/src/main/assets/searchplugins/amazon-jp.xml
rm components/feature/search/src/main/assets/searchplugins/baidu.xml
rm components/feature/search/src/main/assets/searchplugins/bing.xml
rm components/feature/search/src/main/assets/searchplugins/ceneje.xml
rm components/feature/search/src/main/assets/searchplugins/coccoc.xml
rm components/feature/search/src/main/assets/searchplugins/daum-kr.xml
rm components/feature/search/src/main/assets/searchplugins/ebay.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-at.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-au.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-befr.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-ca.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-ch.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-co-uk.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-de.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-es.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-fr.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-ie.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-it.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-nl.xml
rm components/feature/search/src/main/assets/searchplugins/ebay-pl.xml
rm components/feature/search/src/main/assets/searchplugins/ecosia.xml
rm components/feature/search/src/main/assets/searchplugins/google-b-1-m.xml
rm components/feature/search/src/main/assets/searchplugins/google-b-m.xml
rm components/feature/search/src/main/assets/searchplugins/google-b-vv.xml
rm components/feature/search/src/main/assets/searchplugins/google-com-nocodes.xml
rm components/feature/search/src/main/assets/searchplugins/gulesider-mobile-NO.xml
rm components/feature/search/src/main/assets/searchplugins/leo_ende_de.xml
rm components/feature/search/src/main/assets/searchplugins/mapy-cz.xml
rm components/feature/search/src/main/assets/searchplugins/mercadolibre-ar.xml
rm components/feature/search/src/main/assets/searchplugins/mercadolibre-cl.xml
rm components/feature/search/src/main/assets/searchplugins/mercadolibre-mx.xml
rm components/feature/search/src/main/assets/searchplugins/odpiralni.xml
rm components/feature/search/src/main/assets/searchplugins/pazaruvaj.xml
rm components/feature/search/src/main/assets/searchplugins/prisjakt-sv-SE.xml
rm components/feature/search/src/main/assets/searchplugins/qwant.xml
rm components/feature/search/src/main/assets/searchplugins/rakuten.xml
rm components/feature/search/src/main/assets/searchplugins/reddit.xml
rm components/feature/search/src/main/assets/searchplugins/salidzinilv.xml
rm components/feature/search/src/main/assets/searchplugins/seznam-cz.xml
rm components/feature/search/src/main/assets/searchplugins/vatera.xml
rm components/feature/search/src/main/assets/searchplugins/yahoo-jp.xml
rm components/feature/search/src/main/assets/searchplugins/yahoo-jp-auctions.xml
rm components/feature/search/src/main/assets/searchplugins/yandex.xml
rm components/feature/search/src/main/assets/searchplugins/yandex.by.xml
rm components/feature/search/src/main/assets/searchplugins/yandex-en.xml
rm components/feature/search/src/main/assets/searchplugins/yandex-ru.xml
rm components/feature/search/src/main/assets/searchplugins/yandex-tr.xml
rm components/feature/search/src/main/assets/searchplugins/youtube.xml

find "$patches/a-c-overlay" -type f | while read -r src; do
    cp "$src" "${src#"$patches/a-c-overlay/"}"
done

# Hack to prevent too long string from breaking build
sed -i '/val statusCmd/,+3d' plugins/config/src/main/java/ConfigPlugin.kt
sed -i '/\/\/ Append "+"/a \        val statusSuffix = "+"' plugins/config/src/main/java/ConfigPlugin.kt
popd

# Application Services

pushd "$application_services"
# Break the dependency on older A-C
sed -i -e "/android-components = /s/133\.0/${FIREFOX_TAG}/" gradle/libs.versions.toml
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

# Set the Safe Browsing API URL to our proxy
sed -i "s|safebrowsing.googleapis.com/v4/|safebrowsing.ironfoxoss.org/v4/|g" \
    mobile/android/geckoview/src/main/java/org/mozilla/geckoview/ContentBlocking.java

# Remove glean telemetry URL
remove_glean_telemetry "${glean}"
remove_glean_telemetry "${application_services}"
remove_glean_telemetry "${mozilla_release}/browser"
remove_glean_telemetry "${mozilla_release}/modules"
remove_glean_telemetry "${mozilla_release}/toolkit"
remove_glean_telemetry "${mozilla_release}/netwerk"


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
    echo 'ac_add_options --disable-debug-js-modules'
    echo 'ac_add_options --disable-debug-symbols'
    echo 'ac_add_options --disable-nodejs'
    echo 'ac_add_options --disable-parental-controls'
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
    echo 'ac_add_options --with-app-basename=IronFox'
    echo 'ac_add_options --with-app-name=ironfox'
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

    if [[ -n ${SB_GAPI_KEY_FILE+x} ]]; then
        echo "ac_add_options --with-google-safebrowsing-api-keyfile=${SB_GAPI_KEY_FILE}"
    fi

    echo "ac_add_options WASM_CC=\"$wasi_install/bin/clang\""
    echo "ac_add_options WASM_CXX=\"$wasi_install/bin/clang++\""
    echo "ac_add_options CC=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang\""
    echo "ac_add_options CXX=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++\""
    echo "ac_add_options STRIP=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip\""
    echo 'mk_add_options MOZ_APP_VENDOR="IronFox OSS"'
    echo 'mk_add_options MOZ_NORMANDY=0'
    echo 'mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj'
    echo 'mk_add_options MOZ_SERVICES_HEALTHREPORT=0'
    echo 'export MOZ_APP_BASENAME=IronFox'
    echo 'export MOZ_APP_DISPLAYNAME=IronFox'
    echo 'export MOZ_APP_NAME=ironfox'
    echo 'export MOZ_APP_REMOTINGNAME=ironfox'
    echo 'export MOZ_APP_UA_NAME="Firefox"'
    echo 'export MOZ_CRASHREPORTER='
    echo 'export MOZ_DATA_REPORTING='
    echo 'export MOZ_DISABLE_PARENTAL_CONTROLS=1'
    echo 'export MOZ_DISTRIBUTION_ID=org.ironfoxoss'
    echo 'export MOZ_INCLUDE_SOURCE_INFO=1'
    echo 'export MOZ_REQUIRE_SIGNING='
    echo 'export MOZ_TELEMETRY_REPORTING='
} >>mozconfig

# Configure
sed -i -e '/check_android_tools("emulator"/d' build/moz.configure/android-sdk.configure

{
    cat "$patches/preferences/phoenix-android.js"
    cat "$patches/preferences/phoenix-extended-android.js"
    cat "$patches/preferences/ironfox.js"
} >>mobile/android/app/geckoview-prefs.js

popd
