#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -eu
set -o pipefail
set -o xtrace

source $(dirname $0)/utilities.sh

case "${BUILD_VARIANT}" in
arm64 | arm | x86_64 | bundle) ;;
*)
    echo_red_text "Unknown build variant: '${BUILD_VARIANT}'." >&2
    exit 1
    ;;
esac

export IRONFOX_CI=1

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
    # Target release
    export IRONFOX_RELEASE=1
fi

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Extract our GeckoView AAR artifacts
if [ "${BUILD_VARIANT}" == 'bundle' ]; then
    mkdir -p "${IRONFOX_DOWNLOADS}/geckoview-arm64"
    mkdir -p "${IRONFOX_DOWNLOADS}/geckoview-arm"
    mkdir -p "${IRONFOX_DOWNLOADS}/geckoview-x86_64"

    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-arm64.tar.xz" -C "${IRONFOX_DOWNLOADS}/geckoview-arm64"
    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-arm.tar.xz" -C "${IRONFOX_DOWNLOADS}/geckoview-arm"
    "${IRONFOX_TAR}" xvJf "${IRONFOX_ARTIFACTS}/build-aar-x86_64.tar.xz" -C "${IRONFOX_DOWNLOADS}/geckoview-x86_64"

    cp -vf "${IRONFOX_DOWNLOADS}/geckoview-arm64/aar/geckoview-arm64-v8a.zip" "${IRONFOX_OUTPUTS_GV_AAR_ARM64}"
    cp -vf "${IRONFOX_DOWNLOADS}/geckoview-arm/aar/geckoview-armeabi-v7a.zip" "${IRONFOX_OUTPUTS_GV_AAR_ARM}"
    cp -vf "${IRONFOX_DOWNLOADS}/geckoview-x86_64/aar/geckoview-x86_64.zip" "${IRONFOX_OUTPUTS_GV_AAR_X86_64}"
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
bash -x "${IRONFOX_SCRIPTS}/build.sh" "${BUILD_VARIANT}"
