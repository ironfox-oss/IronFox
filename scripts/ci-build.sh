#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -eu
set -o pipefail
set -o xtrace

echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

echo_green_text() {
	echo -e "\033[32m$1\033[0m"
}

case "${BUILD_VARIANT}" in
arm)
    BUILD_TYPE='apk'
    ;;
x86_64)
    BUILD_TYPE='apk'
    ;;
arm64)
    BUILD_TYPE='apk'
    ;;
bundle)
    BUILD_TYPE='bundle'
    ;;
*)
    echo_red_text "Unknown build variant: '${BUILD_VARIANT}'." >&2
    exit 1
    ;;
esac

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
    # Target release
    export IRONFOX_RELEASE=1
fi

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Get sources
bash -x "${IRONFOX_SCRIPTS}/get_sources.sh"

# Prepare sources
bash -x "${IRONFOX_SCRIPTS}/prebuild.sh" "${BUILD_VARIANT}"

# Build
bash -x "${IRONFOX_SCRIPTS}/build.sh" "${BUILD_TYPE}"

# Include version info
source "${IRONFOX_VERSIONS}"

# Configure our build target
source "${IRONFOX_ENV_TARGET}"

if [[ "${BUILD_TYPE}" == "apk" ]]; then
    # Sign APK
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ABI}-unsigned.apk"
    APK_OUT="${IRONFOX_OUTPUTS_APK}/IronFox-v${IRONFOX_VERSION}-${IRONFOX_TARGET_ABI}.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${KEYSTORE}" \
      --ks-pass="pass:${KEYSTORE_PASS}" \
      --ks-key-alias="${KEYSTORE_KEY_ALIAS}" \
      --key-pass="pass:${KEYSTORE_KEY_PASS}" \
      --out="${APK_OUT}" \
      "${APK_IN}"
fi

if [[ "${BUILD_TYPE}" == "bundle" ]]; then
    # Sign universal APK
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-universal-unsigned.apk"
    APK_OUT="${IRONFOX_OUTPUTS_APK}/IronFox-v${IRONFOX_VERSION}-${IRONFOX_CHANNEL}-universal.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${KEYSTORE}" \
      --ks-pass="pass:${KEYSTORE_PASS}" \
      --ks-key-alias="${KEYSTORE_KEY_ALIAS}" \
      --key-pass="pass:${KEYSTORE_KEY_PASS}" \
      --out="${APK_OUT}" \
      "${APK_IN}"

    # Build signed APK set
    AAB_IN="${IRONFOX_OUTPUTS_AAB}/ironfox-${IRONFOX_CHANNEL}.aab"
    APKS_OUT="${IRONFOX_OUTPUTS_APKS}/IronFox-v${IRONFOX_VERSION}.apks"
    "${IRONFOX_BUNDLETOOL}" build-apks \
        --bundle="${AAB_IN}" \
        --output="${APKS_OUT}" \
        --ks="${KEYSTORE}" \
        --ks-pass="pass:${KEYSTORE_PASS}" \
        --ks-key-alias="${KEYSTORE_KEY_ALIAS}" \
        --key-pass="pass:${KEYSTORE_KEY_PASS}"
fi
