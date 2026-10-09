#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

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

# Set verbosity
set_verbosity

# Ensure we have `IRONFOX_CI`
verify_env "${IRONFOX_CI}" 'IRONFOX_CI' || exit 1

# Ensure we have `IRONFOX_ARTIFACTS`
verify_env "${IRONFOX_ARTIFACTS}" 'IRONFOX_ARTIFACTS' || exit 1

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  exit 1
fi

# Ensure we have touch
verify_exec "${IRONFOX_TOUCH}" 'IRONFOX_TOUCH' || exit 1

readonly artifact_name="$1"
readonly artifact_archive="${artifact_name}.tar.xz"
readonly artifact_path="${IRONFOX_ARTIFACTS}/${artifact_archive}"

function ironfox_package_artifacts() {
  # Ensure we have find
  verify_exec "${IRONFOX_FIND}" 'IRONFOX_FIND' || exit 1

  # Ensure we have GNU tar
  verify_exec "${IRONFOX_TAR}" 'IRONFOX_TAR' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have tr
  verify_exec "${IRONFOX_TR}" 'IRONFOX_TR' || exit 1

  # For debugging purposes
  echo "Listing available artifacts"
  "${IRONFOX_FIND}" "${IRONFOX_ARTIFACTS}"

  local -r includes=$(echo "${IRONFOX_ARTIFACT_INCLUDES}" | "${IRONFOX_TR}" ";" "\n")
  local paths=()
  for include in ${includes}; do
    local path="${IRONFOX_ARTIFACTS}/${include}"
    if [[ -e "${path}" ]]; then
      echo "Including ${path}"
      paths+=("${include}")
    else
      echo_red_text "Warning: ${path} does not exist!"
    fi
  done

  if [[ ${#paths[@]} -eq 0 ]]; then
    echo_red_text "No valid artifact paths found. Creating empty artifact."
    "${IRONFOX_TOUCH}" "${artifact_path}"
    return
  fi

  "${IRONFOX_MKDIR}" -p "${IRONFOX_ARTIFACTS}"
  "${IRONFOX_TAR}" cvJf "${artifact_path}" -C "${IRONFOX_ARTIFACTS}" "${paths[@]}"
}

if [[ -z "${IRONFOX_ARTIFACT_INCLUDES+x}" ]]; then
  echo_red_text "IRONFOX_ARTIFACT_INCLUDES has not been specified. Creating empty artifact."
  "${IRONFOX_TOUCH}" "${artifact_path}"
else
  ironfox_package_artifacts
fi

if [ "${IRONFOX_CI_BUILD_FAILED}" == 1 ]; then
  exit 1
fi
