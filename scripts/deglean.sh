#!/bin/bash

source "$rootdir/scripts/versions.sh"

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
                $SED -i -r 's/^(.*apply plugin:.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'classpath.*glean' "$file"; then
                $SED -i -r 's/^(.*classpath.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'compileOnly.*glean' "$file"; then
                $SED -i -r 's/^(.*compileOnly.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'implementation.*glean' "$file"; then
                $SED -i -r 's/^(.*implementation.*glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'testImplementation.*glean' "$file"; then
                $SED -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "$file"
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
                $SED -i -r 's/^(.*import mozilla.telemetry.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'import .*GleanMetrics' "$file"; then
                $SED -i -r 's/^(.*GleanMetrics.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'import .*gleandebugtools' "$file"; then
                $SED -i -r 's/^(.*gleandebugtools.*)$/\/\/ \1/' "$file"
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

function deglean_fenix() {
    local dir="$1"
    local gradle_files=$(find "${dir}" -type f -name "*.gradle")
    local kt_files=$(find "${dir}" -type f -name "*.kt")

    if [ -n "$gradle_files" ]; then
        for file in $gradle_files; do
            local modified=false

            if grep -q 'implementation.*service-glean' "$file"; then
                $SED -i -r 's/^(.*implementation.*service-glean.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if grep -q 'testImplementation.*glean' "$file"; then
                $SED -i -r 's/^(.*testImplementation.*glean.*)$/\/\/ \1/' "$file"
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

            if grep -q 'import .*gleandebugtools' "$file"; then
                $SED -i -r 's/^(.*gleandebugtools.*)$/\/\/ \1/' "$file"
                modified=true
            fi

            if [ "$modified" = true ]; then
                echo "De-gleaned $file."
            fi
        done
    else
        echo "No *.kt files found in $dir."
    fi
}

deglean "${application_services}"
deglean "${mozilla_release}/mobile/android/android-components"
deglean "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/gecko"
deglean "${mozilla_release}/mobile/android/geckoview"
deglean "${mozilla_release}/mobile/android/gradle"
deglean_fenix "${mozilla_release}/mobile/android/fenix"

$SED -i 's|mozilla-glean|# mozilla-glean|g' "${application_services}/gradle/libs.versions.toml"
$SED -i 's|glean|# glean|g' "${application_services}/gradle/libs.versions.toml"

$SED -i 's|classpath libs.glean.gradle.plugin|// classpath libs.glean.gradle.plugin|g' "${mozilla_release}/build.gradle"

# Remove the Glean service
## https://searchfox.org/firefox-main/source/mobile/android/android-components/components/service/glean/README.md
$SED -i 's|- components:service-glean|# - components:service-glean|g' "${mozilla_release}/mobile/android/fenix/.buildconfig.yml"
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

# Remove Glean debugging tools
## (Also see `fenix-remove-glean.patch`)
## (In addition to reducing Glean dependencies, this also unbreaks the Debug Drawer)
$SED -i 's|object GleanDebugTools|// object GleanDebugTools|g' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/debugsettings/store/DebugDrawerAction.kt"
$SED -i 's|is DebugDrawerAction.NavigateTo.GleanDebugTools|// is DebugDrawerAction.NavigateTo.GleanDebugTools|g' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/debugsettings/store/DebugDrawerNavigationMiddleware.kt"
$SED -i 's|navController.navigate(route = DebugDrawerRoute.GleanDebugTools|// navController.navigate(route = DebugDrawerRoute.GleanDebugTools|g' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/debugsettings/store/DebugDrawerNavigationMiddleware.kt"
$SED -i 's|gleanDebugToolsStore:|// gleanDebugToolsStore:|g' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/debugsettings/ui/FenixOverlay.kt"
$SED -i 's|gleanDebugToolsStore =|// gleanDebugToolsStore =|g' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/debugsettings/ui/FenixOverlay.kt"
$SED -i 's|BrowserDirection.FromGleanDebugToolsFragment|// BrowserDirection.FromGleanDebugToolsFragment|g' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/ext/Activity.kt"
$SED -i 's|FromGlean|// FromGlean|g' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/BrowserDirection.kt"
rm -rvf "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/debugsettings/gleandebugtools"

# Remove Glean classes (Android Components)
$SED -i -e 's|GleanMessaging|// GleanMessaging|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
$SED -i -e 's|Microsurvey.confirmation|// Microsurvey.confirmation|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
$SED -i -e 's|Microsurvey.dismiss|// Microsurvey.dismiss|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
$SED -i -e 's|Microsurvey.privacy|// Microsurvey.privacy|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
$SED -i -e 's|Microsurvey.shown|// Microsurvey.shown|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt"
$SED -i -e 's|GleanMessaging|// GleanMessaging|' "${mozilla_release}/mobile/android/android-components/components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingStorage.kt"
rm -vf "${mozilla_release}/mobile/android/android-components/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/GleanCrashReporterService.kt"

# Remove Glean classes (Application Services)
$SED -i 's|FxaClientMetrics|// FxaClientMetrics|g' "${application_services}/components/fxa-client/android/src/main/java/mozilla/appservices/fxaclient/FxaClient.kt"
$SED -i 's|LoginsStoreMetrics|// LoginsStoreMetrics|g' "${application_services}/components/logins/android/src/main/java/mozilla/appservices/logins/DatabaseLoginsStorage.kt"
$SED -i 's|NimbusEvents.isReady|// NimbusEvents.isReady|g' "${application_services}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt"
$SED -i 's|PlacesManagerMetrics|// PlacesManagerMetrics|g' "${application_services}/components/places/android/src/main/java/mozilla/appservices/places/PlacesConnection.kt"

# Remove Glean classes (Gecko)
$SED -i -e 's|Metrics|// Metrics|' "${mozilla_release}/mobile/android/fenix/app/src/main/java/org/mozilla/gecko/search/SearchWidgetProvider.kt"
