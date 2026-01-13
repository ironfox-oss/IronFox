#!/bin/bash

function noop_mozilla_endpoints() {
    local endpoint="$1"
    local dir="$2"

    # Find files containing the endpoint
    local files=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}[^\"']*\"" -e "'${endpoint}[^\"']*'")
    local files_slash=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}/[^\"']*\"" -e "'${endpoint}/[^\"']*'")
    local files_period=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}.[^\"']*\"" -e "'${endpoint}.[^\"']*'")
    local http_files=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}[^\"']*\"" -e "'http://${endpoint}[^\"']*'")
    local http_files_slash=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}/[^\"']*\"" -e "'http://${endpoint}/[^\"']*'")
    local http_files_period=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}.[^\"']*\"" -e "'http://${endpoint}.[^\"']*'")
    local https_files=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}[^\"']*\"" -e "'https://${endpoint}[^\"']*'")
    local https_files_slash=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}/[^\"']*\"" -e "'https://${endpoint}/[^\"']*'")
    local https_files_period=$(grep -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}.[^\"']*\"" -e "'https://${endpoint}.[^\"']*'")

    # Check if any files were found and modify them
    if [ -n "${files}" ]; then
        echo "Removing ${endpoint} from files... ${files}"
        echo "${files}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}[^\"']*\"|\"\"|g" -e "s|'${endpoint}[^\"']*'|''|g"
    fi

    if [ -n "${files_slash}" ]; then
        echo "Removing ${endpoint}/ from files... ${files_slash}"
        echo "${files_slash}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}/[^\"']*\"|\"\"|g" -e "s|'${endpoint}/[^\"']*'|''|g"
    fi

    if [ -n "${files_period}" ]; then
        echo "Removing ${endpoint}. from files... ${files_period}"
        echo "${files_period}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}.[^\"']*\"|\"\"|g" -e "s|'${endpoint}.[^\"']*'|''|g"
    fi

    if [ -n "${http_files}" ]; then
        echo "Removing http://${endpoint} from files... ${http_files}"
        echo "${http_files}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}[^\"']*'|''|g"
    fi

    if [ -n "${http_files_slash}" ]; then
        echo "Removing http://${endpoint}/ from files... ${http_files_slash}"
        echo "${http_files_slash}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}/[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}/[^\"']*'|''|g"
    fi

    if [ -n "${http_files_period}" ]; then
        echo "Removing http://${endpoint}. from files... ${http_files_period}"
        echo "${http_files_period}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}.[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}.[^\"']*'|''|g"
    fi

    if [ -n "${https_files}" ]; then
        echo "Removing https://${endpoint} from files... ${https_files}"
        echo "${https_files}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}[^\"']*'|''|g"
    fi

    if [ -n "${https_files_slash}" ]; then
        echo "Removing https://${endpoint}/ from files... ${https_files_slash}"
        echo "${https_files_slash}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}/[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}/[^\"']*'|''|g"
    fi

    if [ -n "${https_files_period}" ]; then
        echo "Removing https://${endpoint}. from files... ${https_files_period}"
        echo "${https_files_period}" | xargs -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}.[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}.[^\"']*'|''|g"
    fi
}

## AMO Discovery/recommendations
noop_mozilla_endpoints "discovery.addons.mozilla.org" "${IRONFOX_GECKO}/toolkit/mozapps/extensions/AddonManager.sys.mjs"
noop_mozilla_endpoints "services.addons.mozilla.org" "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt"
noop_mozilla_endpoints "services.addons.mozilla.org" "${IRONFOX_FENIX}/app/build.gradle"

## Contile
noop_mozilla_endpoints "contile.services.mozilla.com" "${IRONFOX_AC}/components/service/mars/src/main/java/mozilla/components/service/mars/contile/ContileTopSitesProvider.kt"

## Crash reporting
noop_mozilla_endpoints "crash-reports.mozilla.com" "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/socorro/MozillaSocorroService.kt"
noop_mozilla_endpoints "crash-reports.mozilla.com" "${IRONFOX_GECKO}/mobile/android/geckoview/src/main/java/org/mozilla/geckoview/CrashHandler.java"
noop_mozilla_endpoints "crash-reports.mozilla.com" "${IRONFOX_GECKO}/toolkit/moz.configure"
noop_mozilla_endpoints "crash-stats.mozilla.org" "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/socorro/MozillaSocorroService.kt"

## DoH canary requests
noop_mozilla_endpoints "sitereview.zscaler.com" "${IRONFOX_GECKO}/toolkit/components/doh/DoHHeuristics.sys.mjs"
noop_mozilla_endpoints "use-application-dns.net" "${IRONFOX_GECKO}/toolkit/components/doh/DoHHeuristics.sys.mjs"

## DoH performance tests
noop_mozilla_endpoints "firefox-dns-perf-test.net" "${IRONFOX_GECKO}/toolkit/components/doh/TRRPerformance.sys.mjs"

## GeoIP
noop_mozilla_endpoints "location.services.mozilla.com" "${IRONFOX_AC}/components/service/location/src/main/java/mozilla/components/service/location/MozillaLocationService.kt"

## MARS
noop_mozilla_endpoints "ads.allizom.org" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt"
noop_mozilla_endpoints "ads.mozilla.org" "${IRONFOX_AS}/components/context_id/src/mars.rs"
noop_mozilla_endpoints "ads.mozilla.org" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt"

## Pocket
noop_mozilla_endpoints "firefox-android-home-recommendations.getpocket.com" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/stories/api/PocketEndpointRaw.kt"
noop_mozilla_endpoints "img-getpocket.cdn.mozilla.net" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/recommendations/api/ContentRecommendationsEndpoint.kt"
noop_mozilla_endpoints "spocs.getpocket.com" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt"
noop_mozilla_endpoints "spocs.getpocket.dev" "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt"

## Remote search configuration
noop_mozilla_endpoints "firefox.settings.services.allizom.org" "${IRONFOX_GECKO}/toolkit/components/search/SearchUtils.sys.mjs"
noop_mozilla_endpoints "firefox.settings.services.mozilla.com" "${IRONFOX_GECKO}/toolkit/components/search/SearchUtils.sys.mjs"

## Sentry
noop_mozilla_endpoints "5cfe351fb3a24e8d82c751252b48722b@o1069899.ingest.sentry.io" "${IRONFOX_GECKO}/python/mach/mach/sentry.py"

## Telemetry
noop_mozilla_endpoints "debug-ping-preview.firebaseapp.com" "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/debugsettings/gleandebugtools/GleanDebugToolsMiddleware.kt"
noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GECKO}/toolkit/components/glean/src/init/mod.rs"
noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GECKO}/toolkit/components/telemetry/pings/BackgroundTask_pingsender.sys.mjs"
noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt"
noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/python/glean/config.py"
noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/rlb/src/configuration.rs"
noop_mozilla_endpoints "incoming.thunderbird.net" "${IRONFOX_GECKO}/toolkit/components/glean/src/init/mod.rs"
noop_mozilla_endpoints "localhost" "${IRONFOX_GECKO}/toolkit/components/telemetry/pings/BackgroundTask_pingsender.sys.mjs"
noop_mozilla_endpoints "mozilla-ohttp.fastly-edge.com" "${IRONFOX_GECKO}/toolkit/components/glean/src/init/viaduct_uploader.rs"
noop_mozilla_endpoints "prod.ohttp-gateway.prod.webservices.mozgcp.net" "${IRONFOX_GECKO}/toolkit/components/glean/src/init/viaduct_uploader.rs"
