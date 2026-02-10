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
arm64)
    ;;
arm)
    ;;
x86_64)
    ;;
bundle)
    ;;
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

# Get sources
bash -x "${IRONFOX_SCRIPTS}/get_sources.sh"

# Prepare sources
bash -x "${IRONFOX_SCRIPTS}/prebuild.sh"

# Build
bash -x "${IRONFOX_SCRIPTS}/build.sh" "${BUILD_VARIANT}"

# Include version info
source "${IRONFOX_VERSIONS}"

if [[ "${BUILD_VARIANT}" == 'bundle' ]]; then
    # Sign ARM64 APK
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-arm64-v8a-unsigned.apk"
    APK_OUT="${IRONFOX_APK_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}-arm64-v8a.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="pass:${IRONFOX_KEYSTORE_PASS}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="pass:${IRONFOX_KEYSTORE_KEY_PASS}" \
      --out="${APK_OUT}" \
      "${APK_IN}"

    # Sign ARM APK
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-armeabi-v7a-unsigned.apk"
    APK_OUT="${IRONFOX_APK_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}-armeabi-v7a.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="pass:${IRONFOX_KEYSTORE_PASS}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="pass:${IRONFOX_KEYSTORE_KEY_PASS}" \
      --out="${APK_OUT}" \
      "${APK_IN}"

    # Sign x86_64 APK
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-x86_64-unsigned.apk"
    APK_OUT="${IRONFOX_APK_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}-x86_64.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="pass:${IRONFOX_KEYSTORE_PASS}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="pass:${IRONFOX_KEYSTORE_KEY_PASS}" \
      --out="${APK_OUT}" \
      "${APK_IN}"

    # Sign universal APK
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-universal-unsigned.apk"
    APK_OUT="${IRONFOX_APK_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}-universal.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="pass:${IRONFOX_KEYSTORE_PASS}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="pass:${IRONFOX_KEYSTORE_KEY_PASS}" \
      --out="${APK_OUT}" \
      "${APK_IN}"

    # Build signed APK set
    AAB_IN="${IRONFOX_OUTPUTS_AAB}/ironfox-${IRONFOX_CHANNEL}.aab"
    APKS_OUT="${IRONFOX_APKS_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}.apks"
    "${IRONFOX_BUNDLETOOL}" build-apks \
        --bundle="${AAB_IN}" \
        --output="${APKS_OUT}" \
        --ks="${IRONFOX_KEYSTORE}" \
        --ks-pass="pass:${IRONFOX_KEYSTORE_PASS}" \
        --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
        --key-pass="pass:${IRONFOX_KEYSTORE_KEY_PASS}"
fi
