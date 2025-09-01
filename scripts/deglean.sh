#!/bin/bash

if [[ "$env_source" != "true" ]]; then
    echo "Use 'source scripts/env_local.sh' before calling prebuild or build"
    return 1
fi

function deglean() {
    local dir="$1"
    local gradle_files=$(find "${dir}" -type f -name "*.gradle")
    local kt_files=$(find "${dir}" -type f -name "*.kt")
    local yaml_files=$(find "${dir}" -type f -name "metrics.yaml" -o -name "pings.yaml")

    if [ -n "$gradle_files" ]; then
        for file in $gradle_files; do
            local modified=false
            python3 "$rootdir/scripts/deglean.py" "$file"

            if grep -q 'apply plugin.*glean' "$file"; then
                sed -i -r 's/^(.*apply plugin:.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'classpath.*glean' "$file"; then
                sed -i -r 's/^(.*classpath.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'compileOnly.*glean' "$file"; then
                sed -i -r 's/^(.*compileOnly.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'implementation.*glean' "$file"; then
                sed -i -r 's/^(.*implementation.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'testImplementation.*glean' "$file"; then
                sed -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if [ "$modified" = true ]; then
                echo "De-gleaned $file."
            fi
        done
    else
        echo "No *.gradle files found in $dir."
    fi

    if [ -n "$kt_files" ]; then
        for file in $kt_files; do
            local modified=false

            if grep -q 'import mozilla.telemetry.*' "$file"; then
                sed -i -r 's/^(.*import mozilla.telemetry.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'import .*GleanMetrics' "$file"; then
                sed -i -r 's/^(.*GleanMetrics.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'import .*gleandebugtools' "$file"; then
                sed -i -r 's/^(.*gleandebugtools.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if [ "$modified" = true ]; then
                echo "De-gleaned $file."
            fi
        done
    else
        echo "No *.kt files found in $dir."
    fi

    if [ -n "$yaml_files" ]; then
        for yaml_file in $yaml_files; do
            rm -vf "$yaml_file"
            echo "De-gleaned $yaml_file."
        done
    else
        echo "No metrics.yaml or pings.yaml files found in $dir."
    fi
}

deglean "${application_services}"
deglean "${mozilla_release}/mobile/android/android-components"
deglean "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/gecko"
deglean "${mozilla_release}/mobile/android/geckoview"
deglean "${mozilla_release}/mobile/android/gradle"

sed -i 's|classpath libs.glean.gradle.plugin|// classpath libs.glean.gradle.plugin|g' "${mozilla_release}/build.gradle"

# Remove the Glean service
## https://searchfox.org/firefox-main/source/mobile/android/android-components/components/service/glean/README.md
sed -i 's|- components:service-glean|# - components:service-glean|g' "${mozilla_release}/mobile/android/fenix/.buildconfig.yml"
rm -rvf "${mozilla_release}/mobile/android/android-components/components/service/glean"
rm -rvf "${mozilla_release}/mobile/android/android-components/samples/glean"

# Remove unused/unnecessary Glean components (Application Services)
rm -vf "${application_services}/components/sync_manager/android/src/main/java/mozilla/appservices/syncmanager/BaseGleanSyncPing.kt"

# Remove unused/unnecessary Glean components (Fenix)
rm -vf "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/ext/Configuration.kt"
rm -vf "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/metrics/GleanMetricsService.kt"
rm -vf "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReporting.kt"
rm -vf "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingApi.kt"
rm -vf "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingLifecycleObserver.kt"
rm -vf "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingMetricsService.kt"

# Remove Glean classes (Android Components)
sed -i -e 's|GleanMessaging|// GleanMessaging|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
sed -i -e 's|Microsurvey.confirmation|// Microsurvey.confirmation|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
sed -i -e 's|Microsurvey.dismiss|// Microsurvey.dismiss|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
sed -i -e 's|Microsurvey.privacy|// Microsurvey.privacy|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
sed -i -e 's|Microsurvey.shown|// Microsurvey.shown|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
sed -i -e 's|GleanMessaging|// GleanMessaging|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingStorage.kt"
rm -vf "${mozilla_release}/mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/GleanCrashReporterService.kt"

# Remove Glean classes (Application Services)
sed -i 's|FxaClientMetrics|// FxaClientMetrics|g' "${application_services}/components/fxa-client/android/src/main/java/mozilla/appservices/fxaclient/FxaClient.kt"
sed -i 's|LoginsStoreMetrics|// LoginsStoreMetrics|g' "${application_services}/components/logins/android/src/main/java/mozilla/appservices/logins/DatabaseLoginsStorage.kt"
sed -i 's|NimbusEvents.isReady|// NimbusEvents.isReady|g' "${application_services}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt"
sed -i 's|PlacesManagerMetrics|// PlacesManagerMetrics|g' "${application_services}/components/places/android/src/main/java/mozilla/appservices/places/PlacesConnection.kt"

# Remove Glean classes (Fenix)
sed -i -e 's|import mozilla.telemetry.glean|// import mozilla.telemetry.glean|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/FenixApplication.kt"
sed -i -e 's|import mozilla.telemetry.glean|// import mozilla.telemetry.glean|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"
sed -i -e 's|import org.mozilla.fenix.GleanMetrics|// import org.mozilla.fenix.GleanMetrics|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/FenixApplication.kt"
sed -i -e 's|import org.mozilla.fenix.GleanMetrics|// import org.mozilla.fenix.GleanMetrics|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"
sed -i -e 's|import org.mozilla.fenix.GleanMetrics|// import org.mozilla.fenix.GleanMetrics|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/onboarding/OnboardingFragment.kt"
sed -i -e 's|import org.mozilla.fenix.GleanMetrics|// import org.mozilla.fenix.GleanMetrics|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/utils/Settings.kt"

sed -i -e 's|AppIcon.|// AppIcon.|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"
sed -i -e 's|Events.|// Events.|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"
sed -i -e 's|Metrics.default|// Metrics.default|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"
sed -i -e 's|Metrics.has|// Metrics.has|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"
sed -i -e 's|Metrics.recently|// Metrics.recently|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"
sed -i -e 's|Metrics.set|// Metrics.set|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"
sed -i -e 's|Pings.|// Pings.|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/onboarding/OnboardingFragment.kt"
sed -i -e 's|StartOnHome.enterHome|// StartOnHome.enterHome|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/HomeActivity.kt"

# Remove Glean classes (Gecko)
sed -i -e 's|Metrics|// Metrics|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/gecko/search/SearchWidgetProvider.kt"
