#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
    bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Set up target parameters
if [[ -z "${1+x}" ]]; then
    readonly noop_target='all'
else
    readonly noop_target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

IRONFOX_NOOP_AC=0
IRONFOX_NOOP_AS=0
IRONFOX_NOOP_FENIX=0
IRONFOX_NOOP_GECKO=0
IRONFOX_NOOP_GLEAN=0

if [ "${noop_target}" == 'ac' ]; then
    # No-op endpoints from Android Components
    IRONFOX_NOOP_AC=1
elif [ "${noop_target}" == 'as' ]; then
    # No-op endpoints from Application Services
    IRONFOX_NOOP_AS=1
elif [ "${noop_target}" == 'fenix' ]; then
    # No-op endpoints from Fenix
    IRONFOX_NOOP_FENIX=1
elif [ "${noop_target}" == 'firefox' ]; then
    # No-op endpoints from Firefox (Gecko/mozilla-central)
    IRONFOX_NOOP_GECKO=1
elif [ "${noop_target}" == 'glean' ]; then
    # No-op endpoints from Glean
    IRONFOX_NOOP_GLEAN=1
elif [ "${noop_target}" == 'all' ]; then
    # If no argument is specified (or argument is set to "all"), just no-op endpoints for everything
    IRONFOX_NOOP_AC=1
    IRONFOX_NOOP_AS=1
    IRONFOX_NOOP_FENIX=1
    IRONFOX_NOOP_GECKO=1
    IRONFOX_NOOP_GLEAN=1
else
    echo_red_text "ERROR: Invalid target: ${noop_target}\n You must enter one of the following:"
    echo 'All:                              all (Default)'
    echo 'Android Components:               ac'
    echo 'Application Services:             as'
    echo 'Fenix:                            fenix'
    echo 'Firefox (Gecko/mozilla-central):  firefox'
    echo 'Glean:                            glean'
    exit 1
fi
readonly IRONFOX_NOOP_AC
readonly IRONFOX_NOOP_AS
readonly IRONFOX_NOOP_FENIX
readonly IRONFOX_NOOP_GECKO
readonly IRONFOX_NOOP_GLEAN

function noop_mozilla_endpoints() {
    local readonly endpoint="$1"
    local readonly dir="$2"

    # Find files containing the endpoint
    local readonly files=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}[^\"']*\"" -e "'${endpoint}[^\"']*'")
    local readonly files_slash=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}/[^\"']*\"" -e "'${endpoint}/[^\"']*'")
    local readonly files_period=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}.[^\"']*\"" -e "'${endpoint}.[^\"']*'")
    local readonly http_files=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}[^\"']*\"" -e "'http://${endpoint}[^\"']*'")
    local readonly http_files_slash=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}/[^\"']*\"" -e "'http://${endpoint}/[^\"']*'")
    local readonly http_files_period=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}.[^\"']*\"" -e "'http://${endpoint}.[^\"']*'")
    local readonly https_files=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}[^\"']*\"" -e "'https://${endpoint}[^\"']*'")
    local readonly https_files_slash=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}/[^\"']*\"" -e "'https://${endpoint}/[^\"']*'")
    local readonly https_files_period=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}.[^\"']*\"" -e "'https://${endpoint}.[^\"']*'")

    # Check if any files were found and modify them
    if [ -n "${files}" ]; then
        echo_red_text "Removing ${endpoint} from files... ${files}"
        echo "${files}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}[^\"']*\"|\"\"|g" -e "s|'${endpoint}[^\"']*'|''|g"
    fi

    if [ -n "${files_slash}" ]; then
        echo_red_text "Removing ${endpoint}/ from files... ${files_slash}"
        echo "${files_slash}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}/[^\"']*\"|\"\"|g" -e "s|'${endpoint}/[^\"']*'|''|g"
    fi

    if [ -n "${files_period}" ]; then
        echo_red_text "Removing ${endpoint}. from files... ${files_period}"
        echo "${files_period}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}.[^\"']*\"|\"\"|g" -e "s|'${endpoint}.[^\"']*'|''|g"
    fi

    if [ -n "${http_files}" ]; then
        echo_red_text "Removing http://${endpoint} from files... ${http_files}"
        echo "${http_files}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}[^\"']*'|''|g"
    fi

    if [ -n "${http_files_slash}" ]; then
        echo_red_text "Removing http://${endpoint}/ from files... ${http_files_slash}"
        echo "${http_files_slash}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}/[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}/[^\"']*'|''|g"
    fi

    if [ -n "${http_files_period}" ]; then
        echo_red_text "Removing http://${endpoint}. from files... ${http_files_period}"
        echo "${http_files_period}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}.[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}.[^\"']*'|''|g"
    fi

    if [ -n "${https_files}" ]; then
        echo_red_text "Removing https://${endpoint} from files... ${https_files}"
        echo "${https_files}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}[^\"']*'|''|g"
    fi

    if [ -n "${https_files_slash}" ]; then
        echo_red_text "Removing https://${endpoint}/ from files... ${https_files_slash}"
        echo "${https_files_slash}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}/[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}/[^\"']*'|''|g"
    fi

    if [ -n "${https_files_period}" ]; then
        echo_red_text "Removing https://${endpoint}. from files... ${https_files_period}"
        echo "${https_files_period}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}.[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}.[^\"']*'|''|g"
    fi
}

function noop_ac() {
    echo_red_text 'No-oping endpoints from Android Components...'

    # AMO Discovery/recommendations
    noop_mozilla_endpoints "services.addons.mozilla.org" "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt"

    # GeoIP
    noop_mozilla_endpoints "location.services.mozilla.com" "${IRONFOX_AC}/components/service/location/src/main/java/mozilla/components/service/location/MozillaLocationService.kt"

    # MARS
    noop_mozilla_endpoints "ads.allizom.org" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt"
    noop_mozilla_endpoints "ads.mozilla.org" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt"

    # Pocket
    noop_mozilla_endpoints "firefox-android-home-recommendations.getpocket.com" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/stories/api/PocketEndpointRaw.kt"
    noop_mozilla_endpoints "img-getpocket.cdn.mozilla.net" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/recommendations/api/ContentRecommendationsEndpoint.kt"
    noop_mozilla_endpoints "spocs.getpocket.com" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt"
    noop_mozilla_endpoints "spocs.getpocket.dev" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt"

    echo_green_text 'SUCCESS: No-oped endpoints from Android Components'
}

function noop_as() {
    echo_red_text 'No-oping endpoints from Application Services...'

    # MARS
    noop_mozilla_endpoints "ads.mozilla.org" "${IRONFOX_AS}/components/context_id/src/mars.rs"

    echo_green_text 'SUCCESS: No-oped endpoints from Application Services'
}

function noop_fenix() {
    echo_red_text 'No-oping endpoints from Fenix...'

    # AMO Discovery/recommendations
    noop_mozilla_endpoints "services.addons.mozilla.org" "${IRONFOX_FENIX}/app/build.gradle"

    # Telemetry
    noop_mozilla_endpoints "debug-ping-preview.firebaseapp.com" "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/debugsettings/gleandebugtools/GleanDebugToolsMiddleware.kt"

    echo_green_text 'SUCCESS: No-oped endpoints from Fenix'
}

function noop_firefox() {
    echo_red_text 'No-oping endpoints from Firefox...'

    # AMO Discovery/recommendations
    noop_mozilla_endpoints "discovery.addons.mozilla.org" "${IRONFOX_GECKO}/toolkit/mozapps/extensions/AddonManager.sys.mjs"

    # Crash reporting
    noop_mozilla_endpoints "crash-reports.mozilla.com" "${IRONFOX_GECKO}/mobile/android/geckoview/src/main/java/org/mozilla/geckoview/CrashHandler.java"
    noop_mozilla_endpoints "crash-reports.mozilla.com" "${IRONFOX_GECKO}/toolkit/moz.configure"

    # DoH canary requests
    noop_mozilla_endpoints "sitereview.zscaler.com" "${IRONFOX_GECKO}/toolkit/components/doh/DoHHeuristics.sys.mjs"
    noop_mozilla_endpoints "use-application-dns.net" "${IRONFOX_GECKO}/toolkit/components/doh/DoHHeuristics.sys.mjs"

    # DoH performance tests
    noop_mozilla_endpoints "firefox-dns-perf-test.net" "${IRONFOX_GECKO}/toolkit/components/doh/TRRPerformance.sys.mjs"

    # Remote search configuration
    noop_mozilla_endpoints "firefox.settings.services.allizom.org" "${IRONFOX_GECKO}/toolkit/components/search/SearchUtils.sys.mjs"
    noop_mozilla_endpoints "firefox.settings.services.mozilla.com" "${IRONFOX_GECKO}/toolkit/components/search/SearchUtils.sys.mjs"

    # Sentry
    noop_mozilla_endpoints "5cfe351fb3a24e8d82c751252b48722b@o1069899.ingest.sentry.io" "${IRONFOX_GECKO}/python/mach/mach/sentry.py"

    # Telemetry
    noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GECKO}/toolkit/components/glean/src/init/mod.rs"
    noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GECKO}/toolkit/components/telemetry/pings/BackgroundTask_pingsender.sys.mjs"
    noop_mozilla_endpoints "incoming.thunderbird.net" "${IRONFOX_GECKO}/toolkit/components/glean/src/init/mod.rs"
    noop_mozilla_endpoints "localhost" "${IRONFOX_GECKO}/toolkit/components/telemetry/pings/BackgroundTask_pingsender.sys.mjs"
    noop_mozilla_endpoints "mozilla-ohttp.fastly-edge.com" "${IRONFOX_GECKO}/toolkit/components/glean/src/init/viaduct_uploader.rs"
    noop_mozilla_endpoints "prod.ohttp-gateway.prod.webservices.mozgcp.net" "${IRONFOX_GECKO}/toolkit/components/glean/src/init/viaduct_uploader.rs"

    echo_green_text 'SUCCESS: No-oped endpoints from Firefox'
}

function noop_glean() {
    echo_red_text 'No-oping endpoints from Glean...'

    # Telemetry
    noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt"
    noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/python/glean/config.py"
    noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/rlb/src/configuration.rs"

    echo_green_text 'SUCCESS: No-oped endpoints from Glean'
}

if [ "${IRONFOX_NOOP_AC}" == 1 ]; then
    noop_ac
fi

if [ "${IRONFOX_NOOP_AS}" == 1 ]; then
    noop_as
fi

if [ "${IRONFOX_NOOP_FENIX}" == 1 ]; then
    noop_fenix
fi

if [ "${IRONFOX_NOOP_GECKO}" == 1 ]; then
    noop_firefox
fi

if [ "${IRONFOX_NOOP_GLEAN}" == 1 ]; then
    noop_glean
fi
