#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  readonly target='all'
else
  readonly target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# Prepare to build IronFox
readonly IRONFOX_FROM_PREBUILD=1
export IRONFOX_FROM_PREBUILD
if [[ "${IRONFOX_LOG_PREBUILD}" == 1 ]]; then
  readonly PREBUILD_LOG_FILE="${IRONFOX_LOG_DIR}/prebuild.log"

  # If the log file already exists, remove it
  if [[ -f "${PREBUILD_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${PREBUILD_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  /bin/bash -x "${IRONFOX_SCRIPTS}/prebuild-if.sh" "${target}" > >("${IRONFOX_TEE}" -a "${PREBUILD_LOG_FILE}") 2>&1
else
  /bin/bash -x "${IRONFOX_SCRIPTS}/prebuild-if.sh" "${target}"
fi
