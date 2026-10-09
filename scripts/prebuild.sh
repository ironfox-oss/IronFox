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

# Ensure we have `IRONFOX_LOG_PREBUILD`
verify_env "${IRONFOX_LOG_PREBUILD}" 'IRONFOX_LOG_PREBUILD' || exit 1

# Ensure we have `IRONFOX_SCRIPTS`
verify_dir_with_env "${IRONFOX_SCRIPTS}" 'IRONFOX_SCRIPTS' || exit 1

# Ensure we have our target script
readonly IRONFOX_PREBUILD_SH="${IRONFOX_SCRIPTS}/prebuild-if.sh"
verify_file "${IRONFOX_PREBUILD_SH}" || exit 1

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  readonly prebuild_target='all'
else
  readonly prebuild_target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# Prepare to build IronFox
readonly IRONFOX_FROM_PREBUILD=1
export IRONFOX_FROM_PREBUILD
if [[ "${IRONFOX_LOG_PREBUILD}" == 1 ]]; then
  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  # Ensure we have tee
  verify_exec "${IRONFOX_TEE}" 'IRONFOX_TEE' || exit 1

  # Ensure we have `IRONFOX_LOG_DIR`
  verify_env "${IRONFOX_LOG_DIR}" 'IRONFOX_LOG_DIR' || exit 1

  readonly PREBUILD_LOG_FILE="${IRONFOX_LOG_DIR}/prebuild.log"

  # If the log file already exists, remove it
  if [[ -f "${PREBUILD_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${PREBUILD_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  source "${IRONFOX_PREBUILD_SH}" "${prebuild_target}" > >("${IRONFOX_TEE}" -a "${PREBUILD_LOG_FILE}") 2>&1 || exit 1
else
  source "${IRONFOX_PREBUILD_SH}" "${prebuild_target}" || exit 1
fi
