#!/bin/bash
#
#    IronFox build scripts
#    Copyright (C) 2024-2026  Akash Yadav, celenity
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

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh

if [[ -n "${FDROID_BUILD+x}" ]]; then
    source "${IRONFOX_ENV_FDROID}"
fi

# Include utilities
source "${IRONFOX_UTILS}"

# Include patch utilities
source "${IRONFOX_SCRIPTS}/patches.sh"

if [[ -z "${IRONFOX_FROM_PREBUILD+x}" ]]; then
    echo_red_text "ERROR: Do not call prebuild-if.sh directly. Instead, use prebuild.sh." >&1
    exit 1
fi

if [ -f "${IRONFOX_BUILD}/finished-prebuild" ]; then
    rm -f "${IRONFOX_BUILD}/finished-prebuild"
fi

readonly target="$1"

# Set up target parameters
IRONFOX_PREPARE_AC=0
IRONFOX_PREPARE_ANDROID_SDK=0
IRONFOX_PREPARE_AS=0
IRONFOX_PREPARE_BUNDLETOOL=0
IRONFOX_PREPARE_FENIX=0
IRONFOX_PREPARE_GECKO=0
IRONFOX_PREPARE_GLEAN=0
IRONFOX_PREPARE_LLVM=0
IRONFOX_PREPARE_MICROG=0
IRONFOX_PREPARE_RUST=0
IRONFOX_PREPARE_PHOENIX=0
IRONFOX_PREPARE_PREBUILDS=0

if [ "${target}" == 'ac' ]; then
    # Prepare Android Components
    IRONFOX_PREPARE_AC=1
elif [ "${target}" == 'android-sdk' ]; then
    # Prepare Android SDK
    IRONFOX_PREPARE_ANDROID_SDK=1
elif [ "${target}" == 'as' ]; then
    # Prepare Application Services
    IRONFOX_PREPARE_AS=1
elif [ "${target}" == 'bundletool' ]; then
    # Prepare Bundletool
    IRONFOX_PREPARE_BUNDLETOOL=1
elif [ "${target}" == 'fenix' ]; then
    # Prepare Fenix
    IRONFOX_PREPARE_FENIX=1
elif [ "${target}" == 'firefox' ]; then
    # Prepare Firefox (Gecko/mozilla-central)
    IRONFOX_PREPARE_GECKO=1
elif [ "${target}" == 'glean' ]; then
    # Prepare Glean
    IRONFOX_PREPARE_GLEAN=1
elif [ "${target}" == 'llvm' ]; then
    # Prepare LLVM
    IRONFOX_PREPARE_LLVM=1
elif [ "${target}" == 'microg' ]; then
    # Prepare microG
    IRONFOX_PREPARE_MICROG=1
elif [ "${target}" == 'rust' ]; then
    # Prepare rust/cargo
    IRONFOX_PREPARE_RUST=1
elif [ "${target}" == 'phoenix' ]; then
    # Prepare Phoenix
    IRONFOX_PREPARE_PHOENIX=1
elif [ "${target}" == 'prebuilds' ]; then
    # Prepare IronFox prebuilds
    IRONFOX_PREPARE_PREBUILDS=1
elif [ "${target}" == 'all' ]; then
    # If no argument is specified (or argument is set to "all"), just prepare everything
    IRONFOX_PREPARE_AC=1
    IRONFOX_PREPARE_ANDROID_SDK=1
    IRONFOX_PREPARE_AS=1
    IRONFOX_PREPARE_FENIX=1
    IRONFOX_PREPARE_GECKO=1
    IRONFOX_PREPARE_GLEAN=1
    IRONFOX_PREPARE_MICROG=1
    IRONFOX_PREPARE_RUST=1
    IRONFOX_PREPARE_PHOENIX=1

    # Respect IRONFOX_NO_PREBUILDS...
    if [ "${IRONFOX_NO_PREBUILDS}" == 1 ]; then
        IRONFOX_PREPARE_BUNDLETOOL=1
        IRONFOX_PREPARE_PREBUILDS=1
        
        if [[ -n "${FDROID_BUILD+x}" ]]; then
            IRONFOX_PREPARE_LLVM=1
        fi
    fi
else
    echo_red_text "ERROR: Invalid target: ${target}\n You must enter one of the following:"
    echo 'All:                              all (Default)'
    echo 'Android Components:               ac'
    echo 'Android SDK:                      android-sdk'
    echo 'Application Services:             as'
    echo 'Bundletool:                       bundletool'
    echo 'Fenix:                            fenix'
    echo 'Firefox (Gecko/mozilla-central):  firefox'
    echo 'Glean:                            glean'
    echo 'LLVM:                             llvm'
    echo 'microG:                           microg'
    echo 'Rust:                             rust'
    echo 'Phoenix:                          phoenix'
    echo 'Prebuilds:                        prebuilds'
    exit 1
fi
readonly IRONFOX_PREPARE_AC
readonly IRONFOX_PREPARE_ANDROID_SDK
readonly IRONFOX_PREPARE_AS
readonly IRONFOX_PREPARE_BUNDLETOOL
readonly IRONFOX_PREPARE_FENIX
readonly IRONFOX_PREPARE_GECKO
readonly IRONFOX_PREPARE_GLEAN
readonly IRONFOX_PREPARE_LLVM
readonly IRONFOX_PREPARE_MICROG
readonly IRONFOX_PREPARE_RUST
readonly IRONFOX_PREPARE_PHOENIX
readonly IRONFOX_PREPARE_PREBUILDS

# Include version info
source "${IRONFOX_VERSIONS}"

function localize_gradle() {
    find ./* -name gradlew -type f | while read -r gradlew; do
        echo -e "#!/bin/sh\n\""'${IRONFOX_GRADLE}'"\" \${IRONFOX_GRADLE_FLAGS} \""'$@'"\"" >"${gradlew}"
        chmod 755 "${gradlew}"
    done
}

function localize_maven() {
    # Replace custom Maven repositories with mavenLocal()
    find ./* -name '*.gradle' -type f -exec "${IRONFOX_PYTHON}" "${IRONFOX_SCRIPTS}/localize_maven.py" {} \;
}

# Applies the overlay files in the given directory
# to the current directory
function apply_overlay() {
    local readonly source_dir="$1"
    find "${source_dir}" -type f| while read -r src; do
        local overlay_target="${src#"${source_dir}"}"
        mkdir -vp "$(dirname "${overlay_target}")"
        cp -vrf "${src}" "${overlay_target}"
    done
}

function prepare_ac() {
    echo_red_text 'Preparing Android Components...'

    pushd "${IRONFOX_AC}"

    # Remove default built-in search engines
    rm -vr "${IRONFOX_AC}/components/feature/search/src/main/assets/searchplugins/"*

    # No-op AMO collections/recommendations
    "${IRONFOX_SED}" -i -e 's/DEFAULT_COLLECTION_NAME = ".*"/DEFAULT_COLLECTION_NAME = ""/' "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt"
    "${IRONFOX_SED}" -i 's|7e8d6dc651b54ab385fb8791bf9dac||g' "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt"
    "${IRONFOX_SED}" -i -e 's/DEFAULT_COLLECTION_USER = ".*"/DEFAULT_COLLECTION_USER = ""/' "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt"
    "${IRONFOX_SED}" -i -e 's/DEFAULT_SERVER_URL = ".*"/DEFAULT_SERVER_URL = ""/' "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt"
 
    # No-op crash reporting
    "${IRONFOX_SED}" -i -e 's|enabled: Boolean = .*|enabled: Boolean = false,|g' "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt"
    "${IRONFOX_SED}" -i -e 's|shouldPrompt: Prompt = .*|shouldPrompt: Prompt = Prompt.ALWAYS,|g' "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt"
    "${IRONFOX_SED}" -i -e 's|useLegacyReporting: Boolean = .*|useLegacyReporting: Boolean = false,|g' "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt"
    "${IRONFOX_SED}" -i -e 's|var enabled: Boolean = false,|var enabled: Boolean = enabled|g' "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt"

    # No-op GeoIP/Region service
    ## https://searchfox.org/mozilla-release/source/toolkit/modules/docs/Region.rst
    "${IRONFOX_SED}" -i -e 's/GEOIP_SERVICE_URL = ".*"/GEOIP_SERVICE_URL = ""/' "${IRONFOX_AC}/components/service/location/src/main/java/mozilla/components/service/location/MozillaLocationService.kt"
    "${IRONFOX_SED}" -i -e 's/USER_AGENT = ".*/USER_AGENT = ""/' "${IRONFOX_AC}/components/service/location/src/main/java/mozilla/components/service/location/MozillaLocationService.kt"

    # No-op MARS
    "${IRONFOX_SED}" -i -e 's/MARS_ENDPOINT_BASE_URL = ".*"/MARS_ENDPOINT_BASE_URL = ""/' "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt"
    "${IRONFOX_SED}" -i -e 's/MARS_ENDPOINT_STAGING_BASE_URL = ".*"/MARS_ENDPOINT_STAGING_BASE_URL = ""/' "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt"

    # No-op Pocket
    "${IRONFOX_SED}" -i -e 's/POCKET_ENDPOINT_URL = ".*"/POCKET_ENDPOINT_URL = ""/' "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/stories/api/PocketEndpointRaw.kt"

    # No-op telemetry (GeckoView)
    "${IRONFOX_SED}" -i -e 's|allowMetricsFromAAR = .*|allowMetricsFromAAR = false|g' "${IRONFOX_AC}/components/browser/engine-gecko/build.gradle"

    # Nuke the "Mozilla Android Components - Ads Telemetry" and "Mozilla Android Components - Search Telemetry" extensions
    ## We don't install these with fenix-disable-telemetry.patch - so no need to keep the files around...
    rm -vr "${IRONFOX_AC}/components/feature/search/src/main/assets/extensions/ads"
    rm -vr "${IRONFOX_AC}/components/feature/search/src/main/assets/extensions/search"

    ## We can also remove the directories/libraries themselves as well
    rm -v "${IRONFOX_AC}/components/feature/search/src/main/java/mozilla/components/feature/search/middleware/AdsTelemetryMiddleware.kt"
    rm -vr "${IRONFOX_AC}/components/feature/search/src/main/java/mozilla/components/feature/search/telemetry"

    # Remove the 'search telemetry' config
    rm -v "${IRONFOX_AC}/components/feature/search/src/main/assets/search/search_telemetry_v2.json"
 
    # Remove Glean
    bash -x "${IRONFOX_SCRIPTS}/deglean.sh" 'ac'

    # Nuke undesired Mozilla endpoints
    bash -x "${IRONFOX_SCRIPTS}/noop_mozilla_endpoints.sh" 'ac'

    # Remove unused/unwanted sample libraries
    ## Since we remove the Glean Service and Web Compat Reporter dependencies, the existence of these files causes build issues
    ## We don't build or use these sample libraries at all anyways, so instead of patching these files, I don't see a reason why we shouldn't just delete them.
    rm -rv "${IRONFOX_AC}/samples/browser"
    rm -rv "${IRONFOX_AC}/samples/crash"

    # Remove Nimbus
    rm -v "${IRONFOX_AC}/components/browser/engine-gecko/geckoview.fml.yaml"
    rm -vr "${IRONFOX_AC}/components/browser/engine-gecko/src/main/java/mozilla/components/experiment"
    "${IRONFOX_SED}" -i -e 's|-keep class mozilla.components.service.nimbus|#-keep class mozilla.components.service.nimbus|' "${IRONFOX_AC}/components/service/nimbus/proguard-rules-consumer.pro"
    "${IRONFOX_SED}" -i -e '/buildConfig/s/true/false/' "${IRONFOX_AC}/components/service/nimbus/build.gradle"

    # Remove Firebase
    rm -vr "${IRONFOX_AC}/components/lib/push-firebase"

    # Remove Google Play Integrity
    rm -vr "${IRONFOX_AC}/components/lib/integrity-googleplay"

    # Remove MARS
    rm -vr "${IRONFOX_AC}/components/service/mars"

    # Remove Sentry
    rm -vr "${IRONFOX_AC}/components/lib/crash-sentry"

    # Remove unnecessary crash reporting components
    rm -vr "${IRONFOX_AC}/components/support/appservices/src/main/java/mozilla/components/support/rusterrors"
    rm -v "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/MozillaSocorroService.kt"

    # Remove Web Compat Reporter
    rm -vr "${IRONFOX_AC}/components/feature/webcompat-reporter"

    # Apply a-c overlay
    apply_overlay "${IRONFOX_AC_OVERLAY}/"

    popd

    echo_green_text 'SUCCESS: Prepared Android Components'
}

function prepare_android_sdk() {
    echo_red_text 'Preparing Android SDK...'

    # Create Android NDK symlink
    if [[ ! -d "${IRONFOX_ANDROID_SDK}/ndk/${ANDROID_NDK_REVISION}" ]]; then
        mkdir -p "${IRONFOX_ANDROID_SDK}/ndk"
        ln -s "${IRONFOX_ANDROID_NDK}" "${IRONFOX_ANDROID_SDK}/ndk/${ANDROID_NDK_REVISION}"
    fi

    # Create Android SDK Build Tools symlinks
    if [[ ! -d "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_SDK_BUILD_TOOLS_VERSION_STRING}" ]]; then
        mkdir -p "${IRONFOX_ANDROID_SDK}/build-tools"
        ln -s "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_SDK_BUILD_TOOLS_VERSION_STRING}"
    fi
    if [[ ! -d "${IRONFOX_ANDROID_SDK}/build-tools/35.0.0" ]]; then
        mkdir -p "${IRONFOX_ANDROID_SDK}/build-tools"
        ln -s "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${IRONFOX_ANDROID_SDK}/build-tools/35.0.0"
    fi

    # Create Android SDK Platform Tools symlink
    if [ ! -d "${IRONFOX_ANDROID_SDK}/platform-tools" ]; then
        ln -s "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${IRONFOX_ANDROID_SDK}/platform-tools"
    fi

    echo_green_text 'SUCCESS: Prepared Android SDK'
}

function prepare_as() {
    echo_red_text 'Preparing Application Services...'

    pushd "${IRONFOX_AS}"

    # Check patches
    if ! a-s_check_patches; then
        echo_red_text 'ERROR: Patch validation failed. Please check the patch files and try again.'
        exit 1
    fi

    # Apply patches
    a-s_apply_patches

    # Always use our Gradle wrapper with our Gradle flags/configuration
    localize_gradle

    # Break the dependency on older Rust
    "${IRONFOX_SED}" -i -e "s|channel = .*|channel = \""${RUST_VERSION}\""|g" "${IRONFOX_AS}/rust-toolchain.toml"

    # Disable debug
    "${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' "${IRONFOX_AS}/Cargo.toml"

    # Enable performance optimizations
    "${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" "${IRONFOX_AS}/Cargo.toml"
    "${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" "${IRONFOX_AS}/Cargo.toml"

    "${IRONFOX_SED}" -i -e '/NDK ez-install/,/^$/d' "${IRONFOX_AS}/libs/verify-android-ci-environment.sh"
    "${IRONFOX_SED}" -i -e '/content {/,/}/d' "${IRONFOX_AS}/build.gradle"

    # Replace undesired Maven repos (ex. Mozilla's) with mavenLocal
    localize_maven

    # No-op Nimbus (Experimentation)
    "${IRONFOX_SED}" -i -e 's|NimbusInterface.isLocalBuild() = .*|NimbusInterface.isLocalBuild() = true|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt"
    "${IRONFOX_SED}" -i -e 's|isFetchEnabled(): Boolean = .*|isFetchEnabled(): Boolean = false|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt"
    "${IRONFOX_SED}" -i -e 's|isFetchEnabled(): Boolean = .*|isFetchEnabled(): Boolean = false|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt"
    "${IRONFOX_SED}" -i -e 's/EXPERIMENT_COLLECTION_NAME = ".*"/EXPERIMENT_COLLECTION_NAME = ""/' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/Nimbus.kt"
    "${IRONFOX_SED}" -i 's|nimbus-mobile-experiments||g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/Nimbus.kt"

    # Remove default built-in search engines
    rm -vr "${IRONFOX_AS}"/components/remote_settings/dumps/main/attachments/search-config-icons/*

    # Remove Glean
    bash -x "${IRONFOX_SCRIPTS}/deglean.sh" 'as'

    # Nuke undesired Mozilla endpoints
    bash -x "${IRONFOX_SCRIPTS}/noop_mozilla_endpoints.sh" 'as'

    # Remove the 'regions' configs
    rm -v "${IRONFOX_AS}/components/remote_settings/dumps/main/regions.json"
    rm -vr "${IRONFOX_AS}/components/remote_settings/dumps/main/attachments/regions"
    "${IRONFOX_SED}" -i -e 's|("main", "regions"),|// ("main", "regions"),|g' "${IRONFOX_AS}/components/remote_settings/src/client.rs"

    # Remove the 'search telemetry' config
    rm -v "${IRONFOX_AS}/components/remote_settings/dumps/main/search-telemetry-v2.json"
    "${IRONFOX_SED}" -i -e 's|("main", "search-telemetry-v2"),|// ("main", "search-telemetry-v2"),|g' "${IRONFOX_AS}/components/remote_settings/src/client.rs"

    # Remove the Mozilla Ads Client library
    "${IRONFOX_SED}" -i 's|"components/ads-client"|# "components/ads-client"|g' "${IRONFOX_AS}/Cargo.toml"
    "${IRONFOX_SED}" -i 's|ads-client|# ads-client|g' "${IRONFOX_AS}/megazords/full/Cargo.toml"

    # Remove the Crash Reporter test library
    "${IRONFOX_SED}" -i 's|"components/crashtest"|# "components/crashtest"|g' "${IRONFOX_AS}/Cargo.toml"
    "${IRONFOX_SED}" -i 's|crashtest|# crashtest|g' "${IRONFOX_AS}/megazords/full/Cargo.toml"

    # Remove the Rust Error support library
    ## Used for telemetry/error reporting, depends on Glean
    "${IRONFOX_SED}" -i 's|"components/support/error|# "components/support/error|g' "${IRONFOX_AS}/Cargo.toml"
    "${IRONFOX_SED}" -i 's|error-support|# error-support|g' "${IRONFOX_AS}/megazords/full/Cargo.toml"

    # Apply Application Services overlay
    apply_overlay "${IRONFOX_AS_OVERLAY}/"

    popd

    echo_green_text 'SUCCESS: Prepared Application Services'
}

function prepare_bundletool() {
    echo_red_text 'Preparing Bundletool...'

    pushd "${IRONFOX_BUNDLETOOL_DIR}"

    # Always use our Gradle wrapper with our Gradle flags/configuration
    localize_gradle

    # Replace undesired Maven repos (ex. Mozilla's) with mavenLocal
    localize_maven

    popd

    echo_green_text 'SUCCESS: Prepared Bundletool'
}

function prepare_fenix() {
    echo_red_text 'Preparing Fenix...'

    mkdir -p "${IRONFOX_BUILD}/tmp/fenix/app/src/main/res"
    mkdir -p "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/values"
    mkdir -p "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/xml"

    pushd "${IRONFOX_FENIX}"

    # Set-up the app ID, version name and version code
    "${IRONFOX_SED}" -i \
        -e 's|applicationId "org.mozilla"|applicationId "org.ironfoxoss"|' \
        -e 's|"sharedUserId": "org.mozilla.firefox.sharedID"|"sharedUserId": "org.ironfoxoss.ironfox.sharedID"|' \
        -e "s/Config.releaseVersionName(project)/'${IRONFOX_VERSION}'/" \
        "${IRONFOX_FENIX}/app/build.gradle"

    # Disable crash reporting
    "${IRONFOX_SED}" -i -e '/CRASH_REPORTING/s/true/false/' "${IRONFOX_FENIX}/app/build.gradle"

    # Disable Pocket "Discover More Stories"
    "${IRONFOX_SED}" -i -e 's|DISCOVER_MORE_STORIES = .*|DISCOVER_MORE_STORIES = false|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/FeatureFlags.kt"

    # Disable telemetry
    "${IRONFOX_SED}" -i -e 's|Telemetry enabled: " + .*)|Telemetry enabled: " + false)|g' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i -e '/TELEMETRY/s/true/false/' "${IRONFOX_FENIX}/app/build.gradle"

    # Enable Firefox Labs
    "${IRONFOX_SED}" -i -e 's|FIREFOX_LABS = .*|FIREFOX_LABS = true|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/FeatureFlags.kt"

    # Ensure onboarding is always enabled
    "${IRONFOX_SED}" -i -e 's|onboardingFeatureEnabled = .*|onboardingFeatureEnabled = true|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/FeatureFlags.kt"

    # No-op AMO collections/recommendations
    "${IRONFOX_SED}" -i -e 's|"AMO_COLLECTION_NAME", "\\".*\\""|"AMO_COLLECTION_NAME", "\\"\\""|g' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i 's|Extensions-for-Android||g' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i -e 's|"AMO_COLLECTION_USER", "\\".*\\""|"AMO_COLLECTION_USER", "\\"\\""|g' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i -e 's|"AMO_SERVER_URL", "\\".*\\""|"AMO_SERVER_URL", "\\"\\""|g' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i -e 's|customExtensionCollectionFeature = .*|customExtensionCollectionFeature = false|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/FeatureFlags.kt"

    # No-op Glean
    "${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' "${IRONFOX_FENIX}/app/pings.yaml"
    "${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' "${IRONFOX_FENIX}/app/pings.yaml"

    # No-op Nimbus (Experimentation)
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.ext.recordEventInNimbus|// import org.mozilla.fenix.ext.recordEventInNimbus|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt"
    "${IRONFOX_SED}" -i -e 's|context.recordEventInNimbus|// context.recordEventInNimbus|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt"
    "${IRONFOX_SED}" -i -e 's|FxNimbus.features.junoOnboarding.recordExposure|// FxNimbus.features.junoOnboarding.recordExposure|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/utils/Settings.kt"

    # No-op search telemetry
    "${IRONFOX_SED}" -i 's|search-telemetry-v2||g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/Core.kt"

    # Remove unused media
    ## Based on Tor Browser: https://gitlab.torproject.org/tpo/applications/tor-browser/-/commit/264dc7cd915e75ba9db3a27e09253acffe3f2311
    ## This should help reduce our APK sizes...
    rm -v "${IRONFOX_FENIX}/app/src/main/ic_launcher_private-web.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/ic_launcher-web.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_launcher_foreground.xml"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_launcher_monochrome.xml"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_onboarding_search_widget.xml"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_onboarding_sync.xml"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_wordmark_logo.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable/microsurvey_success.xml"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-hdpi/fenix_search_widget.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-hdpi/ic_logo_wordmark_normal.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-hdpi/ic_logo_wordmark_private.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-mdpi/ic_logo_wordmark_normal.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-mdpi/ic_logo_wordmark_private.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xhdpi/ic_logo_wordmark_normal.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xhdpi/ic_logo_wordmark_private.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xxhdpi/ic_logo_wordmark_normal.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xxhdpi/ic_logo_wordmark_private.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xxxhdpi/ic_logo_wordmark_normal.webp"
    rm -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xxxhdpi/ic_logo_wordmark_private.webp"
    "${IRONFOX_SED}" -i -e 's|R.drawable.microsurvey_success|R.drawable.fox_alert_crash_dark|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/microsurvey/ui/MicrosurveyCompleted.kt"
    "${IRONFOX_SED}" -i -e 's|R.drawable.ic_onboarding_sync|R.drawable.fox_alert_crash_dark|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/onboarding/redesign/view/OnboardingScreenRedesign.kt"
    "${IRONFOX_SED}" -i -e 's|R.drawable.ic_onboarding_sync|R.drawable.fox_alert_crash_dark|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/onboarding/view/OnboardingScreen.kt"
    "${IRONFOX_SED}" -i -e 's|ic_onboarding_search_widget|fox_alert_crash_dark|' "${IRONFOX_FENIX}/app/onboarding.fml.yaml"
    "${IRONFOX_SED}" -i -e 's|ic_onboarding_sync|fox_alert_crash_dark|' "${IRONFOX_FENIX}/app/onboarding.fml.yaml"

    # Remove unused telemetry and marketing services/components
    "${IRONFOX_SED}" -i -e 's|import mozilla.appservices.syncmanager.SyncTelemetry|// import mozilla.appservices.syncmanager.SyncTelemetry|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt"
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.downloads.listscreen.middleware.DownloadTelemetryMiddleware|// import org.mozilla.fenix.downloads.listscreen.middleware.DownloadTelemetryMiddleware|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt"
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.components.toolbar.BrowserToolbarTelemetryMiddleware|// import org.mozilla.fenix.components.toolbar.BrowserToolbarTelemetryMiddleware|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt"
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.home.toolbar.BrowserToolbarTelemetryMiddleware|// import org.mozilla.fenix.home.toolbar.BrowserToolbarTelemetryMiddleware|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt"
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.tabstray.TabsTrayTelemetryMiddleware|// import org.mozilla.fenix.tabstray.TabsTrayTelemetryMiddleware|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt"
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.webcompat.middleware.WebCompatReporterTelemetryMiddleware|// import org.mozilla.fenix.webcompat.middleware.WebCompatReporterTelemetryMiddleware|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt"

    "${IRONFOX_SED}" -i -e 's|BookmarksTelemetryMiddleware(|// BookmarksTelemetryMiddleware(|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/bookmarks/BookmarkFragment.kt"
    "${IRONFOX_SED}" -i -e 's|BrowserToolbarTelemetryMiddleware(|// BrowserToolbarTelemetryMiddleware(|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt"
    "${IRONFOX_SED}" -i -e 's|BrowserToolbarTelemetryMiddleware(|// BrowserToolbarTelemetryMiddleware(|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt"
    "${IRONFOX_SED}" -i -e 's|CustomReviewPromptTelemetryMiddleware(|// CustomReviewPromptTelemetryMiddleware(|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptBottomSheetFragment.kt"
    "${IRONFOX_SED}" -i -e 's|private fun provideTelemetryMiddleware|// private fun provideTelemetryMiddleware|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt"
    "${IRONFOX_SED}" -i -e 's|private fun provideTelemetryMiddleware|// private fun provideTelemetryMiddleware|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt"
    "${IRONFOX_SED}" -i -e 's|provideTelemetryMiddleware(|// provideTelemetryMiddleware(|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt"
    "${IRONFOX_SED}" -i -e 's|provideTelemetryMiddleware(|// provideTelemetryMiddleware(|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt"
    "${IRONFOX_SED}" -i -e 's|SyncTelemetry.|// SyncTelemetry.|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt"
    "${IRONFOX_SED}" -i -e 's|TabsTrayTelemetryMiddleware(|// TabsTrayTelemetryMiddleware(|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt"
    "${IRONFOX_SED}" -i -e 's|WebCompatReporterTelemetryMiddleware(|// WebCompatReporterTelemetryMiddleware(|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt"

    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/bookmarks/BookmarksTelemetryMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/ActivationPing.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/AdjustMetricsService.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/BreadcrumbsRecorder.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/Event.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/FirstSessionMetricsService.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanMetricsService.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReporting.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingApi.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingLifecycleObserver.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingMetricsService.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GrowthDataWorker.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/InstallReferrerMetricsService.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/InstallReferrerWorker.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MarketingAttributionService.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MetricController.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MetricsMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MetricsService.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MetricsStorage.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MozillaProductDetector.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/toolbar/BrowserToolbarTelemetryMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/crashes/CrashFactCollector.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/crashes/CrashReportingAppMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/crashes/NimbusExperimentDataProvider.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/crashes/ReleaseRuntimeTagProvider.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/downloads/listscreen/middleware/DownloadTelemetryMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/ext/Configuration.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/middleware/HomeTelemetryMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/PocketMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/toolbar/BrowserToolbarTelemetryMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/messaging/state/MessagingMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptTelemetryMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/reviewprompt/ReviewPromptMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/tabstray/TabsTrayTelemetryMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/telemetry/TelemetryMiddleware.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/middleware/WebCompatReporterTelemetryMiddleware.kt"
    rm -vr "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/fonts"
    rm -vr "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/datachoices"
    rm -vr "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/startupCrash"

    # Remove MARS components
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/Ads.kt"
    rm -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/TopSitesRefresher.kt"

    # Remove Glean
    bash -x "${IRONFOX_SCRIPTS}/deglean.sh" 'fenix'

    # Nuke undesired Mozilla endpoints
    bash -x "${IRONFOX_SCRIPTS}/noop_mozilla_endpoints.sh" 'fenix'

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
        "${IRONFOX_FENIX}"/app/src/*/res/values*/*strings.xml

    # Replace instances of "Firefox" with "IronFox" or "IronFox Nightly"
    ## Also ensure that Firefox Suggest isn't incorrectly labeled as "IronFox Suggest",
    ## because Firefox Suggest suggestions are provided by Mozilla, not us, and
    ## ensure text states to sign-in to a "Firefox-based web browser" instead of "IronFox" on desktop
    "${IRONFOX_SED}" -i \
        -e 's/Firefox Fenix/{IRONFOX_NAME}/; s/Mozilla Firefox/{IRONFOX_NAME}/; s/Firefox/{IRONFOX_NAME}/g' \
        -e 's/{IRONFOX_NAME} Suggest/Firefox Suggest/' \
        -e 's/On your computer open {IRONFOX_NAME} and/On your computer, open a Firefox-based web browser, and/' \
        -e 's/To send a tab, sign in to {IRONFOX_NAME}/To send a tab, sign in to a Firefox-based web browser/' \
        "${IRONFOX_FENIX}"/app/src/*/res/values*/*strings.xml

    # Refer to "account" as "Firefox account" and "Sync" as "Firefox Sync"
    ## This makes it clear that these are third-party services, not operated by us
    ## (We need to set these last to ensure that "Firefox" here is not replaced with
    ##  "IronFox" or "IronFox Nightly")
    "${IRONFOX_SED}" -i \
        -e 's/Learn more about sync/Learn more about Firefox Sync/' \
        -e 's/No account?/No Firefox account?/' \
        -e 's/Sync is on/Firefox Sync is on/' \
        -e 's/%s will stop syncing with your account/%s will stop syncing with your Firefox account/' \
        "${IRONFOX_FENIX}"/app/src/*/res/values*/*strings.xml

    "${IRONFOX_SED}" -i -e 's|FENIX_PLAY_STORE_URL = ".*"|FENIX_PLAY_STORE_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"
    "${IRONFOX_SED}" -i -e 's|GOOGLE_URL = ".*"|GOOGLE_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"
    "${IRONFOX_SED}" -i -e 's|GOOGLE_US_URL = ".*"|GOOGLE_US_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"
    "${IRONFOX_SED}" -i -e 's|GOOGLE_XX_URL = ".*"|GOOGLE_XX_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"
    "${IRONFOX_SED}" -i -e 's|RATE_APP_URL = ".*"|RATE_APP_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"

    "${IRONFOX_SED}" -i -e 's|ANDROID_SUPPORT_SUMO_URL = ".*"|ANDROID_SUPPORT_SUMO_URL = "https://ironfoxoss.org/docs/faq/"|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"
    "${IRONFOX_SED}" -i -e 's|WHATS_NEW_URL = ".*"|WHATS_NEW_URL = "https://gitlab.com/ironfox-oss/IronFox/-/releases"|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"
    "${IRONFOX_SED}" -i 's|mzl.la/AndroidSupport|https://ironfoxoss.org/docs/faq/|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"
    "${IRONFOX_SED}" -i 's|https://www.mozilla.org/firefox/android/notes|https://gitlab.com/ironfox-oss/IronFox/-/releases|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt"

    # Replace proprietary artwork
    rm -v "${IRONFOX_FENIX}/app/src/release/res/drawable/ic_launcher_foreground.xml"
    rm -v "${IRONFOX_FENIX}"/app/src/release/res/mipmap-*/ic_launcher.webp
    rm -v "${IRONFOX_FENIX}/app/src/release/res/values/colors.xml"
    "${IRONFOX_SED}" -i -e '/android:roundIcon/d' "${IRONFOX_FENIX}/app/src/main/AndroidManifest.xml"
    "${IRONFOX_SED}" -i -e '/SplashScreen/,+5d' "${IRONFOX_FENIX}/app/src/main/res/values-v27/styles.xml"
    mkdir -vp "${IRONFOX_FENIX}/app/src/release/res/mipmap-anydpi-v26"
    "${IRONFOX_SED}" -i \
        -e 's/googleg_standard_color_18/ic_download/' \
        "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/menu/compose/MenuItem.kt" \
        "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/compose/list/ListItem.kt"

    # Remove default built-in search engines
    rm -vr "${IRONFOX_FENIX}/app/src/main/assets/searchplugins"/*

    # Display proper name and description for wallpaper collection
    "${IRONFOX_SED}" -i -e 's|R.string.wallpaper_artist_series_title|R.string.wallpaper_collection_fennec|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/wallpaper/WallpaperSettings.kt"
    "${IRONFOX_SED}" -i -e 's|R.string.wallpaper_artist_series_description_with_learn_more|R.string.wallpaper_collection_fennec_description|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/wallpaper/WallpaperSettings.kt"

    # Apply Fenix overlay
    apply_overlay "${IRONFOX_FENIX_OVERLAY}/"

    # Apply UnifiedPush-AC overlay (for Fenix)
    apply_overlay "${IRONFOX_UP_AC}/fenix-overlay/"

    ## The following are for the build script, so that it can update the environment variables if needed
    ### (ex. if the user changes them)
    if [[ -f "${IRONFOX_BUILD}/tmp/fenix/app/build.gradle" ]]; then
        rm -f "${IRONFOX_BUILD}/tmp/fenix/app/build.gradle"
    fi
    cp -f "${IRONFOX_FENIX}/app/build.gradle" "${IRONFOX_BUILD}/tmp/fenix/app/build.gradle"

    if [[ -f "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/values/static_strings.xml" ]]; then
        rm -f "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/values/static_strings.xml"
    fi
    cp -f "${IRONFOX_FENIX}/app/src/release/res/values/static_strings.xml" "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/values/static_strings.xml"

    if [[ -f "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/xml/shortcuts.xml" ]]; then
        rm -f "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/xml/shortcuts.xml"
    fi
    cp -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml" "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/xml/shortcuts.xml"

    if [[ -d "${IRONFOX_BUILD}/tmp/fenix/app/src/main/res" ]]; then
        rm -rf "${IRONFOX_BUILD}/tmp/fenix/app/src/main/res"
    fi
    cp -rf "${IRONFOX_FENIX}/app/src/main/res/" "${IRONFOX_BUILD}/tmp/fenix/app/src/main/res/"

    popd

    echo_green_text 'SUCCESS: Prepared Fenix'
}

function prepare_firefox() {
    echo_red_text 'Preparing Firefox...'

    mkdir -p "${IRONFOX_BUILD}/tmp/gecko/ironfox"
    mkdir -p "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages"
    mkdir -p "${IRONFOX_MOZBUILD}"
 
    ## Copy machrc config
    cp -f "${IRONFOX_CONFIGS}/mach/machrc" "${IRONFOX_MOZBUILD}/machrc"

    pushd "${IRONFOX_GECKO}"

    # Check patches
    if ! check_patches; then
        echo_red_text 'ERROR: Patch validation failed. Please check the patch files and try again.'
        exit 1
    fi

    ## For UnifiedPush-AC
    if ! up_ac_check_patches; then
        echo_red_text 'ERROR: Patch validation failed. Please check the patch files and try again.'
        exit 1
    fi

    # Apply patches
    apply_patches

    ## For UnifiedPush-AC
    up_ac_apply_patches

    # Always use our Gradle wrapper with our Gradle flags/configuration
    localize_gradle

    # Let it be IronFox (part 2...)
    "${IRONFOX_SED}" -i -e 's|"MOZ_APP_VENDOR", ".*"|"MOZ_APP_VENDOR", "IronFox OSS"|g' "${IRONFOX_GECKO}/mobile/android/moz.configure"
    echo '' >>"${IRONFOX_GECKO}/mobile/android/moz.configure"
    echo 'include("../../ironfox/ironfox.configure")' >>"${IRONFOX_GECKO}/mobile/android/moz.configure"
    echo '' >>"${IRONFOX_GECKO}/moz.build"
    echo 'DIRS += ["ironfox"]' >>"${IRONFOX_GECKO}/moz.build"

    # Replace instances of "Firefox" with "IronFox" or "IronFox Nightly"
    "${IRONFOX_SED}" -i -e 's/Firefox/{IRONFOX_NAME}/' "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html"
    "${IRONFOX_SED}" -i -e 's/Firefox/{IRONFOX_NAME}/' "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html"

    # Use `commit` instead of `rev` for source URL
    ## (ex. displayed at `about:buildconfig`)
    "${IRONFOX_SED}" -i 's|/rev/|/commit/|' "${IRONFOX_GECKO}/build/variables.py"

    # about: pages
    echo '' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"
    echo '@BINPATH@/chrome/browser@JAREXT@' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"
    echo '@BINPATH@/chrome/browser.manifest' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"
    echo '' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"
    echo '@BINPATH@/chrome/ironfox@JAREXT@' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"
    echo '@BINPATH@/chrome/ironfox.manifest' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"
    echo '' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"
    echo '@BINPATH@/defaults/autoconfig/ironfox.cfg' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"
    echo '@BINPATH@/defaults/policies.json' >>"${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"

    # about:policies
    mkdir -vp "${IRONFOX_GECKO}/ironfox/locales/en-US/browser/policies"
    cp -vf browser/locales/en-US/browser/aboutPolicies.ftl "${IRONFOX_GECKO}/ironfox/locales/en-US/browser/"
    cp -vf browser/locales/en-US/browser/policies/policies-descriptions.ftl "${IRONFOX_GECKO}/ironfox/locales/en-US/browser/policies/"

    # about:robots
    mkdir -vp "${IRONFOX_GECKO}/ironfox/about/browser/robots"
    cp -vf browser/base/content/aboutRobots.css "${IRONFOX_GECKO}/ironfox/about/browser/robots/"
    cp -vf browser/base/content/aboutRobots.js "${IRONFOX_GECKO}/ironfox/about/browser/robots/"
    cp -vf browser/base/content/aboutRobots.xhtml "${IRONFOX_GECKO}/ironfox/about/browser/robots/"
    cp -vf browser/base/content/aboutRobots-icon.png "${IRONFOX_GECKO}/ironfox/about/browser/robots/"
    cp -vf browser/base/content/robot.ico "${IRONFOX_GECKO}/ironfox/about/browser/robots/"
    cp -vf browser/base/content/static-robot.png "${IRONFOX_GECKO}/ironfox/about/browser/robots/"
    cp -vf browser/locales/en-US/browser/aboutRobots.ftl "${IRONFOX_GECKO}/ironfox/locales/en-US/browser/"

    # Ensure we're building for release
    "${IRONFOX_SED}" -i -e 's/variant=variant(.*)/variant=variant("release")/' "${IRONFOX_GECKO}/mobile/android/gradle.configure"

    # Fix v125 aar output not including native libraries
    "${IRONFOX_SED}" -i \
        -e "s/singleVariant('debug')/singleVariant('release')/" \
        "${IRONFOX_GECKO}/mobile/android/geckoview/build.gradle"

    # Fail on use of prebuilt nimbus-fml
    "${IRONFOX_SED}" -i 's|https://|hxxps://|' "${IRONFOX_GECKO}/mobile/android/gradle/plugins/nimbus-gradle-plugin/src/main/kotlin/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.kt"

    # Break the dependency on older Rust
    "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_VERSION}\""|g" "${IRONFOX_GECKO}/Cargo.toml"
    "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" "${IRONFOX_GECKO}/intl/icu_capi/Cargo.toml"
    "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" "${IRONFOX_GECKO}/intl/icu_segmenter_data/Cargo.toml"

    # Disable debug
    "${IRONFOX_SED}" -i -e 's|debug-assertions = .*|debug-assertions = false|g' "${IRONFOX_GECKO}/Cargo.toml"
    "${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' "${IRONFOX_GECKO}/gfx/harfbuzz/src/rust/Cargo.toml"
    "${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' "${IRONFOX_GECKO}/gfx/wr/Cargo.toml"

    # Enable overflow checks
    "${IRONFOX_SED}" -i -e 's|overflow-checks = .*|overflow-checks = true|g' "${IRONFOX_GECKO}/gfx/harfbuzz/src/rust/Cargo.toml"

    # Enable performance optimizations
    "${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" "${IRONFOX_GECKO}/Cargo.toml"
    "${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" "${IRONFOX_GECKO}/Cargo.toml"
    "${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" "${IRONFOX_GECKO}/gfx/wr/Cargo.toml"

    # Disable Normandy (Experimentation)
    "${IRONFOX_SED}" -i -e 's|"MOZ_NORMANDY", .*)|"MOZ_NORMANDY", False)|g' "${IRONFOX_GECKO}/mobile/android/moz.configure"

    # Disable SSLKEYLOGGING
    ## https://bugzilla.mozilla.org/show_bug.cgi?id=1183318
    ## https://bugzilla.mozilla.org/show_bug.cgi?id=1915224
    "${IRONFOX_SED}" -i -e 's|NSS_ALLOW_SSLKEYLOGFILE ?= .*|NSS_ALLOW_SSLKEYLOGFILE ?= 0|g' "${IRONFOX_GECKO}/security/nss/lib/ssl/Makefile"
    echo '' >>"${IRONFOX_GECKO}/security/moz.build"
    echo 'gyp_vars["enable_sslkeylogfile"] = 0' >>"${IRONFOX_GECKO}/security/moz.build"

    # Disable telemetry
    "${IRONFOX_SED}" -i -e 's|"MOZ_SERVICES_HEALTHREPORT", .*)|"MOZ_SERVICES_HEALTHREPORT", False)|g' "${IRONFOX_GECKO}/mobile/android/moz.configure"

    # Ensure UA is always set to Firefox
    "${IRONFOX_SED}" -i -e 's|"MOZ_APP_UA_NAME", ".*"|"MOZ_APP_UA_NAME", "Firefox"|g' "${IRONFOX_GECKO}/mobile/android/moz.configure"

    # Include additional Remote Settings local dumps (+ add our own...)
    "${IRONFOX_SED}" -i -e 's|"mobile/"|"0"|g' "${IRONFOX_GECKO}/services/settings/dumps/blocklists/moz.build"
    "${IRONFOX_SED}" -i -e 's|"mobile/"|"0"|g' "${IRONFOX_GECKO}/services/settings/dumps/security-state/moz.build"
    echo '' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo 'FINAL_TARGET_FILES.defaults.settings.main += [' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo '    "anti-tracking-url-decoration.json",' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo '    "cookie-banner-rules-list.json",' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo '    "hijack-blocklists.json",' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo '    "translations-models.json",' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo '    "translations-wasm.json",' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo '    "url-classifier-skip-urls.json",' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo '    "url-parser-default-unknown-schemes-interventions.json",' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"
    echo ']' >>"${IRONFOX_GECKO}/services/settings/dumps/main/moz.build"

    # Remove unused about:glean assets
    rm -v "${IRONFOX_GECKO}/toolkit/content/aboutGlean.css" "${IRONFOX_GECKO}/toolkit/content/aboutGlean.js" "${IRONFOX_GECKO}/toolkit/content/aboutGlean.html"

    # Remove unused about:restricted (Used for parental controls) assets
    rm -vr "${IRONFOX_GECKO}/toolkit/content/aboutRestricted"

    # Remove unused about:telemetry assets
    rm -v "${IRONFOX_GECKO}/toolkit/content/aboutTelemetry.css" "${IRONFOX_GECKO}/toolkit/content/aboutTelemetry.js" "${IRONFOX_GECKO}/toolkit/content/aboutTelemetry.xhtml"

    # Remove unused localizations
    "${IRONFOX_SED}" -i 's|locale/@AB_CD@/global/aboutStudies|# locale/@AB_CD@/global/aboutStudies|' "${IRONFOX_GECKO}/toolkit/locales/jar.mn"
    "${IRONFOX_SED}" -i 's|crashreporter|# crashreporter|' "${IRONFOX_GECKO}/toolkit/locales/jar.mn"
    "${IRONFOX_SED}" -i 's|locales-preview/aboutRestricted|# locales-preview/aboutRestricted|' "${IRONFOX_GECKO}/toolkit/locales/jar.mn"
    rm -vr "${IRONFOX_GECKO}/toolkit/locales/en-US/crashreporter"
    rm -v "${IRONFOX_GECKO}/toolkit/locales/en-US/toolkit/about/aboutGlean.ftl"
    rm -v "${IRONFOX_GECKO}/toolkit/locales/en-US/toolkit/about/aboutTelemetry.ftl"
    rm -v "${IRONFOX_GECKO}/toolkit/locales-preview/aboutRestricted.ftl"

    # Prevent registration of the Glean add-on ping scheduler
    "${IRONFOX_SED}" -i 's|category update-timer amGleanDaily|# category update-timer amGleanDaily|' "${IRONFOX_GECKO}/toolkit/mozapps/extensions/extensions.manifest"

    # Remove the Clear Key CDM
    "${IRONFOX_SED}" -i 's|@BINPATH@/@DLL_PREFIX@clearkey|; @BINPATH@/@DLL_PREFIX@clearkey|' "${IRONFOX_GECKO}/mobile/android/installer/package-manifest.in"

    # Remove GMP sources
    rm -vr "${IRONFOX_GECKO}/toolkit/content/gmp-sources"

    # Remove Claude integration
    ## (Necessary for those with IDEs that may try to parse/use this functionality)
    rm -v "${IRONFOX_GECKO}/.mcp.json"
    rm -v "${IRONFOX_GECKO}/AGENTS.md"
    rm -v "${IRONFOX_GECKO}/CLAUDE.md"
    rm -vr "${IRONFOX_GECKO}/.claude"
    rm -vr "${IRONFOX_GECKO}/.codex"

    # Remove OpenAI components
    rm -v "${IRONFOX_GECKO}/toolkit/components/ml/content/backends/OpenAIPipeline.mjs"
    rm -vr "${IRONFOX_GECKO}/toolkit/components/ml/vendor/openai"

    # No-op RemoteSettingsCrashPull
    "${IRONFOX_SED}" -i 's|crash-reports-ondemand||g' "${IRONFOX_GECKO}/toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs"
    "${IRONFOX_SED}" -i -e 's/REMOTE_SETTINGS_CRASH_COLLECTION = ".*"/REMOTE_SETTINGS_CRASH_COLLECTION = ""/' "${IRONFOX_GECKO}/toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs"

    # No-op Normandy (Experimentation)
    "${IRONFOX_SED}" -i -e 's/REMOTE_SETTINGS_COLLECTION = ".*"/REMOTE_SETTINGS_COLLECTION = ""/' "${IRONFOX_GECKO}/toolkit/components/normandy/lib/RecipeRunner.sys.mjs"
    "${IRONFOX_SED}" -i 's|normandy-recipes-capabilities||g' "${IRONFOX_GECKO}/toolkit/components/normandy/lib/RecipeRunner.sys.mjs"

    # No-op Nimbus (Experimentation) (Gecko)
    ## (Primarily for defense in depth)
    "${IRONFOX_SED}" -i -e 's/COLLECTION_ID_FALLBACK = ".*"/COLLECTION_ID_FALLBACK = ""/' "${IRONFOX_GECKO}/toolkit/components/nimbus/ExperimentAPI.sys.mjs"
    "${IRONFOX_SED}" -i -e 's/COLLECTION_ID_FALLBACK = ".*"/COLLECTION_ID_FALLBACK = ""/' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs"
    "${IRONFOX_SED}" -i -e 's/EXPERIMENTS_COLLECTION = ".*"/EXPERIMENTS_COLLECTION = ""/' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs"
    "${IRONFOX_SED}" -i -e 's/SECURE_EXPERIMENTS_COLLECTION = ".*"/SECURE_EXPERIMENTS_COLLECTION = ""/' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs"
    "${IRONFOX_SED}" -i -e 's/SECURE_EXPERIMENTS_COLLECTION_ID = ".*"/SECURE_EXPERIMENTS_COLLECTION_ID = ""/' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs"
    "${IRONFOX_SED}" -i 's|nimbus-desktop-experiments||g' "${IRONFOX_GECKO}/toolkit/components/nimbus/ExperimentAPI.sys.mjs"
    "${IRONFOX_SED}" -i 's|nimbus-desktop-experiments||g' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs"
    "${IRONFOX_SED}" -i 's|nimbus-secure-experiments||g' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs"

    # No-op telemetry (Gecko)
    "${IRONFOX_SED}" -i -e '/enable_internal_pings:/s/true/false/' "${IRONFOX_GECKO}/toolkit/components/glean/src/init/mod.rs"
    "${IRONFOX_SED}" -i -e '/upload_enabled =/s/true/false/' "${IRONFOX_GECKO}/toolkit/components/glean/src/init/mod.rs"
    "${IRONFOX_SED}" -i -e '/use_core_mps:/s/true/false/' "${IRONFOX_GECKO}/toolkit/components/glean/src/init/mod.rs"
    "${IRONFOX_SED}" -i -e 's/usageDeletionRequest.setEnabled(.*)/usageDeletionRequest.setEnabled(false)/' "${IRONFOX_GECKO}/toolkit/components/telemetry/app/UsageReporting.sys.mjs"
    "${IRONFOX_SED}" -i -e 's|useTelemetry = .*|useTelemetry = false;|g' "${IRONFOX_GECKO}/toolkit/components/telemetry/core/Telemetry.cpp"
    "${IRONFOX_SED}" -i '/# This must remain last./i gkrust_features += ["glean_disable_upload"]\n' "${IRONFOX_GECKO}/toolkit/library/rust/gkrust-features.mozbuild"

    "${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' "${IRONFOX_GECKO}/toolkit/components/glean/pings.yaml"
    "${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' "${IRONFOX_GECKO}/toolkit/components/glean/pings.yaml"
    "${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' "${IRONFOX_GECKO}/toolkit/components/nimbus/pings.yaml"
    "${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' "${IRONFOX_GECKO}/toolkit/components/nimbus/pings.yaml"

    # Prevent DoH canary requests
    "${IRONFOX_SED}" -i -e 's/GLOBAL_CANARY = ".*"/GLOBAL_CANARY = ""/' "${IRONFOX_GECKO}/toolkit/components/doh/DoHHeuristics.sys.mjs"
    "${IRONFOX_SED}" -i -e 's/ZSCALER_CANARY = ".*"/ZSCALER_CANARY = ""/' "${IRONFOX_GECKO}/toolkit/components/doh/DoHHeuristics.sys.mjs"

    # Prevent DoH remote config/rollout
    "${IRONFOX_SED}" -i -e 's/RemoteSettings(".*"/RemoteSettings(""/' "${IRONFOX_GECKO}/toolkit/components/doh/DoHConfig.sys.mjs"
    "${IRONFOX_SED}" -i -e 's/kConfigCollectionKey = ".*"/kConfigCollectionKey = ""/' "${IRONFOX_GECKO}/toolkit/components/doh/DoHTestUtils.sys.mjs"
    "${IRONFOX_SED}" -i -e 's/kProviderCollectionKey = ".*"/kProviderCollectionKey = ""/' "${IRONFOX_GECKO}/toolkit/components/doh/DoHTestUtils.sys.mjs"
    "${IRONFOX_SED}" -i 's|"doh-config"||g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHConfig.sys.mjs"
    "${IRONFOX_SED}" -i 's|"doh-providers"||g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHConfig.sys.mjs"
    "${IRONFOX_SED}" -i 's|"doh-config"||g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHTestUtils.sys.mjs"
    "${IRONFOX_SED}" -i 's|"doh-providers"||g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHTestUtils.sys.mjs"

    # Remove DoH config/rollout local dumps
    "${IRONFOX_SED}" -i -e 's|"doh-config.json"|# "doh-config.json"|g' "${IRONFOX_GECKO}/services/settings/static-dumps/main/moz.build"
    "${IRONFOX_SED}" -i -e 's|"doh-providers.json"|# "doh-providers.json"|g' "${IRONFOX_GECKO}/services/settings/static-dumps/main/moz.build"
    rm -vf services/settings/static-dumps/main/doh-config.json "${IRONFOX_GECKO}/services/settings/static-dumps/main/doh-providers.json"

    # Remove example dependencies
    ## Also see `gecko-remove-example-dependencies.patch`
    "${IRONFOX_SED}" -i "s|include ':annotations', .*|include ':annotations'|g" "${IRONFOX_GECKO}/settings.gradle"
    "${IRONFOX_SED}" -i "s|project(':messaging_example'|// project(':messaging_example'|g" "${IRONFOX_GECKO}/settings.gradle"
    "${IRONFOX_SED}" -i "s|project(':port_messaging_example'|// project(':port_messaging_example'|g" "${IRONFOX_GECKO}/settings.gradle"
    "${IRONFOX_SED}" -i -e 's#if (rootDir.toString().contains("android-components") || !project.key.startsWith("samples"))#if (!project.key.startsWith("samples"))#' "${IRONFOX_GECKO}/mobile/android/shared-settings.gradle"

    # Remove ExoPlayer
    "${IRONFOX_SED}" -i "s|include ':exoplayer2'|// include ':exoplayer2'|g" "${IRONFOX_GECKO}/settings.gradle"
    "${IRONFOX_SED}" -i "s|project(':exoplayer2'|// project(':exoplayer2'|g" "${IRONFOX_GECKO}/settings.gradle"

    # Remove proprietary/tracking libraries
    "${IRONFOX_SED}" -i 's|adjust|# adjust|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml"
    "${IRONFOX_SED}" -i 's|firebase-messaging|# firebase-messaging|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml"
    "${IRONFOX_SED}" -i 's|installreferrer|# installreferrer|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml"
    "${IRONFOX_SED}" -i 's|kotlinx-coroutines-play-services|# kotlinx-coroutines-play-services|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml"
    "${IRONFOX_SED}" -i 's|play-integrity|# play-integrity|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml"
    "${IRONFOX_SED}" -i 's|play-review|# play-review|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml"
    "${IRONFOX_SED}" -i 's|play-services-|# play-services-|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml"
    "${IRONFOX_SED}" -i 's|sentry|# sentry|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml"

    # Remove Glean
    bash -x "${IRONFOX_SCRIPTS}/deglean.sh" 'firefox'

    # Nuke undesired Mozilla endpoints
    bash -x "${IRONFOX_SCRIPTS}/noop_mozilla_endpoints.sh" 'firefox'

    # Take back control of preferences
    ## This prevents GeckoView from overriding the follow prefs at runtime, which also means we don't have to worry about Nimbus overriding them, etc...
    ## The prefs will instead take the values we specify in the phoenix/ironfox .js files, and users will also be able to override them via the `about:config`
    ## This is ideal for features that aren't exposed by the UI, it gives more freedom/control back to users, and it's great to ensure things are always configured how we want them...
    "${IRONFOX_SED}" -i \
        -e 's|"browser.contentblocking.category"|"z99.ignore.string"|' \
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
        -e 's|"privacy.trackingprotection.harmfuladdon.enabled"|"z99.ignore.boolean"|' \
        -e 's|"privacy.trackingprotection.socialtracking.enabled"|"z99.ignore.boolean"|' \
        -e 's|"urlclassifier.features.cryptomining.blacklistTables"|"z99.ignore.string"|' \
        -e 's|"urlclassifier.features.emailtracking.blocklistTables"|"z99.ignore.string"|' \
        -e 's|"urlclassifier.features.fingerprinting.blacklistTables"|"z99.ignore.string"|' \
        -e 's|"urlclassifier.features.harmfuladdon.blocklistTables"|"z99.ignore.string"|' \
        -e 's|"urlclassifier.features.socialtracking.annotate.blacklistTables"|"z99.ignore.string"|' \
        -e 's|"urlclassifier.malwareTable"|"z99.ignore.string"|' \
        -e 's|"urlclassifier.phishTable"|"z99.ignore.string"|' \
        -e 's|"urlclassifier.trackingTable"|"z99.ignore.string"|' \
        "${IRONFOX_GECKO}/mobile/android/geckoview/src/main/java/org/mozilla/geckoview/ContentBlocking.java"

    "${IRONFOX_SED}" -i \
        -e 's|"apz.allow_double_tap_zooming"|"z99.ignore.boolean"|' \
        -e 's|"browser.crashReports.requestedNeverShowAgain"|"z99.ignore.boolean"|' \
        -e 's|"browser.display.use_document_fonts"|"z99.ignore.integer"|' \
        -e 's|"devtools.debugger.remote-enabled"|"z99.ignore.boolean"|' \
        -e 's|"devtools.console.stdout.chrome"|"z99.ignore.boolean"|' \
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
        -e 's|"network.trr.default_provider_uri"|"z99.ignore.string"|' \
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
        "${IRONFOX_GECKO}/mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntimeSettings.java"

    # Fail on use of prebuilt binary
    "${IRONFOX_SED}" -i 's|https://github.com|hxxps://github.com|' "${IRONFOX_GECKO}/python/mozboot/mozboot/android.py"

    # Make the build system think we installed the emulator and an AVD
    mkdir -vp "${IRONFOX_ANDROID_SDK}/emulator"
    mkdir -vp "${IRONFOX_MOZBUILD}/android-device/avd"

    # Do not check the "emulator" utility which is obviously absent in the empty directory we created above
    "${IRONFOX_SED}" -i -e '/check_android_tools("emulator"/d' "${IRONFOX_GECKO}/build/moz.configure/android-sdk.configure"

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
        "${IRONFOX_GECKO}/mobile/android/app/geckoview-prefs.js"

    # Gecko prefs
    echo '' >>"${IRONFOX_GECKO}/mobile/android/app/geckoview-prefs.js"
    echo '#include ../../../ironfox/prefs/ironfox.js' >>"${IRONFOX_GECKO}/mobile/android/app/geckoview-prefs.js"

    # Apply Gecko overlay
    apply_overlay "${IRONFOX_GECKO_OVERLAY}/"

    ## The following are for the build script, so that it can update the environment variables if needed
    ### (ex. if the user changes them)
    if [[ -f "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages/connection-not-secure.html" ]]; then
        rm -f "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages/connection-not-secure.html"
    fi
    cp -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html" "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages/connection-not-secure.html"

    if [[ -f "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages/time-errors.html" ]]; then
        rm -f "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages/time-errors.html"
    fi
    cp -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html" "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages/time-errors.html"

    popd

    echo_green_text 'SUCCESS: Prepared Firefox'
}

function prepare_glean() {
    echo_red_text 'Preparing Glean...'

    mkdir -p "${IRONFOX_GLEAN_PYENV}/bootstrap-24.3.0-0"
    mkdir -p "${IRONFOX_BUILD}/tmp/glean"

    # Set Python symlinks so that Glean will use our Python environment, instead of attempting to create its own...
    if [[ ! -d "${IRONFOX_GLEAN_PYENV}/pythonenv" ]]; then
        ln -s "${IRONFOX_PYENV_DIR}" "${IRONFOX_GLEAN_PYENV}/pythonenv"
    fi

    if [[ ! -d "${IRONFOX_GLEAN_PYENV}/bootstrap-24.3.0-0/Miniconda3" ]]; then
        ln -s "${IRONFOX_PYENV_DIR}" "${IRONFOX_GLEAN_PYENV}/bootstrap-24.3.0-0/Miniconda3"
    fi

    # We currently remove Glean fully from Android Components (See `a-c-remove-glean.patch`) and Application Services (see `a-s-remove-glean.patch`). Unfortunately, it's currently untenable to remove Glean in its entirety from Fenix (though we do remove Mozilla's `Glean Service` library/implementation). So, our approach is to stub Glean for Fenix, which we can do thanks to Tor's no-op UniFFi binding generator, as well as our `fenix-remove-glean.patch` patch, and the commands below.
    ## https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/tree/main/projects/glean

    pushd "${IRONFOX_GLEAN}"

    # Check patches
    if ! glean_check_patches; then
        echo_red_text 'ERROR: Patch validation failed. Please check the patch files and try again.'
        exit 1
    fi

    # Apply patches
    glean_apply_patches

    # Always use our Gradle wrapper with our Gradle flags/configuration
    localize_gradle

    # Replace undesired Maven repos (ex. Mozilla's) with mavenLocal
    localize_maven

    # Break the dependency on older Rust
    "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" "${IRONFOX_GLEAN}/glean-core/Cargo.toml"
    "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" "${IRONFOX_GLEAN}/glean-core/build/Cargo.toml"
    "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${RUST_MAJOR_VERSION}\""|g" "${IRONFOX_GLEAN}/glean-core/rlb/Cargo.toml"

    # Disable debug
    "${IRONFOX_SED}" -i -e "s|debug = .*|debug = false|g" "${IRONFOX_GLEAN}/Cargo.toml"

    # Enable performance optimizations
    "${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" "${IRONFOX_GLEAN}/Cargo.toml"
    "${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" "${IRONFOX_GLEAN}/Cargo.toml"

    # Ensure that the Glean gradle plug-in/glean_parser always runs offline
    "${IRONFOX_SED}" -i "s|(isOffline)|(true)|" "${IRONFOX_GLEAN}/gradle-plugin/src/main/groovy/mozilla/telemetry/glean-gradle-plugin/GleanGradlePlugin.groovy"
    "${IRONFOX_SED}" -i "s|pypi.python.org|noop.invalid|" "${IRONFOX_GLEAN}/gradle-plugin/src/main/groovy/mozilla/telemetry/glean-gradle-plugin/GleanGradlePlugin.groovy"

    # No-op Glean
    "${IRONFOX_SED}" -i -e 's|allowGleanInternal = .*|allowGleanInternal = false|g' "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
    "${IRONFOX_SED}" -i -e '/minifyEnabled/s/false/true/' "${IRONFOX_GLEAN}/glean-core/android-native/build.gradle"
    "${IRONFOX_SED}" -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' "${IRONFOX_GLEAN}/glean-core/python/glean/config.py"
    "${IRONFOX_SED}" -i -e '/enable_internal_pings:/s/true/false/' "${IRONFOX_GLEAN}/glean-core/python/glean/config.py"
    "${IRONFOX_SED}" -i -e "s|DEFAULT_GLEAN_ENDPOINT: .*|DEFAULT_GLEAN_ENDPOINT: \&\str = \"\";|g" "${IRONFOX_GLEAN}/glean-core/rlb/src/configuration.rs"
    "${IRONFOX_SED}" -i -e '/enable_internal_pings:/s/true/false/' "${IRONFOX_GLEAN}/glean-core/rlb/src/configuration.rs"
    "${IRONFOX_SED}" -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt"
    "${IRONFOX_SED}" -i -e '/enableInternalPings:/s/true/false/' "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt"
    "${IRONFOX_SED}" -i -e '/enableEventTimestamps:/s/true/false/' "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt"
    "${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' "${IRONFOX_GLEAN}/glean-core/src/core_metrics.rs"
    "${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' "${IRONFOX_GLEAN}/glean-core/src/glean_metrics.rs"
    "${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' "${IRONFOX_GLEAN}/glean-core/src/internal_metrics.rs"
    "${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' "${IRONFOX_GLEAN}/glean-core/src/lib_unit_tests.rs"
    "${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' "${IRONFOX_GLEAN}/glean-core/pings.yaml"
    "${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' "${IRONFOX_GLEAN}/glean-core/pings.yaml"
    "${IRONFOX_SED}" -i -e 's|"$rootDir/glean-core/android/metrics.yaml"|// "$rootDir/glean-core/android/metrics.yaml"|g' "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
    rm -v "${IRONFOX_GLEAN}/glean-core/android/metrics.yaml"

    # Nuke undesired Mozilla endpoints
    bash -x "${IRONFOX_SCRIPTS}/noop_mozilla_endpoints.sh" 'glean'

    # Ensure we're building for release
    "${IRONFOX_SED}" -i -e 's|ext.cargoProfile = .*|ext.cargoProfile = "release"|g' "${IRONFOX_GLEAN}/build.gradle"

    # Set libxul location (for use with Tor's no-op UniFFi binding generator)
    if [[ "${IRONFOX_OS}" == 'osx' ]]; then
        "${IRONFOX_SED}" -i "s|{libxul_dir}|aarch64-linux-android/release|" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
    else
        "${IRONFOX_SED}" -i "s|{libxul_dir}|release|" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
    fi

    # Apply Glean overlay
    apply_overlay "${IRONFOX_GLEAN_OVERLAY}/"

    ## This is so the build script can set the uniffi path if needed (ex. if the user changes it)
    if [[ -f "${IRONFOX_BUILD}/tmp/glean/build.gradle" ]]; then
        rm -f "${IRONFOX_BUILD}/tmp/glean/build.gradle"
    fi
    cp -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle" "${IRONFOX_BUILD}/tmp/glean/build.gradle"

    popd

    echo_green_text 'SUCCESS: Prepared Glean'
}

function prepare_llvm() {
    echo_red_text 'Preparing LLVM...'

    if [[ -n "${FDROID_BUILD+x}" ]]; then
        # Patch the LLVM source code
        # Search clang- in https://android.googlesource.com/platform/ndk/+/refs/tags/ndk-r28b/ndk/toolchains.py
        readonly LLVM_SVN='530567'
        "${IRONFOX_PYTHON}" "${toolchain_utils}/llvm_tools/patch_manager.py" \
            --svn_version $LLVM_SVN \
            --patch_metadata_file "${llvm_android}/patches/PATCHES.json" \
            --src_path "${llvm}"
    fi

    echo_green_text 'SUCCESS: Prepared LLVM'
}

function prepare_microg() {
    echo_red_text 'Preparing microG...'

    pushd "${IRONFOX_GMSCORE}"

    # Always use our Gradle wrapper with our Gradle flags/configuration
    localize_gradle

    # Bump Android build tools
    "${IRONFOX_SED}" -i -e "s|ext.androidBuildVersionTools = .*|ext.androidBuildVersionTools = '${ANDROID_SDK_BUILD_TOOLS_VERSION_STRING}'|g" "${IRONFOX_GMSCORE}/build.gradle"

    # Bump Android compile SDK
    "${IRONFOX_SED}" -i -e "s|ext.androidCompileSdk = .*|ext.androidCompileSdk = ${ANDROID_SDK_TARGET}|g" "${IRONFOX_GMSCORE}/build.gradle"

    # Bump Android minimum SDK
    ## (This matches what we're using for the browser itself, as well as Mozilla's various components/dependencies)
    "${IRONFOX_SED}" -i -e 's|ext.androidMinSdk = .*|ext.androidMinSdk = 26|g' "${IRONFOX_GMSCORE}/build.gradle"

    # Bump Android target SDK
    "${IRONFOX_SED}" -i -e "s|ext.androidTargetSdk = .*|ext.androidTargetSdk = ${ANDROID_SDK_TARGET}|g" "${IRONFOX_GMSCORE}/build.gradle"

    popd

    echo_green_text 'SUCCESS: Prepared microG'
}

function prepare_phoenix() {
    echo_red_text 'Preparing Phoenix...'

    pushd "${IRONFOX_PHOENIX}"

    # Ensure we don't reset devtools.debugger.remote-enabled per-launch from Phoenix
    ## We handle this ourselves with ironfox.cfg instead, so that we can allow that value to persist on Nightly builds (but not for Release)
    ## I don't love this - it's hacky, and I probably need to find a better way to deal with this in Phoenix upstream...
    "${IRONFOX_SED}" -i -e 's|pref("devtools.debugger.remote-enabled"|// pref("devtools.debugger.remote-enabled"|g' "${IRONFOX_PHOENIX}/build-resources/phoenix-user-pref.cfg"

    popd

    echo_green_text 'SUCCESS: Prepared Phoenix'
}

function prepare_prebuilds() {
    echo_red_text 'Preparing IronFox prebuilds...'

    pushd "${IRONFOX_PREBUILDS}"
    bash -x "${IRONFOX_PREBUILDS}/scripts/prebuild.sh"
    popd

    echo_green_text 'SUCCESS: Prepared IronFox prebuilds'
}

function prepare_rust() {
    echo_red_text 'Preparing Rust...'

    # Create Cargo home directory
    mkdir -p "${IRONFOX_CARGO_HOME}"

    ## Symlink Rust (cargo) config
    if [[ ! -f "${IRONFOX_CARGO_HOME}/config.toml" ]]; then
        ln -s "${IRONFOX_CONFIGS}/cargo/config.toml" "${IRONFOX_CARGO_HOME}/config.toml"
    fi

    echo_green_text 'SUCCESS: Prepared Rust'
}

echo_red_text "Preparing to build IronFox ${IRONFOX_VERSION}..."

# This needs to run before we get Android Components, to ensure that ex. patches apply properly
if [ "${IRONFOX_PREPARE_GECKO}" == 1 ]; then
   prepare_firefox
fi

if [ "${IRONFOX_PREPARE_AC}" == 1 ]; then
    prepare_ac
fi

if [ "${IRONFOX_PREPARE_ANDROID_SDK}" == 1 ]; then
    prepare_android_sdk
fi

if [ "${IRONFOX_PREPARE_AS}" == 1 ]; then
    prepare_as
fi

if [ "${IRONFOX_PREPARE_BUNDLETOOL}" == 1 ]; then
    prepare_bundletool
fi

if [ "${IRONFOX_PREPARE_FENIX}" == 1 ]; then
    prepare_fenix
fi

if [ "${IRONFOX_PREPARE_GLEAN}" == 1 ]; then
    prepare_glean
fi

if [ "${IRONFOX_PREPARE_LLVM}" == 1 ]; then
    prepare_llvm
fi

if [ "${IRONFOX_PREPARE_MICROG}" == 1 ]; then
    prepare_microg
fi

if [ "${IRONFOX_PREPARE_PHOENIX}" == 1 ]; then
    prepare_phoenix
fi

if [ "${IRONFOX_PREPARE_PREBUILDS}" == 1 ]; then
    prepare_prebuilds
fi

if [ "${IRONFOX_PREPARE_RUST}" == 1 ]; then
    prepare_rust
fi

echo_green_text "SUCCESS: Prepared to build IronFox ${IRONFOX_VERSION}"
touch "${IRONFOX_BUILD}/finished-prebuild"
