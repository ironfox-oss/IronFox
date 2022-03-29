#!/bin/bash
#
#    Fennec build scripts
#    Copyright (C) 2020-2022  Matías Zúñiga, Andrew Nayenko
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
        echo 'gradle "$@"' > "$gradlew"
        chmod 755 "$gradlew"
    done
}

# Set up the app ID, version name and version code
sed -i \
    -e 's|\.firefox|.fennec_fdroid|' \
    -e "s/Config.releaseVersionName(project)/'$1'/" \
    -e "s/Config.generateFennecVersionCode(arch)/$2/" \
    app/build.gradle
sed -i \
    -e '/android:targetPackage/s/firefox/fennec_fdroid/' \
    app/src/release/res/xml/shortcuts.xml

# Remove proprietary and tracking libraries
sed -i \
    -e '/Deps.mozilla_lib_push_firebase/d' \
    -e '/Deps.adjust/d; /Deps.installreferrer/d; /Deps.google_ads_id/d' \
    -e '/Deps.google_play_store/d' \
    app/build.gradle

# Disable crash reporting
sed -i -e '/CRASH_REPORTING/s/true/false/' app/build.gradle

# Disable MetricController
sed -i -e '/TELEMETRY/s/true/false/' app/build.gradle

# Replace custom Maven repositories with mavenLocal()
sed -i \
    -e '/repositories {/a\        mavenLocal()' \
    -e '/^ \{8\}maven {/,/^ \{8\}}/d' \
    -e '/^ \{12\}maven {/,/^ \{12\}}/d' build.gradle
sed -i \
    -e '/^ \{8\}maven {/,/^ \{8\}}/d' \
    buildSrc/build.gradle \
    mozilla-lint-rules/build.gradle

# We need only stable GeckoView
sed -i \
    -e '/Deps.mozilla_browser_engine_gecko_nightly/d' \
    -e '/Deps.mozilla_browser_engine_gecko_beta/d' \
    app/build.gradle

# Patch the use of proprietary and tracking libraries
patch -p1 --no-backup-if-mismatch --quiet < "$patches/fenix-liberate.patch"

# Let it be Fennec
sed -i -e 's/Firefox Daylight/Fennec/; s/Firefox/Fennec/g' \
    app/src/*/res/values*/*strings.xml

# Replace proprietary artwork
rm app/src/release/res/drawable/ic_launcher_foreground.xml
rm app/src/release/res/mipmap-*/ic_launcher.png
sed -i -e '/android:roundIcon/d' app/src/main/AndroidManifest.xml
find "$patches/fenix-overlay" -type f | while read -r src; do
    dst="app/src/release/${src#$patches/fenix-overlay/}"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
done

# Enable about:config
sed -i \
    -e 's/aboutConfigEnabled(.*)/aboutConfigEnabled(true)/' \
    app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt

# Expose "Custom Add-on collection" setting
sed -i \
    -e 's/Config.channel.isNightlyOrDebug && //' \
    app/src/main/java/org/mozilla/fenix/components/Components.kt
sed -i \
    -e 's/Config.channel.isNightlyOrDebug && //' \
    app/src/main/java/org/mozilla/fenix/settings/SettingsFragment.kt

# Disable periodic user notification to set as default browser
sed -i \
    -e 's/!defaultBrowserNotificationDisplayed && !isDefaultBrowserBlocking()/false/' \
    app/src/main/java/org/mozilla/fenix/utils/Settings.kt

# Always show the Quit button
sed -i \
    -e 's/if (settings.shouldDeleteBrowsingDataOnQuit) quitItem else null/quitItem/' \
    -e '/val settings = context.components.settings/d' \
    app/src/main/java/org/mozilla/fenix/home/HomeMenu.kt

# Set up target parameters
minsdk=21
case $(echo "$2" | cut -c 5) in
    0)
        abi=armeabi-v7a
        target=arm-linux-androideabi
        rusttarget=arm
        triplet="armv7a-linux-androideabi$minsdk"
        ;;
    1)
        abi=x86
        target=i686-linux-android
        rusttarget=x86
        triplet="$target$minsdk"
        ;;
    2)
        abi=arm64-v8a
        target=aarch64-linux-android
        rusttarget=arm64
        triplet="$target$minsdk"
        ;;
    *)
        echo "Unknown target code in $2." >&2
        exit 1
    ;;
esac
sed -i -e "s/include \".*\"/include \"$abi\"/" app/build.gradle

#
# Glean
#

pushd "$glean_as"
echo "rust.targets=$rusttarget" >> local.properties
localize_maven
popd
pushd "$glean"
echo "rust.targets=linux-x86-64,$rusttarget" >> local.properties
sed -i -e '/ndkVersion:/a\        ndkPath: System.getenv("ANDROID_NDK"),' \
    build.gradle
localize_maven
popd

#
# Android Components
#

pushd "$android_components_as"
acver=$(git name-rev --tags --name-only "$(git rev-parse HEAD)")
acver=${acver#v}
sed -e "s/VERSION/$acver/" "$patches/a-c-buildconfig.yml" > .buildconfig.yml
# We don't need Gecko while building A-C for A-S
rm -fR components/browser/engine-gecko*
localize_maven
popd

pushd "$android_components"
find "$patches/a-c-overlay" -type f | while read -r src; do
    cp "$src" "${src#$patches/a-c-overlay/}"
done
# We only need a release Gecko
rm -fR components/browser/engine-gecko-{beta,nightly}
gvver=$(echo "$1" | cut -d. -f1)
sed -i \
    -e "s/version = \"$gvver\.[0-9.]*\"/version = \"$gvver.+\"/" \
    buildSrc/src/main/java/Gecko.kt
localize_maven
popd

#
# Application Services
#

pushd "$application_services"
echo "rust.targets=linux-x86-64,$rusttarget" >> local.properties
sed -i -e '/NDK_VERSION/d' libs/android_defaults.sh
sed -i -e '/ndkVersion:/a\        ndkPath: System.getenv("ANDROID_NDK"),' \
    build.gradle
sed -i -e '/content {/,/}/d' build.gradle
sed -i -e '/ndkVersion/a\    ndkPath rootProject.ext.build.ndkPath' \
    build-scripts/component-common.gradle \
    megazords/full/android/build.gradle
sed -i -e '/sdkmanager/d' libs/verify-android-ci-environment.sh
localize_maven
popd

#
# GeckoView
#

pushd "$mozilla_release"

# Remove proprietary libraries
sed -i \
    -e '/com.google.android.gms/d' \
    mobile/android/geckoview/build.gradle

# Patch the use of proprietary libraries
patch -p1 --no-backup-if-mismatch --quiet < "$patches/gecko-liberate.patch"

# Remove Mozilla repositories substitution and explicitly add the required ones
sed -i \
    -e '/maven {/,/}$/d; /gradle.mozconfig.substs/,/}$/{N;d;}' \
    -e '/repositories {/a\        mavenLocal()' \
    -e '/repositories {/a\        maven { url "https://plugins.gradle.org/m2/" }' \
    -e '/repositories {/a\        google()' \
    build.gradle

# Replace the uses of std::is_xxx_v<T> traits with std::is_xxx<T>::value
# because they are not supported by libstdc++ 6.3.0 (we're still on Debian 9)
sed -i -E \
    -e 's/std::is_([_a-z]*)_v<([_A-Za-z][_A-Za-z0-9]*)>/std::is_\1<\2>::value/' \
    -e 's/std::is_([_a-z]*)_v<([_A-Za-z][_A-Za-z0-9]*), ([_A-Za-z][_A-Za-z0-9]*)>/std::is_\1<\2, \3>::value/' \
    mfbt/*.h

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
ac_add_options --with-android-min-sdk=$minsdk
ac_add_options --with-android-ndk="$ANDROID_NDK"
ac_add_options --with-android-sdk="$ANDROID_SDK"
ac_add_options --with-java-bin-path="/usr/bin"
ac_add_options --with-gradle=$(command -v gradle)
ac_add_options --with-wasi-sysroot="$wasi/build/install/wasi/share/wasi-sysroot"
ac_add_options CC="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/$triplet-clang"
ac_add_options CXX="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/$triplet-clang++"
ac_add_options WASM_CC="$wasi/build/install/wasi/bin/clang"
ac_add_options WASM_CXX="$wasi/build/install/wasi/bin/clang++"
mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj
EOF

# Disable Gecko Media Plugins and casting
sed -i -e '/gmp-provider/d; /casting.enabled/d' mobile/android/app/mobile.js
cat << EOF >> mobile/android/app/mobile.js

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

// Disable WebAuthn, since it is a stub
pref("security.webauth.webauthn", false);
EOF

popd
