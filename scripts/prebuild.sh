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

# Applies the overlay files in the given directory
# to the current directory
function apply_overlay() {
    source_dir="$1"
    find "$source_dir" -type f| while read -r src; do
        target="${src#"$source_dir"}"
        mkdir -vp "$(dirname "$target")"
        cp -vrf "$src" "$target"
    done
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
    echo "\$FIREFOX_VERSION is not set! Aborting..."
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

# Set platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM=darwin
else
    PLATFORM=linux
fi

# Set architecture
PLATFORM_ARCH=$(uname -m)
if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
    PLATFORM_ARCHITECTURE=aarch64
else
    PLATFORM_ARCHITECTURE=x86-64
fi

# Create build directory
mkdir -vp "$rootdir/build"

# Check patch files
source "$rootdir/scripts/patches.sh"

pushd "$application_services"
if ! a-s_check_patches; then
    echo "Patch validation failed. Please check the patch files and try again."
    exit 1
fi
popd

pushd "$glean"
if ! glean_check_patches; then
    echo "Patch validation failed. Please check the patch files and try again."
    exit 1
fi
popd

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
    curl --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -sSf https://sh.rustup.rs | sh -s -- -y --no-update-default-toolchain
fi

if [[ "$PLATFORM" == "darwin" ]]; then
    libclang="$ANDROID_NDK/toolchains/llvm/prebuilt/$PLATFORM-x86_64/lib"
else
    libclang="$ANDROID_NDK/toolchains/llvm/prebuilt/$PLATFORM-x86_64/musl/lib"
fi
echo "...libclang dir set to ${libclang}"

# shellcheck disable=SC1090,SC1091
source "$CARGO_HOME/env"
rustup default "$RUST_VERSION"
rustup target add thumbv7neon-linux-androideabi
rustup target add armv7-linux-androideabi
rustup target add aarch64-linux-android
rustup target add i686-linux-android
rustup target add x86_64-linux-android
cargo install --vers "$CBINDGEN_VERSION" cbindgen

# Fenix
# shellcheck disable=SC2154
pushd "$fenix"

# Set up the app ID, version name and version code
$SED -i \
    -e 's|applicationId "org.mozilla"|applicationId "org.ironfoxoss"|' \
    -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' \
    -e 's|"sharedUserId": "org.mozilla.firefox.sharedID"|"sharedUserId": "org.ironfoxoss.ironfox.sharedID"|' \
    -e "s/Config.releaseVersionName(project)/'${IRONFOX_VERSION}'/" \
    app/build.gradle
$SED -i \
    -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox/' \
    app/src/release/res/xml/shortcuts.xml

# Set flag for 'official' builds to ensure we're not enabling debug/dev settings
# https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/27623
# We're also setting the "MOZILLA_OFFICIAL" env variable below
$SED -i -e '/MOZILLA_OFFICIAL/s/false/true/' app/build.gradle
echo "official=true" >>local.properties

# Disable crash reporting
$SED -i -e '/CRASH_REPORTING/s/true/false/' app/build.gradle

# Disable telemetry
$SED -i -e 's|Telemetry enabled: " + .*)|Telemetry enabled: " + false)|g' app/build.gradle
$SED -i -e '/TELEMETRY/s/true/false/' app/build.gradle
$SED -i -e 's|META_ATTRIBUTION_ENABLED = .*|META_ATTRIBUTION_ENABLED = false|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# Disable "custom review pre-prompts"
$SED -i -e 's|CUSTOM_REVIEW_PROMPT_ENABLED = .*|CUSTOM_REVIEW_PROMPT_ENABLED = false|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# Ensure onboarding is always enabled
$SED -i -e 's|onboardingFeatureEnabled = .*|onboardingFeatureEnabled = true|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# No-op AMO collections/recommendations
$SED -i -e 's|"AMO_COLLECTION_NAME", "\\".*\\""|"AMO_COLLECTION_NAME", "\\"\\""|g' app/build.gradle
$SED -i 's|Extensions-for-Android||g' app/build.gradle
$SED -i -e 's|"AMO_COLLECTION_USER", "\\".*\\""|"AMO_COLLECTION_USER", "\\"\\""|g' app/build.gradle
$SED -i -e 's|"AMO_SERVER_URL", "\\".*\\""|"AMO_SERVER_URL", "\\"\\""|g' app/build.gradle
$SED -i 's|https://services.addons.mozilla.org||g' app/build.gradle
$SED -i -e 's|customExtensionCollectionFeature = .*|customExtensionCollectionFeature = false|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# No-op Glean
## https://searchfox.org/mozilla-central/rev/31123021/mobile/android/fenix/app/build.gradle#443
echo 'glean.custom.server.url="data;"' >>local.properties
$SED -i -e 's|include_client_id: .*|include_client_id: false|g' app/pings.yaml
$SED -i -e 's|send_if_empty: .*|send_if_empty: false|g' app/pings.yaml

# Remove proprietary/tracking libraries
$SED -i 's|- components:lib-crash-sentry|# - components:lib-crash-sentry|g' .buildconfig.yml
$SED -i 's|- components:lib-push-firebase|# - components:lib-push-firebase|g' .buildconfig.yml
$SED -i 's|implementation libs.thirdparty.sentry|// implementation libs.thirdparty.sentry|g' app/build.gradle
$SED -i "s|implementation project(':components:lib-crash-sentry')|// implementation project(':components:lib-crash-sentry')|g" app/build.gradle
$SED -i "s|implementation project(':components:lib-push-firebase')|// implementation project(':components:lib-push-firebase')|g" app/build.gradle
$SED -i 's|implementation(libs.adjust)|// implementation(libs.adjust)|g' app/build.gradle
$SED -i 's|implementation(libs.installreferrer)|// implementation(libs.installreferrer)|g' app/build.gradle
$SED -i 's|implementation libs.play|// implementation libs.play|g' app/build.gradle
$SED -i -e 's|<uses-permission android:name="com.adjust.preinstall.READ_PERMISSION"/>|<!-- <uses-permission android:name="com.adjust.preinstall.READ_PERMISSION"/> -->|' app/src/*/AndroidManifest.xml

# Remove unused telemetry and marketing services/components
$SED -i -e 's|import mozilla.appservices.syncmanager.SyncTelemetry|// import mozilla.appservices.syncmanager.SyncTelemetry|' app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt
$SED -i -e 's|import org.mozilla.fenix.downloads.listscreen.middleware.DownloadTelemetryMiddleware|// import org.mozilla.fenix.downloads.listscreen.middleware.DownloadTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt
$SED -i -e 's|import org.mozilla.fenix.components.toolbar.BrowserToolbarTelemetryMiddleware|// import org.mozilla.fenix.components.toolbar.BrowserToolbarTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt
$SED -i -e 's|import org.mozilla.fenix.home.toolbar.BrowserToolbarTelemetryMiddleware|// import org.mozilla.fenix.home.toolbar.BrowserToolbarTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt
$SED -i -e 's|import org.mozilla.fenix.tabstray.TabsTrayTelemetryMiddleware|// import org.mozilla.fenix.tabstray.TabsTrayTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt
$SED -i -e 's|import org.mozilla.fenix.webcompat.middleware.WebCompatReporterTelemetryMiddleware|// import org.mozilla.fenix.webcompat.middleware.WebCompatReporterTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt

$SED -i -e 's|BookmarksTelemetryMiddleware(|// BookmarksTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/bookmarks/BookmarkFragment.kt
$SED -i -e 's|BrowserToolbarTelemetryMiddleware(|// BrowserToolbarTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt
$SED -i -e 's|BrowserToolbarTelemetryMiddleware(|// BrowserToolbarTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt
$SED -i -e 's|CustomReviewPromptTelemetryMiddleware(|// CustomReviewPromptTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptBottomSheetFragment.kt
$SED -i -e 's|private fun provideTelemetryMiddleware|// private fun provideTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt
$SED -i -e 's|private fun provideTelemetryMiddleware|// private fun provideTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt
$SED -i -e 's|provideTelemetryMiddleware(|// provideTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt
$SED -i -e 's|provideTelemetryMiddleware(|// provideTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt
$SED -i -e 's|SyncTelemetry.|// SyncTelemetry.|' app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt
$SED -i -e 's|TabsTrayTelemetryMiddleware(|// TabsTrayTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/tabstray/TabsTrayFragment.kt
$SED -i -e 's|TabsTrayTelemetryMiddleware(|// TabsTrayTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt
$SED -i -e 's|WebCompatReporterTelemetryMiddleware(|// WebCompatReporterTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt

rm -vf app/src/*/java/org/mozilla/fenix/bookmarks/BookmarksTelemetryMiddleware.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/ActivationPing.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/AdjustMetricsService.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/BreadcrumbsRecorder.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/Event.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/FirstSessionPing.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/GrowthDataWorker.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/InstallReferrerMetricsService.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/MarketingAttributionService.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/MetricController.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/MetricsMiddleware.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/MetricsService.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/MetricsStorage.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/MozillaProductDetector.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/toolbar/BrowserToolbarTelemetryMiddleware.kt
rm -vf app/src/*/java/org/mozilla/fenix/downloads/listscreen/middleware/DownloadTelemetryMiddleware.kt
rm -vf app/src/*/java/org/mozilla/fenix/home/toolbar/BrowserToolbarTelemetryMiddleware.kt
rm -vf app/src/*/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptTelemetryMiddleware.kt
rm -vf app/src/*/java/org/mozilla/fenix/tabstray/TabsTrayTelemetryMiddleware.kt
rm -vf app/src/*/java/org/mozilla/fenix/webcompat/middleware/WebCompatReporterTelemetryMiddleware.kt
rm -vrf app/src/*/java/org/mozilla/fenix/components/metrics/fonts
rm -vrf app/src/*/java/org/mozilla/fenix/settings/datachoices
rm -vrf app/src/*/java/org/mozilla/fenix/telemetry

# Let it be IronFox
$SED -i \
    -e 's/Notifications help you stay safer with Firefox/Enable notifications/' \
    -e 's/Securely send tabs between your devices and discover other privacy features in Firefox./IronFox can remind you when private tabs are open and show you the progress of file downloads./' \
    -e 's/Agree and continue/Continue/' \
    -e 's/Address bar - Firefox Suggest/Address bar/' \
    -e 's/Firefox Daylight/IronFox/; s/Firefox Fenix/IronFox/; s/Mozilla Firefox/IronFox/; s/Firefox/IronFox/g' \
    -e '/about_content/s/Mozilla/IronFox OSS/' \
    -e 's/IronFox Suggest/Firefox Suggest/' \
    -e 's/Learn more about Firefox Suggest/Learn more about search suggestions/' \
    -e 's/Suggestions from %1$s/Suggestions from Mozilla/' \
    -e 's/Notifications for tabs received from other IronFox devices/Notifications for tabs received from other devices/' \
    -e 's/To send a tab, sign in to IronFox/To send a tab, sign in to a Firefox-based web browser/' \
    -e 's/On your computer open IronFox and/On your computer, open a Firefox-based web browser, and/' \
    -e 's/Fast and secure web browsing/The private, secure, user first web browser for Android./' \
    -e 's/Sync is on/Firefox Sync is on/' \
    -e 's/No account?/No Firefox account?/' \
    -e 's/to sync IronFox/to sync your browsing data/' \
    -e 's/%s will stop syncing with your account/%s will stop syncing with your Firefox account/' \
    -e 's/%1$s decides when to use secure DNS to protect your privacy/IronFox will use your system’s DNS resolver/' \
    -e 's/Use your default DNS resolver if there is a problem with the secure DNS provider/Use your default DNS resolver/' \
    -e 's/You control when to use secure DNS and choose your provider/IronFox will use secure DNS with your chosen provider by default, but might fallback to your system’s DNS resolver if secure DNS is unavailable/' \
    -e '/preference_doh_off_summary/s/Use your default DNS resolver/Never use secure DNS, even if supported by your system’s DNS resolver/' \
    -e 's/Learn more about sync/Learn more about Firefox Sync/' \
    -e 's/search?client=firefox&amp;q=%s/search?q=%s/' \
    -e 's/You don’t have any tabs open in IronFox on your other devices/You don’t have any tabs open on your other devices/' \
    -e 's/Google Search/Google search/' \
    app/src/*/res/values*/*strings.xml
$SED -i -e 's/GOOGLE_URL = ".*"/GOOGLE_URL = ""/' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
$SED -i -e 's/GOOGLE_US_URL = ".*"/GOOGLE_US_URL = ""/' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
$SED -i -e 's/GOOGLE_XX_URL = ".*"/GOOGLE_XX_URL = ""/' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
$SED -i -e 's|WHATS_NEW_URL = ".*"|WHATS_NEW_URL = "https://gitlab.com/ironfox-oss/IronFox/-/releases"|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
$SED -i 's|https://www.mozilla.org/firefox/android/notes|https://gitlab.com/ironfox-oss/IronFox/-/releases|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt

# Fenix uses reflection to create a instance of profile based on the text of
# the label, see
# app/src/main/java/org/mozilla/fenix/perf/ProfilerStartDialogFragment.kt#185
$SED -i \
    -e '/Firefox(.*, .*)/s/Firefox/IronFox/' \
    -e 's/firefox_threads/ironfox_threads/' \
    -e 's/firefox_features/ironfox_features/' \
    app/src/main/java/org/mozilla/fenix/perf/ProfilerUtils.kt

# Replace proprietary artwork
rm -vf app/src/release/res/drawable/ic_launcher_foreground.xml
rm -vf app/src/release/res/mipmap-*/ic_launcher.webp
rm -vf app/src/release/res/values/colors.xml
rm -vf app/src/main/res/values-v24/styles.xml
$SED -i -e '/android:roundIcon/d' app/src/main/AndroidManifest.xml
$SED -i -e '/SplashScreen/,+5d' app/src/main/res/values-v27/styles.xml
mkdir -vp app/src/release/res/mipmap-anydpi-v26
$SED -i \
    -e 's/googleg_standard_color_18/ic_download/' \
    app/src/main/java/org/mozilla/fenix/components/menu/compose/MenuItem.kt \
    app/src/main/java/org/mozilla/fenix/compose/list/ListItem.kt

# Remove default built-in search engines
rm -vrf app/src/*/assets/searchplugins/*

# Create wallpaper directories
mkdir -vp app/src/main/assets/wallpapers/algae
mkdir -vp app/src/main/assets/wallpapers/colorful-bubbles
mkdir -vp app/src/main/assets/wallpapers/dark-dune
mkdir -vp app/src/main/assets/wallpapers/dune
mkdir -vp app/src/main/assets/wallpapers/firey-red

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

$SED -i -e "s/include \".*\"/include $abi/" app/build.gradle
echo "$llvmtarget" >"$builddir/targets_to_build"

# Enable the auto-publication workflow
# shellcheck disable=SC2154
echo "autoPublish.application-services.dir=$application_services" >>local.properties

# Disable FUS Service or we'll get errors like:
# Exception while loading configuration for :app: Could not load the value of field `__buildFusService__` of task `:app:compileFenixReleaseKotlin` of type `org.jetbrains.kotlin.gradle.tasks.KotlinCompile`.
echo "kotlin.internal.collectFUSMetrics=false" >> local.properties

# Apply Fenix overlay
apply_overlay "$patches/fenix-overlay/"

popd

#
# Glean
#

# We currently remove Glean fully from Android Components (See `a-c-remove-glean.patch`) and Application Services (see `a-s-remove-glean.patch`). Unfortunately, it's currently untenable to remove Glean in its entirety from Fenix (though we do remove Mozilla's `Glean Service` library/implementation). So, our approach is to stub Glean for Fenix, which we can do thanks to Tor's no-op UniFFi binding generator, as well as our `fenix-remove-glean.patch` patch, and the commands below.
## https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/tree/main/projects/glean

# shellcheck disable=SC2154
pushd "$glean"

echo "rust.targets=$PLATFORM-$PLATFORM_ARCHITECTURE,$rusttarget" >>local.properties

# Apply patches
glean_apply_patches

localize_maven

# Break the dependency on older Rust
$SED -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/Cargo.toml
$SED -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/build/Cargo.toml
$SED -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/rlb/Cargo.toml

# No-op Glean
$SED -i -e 's|allowGleanInternal = .*|allowGleanInternal = false|g' glean-core/android/build.gradle
$SED -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' glean-core/python/glean/config.py
$SED -i -e '/enable_internal_pings:/s/true/false/' glean-core/python/glean/config.py
$SED -i -e "s|DEFAULT_GLEAN_ENDPOINT: .*|DEFAULT_GLEAN_ENDPOINT: \&\str = \"\";|g" glean-core/rlb/src/configuration.rs
$SED -i -e '/enable_internal_pings:/s/true/false/' glean-core/rlb/src/configuration.rs
$SED -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
$SED -i -e '/enableInternalPings:/s/true/false/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
$SED -i -e '/enableEventTimestamps:/s/true/false/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
$SED -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/core_metrics.rs
$SED -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/glean_metrics.rs
$SED -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/internal_metrics.rs
$SED -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/lib_unit_tests.rs
$SED -i -e 's|include_client_id: .*|include_client_id: false|g' glean-core/pings.yaml
$SED -i -e 's|send_if_empty: .*|send_if_empty: false|g' glean-core/pings.yaml
$SED -i -e 's|"$rootDir/glean-core/android/metrics.yaml"|// "$rootDir/glean-core/android/metrics.yaml"|g' glean-core/android/build.gradle
rm -vf glean-core/android/metrics.yaml

# Ensure we're building for release
$SED -i -e 's|ext.cargoProfile = .*|ext.cargoProfile = "release"|g' build.gradle

# Use Tor's no-op UniFFi binding generator
if [[ "$PLATFORM" == "darwin" ]]; then
    # Do nothing here, unfortunately this doesn't appear to work on macOS ATM
    ## We don't ship or build releases from macOS; and regardless, we still stub Glean's Kotlin code through our glean-overlay, disable it entirely, etc - so, while this isn't ideal, it's not the end of the world - the biggest implication here is probably just extra space
    echo "macOS: Doing nothing..."
else
    patch -p1 --no-backup-if-mismatch --quiet < "$patches/glean-noop-uniffi.patch"
    if [[ -n ${FDROID_BUILD+x} ]]; then
        $SED -i -e "s|commandLine 'cargo', 'uniffi-bindgen'|commandLine '$uniffi/target/release/uniffi-bindgen'|g" glean-core/android/build.gradle
    else
        $SED -i -e "s|commandLine 'cargo', 'uniffi-bindgen'|commandLine '$uniffi/uniffi-bindgen'|g" glean-core/android/build.gradle
    fi
fi

# Ensure we're building for release
$SED -i -e 's|ext.cargoProfile = .*|ext.cargoProfile = "release"|g' build.gradle

# Use Tor's no-op UniFFi binding generator
if [[ -n ${FDROID_BUILD+x} ]]; then
    sed -i -e "s|commandLine 'cargo', 'uniffi-bindgen'|commandLine '$uniffi/target/release/uniffi-bindgen'|g" glean-core/android/build.gradle
else
    sed -i -e "s|commandLine 'cargo', 'uniffi-bindgen'|commandLine '$uniffi/uniffi-bindgen'|g" glean-core/android/build.gradle
fi

# Apply Glean overlay
apply_overlay "$patches/glean-overlay/"

popd

#
# Android Components
#

# shellcheck disable=SC2154
pushd "$android_components"

# Remove default built-in search engines
rm -vrf components/feature/search/src/*/assets/searchplugins/*

# Nuke the "Mozilla Android Components - Ads Telemetry" and "Mozilla Android Components - Search Telemetry" extensions
## We don't install these with fenix-disable-telemetry.patch - so no need to keep the files around...
rm -vrf components/feature/search/src/*/assets/extensions/ads
rm -vrf components/feature/search/src/*/assets/extensions/search

# We can also remove the directories/libraries themselves as well
rm -vf components/feature/search/src/*/java/mozilla/components/feature/search/middleware/AdsTelemetryMiddleware.kt
rm -vrf components/feature/search/src/*/java/mozilla/components/feature/search/telemetry

# Remove the 'search telemetry' config
rm -vf components/feature/search/src/*/assets/search/search_telemetry_v2.json

# Since we remove the Glean Service and Web Compat Reporter dependencies, the existence of these files causes build issues
## We don't build or use these sample libraries at all anyways, so instead of patching these files, I don't see a reason why we shouldn't just delete them. 
rm -vf samples/browser/build.gradle
rm -vf samples/crash/build.gradle
rm -vf samples/glean/build.gradle
rm -vf samples/glean/samples-glean-library/build.gradle

# Remove Nimbus
rm -vf components/browser/engine-gecko/geckoview.fml.yaml
rm -vrf components/browser/engine-gecko/src/main/java/mozilla/components/experiment
$SED -i -e 's|-keep class mozilla.components.service.nimbus|#-keep class mozilla.components.service.nimbus|' components/service/nimbus/proguard-rules-consumer.pro

# Apply a-c overlay
apply_overlay "$patches/a-c-overlay/"

popd

#
# Application Services
#

pushd "${application_services}"

# Apply patches
a-s_apply_patches

# Break the dependency on older A-C
$SED -i -e "/^android-components = \"/c\\android-components = \"${FIREFOX_VERSION}\"" gradle/libs.versions.toml

# Break the dependency on older Rust
$SED -i -e "s|channel = .*|channel = \""${RUST_VERSION}\""|g" rust-toolchain.toml

# Disable debug
$SED -i -e 's|debug = .*|debug = false|g' Cargo.toml

echo "rust.targets=$PLATFORM-$PLATFORM_ARCHITECTURE,$rusttarget" >>local.properties
$SED -i -e '/NDK ez-install/,/^$/d' libs/verify-android-ci-environment.sh
$SED -i -e '/content {/,/}/d' build.gradle

localize_maven

# Fix stray
$SED -i -e '/^    mavenLocal/{n;d}' tools/nimbus-gradle-plugin/build.gradle
# Fail on use of prebuilt binary
$SED -i 's|https://|hxxps://|' tools/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy

# No-op Nimbus (Experimentation)
$SED -i -e 's|NimbusInterface.isLocalBuild() = .*|NimbusInterface.isLocalBuild() = true|g' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt
$SED -i -e 's|isFetchEnabled(): Boolean = .*|isFetchEnabled(): Boolean = false|g' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt

# Remove the 'search telemetry' config
rm -vf components/remote_settings/dumps/*/search-telemetry-v2.json
$SED -i -e 's|("main", "search-telemetry-v2"),|// ("main", "search-telemetry-v2"),|g' components/remote_settings/src/client.rs

# Apply Application Services overlay
apply_overlay "$patches/a-s-overlay/"

popd

# WASI SDK
# shellcheck disable=SC2154
if [[ -n ${FDROID_BUILD+x} ]]; then
    pushd "$wasi"
    patch -p1 --no-backup-if-mismatch --quiet <"$mozilla_release/taskcluster/scripts/misc/wasi-sdk.patch"

    # Break the dependency on older cmake
    $SED -i -e 's|cmake_minimum_required(VERSION .*)|cmake_minimum_required(VERSION 3.5.0)|g' wasi-sdk.cmake

    popd

    # Break the dependency on older cmake
    sed -i -e 's|cmake_minimum_required(VERSION .*)|cmake_minimum_required(VERSION 3.5.0)|g' wasi-sdk.cmake

    popd

    export wasi_install=$wasi/build/install/wasi
else
    export wasi_install=$wasi
fi

# uniffi-bindgen
if [[ -n ${FDROID_BUILD+x} ]]; then
    pushd "$uniffi"

    # Break the dependency on older Rust
    $SED -i -e "s|channel = .*|channel = \""${RUST_VERSION}\""|g" rust-toolchain.toml

    popd
fi

# Gecko
pushd "$mozilla_release"

# Apply patches
apply_patches

# Let it be IronFox (part 2...)
mkdir -vp mobile/android/branding/ironfox/content
mkdir -vp mobile/android/branding/ironfox/locales/en-US
$SED -i -e 's/Fennec/IronFox/g; s/Firefox/IronFox/g' build/moz.configure/init.configure
$SED -i -e 's|"MOZ_APP_VENDOR", ".*"|"MOZ_APP_VENDOR", "IronFox OSS"|g' mobile/android/moz.configure
echo '' >>mobile/android/moz.configure
echo 'include("ironfox.configure")' >>mobile/android/moz.configure

$SED -i '/{"about", "chrome:\/\/global\/content\/aboutAbout.html", 0},/a \    {"ironfox", "chrome:\/\/global\/content\/ironfox.html",\n     nsIAboutModule::URI_SAFE_FOR_UNTRUSTED_CONTENT},' docshell/base/nsAboutRedirector.cpp
$SED -i '/{"about", "chrome:\/\/global\/content\/aboutAbout.html", 0},/a \    {"attribution", "chrome:\/\/global\/content\/attribution.html",\n     nsIAboutModule::URI_SAFE_FOR_UNTRUSTED_CONTENT},' docshell/base/nsAboutRedirector.cpp
$SED -i "/about_pages.append('inference')/a \    about_pages.append('ironfox')" docshell/build/components.conf
$SED -i "/about_pages.append('inference')/a \    about_pages.append('attribution')" docshell/build/components.conf
echo '' >>toolkit/content/jar.mn
echo '   content/global/attribution.css' >>toolkit/content/jar.mn
echo '   content/global/attribution.html' >>toolkit/content/jar.mn
echo '   content/global/ironfox.css' >>toolkit/content/jar.mn
echo '   content/global/ironfox.html' >>toolkit/content/jar.mn

# Copy policy definitions/schema/etc. from Firefox for Desktop
cp -vrf browser/components/enterprisepolicies mobile/android/components

# about:policies
echo '' >>toolkit/content/jar.mn
echo '   content/global/policies/aboutPolicies.css              (aboutPolicies.css)' >>toolkit/content/jar.mn
echo '   content/global/policies/aboutPolicies.html             (aboutPolicies.html)' >>toolkit/content/jar.mn
echo '   content/global/policies/aboutPolicies.js               (aboutPolicies.js)' >>toolkit/content/jar.mn
echo '   content/global/policies/policies-active.svg            (policies-active.svg)' >>toolkit/content/jar.mn
echo '   content/global/policies/policies-documentation.svg            (policies-documentation.svg)' >>toolkit/content/jar.mn
echo '   content/global/policies/policies-error.svg            (policies-error.svg)' >>toolkit/content/jar.mn
cp -vf browser/locales/en-US/browser/aboutPolicies.ftl toolkit/locales/en-US/toolkit/about/
cp -vf browser/locales/en-US/browser/policies/policies-descriptions.ftl toolkit/locales/en-US/toolkit/about/
cp -vrf browser/components/enterprisepolicies/content toolkit
$SED -i "/about_pages.append('inference')/a \    about_pages.append('policies')" docshell/build/components.conf

# Ensure we're building for release
$SED -i -e 's/variant=variant(.*)/variant=variant("release")/' mobile/android/gradle.configure

# Fix v125 aar output not including native libraries
$SED -i \
    -e "s/singleVariant('debug')/singleVariant('release')/" \
    mobile/android/geckoview/build.gradle

# Hack the timeout for
# geckoview:generateJNIWrappersForGeneratedWithGeckoBinariesDebug
$SED -i \
    -e 's/max_wait_seconds=600/max_wait_seconds=1800/' \
    mobile/android/gradle.py

# Ensure we're using our mozconfig
echo "mozilla-central.mozconfig=$mozilla_release/mozconfig" >>local.properties

# Break the dependency on older Rust
$SED -i -e "s|rust-version = .*|rust-version = \""${RUST_VERSION}\""|g" Cargo.toml
$SED -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" intl/icu_capi/Cargo.toml
$SED -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" intl/icu_segmenter_data/Cargo.toml

# Disable debug
$SED -i -e 's|debug-assertions = .*|debug-assertions = false|g' Cargo.toml
$SED -i -e 's|debug = .*|debug = false|g' gfx/harfbuzz/src/rust/Cargo.toml

# Remove the `NETWORK_ACCESS_STATE` permission (Fenix)
$SED -i -e 's|<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />|<!-- <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" /> -->|' mobile/android/fenix/app/src/main/AndroidManifest.xml

# Remove the `NETWORK_ACCESS_STATE` permission (GeckoView)
$SED -i -e 's|<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>|<!-- <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" /> -->|' mobile/android/geckoview/src/main/AndroidManifest.xml

# Disable Normandy (Experimentation)
$SED -i -e 's|"MOZ_NORMANDY", .*)|"MOZ_NORMANDY", False)|g' mobile/android/moz.configure

# Disable SSLKEYLOGGING
## https://bugzilla.mozilla.org/show_bug.cgi?id=1183318
## https://bugzilla.mozilla.org/show_bug.cgi?id=1915224
$SED -i -e 's|NSS_ALLOW_SSLKEYLOGFILE ?= .*|NSS_ALLOW_SSLKEYLOGFILE ?= 0|g' security/nss/lib/ssl/Makefile
echo '' >>security/moz.build
echo 'gyp_vars["enable_sslkeylogfile"] = 0' >>security/moz.build

# Disable telemetry
$SED -i -e 's|"MOZ_SERVICES_HEALTHREPORT", .*)|"MOZ_SERVICES_HEALTHREPORT", False)|g' mobile/android/moz.configure

# Disable crash reporting (GeckoView)
$SED -i -e '/MOZ_CRASHREPORTER/s/true/false/' mobile/android/geckoview/build.gradle

# Disable debug (GeckoView)
$SED -i -e '/DEBUG_BUILD/s/true/false/' mobile/android/geckoview/build.gradle

# Set flag for 'official' builds to ensure we're not enabling debug/dev settings
# https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/27623
# We're also setting the "MOZILLA_OFFICIAL" env variable below
$SED -i -e '/MOZILLA_OFFICIAL/s/false/true/' mobile/android/geckoview/build.gradle

# Target release
$SED -i -e '/RELEASE_OR_BETA/s/false/true/' mobile/android/geckoview/build.gradle
$SED -i -e '/NIGHTLY_BUILD/s/true/false/' mobile/android/geckoview/build.gradle

# Disable crash reporting (GeckoView)
$SED -i -e '/MOZ_CRASHREPORTER/s/true/false/' mobile/android/geckoview/build.gradle

# Disable debug (GeckoView)
$SED -i -e '/DEBUG_BUILD/s/true/false/' mobile/android/geckoview/build.gradle

# Set flag for 'official' builds to ensure we're not enabling debug/dev settings
# https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/27623
# We're also setting the "MOZILLA_OFFICIAL" env variable below
$SED -i -e '/MOZILLA_OFFICIAL/s/false/true/' mobile/android/geckoview/build.gradle

# Target release
$SED -i -e '/RELEASE_OR_BETA/s/false/true/' mobile/android/geckoview/build.gradle
$SED -i -e '/NIGHTLY_BUILD/s/true/false/' mobile/android/geckoview/build.gradle

# Ensure UA is always set to Firefox
$SED -i -e 's|"MOZ_APP_UA_NAME", ".*"|"MOZ_APP_UA_NAME", "Firefox"|g' mobile/android/moz.configure

# Include additional Remote Settings local dumps (+ add our own...)
$SED -i -e 's|"mobile/"|"0"|g' services/settings/dumps/blocklists/moz.build
$SED -i -e 's|"mobile/"|"0"|g' services/settings/dumps/security-state/moz.build
echo '' >>services/settings/dumps/main/moz.build
echo 'FINAL_TARGET_FILES.defaults.settings.main += [' >>services/settings/dumps/main/moz.build
echo '    "anti-tracking-url-decoration.json",' >>services/settings/dumps/main/moz.build
echo '    "cookie-banner-rules-list.json",' >>services/settings/dumps/main/moz.build
echo '    "hijack-blocklists.json",' >>services/settings/dumps/main/moz.build
echo '    "ironfox-fingerprinting-protection-overrides.json",' >>services/settings/dumps/main/moz.build
echo '    "translations-models.json",' >>services/settings/dumps/main/moz.build
echo '    "translations-wasm.json",' >>services/settings/dumps/main/moz.build
echo '    "url-classifier-skip-urls.json",' >>services/settings/dumps/main/moz.build
echo '    "url-parser-default-unknown-schemes-interventions.json",' >>services/settings/dumps/main/moz.build
echo ']' >>services/settings/dumps/main/moz.build

# No-op AMO collections/recommendations
$SED -i -e 's/DEFAULT_COLLECTION_NAME = ".*"/DEFAULT_COLLECTION_NAME = ""/' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
$SED -i 's|7e8d6dc651b54ab385fb8791bf9dac||g' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
$SED -i -e 's/DEFAULT_COLLECTION_USER = ".*"/DEFAULT_COLLECTION_USER = ""/' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
$SED -i -e 's/DEFAULT_SERVER_URL = ".*"/DEFAULT_SERVER_URL = ""/' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
$SED -i 's|https://services.addons.mozilla.org||g' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt

# Remove unnecessary crash reporting components
rm -vrf mobile/android/android-components/components/support/appservices/src/main/java/mozilla/components/support/rusterrors

$SED -i -e 's|enabled: Boolean = .*|enabled: Boolean = false,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
$SED -i -e 's|sendCaughtExceptions: Boolean = .*|sendCaughtExceptions: Boolean = false,|g' mobile/android/android-components/components/lib/crash-sentry/src/*/java/mozilla/components/lib/crash/sentry/SentryService.kt
$SED -i -e 's|shouldPrompt: Prompt = .*|shouldPrompt: Prompt = Prompt.ALWAYS,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
$SED -i -e 's|useLegacyReporting: Boolean = .*|useLegacyReporting: Boolean = false,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
$SED -i -e 's|var enabled: Boolean = false,|var enabled: Boolean = enabled|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt

$SED -i 's|crash-reports-ondemand||g' toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs
$SED -i -e 's/REMOTE_SETTINGS_CRASH_COLLECTION = ".*"/REMOTE_SETTINGS_CRASH_COLLECTION = ""/' toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs

# No-op MARS
$SED -i -e 's/MARS_ENDPOINT_BASE_URL = ".*"/MARS_ENDPOINT_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt
$SED -i -e 's/MARS_ENDPOINT_STAGING_BASE_URL = ".*"/MARS_ENDPOINT_STAGING_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt

# Remove MARS
$SED -i 's|- components:service-mars|# - components:service-mars|g' mobile/android/fenix/.buildconfig.yml
$SED -i "s|implementation project(':components:service-mars')|// implementation project(':components:service-mars')|g" mobile/android/fenix/app/build.gradle

rm -vf mobile/android/fenix/app/src/main/java/org/mozilla/fenix/home/TopSitesRefresher.kt

# No-op GeoIP/Region service
## https://searchfox.org/mozilla-release/source/toolkit/modules/docs/Region.rst
$SED -i -e 's/GEOIP_SERVICE_URL = ".*"/GEOIP_SERVICE_URL = ""/' mobile/android/android-components/components/service/location/src/*/java/mozilla/components/service/location/MozillaLocationService.kt
$SED -i -e 's/USER_AGENT = ".*/USER_AGENT = ""/' mobile/android/android-components/components/service/location/src/*/java/mozilla/components/service/location/MozillaLocationService.kt

# No-op Normandy (Experimentation)
$SED -i -e 's/REMOTE_SETTINGS_COLLECTION = ".*"/REMOTE_SETTINGS_COLLECTION = ""/' toolkit/components/normandy/lib/RecipeRunner.sys.mjs
$SED -i 's|normandy-recipes-capabilities||g' toolkit/components/normandy/lib/RecipeRunner.sys.mjs

# No-op Nimbus (Experimentation)
$SED -i -e 's|import org.mozilla.fenix.ext.recordEventInNimbus|// import org.mozilla.fenix.ext.recordEventInNimbus|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt
$SED -i -e 's|context.recordEventInNimbus|// context.recordEventInNimbus|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt
$SED -i -e 's|FxNimbus.features.junoOnboarding.recordExposure|// FxNimbus.features.junoOnboarding.recordExposure|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/utils/Settings.kt
$SED -i 's|classpath "${ApplicationServicesConfig.groupId}:tooling-nimbus-gradle|// "${ApplicationServicesConfig.groupId}:tooling-nimbus-gradle|g' build.gradle

# No-op Pocket
$SED -i -e 's/SPOCS_ENDPOINT_DEV_BASE_URL = ".*"/SPOCS_ENDPOINT_DEV_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt
$SED -i -e 's/SPOCS_ENDPOINT_PROD_BASE_URL = ".*"/SPOCS_ENDPOINT_PROD_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt
$SED -i -e 's/POCKET_ENDPOINT_URL = ".*"/POCKET_ENDPOINT_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/stories/api/PocketEndpointRaw.kt

# No-op search telemetry
$SED -i 's|search-telemetry-v2||g' mobile/android/fenix/app/src/*/java/org/mozilla/fenix/components/Core.kt

# No-op telemetry (Gecko)
$SED -i -e '/enable_internal_pings:/s/true/false/' toolkit/components/glean/src/init/mod.rs
$SED -i -e '/upload_enabled =/s/true/false/' toolkit/components/glean/src/init/mod.rs
$SED -i -e '/use_core_mps:/s/true/false/' toolkit/components/glean/src/init/mod.rs
$SED -i 's|localhost||g' toolkit/components/telemetry/pings/BackgroundTask_pingsender.sys.mjs
$SED -i 's|localhost||g' toolkit/components/telemetry/pingsender/pingsender.cpp
$SED -i -e 's/usageDeletionRequest.setEnabled(.*)/usageDeletionRequest.setEnabled(false)/' toolkit/components/telemetry/app/UsageReporting.sys.mjs
$SED -i -e 's|useTelemetry = .*|useTelemetry = false;|g' toolkit/components/telemetry/core/Telemetry.cpp
$SED -i '/# This must remain last./i gkrust_features += ["glean_disable_upload"]\n' toolkit/library/rust/gkrust-features.mozbuild

$SED -i -e 's|include_client_id: .*|include_client_id: false|g' toolkit/components/glean/pings.yaml
$SED -i -e 's|send_if_empty: .*|send_if_empty: false|g' toolkit/components/glean/pings.yaml
$SED -i -e 's|include_client_id: .*|include_client_id: false|g' toolkit/components/nimbus/pings.yaml
$SED -i -e 's|send_if_empty: .*|send_if_empty: false|g' toolkit/components/nimbus/pings.yaml

# No-op telemetry (GeckoView)
$SED -i -e 's|allowMetricsFromAAR = .*|allowMetricsFromAAR = false|g' mobile/android/android-components/components/browser/engine-gecko/build.gradle

# Prevent DoH canary requests
$SED -i -e 's/GLOBAL_CANARY = ".*"/GLOBAL_CANARY = ""/' toolkit/components/doh/DoHHeuristics.sys.mjs
$SED -i -e 's/ZSCALER_CANARY = ".*"/ZSCALER_CANARY = ""/' toolkit/components/doh/DoHHeuristics.sys.mjs

# Remove unused crash reporting services/components
rm -vf mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/MinidumpAnalyzer.kt
rm -vf mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/MozillaSocorroService.kt

# Remove example dependencies
## Also see `gecko-remove-example-dependencies.patch`
$SED -i "s|include ':annotations', .*|include ':annotations'|g" settings.gradle
$SED -i "s|project(':messaging_example'|// project(':messaging_example'|g" settings.gradle
$SED -i "s|project(':port_messaging_example'|// project(':port_messaging_example'|g" settings.gradle
$SED -i -e 's#if (rootDir.toString().contains("android-components") || !project.key.startsWith("samples"))#if (!project.key.startsWith("samples"))#' mobile/android/shared-settings.gradle

# Remove ExoPlayer
$SED -i "s|include ':exoplayer2'|// include ':exoplayer2'|g" settings.gradle
$SED -i "s|project(':exoplayer2'|// project(':exoplayer2'|g" settings.gradle

# Remove unused/unnecessary DebugConfig class
$SED -i -e 's|-keep class org.mozilla.gecko.util.DebugConfig|#-keep class org.mozilla.gecko.util.DebugConfig|' mobile/android/fenix/app/proguard-rules.pro

# Remove proprietary/tracking libraries
$SED -i 's|adjust|# adjust|g' gradle/libs.versions.toml
$SED -i 's|firebase-messaging|# firebase-messaging|g' gradle/libs.versions.toml
$SED -i 's|installreferrer|# installreferrer|g' gradle/libs.versions.toml
$SED -i 's|play-review|# play-review|g' gradle/libs.versions.toml
$SED -i 's|play-services|# play-services|g' gradle/libs.versions.toml
$SED -i 's|thirdparty-sentry|# thirdparty-sentry|g' gradle/libs.versions.toml
$SED -i 's|sentry|# sentry|g' gradle/libs.versions.toml

$SED -i 's|-include "adjust-keeps.cfg"|# -include "adjust-keeps.cfg"|g' mobile/android/config/proguard/proguard.cfg
$SED -i 's|-include "play-services-keeps.cfg"|# -include "play-services-keeps.cfg"|g' mobile/android/config/proguard/proguard.cfg
$SED -i 's|-include "proguard-leanplum.cfg"|# -include "proguard-leanplum.cfg"|g' mobile/android/config/proguard/proguard.cfg
rm -vf mobile/android/config/proguard/adjust-keeps.cfg
rm -vf mobile/android/config/proguard/play-services-keeps.cfg
rm -vf mobile/android/config/proguard/proguard-leanplum.cfg

# Remove Web Compatibility Reporter
## Also see `fenix-remove-webcompat-reporter.patch`
$SED -i 's|- components:feature-webcompat-reporter|# - components:feature-webcompat-reporter|g' mobile/android/fenix/.buildconfig.yml
$SED -i "s|implementation project(':components:feature-webcompat-reporter')|// implementation project(':components:feature-webcompat-reporter')|g" mobile/android/fenix/app/build.gradle

# Replace Google Play FIDO with microG
$SED -i 's|libs.play.services.fido|"org.microg.gms:play-services-fido:v0.0.0.250932"|g' mobile/android/geckoview/build.gradle

# Remove Glean
source "$rootdir/scripts/deglean.sh"

# Nuke undesired Mozilla endpoints
source "$rootdir/scripts/noop_mozilla_endpoints.sh"

# Remove unused media
## Based on Tor Browser: https://gitlab.torproject.org/tpo/applications/tor-browser/-/commit/264dc7cd915e75ba9db3a27e09253acffe3f2311
## This should help reduce our APK sizes...
rm -vf mobile/android/fenix/app/src/debug/ic_launcher-playstore.png
rm -vf mobile/android/fenix/app/src/debug/ic_launcher-web.webp
rm -vf mobile/android/fenix/app/src/debug/res/drawable/ic_launcher_foreground.xml
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-anydpi-v26/ic_launcher_round.xml
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-anydpi-v26/ic_launcher.xml
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-hdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-hdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-mdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-mdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-xhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-xhdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-xxhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-xxhdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-xxxhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/debug/res/mipmap-xxxhdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/main/ic_launcher_private-web.webp
rm -vf mobile/android/fenix/app/src/main/ic_launcher-web.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable/ic_launcher_foreground.xml
rm -vf mobile/android/fenix/app/src/main/res/drawable/ic_launcher_monochrome.xml
rm -vf mobile/android/fenix/app/src/main/res/drawable/ic_onboarding_search_widget.xml
rm -vf mobile/android/fenix/app/src/main/res/drawable/ic_onboarding_sync.xml
rm -vf mobile/android/fenix/app/src/main/res/drawable/ic_wordmark_logo.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable/ic_wordmark_text_normal.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable/ic_wordmark_text_private.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable/microsurvey_success.xml
rm -vf mobile/android/fenix/app/src/main/res/drawable/onboarding_ctd_sync.xml
rm -vf mobile/android/fenix/app/src/main/res/drawable-hdpi/fenix_search_widget.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-hdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-hdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-mdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-mdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-xhdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-xhdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-xxhdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-xxhdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-xxxhdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/main/res/drawable-xxxhdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-anydpi-v26/ic_launcher_private_round.xml
rm -vf mobile/android/fenix/app/src/main/res/mipmap-anydpi-v26/ic_launcher_private.xml
rm -vf mobile/android/fenix/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
rm -vf mobile/android/fenix/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
rm -vf mobile/android/fenix/app/src/main/res/mipmap-hdpi/ic_launcher_private_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-hdpi/ic_launcher_private.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-hdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-hdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-mdpi/ic_launcher_private_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-mdpi/ic_launcher_private.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-mdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-mdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xhdpi/ic_launcher_private_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xhdpi/ic_launcher_private.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xhdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xxhdpi/ic_launcher_private_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xxhdpi/ic_launcher_private.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xxhdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xxxhdpi/ic_launcher_private_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xxxhdpi/ic_launcher_private.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/main/res/mipmap-xxxhdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable/ic_firefox.xml
rm -vf mobile/android/fenix/app/src/nightly/res/drawable/ic_launcher_foreground.xml
rm -vf mobile/android/fenix/app/src/nightly/res/drawable/ic_wordmark_logo.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable/ic_wordmark_text_normal.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable/ic_wordmark_text_private.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-hdpi/fenix_search_widget.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-hdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-hdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-mdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-mdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-xhdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-xhdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-xxhdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-xxhdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-xxxhdpi/ic_logo_wordmark_normal.webp
rm -vf mobile/android/fenix/app/src/nightly/res/drawable-xxxhdpi/ic_logo_wordmark_private.webp
rm -vf mobile/android/fenix/app/src/nightly/res/ic_launcher-web.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-hdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-hdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-mdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-mdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-xhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-xhdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-xxhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-xxhdpi/ic_launcher.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-xxxhdpi/ic_launcher_round.webp
rm -vf mobile/android/fenix/app/src/nightly/res/mipmap-xxxhdpi/ic_launcher.webp
$SED -i -e 's|R.drawable.microsurvey_success|R.drawable.mozac_lib_crash_notification|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/microsurvey/ui/MicrosurveyCompleted.kt
$SED -i -e 's|R.drawable.ic_onboarding_sync|R.drawable.mozac_lib_crash_notification|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/onboarding/view/OnboardingScreen.kt
$SED -i -e 's|ic_onboarding_search_widget|mozac_lib_crash_notification|' mobile/android/fenix/app/onboarding.fml.yaml
$SED -i -e 's|ic_onboarding_sync|mozac_lib_crash_notification|' mobile/android/fenix/app/onboarding.fml.yaml

# Take back control of preferences
## This prevents GeckoView from overriding the follow prefs at runtime, which also means we don't have to worry about Nimbus overriding them, etc...
## The prefs will instead take the values we specify in the phoenix/ironfox .js files, and users will also be able to override them via the `about:config`
## This is ideal for features that aren't exposed by the UI, it gives more freedom/control back to users, and it's great to ensure things are always configured how we want them...
$SED -i \
    -e 's|"browser.safebrowsing.provider."|"z99.ignore.string."|' \
    -e 's|"cookiebanners.service.detectOnly"|"z99.ignore.boolean"|' \
    -e 's|"cookiebanners.service.enableGlobalRules"|"z99.ignore.boolean"|' \
    -e 's|"cookiebanners.service.enableGlobalRules.subFrames"|"z99.ignore.boolean"|' \
    -e 's|"cookiebanners.service.mode"|"z99.ignore.integer"|' \
    -e 's|"network.cookie.cookieBehavior"|"z99.ignore.integer"|' \
    -e 's|"network.cookie.cookieBehavior.pbmode"|"z99.ignore.integer"|' \
    -e 's|"privacy.annotate_channels.strict_list.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.bounceTrackingProtection.mode"|"z99.ignore.integer"|' \
    -e 's|"privacy.purge_trackers.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.query_stripping.allow_list"|"z99.ignore.string"|' \
    -e 's|"privacy.query_stripping.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.query_stripping.enabled.pbmode"|"z99.ignore.boolean"|' \
    -e 's|"privacy.query_stripping.strip_list"|"z99.ignore.string"|' \
    -e 's|"privacy.socialtracking.block_cookies.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.trackingprotection.annotate_channels"|"z99.ignore.boolean"|' \
    -e 's|"privacy.trackingprotection.cryptomining.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.trackingprotection.emailtracking.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.trackingprotection.emailtracking.pbmode.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.trackingprotection.fingerprinting.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.trackingprotection.socialtracking.enabled"|"z99.ignore.boolean"|' \
    -e 's|"urlclassifier.features.cryptomining.blacklistTables"|"z99.ignore.string"|' \
    -e 's|"urlclassifier.features.emailtracking.blocklistTables"|"z99.ignore.string"|' \
    -e 's|"urlclassifier.features.fingerprinting.blacklistTables"|"z99.ignore.string"|' \
    -e 's|"urlclassifier.features.socialtracking.annotate.blacklistTables"|"z99.ignore.string"|' \
    -e 's|"urlclassifier.malwareTable"|"z99.ignore.string"|' \
    -e 's|"urlclassifier.phishTable"|"z99.ignore.string"|' \
    -e 's|"urlclassifier.trackingTable"|"z99.ignore.string"|' \
    mobile/android/geckoview/src/main/java/org/mozilla/geckoview/ContentBlocking.java

$SED -i \
    -e 's|"apz.allow_double_tap_zooming"|"z99.ignore.boolean"|' \
    -e 's|"browser.display.use_document_fonts"|"z99.ignore.integer"|' \
    -e 's|"docshell.shistory.sameDocumentNavigationOverridesLoadType"|"z99.ignore.boolean"|' \
    -e 's|"docshell.shistory.sameDocumentNavigationOverridesLoadType.forceDisable"|"z99.ignore.string"|' \
    -e 's|"dom.ipc.processCount"|"z99.ignore.integer"|' \
    -e 's|"dom.manifest.enabled"|"z99.ignore.boolean"|' \
    -e 's|"extensions.webapi.enabled"|"z99.ignore.boolean"|' \
    -e 's|"extensions.webextensions.crash.threshold"|"z99.ignore.integer"|' \
    -e 's|"extensions.webextensions.crash.timeframe"|"z99.ignore.long"|' \
    -e 's|"extensions.webextensions.remote"|"z99.ignore.boolean"|' \
    -e 's|"fission.autostart"|"z99.ignore.boolean"|' \
    -e 's|"fission.disableSessionHistoryInParent"|"z99.ignore.boolean"|' \
    -e 's|"fission.webContentIsolationStrategy"|"z99.ignore.integer"|' \
    -e 's|"formhelper.autozoom"|"z99.ignore.boolean"|' \
    -e 's|"javascript.options.mem.gc_parallel_marking"|"z99.ignore.boolean"|' \
    -e 's|"javascript.options.use_fdlibm_for_sin_cos_tan"|"z99.ignore.boolean"|' \
    -e 's|"network.cookie.cookieBehavior.optInPartitioning"|"z99.ignore.boolean"|' \
    -e 's|"network.cookie.cookieBehavior.optInPartitioning.pbmode"|"z99.ignore.boolean"|' \
    -e 's|"network.fetchpriority.enabled"|"z99.ignore.boolean"|' \
    -e 's|"network.http.http3.enable_kyber"|"z99.ignore.boolean"|' \
    -e 's|"network.http.largeKeepaliveFactor"|"z99.ignore.integer"|' \
    -e 's|"network.security.ports.banned"|"z99.ignore.string"|' \
    -e 's|"privacy.baselineFingerprintingProtection"|"z99.ignore.boolean"|' \
    -e 's|"privacy.baselineFingerprintingProtection.overrides"|"z99.ignore.string"|' \
    -e 's|"privacy.fingerprintingProtection"|"z99.ignore.boolean"|' \
    -e 's|"privacy.fingerprintingProtection.overrides"|"z99.ignore.string"|' \
    -e 's|"privacy.fingerprintingProtection.pbmode"|"z99.ignore.boolean"|' \
    -e 's|"privacy.globalprivacycontrol.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.globalprivacycontrol.functionality.enabled"|"z99.ignore.boolean"|' \
    -e 's|"privacy.globalprivacycontrol.pbmode.enabled"|"z99.ignore.boolean"|' \
    -e 's|"security.pki.certificate_transparency.mode"|"z99.ignore.integer"|' \
    -e 's|"security.tls.enable_kyber"|"z99.ignore.boolean"|' \
    -e 's|"webgl.msaa-samples"|"z99.ignore.integer"|' \
    mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntimeSettings.java

# shellcheck disable=SC2154
if [[ -n ${FDROID_BUILD+x} ]]; then
    # Patch the LLVM source code
    # Search clang- in https://android.googlesource.com/platform/ndk/+/refs/tags/ndk-r28b/ndk/toolchains.py
    LLVM_SVN='530567'
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
    echo 'ac_add_options --disable-dtrace'
    echo 'ac_add_options --disable-dump-painting'
    echo 'ac_add_options --disable-execution-tracing'
    echo 'ac_add_options --disable-extensions-webidl-bindings'
    echo 'ac_add_options --disable-ffmpeg'
    echo 'ac_add_options --disable-gecko-profiler'
    echo 'ac_add_options --disable-geckodriver'
    echo 'ac_add_options --disable-gtest-in-build'
    echo 'ac_add_options --disable-instruments'
    echo 'ac_add_options --disable-jitdump'
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
    echo 'ac_add_options --disable-rust-tests'
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
    echo 'ac_add_options --enable-android-subproject="fenix"'
    echo 'ac_add_options --enable-application="mobile/android"'
    echo 'ac_add_options --enable-disk-remnant-avoidance'
    echo 'ac_add_options --enable-geckoview-lite'
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
    echo 'ac_add_options --enable-update-channel="release"'
    echo 'ac_add_options --with-app-basename="IronFox"'
    echo 'ac_add_options --with-app-name="ironfox"'
    echo 'ac_add_options --with-branding="mobile/android/branding/ironfox"'
    echo 'ac_add_options --with-crashreporter-url="data;"'
    echo 'ac_add_options --with-distribution-id="org.ironfoxoss"'
    echo "ac_add_options --with-java-bin-path=\"$JAVA_HOME/bin\""

    if [[ -n "${target}" ]]; then
        echo "ac_add_options --target=$target"
    fi

    echo "ac_add_options --with-android-ndk=\"$ANDROID_NDK\""
    echo "ac_add_options --with-android-sdk=\"$ANDROID_HOME\""
    echo "ac_add_options --with-gradle=$(command -v gradle)"
    echo "ac_add_options --with-libclang-path=\"$libclang\""
    echo "ac_add_options --with-wasi-sysroot=\"$wasi_install/share/wasi-sysroot\""
    echo 'ac_add_options --without-adjust-sdk-keyfile'
    echo 'ac_add_options --without-android-googlevr-sdk'
    echo 'ac_add_options --without-bing-api-keyfile'
    echo 'ac_add_options --without-google-location-service-api-keyfile'
    echo 'ac_add_options --without-mozilla-api-keyfile'
    echo 'ac_add_options --without-leanplum-sdk-keyfile'
    echo 'ac_add_options --without-pocket-api-keyfile'

    if [[ -n ${SB_GAPI_KEY_FILE+x} ]]; then
        echo "ac_add_options --with-google-safebrowsing-api-keyfile=${SB_GAPI_KEY_FILE}"
    fi

    echo "ac_add_options ANDROID_BUNDLETOOL_PATH=\"$BUILDDIR/bundletool.jar\""
    echo "ac_add_options WASM_CC=\"$wasi_install/bin/clang\""
    echo "ac_add_options WASM_CXX=\"$wasi_install/bin/clang++\""
    echo "ac_add_options CC=\"$ANDROID_NDK/toolchains/llvm/prebuilt/$PLATFORM-x86_64/bin/clang\""
    echo "ac_add_options CXX=\"$ANDROID_NDK/toolchains/llvm/prebuilt/$PLATFORM-x86_64/bin/clang++\""
    echo "ac_add_options STRIP=\"$ANDROID_NDK/toolchains/llvm/prebuilt/$PLATFORM-x86_64/bin/llvm-strip\""
    echo 'ac_add_options MOZ_APP_BASENAME="IronFox"'
    echo 'ac_add_options MOZ_APP_DISPLAYNAME="IronFox"'
    echo 'ac_add_options MOZ_APP_NAME="ironfox"'
    echo 'ac_add_options MOZ_APP_REMOTINGNAME="ironfox"'
    echo 'ac_add_options MOZ_ARTIFACT_BUILDS='
    echo 'ac_add_options MOZ_CALLGRIND='
    echo 'ac_add_options MOZ_CRASHREPORTER_URL="data;"'
    echo 'ac_add_options MOZ_DEBUG_FLAGS='
    echo 'ac_add_options MOZ_EXECUTION_TRACING='
    echo 'ac_add_options MOZ_INCLUDE_SOURCE_INFO=1'
    echo 'ac_add_options MOZ_INSTRUMENTS='
    echo 'ac_add_options MOZ_LTO=1'
    echo 'ac_add_options MOZ_PACKAGE_JSSHELL='
    echo 'ac_add_options MOZ_PHC='
    echo 'ac_add_options MOZ_PROFILING='
    echo 'ac_add_options MOZ_REQUIRE_SIGNING='
    echo 'ac_add_options MOZ_RUST_SIMD=1'
    echo 'ac_add_options MOZ_SECURITY_HARDENING=1'
    echo 'ac_add_options MOZ_TELEMETRY_REPORTING='
    echo 'ac_add_options MOZ_VTUNE='
    echo 'ac_add_options MOZILLA_OFFICIAL=1'
    echo 'ac_add_options NODEJS='
    echo 'ac_add_options RUSTC_OPT_LEVEL=2'
    echo 'mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj'
    echo "export ANDROID_BUNDLETOOL_PATH=\"$BUILDDIR/bundletool.jar\""
    echo 'export MOZ_APP_BASENAME="IronFox"'
    echo 'export MOZ_APP_DISPLAYNAME="IronFox"'
    echo 'export MOZ_APP_NAME="ironfox"'
    echo 'export MOZ_APP_REMOTINGNAME="ironfox"'
    echo 'export MOZ_ARTIFACT_BUILDS='
    echo 'export MOZ_CALLGRIND='
    echo 'export MOZ_CRASHREPORTER_URL="data;"'
    echo 'export MOZ_EXECUTION_TRACING='
    echo 'export MOZ_INCLUDE_SOURCE_INFO=1'
    echo 'export MOZ_INSTRUMENTS='
    echo 'export MOZ_LTO=1'
    echo 'export MOZ_PACKAGE_JSSHELL='
    echo 'export MOZ_PGO=1'
    echo 'export MOZ_PHC='
    echo 'export MOZ_PROFILING='
    echo 'export MOZ_REQUIRE_SIGNING='
    echo 'export MOZ_RUST_SIMD=1'
    echo 'export MOZ_SECURITY_HARDENING=1'
    echo 'export MOZ_TELEMETRY_REPORTING='
    echo 'export MOZ_VTUNE='
    echo 'export MOZILLA_OFFICIAL=1'
    echo 'export RUSTC_OPT_LEVEL=2'
} >>mozconfig

# Fail on use of prebuilt binary
$SED -i 's|https://github.com|hxxps://github.com|' python/mozboot/mozboot/android.py

# Make the build system think we installed the emulator and an AVD
mkdir -vp "$ANDROID_HOME/emulator"
mkdir -vp "$HOME/.mozbuild/android-device/avd"

# Do not check the "emulator" utility which is obviously absent in the empty directory we created above
$SED -i -e '/check_android_tools("emulator"/d' build/moz.configure/android-sdk.configure

# Do not define `browser.safebrowsing.features.` prefs by default
## These are unnecessary, add extra confusion and complexity, and don't appear to interact well with our other prefs/settings
$SED -i \
    -e 's|"browser.safebrowsing.features.cryptomining.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.fingerprinting.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.malware.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.phishing.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.trackingAnnotation.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.trackingProtection.update"|"z99.ignore.boolean"|' \
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

# Apply Gecko overlay
apply_overlay "$patches/gecko-overlay/"

popd

# We temporarily need this to unbreak the FIDO library
## https://github.com/microg/GmsCore/issues/3054
pushd "$gmscore"
patch -p1 --no-backup-if-mismatch --quiet < "$patches/microg-unbreak-fido.patch"
popd
