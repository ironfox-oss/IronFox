#!/bin/bash

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x || exit 1

# Set-up our environment
source $(dirname $0)/env.sh || exit 1

# Include utilities
source "${IRONFOX_UTILS}" || exit 1

# Include version info
source "${IRONFOX_VERSIONS}" || exit 1

readonly target="$1"

# Fail early if our inputs are missing...

## ARM64
if [[ "${target}" == 'arm64' ]] || [[ "${target}" == 'bundle' ]]; then
  verify_file_with_env "${IRONFOX_OUTPUTS_ARM64_UNSIGNED}" 'IRONFOX_OUTPUTS_ARM64_UNSIGNED' || exit 1
fi

# ARM
if [[ "${target}" == 'arm' ]] || [[ "${target}" == 'bundle' ]]; then
  verify_file_with_env "${IRONFOX_OUTPUTS_ARM_UNSIGNED}" 'IRONFOX_OUTPUTS_ARM_UNSIGNED' || exit 1
fi

# x86_64
if [[ "${target}" == 'x86_64' ]] || [[ "${target}" == 'bundle' ]]; then
  verify_file_with_env "${IRONFOX_OUTPUTS_X86_64_UNSIGNED}" 'IRONFOX_OUTPUTS_X86_64_UNSIGNED' || exit 1
fi

# Universal APK + AAB
if [[ "${target}" == 'bundle' ]]; then
  verify_file_with_env "${IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED}" 'IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED' || exit 1
  verify_file_with_env "${IRONFOX_OUTPUTS_BUNDLE_AAB}" 'IRONFOX_OUTPUTS_BUNDLE_AAB' || exit 1
fi

# Sign an APK
function sign_apk() {
  function print_usage() {
    echo "Usage: sign_apk '/path/to/apk' '/path/to/signed_apk'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to the APK to sign!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to where the signed APK should be placed!'
    print_usage
    exit 1
  fi

  # Ensure we have apksigner
  verify_exec "${IRONFOX_APKSIGNER}" 'IRONFOX_APKSIGNER' || exit 1

  # Ensure we have dirname
  verify_exec "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  local -r unsigned_apk="$1"
  local -r signed_apk="$2"

  # Ensure the unsigned APK is valid
  verify_file "${unsigned_apk}" || exit 1

  # Ensure our secrets are valid
  verify_file_with_env "${IRONFOX_ANDROID_KEYSTORE}" || exit 1
  verify_file_with_env "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" || exit 1
  verify_file_with_env "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" || exit 1

  # If the directory for our output signed APK doesn't exist, create it
  local -r signed_apk_dir="$("${IRONFOX_DIRNAME}" "${signed_apk}")"
  if [[ ! -d "${signed_apk_dir}" ]]; then
    "${IRONFOX_MKDIR}" -p "${signed_apk_dir}"
  fi

  echo_red_text "Signing APK: '${unsigned_apk}' (Output: '${signed_apk}')..."
  "${IRONFOX_APKSIGNER}" sign \
    --ks="${IRONFOX_ANDROID_KEYSTORE}" \
    --ks-pass="file:/${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" \
    --ks-key-alias="${IRONFOX_ANDROID_KEYSTORE_KEY_ALIAS}" \
    --key-pass="file:/${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" \
    --out="${signed_apk}" \
    "${unsigned_apk}"

  # Ensure nothing went wrong...
  verify_file "${signed_apk}" || exit 1

  echo_green_text "SUCCESS: Signed APK: '${unsigned_apk}' (Output: '${signed_apk}')!"
}

# Sign an AAB (to produce an ApkSet)
function sign_apkset() {
  function print_usage() {
    echo "Usage: sign_apkset '/path/to/aab' '/path/to/signed_apkset'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to the AAB to sign!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to where the signed ApkSet should be placed!'
    print_usage
    exit 1
  fi

  # Ensure we have bundletool
  verify_exec "${IRONFOX_BUNDLETOOL}" 'IRONFOX_BUNDLETOOL' || exit 1

  # Ensure we have dirname
  verify_exec "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  local -r aab="$1"
  local -r apkset="$2"

  # Ensure the unsigned AAB is valid
  verify_file "${aab}" || exit 1

  # Ensure our secrets are valid
  verify_file_with_env "${IRONFOX_ANDROID_KEYSTORE}" || exit 1
  verify_file_with_env "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" || exit 1
  verify_file_with_env "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" || exit 1

  # If the directory for our output signed APK doesn't exist, create it
  local -r apkset_dir="$("${IRONFOX_DIRNAME}" "${apkset}")"
  if [[ ! -d "${apkset_dir}" ]]; then
    "${IRONFOX_MKDIR}" -p "${apkset_dir}"
  fi

  echo_red_text "Signing AAB: '${aab}' (Output: '${apkset}')..."
  "${IRONFOX_BUNDLETOOL}" build-apks \
    --bundle="${aab}" \
    --output="${apkset}" \
    --ks="${IRONFOX_ANDROID_KEYSTORE}" \
    --ks-pass="file:/${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" \
    --ks-key-alias="${IRONFOX_ANDROID_KEYSTORE_KEY_ALIAS}" \
    --key-pass="file:/${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" \
    --mode='universal' \
    --overwrite

  # Ensure nothing went wrong...
  verify_file "${apkset}" || exit 1

  echo_green_text "SUCCESS: Signed AAB: '${aab}' (Output: '${apkset}')!"
}

# Sign ARM64 APK
if [[ "${target}" == 'arm64' ]] || [[ "${target}" == 'bundle' ]]; then
  sign_apk "${IRONFOX_OUTPUTS_ARM64_UNSIGNED}" "${IRONFOX_OUTPUTS_ARM64}" || exit 1
fi

# Sign ARM APK
if [[ "${target}" == 'arm' ]] || [[ "${target}" == 'bundle' ]]; then
  sign_apk "${IRONFOX_OUTPUTS_ARM_UNSIGNED}" "${IRONFOX_OUTPUTS_ARM}" || exit 1
fi

# Sign x86_64 APK
if [[ "${target}" == 'x86_64' ]] || [[ "${target}" == 'bundle' ]]; then
  sign_apk "${IRONFOX_OUTPUTS_X86_64_UNSIGNED}" "${IRONFOX_OUTPUTS_X86_64}" || exit 1
fi

# Sign universal APK + build signed APK set
if [[ "${target}" == 'bundle' ]]; then
  sign_apk "${IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED}" "${IRONFOX_OUTPUTS_UNIVERSAL}" || exit 1
  sign_apkset "${IRONFOX_OUTPUTS_BUNDLE_AAB}" "${IRONFOX_OUTPUTS_BUNDLE}" || exit 1
fi
