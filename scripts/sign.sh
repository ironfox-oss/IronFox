#!/bin/bash

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

readonly target="$1"

# Include version info
source "${IRONFOX_VERSIONS}"

# Temporarily add Java to PATH, as apksigner requires it
export PATH="${IRONFOX_JAVA_HOME}/bin:${PATH}"

# Functions

function sign_apk() {
    local readonly target_arch="$1"
    local readonly APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${target_arch}-unsigned.apk"

    if [ "${IRONFOX_CI}" == 1 ]; then
        local readonly APK_OUT="${IRONFOX_APK_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}-${target_arch}.apk"
    else
        local readonly APK_OUT="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${target_arch}-signed.apk"
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

    if [ "${IRONFOX_CI}" == 1 ]; then
        local readonly APKS_OUT="${IRONFOX_APKS_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}.apks"
    else
        local readonly APKS_OUT="${IRONFOX_OUTPUTS_FENIX_APKS}"
    fi

    "${IRONFOX_BUNDLETOOL}" build-apks \
      --bundle="${IRONFOX_OUTPUTS_FENIX_AAB}" \
      --output="${APKS_OUT}" \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="file:/${IRONFOX_KEYSTORE_PASS_FILE}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="file:/${IRONFOX_KEYSTORE_KEY_PASS_FILE}"

    echo_green_text 'SUCCESS: Created signed bundleset'
}

if [ "${target}" == 'bundle' ]; then
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
elif [ "${target}" == 'arm64' ]; then
    # Sign ARM64 APK
    sign_arm64
elif [ "${target}" == 'arm' ]; then
    # Sign ARM APK
    sign_arm
elif [ "${target}" == 'x86_64' ]; then
    # Sign x86_64 APK
    sign_x86_64
else
    echo_red_text "ERROR: Unknown target architecture: ${target}"
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
        if [ "${target}" == 'bundle' ]; then
            # If we built a bundle, install the universal APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_FENIX_UNIVERSAL_SIGNED}"
        elif [ "${target}" == 'arm64' ]; then
            # Install the ARM64 APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_FENIX_ARM64_SIGNED}"
        elif [ "${target}" == 'arm' ]; then
            # Install the ARM APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_FENIX_ARM_SIGNED}"
        elif [ "${target}" == 'x86_64' ]; then
            # Install the x86_64 APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_FENIX_X86_64_SIGNED}"
        fi
        # Now that the app is installed, we can kill the server
        "${IRONFOX_ADB}" kill-server
    else
        exit 0
    fi
fi
