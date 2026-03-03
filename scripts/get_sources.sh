#!/bin/bash

set -euo pipefail

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Set up target parameters
if [[ -z "${1+x}" ]]; then
    target='all'
else
    target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

if [[ -z "${2+x}" ]]; then
    mode='download'
else
    mode=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# Get sources
export IRONFOX_FROM_SOURCES=1
if [ "${IRONFOX_LOG_SOURCES}" == 1 ]; then
    SOURCES_LOG_FILE="${IRONFOX_LOG_DIR}/get_sources.log"

    # If the log file already exists, remove it
    if [ -f "${SOURCES_LOG_FILE}" ]; then
        rm "${SOURCES_LOG_FILE}"
    fi

    # Ensure our log directory exists
    mkdir -vp "${IRONFOX_LOG_DIR}"

    bash -x "${IRONFOX_SCRIPTS}/get_sources-if.sh" "${target}" "${mode}" > >(tee -a "${SOURCES_LOG_FILE}") 2>&1
else
    bash -x "${IRONFOX_SCRIPTS}/get_sources-if.sh" "${target}" "${mode}"
fi
