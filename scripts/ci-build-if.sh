#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [[ -z "${IRONFOX_FROM_CI_BUILD+x}" ]]; then
    echo_red_text 'ERROR: Do not call ci-build-if.sh directly. Instead, use ci-build.sh.' >&1
    exit 1
fi

readonly ci_build_target="$1"

case "${ci_build_target}" in
arm64|arm|x86_64|bundle)
    ;;
*)
    echo_red_text "Unknown build variant: '${ci_build_target}'." >&2
    exit 1
    ;;
esac

# Extract our GeckoView AAR artifacts
if [ "${ci_build_target}" == 'bundle' ]; then
    mkdir -vp "${IRONFOX_GECKOVIEW_AAR_ARM64_DIR}"
    mkdir -vp "${IRONFOX_GECKOVIEW_AAR_ARM_DIR}"
    mkdir -vp "${IRONFOX_GECKOVIEW_AAR_X86_64_DIR}"

    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-arm64.tar.xz" -C "${IRONFOX_GECKOVIEW_AAR_ARM64_DIR}"
    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-arm.tar.xz" -C "${IRONFOX_GECKOVIEW_AAR_ARM_DIR}"
    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-x86_64.tar.xz" -C "${IRONFOX_GECKOVIEW_AAR_X86_64_DIR}"
fi

# Fail-fast in case the signing key is unavailable or empty file
if ! [[ -f "${IRONFOX_KEYSTORE}" ]]; then
    echo_red_text "ERROR: Keystore file ${IRONFOX_KEYSTORE} does not exist!"
    exit 1
fi

if ! [[ -s "${IRONFOX_KEYSTORE}" ]]; then
    echo_red_text "ERROR: Keystore file ${IRONFOX_KEYSTORE} is empty!"
    exit 1
fi

# Get sources
bash -x "${IRONFOX_SCRIPTS}/get_sources.sh"

# Prepare sources
bash -x "${IRONFOX_SCRIPTS}/prebuild.sh"

# Build
bash -x "${IRONFOX_SCRIPTS}/build.sh" "${ci_build_target}"

# Copy our GeckoView AAR archives to the artifacts directory for publishing
mkdir -vp "${IRONFOX_AAR_ARTIFACTS}"
if [ "${ci_build_target}" == 'arm64' ]; then
    cp -v "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64}" "${IRONFOX_AAR_ARTIFACTS}/"
elif [ "${ci_build_target}" == 'arm' ]; then
    cp -v "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM}" "${IRONFOX_AAR_ARTIFACTS}/"
elif [ "${ci_build_target}" == 'x86_64' ]; then
    cp -v "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64}" "${IRONFOX_AAR_ARTIFACTS}/"
fi

# Copy our Fenix outputs to the artifacts directory for publishing
if [ "${ci_build_target}" == 'bundle' ]; then
    mkdir -vp "${IRONFOX_APK_ARTIFACTS}"
    mkdir -vp "${IRONFOX_APKS_ARTIFACTS}"

    cp -v "${IRONFOX_OUTPUTS_ARM64}" "${IRONFOX_APK_ARTIFACTS}/"
    cp -v "${IRONFOX_OUTPUTS_ARM}" "${IRONFOX_APK_ARTIFACTS}/"
    cp -v "${IRONFOX_OUTPUTS_X86_64}" "${IRONFOX_APK_ARTIFACTS}/"
    cp -v "${IRONFOX_OUTPUTS_UNIVERSAL}" "${IRONFOX_APK_ARTIFACTS}/"
fi
