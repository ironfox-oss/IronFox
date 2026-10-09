#!/bin/bash

set -euo pipefail

# Set-up our environment
function setup_env() {
  if [[ -z "${IRONFOX_SET_ENVS+x}" ]] || [[ "${IRONFOX_SET_ENVS}" != 1 ]]; then
    # Find dirname
    if [[ -n "${IRONFOX_DIRNAME+x}" ]] && [[ -x "${IRONFOX_DIRNAME}" ]]; then
      local -r dirname="${IRONFOX_DIRNAME}"
    elif [[ -x '/bin/dirname' ]]; then
      local -r dirname='/bin/dirname'
    elif [[ -x '/usr/bin/dirname' ]]; then
      local -r dirname='/usr/bin/dirname'
    else
      if ! command -v dirname > /dev/null 2>&1; then
        echo "ERROR: Missing dirname!" >&2
        exit 1
      fi
      # It isn't a known location, so we sadly have to just fall-back to the PATH
      local -r dirname="$(dirname)"
    fi

    # Set-up our environment
    readonly IRONFOX_ENV_SH="$("${dirname}" $0)/env.sh"
    if [[ ! -f "${IRONFOX_ENV_SH}" ]] || [[ ! -s "${IRONFOX_ENV_SH}" ]]; then
      echo "ERROR: '${IRONFOX_ENV_SH}' is invalid!"
      exit 1
    fi
    source "${IRONFOX_ENV_SH}" || exit 1
  fi
}

# Set-up our environment
setup_env

# Ensure we have GNU awk
verify_exec "${IRONFOX_AWK}" 'IRONFOX_AWK' || exit 1

# Ensure we have `IRONFOX_LOG_BUILD`
verify_env "${IRONFOX_LOG_BUILD}" 'IRONFOX_LOG_BUILD' || exit 1

# Ensure we have `IRONFOX_LOG_SIGN`
verify_env "${IRONFOX_LOG_SIGN}" 'IRONFOX_LOG_SIGN' || exit 1

# Ensure we have `IRONFOX_SIGN`
verify_env "${IRONFOX_SIGN}" 'IRONFOX_SIGN' || exit 1

# Ensure we have `IRONFOX_SIGN_SKIP_ADB`
verify_env "${IRONFOX_SIGN_SKIP_ADB}" 'IRONFOX_SIGN_SKIP_ADB' || exit 1

# Ensure we have `IRONFOX_SCRIPTS`
verify_dir_with_env "${IRONFOX_SCRIPTS}" 'IRONFOX_SCRIPTS' || exit 1

# Ensure we have our target scripts
readonly IRONFOX_BUILD_SH="${IRONFOX_SCRIPTS}/build-if.sh"
verify_file "${IRONFOX_BUILD_SH}" || exit 1

readonly IRONFOX_SIGN_SH="${IRONFOX_SCRIPTS}/sign.sh"
if [[ "${IRONFOX_SIGN}" == 1 ]]; then
  verify_file "${IRONFOX_SIGN_SH}" || exit 1
fi

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  echo_red_text "Usage: $0 arm|arm64|x86_64|bundle" >&1
  exit 1
fi

readonly build_target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')

if [[ -z "${2+x}" ]]; then
  readonly build_project='fenix'
else
  readonly build_project=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

pushd "${IRONFOX_ROOT}"

# Build IronFox
readonly IRONFOX_FROM_BUILD=1
export IRONFOX_FROM_BUILD
if [[ "${IRONFOX_LOG_BUILD}" == 1 ]]; then
  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  # Ensure we have tee
  verify_exec "${IRONFOX_TEE}" 'IRONFOX_TEE' || exit 1

  # Ensure we have `IRONFOX_LOG_DIR`
  verify_env "${IRONFOX_LOG_DIR}" 'IRONFOX_LOG_DIR' || exit 1

  readonly BUILD_LOG_FILE="${IRONFOX_LOG_DIR}/build-${build_target}.log"

  # If the log file already exists, remove it
  if [[ -f "${BUILD_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${BUILD_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  source "${IRONFOX_BUILD_SH}" "${build_target}" "${build_project}" > >("${IRONFOX_TEE}" -a "${BUILD_LOG_FILE}") 2>&1 || exit 1
else
  source "${IRONFOX_BUILD_SH}" "${build_target}" "${build_project}" || exit 1
fi

# Ensure we have `IRONFOX_BUILT_FENIX`
verify_env "${IRONFOX_BUILT_FENIX}" 'IRONFOX_BUILT_FENIX' || exit 1

# Sign IronFox
if [[ "${IRONFOX_BUILT_FENIX}" == 1 ]] && [[ "${IRONFOX_SIGN}" == 1 ]]; then
  if [[ "${IRONFOX_LOG_SIGN}" == 1 ]]; then
    # Ensure we have mkdir
    verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

    # Ensure we have rm
    verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

    # Ensure we have tee
    verify_exec "${IRONFOX_TEE}" 'IRONFOX_TEE' || exit 1

    # Ensure we have `IRONFOX_LOG_DIR`
    verify_env "${IRONFOX_LOG_DIR}" 'IRONFOX_LOG_DIR' || exit 1

    readonly SIGN_LOG_FILE="${IRONFOX_LOG_DIR}/sign.log"

    # If the log file already exists, remove it
    if [[ -f "${SIGN_LOG_FILE}" ]]; then
      "${IRONFOX_RM}" "${SIGN_LOG_FILE}"
    fi

    # Ensure our log directory exists
    "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

    source "${IRONFOX_SIGN_SH}" "${build_target}" > >("${IRONFOX_TEE}" -a "${SIGN_LOG_FILE}") 2>&1 || exit 1
  else
    source "${IRONFOX_SIGN_SH}" "${build_target}" || exit 1
  fi
fi

# Ensure we have adb and sleep
if [[ "${IRONFOX_BUILT_FENIX}" == 1 ]] && [[ "${IRONFOX_SIGN_SKIP_ADB}" != 1 ]]; then
  verify_exec "${IRONFOX_ADB}" 'IRONFOX_ADB' || exit 1
  verify_exec "${IRONFOX_SLEEP}" 'IRONFOX_SLEEP' || exit 1
fi

# Offer to install IronFox via ADB
if [[ "${IRONFOX_BUILT_FENIX}" == 1 ]] && [[ "${IRONFOX_SIGN_SKIP_ADB}" != 1 ]]; then
  echo_red_text 'Would you like to install IronFox to a connected device?'
  read -p "If you'd like to install IronFox, please ensure your device is connected before proceeding. [y/N] " -n 1 -r
  echo
  if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
    # Ensure we have ADB
    "${IRONFOX_ADB}" devices
    if [[ "${IRONFOX_OS}" == 'osx' ]]; then
      # On OS X, the user may need to accept a prompt to allow their device to connect,
      ## so wait to ensure we allow them to accept it
      "${IRONFOX_SLEEP}" 6
    fi
    if [[ "${build_target}" == 'bundle' ]]; then
      # If we built a bundle, install the universal APK
      verify_file_with_env "${IRONFOX_OUTPUTS_UNIVERSAL}" 'IRONFOX_OUTPUTS_UNIVERSAL' || exit 1
      "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_UNIVERSAL}"
    elif [[ "${build_target}" == 'arm64' ]]; then
      # Install the ARM64 APK
      verify_file_with_env "${IRONFOX_OUTPUTS_ARM64}" 'IRONFOX_OUTPUTS_ARM64' || exit 1
      "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_ARM64}"
    elif [[ "${build_target}" == 'arm' ]]; then
      # Install the ARM APK
      verify_file_with_env "${IRONFOX_OUTPUTS_ARM}" 'IRONFOX_OUTPUTS_ARM' || exit 1
      "${IRONFOX_ADB}" install -r "${IRONFOX_OUTPUTS_ARM}"
    elif [[ "${build_target}" == 'x86_64' ]]; then
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

popd
