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

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 versionName versionCode" >&1
    exit 1
fi

# shellcheck source=paths.sh
source "$(dirname "$0")/paths.sh"

function localize_maven {
    # Replace custom Maven repositories with mavenLocal()
    find ./* -name '*.gradle' -type f -print0 | xargs -0 \
        sed -n -i \
            -e '/maven {/{:loop;N;/}$/!b loop;/plugins.gradle.org/!s/maven .*/mavenLocal()/};p'
    # Make gradlew scripts call our Gradle wrapper
    find ./* -name gradlew -type f | while read -r gradlew; do
        echo -e '#!/bin/sh\ngradle "$@"' > "$gradlew"
        chmod 755 "$gradlew"
    done
}

# Set up Rust
"$rustup"/rustup-init.sh -y --no-update-default-toolchain
# shellcheck disable=SC1090,SC1091
source "$HOME/.cargo/env"
rustup default 1.81.0

#
# Fenix
#

pushd "$fenix"

# Set up the app ID, version name and version code
sed -i \
    -e 's|\.firefox|.fennec_fdroid|' \
    -e "s/Config.releaseVersionName(project)/'$1'/" \
    -e "s/Config.generateFennecVersionCode(arch, aab)/$2/" \
    app/build.gradle
sed -i \
    -e '/android:targetPackage/s/firefox/fennec_fdroid/' \
    app/src/release/res/xml/shortcuts.xml

# Disable crash reporting
sed -i -e '/CRASH_REPORTING/s/true/false/' app/build.gradle

# Disable MetricController
sed -i -e '/TELEMETRY/s/true/false/' app/build.gradle

# Let it be Fennec
sed -i -e 's/Firefox Daylight/Fennec/; s/Firefox/Fennec/g' \
    app/src/*/res/values*/*strings.xml

# Fenix uses reflection to create a instance of profile based on the text of
# the label, see
# app/src/main/java/org/mozilla/fenix/perf/ProfilerStartDialogFragment.kt#185
sed -i \
    -e '/Firefox(.*, .*)/s/Firefox/Fennec/' \
    -e 's/firefox_threads/fennec_threads/' \
    -e 's/firefox_features/fennec_features/' \
    app/src/main/java/org/mozilla/fenix/perf/ProfilerUtils.kt

# Replace proprietary artwork
sed -i -e 's|@drawable/animated_splash_screen<|@drawable/splash_screen<|' \
    app/src/main/res/values-v*/styles.xml
find "$patches/fenix-overlay" -type f | while read -r src; do
    dst=app/src/release/${src#"$patches/fenix-overlay/"}
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
done

# Enable about:config
sed -i \
    -e 's/aboutConfigEnabled(.*)/aboutConfigEnabled(true)/' \
    app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt

# Add wallpaper URL
echo 'https://gitlab.com/relan/fennecmedia/-/raw/master/wallpapers/android' > .wallpaper_url

# Set up target parameters
case $(echo "$2" | cut -c 6) in
    0)
        abi=armeabi-v7a
        target=arm-linux-androideabi
        echo "ARM" > "$llvm/targets_to_build"
        rusttarget=arm
        rustup target add thumbv7neon-linux-androideabi
        rustup target add armv7-linux-androideabi
        ;;
    1)
        abi=x86
        target=i686-linux-android
        echo "X86" > "$llvm/targets_to_build"
        rusttarget=x86
        rustup target add i686-linux-android
        ;;
    2)
        abi=arm64-v8a
        target=aarch64-linux-android
        echo "AArch64" > "$llvm/targets_to_build"
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
echo "autoPublish.application-services.dir=$application_services" >> local.properties

popd

#
# Glean
#

pushd "$glean"
echo "rust.targets=linux-x86-64,$rusttarget" >> local.properties
localize_maven
popd

#
# Android Components
#

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

#
# Application Services
#

pushd "$application_services"
# Break the dependency on older A-C
sed -i -e "/android-components = /s/130.0.1/${1%.0}/" gradle/libs.versions.toml
sed -i -e "/glean = /s/61.1.0/61.2.0/" gradle/libs.versions.toml
echo "rust.targets=linux-x86-64,$rusttarget" >> local.properties
sed -i -e '/NDK ez-install/,/^$/d' libs/verify-android-ci-environment.sh
sed -i -e '/content {/,/}/d' build.gradle
localize_maven
# Fix stray
sed -i -e '/^    mavenLocal/{n;d}' tools/nimbus-gradle-plugin/build.gradle
# Fail on use of prebuilt binary
sed -i 's|https://|hxxps://|' tools/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy
popd


#
# WASI SDK
#

pushd "$wasi"
patch -p1 --no-backup-if-mismatch --quiet < "$mozilla_release/taskcluster/scripts/misc/wasi-sdk.patch"
popd

#
# GeckoView
#

pushd "$mozilla_release"
# Remove Mozilla repositories substitution and explicitly add the required ones
patch -p1 --no-backup-if-mismatch --quiet < "$patches/gecko-localize_maven.patch"

# Replace GMS with microG client library
patch -p1 --no-backup-if-mismatch --quiet < "$patches/gecko-liberate.patch"

# Patch the use of proprietary and tracking libraries
patch -p1 --no-backup-if-mismatch --quiet < "$patches/fenix-liberate.patch"
patch -p1 --no-backup-if-mismatch --quiet < "$patches/remove_stray_firebase_reference.patch"

# Fix v125 compile error
patch -p1 --no-backup-if-mismatch --quiet < "$patches/gecko-fix-125-compile.patch"

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

# Patch the LLVM source code
# Search clang- in https://android.googlesource.com/platform/ndk/+/refs/tags/ndk-r27/ndk/toolchains.py
LLVM_SVN='522817'
python3 "$toolchain_utils/llvm_tools/patch_manager.py" \
    --svn_version "$LLVM_SVN" \
    --patch_metadata_file "$llvm_android/patches/PATCHES.json" \
    --src_path "$llvm"

# Configure
sed -i -e '/check_android_tools("emulator"/d' build/moz.configure/android-sdk.configure
cat << EOF > mozconfig
ac_add_options --disable-crashreporter
ac_add_options --disable-debug
ac_add_options --disable-nodejs
ac_add_options --disable-tests
ac_add_options --disable-updater
ac_add_options --enable-application=mobile/android
ac_add_options --enable-release
ac_add_options --enable-minify=properties # JS minification breaks addons
ac_add_options --enable-update-channel=release
ac_add_options --target=$target
ac_add_options --with-android-ndk="$ANDROID_NDK"
ac_add_options --with-android-sdk="$ANDROID_SDK"
ac_add_options --with-libclang-path="$llvm/out/lib"
ac_add_options --with-java-bin-path="/usr/bin"
ac_add_options --with-gradle=$(command -v gradle)
ac_add_options --with-wasi-sysroot="$wasi/build/install/wasi/share/wasi-sysroot"
ac_add_options CC="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang"
ac_add_options CXX="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++"
ac_add_options STRIP="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"
ac_add_options WASM_CC="$wasi/build/install/wasi/bin/clang"
ac_add_options WASM_CXX="$wasi/build/install/wasi/bin/clang++"
mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj
EOF

# Disable Gecko Media Plugins and casting
sed -i -e '/gmp-provider/d; /casting.enabled/d' mobile/android/app/geckoview-prefs.js
cat << EOF >> mobile/android/app/geckoview-prefs.js

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

popd
