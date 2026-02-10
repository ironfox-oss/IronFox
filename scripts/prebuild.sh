#!/bin/bash

set -euo pipefail

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Prepare to build IronFox
export IRONFOX_FROM_PREBUILD=1
if [ "${IRONFOX_LOG_PREBUILD}" == 1 ]; then
    PREBUILD_LOG_FILE="${IRONFOX_LOG_DIR}/prebuild.log"

    # If the log file already exists, remove it
    if [ -f "${PREBUILD_LOG_FILE}" ]; then
        rm "${PREBUILD_LOG_FILE}"
    fi

    # Ensure our log directory exists
    mkdir -vp "${IRONFOX_LOG_DIR}"

    bash -x "${IRONFOX_SCRIPTS}/prebuild-if.sh" > >(tee -a "${PREBUILD_LOG_FILE}") 2>&1
else
    bash -x "${IRONFOX_SCRIPTS}/prebuild-if.sh"
fi
