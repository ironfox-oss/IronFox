#!/bin/bash

set -euo pipefail

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

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

    bash -x "${IRONFOX_SCRIPTS}/get_sources-if.sh" >> "${SOURCES_LOG_FILE}" 2>&1
else
    bash -x "${IRONFOX_SCRIPTS}/get_sources-if.sh"
fi
