#!/bin/bash

set -euo pipefail

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
  # Target release
  export IRONFOX_RELEASE=1
fi

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
  export IRONFOX_CI=1
fi
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Set-up target parameters
readonly target_artifact=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
readonly target_arch=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')

# Upload our artifacts
readonly IRONFOX_FROM_AR_DOWN=1
export IRONFOX_FROM_AR_DOWN
if [[ "${IRONFOX_LOG_AR_DOWN}" == 1 ]]; then
  readonly AR_DOWN_LOG_FILE="${IRONFOX_LOG_DIR}/download-artifacts-${CI_PIPELINE_ID}-${target_artifact}.log"

  # If the log file already exists, remove it
  if [[ -f "${AR_DOWN_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${AR_DOWN_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  /bin/bash -x "${IRONFOX_SCRIPTS}/ci-download-artifacts-if.sh" "${target_artifact}" "${target_arch}" > >("${IRONFOX_TEE}" -a "${AR_DOWN_LOG_FILE}") 2>&1
else
  /bin/bash -x "${IRONFOX_SCRIPTS}/ci-download-artifacts-if.sh" "${target_artifact}" "${target_arch}"
fi
