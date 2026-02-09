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
    IRONFOX_TARGET_ABI='arm64-v8a'
    ;;
arm)
    IRONFOX_TARGET_ABI='armeabi-v7a'
    ;;
x86_64)
    IRONFOX_TARGET_ABI='x86_64'
    ;;
bundle)
    IRONFOX_TARGET_ABI='bundle'
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

# Create artifact directories
mkdir -vp "${IRONFOX_AAR_ARTIFACTS}"
mkdir -vp "${IRONFOX_APK_ARTIFACTS}"
mkdir -vp "${IRONFOX_APKS_ARTIFACTS}"

# Get sources
bash -x "${IRONFOX_SCRIPTS}/get_sources.sh"

# Prepare sources
bash -x "${IRONFOX_SCRIPTS}/prebuild.sh"

if [[ "${BUILD_VARIANT}" == 'bundle' ]]; then
    export MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
    export MOZ_ANDROID_FAT_AAR_ARM64_V8A="${IRONFOX_AAR_ARTIFACTS}/geckoview-arm64-v8a.zip"
    export MOZ_ANDROID_FAT_AAR_ARMEABI_V7A="${IRONFOX_AAR_ARTIFACTS}/geckoview-armeabi-v7a.zip"
    export MOZ_ANDROID_FAT_AAR_X86_64="${IRONFOX_AAR_ARTIFACTS}/geckoview-x86_64.zip"
fi

# Build
bash -x "${IRONFOX_SCRIPTS}/build.sh" "${BUILD_VARIANT}"

# Include version info
source "${IRONFOX_VERSIONS}"

if [[ "${BUILD_VARIANT}" == 'bundle' ]]; then
    # Build signed APK set
    AAB_IN="${IRONFOX_OUTPUTS_AAB}/ironfox-${IRONFOX_CHANNEL}.aab"
    APKS_OUT="${IRONFOX_OUTPUTS_APKS}/IronFox-v${IRONFOX_VERSION}.apks"
    "${IRONFOX_BUNDLETOOL}" build-apks \
        --bundle="${AAB_IN}" \
        --output="${APKS_OUT}" \
        --ks="${IRONFOX_KEYSTORE}" \
        --ks-pass="pass:${IRONFOX_KEYSTORE_PASS}" \
        --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
        --key-pass="pass:${IRONFOX_KEYSTORE_KEY_PASS}"
else
    # Copy GeckoView AAR archives
    if [[ "${BUILD_VARIANT}" == 'arm64' ]]; then
        cp -vf "${IRONFOX_OUTPUTS_GV_AAR_ARM64}" "${IRONFOX_AAR_ARTIFACTS}/"
    elif [[ "${BUILD_VARIANT}" == 'arm' ]]; then
        cp -vf "${IRONFOX_OUTPUTS_GV_AAR_ARM}" "${IRONFOX_AAR_ARTIFACTS}/"
    elif [[ "${BUILD_VARIANT}" == 'x86_64' ]]; then
        cp -vf "${IRONFOX_OUTPUTS_GV_AAR_X86_64}" "${IRONFOX_AAR_ARTIFACTS}/"
    fi

    # Sign APK
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ABI}-unsigned.apk"
    APK_OUT="${IRONFOX_OUTPUTS_APK}/IronFox-v${IRONFOX_VERSION}-${IRONFOX_TARGET_ABI}.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="pass:${IRONFOX_KEYSTORE_PASS}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="pass:${IRONFOX_KEYSTORE_KEY_PASS}" \
      --out="${APK_OUT}" \
      "${APK_IN}"
fi
