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

# Set verbosity
set_verbosity

# Ensure we have `IRONFOX_SCRIPTS`
verify_dir_with_env "${IRONFOX_SCRIPTS}" 'IRONFOX_SCRIPTS' || return 1

# Include de-Glean utilities
verify_file "${IRONFOX_SCRIPTS}/deglean.sh" || return 1
source "${IRONFOX_SCRIPTS}/deglean.sh" || return 1

# Include noop endpoint utilities
verify_file "${IRONFOX_SCRIPTS}/noop_mozilla_endpoints.sh" || return 1
source "${IRONFOX_SCRIPTS}/noop_mozilla_endpoints.sh" || return 1

# Include patch utilities
verify_file "${IRONFOX_SCRIPTS}/patches.sh" || return 1
source "${IRONFOX_SCRIPTS}/patches.sh" || return 1

if [[ -z "${IRONFOX_FROM_PREBUILD+x}" ]]; then
  echo_red_text "ERROR: Do not call 'prebuild-if.sh' directly! Instead, use 'prebuild.sh'." >&1
  return 1
fi

# Ensure we have rm
verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

# Ensure we have touch
verify_exec "${IRONFOX_TOUCH}" 'IRONFOX_TOUCH' || return 1

# Ensure we have `IRONFOX_BUILD`
verify_env "${IRONFOX_BUILD}" 'IRONFOX_BUILD' || return 1

# Ensure we have `IRONFOX_VERSION`
verify_env "${IRONFOX_VERSION}" 'IRONFOX_VERSION' || return 1

if [[ -f "${IRONFOX_BUILD}/finished-prebuild" ]]; then
  "${IRONFOX_RM}" -f "${IRONFOX_BUILD}/finished-prebuild"
fi

verify_env "${prebuild_target}" 'prebuild_target' || {
  echo_red_text "ERROR: Missing prebuild target!"
  return 1
}

# Set-up target parameters
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
IRONFOX_PREPARE_UNIFFI=0
IRONFOX_PREPARE_WASI=0

if [[ "${prebuild_target}" == 'ac' ]]; then
  # Prepare Android Components
  IRONFOX_PREPARE_AC=1
elif [[ "${prebuild_target}" == 'android-sdk' ]]; then
  # Prepare Android SDK
  IRONFOX_PREPARE_ANDROID_SDK=1
elif [[ "${prebuild_target}" == 'as' ]]; then
  # Prepare Application Services
  IRONFOX_PREPARE_AS=1
elif [[ "${prebuild_target}" == 'bundletool' ]]; then
  # Prepare Bundletool
  IRONFOX_PREPARE_BUNDLETOOL=1
elif [[ "${prebuild_target}" == 'fenix' ]]; then
  # Prepare Fenix
  IRONFOX_PREPARE_FENIX=1
elif [[ "${prebuild_target}" == 'firefox' ]]; then
  # Prepare Firefox (Gecko/mozilla-central)
  IRONFOX_PREPARE_GECKO=1
elif [[ "${prebuild_target}" == 'glean' ]]; then
  # Prepare Glean
  IRONFOX_PREPARE_GLEAN=1
elif [[ "${prebuild_target}" == 'llvm' ]]; then
  # Prepare LLVM
  IRONFOX_PREPARE_LLVM=1
elif [[ "${prebuild_target}" == 'microg' ]]; then
  # Prepare microG
  IRONFOX_PREPARE_MICROG=1
elif [[ "${prebuild_target}" == 'rust' ]]; then
  # Prepare rust/cargo
  IRONFOX_PREPARE_RUST=1
elif [[ "${prebuild_target}" == 'uniffi' ]]; then
  # Prepare uniffi
  IRONFOX_PREPARE_UNIFFI=1
elif [[ "${prebuild_target}" == 'wasi' ]]; then
  # Prepare WASI SDK
  IRONFOX_PREPARE_WASI=1
elif [[ "${prebuild_target}" == 'all' ]]; then
  # If no argument is specified (or argument is set to "all"), just prepare everything
  IRONFOX_PREPARE_AC=1
  IRONFOX_PREPARE_ANDROID_SDK=1
  IRONFOX_PREPARE_AS=1
  IRONFOX_PREPARE_FENIX=1
  IRONFOX_PREPARE_GECKO=1
  IRONFOX_PREPARE_GLEAN=1
  IRONFOX_PREPARE_MICROG=1
  IRONFOX_PREPARE_RUST=1
  IRONFOX_PREPARE_UNIFFI=1

  # Respect IRONFOX_NO_PREBUILDS...
  if [[ "${IRONFOX_NO_PREBUILDS}" == 1 ]]; then
    IRONFOX_PREPARE_BUNDLETOOL=1
    IRONFOX_PREPARE_WASI=1

    if [[ -n "${FDROID_BUILD+x}" ]]; then
      IRONFOX_PREPARE_LLVM=1
    fi
  fi
else
  echo_red_text "ERROR: Invalid target: '${prebuild_target}'\n You must enter one of the following:"
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
  echo 'uniffi-bindgen:                   uniffi'
  echo 'WASI SDK:                         wasi'
  return 1
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
readonly IRONFOX_PREPARE_UNIFFI
readonly IRONFOX_PREPARE_WASI

function localize_gradle() {
  # Ensure we have chmod
  verify_exec "${IRONFOX_CHMOD}" 'IRONFOX_CHMOD' || return 1

  # Ensure we have find
  verify_exec "${IRONFOX_FIND}" 'IRONFOX_FIND' || return 1

  "${IRONFOX_FIND}" ./* -name gradlew -type f | while read -r gradlew; do
    echo -e "#!/bin/sh\n\""'${IRONFOX_GRADLE}'"\" \${IRONFOX_GRADLE_FLAGS} \""'$@'"\"" > "${gradlew}" || return 1
    "${IRONFOX_CHMOD}" 755 "${gradlew}"
  done
}

function localize_maven() {
  # Ensure we have find
  verify_exec "${IRONFOX_FIND}" 'IRONFOX_FIND' || return 1

  # Ensure we have Python
  verify_exec "${IRONFOX_PYTHON}" 'IRONFOX_PYTHON' || return 1

  # Replace custom Maven repositories with mavenLocal()
  "${IRONFOX_FIND}" ./* -name '*.gradle' -type f -exec "${IRONFOX_PYTHON}" "${IRONFOX_SCRIPTS}/localize_maven.py" {} \;
}

# Applies the overlay files in the given directory
# to the current directory
function apply_overlay() {
  # Ensure we have cp
  verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || return 1

  # Ensure we have dirname
  verify_exec "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' || return 1

  # Ensure we have find
  verify_exec "${IRONFOX_FIND}" 'IRONFOX_FIND' || return 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || return 1

  local -r source_dir="$1"
  "${IRONFOX_FIND}" "${source_dir}" -type f | while read -r src; do
    local overlay_target="${src#"${source_dir}"}"
    "${IRONFOX_MKDIR}" -vp "$("${IRONFOX_DIRNAME}" "${overlay_target}")" || return 1
    "${IRONFOX_CP}" -vrf "${src}" "${overlay_target}" || return 1
  done
}

function prepare_ac() {
  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  # Ensure we have `IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR`
  verify_env "${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}" 'IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR' || return 1

  # Ensure we have `IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR`
  verify_env "${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}" 'IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR' || return 1

  # Ensure we have `IRONFOX_ANDROID_MIN_SDK`
  verify_env "${IRONFOX_ANDROID_MIN_SDK}" 'IRONFOX_ANDROID_MIN_SDK' || return 1

  # Ensure we have `IRONFOX_ANDROID_TARGET_SDK`
  verify_env "${IRONFOX_ANDROID_TARGET_SDK}" 'IRONFOX_ANDROID_TARGET_SDK' || return 1

  echo_red_text 'Preparing Android Components...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_AC}" 'IRONFOX_AC' || return 1
  verify_dir_with_env "${IRONFOX_AC_OVERLAY}" 'IRONFOX_AC_OVERLAY' || return 1

  pushd "${IRONFOX_AC}" || return 1

  # Remove default built-in search engines
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/feature/search/src/main/assets/searchplugins/"* || return 1

  # No-op AMO collections/recommendations
  "${IRONFOX_SED}" -i -e 's/DEFAULT_COLLECTION_NAME = ".*"/DEFAULT_COLLECTION_NAME = ""/' "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt" || return 1
  "${IRONFOX_SED}" -i 's|7e8d6dc651b54ab385fb8791bf9dac||g' "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt" || return 1
  "${IRONFOX_SED}" -i -e 's/DEFAULT_COLLECTION_USER = ".*"/DEFAULT_COLLECTION_USER = ""/' "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt" || return 1
  "${IRONFOX_SED}" -i -e 's/DEFAULT_SERVER_URL = ".*"/DEFAULT_SERVER_URL = ""/' "${IRONFOX_AC}/components/feature/addons/src/main/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt" || return 1

  # No-op crash reporting
  "${IRONFOX_SED}" -i -e 's|enabled: Boolean = .*|enabled: Boolean = false,|g' "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|shouldPrompt: Prompt = .*|shouldPrompt: Prompt = Prompt.ALWAYS,|g' "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|useLegacyReporting: Boolean = .*|useLegacyReporting: Boolean = false,|g' "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|var enabled: Boolean = false,|var enabled: Boolean = enabled|g' "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt" || return 1

  # No-op GeoIP/Region service
  ## https://searchfox.org/mozilla-release/source/toolkit/modules/docs/Region.rst
  "${IRONFOX_SED}" -i -e 's/GEOIP_SERVICE_URL = ".*"/GEOIP_SERVICE_URL = ""/' "${IRONFOX_AC}/components/service/location/src/main/java/mozilla/components/service/location/MozillaLocationService.kt" || return 1
  "${IRONFOX_SED}" -i -e 's/USER_AGENT = ".*/USER_AGENT = ""/' "${IRONFOX_AC}/components/service/location/src/main/java/mozilla/components/service/location/MozillaLocationService.kt" || return 1

  # No-op MARS
  "${IRONFOX_SED}" -i -e 's/MARS_ENDPOINT_BASE_URL = ".*"/MARS_ENDPOINT_BASE_URL = ""/' "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt" || return 1
  "${IRONFOX_SED}" -i -e 's/MARS_ENDPOINT_STAGING_BASE_URL = ".*"/MARS_ENDPOINT_STAGING_BASE_URL = ""/' "${IRONFOX_AC}/components/service/pocket/src/main/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt" || return 1

  # No-op telemetry (GeckoView)
  "${IRONFOX_SED}" -i -e 's|allowMetricsFromAAR = .*|allowMetricsFromAAR = false|g' "${IRONFOX_AC}/components/browser/engine-gecko/build.gradle" || return 1

  # Nuke the "Mozilla Android Components - Ads Telemetry" and "Mozilla Android Components - Search Telemetry" extensions
  ## We don't install these with fenix-disable-telemetry.patch - so no need to keep the files around...
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/feature/search/src/main/assets/extensions/ads" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/feature/search/src/main/assets/extensions/search" || return 1

  ## We can also remove the directories/libraries themselves as well
  "${IRONFOX_RM}" -v "${IRONFOX_AC}/components/feature/search/src/main/java/mozilla/components/feature/search/middleware/AdsTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/feature/search/src/main/java/mozilla/components/feature/search/telemetry" || return 1

  # Nuke undesired Mozilla endpoints
  noop_ac_endpoints || return 1

  # Remove unused/unwanted sample libraries
  ## Since we remove the Glean Service and Web Compat Reporter dependencies, the existence of these files causes build issues
  ## We don't build or use these sample libraries at all anyways, so instead of patching these files, I don't see a reason why we shouldn't just delete them.
  "${IRONFOX_RM}" -rv "${IRONFOX_AC}/samples/browser" || return 1
  "${IRONFOX_RM}" -rv "${IRONFOX_AC}/samples/crash" || return 1

  # Remove Nimbus
  "${IRONFOX_RM}" -v "${IRONFOX_AC}/components/browser/engine-gecko/geckoview.fml.yaml" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/browser/engine-gecko/src/main/java/mozilla/components/experiment" || return 1
  "${IRONFOX_SED}" -i -e 's|-keep class mozilla.components.service.nimbus|#-keep class mozilla.components.service.nimbus|g' "${IRONFOX_AC}/components/service/nimbus/proguard-rules-consumer.pro" || return 1
  "${IRONFOX_SED}" -i -e '/buildConfig/s/true/false/' "${IRONFOX_AC}/components/service/nimbus/build.gradle" || return 1

  # Remove Firebase
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/lib/push-firebase" || return 1

  # Remove Google Play Integrity
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/feature/ipprotection/src/main/java/mozilla/components/feature/ipprotection/auth/gpi" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/lib/integrity-googleplay" || return 1

  # Remove MARS
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/service/mars" || return 1

  # Remove Sentry
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/lib/crash-sentry" || return 1

  # Remove unnecessary crash reporting components
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/support/appservices/src/main/java/mozilla/components/support/rusterrors" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_AC}/components/lib/crash/src/main/java/mozilla/components/lib/crash/service/MozillaSocorroService.kt" || return 1

  # Remove Web Compat Reporter
  "${IRONFOX_RM}" -vr "${IRONFOX_AC}/components/feature/webcompat-reporter" || return 1

  # Apply a-c overlay
  apply_overlay "${IRONFOX_AC_OVERLAY}/" || return 1

  popd || return 1

  echo_green_text 'SUCCESS: Prepared Android Components!'
}

function prepare_android_sdk() {
  # Ensure we have ln
  verify_exec "${IRONFOX_LN}" 'IRONFOX_LN' || return 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || return 1

  # Ensure we have `IRONFOX_ANDROID_NDK_REVISION`
  verify_env "${IRONFOX_ANDROID_NDK_REVISION}" 'IRONFOX_ANDROID_NDK_REVISION' || return 1

  # Ensure we have `IRONFOX_ANDROID_SDK_BUILD_TOOLS_REVISION`
  verify_env "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_REVISION}" 'IRONFOX_ANDROID_SDK_BUILD_TOOLS_REVISION' || return 1

  echo_red_text 'Preparing Android SDK...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_ANDROID_NDK}" 'IRONFOX_ANDROID_NDK' || return 1
  verify_dir_with_env "${IRONFOX_ANDROID_SDK}" 'IRONFOX_ANDROID_SDK' || return 1
  verify_dir_with_env "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" 'IRONFOX_ANDROID_SDK_BUILD_TOOLS' || return 1
  verify_dir_with_env "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" 'IRONFOX_ANDROID_SDK_PLATFORM_TOOLS' || return 1
  verify_dir_with_env "${IRONFOX_SYSROOT}" 'IRONFOX_SYSROOT' || return 1

  # Create Android NDK symlink
  if [[ ! -d "${IRONFOX_ANDROID_SDK}/ndk/${IRONFOX_ANDROID_NDK_REVISION}" ]]; then
    "${IRONFOX_MKDIR}" -p "${IRONFOX_ANDROID_SDK}/ndk"
    "${IRONFOX_LN}" -s "${IRONFOX_ANDROID_NDK}" "${IRONFOX_ANDROID_SDK}/ndk/${IRONFOX_ANDROID_NDK_REVISION}" || return 1
  fi

  # Create Android SDK Build Tools symlinks
  if [[ ! -d "${IRONFOX_ANDROID_SDK}/build-tools/${IRONFOX_ANDROID_SDK_BUILD_TOOLS_REVISION}" ]]; then
    "${IRONFOX_MKDIR}" -p "${IRONFOX_ANDROID_SDK}/build-tools"
    "${IRONFOX_LN}" -s "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${IRONFOX_ANDROID_SDK}/build-tools/${IRONFOX_ANDROID_SDK_BUILD_TOOLS_REVISION}" || return 1
  fi

  if [[ -d "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" ]] && [[ ! -d "${IRONFOX_ANDROID_SDK}/build-tools/35.0.0" ]]; then
    "${IRONFOX_MKDIR}" -p "${IRONFOX_ANDROID_SDK}/build-tools"
    "${IRONFOX_LN}" -s "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${IRONFOX_ANDROID_SDK}/build-tools/35.0.0" || return 1
  fi

  # Create Android SDK Platform Tools symlink
  if [[ ! -d "${IRONFOX_ANDROID_SDK}/platform-tools" ]]; then
    "${IRONFOX_LN}" -s "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${IRONFOX_ANDROID_SDK}/platform-tools" || return 1
  fi

  # Work-around "error: Unversioned target triples are not supported!" error for Application Services
  pushd "${IRONFOX_SYSROOT}" || return 1
  apply_patch 'android-ndk-fix-target-triples.patch' || return 1
  popd || return 1

  echo_green_text 'SUCCESS: Prepared Android SDK!'
}

function prepare_as() {
  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  # Ensure we have `IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR`
  verify_env "${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}" 'IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR' || return 1

  # Ensure we have `IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR`
  verify_env "${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}" 'IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR' || return 1

  # Ensure we have `IRONFOX_ANDROID_MIN_SDK`
  verify_env "${IRONFOX_ANDROID_MIN_SDK}" 'IRONFOX_ANDROID_MIN_SDK' || return 1

  # Ensure we have `IRONFOX_ANDROID_TARGET_SDK`
  verify_env "${IRONFOX_ANDROID_TARGET_SDK}" 'IRONFOX_ANDROID_TARGET_SDK' || return 1

  # Ensure we have `IRONFOX_RUST_VERSION`
  verify_env "${IRONFOX_RUST_VERSION}" 'IRONFOX_RUST_VERSION' || return 1

  echo_red_text 'Preparing Application Services...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_AS}" 'IRONFOX_AS' || return 1
  verify_dir_with_env "${IRONFOX_AS_OVERLAY}" 'IRONFOX_AS_OVERLAY' || return 1

  pushd "${IRONFOX_AS}" || return 1

  # Check patches
  if ! a-s_check_patches; then
    echo_red_text 'ERROR: Patch validation failed. Please check the patch files and try again.'
    return 1
  fi

  # Apply patches
  a-s_apply_patches || return 1

  # Always use our Gradle wrapper with our Gradle flags/configuration
  localize_gradle || return 1

  # Disable debug
  "${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' "${IRONFOX_AS}/Cargo.toml" || return 1

  # Enable performance optimizations
  "${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" "${IRONFOX_AS}/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" "${IRONFOX_AS}/Cargo.toml" || return 1

  "${IRONFOX_SED}" -i -e '/NDK ez-install/,/^$/d' "${IRONFOX_AS}/libs/verify-android-ci-environment.sh" || return 1
  "${IRONFOX_SED}" -i -e '/content {/,/}/d' "${IRONFOX_AS}/build.gradle" || return 1

  # Replace undesired Maven repos (ex. Mozilla's) with mavenLocal
  localize_maven || return 1

  # Set Android compile SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|g" "${IRONFOX_AS}/build.gradle" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|g" "${IRONFOX_AS}/settings.gradle" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|g" "${IRONFOX_AS}/build.gradle" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|g" "${IRONFOX_AS}/settings.gradle" || return 1

  # Set Android minimum SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_MIN_SDK}|${IRONFOX_ANDROID_MIN_SDK}|g" "${IRONFOX_AS}/build.gradle" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_MIN_SDK}|${IRONFOX_ANDROID_MIN_SDK}|g" "${IRONFOX_AS}/settings.gradle" || return 1

  # Set Android target SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_TARGET_SDK}|${IRONFOX_ANDROID_TARGET_SDK}|g" "${IRONFOX_AS}/build.gradle" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_TARGET_SDK}|${IRONFOX_ANDROID_TARGET_SDK}|g" "${IRONFOX_AS}/settings.gradle" || return 1

  # Set Rust version
  "${IRONFOX_SED}" -i -e "s|channel = .*|channel = \""${IRONFOX_RUST_VERSION}\""|g" "${IRONFOX_AS}/rust-toolchain.toml" || return 1

  # No-op Nimbus (Experimentation)
  "${IRONFOX_SED}" -i -e 's|NimbusInterface.isLocalBuild() = .*|NimbusInterface.isLocalBuild() = true|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|isFetchEnabled(): Boolean = .*|isFetchEnabled(): Boolean = false|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|isFetchEnabled(): Boolean = .*|isFetchEnabled(): Boolean = false|g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt" || return 1
  "${IRONFOX_SED}" -i -e 's/EXPERIMENT_COLLECTION_NAME = ".*"/EXPERIMENT_COLLECTION_NAME = ""/' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/Nimbus.kt" || return 1
  "${IRONFOX_SED}" -i 's|nimbus-mobile-experiments||g' "${IRONFOX_AS}/components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/Nimbus.kt" || return 1

  # Remove default built-in search engines
  "${IRONFOX_RM}" -vr "${IRONFOX_AS}"/components/remote_settings/dumps/main/attachments/search-config-icons/* || return 1

  # Remove Glean
  deglean_as || return 1

  # Nuke undesired Mozilla endpoints
  noop_as_endpoints || return 1

  # Remove the AI summarizer models configuration collection
  "${IRONFOX_RM}" -v "${IRONFOX_AS}/components/remote_settings/dumps/main/summarizer-models-config.json" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_AS}/components/remote_settings/dumps/main/summarizer-models-config.timestamp" || return 1

  # Remove the regions collection (and attachments)
  "${IRONFOX_RM}" -v "${IRONFOX_AS}/components/remote_settings/dumps/main/regions.json" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_AS}/components/remote_settings/dumps/main/regions.timestamp" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_AS}/components/remote_settings/dumps/main/attachments/regions" || return 1

  # Remove the search telemetry collection
  "${IRONFOX_RM}" -v "${IRONFOX_AS}/components/remote_settings/dumps/main/search-telemetry-v2.json" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_AS}/components/remote_settings/dumps/main/search-telemetry-v2.timestamp" || return 1

  # Remove the Mozilla Ads Client library
  "${IRONFOX_SED}" -i 's|"components/ads-client"|# "components/ads-client"|g' "${IRONFOX_AS}/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i 's|ads-client|# ads-client|g' "${IRONFOX_AS}/megazords/full/Cargo.toml" || return 1

  # Remove the Crash Reporter test library
  "${IRONFOX_SED}" -i 's|"components/crashtest"|# "components/crashtest"|g' "${IRONFOX_AS}/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i 's|crashtest|# crashtest|g' "${IRONFOX_AS}/megazords/full/Cargo.toml" || return 1

  # Remove the Filter Adult (parental controls) library
  "${IRONFOX_SED}" -i 's|"components/filter_adult"|# "components/filter_adult"|g' "${IRONFOX_AS}/Cargo.toml" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_AS}/components/filter_adult" || return 1

  # Remove the Rust Error support library
  ## Used for telemetry/error reporting, depends on Glean
  "${IRONFOX_SED}" -i 's|"components/support/error|# "components/support/error|g' "${IRONFOX_AS}/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i 's|error-support|# error-support|g' "${IRONFOX_AS}/megazords/full/Cargo.toml" || return 1

  # Apply Application Services overlay
  apply_overlay "${IRONFOX_AS_OVERLAY}/" || return 1

  popd || return 1

  echo_green_text 'SUCCESS: Prepared Application Services!'
}

function prepare_bundletool() {
  echo_red_text 'Preparing Bundletool...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_BUNDLETOOL_DIR}" 'IRONFOX_BUNDLETOOL_DIR' || return 1

  pushd "${IRONFOX_BUNDLETOOL_DIR}" || return 1

  # Apply patches
  apply_patch 'bundletool-localize-maven.patch' || return 1

  # Always use our Gradle wrapper with our Gradle flags/configuration
  localize_gradle || return 1

  popd || return 1

  echo_green_text 'SUCCESS: Prepared Bundletool!'
}

function prepare_fenix() {
  # Ensure we have cp
  verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || return 1

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  echo_red_text 'Preparing Fenix...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_FENIX}" 'IRONFOX_FENIX' || return 1
  verify_dir_with_env "${IRONFOX_FENIX_OVERLAY}" 'IRONFOX_FENIX_OVERLAY' || return 1
  verify_dir_with_env "${IRONFOX_UP_AC}" 'IRONFOX_UP_AC' || return 1
  verify_dir "${IRONFOX_UP_AC}/fenix-overlay" || return 1

  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}/fenix/app/src/main/res"
  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}/fenix/app/src/release/res/values"
  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}/fenix/app/src/release/res/xml"

  pushd "${IRONFOX_FENIX}" || return 1

  # Prevent Gradle from incorrectly reporting that telemetry is enabled
  "${IRONFOX_SED}" -i -e 's|Telemetry enabled: " + .*)|Telemetry enabled: " + false)|g' "${IRONFOX_FENIX}/app/build.gradle" || return 1

  # Enable pull-to-refresh
  "${IRONFOX_SED}" -i -e 's|PULL_TO_REFRESH_ENABLED = .*|PULL_TO_REFRESH_ENABLED = true|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/FeatureFlags.kt" || return 1

  # Ensure onboarding is always enabled
  "${IRONFOX_SED}" -i -e 's|onboardingFeatureEnabled = .*|onboardingFeatureEnabled = true|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/FeatureFlags.kt" || return 1

  # No-op AMO collections/recommendations
  "${IRONFOX_SED}" -i -e 's|"AMO_COLLECTION_NAME", "\\".*\\""|"AMO_COLLECTION_NAME", "\\"\\""|g' "${IRONFOX_FENIX}/app/build.gradle" || return 1
  "${IRONFOX_SED}" -i 's|Extensions-for-Android||g' "${IRONFOX_FENIX}/app/build.gradle" || return 1
  "${IRONFOX_SED}" -i -e 's|"AMO_COLLECTION_USER", "\\".*\\""|"AMO_COLLECTION_USER", "\\"\\""|g' "${IRONFOX_FENIX}/app/build.gradle" || return 1
  "${IRONFOX_SED}" -i -e 's|"AMO_SERVER_URL", "\\".*\\""|"AMO_SERVER_URL", "\\"\\""|g' "${IRONFOX_FENIX}/app/build.gradle" || return 1
  "${IRONFOX_SED}" -i -e 's|customExtensionCollectionFeature = .*|customExtensionCollectionFeature = false|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/FeatureFlags.kt" || return 1

  # No-op Glean
  "${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' "${IRONFOX_FENIX}/app/pings.yaml" || return 1
  "${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' "${IRONFOX_FENIX}/app/pings.yaml" || return 1

  # No-op Nimbus (Experimentation)
  "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.ext.recordEventInNimbus|// import org.mozilla.fenix.ext.recordEventInNimbus|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|context.recordEventInNimbus|// context.recordEventInNimbus|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/BackgroundServices.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|FxNimbus.features.junoOnboarding.recordExposure|// FxNimbus.features.junoOnboarding.recordExposure|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/utils/Settings.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/raw/initial_experiments.json" || return 1

  # No-op search telemetry
  "${IRONFOX_SED}" -i 's|search-telemetry-v2||g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/Core.kt" || return 1

  # Remove unused media
  ## Based on Tor Browser: https://gitlab.torproject.org/tpo/applications/tor-browser/-/commit/264dc7cd915e75ba9db3a27e09253acffe3f2311
  ## This should help reduce our APK sizes...
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/ic_launcher_private-web.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/ic_launcher-web.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/fox_ai_on_state.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_launcher_foreground.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_launcher_monochrome.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_onboarding_search_widget.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/ic_onboarding_sync.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/microsurvey_success.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/nova_onboarding_marketing.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/nova_onboarding_sync.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/nova_onboarding_tou.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/nova_onboarding_tou_2.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/nova_onboarding_widget.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/review_prompt_negative_button.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable/review_prompt_positive_button.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-hdpi/fenix_search_widget.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-hdpi/ic_logo_wordmark_normal.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-hdpi/ic_logo_wordmark_private.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-mdpi/ic_logo_wordmark_normal.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-mdpi/ic_logo_wordmark_private.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xhdpi/ic_logo_wordmark_normal.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xhdpi/ic_logo_wordmark_private.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xxhdpi/ic_logo_wordmark_normal.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xxhdpi/ic_logo_wordmark_private.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xxxhdpi/ic_logo_wordmark_normal.webp" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/res/drawable-xxxhdpi/ic_logo_wordmark_private.webp" || return 1
  # Compose artwork must resolve to a vector, not the ic_storage state selector.
  "${IRONFOX_SED}" -i -e 's|R.drawable.fox_ai_on_state|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/ai/AIControlsScreen.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.ic_onboarding_sync|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/onboarding/view/OnboardingScreen.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.microsurvey_success|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/microsurvey/ui/MicrosurveyCompleted.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.nova_onboarding_marketing|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/onboarding/view/MarketingDataOnboardingPage.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.nova_onboarding_sync|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/onboarding/continuous/ContinuousOnboardingFeature.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.nova_onboarding_sync|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/onboarding/continuous/ContinuousOnboardingScreen.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.nova_onboarding_sync|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/onboarding/view/OnboardingPage.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.nova_onboarding_widget|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/onboarding/view/OnboardingPage.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.review_prompt_negative_button|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/reviewprompt/ui/CustomReviewPrompt.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|R.drawable.review_prompt_positive_button|R.drawable.ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/reviewprompt/ui/CustomReviewPrompt.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|image-res: nova_onboarding_marketing|image-res: ic_ironfox_artwork|g' "${IRONFOX_FENIX}/app/onboarding.fml.yaml" || return 1

  # Remove unused telemetry and marketing services/components
  "${IRONFOX_SED}" -i -e 's|import mozilla.appservices.syncmanager.SyncTelemetry|// import mozilla.appservices.syncmanager.SyncTelemetry|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.downloads.listscreen.middleware.DownloadTelemetryMiddleware|// import org.mozilla.fenix.downloads.listscreen.middleware.DownloadTelemetryMiddleware|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.components.toolbar.BrowserToolbarTelemetryMiddleware|// import org.mozilla.fenix.components.toolbar.BrowserToolbarTelemetryMiddleware|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.home.toolbar.BrowserToolbarTelemetryMiddleware|// import org.mozilla.fenix.home.toolbar.BrowserToolbarTelemetryMiddleware|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.tabstray.TabsTrayTelemetryMiddleware|// import org.mozilla.fenix.tabstray.TabsTrayTelemetryMiddleware|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|import org.mozilla.fenix.webcompat.middleware.WebCompatReporterTelemetryMiddleware|// import org.mozilla.fenix.webcompat.middleware.WebCompatReporterTelemetryMiddleware|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt" || return 1

  "${IRONFOX_SED}" -i -e 's|BookmarksTelemetryMiddleware(|// BookmarksTelemetryMiddleware(|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/bookmarks/BookmarkFragment.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|BrowserToolbarTelemetryMiddleware(|// BrowserToolbarTelemetryMiddleware(|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|BrowserToolbarTelemetryMiddleware(|// BrowserToolbarTelemetryMiddleware(|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|CustomReviewPromptTelemetryMiddleware(|// CustomReviewPromptTelemetryMiddleware(|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptBottomSheetFragment.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|private fun provideTelemetryMiddleware|// private fun provideTelemetryMiddleware|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|private fun provideTelemetryMiddleware|// private fun provideTelemetryMiddleware|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|provideTelemetryMiddleware(|// provideTelemetryMiddleware(|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|provideTelemetryMiddleware(|// provideTelemetryMiddleware(|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|SyncTelemetry.|// SyncTelemetry.|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|TabsTrayTelemetryMiddleware(|// TabsTrayTelemetryMiddleware(|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|WebCompatReporterTelemetryMiddleware(|// WebCompatReporterTelemetryMiddleware(|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt" || return 1

  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/bookmarks/BookmarksTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/ActivationPing.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/AdjustMetricsService.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/AdjustSdkController.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/AdjustThirdPartySharingController.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/BreadcrumbsRecorder.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/ConversionEventRecorder.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/DefaultInstallReferrerClient.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/Event.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/FirstSessionMetricsService.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanMetricsService.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReporting.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingApi.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingLifecycleObserver.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingMetricsService.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/GrowthDataWorker.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/InstallAge.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/InstallReferrerClientWrapper.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/InstallReferrerHandlingService.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/InstallReferrerMetricsService.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/InstallReferrerWorker.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MetricController.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MetricsMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MetricsService.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MetricsStorage.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/MozillaProductDetector.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/ReferralAttribution.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/RtamoAttributionHandler.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/toolbar/BrowserToolbarTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/crashes/CrashFactCollector.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/crashes/CrashReportingAppMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/crashes/NimbusExperimentDataProvider.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/crashes/ReleaseRuntimeTagProvider.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/downloads/listscreen/middleware/DownloadTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/ext/Configuration.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/middleware/HomeTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/PocketMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/toolbar/BrowserToolbarTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/messaging/state/MessagingMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/reviewprompt/ReviewPromptMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/tabstray/TabsTrayTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/telemetry/TelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/webcompat/middleware/WebCompatReporterTelemetryMiddleware.kt" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/metrics/fonts" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/datachoices" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/startupCrash" || return 1

  # Remove MARS components
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/Ads.kt" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/home/TopSitesRefresher.kt" || return 1

  # Remove Glean
  deglean_fenix || return 1

  # Nuke undesired Mozilla endpoints
  noop_fenix_endpoints || return 1

  # Let it be IronFox
  # shellcheck disable=SC1112
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
    "${IRONFOX_FENIX}"/app/src/*/res/values*/*strings.xml || return 1

  # Replace instances of "Firefox" with "IronFox" or "IronFox Nightly"
  ## Also ensure that Firefox Suggest isn't incorrectly labeled as "IronFox Suggest",
  ## because Firefox Suggest suggestions are provided by Mozilla, not us, and
  ## ensure text states to sign-in to a "Firefox-based web browser" instead of "IronFox" on desktop
  "${IRONFOX_SED}" -i \
    -e 's/Firefox Fenix/{IRONFOX_NAME}/; s/Mozilla Firefox/{IRONFOX_NAME}/; s/Firefox/{IRONFOX_NAME}/g' \
    -e 's/{IRONFOX_NAME} Suggest/Firefox Suggest/' \
    -e 's/On your computer open {IRONFOX_NAME} and/On your computer, open a Firefox-based web browser, and/' \
    -e 's/To send a tab, sign in to {IRONFOX_NAME}/To send a tab, sign in to a Firefox-based web browser/' \
    "${IRONFOX_FENIX}"/app/src/*/res/values*/*strings.xml || return 1

  # Refer to "account" as "Firefox account" and "Sync" as "Firefox Sync"
  ## This makes it clear that these are third-party services, not operated by us
  ## (We need to set these last to ensure that "Firefox" here is not replaced with
  ##  "IronFox" or "IronFox Nightly")
  "${IRONFOX_SED}" -i \
    -e 's/Learn more about sync/Learn more about Firefox Sync/' \
    -e 's/No account?/No Firefox account?/' \
    -e 's/Sync is on/Firefox Sync is on/' \
    -e 's/%s will stop syncing with your account/%s will stop syncing with your Firefox account/' \
    "${IRONFOX_FENIX}"/app/src/*/res/values*/*strings.xml || return 1

  "${IRONFOX_SED}" -i -e 's|FENIX_PLAY_STORE_URL = ".*"|FENIX_PLAY_STORE_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|GOOGLE_URL = ".*"|GOOGLE_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|GOOGLE_US_URL = ".*"|GOOGLE_US_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|GOOGLE_XX_URL = ".*"|GOOGLE_XX_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|RATE_APP_URL = ".*"|RATE_APP_URL = ""|g' "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt" || return 1

  # Replace proprietary artwork
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/release/res/drawable/ic_launcher_foreground.xml" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}"/app/src/release/res/mipmap-*/ic_launcher.webp || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_FENIX}/app/src/release/res/values/colors.xml" || return 1
  "${IRONFOX_SED}" -i -e '/android:roundIcon/d' "${IRONFOX_FENIX}/app/src/main/AndroidManifest.xml" || return 1
  "${IRONFOX_SED}" -i -e '/SplashScreen/,+5d' "${IRONFOX_FENIX}/app/src/main/res/values-v27/styles.xml" || return 1
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_FENIX}/app/src/release/res/mipmap-anydpi-v26"
  "${IRONFOX_SED}" -i \
    -e 's/googleg_standard_color_18/ic_download/' \
    "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/components/menu/compose/MenuItem.kt" \
    "${IRONFOX_FENIX}/app/src/main/java/org/mozilla/fenix/compose/list/ListItem.kt" || return 1

  # Remove default built-in search engines
  "${IRONFOX_RM}" -vr "${IRONFOX_FENIX}/app/src/main/assets/searchplugins"/* || return 1

  # Apply Fenix overlay
  apply_overlay "${IRONFOX_FENIX_OVERLAY}/" || return 1

  # Apply UnifiedPush-AC overlay (for Fenix)
  apply_overlay "${IRONFOX_UP_AC}/fenix-overlay/" || return 1

  ## The following are for the build script, so that it can update the environment variables if needed
  ### (ex. if the user changes them)
  if [[ -f "${IRONFOX_TEMP}/fenix/app/build.gradle" ]]; then
    "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/fenix/app/build.gradle"
  fi
  "${IRONFOX_CP}" -f "${IRONFOX_FENIX}/app/build.gradle" "${IRONFOX_TEMP}/fenix/app/build.gradle" || return 1

  if [[ -f "${IRONFOX_TEMP}/fenix/app/src/release/res/values/static_strings.xml" ]]; then
    "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/fenix/app/src/release/res/values/static_strings.xml"
  fi
  "${IRONFOX_CP}" -f "${IRONFOX_FENIX}/app/src/release/res/values/static_strings.xml" "${IRONFOX_TEMP}/fenix/app/src/release/res/values/static_strings.xml" || return 1

  if [[ -f "${IRONFOX_TEMP}/fenix/app/src/release/res/xml/shortcuts.xml" ]]; then
    "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/fenix/app/src/release/res/xml/shortcuts.xml"
  fi
  "${IRONFOX_CP}" -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml" "${IRONFOX_TEMP}/fenix/app/src/release/res/xml/shortcuts.xml" || return 1

  if [[ -d "${IRONFOX_TEMP}/fenix/app/src/main/res" ]]; then
    "${IRONFOX_RM}" -rf "${IRONFOX_TEMP}/fenix/app/src/main/res"
  fi
  "${IRONFOX_CP}" -rf "${IRONFOX_FENIX}/app/src/main/res/" "${IRONFOX_TEMP}/fenix/app/src/main/res/" || return 1

  popd || return 1

  echo_green_text 'SUCCESS: Prepared Fenix!'
}

function prepare_firefox() {
  # Ensure we have cp
  verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || return 1

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  # Ensure we have `IRONFOX_RUST_VERSION`
  verify_env "${IRONFOX_RUST_VERSION}" 'IRONFOX_RUST_VERSION' || return 1

  echo_red_text 'Preparing Firefox...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_GECKO}" 'IRONFOX_GECKO' || return 1
  verify_dir_with_env "${IRONFOX_AC}" 'IRONFOX_AC' || return 1
  verify_dir_with_env "${IRONFOX_GECKO_OVERLAY}" 'IRONFOX_GECKO_OVERLAY' || return 1

  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}/gecko/ironfox"
  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages"
  "${IRONFOX_MKDIR}" -p "${IRONFOX_MOZBUILD}"

  ## Copy machrc config
  "${IRONFOX_CP}" -f "${IRONFOX_CONFIGS}/mach/machrc" "${IRONFOX_MOZBUILD}/machrc" || return 1

  pushd "${IRONFOX_GECKO}" || return 1

  # Check patches
  if ! check_patches; then
    echo_red_text 'ERROR: Patch validation failed. Please check the patch files and try again.'
    return 1
  fi

  ## For UnifiedPush-AC
  if [[ -d "${IRONFOX_UP_AC}" ]]; then
    if ! up_ac_check_patches; then
      echo_red_text 'ERROR: Patch validation failed. Please check the patch files and try again.'
      return 1
    fi
  fi

  # Apply patches
  apply_patches || return 1

  ## For UnifiedPush-AC
  if [[ -d "${IRONFOX_UP_AC}" ]]; then
    up_ac_apply_patches || return 1
  fi

  # Always use our Gradle wrapper with our Gradle flags/configuration
  localize_gradle || return 1

  # Let it be IronFox (part 2...)
  "${IRONFOX_SED}" -i -e 's|"MOZ_APP_VENDOR", ".*"|"MOZ_APP_VENDOR", "IronFox OSS"|g' "${IRONFOX_GECKO}/mobile/android/moz.configure" || return 1

  # Replace instances of "Firefox" with "IronFox" or "IronFox Nightly"
  "${IRONFOX_SED}" -i -e 's/Firefox/{IRONFOX_NAME}/g' "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html" || return 1
  "${IRONFOX_SED}" -i -e 's/Firefox/{IRONFOX_NAME}/g' "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html" || return 1

  # Use `commit` instead of `rev` for source URL
  ## (ex. displayed at `about:buildconfig`)
  "${IRONFOX_SED}" -i 's|/rev/|/commit/|g' "${IRONFOX_GECKO}/build/variables.py" || return 1

  # about:policies
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_GECKO}/ironfox/locales/en-US/browser/policies"
  "${IRONFOX_CP}" -vf browser/locales/en-US/browser/aboutPolicies.ftl "${IRONFOX_GECKO}/ironfox/locales/en-US/browser/" || return 1
  "${IRONFOX_CP}" -vf browser/locales/en-US/browser/policies/policies-descriptions.ftl "${IRONFOX_GECKO}/ironfox/locales/en-US/browser/policies/" || return 1

  # about:robots
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_GECKO}/ironfox/about/browser/robots"
  "${IRONFOX_CP}" -vf browser/base/content/aboutRobots.css "${IRONFOX_GECKO}/ironfox/about/browser/robots/" || return 1
  "${IRONFOX_CP}" -vf browser/base/content/aboutRobots.js "${IRONFOX_GECKO}/ironfox/about/browser/robots/" || return 1
  "${IRONFOX_CP}" -vf browser/base/content/aboutRobots.xhtml "${IRONFOX_GECKO}/ironfox/about/browser/robots/" || return 1
  "${IRONFOX_CP}" -vf browser/base/content/aboutRobots-icon.png "${IRONFOX_GECKO}/ironfox/about/browser/robots/" || return 1
  "${IRONFOX_CP}" -vf browser/base/content/robot.ico "${IRONFOX_GECKO}/ironfox/about/browser/robots/" || return 1
  "${IRONFOX_CP}" -vf browser/base/content/static-robot.png "${IRONFOX_GECKO}/ironfox/about/browser/robots/" || return 1
  "${IRONFOX_CP}" -vf browser/locales/en-US/browser/aboutRobots.ftl "${IRONFOX_GECKO}/ironfox/locales/en-US/browser/" || return 1

  # about:logo
  "${IRONFOX_SED}" -i 's|chrome://branding/content/about.png|chrome://branding/content/about-if.png|g' "${IRONFOX_GECKO}/docshell/base/nsAboutRedirector.cpp" || return 1

  # Ensure we're building for release
  "${IRONFOX_SED}" -i -e 's/variant=variant(.*)/variant=variant("release")/g' "${IRONFOX_GECKO}/mobile/android/gradle.configure" || return 1

  # Use our own Glean Parser Python environment
  "${IRONFOX_SED}" -i -e 's/set_config("GRADLE_GLEAN_PARSER_VENV"/# set_config("GRADLE_GLEAN_PARSER_VENV"/g' "${IRONFOX_GECKO}/mobile/android/gradle.configure" || return 1

  # Fail on use of prebuilt nimbus-fml
  "${IRONFOX_SED}" -i 's|https://|hxxps://|g' "${IRONFOX_GECKO}/mobile/android/gradle/plugins/nimbus-gradle-plugin/src/main/kotlin/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.kt" || return 1

  # Set Android compile SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|g" "${IRONFOX_AC}/.config.yml" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|g" "${IRONFOX_AC}/.config.yml" || return 1

  # Set Android minimum SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_MIN_SDK}|${IRONFOX_ANDROID_MIN_SDK}|g" "${IRONFOX_AC}/.config.yml" || return 1

  # Set Android target SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_TARGET_SDK}|${IRONFOX_ANDROID_TARGET_SDK}|g" "${IRONFOX_AC}/.config.yml" || return 1

  # Set Rust version
  "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${IRONFOX_RUST_VERSION}\""|g" "${IRONFOX_GECKO}/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${IRONFOX_RUST_VERSION}\""|g" "${IRONFOX_GECKO}/intl/icu_capi/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${IRONFOX_RUST_VERSION}\""|g" "${IRONFOX_GECKO}/intl/icu_segmenter_data/Cargo.toml" || return 1

  # Disable debug
  "${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' "${IRONFOX_GECKO}/gfx/harfbuzz/src/rust/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e 's|debug = .*|debug = false|g' "${IRONFOX_GECKO}/gfx/wr/Cargo.toml" || return 1

  # Enable overflow checks
  "${IRONFOX_SED}" -i -e 's|overflow-checks = .*|overflow-checks = true|g' "${IRONFOX_GECKO}/gfx/harfbuzz/src/rust/Cargo.toml" || return 1

  # Enable performance optimizations
  "${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" "${IRONFOX_GECKO}/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" "${IRONFOX_GECKO}/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" "${IRONFOX_GECKO}/gfx/wr/Cargo.toml" || return 1

  # Disable SSLKEYLOGGING
  ## https://bugzilla.mozilla.org/show_bug.cgi?id=1183318
  ## https://bugzilla.mozilla.org/show_bug.cgi?id=1915224
  "${IRONFOX_SED}" -i -e 's|NSS_ALLOW_SSLKEYLOGFILE ?= .*|NSS_ALLOW_SSLKEYLOGFILE ?= 0|g' "${IRONFOX_GECKO}/security/nss/lib/ssl/Makefile" || return 1
  echo '' >> "${IRONFOX_GECKO}/security/moz.build" || return 1
  echo 'gyp_vars["enable_sslkeylogfile"] = 0' >> "${IRONFOX_GECKO}/security/moz.build" || return 1

  # Include additional Remote Settings local dumps (+ add our own...)
  "${IRONFOX_SED}" -i -e 's|"mobile/"|"0"|g' "${IRONFOX_GECKO}/services/settings/dumps/blocklists/moz.build" || return 1
  "${IRONFOX_SED}" -i -e 's|"mobile/"|"0"|g' "${IRONFOX_GECKO}/services/settings/dumps/security-state/moz.build" || return 1
  echo '' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1
  echo 'FINAL_TARGET_FILES.defaults.settings.main += [' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1
  echo '    "anti-tracking-url-decoration.json",' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1
  echo '    "hijack-blocklists.json",' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1
  echo '    "translations-models.json",' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1
  echo '    "translations-wasm.json",' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1
  echo '    "url-classifier-skip-urls.json",' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1
  echo '    "url-parser-default-unknown-schemes-interventions.json",' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1
  echo ']' >> "${IRONFOX_GECKO}/services/settings/dumps/main/moz.build" || return 1

  # Remove unused about:telemetry CSS
  "${IRONFOX_RM}" -v "${IRONFOX_GECKO}/toolkit/content/aboutTelemetry.css" || return 1

  # Remove unused localizations
  "${IRONFOX_SED}" -i 's|locale/@AB_CD@/global/aboutStudies|# locale/@AB_CD@/global/aboutStudies|g' "${IRONFOX_GECKO}/toolkit/locales/jar.mn" || return 1
  "${IRONFOX_SED}" -i 's|crashreporter|# crashreporter|g' "${IRONFOX_GECKO}/toolkit/locales/jar.mn" || return 1
  "${IRONFOX_SED}" -i 's|locales-preview/aboutRestricted|# locales-preview/aboutRestricted|g' "${IRONFOX_GECKO}/toolkit/locales/jar.mn" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_GECKO}/toolkit/locales/en-US/crashreporter" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_GECKO}/toolkit/locales/en-US/toolkit/about/aboutGlean.ftl" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_GECKO}/toolkit/locales/en-US/toolkit/about/aboutTelemetry.ftl" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_GECKO}/toolkit/locales-preview/aboutRestricted.ftl" || return 1

  # Prevent registration of the Glean add-on ping scheduler
  "${IRONFOX_SED}" -i 's|category update-timer amGleanDaily|# category update-timer amGleanDaily|g' "${IRONFOX_GECKO}/toolkit/mozapps/extensions/extensions.manifest" || return 1

  # Remove Claude integration
  ## (Necessary for those with IDEs that may try to parse/use this functionality)
  "${IRONFOX_RM}" -v "${IRONFOX_GECKO}/.mcp.json" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_GECKO}/AGENTS.md" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_GECKO}/CLAUDE.md" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_GECKO}/.claude" || return 1
  "${IRONFOX_RM}" -vr "${IRONFOX_GECKO}/.codex" || return 1

  # No-op RemoteSettingsCrashPull
  "${IRONFOX_SED}" -i 's|crash-reports-ondemand||g' "${IRONFOX_GECKO}/toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs" || return 1
  "${IRONFOX_SED}" -i -e 's/REMOTE_SETTINGS_CRASH_COLLECTION = ".*"/REMOTE_SETTINGS_CRASH_COLLECTION = ""/g' "${IRONFOX_GECKO}/toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs" || return 1

  # No-op Normandy (Experimentation)
  "${IRONFOX_SED}" -i -e 's/REMOTE_SETTINGS_COLLECTION = ".*"/REMOTE_SETTINGS_COLLECTION = ""/g' "${IRONFOX_GECKO}/toolkit/components/normandy/lib/RecipeRunner.sys.mjs" || return 1
  "${IRONFOX_SED}" -i 's|normandy-recipes-capabilities||g' "${IRONFOX_GECKO}/toolkit/components/normandy/lib/RecipeRunner.sys.mjs" || return 1

  # No-op Nimbus (Experimentation) (Gecko)
  ## (Primarily for defense in depth)
  "${IRONFOX_SED}" -i -e 's/COLLECTION_ID_FALLBACK = ".*"/COLLECTION_ID_FALLBACK = ""/g' "${IRONFOX_GECKO}/toolkit/components/nimbus/ExperimentAPI.sys.mjs" || return 1
  "${IRONFOX_SED}" -i -e 's/COLLECTION_ID_FALLBACK = ".*"/COLLECTION_ID_FALLBACK = ""/g' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs" || return 1
  "${IRONFOX_SED}" -i -e 's/EXPERIMENTS_COLLECTION = ".*"/EXPERIMENTS_COLLECTION = ""/g' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs" || return 1
  "${IRONFOX_SED}" -i -e 's/SECURE_EXPERIMENTS_COLLECTION = ".*"/SECURE_EXPERIMENTS_COLLECTION = ""/g' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs" || return 1
  "${IRONFOX_SED}" -i -e 's/SECURE_EXPERIMENTS_COLLECTION_ID = ".*"/SECURE_EXPERIMENTS_COLLECTION_ID = ""/g' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs" || return 1
  "${IRONFOX_SED}" -i 's|nimbus-desktop-experiments||g' "${IRONFOX_GECKO}/toolkit/components/nimbus/ExperimentAPI.sys.mjs" || return 1
  "${IRONFOX_SED}" -i 's|nimbus-desktop-experiments||g' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs" || return 1
  "${IRONFOX_SED}" -i 's|nimbus-secure-experiments||g' "${IRONFOX_GECKO}/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs" || return 1

  # No-op telemetry (Gecko)
  "${IRONFOX_SED}" -i -e 's/usageDeletionRequest.setEnabled(.*)/usageDeletionRequest.setEnabled(false)/g' "${IRONFOX_GECKO}/toolkit/components/telemetry/app/UsageReporting.sys.mjs" || return 1

  "${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' "${IRONFOX_GECKO}/toolkit/components/glean/pings.yaml" || return 1
  "${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' "${IRONFOX_GECKO}/toolkit/components/glean/pings.yaml" || return 1
  "${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' "${IRONFOX_GECKO}/toolkit/components/nimbus/pings.yaml" || return 1
  "${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' "${IRONFOX_GECKO}/toolkit/components/nimbus/pings.yaml" || return 1

  # Prevent DoH canary requests
  "${IRONFOX_SED}" -i -e 's/GLOBAL_CANARY = ".*"/GLOBAL_CANARY = ""/g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHHeuristics.sys.mjs" || return 1
  "${IRONFOX_SED}" -i -e 's/ZSCALER_CANARY = ".*"/ZSCALER_CANARY = ""/g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHHeuristics.sys.mjs" || return 1

  # Prevent DoH remote config/rollout
  "${IRONFOX_SED}" -i -e 's/RemoteSettings(".*"/RemoteSettings(""/g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHConfig.sys.mjs" || return 1
  "${IRONFOX_SED}" -i -e 's/kConfigCollectionKey = ".*"/kConfigCollectionKey = ""/g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHTestUtils.sys.mjs" || return 1
  "${IRONFOX_SED}" -i -e 's/kProviderCollectionKey = ".*"/kProviderCollectionKey = ""/g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHTestUtils.sys.mjs" || return 1
  "${IRONFOX_SED}" -i 's|"doh-config"||g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHConfig.sys.mjs" || return 1
  "${IRONFOX_SED}" -i 's|"doh-providers"||g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHConfig.sys.mjs" || return 1
  "${IRONFOX_SED}" -i 's|"doh-config"||g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHTestUtils.sys.mjs" || return 1
  "${IRONFOX_SED}" -i 's|"doh-providers"||g' "${IRONFOX_GECKO}/toolkit/components/doh/DoHTestUtils.sys.mjs" || return 1

  # Remove DoH config/rollout local dumps
  "${IRONFOX_SED}" -i -e 's|"doh-config.json"|# "doh-config.json"|g' "${IRONFOX_GECKO}/services/settings/static-dumps/main/moz.build" || return 1
  "${IRONFOX_SED}" -i -e 's|"doh-providers.json"|# "doh-providers.json"|g' "${IRONFOX_GECKO}/services/settings/static-dumps/main/moz.build" || return 1
  "${IRONFOX_RM}" -vf services/settings/static-dumps/main/doh-config.json "${IRONFOX_GECKO}/services/settings/static-dumps/main/doh-providers.json" || return 1

  # Remove example dependencies
  ## Also see `gecko-remove-example-dependencies.patch` and `gecko-substitute-geckoview.patch`
  "${IRONFOX_SED}" -i "s|project(':messaging_example'|// project(':messaging_example'|g" "${IRONFOX_GECKO}/settings.gradle" || return 1
  "${IRONFOX_SED}" -i "s|project(':port_messaging_example'|// project(':port_messaging_example'|g" "${IRONFOX_GECKO}/settings.gradle" || return 1

  # Remove proprietary/tracking libraries
  "${IRONFOX_SED}" -i 's|adjust|# adjust|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml" || return 1
  "${IRONFOX_SED}" -i 's|firebase-messaging|# firebase-messaging|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml" || return 1
  "${IRONFOX_SED}" -i 's|installreferrer|# installreferrer|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml" || return 1
  "${IRONFOX_SED}" -i 's|kotlinx-coroutines-play-services|# kotlinx-coroutines-play-services|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml" || return 1
  "${IRONFOX_SED}" -i 's|play-integrity|# play-integrity|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml" || return 1
  "${IRONFOX_SED}" -i 's|play-review|# play-review|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml" || return 1
  "${IRONFOX_SED}" -i 's|play-services-|# play-services-|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml" || return 1
  "${IRONFOX_SED}" -i 's|sentry|# sentry|g' "${IRONFOX_GECKO}/gradle/libs.versions.toml" || return 1

  # Remove Glean
  deglean_firefox || return 1

  "${IRONFOX_SED}" -i 's/1753c69b71ae24a9b339d98e9b71166740a15506cfc46245251eb63c0222568f/0414411ba8ef1580ccd812794c5f843e9726d2af28e916cdd2359ce55d0215de/g' "${IRONFOX_GECKO}/third_party/rust/glean-core/.cargo-checksum.json" || return 1
  "${IRONFOX_SED}" -i 's/ada8f059f0fa8a3a82315606318429d3a70200bbb2886d1a1bcaad2856a6303b/9e2f2f22f500be3e80638131fb0921c47702d377aaa13f4662d51dae57c21155/g' "${IRONFOX_GECKO}/third_party/rust/glean-core/.cargo-checksum.json" || return 1

  ## We also need to de-glean Android Components here, as not doing so appears to cause build failures for ex. GeckoView
  deglean_ac || return 1

  # Nuke undesired Mozilla endpoints
  noop_firefox_endpoints || return 1

  # Fail on use of prebuilt binary
  "${IRONFOX_SED}" -i 's|https://github.com|hxxps://github.com|g' "${IRONFOX_GECKO}/python/mozboot/mozboot/android.py" || return 1

  # Make the build system think we installed the emulator and an AVD
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_ANDROID_SDK}/emulator" || return 1
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_MOZBUILD}/android-device/avd" || return 1

  # Do not check the "emulator" utility which is obviously absent in the empty directory we created above
  "${IRONFOX_SED}" -i -e '/check_android_tools("emulator"/d' "${IRONFOX_GECKO}/build/moz.configure/android-sdk.configure" || return 1

  # Do not define `browser.safebrowsing.features.` prefs by default
  ## These are unnecessary, add extra confusion and complexity, and don't appear to interact well with our other prefs/settings
  "${IRONFOX_SED}" -i \
    -e 's|"browser.safebrowsing.features.cryptomining.update"|"z99.ignore.boolean"|g' \
    -e 's|"browser.safebrowsing.features.fingerprinting.update"|"z99.ignore.boolean"|g' \
    -e 's|"browser.safebrowsing.features.harmfuladdon.update"|"z99.ignore.boolean"|g' \
    -e 's|"browser.safebrowsing.features.malware.update"|"z99.ignore.boolean"|g' \
    -e 's|"browser.safebrowsing.features.phishing.update"|"z99.ignore.boolean"|g' \
    -e 's|"browser.safebrowsing.features.trackingAnnotation.update"|"z99.ignore.boolean"|g' \
    -e 's|"browser.safebrowsing.features.trackingProtection.update"|"z99.ignore.boolean"|g' \
    "${IRONFOX_GECKO}/mobile/android/app/geckoview-prefs.js" || return 1

  # Apply Gecko overlay
  apply_overlay "${IRONFOX_GECKO_OVERLAY}/" || return 1

  ## The following are for the build script, so that it can update the environment variables if needed
  ### (ex. if the user changes them)
  if [[ -f "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages/connection-not-secure.html" ]]; then
    "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages/connection-not-secure.html"
  fi
  "${IRONFOX_CP}" -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html" "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages/connection-not-secure.html" || return 1

  if [[ -f "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages/time-errors.html" ]]; then
    "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages/time-errors.html"
  fi
  "${IRONFOX_CP}" -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html" "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages/time-errors.html" || return 1

  popd || return 1

  echo_green_text 'SUCCESS: Prepared Firefox!'
}

function prepare_glean() {
  echo_red_text 'Preparing Glean...'

  # Ensure we have cp
  verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || return 1

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have ln
  verify_exec "${IRONFOX_LN}" 'IRONFOX_LN' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  # Ensure we have `IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR`
  verify_env "${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}" 'IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR' || return 1

  # Ensure we have `IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR`
  verify_env "${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}" 'IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR' || return 1

  # Ensure we have `IRONFOX_ANDROID_MIN_SDK`
  verify_env "${IRONFOX_ANDROID_MIN_SDK}" 'IRONFOX_ANDROID_MIN_SDK' || return 1

  # Ensure we have `IRONFOX_ANDROID_TARGET_SDK`
  verify_env "${IRONFOX_ANDROID_TARGET_SDK}" 'IRONFOX_ANDROID_TARGET_SDK' || return 1

  # Ensure we have `IRONFOX_RUST_VERSION`
  verify_env "${IRONFOX_RUST_VERSION}" 'IRONFOX_RUST_VERSION' || return 1

  # Verify directories
  verify_dir_with_env "${IRONFOX_GLEAN}" 'IRONFOX_GLEAN' || return 1
  verify_dir_with_env "${IRONFOX_GLEAN_OVERLAY}" 'IRONFOX_GLEAN_OVERLAY' || return 1

  "${IRONFOX_MKDIR}" -p "${IRONFOX_GLEAN_PYENV}/bootstrap-24.3.0-0"
  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}/glean"

  # Set Python symlinks so that Glean will use our Python environment, instead of attempting to create its own...
  if [[ ! -d "${IRONFOX_GLEAN_PYENV}/pythonenv" ]]; then
    "${IRONFOX_LN}" -s "${IRONFOX_PYENV_DIR}" "${IRONFOX_GLEAN_PYENV}/pythonenv" || return 1
  fi

  if [[ ! -d "${IRONFOX_GLEAN_PYENV}/bootstrap-24.3.0-0/Miniconda3" ]]; then
    "${IRONFOX_LN}" -s "${IRONFOX_PYENV_DIR}" "${IRONFOX_GLEAN_PYENV}/bootstrap-24.3.0-0/Miniconda3" || return 1
  fi

  # We currently remove Glean fully from Android Components (See `a-c-remove-glean.patch`) and Application Services (see `a-s-remove-glean.patch`). Unfortunately, it's currently untenable to remove Glean in its entirety from Fenix (though we do remove Mozilla's `Glean Service` library/implementation). So, our approach is to stub Glean for Fenix, which we can do thanks to Tor's no-op UniFFi binding generator, as well as our `fenix-remove-glean.patch` patch, and the commands below.
  ## https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/tree/main/projects/glean

  pushd "${IRONFOX_GLEAN}" || return 1

  # Check patches
  if ! glean_check_patches; then
    echo_red_text 'ERROR: Patch validation failed. Please check the patch files and try again.'
    return 1
  fi

  # Apply patches
  glean_apply_patches || return 1

  # Always use our Gradle wrapper with our Gradle flags/configuration
  localize_gradle || return 1

  # Replace undesired Maven repos (ex. Mozilla's) with mavenLocal
  localize_maven || return 1

  # Set Android compile SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|g" "${IRONFOX_GLEAN}/build.gradle" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|g" "${IRONFOX_GLEAN}/build.gradle" || return 1

  # Set Android minimum SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_MIN_SDK}|${IRONFOX_ANDROID_MIN_SDK}|g" "${IRONFOX_GLEAN}/build.gradle" || return 1

  # Set Android target SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_TARGET_SDK}|${IRONFOX_ANDROID_TARGET_SDK}|g" "${IRONFOX_GLEAN}/build.gradle" || return 1

  # Set Glean Parser version
  "${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN_PARSER_VERSION}|${IRONFOX_GLEAN_PARSER_VERSION}|g" "${IRONFOX_GLEAN}/Makefile" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN_PARSER_VERSION}|${IRONFOX_GLEAN_PARSER_VERSION}|g" "${IRONFOX_GLEAN}/pyproject.toml" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN_PARSER_VERSION}|${IRONFOX_GLEAN_PARSER_VERSION}|g" "${IRONFOX_GLEAN}/glean-core/Cargo.toml" || return 1

  # Set Rust version
  "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${IRONFOX_RUST_VERSION}\""|g" "${IRONFOX_GLEAN}/glean-core/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${IRONFOX_RUST_VERSION}\""|g" "${IRONFOX_GLEAN}/glean-core/build/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e "s|rust-version = .*|rust-version = \""${IRONFOX_RUST_VERSION}\""|g" "${IRONFOX_GLEAN}/glean-core/rlb/Cargo.toml" || return 1

  # Disable debug
  "${IRONFOX_SED}" -i -e "s|debug = .*|debug = false|g" "${IRONFOX_GLEAN}/Cargo.toml" || return 1

  # Enable performance optimizations
  "${IRONFOX_SED}" -i -e "s|lto = .*|lto = true|g" "${IRONFOX_GLEAN}/Cargo.toml" || return 1
  "${IRONFOX_SED}" -i -e "s|opt-level = .*|opt-level = 3|g" "${IRONFOX_GLEAN}/Cargo.toml" || return 1

  # Ensure that the Glean gradle plug-in/glean_parser always runs offline
  "${IRONFOX_SED}" -i "s|pypi.python.org|noop.invalid|g" "${IRONFOX_GLEAN}/gradle-plugin/src/main/groovy/mozilla/telemetry/glean-gradle-plugin/GleanGradlePlugin.groovy" || return 1

  # No-op Glean
  "${IRONFOX_SED}" -i -e 's|allowGleanInternal = .*|allowGleanInternal = false|g' "${IRONFOX_GLEAN}/glean-core/android/build.gradle" || return 1
  "${IRONFOX_SED}" -i -e '/minifyEnabled/s/false/true/' "${IRONFOX_GLEAN}/glean-core/android-native/build.gradle" || return 1
  "${IRONFOX_SED}" -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' "${IRONFOX_GLEAN}/glean-core/python/glean/config.py" || return 1
  "${IRONFOX_SED}" -i -e '/enable_internal_pings:/s/true/false/' "${IRONFOX_GLEAN}/glean-core/python/glean/config.py" || return 1
  "${IRONFOX_SED}" -i -e "s|DEFAULT_GLEAN_ENDPOINT: .*|DEFAULT_GLEAN_ENDPOINT: \&\str = \"\";|g" "${IRONFOX_GLEAN}/glean-core/rlb/src/configuration.rs" || return 1
  "${IRONFOX_SED}" -i -e '/enable_internal_pings:/s/true/false/' "${IRONFOX_GLEAN}/glean-core/rlb/src/configuration.rs" || return 1
  "${IRONFOX_SED}" -i -e 's/DEFAULT_TELEMETRY_ENDPOINT = ".*"/DEFAULT_TELEMETRY_ENDPOINT = ""/' "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt" || return 1
  "${IRONFOX_SED}" -i -e '/enableInternalPings:/s/true/false/' "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt" || return 1
  "${IRONFOX_SED}" -i -e '/enableEventTimestamps:/s/true/false/' "${IRONFOX_GLEAN}/glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt" || return 1
  "${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' "${IRONFOX_GLEAN}/glean-core/src/core_metrics.rs" || return 1
  "${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' "${IRONFOX_GLEAN}/glean-core/src/glean_metrics.rs" || return 1
  "${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' "${IRONFOX_GLEAN}/glean-core/src/internal_metrics.rs" || return 1
  "${IRONFOX_SED}" -i -e 's|disabled: .*|disabled: true,|g' "${IRONFOX_GLEAN}/glean-core/src/lib_unit_tests.rs" || return 1
  "${IRONFOX_SED}" -i -e 's|include_client_id: .*|include_client_id: false|g' "${IRONFOX_GLEAN}/glean-core/pings.yaml" || return 1
  "${IRONFOX_SED}" -i -e 's|send_if_empty: .*|send_if_empty: false|g' "${IRONFOX_GLEAN}/glean-core/pings.yaml" || return 1
  "${IRONFOX_SED}" -i -e 's|"$rootDir/glean-core/android/metrics.yaml"|// "$rootDir/glean-core/android/metrics.yaml"|g' "${IRONFOX_GLEAN}/glean-core/android/build.gradle" || return 1
  "${IRONFOX_RM}" -v "${IRONFOX_GLEAN}/glean-core/android/metrics.yaml" || return 1

  # Nuke undesired Mozilla endpoints
  noop_glean_endpoints || return 1

  # Ensure we're building for release
  "${IRONFOX_SED}" -i -e 's|ext.cargoProfile = .*|ext.cargoProfile = "release"|g' "${IRONFOX_GLEAN}/build.gradle" || return 1

  # Set libxul location (for use with Tor's no-op UniFFi binding generator)
  if [[ "${IRONFOX_OS}" == 'osx' ]]; then
    "${IRONFOX_SED}" -i "s|{libxul_dir}|aarch64-linux-android/release|g" "${IRONFOX_GLEAN}/glean-core/android/build.gradle" || return 1
  else
    "${IRONFOX_SED}" -i "s|{libxul_dir}|release|g" "${IRONFOX_GLEAN}/glean-core/android/build.gradle" || return 1
  fi

  # Apply Glean overlay
  apply_overlay "${IRONFOX_GLEAN_OVERLAY}/" || return 1

  ## This is so the build script can set the uniffi path if needed (ex. if the user changes it)
  if [[ -f "${IRONFOX_TEMP}/glean/build.gradle" ]]; then
    "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/glean/build.gradle"
  fi
  "${IRONFOX_CP}" -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle" "${IRONFOX_TEMP}/glean/build.gradle" || return 1

  popd || return 1

  echo_green_text 'SUCCESS: Prepared Glean!'
}

function prepare_llvm() {
  # Ensure we have Python
  verify_exec "${IRONFOX_PYTHON}" 'IRONFOX_PYTHON' || return 1

  echo_red_text 'Preparing LLVM...'

  if [[ -n "${FDROID_BUILD+x}" ]]; then
    # Patch the LLVM source code
    # Search clang- in https://android.googlesource.com/platform/ndk/+/refs/tags/ndk-r28b/ndk/toolchains.py
    readonly LLVM_SVN='530567'
    "${IRONFOX_PYTHON}" "${toolchain_utils}/llvm_tools/patch_manager.py" \
      --svn_version $LLVM_SVN \
      --patch_metadata_file "${llvm_android}/patches/PATCHES.json" \
      --src_path "${llvm}" || return 1
  fi

  echo_green_text 'SUCCESS: Prepared LLVM!'
}

function prepare_microg() {
  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  # Ensure we have `IRONFOX_ANDROID_SDK_BUILD_TOOLS_REVISION`
  verify_env "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_REVISION}" 'IRONFOX_ANDROID_SDK_BUILD_TOOLS_REVISION' || return 1

  # Ensure we have `IRONFOX_ANDROID_MIN_SDK`
  verify_env "${IRONFOX_ANDROID_MIN_SDK}" 'IRONFOX_ANDROID_MIN_SDK' || return 1

  # Ensure we have `IRONFOX_ANDROID_TARGET_SDK`
  verify_env "${IRONFOX_ANDROID_TARGET_SDK}" 'IRONFOX_ANDROID_TARGET_SDK' || return 1

  # Ensure we have `IRONFOX_GMSCORE_ANDROID_SDK_COMPILE_VERSION`
  verify_env "${IRONFOX_GMSCORE_ANDROID_SDK_COMPILE_VERSION}" 'IRONFOX_GMSCORE_ANDROID_SDK_COMPILE_VERSION' || return 1

  echo_red_text 'Preparing microG...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_GMSCORE}" 'IRONFOX_GMSCORE' || return 1

  pushd "${IRONFOX_GMSCORE}" || return 1

  # Apply patches
  apply_patch 'microg-bump-android-sdk.patch' || return 1
  apply_patch 'microg-gradle-project-resolution.patch' || return 1
  apply_patch 'microg-localize-maven.patch' || return 1

  # Always use our Gradle wrapper with our Gradle flags/configuration
  localize_gradle || return 1

  # Set Android compile SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MAJOR}|g" "${IRONFOX_GMSCORE}/build.gradle" || return 1
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|${IRONFOX_ANDROID_COMPILE_SDK_VERSION_MINOR}|g" "${IRONFOX_GMSCORE}/build.gradle" || return 1

  # Set Android minimum SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_MIN_SDK}|${IRONFOX_ANDROID_MIN_SDK}|g" "${IRONFOX_GMSCORE}/build.gradle" || return 1

  # Set Android target SDK version
  "${IRONFOX_SED}" -i "s|{IRONFOX_ANDROID_TARGET_SDK}|${IRONFOX_ANDROID_TARGET_SDK}|g" "${IRONFOX_GMSCORE}/build.gradle" || return 1

  popd || return 1

  echo_green_text 'SUCCESS: Prepared microG!'
}

function prepare_uniffi() {
  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || return 1

  echo_red_text 'Preparing uniffi-bindgen...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_UNIFFI_DIR}" 'IRONFOX_UNIFFI_DIR' || return 1

  # Apply patches
  pushd "${IRONFOX_UNIFFI_DIR}" || return 1
  apply_patch 'uniffi-noop.patch' || return 1
  popd || return 1

  # Set Rust version
  "${IRONFOX_SED}" -i -e "s|channel = .*|channel = \""${IRONFOX_RUST_VERSION}\""|g" "${IRONFOX_UNIFFI_DIR}/rust-toolchain.toml" || return 1

  echo_green_text 'SUCCESS: Prepared uniffi-bindgen!'
}

function prepare_wasi() {
  echo_red_text 'Preparing WASI SDK...'

  # Ensure we have bash
  verify_exec "${IRONFOX_BASH}" 'IRONFOX_BASH' || return 1

  # Verify directories
  verify_dir_with_env "${IRONFOX_PREBUILDS}" 'IRONFOX_PREBUILDS' || return 1

  pushd "${IRONFOX_PREBUILDS}" || return 1
  "${IRONFOX_BASH}" "${IRONFOX_PREBUILDS}/scripts/prebuild.sh" 'wasi' || return 1
  popd || return 1

  echo_green_text 'SUCCESS: Prepared WASI SDK!'
}

function prepare_rust() {
  # Ensure we have ln
  verify_exec "${IRONFOX_LN}" 'IRONFOX_LN' || return 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || return 1

  echo_red_text 'Preparing Rust...'

  # Verify directories
  verify_dir_with_env "${IRONFOX_CONFIGS}" 'IRONFOX_CONFIGS' || return 1
  verify_dir "${IRONFOX_CONFIGS}/cargo" || return 1

  # Verify files
  verify_file "${IRONFOX_CONFIGS}/cargo/config.toml" || return 1

  # Create Cargo home directory
  "${IRONFOX_MKDIR}" -p "${IRONFOX_CARGO_HOME}"

  ## Symlink Rust (cargo) config
  if [[ ! -f "${IRONFOX_CARGO_HOME}/config.toml" ]]; then
    "${IRONFOX_LN}" -s "${IRONFOX_CONFIGS}/cargo/config.toml" "${IRONFOX_CARGO_HOME}/config.toml" || return 1
  fi

  echo_green_text 'SUCCESS: Prepared Rust!'
}

echo_red_text "Preparing to build IronFox '${IRONFOX_VERSION}'..."

# This needs to run before we prepare Android Components, to ensure that ex. patches apply properly
if [[ "${IRONFOX_PREPARE_GECKO}" == 1 ]]; then
  prepare_firefox || return 1
fi

if [[ "${IRONFOX_PREPARE_AC}" == 1 ]]; then
  prepare_ac || return 1
fi

if [[ "${IRONFOX_PREPARE_ANDROID_SDK}" == 1 ]]; then
  prepare_android_sdk || return 1
fi

if [[ "${IRONFOX_PREPARE_AS}" == 1 ]]; then
  prepare_as || return 1
fi

if [[ "${IRONFOX_PREPARE_BUNDLETOOL}" == 1 ]]; then
  prepare_bundletool || return 1
fi

if [[ "${IRONFOX_PREPARE_FENIX}" == 1 ]]; then
  prepare_fenix || return 1
fi

if [[ "${IRONFOX_PREPARE_GLEAN}" == 1 ]]; then
  prepare_glean || return 1
fi

if [[ "${IRONFOX_PREPARE_LLVM}" == 1 ]]; then
  prepare_llvm || return 1
fi

if [[ "${IRONFOX_PREPARE_MICROG}" == 1 ]]; then
  prepare_microg || return 1
fi

if [[ "${IRONFOX_PREPARE_RUST}" == 1 ]]; then
  prepare_rust || return 1
fi

if [[ "${IRONFOX_PREPARE_UNIFFI}" == 1 ]]; then
  prepare_uniffi || return 1
fi

if [[ "${IRONFOX_PREPARE_WASI}" == 1 ]]; then
  prepare_wasi || return 1
fi

echo_green_text "SUCCESS: Prepared to build IronFox '${IRONFOX_VERSION}'!"
"${IRONFOX_TOUCH}" "${IRONFOX_BUILD}/finished-prebuild"
