#!/bin/bash
#
#    IronFox build scripts
#    Copyright (C) 2024-2025  Akash Yadav, celenity
#
#    Originally based on: Fennec (Mull) build scripts
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

source "$(dirname $0)/env_local.sh"

# Include version info
source "${rootdir}/scripts/versions.sh"

# If variables are defined with a custom `env_override.sh`, let's use those
if [[ -f "${rootdir}/env_override.sh" ]]; then
    source "${rootdir}/env_override.sh"
fi

function localize_maven {
    # Replace custom Maven repositories with mavenLocal()
    find ./* -name '*.gradle' -type f -exec python3 "${rootdir}/scripts/localize_maven.py" {} \;
    # Make gradlew scripts call our Gradle wrapper
    find ./* -name gradlew -type f | while read -r gradlew; do
        echo -e "#!/bin/sh\n${gradle} \""'$@'"\"" >"${gradlew}"
        chmod 755 "${gradlew}"
    done
}

# Applies the overlay files in the given directory
# to the current directory
function apply_overlay() {
    source_dir="$1"
    find "${source_dir}" -type f| while read -r src; do
        target="${src#"${source_dir}"}"
        mkdir -vp "$(dirname "${target}")"
        cp -vrf "${src}" "${target}"
    done
}

if [ -z "$1" ]; then
    echo "Usage: $0 arm|arm64|x86_64|bundle" >&1
    exit 1
fi

if [[ -n ${FDROID_BUILD+x} ]]; then
    source "$(dirname "$0")/env_fdroid.sh"
fi

if [ ! -d "${IRONFOX_ANDROID_SDK}" ]; then
    echo "\$IRONFOX_ANDROID_SDK($IRONFOX_ANDROID_SDK) does not exist."
    exit 1
fi

if [ ! -d "${IRONFOX_ANDROID_NDK}" ]; then
    echo "\$IRONFOX_ANDROID_NDK($IRONFOX_ANDROID_NDK) does not exist."
    exit 1
fi

JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{sub("^$", "0", $2); print $1$2}')
[ "${JAVA_VER}" -ge 15 ] || {
    echo "Java 17 or newer must be set as default JDK"
    exit 1
}

if [[ -z "${FIREFOX_VERSION}" ]]; then
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

if [[ -z "${IRONFOX_UBO_ASSETS_URL}" ]]; then
    echo "\$IRONFOX_UBO_ASSETS_URL is not set! Aborting..."
    exit 1
fi

if [[ -z "${NO_PREBUILDS}" ]]; then
    # Do not use prebuilds by default
    NO_PREBUILDS=0
fi

# Create build directories
mkdir -vp "${IRONFOX_CARGO_HOME}"
mkdir -vp "${IRONFOX_GLEAN_PIP_ENV}/bootstrap-24.3.0-0"
mkdir -vp "${IRONFOX_GRADLE_CACHE}"
mkdir -vp "${IRONFOX_GRADLE_HOME}"
mkdir -vp "${IRONFOX_MOZBUILD}"
mkdir -vp "${IRONFOX_OUTPUTS}"
mkdir -vp "${builddir}/tmp/fenix"
mkdir -vp "${builddir}/tmp/glean"

## Copy machrc
cp -vf "${patches}/machrc" "${IRONFOX_MOZBUILD}/machrc"

## Copy Rust (cargo) config
cp -vf "${patches}/cargo/config.toml" "${IRONFOX_CARGO_HOME}/config.toml"

# Check patch files
source "${rootdir}/scripts/patches.sh"

pushd "${IRONFOX_AS}"
if ! a-s_check_patches; then
    echo "Patch validation failed. Please check the patch files and try again."
    exit 1
fi
popd

pushd "${IRONFOX_GLEAN}"
if ! glean_check_patches; then
    echo "Patch validation failed. Please check the patch files and try again."
    exit 1
fi
popd

pushd "${IRONFOX_GECKO}"
if ! check_patches; then
    echo "Patch validation failed. Please check the patch files and try again."
    exit 1
fi

# For UnifiedPush-AC
if ! up_ac_check_patches; then
    echo "Patch validation failed. Please check the patch files and try again."
    exit 1
fi
popd

# Set-up Rust
curl ${IRONFOX_CURL_FLAGS} -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --no-update-default-toolchain --profile=minimal

# Set-up cargo
source "${IRONFOX_CARGO_HOME}/env"
rustup set profile minimal
rustup default "${RUST_VERSION}"
rustup target add thumbv7neon-linux-androideabi
rustup target add armv7-linux-androideabi
rustup target add aarch64-linux-android
rustup target add i686-linux-android
rustup target add x86_64-linux-android
cargo install --force --vers "${CBINDGEN_VERSION}" cbindgen

# Set-up pip
python3.9 -m venv "${IRONFOX_PIP_ENV}"

## Set symlinks so that Glean will use our Pip environment, instead of attempting to create its own...
if [[ ! -d "${IRONFOX_GLEAN_PIP_ENV}/pythonenv" ]]; then
    ln -s "${IRONFOX_PIP_ENV}" "${IRONFOX_GLEAN_PIP_ENV}/pythonenv"
fi

if [[ ! -d "${IRONFOX_GLEAN_PIP_ENV}/bootstrap-24.3.0-0/Miniconda3" ]]; then
    ln -s "${IRONFOX_PIP_ENV}" "${IRONFOX_GLEAN_PIP_ENV}/bootstrap-24.3.0-0/Miniconda3"
fi

source "${IRONFOX_PIP_ENV}/bin/activate"
pip install --upgrade pip
pip install glean-parser

if [[ "${IRONFOX_PLATFORM}" == "darwin" ]]; then
    pip install gyp-next
fi

#
# Fenix
#
pushd "${IRONFOX_FENIX}"

# Set up the app ID, version name and version code

"${IRONFOX_SED}" -i \
    -e 's|applicationId "org.mozilla"|applicationId "org.ironfoxoss"|' \
    -e 's|"sharedUserId": "org.mozilla.firefox.sharedID"|"sharedUserId": "org.ironfoxoss.ironfox.sharedID"|' \
    -e "s/Config.releaseVersionName(project)/'${IRONFOX_VERSION}'/" \
    app/build.gradle

# Disable crash reporting
"${IRONFOX_SED}" -i -e '/CRASH_REPORTING/s/true/false/' app/build.gradle

# Disable the Mozilla Ads Client
"${IRONFOX_SED}" -i -e 's|MOZILLA_ADS_CLIENT_ENABLED = .*|MOZILLA_ADS_CLIENT_ENABLED = false|g' app/src/main/java/org/mozilla/fenix/FeatureFlags.kt

# Disable Pocket "Discover More Stories"
"${IRONFOX_SED}" -i -e 's|DISCOVER_MORE_STORIES = .*|DISCOVER_MORE_STORIES = false|g' app/src/main/java/org/mozilla/fenix/FeatureFlags.kt

# Disable telemetry
"${IRONFOX_SED}" -i -e 's|Telemetry enabled: " + .*)|Telemetry enabled: " + false)|g' app/build.gradle
"${IRONFOX_SED}" -i -e '/TELEMETRY/s/true/false/' app/build.gradle
"${IRONFOX_SED}" -i -e 's|META_ATTRIBUTION_ENABLED = .*|META_ATTRIBUTION_ENABLED = false|g' app/src/main/java/org/mozilla/fenix/FeatureFlags.kt

# Ensure onboarding is always enabled
"${IRONFOX_SED}" -i -e 's|onboardingFeatureEnabled = .*|onboardingFeatureEnabled = true|g' app/src/main/java/org/mozilla/fenix/FeatureFlags.kt

# No-op AMO collections/recommendations
"${IRONFOX_SED}" -i -e 's|"AMO_COLLECTION_NAME", "\\".*\\""|"AMO_COLLECTION_NAME", "\\"\\""|g' app/build.gradle
"${IRONFOX_SED}" -i 's|Extensions-for-Android||g' app/build.gradle
"${IRONFOX_SED}" -i -e 's|"AMO_COLLECTION_USER", "\\".*\\""|"AMO_COLLECTION_USER", "\\"\\""|g' app/build.gradle
"${IRONFOX_SED}" -i -e 's|"AMO_SERVER_URL", "\\".*\\""|"AMO_SERVER_URL", "\\"\\""|g' app/build.gradle
"${IRONFOX_SED}" -i -e 's|customExtensionCollectionFeature = .*|customExtensionCollectionFeature = false|g' app/src/main/java/org/mozilla/fenix/FeatureFlags.kt

# No-op Glean
"${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' app/pings.yaml
"${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' app/pings.yaml

# Remove unused telemetry and marketing services/components
"${IRONFOX_SED}" -i -e 's|import mozilla.appservices.syncmanager.SyncTelemetry|// import mozilla.appservices.syncmanager.SyncTelemetry|' app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.downloads.listscreen.middleware.DownloadTelemetryMiddleware|// import org.mozilla.fenix.downloads.listscreen.middleware.DownloadTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.components.toolbar.BrowserToolbarTelemetryMiddleware|// import org.mozilla.fenix.components.toolbar.BrowserToolbarTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.home.toolbar.BrowserToolbarTelemetryMiddleware|// import org.mozilla.fenix.home.toolbar.BrowserToolbarTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.tabstray.TabsTrayTelemetryMiddleware|// import org.mozilla.fenix.tabstray.TabsTrayTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.webcompat.middleware.WebCompatReporterTelemetryMiddleware|// import org.mozilla.fenix.webcompat.middleware.WebCompatReporterTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt

"${IRONFOX_SED}" -i -e 's|BookmarksTelemetryMiddleware(|// BookmarksTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/bookmarks/BookmarkFragment.kt
"${IRONFOX_SED}" -i -e 's|BrowserToolbarTelemetryMiddleware(|// BrowserToolbarTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt
"${IRONFOX_SED}" -i -e 's|BrowserToolbarTelemetryMiddleware(|// BrowserToolbarTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt
"${IRONFOX_SED}" -i -e 's|CustomReviewPromptTelemetryMiddleware(|// CustomReviewPromptTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptBottomSheetFragment.kt
"${IRONFOX_SED}" -i -e 's|private fun provideTelemetryMiddleware|// private fun provideTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt
"${IRONFOX_SED}" -i -e 's|private fun provideTelemetryMiddleware|// private fun provideTelemetryMiddleware|' app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt
"${IRONFOX_SED}" -i -e 's|provideTelemetryMiddleware(|// provideTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt
"${IRONFOX_SED}" -i -e 's|provideTelemetryMiddleware(|// provideTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt
"${IRONFOX_SED}" -i -e 's|SyncTelemetry.|// SyncTelemetry.|' app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt
"${IRONFOX_SED}" -i -e 's|TabsTrayTelemetryMiddleware(|// TabsTrayTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/tabstray/TabsTrayFragment.kt
"${IRONFOX_SED}" -i -e 's|TabsTrayTelemetryMiddleware(|// TabsTrayTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt
"${IRONFOX_SED}" -i -e 's|WebCompatReporterTelemetryMiddleware(|// WebCompatReporterTelemetryMiddleware(|' app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt

rm -vf app/src/main/java/org/mozilla/fenix/bookmarks/BookmarksTelemetryMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/ActivationPing.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/AdjustMetricsService.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/BreadcrumbsRecorder.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/Event.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/FirstSessionPing.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/GrowthDataWorker.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/InstallReferrerMetricsService.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/MarketingAttributionService.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/MetricController.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/MetricsMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/MetricsService.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/MetricsStorage.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/metrics/MozillaProductDetector.kt
rm -vf app/src/main/java/org/mozilla/fenix/components/toolbar/BrowserToolbarTelemetryMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/crashes/CrashFactCollector.kt
rm -vf app/src/main/java/org/mozilla/fenix/crashes/CrashReportingAppMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/crashes/NimbusExperimentDataProvider.kt
rm -vf app/src/main/java/org/mozilla/fenix/crashes/ReleaseRuntimeTagProvider.kt
rm -vf app/src/main/java/org/mozilla/fenix/downloads/listscreen/middleware/DownloadTelemetryMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/home/middleware/HomeTelemetryMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/home/PocketMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/home/toolbar/BrowserToolbarTelemetryMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/messaging/state/MessagingMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptTelemetryMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/reviewprompt/ReviewPromptMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/tabstray/TabsTrayTelemetryMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/telemetry/TelemetryMiddleware.kt
rm -vf app/src/main/java/org/mozilla/fenix/webcompat/middleware/WebCompatReporterTelemetryMiddleware.kt
rm -vrf app/src/main/java/org/mozilla/fenix/components/metrics/fonts
rm -vrf app/src/main/java/org/mozilla/fenix/settings/datachoices
rm -vrf app/src/main/java/org/mozilla/fenix/startupCrash

# Let it be IronFox
"${IRONFOX_SED}" -i \
    -e 's/Address bar - Firefox Suggest/Address bar/' \
    -e 's/Agree and continue/Continue/' \
    -e 's/Fast and secure web browsing/The private, secure, user first web browser for Android./' \
    -e 's/Google Search/Google search/' \
    -e 's/Learn more about Firefox Suggest/Learn more about search suggestions/' \
    -e 's/Notifications help you stay safer with Firefox/Enable notifications/' \
    -e 's/Notifications for tabs received from other Firefox devices/Notifications for tabs received from other devices/' \
    -e 's/Securely send tabs between your devices and discover other privacy features in Firefox/IronFox can remind you when private tabs are open and show you the progress of file downloads/' \
    -e 's/Suggestions from %1$s/Suggestions from Mozilla/' \
    -e 's/Use your default DNS resolver if there is a problem with the secure DNS provider/Use your default DNS resolver/' \
    -e 's/You control when to use secure DNS and choose your provider/IronFox will use secure DNS with your chosen provider by default, but might fallback to your system’s DNS resolver if secure DNS is unavailable/' \
    -e 's/You don’t have any tabs open in Firefox on your other devices/You don’t have any tabs open on your other devices/' \
    -e '/about_content/s/Mozilla/IronFox OSS/' \
    -e '/preference_doh_off_summary/s/Use your default DNS resolver/Never use secure DNS, even if supported by your system’s DNS resolver/' \
    -e 's/search?client=firefox&amp;q=%s/search?q=%s/' \
    -e 's/to sync Firefox/to sync your browsing data/' \
    -e 's/%1$s decides when to use secure DNS to protect your privacy/IronFox will use your system’s DNS resolver/' \
    app/src/*/res/values*/*strings.xml

# Replace instances of "Firefox" with "IronFox" or "IronFox Nightly"
## Also ensure that Firefox Suggest isn't incorrectly labeled as "IronFox Suggest",
## because Firefox Suggest suggestions are provided by Mozilla, not us, and
## ensure text states to sign-in to a "Firefox-based web browser" instead of "IronFox" on desktop
if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
    "${IRONFOX_SED}" -i \
    -e 's/Firefox Daylight/IronFox/; s/Firefox Fenix/IronFox/; s/Mozilla Firefox/IronFox/; s/Firefox/IronFox/g' \
    -e 's/IronFox Suggest/Firefox Suggest/' \
    -e 's/On your computer open IronFox and/On your computer, open a Firefox-based web browser, and/' \
    -e 's/To send a tab, sign in to IronFox/To send a tab, sign in to a Firefox-based web browser/' \
    app/src/*/res/values*/*strings.xml
else
    "${IRONFOX_SED}" -i \
    -e 's/Firefox Daylight/IronFox Nightly/; s/Firefox Fenix/IronFox Nightly/; s/Mozilla Firefox/IronFox Nightly/; s/Firefox/IronFox Nightly/g' \
    -e 's/IronFox Nightly Suggest/Firefox Suggest/' \
    -e 's/On your computer open IronFox Nightly and/On your computer, open a Firefox-based web browser, and/' \
    -e 's/To send a tab, sign in to IronFox Nightly/To send a tab, sign in to a Firefox-based web browser/' \
    app/src/*/res/values*/*strings.xml
fi

# Refer to "account" as "Firefox account" and "Sync" as "Firefox Sync"
## This makes it clear that these are third-party services, not operated by us
## (We need to set these last to ensure that "Firefox" here is not replaced with
##  "IronFox" or "IronFox Nightly")
"${IRONFOX_SED}" -i \
    -e 's/Learn more about sync/Learn more about Firefox Sync/' \
    -e 's/No account?/No Firefox account?/' \
    -e 's/Sync is on/Firefox Sync is on/' \
    -e 's/%s will stop syncing with your account/%s will stop syncing with your Firefox account/' \
    app/src/*/res/values*/*strings.xml

"${IRONFOX_SED}" -i -e 's|FENIX_PLAY_STORE_URL = ".*"|FENIX_PLAY_STORE_URL = ""|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
"${IRONFOX_SED}" -i -e 's|GOOGLE_URL = ".*"|GOOGLE_URL = ""|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
"${IRONFOX_SED}" -i -e 's|GOOGLE_US_URL = ".*"|GOOGLE_US_URL = ""|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
"${IRONFOX_SED}" -i -e 's|GOOGLE_XX_URL = ".*"|GOOGLE_XX_URL = ""|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
"${IRONFOX_SED}" -i -e 's|RATE_APP_URL = ".*"|RATE_APP_URL = ""|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt

"${IRONFOX_SED}" -i -e 's|ANDROID_SUPPORT_SUMO_URL = ".*"|ANDROID_SUPPORT_SUMO_URL = "https://ironfoxoss.org/docs/faq/"|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
"${IRONFOX_SED}" -i -e 's|WHATS_NEW_URL = ".*"|WHATS_NEW_URL = "https://gitlab.com/ironfox-oss/IronFox/-/releases"|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
"${IRONFOX_SED}" -i 's|mzl.la/AndroidSupport|https://ironfoxoss.org/docs/faq/|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
"${IRONFOX_SED}" -i 's|https://www.mozilla.org/firefox/android/notes|https://gitlab.com/ironfox-oss/IronFox/-/releases|g' app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt

# Replace proprietary artwork
rm -vf app/src/release/res/drawable/ic_launcher_foreground.xml
rm -vf app/src/release/res/mipmap-*/ic_launcher.webp
rm -vf app/src/release/res/values/colors.xml
rm -vf app/src/main/res/values-v24/styles.xml
"${IRONFOX_SED}" -i -e '/SplashScreen/,+5d' app/src/main/res/values-v27/styles.xml
mkdir -vp app/src/release/res/mipmap-anydpi-v26
"${IRONFOX_SED}" -i \
    -e 's/googleg_standard_color_18/ic_download/' \
    app/src/main/java/org/mozilla/fenix/components/menu/compose/MenuItem.kt \
    app/src/main/java/org/mozilla/fenix/compose/list/ListItem.kt

# Remove default built-in search engines
rm -vrf app/src/main/assets/searchplugins/*

# Create wallpaper directories
mkdir -vp app/src/main/assets/wallpapers/algae
mkdir -vp app/src/main/assets/wallpapers/colorful-bubbles
mkdir -vp app/src/main/assets/wallpapers/dark-dune
mkdir -vp app/src/main/assets/wallpapers/dune
mkdir -vp app/src/main/assets/wallpapers/firey-red

# Display proper name and description for wallpaper collection
"${IRONFOX_SED}" -i -e 's|R.string.wallpaper_artist_series_title|R.string.wallpaper_collection_fennec|' app/src/main/java/org/mozilla/fenix/settings/wallpaper/WallpaperSettings.kt
"${IRONFOX_SED}" -i -e 's|R.string.wallpaper_artist_series_description_with_learn_more|R.string.wallpaper_collection_fennec_description|' app/src/main/java/org/mozilla/fenix/settings/wallpaper/WallpaperSettings.kt

# Set up target parameters
case "$1" in
arm)
    # APK for armeabi-v7a
    abi='"armeabi-v7a"'
    geckotarget='arm'
    llvmtarget='ARM'
    rusttarget='arm'
    ;;
arm64)
    # APK for arm64-v8a
    abi='"arm64-v8a"'
    geckotarget='arm64'
    llvmtarget='AArch64'
    rusttarget='arm64'
    ;;
x86_64)
    # APK for x86_64
    abi='"x86_64"'
    geckotarget='x86_64'
    llvmtarget='X86_64'
    rusttarget='x86_64'
    ;;
bundle)
    # AAB for both armeabi-v7a and arm64-v8a
    abi='"arm64-v8a", "armeabi-v7a", "x86_64"'
    geckotarget='bundle'
    llvmtarget='AArch64;ARM;X86_64'
    rusttarget='arm64,arm,x86_64'
    ;;
*)
    echo "Unknown build variant: '$1'" >&2
    exit 1
    ;;
esac

"${IRONFOX_SED}" -i -e "s/include \".*\"/include ${abi}/" app/build.gradle
"${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_ARCH}|${geckotarget}|" "${rootdir}/scripts/env_local.sh"

# Apply Fenix overlay
apply_overlay "${patches}/fenix-overlay/"

# Apply UnifiedPush-AC overlay (for Fenix)
apply_overlay "${IRONFOX_UP_AC}/fenix-overlay/"

popd

#
# Glean
#

# We currently remove Glean fully from Android Components (See `a-c-remove-glean.patch`) and Application Services (see `a-s-remove-glean.patch`). Unfortunately, it's currently untenable to remove Glean in its entirety from Fenix (though we do remove Mozilla's `Glean Service` library/implementation). So, our approach is to stub Glean for Fenix, which we can do thanks to Tor's no-op UniFFi binding generator, as well as our `fenix-remove-glean.patch` patch, and the commands below.
## https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/tree/main/projects/glean

pushd "${IRONFOX_GLEAN}"

# Apply patches
glean_apply_patches

localize_maven

# Break the dependency on older Rust
"${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/Cargo.toml
"${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/build/Cargo.toml
"${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" glean-core/rlb/Cargo.toml

# Disable debug
"${IRONFOX_SED}" -i -e "s|debug = .*|debug = false|g" Cargo.toml

# Enable performance optimizations
"${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" Cargo.toml
"${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" Cargo.toml

# No-op Glean
"${IRONFOX_SED}" -i -e 's|allowGleanInternal = .*|allowGleanInternal = false|g' glean-core/android/build.gradle
"${IRONFOX_SED}" -i -e '/minifyEnabled/s/false/true/' glean-core/android-native/build.gradle
"${IRONFOX_SED}" -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' glean-core/python/glean/config.py
"${IRONFOX_SED}" -i -e '/enable_internal_pings:/s/true/false/' glean-core/python/glean/config.py
"${IRONFOX_SED}" -i -e "s|DEFAULT_GLEAN_ENDPOINT: .*|DEFAULT_GLEAN_ENDPOINT: \&\str = \"\";|g" glean-core/rlb/src/configuration.rs
"${IRONFOX_SED}" -i -e '/enable_internal_pings:/s/true/false/' glean-core/rlb/src/configuration.rs
"${IRONFOX_SED}" -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
"${IRONFOX_SED}" -i -e '/enableInternalPings:/s/true/false/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
"${IRONFOX_SED}" -i -e '/enableEventTimestamps:/s/true/false/' glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt
"${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/core_metrics.rs
"${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/glean_metrics.rs
"${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/internal_metrics.rs
"${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' glean-core/src/lib_unit_tests.rs
"${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' glean-core/pings.yaml
"${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' glean-core/pings.yaml
"${IRONFOX_SED}" -i -e 's|"$rootDir/glean-core/android/metrics.yaml"|// "$rootDir/glean-core/android/metrics.yaml"|g' glean-core/android/build.gradle
rm -vf glean-core/android/metrics.yaml

# Ensure we're building for release
"${IRONFOX_SED}" -i -e 's|ext.cargoProfile = .*|ext.cargoProfile = "release"|g' build.gradle

# Set libxul location (for use with Tor's no-op UniFFi binding generator)
if [[ "${IRONFOX_PLATFORM}" == "darwin" ]]; then
    "${IRONFOX_SED}" -i "s|{libxul_dir}|aarch64-linux-android/release|" glean-core/android/build.gradle
else
    "${IRONFOX_SED}" -i "s|{libxul_dir}|release|" glean-core/android/build.gradle
fi

# Apply Glean overlay
apply_overlay "${patches}/glean-overlay/"

## This is so the build script can set the uniffi path if needed (ex. if the user changes it)
if [[ -f "${builddir}/tmp/glean/build.gradle" ]]; then
    rm -f "${builddir}/tmp/glean/build.gradle"
fi
cp -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle" "${builddir}/tmp/glean/build.gradle"

popd

#
# Android Components
#

pushd "${android_components}"

# Remove default built-in search engines
rm -vrf components/feature/search/src/main/assets/searchplugins/*

# Nuke the "Mozilla Android Components - Ads Telemetry" and "Mozilla Android Components - Search Telemetry" extensions
## We don't install these with fenix-disable-telemetry.patch - so no need to keep the files around...
rm -vrf components/feature/search/src/main/assets/extensions/ads
rm -vrf components/feature/search/src/main/assets/extensions/search

## We can also remove the directories/libraries themselves as well
rm -vf components/feature/search/src/main/java/mozilla/components/feature/search/middleware/AdsTelemetryMiddleware.kt
rm -vrf components/feature/search/src/main/java/mozilla/components/feature/search/telemetry

# Remove the 'search telemetry' config
rm -vf components/feature/search/src/main/assets/search/search_telemetry_v2.json

# Remove unused/unwanted sample libraries
## Since we remove the Glean Service and Web Compat Reporter dependencies, the existence of these files causes build issues
## We don't build or use these sample libraries at all anyways, so instead of patching these files, I don't see a reason why we shouldn't just delete them. 
rm -rvf samples/browser
rm -rvf samples/crash

# Remove Nimbus
rm -vf components/browser/engine-gecko/geckoview.fml.yaml
rm -vrf components/browser/engine-gecko/src/main/java/mozilla/components/experiment
"${IRONFOX_SED}" -i -e 's|-keep class mozilla.components.service.nimbus|#-keep class mozilla.components.service.nimbus|' components/service/nimbus/proguard-rules-consumer.pro
"${IRONFOX_SED}" -i -e '/buildConfig/s/true/false/' components/service/nimbus/build.gradle

# Remove MARS
rm -vrf components/service/mars

# Remove Sentry
rm -vrf components/lib/crash-sentry

# Remove Web Compat Reporter
rm -vrf components/feature/webcompat-reporter

# Crash library
"${IRONFOX_SED}" -i -e '/buildConfig/s/true/false/' components/lib/crash/build.gradle

# Apply a-c overlay
apply_overlay "${patches}/a-c-overlay/"

popd

#
# Application Services
#

pushd "${IRONFOX_AS}"

# Apply patches
a-s_apply_patches

# Break the dependency on older A-C
"${IRONFOX_SED}" -i -e "/^android-components = \"/c\\android-components = \"${FIREFOX_VERSION}\"" gradle/libs.versions.toml

# Break the dependency on older Rust
"${IRONFOX_SED}" -i -e "s|channel = .*|channel = \""${RUST_VERSION}\""|g" rust-toolchain.toml

# Disable debug
"${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' Cargo.toml

# Enable performance optimizations
"${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" Cargo.toml
"${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" Cargo.toml

"${IRONFOX_SED}" -i -e '/NDK ez-install/,/^$/d' libs/verify-android-ci-environment.sh
"${IRONFOX_SED}" -i -e '/content {/,/}/d' build.gradle

localize_maven

# Fix stray
"${IRONFOX_SED}" -i -e '/^    mavenLocal/{n;d}' tools/nimbus-gradle-plugin/build.gradle
# Fail on use of prebuilt binary
"${IRONFOX_SED}" -i 's|https://|hxxps://|' tools/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy

# No-op Nimbus (Experimentation)
"${IRONFOX_SED}" -i -e 's|NimbusInterface.isLocalBuild() = .*|NimbusInterface.isLocalBuild() = true|g' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt
"${IRONFOX_SED}" -i -e 's|isFetchEnabled(): Boolean = .*|isFetchEnabled(): Boolean = false|g' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt
"${IRONFOX_SED}" -i -e 's|isFetchEnabled(): Boolean = .*|isFetchEnabled(): Boolean = false|g' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt
"${IRONFOX_SED}" -i -e 's/EXPERIMENT_COLLECTION_NAME = ".*"/EXPERIMENT_COLLECTION_NAME = ""/' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/Nimbus.kt
"${IRONFOX_SED}" -i 's|nimbus-mobile-experiments||g' components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/Nimbus.kt

# Remove default built-in search engines
rm -vrf components/remote_settings/dumps/main/attachments/search-config-icons/*

# Remove the 'regions' configs
rm -vf components/remote_settings/dumps/main/regions.json
rm -vrf components/remote_settings/dumps/main/attachments/regions
"${IRONFOX_SED}" -i -e 's|("main", "regions"),|// ("main", "regions"),|g' components/remote_settings/src/client.rs

# Remove the 'search telemetry' config
rm -vf components/remote_settings/dumps/main/search-telemetry-v2.json
"${IRONFOX_SED}" -i -e 's|("main", "search-telemetry-v2"),|// ("main", "search-telemetry-v2"),|g' components/remote_settings/src/client.rs

# Remove the Mozilla Ads Client library
"${IRONFOX_SED}" -i 's|"components/ads-client"|# "components/ads-client"|g' Cargo.toml
"${IRONFOX_SED}" -i 's|ads-client|# ads-client|g' megazords/full/Cargo.toml

# Remove the Crash Reporter test library
"${IRONFOX_SED}" -i 's|"components/crashtest"|# "components/crashtest"|g' Cargo.toml
"${IRONFOX_SED}" -i 's|crashtest|# crashtest|g' megazords/full/Cargo.toml

# Remove the Rust Error support library
## Used for telemetry/error reporting, depends on Glean
"${IRONFOX_SED}" -i 's|"components/support/error|# "components/support/error|g' Cargo.toml
"${IRONFOX_SED}" -i 's|error-support|# error-support|g' megazords/full/Cargo.toml

# Apply Application Services overlay
apply_overlay "$patches/a-s-overlay/"

popd

#
# Gecko
#
pushd "${IRONFOX_GECKO}"

# Apply patches
apply_patches

## For UnifiedPush-AC
up_ac_apply_patches

# Let it be IronFox (part 2...)
"${IRONFOX_SED}" -i -e 's|"MOZ_APP_VENDOR", ".*"|"MOZ_APP_VENDOR", "IronFox OSS"|g' mobile/android/moz.configure
echo '' >>mobile/android/moz.configure
echo 'include("../../ironfox/ironfox.configure")' >>mobile/android/moz.configure
echo '' >>moz.build
echo 'DIRS += ["ironfox"]' >>moz.build

# Replace proprietary artwork
"${IRONFOX_SED}" -i -e '/android:roundIcon/d' mobile/android/fenix/app/src/main/AndroidManifest.xml

# Use `commit` instead of `rev` for source URL
## (ex. displayed at `about:buildconfig`)
"${IRONFOX_SED}" -i 's|/rev/|/commit/|' build/variables.py

# about: pages
echo '' >>mobile/android/installer/package-manifest.in
echo '@BINPATH@/chrome/browser@JAREXT@' >>mobile/android/installer/package-manifest.in
echo '@BINPATH@/chrome/browser.manifest' >>mobile/android/installer/package-manifest.in
echo '' >>mobile/android/installer/package-manifest.in
echo '@BINPATH@/chrome/ironfox@JAREXT@' >>mobile/android/installer/package-manifest.in
echo '@BINPATH@/chrome/ironfox.manifest' >>mobile/android/installer/package-manifest.in

# about:policies
mkdir -vp ironfox/locales/en-US/browser/policies
cp -vf browser/locales/en-US/browser/aboutPolicies.ftl ironfox/locales/en-US/browser/
cp -vf browser/locales/en-US/browser/policies/policies-descriptions.ftl ironfox/locales/en-US/browser/policies/

# about:robots
mkdir -vp ironfox/about/browser/robots
cp -vf browser/base/content/aboutRobots.css ironfox/about/browser/robots/
cp -vf browser/base/content/aboutRobots.js ironfox/about/browser/robots/
cp -vf browser/base/content/aboutRobots.xhtml ironfox/about/browser/robots/
cp -vf browser/base/content/aboutRobots-icon.png ironfox/about/browser/robots/
cp -vf browser/base/content/robot.ico ironfox/about/browser/robots/
cp -vf browser/base/content/static-robot.png ironfox/about/browser/robots/
cp -vf browser/locales/en-US/browser/aboutRobots.ftl ironfox/locales/en-US/browser/

# Ensure we're building for release
"${IRONFOX_SED}" -i -e 's/variant=variant(.*)/variant=variant("release")/' mobile/android/gradle.configure

# Fix v125 aar output not including native libraries
"${IRONFOX_SED}" -i \
    -e "s/singleVariant('debug')/singleVariant('release')/" \
    mobile/android/geckoview/build.gradle

# Hack the timeout for
# geckoview:generateJNIWrappersForGeneratedWithGeckoBinariesDebug
"${IRONFOX_SED}" -i \
    -e 's/max_wait_seconds=600/max_wait_seconds=1800/' \
    mobile/android/gradle.py

# Break the dependency on older Rust
"${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_VERSION}\""|g" Cargo.toml
"${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" intl/icu_capi/Cargo.toml
"${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" intl/icu_segmenter_data/Cargo.toml

# Disable debug
"${IRONFOX_SED}" -i -e 's|debug-assertions = .*|debug-assertions = false|g' Cargo.toml
"${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' gfx/harfbuzz/src/rust/Cargo.toml
"${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' gfx/wr/Cargo.toml

# Enable overflow checks
"${IRONFOX_SED}" -i -e 's|overflow-checks = .*|overflow-checks = true|g' gfx/harfbuzz/src/rust/Cargo.toml

# Enable performance optimizations
"${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" Cargo.toml
"${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" Cargo.toml
"${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" gfx/wr/Cargo.toml

# Disable Normandy (Experimentation)
"${IRONFOX_SED}" -i -e 's|"MOZ_NORMANDY", .*)|"MOZ_NORMANDY", False)|g' mobile/android/moz.configure

# Disable SSLKEYLOGGING
## https://bugzilla.mozilla.org/show_bug.cgi?id=1183318
## https://bugzilla.mozilla.org/show_bug.cgi?id=1915224
"${IRONFOX_SED}" -i -e 's|NSS_ALLOW_SSLKEYLOGFILE ?= .*|NSS_ALLOW_SSLKEYLOGFILE ?= 0|g' security/nss/lib/ssl/Makefile
echo '' >>security/moz.build
echo 'gyp_vars["enable_sslkeylogfile"] = 0' >>security/moz.build

# Disable telemetry
"${IRONFOX_SED}" -i -e 's|"MOZ_SERVICES_HEALTHREPORT", .*)|"MOZ_SERVICES_HEALTHREPORT", False)|g' mobile/android/moz.configure

# Ensure UA is always set to Firefox
"${IRONFOX_SED}" -i -e 's|"MOZ_APP_UA_NAME", ".*"|"MOZ_APP_UA_NAME", "Firefox"|g' mobile/android/moz.configure

# Include additional Remote Settings local dumps (+ add our own...)
"${IRONFOX_SED}" -i -e 's|"mobile/"|"0"|g' services/settings/dumps/blocklists/moz.build
"${IRONFOX_SED}" -i -e 's|"mobile/"|"0"|g' services/settings/dumps/security-state/moz.build
echo '' >>services/settings/dumps/main/moz.build
echo 'FINAL_TARGET_FILES.defaults.settings.main += [' >>services/settings/dumps/main/moz.build
echo '    "anti-tracking-url-decoration.json",' >>services/settings/dumps/main/moz.build
echo '    "cookie-banner-rules-list.json",' >>services/settings/dumps/main/moz.build
echo '    "hijack-blocklists.json",' >>services/settings/dumps/main/moz.build
echo '    "translations-models.json",' >>services/settings/dumps/main/moz.build
echo '    "translations-wasm.json",' >>services/settings/dumps/main/moz.build
echo '    "url-classifier-skip-urls.json",' >>services/settings/dumps/main/moz.build
echo '    "url-parser-default-unknown-schemes-interventions.json",' >>services/settings/dumps/main/moz.build
echo ']' >>services/settings/dumps/main/moz.build

# Remove unused about:telemetry assets
rm -vf toolkit/content/aboutTelemetry.css toolkit/content/aboutTelemetry.js toolkit/content/aboutTelemetry.xhtml

# Remove the Clear Key CDM
"${IRONFOX_SED}" -i 's|@BINPATH@/@DLL_PREFIX@clearkey|; @BINPATH@/@DLL_PREFIX@clearkey|' mobile/android/installer/package-manifest.in

# No-op AMO collections/recommendations
"${IRONFOX_SED}" -i -e 's/DEFAULT_COLLECTION_NAME = ".*"/DEFAULT_COLLECTION_NAME = ""/' mobile/android/android-components/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
"${IRONFOX_SED}" -i 's|7e8d6dc651b54ab385fb8791bf9dac||g' mobile/android/android-components/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
"${IRONFOX_SED}" -i -e 's/DEFAULT_COLLECTION_USER = ".*"/DEFAULT_COLLECTION_USER = ""/' mobile/android/android-components/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt
"${IRONFOX_SED}" -i -e 's/DEFAULT_SERVER_URL = ".*"/DEFAULT_SERVER_URL = ""/' mobile/android/android-components/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt

# Remove unnecessary crash reporting components
rm -vrf mobile/android/android-components/components/support/appservices/src/main/java/mozilla/components/support/rusterrors

"${IRONFOX_SED}" -i -e 's|enabled: Boolean = .*|enabled: Boolean = false,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
"${IRONFOX_SED}" -i -e 's|shouldPrompt: Prompt = .*|shouldPrompt: Prompt = Prompt.ALWAYS,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
"${IRONFOX_SED}" -i -e 's|useLegacyReporting: Boolean = .*|useLegacyReporting: Boolean = false,|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt
"${IRONFOX_SED}" -i -e 's|var enabled: Boolean = false,|var enabled: Boolean = enabled|g' mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt

"${IRONFOX_SED}" -i 's|crash-reports-ondemand||g' toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs
"${IRONFOX_SED}" -i -e 's/REMOTE_SETTINGS_CRASH_COLLECTION = ".*"/REMOTE_SETTINGS_CRASH_COLLECTION = ""/' toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs

# No-op MARS
"${IRONFOX_SED}" -i -e 's/MARS_ENDPOINT_BASE_URL = ".*"/MARS_ENDPOINT_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt
"${IRONFOX_SED}" -i -e 's/MARS_ENDPOINT_STAGING_BASE_URL = ".*"/MARS_ENDPOINT_STAGING_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt

# Remove MARS
"${IRONFOX_SED}" -i 's|- components:service-mars|# - components:service-mars|g' mobile/android/fenix/.buildconfig.yml
"${IRONFOX_SED}" -i "s|implementation project(':components:service-mars')|// implementation project(':components:service-mars')|g" mobile/android/fenix/app/build.gradle

rm -vf mobile/android/fenix/app/src/main/java/org/mozilla/fenix/home/TopSitesRefresher.kt

# No-op GeoIP/Region service
## https://searchfox.org/mozilla-release/source/toolkit/modules/docs/Region.rst
"${IRONFOX_SED}" -i -e 's/GEOIP_SERVICE_URL = ".*"/GEOIP_SERVICE_URL = ""/' mobile/android/android-components/components/service/location/src/main/java/mozilla/components/service/location/MozillaLocationService.kt
"${IRONFOX_SED}" -i -e 's/USER_AGENT = ".*/USER_AGENT = ""/' mobile/android/android-components/components/service/location/src/main/java/mozilla/components/service/location/MozillaLocationService.kt

# No-op Normandy (Experimentation)
"${IRONFOX_SED}" -i -e 's/REMOTE_SETTINGS_COLLECTION = ".*"/REMOTE_SETTINGS_COLLECTION = ""/' toolkit/components/normandy/lib/RecipeRunner.sys.mjs
"${IRONFOX_SED}" -i 's|normandy-recipes-capabilities||g' toolkit/components/normandy/lib/RecipeRunner.sys.mjs

# No-op Nimbus (Experimentation)
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.ext.recordEventInNimbus|// import org.mozilla.fenix.ext.recordEventInNimbus|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt
"${IRONFOX_SED}" -i -e 's|context.recordEventInNimbus|// context.recordEventInNimbus|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt
"${IRONFOX_SED}" -i -e 's|FxNimbus.features.junoOnboarding.recordExposure|// FxNimbus.features.junoOnboarding.recordExposure|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/utils/Settings.kt
"${IRONFOX_SED}" -i 's|classpath "${ApplicationServicesConfig.groupId}:tooling-nimbus-gradle|// "${ApplicationServicesConfig.groupId}:tooling-nimbus-gradle|g' build.gradle

# No-op Nimbus (Experimentation) (Gecko)
## (Primarily for defense in depth)
"${IRONFOX_SED}" -i -e 's/COLLECTION_ID_FALLBACK = ".*"/COLLECTION_ID_FALLBACK = ""/' toolkit/components/nimbus/ExperimentAPI.sys.mjs
"${IRONFOX_SED}" -i -e 's/COLLECTION_ID_FALLBACK = ".*"/COLLECTION_ID_FALLBACK = ""/' toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs
"${IRONFOX_SED}" -i -e 's/EXPERIMENTS_COLLECTION = ".*"/EXPERIMENTS_COLLECTION = ""/' toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs
"${IRONFOX_SED}" -i -e 's/SECURE_EXPERIMENTS_COLLECTION = ".*"/SECURE_EXPERIMENTS_COLLECTION = ""/' toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs
"${IRONFOX_SED}" -i -e 's/SECURE_EXPERIMENTS_COLLECTION_ID = ".*"/SECURE_EXPERIMENTS_COLLECTION_ID = ""/' toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs
"${IRONFOX_SED}" -i 's|nimbus-desktop-experiments||g' toolkit/components/nimbus/ExperimentAPI.sys.mjs
"${IRONFOX_SED}" -i 's|nimbus-desktop-experiments||g' toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs
"${IRONFOX_SED}" -i 's|nimbus-secure-experiments||g' toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs

# No-op Pocket
"${IRONFOX_SED}" -i -e 's/SPOCS_ENDPOINT_DEV_BASE_URL = ".*"/SPOCS_ENDPOINT_DEV_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt
"${IRONFOX_SED}" -i -e 's/SPOCS_ENDPOINT_PROD_BASE_URL = ".*"/SPOCS_ENDPOINT_PROD_BASE_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt
"${IRONFOX_SED}" -i -e 's/POCKET_ENDPOINT_URL = ".*"/POCKET_ENDPOINT_URL = ""/' mobile/android/android-components/components/service/pocket/src/*/java/mozilla/components/service/pocket/stories/api/PocketEndpointRaw.kt

# No-op search telemetry
"${IRONFOX_SED}" -i 's|search-telemetry-v2||g' mobile/android/fenix/app/src/*/java/org/mozilla/fenix/components/Core.kt

# No-op telemetry (Gecko)
"${IRONFOX_SED}" -i -e '/enable_internal_pings:/s/true/false/' toolkit/components/glean/src/init/mod.rs
"${IRONFOX_SED}" -i -e '/upload_enabled =/s/true/false/' toolkit/components/glean/src/init/mod.rs
"${IRONFOX_SED}" -i -e '/use_core_mps:/s/true/false/' toolkit/components/glean/src/init/mod.rs
"${IRONFOX_SED}" -i -e 's/usageDeletionRequest.setEnabled(.*)/usageDeletionRequest.setEnabled(false)/' toolkit/components/telemetry/app/UsageReporting.sys.mjs
"${IRONFOX_SED}" -i -e 's|useTelemetry = .*|useTelemetry = false;|g' toolkit/components/telemetry/core/Telemetry.cpp
"${IRONFOX_SED}" -i '/# This must remain last./i gkrust_features += ["glean_disable_upload"]\n' toolkit/library/rust/gkrust-features.mozbuild

"${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' toolkit/components/glean/pings.yaml
"${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' toolkit/components/glean/pings.yaml
"${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' toolkit/components/nimbus/pings.yaml
"${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' toolkit/components/nimbus/pings.yaml

# No-op telemetry (GeckoView)
"${IRONFOX_SED}" -i -e 's|allowMetricsFromAAR = .*|allowMetricsFromAAR = false|g' mobile/android/android-components/components/browser/engine-gecko/build.gradle

# Prevent DoH canary requests
"${IRONFOX_SED}" -i -e 's/GLOBAL_CANARY = ".*"/GLOBAL_CANARY = ""/' toolkit/components/doh/DoHHeuristics.sys.mjs
"${IRONFOX_SED}" -i -e 's/ZSCALER_CANARY = ".*"/ZSCALER_CANARY = ""/' toolkit/components/doh/DoHHeuristics.sys.mjs

# Prevent DoH remote config/rollout
"${IRONFOX_SED}" -i -e 's/RemoteSettings(".*"/RemoteSettings(""/' toolkit/components/doh/DoHConfig.sys.mjs
"${IRONFOX_SED}" -i -e 's/kConfigCollectionKey = ".*"/kConfigCollectionKey = ""/' toolkit/components/doh/DoHTestUtils.sys.mjs
"${IRONFOX_SED}" -i -e 's/kProviderCollectionKey = ".*"/kProviderCollectionKey = ""/' toolkit/components/doh/DoHTestUtils.sys.mjs
"${IRONFOX_SED}" -i 's|"doh-config"||g' toolkit/components/doh/DoHConfig.sys.mjs
"${IRONFOX_SED}" -i 's|"doh-providers"||g' toolkit/components/doh/DoHConfig.sys.mjs
"${IRONFOX_SED}" -i 's|"doh-config"||g' toolkit/components/doh/DoHTestUtils.sys.mjs
"${IRONFOX_SED}" -i 's|"doh-providers"||g' toolkit/components/doh/DoHTestUtils.sys.mjs

# Remove DoH config/rollout local dumps
"${IRONFOX_SED}" -i -e 's|"doh-config.json"|# "doh-config.json"|g' services/settings/static-dumps/main/moz.build
"${IRONFOX_SED}" -i -e 's|"doh-providers.json"|# "doh-providers.json"|g' services/settings/static-dumps/main/moz.build
rm -vf services/settings/static-dumps/main/doh-config.json services/settings/static-dumps/main/doh-providers.json

# Remove unused crash reporting services/components
rm -vf mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/MinidumpAnalyzer.kt
rm -vf mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/MozillaSocorroService.kt

# Remove example dependencies
## Also see `gecko-remove-example-dependencies.patch`
"${IRONFOX_SED}" -i "s|include ':annotations', .*|include ':annotations'|g" settings.gradle
"${IRONFOX_SED}" -i "s|project(':messaging_example'|// project(':messaging_example'|g" settings.gradle
"${IRONFOX_SED}" -i "s|project(':port_messaging_example'|// project(':port_messaging_example'|g" settings.gradle
"${IRONFOX_SED}" -i -e 's#if (rootDir.toString().contains("android-components") || !project.key.startsWith("samples"))#if (!project.key.startsWith("samples"))#' mobile/android/shared-settings.gradle

# Remove ExoPlayer
"${IRONFOX_SED}" -i "s|include ':exoplayer2'|// include ':exoplayer2'|g" settings.gradle
"${IRONFOX_SED}" -i "s|project(':exoplayer2'|// project(':exoplayer2'|g" settings.gradle

# Remove proprietary/tracking libraries
"${IRONFOX_SED}" -i 's|adjust|# adjust|g' gradle/libs.versions.toml
"${IRONFOX_SED}" -i 's|firebase-messaging|# firebase-messaging|g' gradle/libs.versions.toml
"${IRONFOX_SED}" -i 's|installreferrer|# installreferrer|g' gradle/libs.versions.toml
"${IRONFOX_SED}" -i 's|play-review|# play-review|g' gradle/libs.versions.toml
"${IRONFOX_SED}" -i 's|play-services|# play-services|g' gradle/libs.versions.toml
"${IRONFOX_SED}" -i 's|sentry|# sentry|g' gradle/libs.versions.toml

# Replace Google Play FIDO with microG
"${IRONFOX_SED}" -i 's|libs.play.services.fido|"org.microg.gms:play-services-fido:v0.0.0.250932"|g' mobile/android/geckoview/build.gradle

# Remove Glean
source "${rootdir}/scripts/deglean.sh"

# Nuke undesired Mozilla endpoints
source "${rootdir}/scripts/noop_mozilla_endpoints.sh"

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
"${IRONFOX_SED}" -i -e 's|R.drawable.microsurvey_success|R.drawable.fox_alert_crash_dark|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/microsurvey/ui/MicrosurveyCompleted.kt
"${IRONFOX_SED}" -i -e 's|R.drawable.ic_onboarding_search_widget|R.drawable.fox_alert_crash_dark|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/onboarding/widget/SetSearchWidgetMainImage.kt
"${IRONFOX_SED}" -i -e 's|R.drawable.ic_onboarding_sync|R.drawable.fox_alert_crash_dark|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/onboarding/redesign/view/OnboardingScreenRedesign.kt
"${IRONFOX_SED}" -i -e 's|R.drawable.ic_onboarding_sync|R.drawable.fox_alert_crash_dark|' mobile/android/fenix/app/src/main/java/org/mozilla/fenix/onboarding/view/OnboardingScreen.kt
"${IRONFOX_SED}" -i -e 's|ic_onboarding_search_widget|fox_alert_crash_dark|' mobile/android/fenix/app/onboarding.fml.yaml
"${IRONFOX_SED}" -i -e 's|ic_onboarding_sync|fox_alert_crash_dark|' mobile/android/fenix/app/onboarding.fml.yaml

# Take back control of preferences
## This prevents GeckoView from overriding the follow prefs at runtime, which also means we don't have to worry about Nimbus overriding them, etc...
## The prefs will instead take the values we specify in the phoenix/ironfox .js files, and users will also be able to override them via the `about:config`
## This is ideal for features that aren't exposed by the UI, it gives more freedom/control back to users, and it's great to ensure things are always configured how we want them...
"${IRONFOX_SED}" -i \
    -e 's|"browser.safebrowsing.malware.enabled"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.phishing.enabled"|"z99.ignore.boolean"|' \
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

"${IRONFOX_SED}" -i \
    -e 's|"apz.allow_double_tap_zooming"|"z99.ignore.boolean"|' \
    -e 's|"browser.crashReports.requestedNeverShowAgain"|"z99.ignore.boolean"|' \
    -e 's|"browser.display.use_document_fonts"|"z99.ignore.integer"|' \
    -e 's|"devtools.debugger.remote-enabled"|"z99.ignore.boolean"|' \
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
    -e 's|"javascript.enabled"|"z99.ignore.boolean"|' \
    -e 's|"javascript.options.mem.gc_parallel_marking"|"z99.ignore.boolean"|' \
    -e 's|"javascript.options.use_fdlibm_for_sin_cos_tan"|"z99.ignore.boolean"|' \
    -e 's|"network.android_doh.autoselect_enabled"|"z99.ignore.boolean"|' \
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
    -e 's|"security.pki.crlite_channel"|"z99.ignore.string"|' \
    -e 's|"security.tls.enable_kyber"|"z99.ignore.boolean"|' \
    -e 's|"toolkit.telemetry.user_characteristics_ping.current_version"|"z99.ignore.integer"|' \
    -e 's|"webgl.msaa-samples"|"z99.ignore.integer"|' \
    mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntimeSettings.java

if [[ -n ${FDROID_BUILD+x} ]]; then
    # Patch the LLVM source code
    # Search clang- in https://android.googlesource.com/IRONFOX_PLATFORM/ndk/+/refs/tags/ndk-r28b/ndk/toolchains.py
    LLVM_SVN='530567'
    python3 "${toolchain_utils}/llvm_tools/patch_manager.py" \
        --svn_version $LLVM_SVN \
        --patch_metadata_file "${llvm_android}/patches/PATCHES.json" \
        --src_path "${llvm}"

    # Bundletool
    pushd "${bundletool}"
    localize_maven
    popd
fi

# Fail on use of prebuilt binary
"${IRONFOX_SED}" -i 's|https://|hxxps://|' mobile/android/gradle/plugins/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy
"${IRONFOX_SED}" -i 's|https://github.com|hxxps://github.com|' python/mozboot/mozboot/android.py

# Make the build system think we installed the emulator and an AVD
mkdir -vp "${IRONFOX_ANDROID_SDK}/emulator"
mkdir -vp "${IRONFOX_MOZBUILD}/android-device/avd"

# Do not check the "emulator" utility which is obviously absent in the empty directory we created above
"${IRONFOX_SED}" -i -e '/check_android_tools("emulator"/d' build/moz.configure/android-sdk.configure

# Do not define `browser.safebrowsing.features.` prefs by default
## These are unnecessary, add extra confusion and complexity, and don't appear to interact well with our other prefs/settings
"${IRONFOX_SED}" -i \
    -e 's|"browser.safebrowsing.features.cryptomining.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.fingerprinting.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.harmfuladdon.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.malware.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.phishing.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.trackingAnnotation.update"|"z99.ignore.boolean"|' \
    -e 's|"browser.safebrowsing.features.trackingProtection.update"|"z99.ignore.boolean"|' \
    mobile/android/app/geckoview-prefs.js

# Gecko prefs
{
    cat "${patches}/gecko-overlay/ironfox/prefs/000-phoenix.js"
    cat "${patches}/gecko-overlay/ironfox/prefs/001-phoenix-extended.js"
    cat "${patches}/build/gecko/002-ironfox.js"
    cat "${patches}/build/gecko/003-ironfox-${IRONFOX_CHANNEL}.js"
} >>mobile/android/app/geckoview-prefs.js

"${IRONFOX_SED}" -i "s|{PHOENIX_VERSION}|${PHOENIX_VERSION}|" mobile/android/app/geckoview-prefs.js
"${IRONFOX_SED}" -i "s|{IRONFOX_UBO_ASSETS_URL}|${IRONFOX_UBO_ASSETS_URL}|" mobile/android/app/geckoview-prefs.js
"${IRONFOX_SED}" -i "s|{IRONFOX_VERSION}|${IRONFOX_VERSION}|" mobile/android/app/geckoview-prefs.js

echo '#include ../../../ironfox/prefs/pdf.js' >>toolkit/components/pdfjs/PdfJsDefaultPrefs.js

# Apply Gecko overlay
apply_overlay "${patches}/gecko-overlay/"

## The following are for the build script, so that it can update the environment variables if needed
### (ex. if the user changes them)

if [[ -f "${builddir}/tmp/fenix/build.gradle" ]]; then
    rm -f "${builddir}/tmp/fenix/build.gradle"
fi
cp -f "${IRONFOX_FENIX}/app/build.gradle" "${builddir}/tmp/fenix/build.gradle"

if [[ -f "${builddir}/tmp/fenix/shortcuts.xml" ]]; then
    rm -f "${builddir}/tmp/fenix/shortcuts.xml"
fi
cp -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml" "${builddir}/tmp/fenix/shortcuts.xml"

popd

#
# microG
#

pushd "${IRONFOX_GMSCORE}"

# Bump Android build tools
"${IRONFOX_SED}" -i -e "s|ext.androidBuildVersionTools = .*|ext.androidBuildVersionTools = '${ANDROID_BUILDTOOLS_VERSION}'|g" build.gradle

# Bump Android compile SDK
"${IRONFOX_SED}" -i -e "s|ext.androidCompileSdk = .*|ext.androidCompileSdk = ${ANDROID_SDK_TARGET}|g" build.gradle

# Bump Android minimum SDK
## (This matches what we're using for the browser itself, as well as Mozilla's various components/dependencies)
"${IRONFOX_SED}" -i -e 's|ext.androidMinSdk = .*|ext.androidMinSdk = 26|g' build.gradle

# Bump Android target SDK
"${IRONFOX_SED}" -i -e "s|ext.androidTargetSdk = .*|ext.androidTargetSdk = ${ANDROID_SDK_TARGET}|g" build.gradle

popd

#
# Prebuilds
#

if [[ "${NO_PREBUILDS}" == 1 ]]; then
    pushd "${prebuilds}"
    echo "Preparing the prebuild build repository..."
    bash "${prebuilds}/scripts/prebuild.sh"
    popd
fi
