#!/bin/bash

set -euo pipefail

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh
source "${IRONFOX_ENV_BUILD}"

# Include version info
source "${IRONFOX_VERSIONS}"

# Temporarily add Java to PATH, as apksigner requires it
export PATH="${IRONFOX_JAVA_HOME}/bin:${PATH}"

# Functions

function sign_apk() {
    target="$1"
    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${target}-unsigned.apk"

    if [ "${IRONFOX_CI}" == 1 ]; then
        APK_OUT="${IRONFOX_APK_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}-${target}.apk"
    else
        APK_OUT="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${target}-signed.apk"
    fi

    "${IRONFOX_APKSIGNER}" sign \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="file:/${IRONFOX_KEYSTORE_PASS_FILE}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="file:/${IRONFOX_KEYSTORE_KEY_PASS_FILE}" \
      --out="${APK_OUT}" \
    "${APK_IN}"
}

function sign_arm64() {
    echo_red_text 'Signing APK (ARM64)...'
    sign_apk 'arm64-v8a'
    echo_green_text 'SUCCESS: Signed APK (ARM64)'
}

function sign_arm() {
    echo_red_text 'Signing APK (ARM)...'
    sign_apk 'armeabi-v7a'
    echo_green_text 'SUCCESS: Signed APK (ARM)'
}

function sign_x86_64() {
    echo_red_text 'Signing APK (x86_64)...'
    sign_apk 'x86_64'
    echo_green_text 'SUCCESS: Signed APK (x86_64)'
}

function sign_universal() {
    echo_red_text 'Signing APK (Universal)...'
    sign_apk 'universal'
    echo_green_text 'SUCCESS: Signed APK (Universal)'
}

function sign_bundle() {
    echo_red_text 'Building signed bundleset...'

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

    echo_green_text 'SUCCESS: Created signed bundleset'
}

if [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
    # Sign ARM64 APK
    sign_arm64

    # Sign ARM APK
    sign_arm

    # Sign x86_64 APK
    sign_x86_64

    # Sign universal APK
    sign_universal

    # Build signed APK set
    sign_bundle
elif [ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]; then
    # Sign ARM64 APK
    sign_arm64
elif [ "${IRONFOX_TARGET_ARCH}" == 'arm' ]; then
    # Sign ARM APK
    sign_arm
elif [ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]; then
    # Sign x86_64 APK
    sign_x86_64
else
    echo_red_text "ERROR: Unknown target architecture: ${IRONFOX_TARGET_ARCH}"
    exit 1
fi

if [ "${IRONFOX_CI}" != 1 ]; then
    echo_red_text 'Would you like to install IronFox to a connected device?'
    read -p "If you'd like to install IronFox, please ensure your device is connected before proceeding. [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        "${IRONFOX_ADB}" devices
        if [[ "${IRONFOX_OS}" == 'osx' ]]; then
            # On OS X, the user may need to accept a prompt to allow their device to connect,
            ## so wait to ensure we allow them to accept it
            /bin/sleep 6
        fi
        if [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
            # If we built a bundle, install the universal APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_FENIX_UNIVERSAL_SIGNED}"
        elif [ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]; then
            # Install the ARM64 APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_FENIX_ARM64_SIGNED}"
        elif [ "${IRONFOX_TARGET_ARCH}" == 'arm' ]; then
            # Install the ARM APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_FENIX_ARM_SIGNED}"
        elif [ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]; then
            # Install the x86_64 APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_FENIX_X86_64_SIGNED}"
        fi
        # Now that the app is installed, we can kill the server
        "${IRONFOX_ADB}" kill-server
    else
        exit 0
    fi
fi
