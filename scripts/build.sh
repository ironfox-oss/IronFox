#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash $(dirname $0)/env.sh || exit 1
fi
source $(dirname $0)/env.sh || exit 1

# Include utilities
source "${IRONFOX_UTILS}" || exit 1

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  echo_red_text "Usage: $0 arm|arm64|x86_64|bundle" >&1
  exit 1
fi

readonly target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')

if [[ -z "${2+x}" ]]; then
  readonly project='fenix'
else
  readonly project=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# Build IronFox
readonly IRONFOX_FROM_BUILD=1
export IRONFOX_FROM_BUILD
if [[ "${IRONFOX_LOG_BUILD}" == 1 ]]; then
  readonly BUILD_LOG_FILE="${IRONFOX_LOG_DIR}/build-${target}.log"

  # If the log file already exists, remove it
  if [[ -f "${BUILD_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${BUILD_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  /bin/bash "${IRONFOX_SCRIPTS}/build-if.sh" "${target}" "${project}" > >("${IRONFOX_TEE}" -a "${BUILD_LOG_FILE}") 2>&1 || exit 1
else
  /bin/bash "${IRONFOX_SCRIPTS}/build-if.sh" "${target}" "${project}" || exit 1
fi

# We should only try to sign IronFox if we actually built Fenix, so check that first
## (All `rebuild-` targets eventually build Fenix, because eventually Fenix consumes everything...)
if [[ "${project}" == 'fenix' ]] || [[ "${project}" == 'rebuild-ac-core' ]] || [[ "${project}" == 'rebuild-ac' ]] ||
  [[ "${project}" == 'rebuild-as' ]] || [[ "${project}" == 'rebuild-fenix' ]] || [[ "${project}" == 'rebuild-gecko' ]] ||
  [[ "${project}" == 'rebuild-geckoview' ]] || [[ "${project}" == 'rebuild-glean' ]] || [[ "${project}" == 'rebuild-ironfox-core' ]] ||
  [[ "${project}" == 'rebuild-llvm' ]] || [[ "${project}" == 'rebuild-microg' ]] || [[ "${project}" == 'rebuild-nimbus-fml' ]] ||
  [[ "${project}" == 'rebuild-phoenix' ]] || [[ "${project}" == 'rebuild-uniffi' ]] || [[ "${project}" == 'rebuild-up-ac' ]] ||
  [[ "${project}" == 'rebuild-wasi' ]]; then
  readonly IRONFOX_BUILT_FENIX=1
else
  readonly IRONFOX_BUILT_FENIX=0
fi

# Sign IronFox
if [[ "${IRONFOX_SIGN}" == 1 ]] && [[ "${IRONFOX_BUILT_FENIX}" == 1 ]]; then
  if [[ "${IRONFOX_LOG_SIGN}" == 1 ]]; then
    readonly SIGN_LOG_FILE="${IRONFOX_LOG_DIR}/sign.log"

    # If the log file already exists, remove it
    if [[ -f "${SIGN_LOG_FILE}" ]]; then
      "${IRONFOX_RM}" "${SIGN_LOG_FILE}"
    fi

    # Ensure our log directory exists
    "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

    /bin/bash "${IRONFOX_SCRIPTS}/sign.sh" "${target}" > >("${IRONFOX_TEE}" -a "${SIGN_LOG_FILE}") 2>&1 || exit 1
  else
    /bin/bash "${IRONFOX_SCRIPTS}/sign.sh" "${target}" || exit 1
  fi
fi

# Offer to install IronFox via ADB
if [[ "${IRONFOX_SIGN_SKIP_ADB}" != 1 ]]; then
  echo_red_text 'Would you like to install IronFox to a connected device?'
  read -p "If you'd like to install IronFox, please ensure your device is connected before proceeding. [y/N] " -n 1 -r
  echo
  if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
    # Ensure we have ADB
    verify_exec "${IRONFOX_ADB}" 'IRONFOX_ADB' || exit 1
    "${IRONFOX_ADB}" devices
    if [[ "${IRONFOX_OS}" == 'osx' ]]; then
      # On OS X, the user may need to accept a prompt to allow their device to connect,
      ## so wait to ensure we allow them to accept it
      "${IRONFOX_SLEEP}" 6
    fi
    if [[ "${target}" == 'bundle' ]]; then
      # If we built a bundle, install the universal APK
      verify_file_with_env "${IRONFOX_OUTPUTS_UNIVERSAL}" 'IRONFOX_OUTPUTS_UNIVERSAL' || exit 1
      "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_UNIVERSAL}"
    elif [[ "${target}" == 'arm64' ]]; then
      # Install the ARM64 APK
      verify_file_with_env "${IRONFOX_OUTPUTS_ARM64}" 'IRONFOX_OUTPUTS_ARM64' || exit 1
      "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_ARM64}"
    elif [[ "${target}" == 'arm' ]]; then
      # Install the ARM APK
      verify_file_with_env "${IRONFOX_OUTPUTS_ARM}" 'IRONFOX_OUTPUTS_ARM' || exit 1
      "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_ARM}"
    elif [[ "${target}" == 'x86_64' ]]; then
      # Install the x86_64 APK
      verify_file_with_env "${IRONFOX_OUTPUTS_X86_64}" 'IRONFOX_OUTPUTS_X86_64' || exit 1
      "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_X86_64}"
    fi
    # Now that the app is installed, we can kill the server
    "${IRONFOX_ADB}" kill-server
  else
    exit 0
  fi
fi
