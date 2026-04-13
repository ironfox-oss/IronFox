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
    readonly deglean_target='all'
else
    readonly deglean_target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

IRONFOX_DEGLEAN_AC=0
IRONFOX_DEGLEAN_AS=0
IRONFOX_DEGLEAN_FENIX=0
IRONFOX_DEGLEAN_GECKO=0

if [ "${deglean_target}" == 'ac' ]; then
    # De-glean Android Components
    IRONFOX_DEGLEAN_AC=1
elif [ "${deglean_target}" == 'as' ]; then
    # De-glean Application Services
    IRONFOX_DEGLEAN_AS=1
elif [ "${deglean_target}" == 'fenix' ]; then
    # De-glean Fenix
    IRONFOX_DEGLEAN_FENIX=1
elif [ "${deglean_target}" == 'firefox' ]; then
    # De-glean Firefox (Gecko/mozilla-central)
    IRONFOX_DEGLEAN_GECKO=1
elif [ "${deglean_target}" == 'all' ]; then
    # If no argument is specified (or argument is set to "all"), just de-glean everything
    IRONFOX_DEGLEAN_AC=1
    IRONFOX_DEGLEAN_AS=1
    IRONFOX_DEGLEAN_FENIX=1
    IRONFOX_DEGLEAN_GECKO=1
else
    echo_red_text "ERROR: Invalid target: ${deglean_target}\n You must enter one of the following:"
    echo 'All:                              all (Default)'
    echo 'Android Components:               ac'
    echo 'Application Services:             as'
    echo 'Fenix:                            fenix'
    echo 'Firefox (Gecko/mozilla-central):  firefox'
    exit 1
fi
readonly IRONFOX_DEGLEAN_AC
readonly IRONFOX_DEGLEAN_AS
readonly IRONFOX_DEGLEAN_FENIX
readonly IRONFOX_DEGLEAN_GECKO

function deglean() {
    local readonly dir="$1"
    local readonly gradle_files=$(find "${dir}" -type f -name "*.gradle")
    local readonly kt_files=$(find "${dir}" -type f -name "*.kt")
    local readonly yaml_files=$(find "${dir}" -type f -name "metrics.yaml" -o -name "pings.yaml")

    if [ -n "${gradle_files}" ]; then
        for file in $gradle_files; do
            local modified=false
            "${IRONFOX_PYTHON}" "${IRONFOX_SCRIPTS}/deglean.py" "${file}"

            if grep -q 'apply plugin.*glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*apply plugin:.*glean.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if grep -q 'classpath.*glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*classpath.*glean.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if grep -q 'compileOnly.*glean' "$file"; then
                "${IRONFOX_SED}" -i -r 's/^(.*compileOnly.*glean.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if grep -q 'implementation.*glean' "$file"; then
                "${IRONFOX_SED}" -i -r 's/^(.*implementation.*glean.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if grep -q 'testImplementation.*glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if [ "${modified}" = true ]; then
                echo_red_text "De-gleaned ${file}."
            fi
        done
    else
        echo_green_text "No *.gradle files found in ${dir}."
    fi

    if [ -n "${kt_files}" ]; then
        for file in $kt_files; do
            local modified=false

            if grep -q 'import mozilla.telemetry.*' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*import mozilla.telemetry.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if grep -q 'import .*GleanMetrics' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*GleanMetrics.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if [ "${modified}" = true ]; then
                echo_red_text "De-gleaned ${file}."
            fi
        done
    else
        echo_green_text "No *.kt files found in ${dir}."
    fi

    if [ -n "${yaml_files}" ]; then
        for yaml_file in $yaml_files; do
            rm -vf "${yaml_file}"
            echo_red_text "De-gleaned ${yaml_file}."
        done
    else
        echo_green_text "No metrics.yaml or pings.yaml files found in ${dir}."
    fi
}

function fenix_deglean() {
    local readonly dir="$1"
    local readonly gradle_files=$(find "${dir}" -type f -name "*.gradle")

    if [ -n "${gradle_files}" ]; then
        for file in $gradle_files; do
            local modified=false

            if grep -q 'implementation.*service-glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*implementation.*service-glean.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if grep -q 'testImplementation.*glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "${file}"
                local modified=true
            fi

            if [ "${modified}" = true ]; then
                echo_red_text "De-gleaned ${file}."
            fi
        done
    else
        echo_green_text "No *.gradle files found in ${dir}."
    fi
}

function deglean_ac() {
    echo_red_text 'De-gleaning Android Components...'

    deglean "${IRONFOX_AC}"

    # Remove the Glean service
    ## https://searchfox.org/firefox-main/source/mobile/android/android-components/components/service/glean/README.md
    rm -rvf "${IRONFOX_AC}/components/service/glean"
    rm -rvf "${IRONFOX_AC}/samples/glean"

    # Remove Glean classes
    "${IRONFOX_SED}" -i -e 's|GleanMessaging|// GleanMessaging|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
    "${IRONFOX_SED}" -i -e 's|Microsurvey.confirmation|// Microsurvey.confirmation|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
    "${IRONFOX_SED}" -i -e 's|Microsurvey.dismiss|// Microsurvey.dismiss|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
    "${IRONFOX_SED}" -i -e 's|Microsurvey.privacy|// Microsurvey.privacy|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
    "${IRONFOX_SED}" -i -e 's|Microsurvey.shown|// Microsurvey.shown|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
    "${IRONFOX_SED}" -i -e 's|GleanMessaging|// GleanMessaging|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingStorage.kt"
    rm -vf "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/GleanCrashReporterService.kt"

    echo_green_text 'SUCCESS: De-gleaned Android Components'
}

function deglean_as() {
    echo_red_text 'De-gleaning Application Services...'

    deglean "${IRONFOX_AS}"
    "${IRONFOX_SED}" -i 's|mozilla-glean|# mozilla-glean|g' "${IRONFOX_AS}/gradle/libs.versions.toml"
    "${IRONFOX_SED}" -i 's|glean|# glean|g' "${IRONFOX_AS}/gradle/libs.versions.toml"

    # Remove unused/unnecessary Glean components
    rm -vf "${IRONFOX_AS}/components/sync_manager/android/src/main/java/mozilla/appservices/syncmanager/BaseGleanSyncPing.kt"

    # Remove Glean classes
    "${IRONFOX_SED}" -i 's|FxaClientMetrics|// FxaClientMetrics|g' "${IRONFOX_AS}/components/fxa-client/android/src/main/java/mozilla/appservices/fxaclient/FxaClient.kt"
    "${IRONFOX_SED}" -i 's|NimbusEvents.isReady|// NimbusEvents.isReady|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt"
    "${IRONFOX_SED}" -i 's|PlacesManagerMetrics|// PlacesManagerMetrics|g' "${IRONFOX_AS}/components/places/android/src/main/java/mozilla/appservices/places/PlacesConnection.kt"

    echo_green_text 'SUCCESS: De-gleaned Application Services'
}

function deglean_fenix() {
    echo_red_text 'De-gleaning Fenix...'

    deglean "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/gecko"
    fenix_deglean "${IRONFOX_FENIX}"

    # Remove Glean classes
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics|// import org.mozilla.fenix.GleanMetrics|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/AppRequestInterceptor.kt"
    "${IRONFOX_SED}" -i 's|ErrorPage.visited|// ErrorPage.visited|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/AppRequestInterceptor.kt"

    "${IRONFOX_SED}" -i -e 's|import mozilla.telemetry|// import mozilla.telemetry|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics.Awesomebar|// import org.mozilla.fenix.GleanMetrics.Awesomebar|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics.Events|// import org.mozilla.fenix.GleanMetrics.Events|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
    "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics.VoiceSearch|// import org.mozilla.fenix.GleanMetrics.VoiceSearch|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
    "${IRONFOX_SED}" -i 's|Awesomebar.clipboardSuggestionClicked|// Awesomebar.clipboardSuggestionClicked|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
    "${IRONFOX_SED}" -i 's|Events.browserToolbarQrScanCompleted|// Events.browserToolbarQrScanCompleted|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
    "${IRONFOX_SED}" -i 's|VoiceSearch.tapped|// VoiceSearch.tapped|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"

    "${IRONFOX_SED}" -i -e 's|Metrics|// Metrics|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/gecko/search/SearchWidgetProvider.kt"

    echo_green_text 'SUCCESS: De-gleaned Fenix'
}

function deglean_firefox() {
    echo_red_text 'De-gleaning Firefox...'

    deglean "${IRONFOX_GECKO}/mobile/android/geckoview"
    deglean "${IRONFOX_GECKO}/mobile/android/gradle"

    "${IRONFOX_SED}" -i 's|classpath libs.mozilla.glean|// classpath libs.mozilla.glean|g' "${IRONFOX_GECKO}/build.gradle"

    echo_green_text 'SUCCESS: De-gleaned Firefox'
}

if [ "${IRONFOX_DEGLEAN_AC}" == 1 ]; then
    deglean_ac
fi

if [ "${IRONFOX_DEGLEAN_AS}" == 1 ]; then
    deglean_as
fi

if [ "${IRONFOX_DEGLEAN_FENIX}" == 1 ]; then
    deglean_fenix
fi

if [ "${IRONFOX_DEGLEAN_GECKO}" == 1 ]; then
    deglean_firefox
fi
