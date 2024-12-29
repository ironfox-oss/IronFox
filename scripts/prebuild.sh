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

if [[ "$paths_source" != "true" ]]; then
    echo "Use 'source scripts/paths_local.sh' before calling prebuild or build (scripts/paths_fdroid.sh for F-Droid builds)."
    exit 1
fi

if [ ! -d "$ANDROID_HOME" ]; then
    echo "\$ANDROID_HOME does not exist."
    exit 1
fi

if [ ! -d "$ANDROID_NDK" ]; then
    echo "\$ANDROID_NDK does not exist."
    exit 1
fi

JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{sub("^$", "0", $2); print $1$2}')
[ "$JAVA_VER" -ge 15 ] || $(echo "Java 17 or newer must be set as default JDK" && exit 1)

if [[ -n ${FDROID_BUILD+x} ]]; then
    # Set up Rust
    "$rustup"/rustup-init.sh -y --no-update-default-toolchain
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-update-default-toolchain
fi

if grep -q "Fedora" /etc/os-release; then
    export libclang=/usr/lib64
else
    export libclang="${builddir}/libclang"
    mkdir -p "$libclang"

    # TODO: Maybe find a way to not hardcode this?
    ln -sf "/usr/lib/x86_64-linux-gnu/libclang-18.so.1" "$libclang/libclang.so"
fi

echo "...libclang dir set to ${libclang}"

# shellcheck disable=SC1090,SC1091
source "$HOME/.cargo/env"
rustup default 1.82.0
cargo install --vers 0.26.0 cbindgen

# Fenix
pushd "$fenix"

# Set up the app ID, version name and version code
sed -i \
    -e 's|applicationId "org.mozilla"|applicationId "com.itsaky"|' \
    -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' \
    -e 's|"sharedUserId": "org.mozilla.firefox.sharedID"|"sharedUserId": "com.itsaky.ironfox.sharedID"|' \
    -e "s/Config.releaseVersionName(project)/'$1'/" \
    -e "s/Config.generateFennecVersionCode(arch, aab)/$2/" \
    app/build.gradle
sed -i \
    -e '/android:targetPackage/s/org.mozilla.firefox/com.itsaky.ironfox/' \
    app/src/release/res/xml/shortcuts.xml

# Disable crash reporting
sed -i -e '/CRASH_REPORTING/s/true/false/' app/build.gradle

# Disable MetricController
sed -i -e '/TELEMETRY/s/true/false/' app/build.gradle

# Let it be IronFox
sed -i \
    -e 's/Firefox Daylight/IronFox/; s/Firefox/IronFox/g' \
    -e '/about_content/s/Mozilla/Akash Yadav/' \
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
    abi=armeabi-v7a
    target=arm-linux-androideabi
    echo "ARM" >"$builddir/targets_to_build"
    rusttarget=arm
    rustup target add thumbv7neon-linux-androideabi
    rustup target add armv7-linux-androideabi
    ;;
1)
    abi=x86
    target=i686-linux-android
    echo "X86" >"$builddir/targets_to_build"
    rusttarget=x86
    rustup target add i686-linux-android
    ;;
2)
    abi=arm64-v8a
    target=aarch64-linux-android
    echo "AArch64" >"$builddir/targets_to_build"
    rusttarget=arm64
    rustup target add aarch64-linux-android
    ;;
*)
    echo "Unknown target code in $2." >&2
    exit 1
    ;;
esac
sed -i -e "s/include \".*\"/include \"$abi\"/" app/build.gradle

# Enable the auto-publication workflow
echo "autoPublish.application-services.dir=$application_services" >>local.properties

popd

#
# Glean
#

pushd "$glean"
echo "rust.targets=linux-x86-64,$rusttarget" >>local.properties
localize_maven
popd

#
# Android Components
#

pushd "$android_components"
chmod +x automation/publish_to_maven_local_if_modified.py
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
chmod +x libs/*.sh
chmod +x automation/publish_to_maven_local_if_modified.py
# Break the dependency on older A-C
sed -i -e '/android-components = /s/131\.0\.2/133.0.3/' gradle/libs.versions.toml
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

# Since we download ZIP files, the executable permissions are lost
chmod +x mach
chmod +x build/cargo-*

# Remove Mozilla repositories substitution and explicitly add the required ones
patch -p1 --no-backup-if-mismatch --quiet <"$patches/gecko-localize_maven.patch"

# Replace GMS with microG client library
patch -p1 --no-backup-if-mismatch --quiet <"$patches/gecko-liberate.patch"

# Patch the use of proprietary and tracking libraries
patch -p1 --no-backup-if-mismatch --quiet <"$patches/fenix-liberate.patch"

# Set strict ETP by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/strict_etp.patch"

# Enable HTTPS only mode by default
patch -p1 --no-backup-if-mismatch --quiet <"$patches/https_only.patch"

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

if [[ -n ${FDROID_BUILD+x} ]]; then
    # Patch the LLVM source code
    # Search clang- in https://android.googlesource.com/platform/ndk/+/refs/tags/ndk-r27/ndk/toolchains.py
    LLVM_SVN='522817'
    python3 $toolchain_utils/llvm_tools/patch_manager.py \
        --svn_version $LLVM_SVN \
        --patch_metadata_file $llvm_android/patches/PATCHES.json \
        --src_path $llvm
fi

echo "" >mozconfig
echo 'ac_add_options --disable-crashreporter' >>mozconfig
echo 'ac_add_options --disable-debug' >>mozconfig
echo 'ac_add_options --disable-nodejs' >>mozconfig
echo 'ac_add_options --disable-profiling' >>mozconfig
echo 'ac_add_options --disable-rust-debug' >>mozconfig
echo 'ac_add_options --disable-tests' >>mozconfig
echo 'ac_add_options --disable-updater' >>mozconfig
echo 'ac_add_options --enable-application=mobile/android' >>mozconfig
echo 'ac_add_options --enable-hardening' >>mozconfig
echo 'ac_add_options --enable-optimize' >>mozconfig
echo 'ac_add_options --enable-release' >>mozconfig
echo 'ac_add_options --enable-minify=properties' >>mozconfig
echo 'ac_add_options --enable-update-channel=release' >>mozconfig
echo 'ac_add_options --enable-rust-simd' >>mozconfig
echo 'ac_add_options --enable-strip' >>mozconfig
echo "ac_add_options --with-java-bin-path=\"$JAVA_HOME/bin\"" >>mozconfig
echo "ac_add_options --target=$target" >>mozconfig
echo "ac_add_options --with-android-ndk=\"$ANDROID_NDK\"" >>mozconfig
echo "ac_add_options --with-android-sdk=\"$ANDROID_HOME\"" >>mozconfig
echo "ac_add_options --with-gradle=$(command -v gradle)" >>mozconfig
echo "ac_add_options --with-libclang-path=\"$libclang\"" >>mozconfig
echo "ac_add_options --with-wasi-sysroot=\"$wasi_install/share/wasi-sysroot\"" >>mozconfig
echo "ac_add_options WASM_CC=\"$wasi_install/bin/clang\"" >>mozconfig
echo "ac_add_options WASM_CXX=\"$wasi_install/bin/clang++\"" >>mozconfig
echo "ac_add_options CC=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang\"" >>mozconfig
echo "ac_add_options CXX=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++\"" >>mozconfig
echo "ac_add_options STRIP=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip\"" >>mozconfig
echo 'mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj' >>mozconfig

# Configure
sed -i -e '/check_android_tools("emulator"/d' build/moz.configure/android-sdk.configure

# Disable Gecko Media Plugins and casting
sed -i -e '/gmp-provider/d; /casting.enabled/d' mobile/android/app/geckoview-prefs.js
cat <<EOF >>mobile/android/app/geckoview-prefs.js

// Disable Encrypted Media Extensions
pref("media.eme.enabled", false);

// Disable Gecko Media Plugins
pref("media.gmp-provider.enabled", false);

// Avoid openh264 being downloaded
pref("media.gmp-manager.url.override", "data:text/plain,");

// Disable openh264 if it is already downloaded
pref("media.gmp-gmpopenh264.enabled", false);

// Disable casting (Roku, Chromecast)
pref("browser.casting.enabled", false);
EOF

cat "$patches/preferences/userjs-arkenfox.js" >>mobile/android/app/geckoview-prefs.js
cat "$patches/preferences/userjs-brace.js" >>mobile/android/app/geckoview-prefs.js

popd
