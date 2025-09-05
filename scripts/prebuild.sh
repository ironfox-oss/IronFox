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
rustup target add i686-linux-android
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

# Allow users to sync addresses
sed -i -e 's|SYNC_ADDRESSES_FEATURE = .*|SYNC_ADDRESSES_FEATURE = true|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# Disable crash reporting
sed -i -e '/CRASH_REPORTING/s/true/false/' app/build.gradle
sed -i -e 's|.crashHandler|// .crashHandler|' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt
sed -i -e 's|import mozilla.components.lib.crash|// import mozilla.components.lib.crash|' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt
sed -i -e 's|import mozilla.components.browser.engine.gecko.crash.GeckoCrashPullDelegate|// import mozilla.components.browser.engine.gecko.crash.GeckoCrashPullDelegate|' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt

# Disable telemetry
sed -i -e 's|Telemetry enabled: " + .*)|Telemetry enabled: " + false)|g' app/build.gradle
sed -i -e '/TELEMETRY/s/true/false/' app/build.gradle
sed -i -e 's|META_ATTRIBUTION_ENABLED = .*|META_ATTRIBUTION_ENABLED = false|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt
sed -i -e 's|measurementDataEnabled: Boolean = .*|measurementDataEnabled: Boolean = false,|g' app/src/*/java/org/mozilla/fenix/settings/datachoices/DataChoicesState.kt
sed -i -e 's|studiesEnabled: Boolean = .*|studiesEnabled: Boolean = false,|g' app/src/*/java/org/mozilla/fenix/settings/datachoices/DataChoicesState.kt
sed -i -e 's|telemetryEnabled: Boolean = .*|telemetryEnabled: Boolean = false,|g' app/src/*/java/org/mozilla/fenix/settings/datachoices/DataChoicesState.kt
sed -i -e 's|usagePingEnabled: Boolean = .*|usagePingEnabled: Boolean = false,|g' app/src/*/java/org/mozilla/fenix/settings/datachoices/DataChoicesState.kt

# Display live downloads in progress
sed -i -e 's|showLiveDownloads = .*|showLiveDownloads = true|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# Disable "custom review pre-prompts"
sed -i -e 's|CUSTOM_REVIEW_PROMPT_ENABLED = .*|CUSTOM_REVIEW_PROMPT_ENABLED = false|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# Disable the ability for users to select a custom app icon
## We currently don't add any custom icons to choose from, so no point exposing/cluttering the UI
sed -i -e 's|alternativeAppIconFeatureEnabled = .*|alternativeAppIconFeatureEnabled = false|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# Ensure onboarding is always enabled
sed -i -e 's|onboardingFeatureEnabled = .*|onboardingFeatureEnabled = true|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# Ensure certain preferences are configured at GeckoProvider.kt
## These should be unnecessary (since we take back control of the related Gecko preferences and set them directly), but it doesn't hurt to set these here either
sed -i -e 's/aboutConfigEnabled(.*)/aboutConfigEnabled(true)/' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt # general.aboutConfig.enable
sed -i -e 's/crashPullNeverShowAgain(.*)/crashPullNeverShowAgain(true)/' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt # browser.crashReports.requestedNeverShowAgain
sed -i -e 's/disableShip(.*)/disableShip(false)/' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt # fission.disableSessionHistoryInParent
sed -i -e 's/extensionsWebAPIEnabled(.*)/extensionsWebAPIEnabled(false)/' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt # extensions.webapi.enabled
sed -i -e 's/fissionEnabled(.*)/fissionEnabled(true)/' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt # fission.autostart

# No-op AMO collections/recommendations
sed -i -e 's|"AMO_COLLECTION_NAME", "\\".*\\""|"AMO_COLLECTION_NAME", "\\"\\""|g' app/build.gradle
sed -i 's|Extensions-for-Android||g' app/build.gradle
sed -i -e 's|"AMO_COLLECTION_USER", "\\".*\\""|"AMO_COLLECTION_USER", "\\"\\""|g' app/build.gradle
sed -i -e 's|"AMO_SERVER_URL", "\\".*\\""|"AMO_SERVER_URL", "\\"\\""|g' app/build.gradle
sed -i 's|https://services.addons.mozilla.org||g' app/build.gradle
sed -i -e 's|customExtensionCollectionFeature = .*|customExtensionCollectionFeature = false|g' app/src/*/java/org/mozilla/fenix/FeatureFlags.kt

# No-op Glean
## https://searchfox.org/mozilla-central/rev/31123021/mobile/android/fenix/app/build.gradle#443
echo 'glean.custom.server.url="data;"' >>local.properties
sed -i -e 's|include_client_id: .*|include_client_id: false|g' app/pings.yaml
sed -i -e 's|send_if_empty: .*|send_if_empty: false|g' app/pings.yaml

# No-op Nimbus
sed -i -e 's|.experimentDelegate|// .experimentDelegate|' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt
sed -i -e 's|import mozilla.components.experiment.NimbusExperimentDelegate|// import mozilla.components.experiment.NimbusExperimentDelegate|' app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt

# Remove proprietary/tracking libraries
sed -i 's|- components:lib-crash-sentry|# - components:lib-crash-sentry|g' .buildconfig.yml
sed -i 's|- components:lib-push-firebase|# - components:lib-push-firebase|g' .buildconfig.yml
sed -i 's|implementation libs.thirdparty.sentry|// implementation libs.thirdparty.sentry|g' app/build.gradle
sed -i "s|implementation project(':components:lib-crash-sentry')|// implementation project(':components:lib-crash-sentry')|g" app/build.gradle
sed -i "s|implementation project(':components:lib-push-firebase')|// implementation project(':components:lib-push-firebase')|g" app/build.gradle
sed -i 's|implementation(libs.adjust)|// implementation(libs.adjust)|g' app/build.gradle
sed -i 's|implementation(libs.installreferrer)|// implementation(libs.installreferrer)|g' app/build.gradle
sed -i "s|implementation libs.play.review.ktx|implementation 'org.microg.gms:play-services-tasks:v0.0.0.250932'|g" app/build.gradle
sed -i 's|implementation libs.play|// implementation libs.play|g' app/build.gradle
sed -i -e 's|<uses-permission android:name="com.adjust.preinstall.READ_PERMISSION"/>|<!-- <uses-permission android:name="com.adjust.preinstall.READ_PERMISSION"/> -->|' app/src/*/AndroidManifest.xml

# Remove unused telemetry and marketing services/components
sed -i -e 's|import androidx.core.app.NotificationManagerCompat|// import androidx.core.app.NotificationManagerCompat|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|import mozilla.components.feature.search.middleware.AdsTelemetryMiddleware|// import mozilla.components.feature.search.middleware.AdsTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/components/Core.kt
sed -i -e 's|import mozilla.components.feature.search.telemetry|// import mozilla.components.feature.search.telemetry|' app/src/main/java/org/mozilla/fenix/components/Core.kt
sed -i -e 's|import mozilla.components.support.base.ext.areNotificationsEnabledSafe|// import mozilla.components.support.base.ext.areNotificationsEnabledSafe|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|import mozilla.components.support.base.ext.isNotificationChannelEnabled|// import mozilla.components.support.base.ext.isNotificationChannelEnabled|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|import org.mozilla.fenix.components.metrics|// import org.mozilla.fenix.components.metrics|' app/src/main/java/org/mozilla/fenix/components/Components.kt
sed -i -e 's|import org.mozilla.fenix.components.metrics.fonts|// import org.mozilla.fenix.components.metrics.fonts|' app/src/main/java/org/mozilla/fenix/HomeActivity.kt
sed -i -e 's|import org.mozilla.fenix.components.metrics.GrowthDataWorker|// import org.mozilla.fenix.components.metrics.GrowthDataWorker|' app/src/main/java/org/mozilla/fenix/HomeActivity.kt
sed -i -e 's|import org.mozilla.fenix.components.metrics.MarketingAttributionService|// import org.mozilla.fenix.components.metrics.MarketingAttributionService|' app/src/main/java/org/mozilla/fenix/HomeActivity.kt
sed -i -e 's|import org.mozilla.fenix.onboarding.MARKETING_CHANNEL_ID|// import org.mozilla.fenix.onboarding.MARKETING_CHANNEL_ID|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|import org.mozilla.fenix.onboarding.ReEngagementNotificationWorker|// import org.mozilla.fenix.onboarding.ReEngagementNotificationWorker|' app/src/main/java/org/mozilla/fenix/HomeActivity.kt
sed -i -e 's|import org.mozilla.fenix.perf.ApplicationExitInfoMetrics|// import org.mozilla.fenix.perf.ApplicationExitInfoMetrics|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|import org.mozilla.fenix.perf.StorageStatsMetrics|// import org.mozilla.fenix.perf.StorageStatsMetrics|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|import org.mozilla.fenix.telemetry|// import org.mozilla.fenix.telemetry|' app/src/main/java/org/mozilla/fenix/components/Core.kt

sed -i -e 's|AdsTelemetryMiddleware|// AdsTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/components/Core.kt
sed -i -e 's|ApplicationExitInfoMetrics.|// ApplicationExitInfoMetrics.|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|FontEnumerationWorker.|// FontEnumerationWorker.|' app/src/main/java/org/mozilla/fenix/HomeActivity.kt
sed -i -e 's|GrowthDataWorker.|// GrowthDataWorker.|' app/src/main/java/org/mozilla/fenix/HomeActivity.kt
sed -i -e 's|MarketingAttributionService(|// MarketingAttributionService(|' app/src/main/java/org/mozilla/fenix/HomeActivity.kt
sed -i -e 's|MetricsMiddleware(|// MetricsMiddleware(|' app/src/main/java/org/mozilla/fenix/components/Components.kt
sed -i -e 's|PerfStartup.|// PerfStartup.|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|ReEngagementNotificationWorker.|// ReEngagementNotificationWorker.|' app/src/main/java/org/mozilla/fenix/HomeActivity.kt
sed -i -e 's|StorageStatsMetrics.|// StorageStatsMetrics.|' app/src/main/java/org/mozilla/fenix/FenixApplication.kt
sed -i -e 's|TelemetryMiddleware(context.*)|// TelemetryMiddleware()|' app/src/main/java/org/mozilla/fenix/components/Core.kt

rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/ActivationPing.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/AdjustMetricsService.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/FirstSessionPing.kt
rm -vf app/src/*/java/org/mozilla/fenix/components/metrics/InstallReferrerMetricsService.kt
rm -vrf app/src/*/java/org/mozilla/fenix/telemetry

sed -i -e 's|val push by lazyMonitored { Push(context, analytics.crashReporter) }|val push by lazyMonitored { Push(context) }|' app/src/main/java/org/mozilla/fenix/components/Components.kt

# Let it be IronFox
sed -i \
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
sed -i -e 's/GOOGLE_URL = ".*"/GOOGLE_URL = ""/' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
sed -i -e 's/GOOGLE_US_URL = ".*"/GOOGLE_US_URL = ""/' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
sed -i -e 's/GOOGLE_XX_URL = ".*"/GOOGLE_XX_URL = ""/' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
sed -i -e 's|WHATS_NEW_URL = ".*"|WHATS_NEW_URL = "https://gitlab.com/ironfox-oss/IronFox/-/releases"|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
sed -i 's|https://www.mozilla.org/firefox/android/notes|https://gitlab.com/ironfox-oss/IronFox/-/releases|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt

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

sed -i -e "s/include \".*\"/include $abi/" app/build.gradle
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
echo "rust.targets=linux-x86-64,$rusttarget" >>local.properties

# Apply patches
glean_apply_patches

localize_maven

# Break the dependency on older Rust
sed -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/Cargo.toml
sed -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/build/Cargo.toml
sed -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/rlb/Cargo.toml

# No-op Glean
sed -i -e 's|allowGleanInternal = .*|allowGleanInternal = false|g' glean-core/android/build.gradle
sed -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' glean-core/python/glean/config.py
sed -i -e '/enable_internal_pings:/s/true/false/' glean-core/python/glean/config.py
sed -i -e "s|DEFAULT_GLEAN_ENDPOINT: .*|DEFAULT_GLEAN_ENDPOINT: \&\str = \"\";|g" glean-core/rlb/src/configuration.rs
sed -i -e '/enable_internal_pings:/s/true/false/' glean-core/rlb/src/configuration.rs
sed -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
sed -i -e '/enableInternalPings:/s/true/false/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
sed -i -e '/enableEventTimestamps:/s/true/false/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
sed -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/core_metrics.rs
sed -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/glean_metrics.rs
sed -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/internal_metrics.rs
sed -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/lib_unit_tests.rs
sed -i -e 's|include_client_id: .*|include_client_id: false|g' glean-core/pings.yaml
sed -i -e 's|send_if_empty: .*|send_if_empty: false|g' glean-core/pings.yaml
sed -i -e 's|"$rootDir/glean-core/android/metrics.yaml"|// "$rootDir/glean-core/android/metrics.yaml"|g' glean-core/android/build.gradle
rm -vf glean-core/android/metrics.yaml

# Ensure we're building for release
sed -i -e 's|ext.cargoProfile = .*|ext.cargoProfile = "release"|g' build.gradle

# Use Tor's no-op UniFFi binding generator
sed -i -e "s|commandLine 'cargo', 'uniffi-bindgen'|commandLine '$uniffi/uniffi-bindgen'|g" glean-core/android/build.gradle

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

# Prevent unsolicited favicon fetching
sed -i -e 's|request.copy(resources = request.resources + resource)|request|' components/browser/icons/src/main/java/mozilla/components/browser/icons/preparer/TippyTopIconPreparer.kt

# Remove unwanted Nimbus classes
sed -i -e 's|-keep class mozilla.components.service.nimbus|#-keep class mozilla.components.service.nimbus|' components/service/nimbus/proguard-rules-consumer.pro

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
sed -i -e "/^android-components = \"/c\\android-components = \"${FIREFOX_VERSION}\"" gradle/libs.versions.toml

# Break the dependency on older Rust
sed -i -e "s|channel = .*|channel = \""${RUST_VERSION}\""|g" rust-toolchain.toml

# Disable debug
sed -i -e 's|debug = .*|debug = false|g' Cargo.toml

echo "rust.targets=linux-x86-64,$rusttarget" >>local.properties
sed -i -e '/NDK ez-install/,/^$/d' libs/verify-android-ci-environment.sh
sed -i -e '/content {/,/}/d' build.gradle

localize_maven

# Fix stray
sed -i -e '/^    mavenLocal/{n;d}' tools/nimbus-gradle-plugin/build.gradle
# Fail on use of prebuilt binary
sed -i 's|https://|hxxps://|' tools/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy

# No-op Nimbus (Experimentation)
sed -i -e 's|NimbusInterface.isLocalBuild() = .*|NimbusInterface.isLocalBuild() = true|g' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt
sed -i -e 's|isFetchEnabled(): Boolean = .*|isFetchEnabled(): Boolean = false|g' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt

# Remove the 'search telemetry' config
rm -vf components/remote_settings/dumps/*/search-telemetry-v2.json
sed -i -e 's|("main", "search-telemetry-v2"),|// ("main", "search-telemetry-v2"),|g' components/remote_settings/src/client.rs

# Apply Application Services overlay
apply_overlay "$patches/a-s-overlay/"

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

# Gecko
pushd "$mozilla_release"

# Let it be IronFox (part 2...)
mkdir -vp mobile/android/branding/ironfox/content
mkdir -vp mobile/android/branding/ironfox/locales/en-US
sed -i -e 's/Fennec/IronFox/; s/Firefox/IronFox/g' build/moz.configure/init.configure
sed -i -e 's|"MOZ_APP_VENDOR", ".*"|"MOZ_APP_VENDOR", "IronFox OSS"|g' mobile/android/moz.configure
echo '' >>mobile/android/moz.configure
echo 'include("ironfox.configure")' >>mobile/android/moz.configure

# Apply patches
apply_patches

# Ensure we're building for release
sed -i -e 's/variant=variant(.*)/variant=variant("release")/' mobile/android/gradle.configure

# Fix v125 aar output not including native libraries
sed -i \
    -e "s/singleVariant('debug')/singleVariant('release')/" \
    mobile/android/geckoview/build.gradle

# Hack the timeout for
# geckoview:generateJNIWrappersForGeneratedWithGeckoBinariesDebug
sed -i \
    -e 's/max_wait_seconds=600/max_wait_seconds=1800/' \
    mobile/android/gradle.py

# Break the dependency on older Rust
sed -i -e "s|rust-version = .*|rust-version = \""${RUST_VERSION}\""|g" Cargo.toml
sed -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" intl/icu_capi/Cargo.toml
sed -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" intl/icu_segmenter_data/Cargo.toml

# Disable debug
sed -i -e 's|debug-assertions = .*|debug-assertions = false|g' Cargo.toml
sed -i -e 's|debug = .*|debug = false|g' gfx/harfbuzz/src/rust/Cargo.toml

# Unbreak builds with --disable-pref-extensions
sed -i -e 's|@BINPATH@/defaults/autoconfig/prefcalls.js|;@BINPATH@/defaults/autoconfig/prefcalls.js|g' mobile/android/installer/package-manifest.in

# Disable network connectivity status monitoring (Fenix)
## (Also removes the `NETWORK_ACCESS_STATE` permission)
## Also see `fenix-disable-network-connectivity-monitoring.patch`
sed -i -e 's|AUTOPLAY_ALLOW_ON_WIFI ->|// AUTOPLAY_ALLOW_ON_WIFI ->|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/settings/PhoneFeature.kt
sed -i -e 's|import org.mozilla.fenix.settings.sitepermissions.AUTOPLAY_ALLOW_ON_WIFI|// import org.mozilla.fenix.settings.sitepermissions.AUTOPLAY_ALLOW_ON_WIFI|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/settings/PhoneFeature.kt
sed -i -e 's|<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />|<!-- <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" /> -->|' mobile/android/fenix/app/src/main/AndroidManifest.xml

# Disable network connectivity status monitoring (GeckoView)
## (Also removes the `NETWORK_ACCESS_STATE` permission)
sed -i -e 's|import org.mozilla.gecko.GeckoNetworkManager|// import org.mozilla.gecko.GeckoNetworkManager|' mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntime.java
sed -i -e 's|GeckoNetworkManager.|// GeckoNetworkManager.|' mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntime.java
sed -i -e 's|<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>|<!-- <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" /> -->|' mobile/android/geckoview/src/main/AndroidManifest.xml

# Disable Normandy (Experimentation)
sed -i -e 's|"MOZ_NORMANDY", .*)|"MOZ_NORMANDY", False)|g' mobile/android/moz.configure

# Disable shipped domains
## (Firefox's built-in list of domains used to autocomplete URLs)
## To quote a Mozilla employee (https://bugzilla.mozilla.org/show_bug.cgi?id=1842106#c0): 'Android's current list of 400+ domain names for address bar suggestions was created way back in December 2015... This list hasn't been updated since 2015 and now includes expired and squatted domains that might serve ads or malware'
## Prevents suggesting squatted domains to users that serve ads and malware, and reduces annoyances/unwanted behavior.
sed -i -e 's|FxNimbus.features.suggestShippedDomains.value().enabled|false|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt

# Disable SSLKEYLOGGING
## https://bugzilla.mozilla.org/show_bug.cgi?id=1183318
## https://bugzilla.mozilla.org/show_bug.cgi?id=1915224
sed -i -e 's|NSS_ALLOW_SSLKEYLOGFILE ?= .*|NSS_ALLOW_SSLKEYLOGFILE ?= 0|g' security/nss/lib/ssl/Makefile
echo '' >>security/moz.build
echo 'gyp_vars["enable_sslkeylogfile"] = 0' >>security/moz.build

# Disable telemetry
sed -i -e 's|"MOZ_SERVICES_HEALTHREPORT", .*)|"MOZ_SERVICES_HEALTHREPORT", False)|g' mobile/android/moz.configure

# Ensure UA is always set to Firefox
sed -i -e 's|"MOZ_APP_UA_NAME", ".*"|"MOZ_APP_UA_NAME", "Firefox"|g' mobile/android/moz.configure

# Enable encrypted storage (via Android's Keystore system: https://developer.android.com/privacy-and-security/keystore) for Firefox account state
sed -i -e 's|secureStateAtRest: Boolean = .*|secureStateAtRest: Boolean = true,|g' mobile/android/android-components/components/concept/sync/src/*/java/mozilla/components/concept/sync/Devices.kt
sed -i -e 's|secureStateAtRest = .*|secureStateAtRest = true,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt

# Hide Remote Debugging UI setting
## Also see `fenix-reset-remote-debugging-per-session.patch`
sed -i -e 's|preferenceRemoteDebugging?.isVisible = .*|preferenceRemoteDebugging?.isVisible = false|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/settings/SettingsFragment.kt

# Include additional Remote Settings local dumps (+ add our own...)
sed -i -e 's|"mobile/"|"0"|g' services/settings/dumps/blocklists/moz.build
sed -i -e 's|"mobile/"|"0"|g' services/settings/dumps/security-state/moz.build
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

# Increase add-on update frequency
## Increases the rate at which Firefox checks for add-on updates, from every 12 hours to hourly
sed -i -e 's|DefaultAddonUpdater(context, Frequency(.*, TimeUnit|DefaultAddonUpdater(context, Frequency(1, TimeUnit|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Components.kt

# No-op AMO collections/recommendations
sed -i -e 's/DEFAULT_COLLECTION_NAME = ".*"/DEFAULT_COLLECTION_NAME = ""/' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
sed -i 's|7e8d6dc651b54ab385fb8791bf9dac||g' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
sed -i -e 's/DEFAULT_COLLECTION_USER = ".*"/DEFAULT_COLLECTION_USER = ""/' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
sed -i -e 's/DEFAULT_SERVER_URL = ".*"/DEFAULT_SERVER_URL = ""/' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
sed -i 's|https://services.addons.mozilla.org||g' mobile/android/android-components/components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt

# No-op Contile
sed -i -e 's/CONTILE_ENDPOINT_URL = ".*"/CONTILE_ENDPOINT_URL = ""/' mobile/android/android-components/components/service/mars/src/*/java/mozilla/components/service/mars/contile/ContileTopSitesProvider.kt

# No-op crash reporting
sed -i -e 's|import org.mozilla.gecko.crashhelper.CrashHelper|// import org.mozilla.gecko.crashhelper.CrashHelper|' mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntime.java

sed -i -e 's|enabled: Boolean = .*|enabled: Boolean = false,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
sed -i -e 's|sendCaughtExceptions: Boolean = .*|sendCaughtExceptions: Boolean = false,|g' mobile/android/android-components/components/lib/crash-sentry/src/*/java/mozilla/components/lib/crash/sentry/SentryService.kt
sed -i -e 's|shouldPrompt: Prompt = .*|shouldPrompt: Prompt = Prompt.ALWAYS,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
sed -i -e 's|useLegacyReporting: Boolean = .*|useLegacyReporting: Boolean = false,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
sed -i -e 's|var enabled: Boolean = false,|var enabled: Boolean = enabled|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt

sed -i 's|crash-reports-ondemand||g' toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs
sed -i -e 's/REMOTE_SETTINGS_CRASH_COLLECTION = ".*"/REMOTE_SETTINGS_CRASH_COLLECTION = ""/' toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs

# No-op MARS
sed -i -e 's/MARS_ENDPOINT_BASE_URL = ".*"/MARS_ENDPOINT_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt
sed -i -e 's/MARS_ENDPOINT_URL = ".*"/MARS_ENDPOINT_URL = ""/' mobile/android/android-components/components/service/mars/src/*/java/mozilla/components/service/mars/MarsTopSitesProvider.kt
sed -i -e 's/MARS_ENDPOINT_STAGING_BASE_URL = ".*"/MARS_ENDPOINT_STAGING_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt

# No-op GeoIP/Region service
## https://searchfox.org/mozilla-release/source/toolkit/modules/docs/Region.rst
sed -i -e 's/GEOIP_SERVICE_URL = ".*"/GEOIP_SERVICE_URL = ""/' mobile/android/android-components/components/service/location/src/*/java/mozilla/components/service/location/MozillaLocationService.kt
sed -i -e 's/USER_AGENT = ".*/USER_AGENT = ""/' mobile/android/android-components/components/service/location/src/*/java/mozilla/components/service/location/MozillaLocationService.kt

# No-op Normandy (Experimentation)
sed -i -e 's/REMOTE_SETTINGS_COLLECTION = ".*"/REMOTE_SETTINGS_COLLECTION = ""/' toolkit/components/normandy/lib/RecipeRunner.sys.mjs
sed -i 's|normandy-recipes-capabilities||g' toolkit/components/normandy/lib/RecipeRunner.sys.mjs

# No-op Pocket
sed -i -e 's/SPOCS_ENDPOINT_DEV_BASE_URL = ".*"/SPOCS_ENDPOINT_DEV_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt
sed -i -e 's/SPOCS_ENDPOINT_PROD_BASE_URL = ".*"/SPOCS_ENDPOINT_PROD_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt
sed -i -e 's/POCKET_ENDPOINT_URL = ".*"/POCKET_ENDPOINT_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/stories/api/PocketEndpointRaw.kt

# No-op search telemetry
sed -i 's|search-telemetry-v2||g' mobile/android/fenix/app/src/*/java/org/mozilla/fenix/components/Core.kt

# No-op telemetry (Gecko)
sed -i -e '/enable_internal_pings:/s/true/false/' toolkit/components/glean/src/init/mod.rs
sed -i -e '/upload_enabled =/s/true/false/' toolkit/components/glean/src/init/mod.rs
sed -i -e '/use_core_mps:/s/true/false/' toolkit/components/glean/src/init/mod.rs
sed -i 's|localhost||g' toolkit/components/telemetry/pings/BackgroundTask_pingsender.sys.mjs
sed -i 's|localhost||g' toolkit/components/telemetry/pingsender/pingsender.cpp
sed -i -e 's/usageDeletionRequest.setEnabled(.*)/usageDeletionRequest.setEnabled(false)/' toolkit/components/telemetry/app/UsageReporting.sys.mjs
sed -i -e 's|useTelemetry = .*|useTelemetry = false;|g' toolkit/components/telemetry/core/Telemetry.cpp
sed -i '/# This must remain last./i gkrust_features += ["glean_disable_upload"]\n' toolkit/library/rust/gkrust-features.mozbuild

sed -i -e 's|include_client_id: .*|include_client_id: false|g' toolkit/components/glean/pings.yaml
sed -i -e 's|send_if_empty: .*|send_if_empty: false|g' toolkit/components/glean/pings.yaml
sed -i -e 's|include_client_id: .*|include_client_id: false|g' toolkit/components/nimbus/pings.yaml
sed -i -e 's|send_if_empty: .*|send_if_empty: false|g' toolkit/components/nimbus/pings.yaml

# No-op telemetry (GeckoView)
sed -i -e 's|allowMetricsFromAAR = .*|allowMetricsFromAAR = false|g' mobile/android/android-components/components/browser/engine-gecko/build.gradle

## Do not prompt users to enable telemetry/studies when enrolling in experiments
### Currently unused
sed -i -e 's|notifyUserToEnableExperiments()|// notifyUserToEnableExperiments()|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/nimbus/controller/NimbusBranchesController.kt

# Prevent DoH canary requests
sed -i -e 's/GLOBAL_CANARY = ".*"/GLOBAL_CANARY = ""/' toolkit/components/doh/DoHHeuristics.sys.mjs
sed -i -e 's/ZSCALER_CANARY = ".*"/ZSCALER_CANARY = ""/' toolkit/components/doh/DoHHeuristics.sys.mjs

# Remove `about:telemetry`
## Also see `gecko-remove-abouttelemetry.patch`
sed -i -e "s|'telemetry'|# &|" docshell/build/components.conf
sed -i -e 's|content/global/aboutTelemetry|# content/global/aboutTelemetry|' toolkit/content/jar.mn

# Remove unused crash reporting services/components
rm -vf mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/MinidumpAnalyzer.kt
rm -vf mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/MozillaSocorroService.kt

# Remove GMP sources
## Removes Firefox's default sources for installing Gecko Media Plugins (GMP), such as OpenH264 and Widevine (the latter is proprietary).
## https://wiki.mozilla.org/GeckoMediaPlugins
sed -i -e 's|content/global/gmp-sources|# content/global/gmp-sources|' toolkit/content/jar.mn

# Remove example dependencies
## Also see `gecko-remove-example-dependencies.patch`
sed -i "s|include ':annotations', .*|include ':annotations'|g" settings.gradle
sed -i "s|project(':messaging_example'|// project(':messaging_example'|g" settings.gradle
sed -i "s|project(':port_messaging_example'|// project(':port_messaging_example'|g" settings.gradle
sed -i -e 's#if (rootDir.toString().contains("android-components") || !project.key.startsWith("samples"))#if (!project.key.startsWith("samples"))#' mobile/android/shared-settings.gradle

# Remove ExoPlayer
sed -i "s|include ':exoplayer2'|// include ':exoplayer2'|g" settings.gradle
sed -i "s|project(':exoplayer2'|// project(':exoplayer2'|g" settings.gradle

# Remove unused/unnecessary DebugConfig class
sed -i -e 's|-keep class org.mozilla.gecko.util.DebugConfig|#-keep class org.mozilla.gecko.util.DebugConfig|' mobile/android/fenix/app/proguard-rules.pro

# Remove proprietary/tracking libraries
sed -i 's|adjust|# adjust|g' gradle/libs.versions.toml
sed -i 's|firebase-messaging|# firebase-messaging|g' gradle/libs.versions.toml
sed -i 's|installreferrer|# installreferrer|g' gradle/libs.versions.toml
sed -i 's|play-review|# play-review|g' gradle/libs.versions.toml
sed -i 's|play-services|# play-services|g' gradle/libs.versions.toml
sed -i 's|thirdparty-sentry|# thirdparty-sentry|g' gradle/libs.versions.toml
sed -i 's|sentry|# sentry|g' gradle/libs.versions.toml

sed -i 's|-include "adjust-keeps.cfg"|# -include "adjust-keeps.cfg"|g' mobile/android/config/proguard/proguard.cfg
sed -i 's|-include "play-services-keeps.cfg"|# -include "play-services-keeps.cfg"|g' mobile/android/config/proguard/proguard.cfg
sed -i 's|-include "proguard-leanplum.cfg"|# -include "proguard-leanplum.cfg"|g' mobile/android/config/proguard/proguard.cfg
rm -vf mobile/android/config/proguard/adjust-keeps.cfg
rm -vf mobile/android/config/proguard/play-services-keeps.cfg
rm -vf mobile/android/config/proguard/proguard-leanplum.cfg

# Remove Web Compatibility Reporter
## Also see `fenix-remove-webcompat-reporter.patch`
sed -i 's|- components:feature-webcompat-reporter|# - components:feature-webcompat-reporter|g' mobile/android/fenix/.buildconfig.yml
sed -i "s|implementation project(':components:feature-webcompat-reporter')|// implementation project(':components:feature-webcompat-reporter')|g" mobile/android/fenix/app/build.gradle

sed -i -e 's|import mozilla.components.feature.webcompat.reporter|// import mozilla.components.feature.webcompat.reporter|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/FenixApplication.kt

sed -i -e 's|FxNimbus.features.menuRedesign.value().reportSiteIssue|false|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/menu/MenuDialogFragment.kt
sed -i -e 's|return !isAboutUrl && !isContentUrl|return false|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/toolbar/DefaultToolbarMenu.kt
sed -i -e 's|WebCompatReporterFeature.|// WebCompatReporterFeature.|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/FenixApplication.kt

# Replace Google Play FIDO with microG
sed -i 's|libs.play.services.fido|"org.microg.gms:play-services-fido:v0.0.0.250932"|g' mobile/android/geckoview/build.gradle

# Unbreak our custom uBlock Origin config
## Also see `gecko-custom-ublock-origin-assets.patch`
sed -i -e 's#else if (platform == "macosx" || platform == "linux")#else if (platform == "macosx" || platform == "linux" || platform == "android")#' toolkit/components/extensions/NativeManifests.sys.mjs

# Remove Glean
source "$rootdir/scripts/deglean.sh"

# Nuke undesired Mozilla endpoints
source "$rootdir/scripts/noop_mozilla_endpoints.sh"

# Ensure certain settings are configured at Fenix Core.kt
## These should be unnecessary (since we generally either configure them with UI settings or take back control of the related Gecko preferences from GeckoProvider.kt and set them directly), but it doesn't hurt to set these here either
## For reference, none of these are exposed in the UI
sed -i -e 's|certificateTransparencyMode = .*|certificateTransparencyMode = 2,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # security.pki.certificate_transparency.mode
sed -i -e 's|dohAutoselectEnabled = .*|dohAutoselectEnabled = false,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # network.android_doh.autoselect_enabled
sed -i -e 's|emailTrackerBlockingPrivateBrowsing = .*|emailTrackerBlockingPrivateBrowsing = true,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # privacy.trackingprotection.emailtracking.pbmode.enabled
sed -i -e 's|fdlibmMathEnabled = .*|fdlibmMathEnabled = true,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # javascript.options.use_fdlibm_for_sin_cos_tan
sed -i -e 's|fetchPriorityEnabled = .*|fetchPriorityEnabled = true,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # network.fetchpriority.enabled
sed -i -e 's|globalPrivacyControlEnabled = .*|globalPrivacyControlEnabled = true,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # privacy.globalprivacycontrol.enabled
sed -i -e 's|parallelMarkingEnabled = .*|parallelMarkingEnabled = true,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # javascript.options.mem.gc_parallel_marking
sed -i -e 's|postQuantumKeyExchangeEnabled = .*|postQuantumKeyExchangeEnabled = true,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # network.http.http3.enable_kyber + security.tls.enable_kyber
sed -i -e 's|userCharacteristicPingCurrentVersion = .*|userCharacteristicPingCurrentVersion = 0,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # toolkit.telemetry.user_characteristics_ping.current_version
sed -i -e 's|webContentIsolationStrategy = WebContentIsolationStrategy..*|webContentIsolationStrategy = WebContentIsolationStrategy.ISOLATE_EVERYTHING,|g' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/Core.kt # fission.webContentIsolationStrategy

# Take back control of preferences
## This prevents GeckoView from overriding the follow prefs at runtime, which also means we don't have to worry about Nimbus overriding them, etc...
## The prefs will instead take the values we specify in the phoenix/ironfox .js files, and users will also be able to override them via the `about:config`
## This is ideal for features that aren't exposed by the UI, it gives more freedom/control back to users, and it's great to ensure things are always configured how we want them...
sed -i \
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

sed -i \
    -e 's|"apz.allow_double_tap_zooming"|"z99.ignore.boolean"|' \
    -e 's|"browser.crashReports.requestedNeverShowAgain"|"z99.ignore.boolean"|' \
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
    -e 's|"general.aboutConfig.enable"|"z99.ignore.boolean"|' \
    -e 's|"javascript.options.mem.gc_parallel_marking"|"z99.ignore.boolean"|' \
    -e 's|"javascript.options.use_fdlibm_for_sin_cos_tan"|"z99.ignore.boolean"|' \
    -e 's|"network.cookie.cookieBehavior.optInPartitioning"|"z99.ignore.boolean"|' \
    -e 's|"network.cookie.cookieBehavior.optInPartitioning.pbmode"|"z99.ignore.boolean"|' \
    -e 's|"network.android_doh.autoselect_enabled"|"z99.ignore.boolean"|' \
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
    -e 's|"toolkit.telemetry.user_characteristics_ping.current_version"|"z99.ignore.integer"|' \
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
    echo "ac_add_options CC=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang\""
    echo "ac_add_options CXX=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++\""
    echo "ac_add_options STRIP=\"$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip\""
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
sed -i 's|https://github.com|hxxps://github.com|' python/mozboot/mozboot/android.py

# Make the build system think we installed the emulator and an AVD
mkdir -vp "$ANDROID_HOME/emulator"
mkdir -vp "$HOME/.mozbuild/android-device/avd"

# Do not check the "emulator" utility which is obviously absent in the empty directory we created above
sed -i -e '/check_android_tools("emulator"/d' build/moz.configure/android-sdk.configure

# Do not define `browser.safebrowsing.features.` prefs by default
## These are unnecessary, add extra confusion and complexity, and don't appear to interact well with our other prefs/settings
sed -i \
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
