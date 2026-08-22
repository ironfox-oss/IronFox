#!/bin/bash

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x

# Set-up our environment
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Include version info
source "${IRONFOX_VERSIONS}"

readonly target="$1"

# Functions

function sign_apk() {
  local -r apk_in="$1"
  local -r apk_out="$2"

  # Ensure the APK to sign exists
  verify_file "${apk_in}" || exit 1

  "${IRONFOX_APKSIGNER}" sign \
    --ks="${IRONFOX_ANDROID_KEYSTORE}" \
    --ks-pass="file:/${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" \
    --ks-key-alias="${IRONFOX_ANDROID_KEYSTORE_KEY_ALIAS}" \
    --key-pass="file:/${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" \
    --out="${apk_out}" \
    "${apk_in}"
}

function sign_bundle() {
  echo_red_text 'Building signed bundleset...'

  # Ensure the AAB to sign exists
  verify_file_with_env "${IRONFOX_OUTPUTS_BUNDLE_AAB}" 'IRONFOX_OUTPUTS_BUNDLE_AAB' || exit 1

  # Create our output directory
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_OUTPUTS_BUNDLE}")

  "${IRONFOX_BUNDLETOOL}" build-apks \
    --bundle="${IRONFOX_OUTPUTS_BUNDLE_AAB}" \
    --output="${IRONFOX_OUTPUTS_BUNDLE}" \
    --ks="${IRONFOX_ANDROID_KEYSTORE}" \
    --ks-pass="file:/${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" \
    --ks-key-alias="${IRONFOX_ANDROID_KEYSTORE_KEY_ALIAS}" \
    --key-pass="file:/${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" \
    --mode='universal' \
    --overwrite

  echo_green_text 'SUCCESS: Created signed bundleset'
}

function sign_arm64() {
  # Create our output directory
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_OUTPUTS_ARM64}")

  echo_red_text 'Signing APK (ARM64)...'
  sign_apk "${IRONFOX_OUTPUTS_ARM64_UNSIGNED}" "${IRONFOX_OUTPUTS_ARM64}"
  echo_green_text 'SUCCESS: Signed APK (ARM64)'
}

function sign_arm() {
  # Create our output directory
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_OUTPUTS_ARM}")

  echo_red_text 'Signing APK (ARM)...'
  sign_apk "${IRONFOX_OUTPUTS_ARM_UNSIGNED}" "${IRONFOX_OUTPUTS_ARM}"
  echo_green_text 'SUCCESS: Signed APK (ARM)'
}

function sign_x86_64() {
  # Create our output directory
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_OUTPUTS_X86_64}")

  echo_red_text 'Signing APK (x86_64)...'
  sign_apk "${IRONFOX_OUTPUTS_X86_64_UNSIGNED}" "${IRONFOX_OUTPUTS_X86_64}"
  echo_green_text 'SUCCESS: Signed APK (x86_64)'
}

function sign_universal() {
  # Create our output directory
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_OUTPUTS_UNIVERSAL}")

  echo_red_text 'Signing APK (Universal)...'
  sign_apk "${IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED}" "${IRONFOX_OUTPUTS_UNIVERSAL}"
  echo_green_text 'SUCCESS: Signed APK (Universal)'
}

# Sign ARM64 APK
if [[ "${target}" == 'arm64' ]] || [[ "${target}" == 'bundle' ]]; then
  sign_arm64
fi

# Sign ARM APK
if [[ "${target}" == 'arm' ]] || [[ "${target}" == 'bundle' ]]; then
  sign_arm
fi

# Sign x86_64 APK
if [[ "${target}" == 'x86_64' ]] || [[ "${target}" == 'bundle' ]]; then
  sign_x86_64
fi

# Sign universal APK + build signed APK set
if [[ "${target}" == 'bundle' ]]; then
  sign_universal
  sign_bundle
fi
