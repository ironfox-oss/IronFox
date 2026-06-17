#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
    export IRONFOX_CI=1
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [[ -z "${IRONFOX_FROM_CI_BUILD+x}" ]]; then
    echo_red_text 'ERROR: Do not call ci-build-if.sh directly. Instead, use ci-build.sh.' >&1
    exit 1
fi

readonly ci_build_arch="$1"

case "${ci_build_arch}" in
arm64|arm|x86_64|bundle)
    ;;
*)
    echo_red_text "Unknown build variant: '${ci_build_arch}'." >&2
    exit 1
    ;;
esac

readonly ci_build_project="$2"

# (For now, we only want to build Fenix and GeckoView directly from CI)
case "${ci_build_project}" in
fenix|geckoview)
    ;;
*)
    echo_red_text "Unknown build project: '${ci_build_project}'." >&2
    exit 1
    ;;
esac

if [[ "${ci_build_project}" == 'fenix' ]]; then
    # Fail-fast in case the signing key is unavailable or empty file
    if [[ ! -f "${IRONFOX_ANDROID_KEYSTORE}" ]]; then
        echo_red_text "ERROR: Keystore file ${IRONFOX_ANDROID_KEYSTORE} does not exist!"
        exit 1
    fi

    if [[ ! -s "${IRONFOX_ANDROID_KEYSTORE}" ]]; then
        echo_red_text "ERROR: Keystore file ${IRONFOX_ANDROID_KEYSTORE} is empty!"
        exit 1
    fi
fi

if [[ "${ci_build_arch}" == 'bundle' ]]; then
    # Extract our GeckoView AAR artifacts
    mkdir -vp "${IRONFOX_GECKOVIEW_AAR_ARM64_DIR}"
    mkdir -vp "${IRONFOX_GECKOVIEW_AAR_ARM_DIR}"
    mkdir -vp "${IRONFOX_GECKOVIEW_AAR_X86_64_DIR}"

    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-arm64.tar.xz" -C "${IRONFOX_GECKOVIEW_AAR_ARM64_DIR}"
    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-arm.tar.xz" -C "${IRONFOX_GECKOVIEW_AAR_ARM_DIR}"
    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-x86_64.tar.xz" -C "${IRONFOX_GECKOVIEW_AAR_X86_64_DIR}"
fi

# Get sources
if [[ "${ci_build_project}" == 'geckoview' ]]; then
    # If we're only building GeckoView, we don't need to download all sources
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'python'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'uv'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-ndk'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-25'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-build-tools'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform-36'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform-tools'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'rust'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'cbindgen'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'bundletool'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'firefox'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-17'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-21'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'gradle'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'gyp'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'microg'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'node'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'npm'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'phoenix'
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh" 'wasi'
else
    bash -x "${IRONFOX_SCRIPTS}/get_sources.sh"
fi

# Prepare sources
if [[ "${ci_build_project}" == 'geckoview' ]]; then
    # If we're only building GeckoView, we don't need to prepare all sources
    bash -x "${IRONFOX_SCRIPTS}/prebuild.sh" 'firefox'
    bash -x "${IRONFOX_SCRIPTS}/prebuild.sh" 'android-sdk'
    bash -x "${IRONFOX_SCRIPTS}/prebuild.sh" 'microg'
    bash -x "${IRONFOX_SCRIPTS}/prebuild.sh" 'rust'
else
    bash -x "${IRONFOX_SCRIPTS}/prebuild.sh"
fi

# Build
bash -x "${IRONFOX_SCRIPTS}/build.sh" "${ci_build_arch}" "${ci_build_project}"

# Copy our GeckoView AAR archives to the artifacts directory for publishing
if [[ "${ci_build_project}" == 'geckoview' ]]; then
    mkdir -vp "${IRONFOX_AAR_ARTIFACTS}"
    if [[ "${ci_build_arch}" == 'arm64' ]]; then
        cp -v "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64}" "${IRONFOX_AAR_ARTIFACTS}/"
    elif [[ "${ci_build_arch}" == 'arm' ]]; then
        cp -v "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM}" "${IRONFOX_AAR_ARTIFACTS}/"
    elif [[ "${ci_build_arch}" == 'x86_64' ]]; then
        cp -v "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64}" "${IRONFOX_AAR_ARTIFACTS}/"
    fi
fi

# Copy our Fenix outputs to the artifacts directory for publishing
if [[ "${ci_build_project}" == 'fenix' ]]; then
    mkdir -vp "${IRONFOX_APK_ARTIFACTS}"
    mkdir -vp "${IRONFOX_APKS_ARTIFACTS}"

    cp -v "${IRONFOX_OUTPUTS_ARM64}" "${IRONFOX_APK_ARTIFACTS}/"
    cp -v "${IRONFOX_OUTPUTS_ARM}" "${IRONFOX_APK_ARTIFACTS}/"
    cp -v "${IRONFOX_OUTPUTS_X86_64}" "${IRONFOX_APK_ARTIFACTS}/"
    cp -v "${IRONFOX_OUTPUTS_UNIVERSAL}" "${IRONFOX_APK_ARTIFACTS}/"
    cp -v "${IRONFOX_OUTPUTS_BUNDLE}" "${IRONFOX_APKS_ARTIFACTS}/"
fi
