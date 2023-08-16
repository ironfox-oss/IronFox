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

# Remove unnecessary projects
rm -fR focus-android
rm -f fenix/app/src/test/java/org/mozilla/fenix/components/ReviewPromptControllerTest.kt

# Hack to prevent too long string from breaking build
sed -i '/val statusCmd/,+3d' android-components/plugins/config/src/main/java/ConfigPlugin.kt
sed -i '/val revision = /a \        val statusSuffix = "+"' android-components/plugins/config/src/main/java/ConfigPlugin.kt

# Patch the use of proprietary and tracking libraries
patch -p1 --no-backup-if-mismatch --quiet < "$patches/fenix-liberate.patch"

# Add wallpaper URL
echo 'https://gitlab.com/relan/fennecmedia/-/raw/master/wallpapers/android' > fenix/.wallpaper_url

#
# Fenix
#

pushd "$fenix"
# Set up the app ID, version name and version code
sed -i \
    -e 's|\.firefox|.fennec_fdroid|' \
    -e "s/Config.releaseVersionName(project)/'$1'/" \
    -e "s/Config.generateFennecVersionCode(arch)/$2/" \
    app/build.gradle
sed -i \
    -e '/android:targetPackage/s/firefox/fennec_fdroid/' \
    app/src/release/res/xml/shortcuts.xml

# Compile nimbus-fml instead of using prebuilt
sed -i \
    -e '/experimenter.yaml/a \ \ \ \ applicationServicesDir = "../../srclib/MozAppServices/"' \
    app/build.gradle;

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
    plugins/fenixdependencies/build.gradle \
    mozilla-lint-rules/build.gradle \
    plugins/apksize/build.gradle

# We need only stable GeckoView
sed -i \
    -e '/Deps.mozilla_browser_engine_gecko_nightly/d' \
    -e '/Deps.mozilla_browser_engine_gecko_beta/d' \
    app/build.gradle

# Let it be Fennec
sed -i -e 's/Firefox Daylight/Fennec/; s/Firefox/Fennec/g' \
    app/src/*/res/values*/*strings.xml

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

# Expose "Pull to refresh" setting
sed -i \
    -e '/pullToRefreshEnabled = /s/Config.channel.isNightlyOrDebug/true/' \
    app/src/main/java/org/mozilla/fenix/FeatureFlags.kt

# Disable "Pull to refresh" by default
sed -i \
    -e '/pref_key_website_pull_to_refresh/{n; s/default = true/default = false/}' \
    app/src/main/java/org/mozilla/fenix/utils/Settings.kt

# Fixup dependency on GMS
sed -i \
    -e 's/com.google.android.gms.common.util.VisibleForTesting/androidx.annotation.VisibleForTesting/' \
    app/src/main/java/org/mozilla/fenix/browser/readermode/ReaderModeController.kt

# Set up target parameters
minsdk=21
case $(echo "$2" | cut -c 6) in
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
popd

#
# Glean
#

pushd "$glean_as"
echo "rust.targets=$rusttarget" >> local.properties
localize_maven
popd
pushd "$glean"
echo "rust.targets=linux-x86-64,$rusttarget" >> local.properties
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
# Remove unnecessary projects
rm -fR ../focus-android
localize_maven
popd

pushd "$android_components"
find "$patches/a-c-overlay" -type f | while read -r src; do
    cp "$src" "${src#"$patches/a-c-overlay/"}"
done
# We only need a release Gecko
rm -fR components/browser/engine-gecko-{beta,nightly}
gvver=$(echo "$1" | cut -d. -f1)
sed -i \
    -e "s/version = \"$gvver\.[0-9.]*\"/version = \"$gvver.+\"/" \
    plugins/dependencies/src/main/java/Gecko.kt
localize_maven
# Compile nimbus-fml instead of using prebuilt
sed -i \
    -e '/ : null/a \ \ \ \ applicationServicesDir = "../../srclib/MozAppServices/"' \
    components/service/nimbus/build.gradle \
    components/browser/engine-gecko/build.gradle;
# Add the added search engines as `general` engines
sed -i \
    -e '41i \ \ \ \ "brave",\n\ \ \ \ "ddghtml",\n\ \ \ \ "ddglite",\n\ \ \ \ "metager",\n\ \ \ \ "mojeek",\n\ \ \ \ "qwantlite",\n\ \ \ \ "startpage",' \
     components/feature/search/src/main/java/mozilla/components/feature/search/storage/SearchEngineReader.kt
popd

#
# Application Services
#

pushd "$application_services"
echo "rust.targets=linux-x86-64,$rusttarget" >> local.properties
sed -i -e '/content {/,/}/d' build.gradle
sed -i -e '/NDK ez-install/,/^$/d' libs/verify-android-ci-environment.sh
localize_maven
# Fix stray
sed -i -e '/^    mavenLocal/{n;d}' tools/nimbus-gradle-plugin/build.gradle
# Fail on use of prebuilt binary
sed -i 's|https://|hxxps://|' tools/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy
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

# Fixup, unsupported on Android
sed -i \
    -e '/AT_EACCESS/d' \
    dom/base/ChromeUtils.cpp

# Revert https://bugzilla.mozilla.org/show_bug.cgi?id=1820876
sed -i \
    -e 's/r23c/r21d/' \
    python/mozboot/mozboot/android.py

# Revert https://bugzilla.mozilla.org/show_bug.cgi?id=1821221
rm -f build/android/libgcc.a
# shellcheck disable=SC2016
sed -i \
    -e 's|LDFLAGS="$extra_android_flags -L$_topsrcdir/build/android $LDFLAGS"|LDFLAGS="$extra_android_flags $LDFLAGS"|' \
    build/autoconf/android.m4
sed -i \
    -e 's/info.version < "13.0":/info.version < "8.0":/' \
     build/moz.configure/toolchain.configure

# Remove Mozilla repositories substitution and explicitly add the required ones
sed -i \
    -e '/maven {/,/}$/d; /gradle.mozconfig.substs/,/}$/{N;d;}' \
    -e '/repositories {/a\        mavenLocal()' \
    -e '/repositories {/a\        maven { url "https://plugins.gradle.org/m2/" }' \
    -e '/repositories {/a\        google()' \
    build.gradle

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
ac_add_options STRIP="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/$target/bin/strip"
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
