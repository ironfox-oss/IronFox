#!/bin/bash

set -euo pipefail

# Set verbosity
set_verbosity

# No-op (remove) unwanted Mozilla endpoints
function noop_mozilla_endpoints() {
  function print_usage() {
    echo "Usage: noop_mozilla_endpoints 'unwanted.endpoint.org' '/path/to/directory_or_file'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the endpoint to remove!'
    print_usage
    return 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please provide the directory or file path!'
    print_usage
    return 1
  fi

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have grep
  verify_exec "${IRONFOX_GREP}" 'IRONFOX_GREP' || return 1

  # Ensure we have xargs
  verify_exec "${IRONFOX_XARGS}" 'IRONFOX_XARGS' || return 1

  local -r endpoint="$1"
  local -r dir="$2"

  # Ensure we have a valid file or directory
  if [[ ! -d "${dir}" ]] && [[ ! -f "${dir}" ]]; then
    return 1
  fi

  # Find files containing the endpoint
  local -r files=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}[^\"']*\"" -e "'${endpoint}[^\"']*'")
  local -r files_slash=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}/[^\"']*\"" -e "'${endpoint}/[^\"']*'")
  local -r files_period=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"${endpoint}.[^\"']*\"" -e "'${endpoint}.[^\"']*'")
  local -r http_files=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}[^\"']*\"" -e "'http://${endpoint}[^\"']*'")
  local -r http_files_slash=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}/[^\"']*\"" -e "'http://${endpoint}/[^\"']*'")
  local -r http_files_period=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"http://${endpoint}.[^\"']*\"" -e "'http://${endpoint}.[^\"']*'")
  local -r https_files=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}[^\"']*\"" -e "'https://${endpoint}[^\"']*'")
  local -r https_files_slash=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}/[^\"']*\"" -e "'https://${endpoint}/[^\"']*'")
  local -r https_files_period=$("${IRONFOX_GREP}" -rnlI --exclude=*.json --exclude=*.md --exclude=*.swift --exclude-dir=androidTest --exclude-dir=docs --exclude-dir=test --exclude-dir=tests "${dir}" -e "\"https://${endpoint}.[^\"']*\"" -e "'https://${endpoint}.[^\"']*'")

  # Check if any files were found and modify them
  if [[ -n "${files}" ]]; then
    echo_red_text "Removing ${endpoint} from files... ${files}"
    echo "${files}" | "${IRONFOX_XARGS}" -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}[^\"']*\"|\"\"|g" -e "s|'${endpoint}[^\"']*'|''|g"
  fi

  if [[ -n "${files_slash}" ]]; then
    echo_red_text "Removing ${endpoint}/ from files... ${files_slash}"
    echo "${files_slash}" | "${IRONFOX_XARGS}"s -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}/[^\"']*\"|\"\"|g" -e "s|'${endpoint}/[^\"']*'|''|g"
  fi

  if [[ -n "${files_period}" ]]; then
    echo_red_text "Removing ${endpoint}. from files... ${files_period}"
    echo "${files_period}" | "${IRONFOX_XARGS}" -L1 "${IRONFOX_SED}" -i -r -e "s|\"${endpoint}.[^\"']*\"|\"\"|g" -e "s|'${endpoint}.[^\"']*'|''|g"
  fi

  if [[ -n "${http_files}" ]]; then
    echo_red_text "Removing http://${endpoint} from files... ${http_files}"
    echo "${http_files}" | "${IRONFOX_XARGS}" -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}[^\"']*'|''|g"
  fi

  if [[ -n "${http_files_slash}" ]]; then
    echo_red_text "Removing http://${endpoint}/ from files... ${http_files_slash}"
    echo "${http_files_slash}" | "${IRONFOX_XARGS}" -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}/[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}/[^\"']*'|''|g"
  fi

  if [[ -n "${http_files_period}" ]]; then
    echo_red_text "Removing http://${endpoint}. from files... ${http_files_period}"
    echo "${http_files_period}" | "${IRONFOX_XARGS}" -L1 "${IRONFOX_SED}" -i -r -e "s|\"http://${endpoint}.[^\"']*\"|\"\"|g" -e "s|'http://${endpoint}.[^\"']*'|''|g"
  fi

  if [[ -n "${https_files}" ]]; then
    echo_red_text "Removing https://${endpoint} from files... ${https_files}"
    echo "${https_files}" | "${IRONFOX_XARGS}" -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}[^\"']*'|''|g"
  fi

  if [[ -n "${https_files_slash}" ]]; then
    echo_red_text "Removing https://${endpoint}/ from files... ${https_files_slash}"
    echo "${https_files_slash}" | "${IRONFOX_XARGS}" -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}/[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}/[^\"']*'|''|g"
  fi

  if [[ -n "${https_files_period}" ]]; then
    echo_red_text "Removing https://${endpoint}. from files... ${https_files_period}"
    echo "${https_files_period}" | "${IRONFOX_XARGS}" -L1 "${IRONFOX_SED}" -i -r -e "s|\"https://${endpoint}.[^\"']*\"|\"\"|g" -e "s|'https://${endpoint}.[^\"']*'|''|g"
  fi
}

# No-op (remove) unwanted Mozilla endpoints from Android Components
function noop_ac_endpoints() {
  echo_red_text 'No-oping endpoints from Android Components...'

  # Ensure we have `IRONFOX_AC`
  verify_dir_with_env "${IRONFOX_AC}" 'IRONFOX_AC' || return 1

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

# No-op (remove) unwanted Mozilla endpoints from Application Services
function noop_as_endpoints() {
  echo_red_text 'No-oping endpoints from Application Services...'

  # Ensure we have `IRONFOX_AS`
  verify_dir_with_env "${IRONFOX_AS}" 'IRONFOX_AS' || return 1

  # MARS
  noop_mozilla_endpoints "ads.mozilla.org" "${IRONFOX_AS}/components/context_id/src/mars.rs"

  echo_green_text 'SUCCESS: No-oped endpoints from Application Services'
}

# No-op (remove) unwanted Mozilla endpoints from Fenix
function noop_fenix_endpoints() {
  echo_red_text 'No-oping endpoints from Fenix...'

  # Ensure we have `IRONFOX_FENIX`
  verify_dir_with_env "${IRONFOX_FENIX}" 'IRONFOX_FENIX' || return 1

  # AMO Discovery/recommendations
  noop_mozilla_endpoints "services.addons.mozilla.org" "${IRONFOX_FENIX}/app/build.gradle"

  # Telemetry
  noop_mozilla_endpoints "debug-ping-preview.firebaseapp.com" "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/debugsettings/gleandebugtools/GleanDebugToolsMiddleware.kt"

  echo_green_text 'SUCCESS: No-oped endpoints from Fenix'
}

# No-op (remove) unwanted Mozilla endpoints from Firefox (Gecko/mozilla-central)
function noop_firefox_endpoints() {
  echo_red_text 'No-oping endpoints from Firefox...'

  # Ensure we have `IRONFOX_GECKO`
  verify_dir_with_env "${IRONFOX_GECKO}" 'IRONFOX_GECKO' || return 1

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

# No-op (remove) unwanted Mozilla endpoints from Glean
function noop_glean_endpoints() {
  echo_red_text 'No-oping endpoints from Glean...'

  # Ensure we have `IRONFOX_GLEAN`
  verify_dir_with_env "${IRONFOX_GLEAN}" 'IRONFOX_GLEAN' || return 1

  # Telemetry
  noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt"
  noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/python/glean/config.py"
  noop_mozilla_endpoints "incoming.telemetry.mozilla.org" "${IRONFOX_GLEAN}/glean-core/rlb/src/configuration.rs"

  echo_green_text 'SUCCESS: No-oped endpoints from Glean'
}
