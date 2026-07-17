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

if [[ -z "${2+x}" ]]; then
  readonly mode='download'
else
  readonly mode=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# Get sources
readonly IRONFOX_FROM_SOURCES=1
export IRONFOX_FROM_SOURCES
if [[ "${IRONFOX_LOG_SOURCES}" == 1 ]]; then
  readonly SOURCES_LOG_FILE="${IRONFOX_LOG_DIR}/get_sources.log"

  # If the log file already exists, remove it
  if [[ -f "${SOURCES_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${SOURCES_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  /bin/bash -x "${IRONFOX_SCRIPTS}/get_sources-if.sh" "${target}" "${mode}" > >("${IRONFOX_TEE}" -a "${SOURCES_LOG_FILE}") 2>&1
else
  /bin/bash -x "${IRONFOX_SCRIPTS}/get_sources-if.sh" "${target}" "${mode}"
fi
