#!/bin/bash

set -euo pipefail

function deglean() {
    local dir="$1"
    local gradle_files=$(find "${dir}" -type f -name "*.gradle")
    local kt_files=$(find "${dir}" -type f -name "*.kt")
    local yaml_files=$(find "${dir}" -type f -name "metrics.yaml" -o -name "pings.yaml")

    if [ -n "${gradle_files}" ]; then
        for file in $gradle_files; do
            local modified=false
            python3 "${rootdir}/scripts/deglean.py" "${file}"

            if grep -q 'apply plugin.*glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*apply plugin:.*glean.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if grep -q 'classpath.*glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*classpath.*glean.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if grep -q 'compileOnly.*glean' "$file"; then
                "${IRONFOX_SED}" -i -r 's/^(.*compileOnly.*glean.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if grep -q 'implementation.*glean' "$file"; then
                "${IRONFOX_SED}" -i -r 's/^(.*implementation.*glean.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if grep -q 'testImplementation.*glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if [ "${modified}" = true ]; then
                echo "De-gleaned ${file}."
            fi
        done
    else
        echo "No *.gradle files found in ${dir}."
    fi

    if [ -n "${kt_files}" ]; then
        for file in $kt_files; do
            local modified=false

            if grep -q 'import mozilla.telemetry.*' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*import mozilla.telemetry.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if grep -q 'import .*GleanMetrics' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*GleanMetrics.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if [ "${modified}" = true ]; then
                echo "De-gleaned ${file}."
            fi
        done
    else
        echo "No *.kt files found in ${dir}."
    fi

    if [ -n "${yaml_files}" ]; then
        for yaml_file in $yaml_files; do
            rm -vf "${yaml_file}"
            echo "De-gleaned ${yaml_file}."
        done
    else
        echo "No metrics.yaml or pings.yaml files found in ${dir}."
    fi
}

function deglean_fenix() {
    local dir="$1"
    local gradle_files=$(find "${dir}" -type f -name "*.gradle")

    if [ -n "${gradle_files}" ]; then
        for file in $gradle_files; do
            local modified=false

            if grep -q 'implementation.*service-glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*implementation.*service-glean.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if grep -q 'testImplementation.*glean' "${file}"; then
                "${IRONFOX_SED}" -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "${file}"
                modified=true
            fi

            if [ "${modified}" = true ]; then
                echo "De-gleaned ${file}."
            fi
        done
    else
        echo "No *.gradle files found in ${dir}."
    fi
}

deglean "${IRONFOX_AS}"
deglean "${IRONFOX_AC}"
deglean "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/gecko"
deglean "${IRONFOX_GECKO}/mobile/android/geckoview"
deglean "${IRONFOX_GECKO}/mobile/android/gradle"
deglean_fenix "${IRONFOX_FENIX}"

"${IRONFOX_SED}" -i 's|mozilla-glean|# mozilla-glean|g' "${IRONFOX_AS}/gradle/libs.versions.toml"
"${IRONFOX_SED}" -i 's|glean|# glean|g' "${IRONFOX_AS}/gradle/libs.versions.toml"

"${IRONFOX_SED}" -i 's|classpath libs.glean.gradle.plugin|// classpath libs.glean.gradle.plugin|g' "${IRONFOX_GECKO}/build.gradle"

# Remove the Glean service
## https://searchfox.org/firefox-main/source/mobile/android/android-components/components/service/glean/README.md
"${IRONFOX_SED}" -i 's|- components:service-glean|# - components:service-glean|g' "${IRONFOX_FENIX}/.buildconfig.yml"
rm -rvf "${IRONFOX_AC}/components/service/glean"
rm -rvf "${IRONFOX_AC}/samples/glean"

# Remove unused/unnecessary Glean components (Application Services)
rm -vf "${IRONFOX_AS}/components/sync_manager/android/src/main/java/mozilla/appservices/syncmanager/BaseGleanSyncPing.kt"

# Remove unused/unnecessary Glean components (Fenix)
rm -vf "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/ext/Configuration.kt"
rm -vf "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanMetricsService.kt"
rm -vf "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReporting.kt"
rm -vf "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingApi.kt"
rm -vf "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingLifecycleObserver.kt"
rm -vf "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingMetricsService.kt"

# Remove Glean classes (Android Components)
"${IRONFOX_SED}" -i -e 's|GleanMessaging|// GleanMessaging|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
"${IRONFOX_SED}" -i -e 's|Microsurvey.confirmation|// Microsurvey.confirmation|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
"${IRONFOX_SED}" -i -e 's|Microsurvey.dismiss|// Microsurvey.dismiss|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
"${IRONFOX_SED}" -i -e 's|Microsurvey.privacy|// Microsurvey.privacy|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
"${IRONFOX_SED}" -i -e 's|Microsurvey.shown|// Microsurvey.shown|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
"${IRONFOX_SED}" -i -e 's|GleanMessaging|// GleanMessaging|' "${IRONFOX_AC}/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingStorage.kt"
rm -vf "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/GleanCrashReporterService.kt"

# Remove Glean classes (Application Services)
"${IRONFOX_SED}" -i 's|FxaClientMetrics|// FxaClientMetrics|g' "${IRONFOX_AS}/components/fxa-client/android/src/main/java/mozilla/appservices/fxaclient/FxaClient.kt"
"${IRONFOX_SED}" -i 's|NimbusEvents.isReady|// NimbusEvents.isReady|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt"
"${IRONFOX_SED}" -i 's|PlacesManagerMetrics|// PlacesManagerMetrics|g' "${IRONFOX_AS}/components/places/android/src/main/java/mozilla/appservices/places/PlacesConnection.kt"

# Remove Glean classes (Fenix)
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics|// import org.mozilla.fenix.GleanMetrics|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/AppRequestInterceptor.kt"
"${IRONFOX_SED}" -i 's|ErrorPage.visited|// ErrorPage.visited|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/AppRequestInterceptor.kt"

"${IRONFOX_SED}" -i -e 's|import mozilla.telemetry|// import mozilla.telemetry|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics.Awesomebar|// import org.mozilla.fenix.GleanMetrics.Awesomebar|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics.Events|// import org.mozilla.fenix.GleanMetrics.Events|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
"${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.GleanMetrics.VoiceSearch|// import org.mozilla.fenix.GleanMetrics.VoiceSearch|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
"${IRONFOX_SED}" -i 's|Awesomebar.clipboardSuggestionClicked|// Awesomebar.clipboardSuggestionClicked|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
"${IRONFOX_SED}" -i 's|Events.browserToolbarQrScanCompleted|// Events.browserToolbarQrScanCompleted|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"
"${IRONFOX_SED}" -i 's|VoiceSearch.tapped|// VoiceSearch.tapped|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/search/SearchDialogFragment.kt"

# Remove Glean classes (Gecko)
"${IRONFOX_SED}" -i -e 's|Metrics|// Metrics|' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/gecko/search/SearchWidgetProvider.kt"
