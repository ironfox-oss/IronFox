#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash $(dirname $0)/env.sh || exit 1
fi
source $(dirname $0)/env.sh || exit 1

# Include utilities
source "${IRONFOX_UTILS}" || exit 1

# Ensure we have GNU awk
verify_exec "${IRONFOX_AWK}" 'IRONFOX_AWK' || exit 1

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  readonly target='all'
else
  readonly target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

if [[ -z "${2+x}" ]]; then
  readonly mode='download'
else
  readonly mode=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# Get sources
readonly IRONFOX_FROM_SOURCES=1
export IRONFOX_FROM_SOURCES
if [[ "${IRONFOX_LOG_SOURCES}" == 1 ]]; then
  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  # Ensure we have tee
  verify_exec "${IRONFOX_TEE}" 'IRONFOX_TEE' || exit 1

  readonly SOURCES_LOG_FILE="${IRONFOX_LOG_DIR}/get_sources.log"

  # If the log file already exists, remove it
  if [[ -f "${SOURCES_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${SOURCES_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  /bin/bash "${IRONFOX_SCRIPTS}/get_sources-if.sh" "${target}" "${mode}" > >("${IRONFOX_TEE}" -a "${SOURCES_LOG_FILE}") 2>&1 || exit 1
else
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources-if.sh" "${target}" "${mode}" || exit 1
fi
