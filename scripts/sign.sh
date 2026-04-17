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
    local readonly apk_in="$1"
    local readonly apk_out="$2"

    "${IRONFOX_APKSIGNER}" sign \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="file:/${IRONFOX_KEYSTORE_PASS_FILE}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="file:/${IRONFOX_KEYSTORE_KEY_PASS_FILE}" \
      --out="${apk_out}" \
    "${apk_in}"
}

function sign_bundle() {
    echo_red_text 'Building signed bundleset...'

   # Create our output directory
   mkdir -p $(dirname "${IRONFOX_OUTPUTS_BUNDLE}")

    "${IRONFOX_BUNDLETOOL}" build-apks \
      --bundle="${IRONFOX_OUTPUTS_BUNDLE_AAB}" \
      --output="${IRONFOX_OUTPUTS_BUNDLE}" \
      --ks="${IRONFOX_KEYSTORE}" \
      --ks-pass="file:/${IRONFOX_KEYSTORE_PASS_FILE}" \
      --ks-key-alias="${IRONFOX_KEYSTORE_KEY_ALIAS}" \
      --key-pass="file:/${IRONFOX_KEYSTORE_KEY_PASS_FILE}"

    echo_green_text 'SUCCESS: Created signed bundleset'
}

function sign_arm64() {
    # Create our output directory
    mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM64}")

    echo_red_text 'Signing APK (ARM64)...'
    sign_apk "${IRONFOX_OUTPUTS_ARM64_UNSIGNED}" "${IRONFOX_OUTPUTS_ARM64}"
    echo_green_text 'SUCCESS: Signed APK (ARM64)'
}

function sign_arm() {
    # Create our output directory
    mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM}")

    echo_red_text 'Signing APK (ARM)...'
    sign_apk "${IRONFOX_OUTPUTS_ARM_UNSIGNED}" "${IRONFOX_OUTPUTS_ARM}"
    echo_green_text 'SUCCESS: Signed APK (ARM)'
}

function sign_x86_64() {
    # Create our output directory
    mkdir -p $(dirname "${IRONFOX_OUTPUTS_X86_64}")

    echo_red_text 'Signing APK (x86_64)...'
    sign_apk "${IRONFOX_OUTPUTS_X86_64_UNSIGNED}" "${IRONFOX_OUTPUTS_X86_64}"
    echo_green_text 'SUCCESS: Signed APK (x86_64)'
}

function sign_universal() {
    # Create our output directory
    mkdir -p $(dirname "${IRONFOX_OUTPUTS_UNIVERSAL}")

    echo_red_text 'Signing APK (Universal)...'
    sign_apk "${IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED}" "${IRONFOX_OUTPUTS_UNIVERSAL}"
    echo_green_text 'SUCCESS: Signed APK (Universal)'
}

# Sign ARM64 APK
if [ "${target}" == 'arm64' ] || [ "${target}" == 'bundle' ]; then
    sign_arm64
fi

# Sign ARM APK
if [ "${target}" == 'arm' ] || [ "${target}" == 'bundle' ]; then
    sign_arm
fi

# Sign x86_64 APK
if [ "${target}" == 'x86_64' ] || [ "${target}" == 'bundle' ]; then
    sign_x86_64
fi

# Sign universal APK + build signed APK set
if [ "${target}" == 'bundle' ]; then
    sign_universal
    sign_bundle
fi

if [ "${IRONFOX_SIGN_SKIP_ADB}" != 1 ]; then
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
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_UNIVERSAL}"
        elif [ "${target}" == 'arm64' ]; then
            # Install the ARM64 APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_ARM64}"
        elif [ "${target}" == 'arm' ]; then
            # Install the ARM APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_ARM}"
        elif [ "${target}" == 'x86_64' ]; then
            # Install the x86_64 APK
            "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_X86_64}"
        fi
        # Now that the app is installed, we can kill the server
        "${IRONFOX_ADB}" kill-server
    else
        exit 0
    fi
fi
