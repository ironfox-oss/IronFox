#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash $(dirname $0)/env.sh || exit 1
fi
source $(dirname $0)/env.sh || exit 1

# Include utilities
source "${IRONFOX_UTILS}" || exit 1

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  exit 1
fi

# Ensure we have GNU awk
verify_exec "${IRONFOX_AWK}" 'IRONFOX_AWK' || exit 1

# Set our CI ID
## For GitLab, we use the pipeline ID
if [[ -z "${CI_PIPELINE_ID+x}" ]]; then
  echo_red_text "ERROR: Missing GitLab pipeline ID! Please set 'CI_PIPELINE_ID'."
  exit 1
else
  readonly IRONFOX_CI_ID="${CI_PIPELINE_ID}"
fi
export IRONFOX_CI_ID

# Set-up target parameters
readonly target_artifact=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
readonly target_arch=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')

# Upload our artifacts
readonly IRONFOX_FROM_AR_UP=1
export IRONFOX_FROM_AR_UP
if [[ "${IRONFOX_LOG_AR_UP}" == 1 ]]; then
  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  # Ensure we have tee
  verify_exec "${IRONFOX_TEE}" 'IRONFOX_TEE' || exit 1

  readonly AR_UP_LOG_FILE="${IRONFOX_LOG_DIR}/upload-artifacts-${IRONFOX_CI_ID}-${target_artifact}.log"

  # If the log file already exists, remove it
  if [[ -f "${AR_UP_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${AR_UP_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  /bin/bash "${IRONFOX_SCRIPTS}/ci-upload-artifacts-if.sh" "${target_artifact}" "${target_arch}" > >("${IRONFOX_TEE}" -a "${AR_UP_LOG_FILE}") 2>&1 || exit 1
else
  /bin/bash "${IRONFOX_SCRIPTS}/ci-upload-artifacts-if.sh" "${target_artifact}" "${target_arch}" || exit 1
fi
