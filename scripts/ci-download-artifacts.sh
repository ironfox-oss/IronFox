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

# Ensure we have `IRONFOX_CI`
verify_env "${IRONFOX_CI}" 'IRONFOX_CI' || exit 1

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  exit 1
fi

# Ensure we have GNU awk
verify_exec "${IRONFOX_AWK}" 'IRONFOX_AWK' || exit 1

# Ensure we have `IRONFOX_LOG_AR_DOWN`
verify_env "${IRONFOX_LOG_AR_DOWN}" 'IRONFOX_LOG_AR_DOWN' || exit 1

# Ensure we have `IRONFOX_SCRIPTS`
verify_dir_with_env "${IRONFOX_SCRIPTS}" 'IRONFOX_SCRIPTS' || exit 1

# Ensure we have our target script
readonly IRONFOX_AR_DOWN_SH="${IRONFOX_SCRIPTS}/ci-download-artifacts-if.sh"
verify_file "${IRONFOX_AR_DOWN_SH}" || exit 1

# Set our CI ID
## For GitLab, we use the pipeline ID
verify_env "${CI_PIPELINE_ID}" 'CI_PIPELINE_ID' || exit 1
readonly IRONFOX_CI_ID="${CI_PIPELINE_ID}"
export IRONFOX_CI_ID

# Set-up target parameters
readonly target_artifact=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
readonly target_arch=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')

pushd "${IRONFOX_ROOT}"

# Download our artifacts
readonly IRONFOX_FROM_AR_DOWN=1
export IRONFOX_FROM_AR_DOWN
if [[ "${IRONFOX_LOG_AR_DOWN}" == 1 ]]; then
  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  # Ensure we have tee
  verify_exec "${IRONFOX_TEE}" 'IRONFOX_TEE' || exit 1

  # Ensure we have `IRONFOX_LOG_DIR`
  verify_env "${IRONFOX_LOG_DIR}" 'IRONFOX_LOG_DIR' || exit 1

  readonly AR_DOWN_LOG_FILE="${IRONFOX_LOG_DIR}/download-artifacts-${IRONFOX_CI_ID}-${target_artifact}.log"

  # If the log file already exists, remove it
  if [[ -f "${AR_DOWN_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${AR_DOWN_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  source "${IRONFOX_AR_DOWN_SH}" "${target_artifact}" "${target_arch}" > >("${IRONFOX_TEE}" -a "${AR_DOWN_LOG_FILE}") 2>&1 || exit 1
else
  source "${IRONFOX_AR_DOWN_SH}" "${target_artifact}" "${target_arch}" || exit 1
fi

popd
