#!/bin/bash

set -euo pipefail

# Functions
function echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

function echo_green_text() {
	echo -e "\033[32m$1\033[0m"
}

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh
source "${IRONFOX_ENV_BUILD}"

# Include version info
source "${IRONFOX_VERSIONS}"

# Functions

function sign_apk() {
    target="$1"
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${target}-unsigned.apk"

    if [ "${IRONFOX_CI}" == 1 ]; then
        APK_OUT="${IRONFOX_APK_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}-${target}.apk"
    else
        APK_OUT="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${target}-signed.apk"
    fi

    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="file:/${IRONFOX_KEYSTORE_PASS_FILE}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="file:/${IRONFOX_KEYSTORE_KEY_PASS_FILE}" \
      --out="${APK_OUT}" \
    "${APK_IN}"
}

function sign_bundle() {
    AAB_IN="${IRONFOX_OUTPUTS_FENIX_AAB}"

    if [ "${IRONFOX_CI}" == 1 ]; then
        APKS_OUT="${IRONFOX_APKS_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}.apks"
    else
        APKS_OUT="${IRONFOX_OUTPUTS_FENIX_APKS}"
    fi

    "${IRONFOX_BUNDLETOOL}" build-apks \
      --bundle="${AAB_IN}" \
      --output="${APKS_OUT}" \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="file:/${IRONFOX_KEYSTORE_PASS_FILE}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="file:/${IRONFOX_KEYSTORE_KEY_PASS_FILE}"
}

if [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
    # Sign ARM64 APK
    echo_red_text 'Signing APK (ARM64)...'
    sign_apk 'arm64-v8a'
    echo_green_text 'SUCCESS: Signed APK (ARM64)'

    # Sign ARM APK
    echo_red_text 'Signing APK (ARM)...'
    sign_apk 'armeabi-v7a'
    echo_green_text 'SUCCESS: Signed APK (ARM)'

    # Sign x86_64 APK
    echo_red_text 'Signing APK (x86_64)...'
    sign_apk 'x86_64'
    echo_green_text 'SUCCESS: Signed APK (x86_64)'

    # Sign universal APK
    echo_red_text 'Signing APK (Universal)...'
    sign_apk 'universal'
    echo_green_text 'SUCCESS: Signed APK (Universal)'

    # Build signed APK set
    echo_red_text 'Building signed bundleset...'
    sign_bundle
    echo_green_text 'SUCCESS: Created signed bundleset'
else
    if [ -f "${IRONFOX_OUTPUTS_FENIX_ARM64_UNSIGNED}" ]; then
        # Sign ARM64 APK
        echo_red_text 'Signing APK (ARM64)...'
        sign_apk 'arm64-v8a'
        echo_green_text 'SUCCESS: Signed APK (ARM64)'
    elif [ -f "${IRONFOX_OUTPUTS_FENIX_ARM_UNSIGNED}" ]; then
        # Sign ARM APK
        echo_red_text 'Signing APK (ARM)...'
        sign_apk 'armeabi-v7a'
        echo_green_text 'SUCCESS: Signed APK (ARM)'
    elif [ -f "${IRONFOX_OUTPUTS_FENIX_X86_64_UNSIGNED}" ]; then
        # Sign x86_64 APK
        echo_red_text 'Signing APK (x86_64)...'
        sign_apk 'x86_64'
        echo_green_text 'SUCCESS: Signed APK (x86_64)'
    fi
fi
