#!/bin/bash

set -euo pipefail

# Set verbosity
set_verbosity

# De-glean a project directory
function deglean() {
  function print_usage() {
    echo "Usage: deglean '/path/to/directory'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a directory that should be de-gleaned!'
    print_usage
    return 1
  fi

  # Ensure we have find
  verify_exec "${IRONFOX_FIND}" 'IRONFOX_FIND' || return 1

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have grep
  verify_exec "${IRONFOX_GREP}" 'IRONFOX_GREP' || return 1

  # Ensure we have Python
  verify_exec "${IRONFOX_PYTHON}" 'IRONFOX_PYTHON' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  local -r dir="$1"
  local -r gradle_files=$("${IRONFOX_FIND}" "${dir}" -type f -name "*.gradle")
  local -r kt_files=$("${IRONFOX_FIND}" "${dir}" -type f -name "*.kt")
  local -r yaml_files=$("${IRONFOX_FIND}" "${dir}" -type f -name "metrics.yaml" -o -name "pings.yaml")

  if [[ -n "${gradle_files}" ]]; then
    for file in $gradle_files; do
      local modified=false
      "${IRONFOX_PYTHON}" "${IRONFOX_SCRIPTS}/deglean.py" "${file}"

      if "${IRONFOX_GREP}" -q 'apply plugin.*glean' "${file}"; then
        "${IRONFOX_SED}" -i -r 's/^(.*apply plugin:.*glean.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if "${IRONFOX_GREP}" -q 'classpath.*glean' "${file}"; then
        "${IRONFOX_SED}" -i -r 's/^(.*classpath.*glean.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if "${IRONFOX_GREP}" -q 'compileOnly.*glean' "$file"; then
        "${IRONFOX_SED}" -i -r 's/^(.*compileOnly.*glean.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if "${IRONFOX_GREP}" -q 'implementation.*glean' "$file"; then
        "${IRONFOX_SED}" -i -r 's/^(.*implementation.*glean.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if "${IRONFOX_GREP}" -q 'testImplementation.*glean' "${file}"; then
        "${IRONFOX_SED}" -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if [[ "${modified}" == true ]]; then
        echo_red_text "De-gleaned ${file}."
      fi
    done
  else
    echo_green_text "No *.gradle files found in ${dir}."
  fi

  if [[ -n "${kt_files}" ]]; then
    for file in $kt_files; do
      local modified=false

      if "${IRONFOX_GREP}" -q 'import mozilla.telemetry.*' "${file}"; then
        "${IRONFOX_SED}" -i -r 's/^(.*import mozilla.telemetry.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if "${IRONFOX_GREP}" -q 'import .*GleanMetrics' "${file}"; then
        "${IRONFOX_SED}" -i -r 's/^(.*GleanMetrics.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if [[ "${modified}" == true ]]; then
        echo_red_text "De-gleaned ${file}."
      fi
    done
  else
    echo_green_text "No *.kt files found in ${dir}."
  fi

  if [[ -n "${yaml_files}" ]]; then
    for yaml_file in $yaml_files; do
      "${IRONFOX_RM}" -vf "${yaml_file}"
      echo_red_text "De-gleaned ${yaml_file}."
    done
  else
    echo_green_text "No metrics.yaml or pings.yaml files found in ${dir}."
  fi
}

# De-glean a Fenix directory
function fenix_deglean() {
  function print_usage() {
    echo "Usage: fenix_deglean '/path/to/directory'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a Fenix directory that should be de-gleaned!'
    print_usage
    return 1
  fi

  # Ensure we have find
  verify_exec "${IRONFOX_FIND}" 'IRONFOX_FIND' || return 1

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have grep
  verify_exec "${IRONFOX_GREP}" 'IRONFOX_GREP' || return 1

  local -r dir="$1"
  local -r gradle_files=$("${IRONFOX_FIND}" "${dir}" -type f -name "*.gradle")

  if [[ -n "${gradle_files}" ]]; then
    for file in $gradle_files; do
      local modified=false

      if "${IRONFOX_GREP}" -q 'implementation.*service-glean' "${file}"; then
        "${IRONFOX_SED}" -i -r 's/^(.*implementation.*service-glean.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if "${IRONFOX_GREP}" -q 'testImplementation.*glean' "${file}"; then
        "${IRONFOX_SED}" -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "${file}"
        local modified=true
      fi

      if [[ "${modified}" = true ]]; then
        echo_red_text "De-gleaned ${file}."
      fi
    done
  else
    echo_green_text "No *.gradle files found in ${dir}."
  fi
}

# De-glean Android Components
function deglean_ac() {
  echo_red_text 'De-gleaning Android Components...'

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  # Ensure we have `IRONFOX_AC`
  verify_dir_with_env "${IRONFOX_AC}" 'IRONFOX_AC' || return 1

  deglean "${IRONFOX_AC}"

  # Remove the Glean service
  ## https://searchfox.org/firefox-main/source/mobile/android/android-components/components/service/glean/README.md
  "${IRONFOX_RM}" -rvf "${IRONFOX_AC}/components/service/glean"
  "${IRONFOX_RM}" -rvf "${IRONFOX_AC}/samples/glean"

  # Remove Glean classes
  "${IRONFOX_SED}" -i -e 's|GleanMessaging|// GleanMessaging|g' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
  "${IRONFOX_SED}" -i -e 's|Microsurvey.confirmation|// Microsurvey.confirmation|g' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
  "${IRONFOX_SED}" -i -e 's|Microsurvey.dismiss|// Microsurvey.dismiss|g' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
  "${IRONFOX_SED}" -i -e 's|Microsurvey.privacy|// Microsurvey.privacy|g' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
  "${IRONFOX_SED}" -i -e 's|Microsurvey.shown|// Microsurvey.shown|g' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
  "${IRONFOX_SED}" -i -e 's|GleanMessaging|// GleanMessaging|g' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingStorage.kt"
  "${IRONFOX_RM}" -vf "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/GleanCrashReporterService.kt"

  echo_green_text 'SUCCESS: De-gleaned Android Components'
}

# De-glean Application Services
function deglean_as() {
  echo_red_text 'De-gleaning Application Services...'

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  # Ensure we have `IRONFOX_AS`
  verify_dir_with_env "${IRONFOX_AS}" 'IRONFOX_AS' || return 1

  deglean "${IRONFOX_AS}"
  "${IRONFOX_SED}" -i 's|mozilla-glean|# mozilla-glean|g' "${IRONFOX_AS}/gradle/libs.versions.toml"
  "${IRONFOX_SED}" -i 's|glean|# glean|g' "${IRONFOX_AS}/gradle/libs.versions.toml"

  # Remove unused/unnecessary Glean components
  "${IRONFOX_RM}" -vf "${IRONFOX_AS}/components/remote_settings/android/src/main/java/mozilla/appservices/remotesettings/GleanTelemetry.kt"
  "${IRONFOX_RM}" -vf "${IRONFOX_AS}/components/sync_manager/android/src/main/java/mozilla/appservices/syncmanager/BaseGleanSyncPing.kt"

  # Remove Glean classes
  "${IRONFOX_SED}" -i 's|FxaClientMetrics|// FxaClientMetrics|g' "${IRONFOX_AS}/components/fxa-client/android/src/main/java/mozilla/appservices/fxaclient/FxaClient.kt"
  "${IRONFOX_SED}" -i 's|NimbusEvents.isReady|// NimbusEvents.isReady|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt"
  "${IRONFOX_SED}" -i 's|PlacesManagerMetrics|// PlacesManagerMetrics|g' "${IRONFOX_AS}/components/places/android/src/main/java/mozilla/appservices/places/PlacesConnection.kt"

  echo_green_text 'SUCCESS: De-gleaned Application Services'
}

# De-glean Fenix
function deglean_fenix() {
  echo_red_text 'De-gleaning Fenix...'

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  # Ensure we have `IRONFOX_FENIX`
  verify_dir_with_env "${IRONFOX_FENIX}" 'IRONFOX_FENIX' || return 1

  deglean "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/gecko"
  fenix_deglean "${IRONFOX_FENIX}"

  # Remove Glean classes
  "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics|// import org.mozilla.fenix.GleanMetrics|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/AppRequestInterceptor.kt"
  "${IRONFOX_SED}" -i 's|ErrorPage.archive|// ErrorPage.archive|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/AppRequestInterceptor.kt"
  "${IRONFOX_SED}" -i 's|ErrorPage.visited|// ErrorPage.visited|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/AppRequestInterceptor.kt"

  "${IRONFOX_SED}" -i -e 's|Metrics|// Metrics|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/gecko/search/SearchWidgetProvider.kt"

  "${IRONFOX_RM}" "${IRONFOX_FENIX}/app/longfox/metrics.yaml"

  echo_green_text 'SUCCESS: De-gleaned Fenix'
}

# De-glean Firefox (Gecko)
function deglean_firefox() {
  echo_red_text 'De-gleaning Firefox...'

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have `IRONFOX_GECKO`
  verify_dir_with_env "${IRONFOX_GECKO}" 'IRONFOX_GECKO' || return 1

  deglean "${IRONFOX_GECKO}/mobile/android/geckoview"
  deglean "${IRONFOX_GECKO}/mobile/android/gradle"

  "${IRONFOX_SED}" -i 's|classpath libs.mozilla.glean|// classpath libs.mozilla.glean|g' "${IRONFOX_GECKO}/build.gradle"

  echo_green_text 'SUCCESS: De-gleaned Firefox'
}
