#!/bin/bash

set -euo pipefail

# Functions
echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

if [ -z "${1+x}" ]; then
    echo_red_text "Usage: $0 arm|arm64|x86_64|bundle" >&1
    exit 1
fi

target="$1"

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Build IronFox
export IRONFOX_FROM_BUILD=1
if [ "${IRONFOX_LOG_BUILD}" == 1 ]; then
    BUILD_LOG_FILE="${IRONFOX_LOG_DIR}/build-${target}.log"

    # If the log file already exists, remove it
    if [ -f "${BUILD_LOG_FILE}" ]; then
        rm "${BUILD_LOG_FILE}"
    fi

    # Ensure our log directory exists
    mkdir -vp "${IRONFOX_LOG_DIR}"

    bash -x "${IRONFOX_SCRIPTS}/build-if.sh" "${target}" >> "${BUILD_LOG_FILE}" 2>&1
else
    bash -x "${IRONFOX_SCRIPTS}/build-if.sh" "${target}"
fi

# Sign IronFox
if [ "${IRONFOX_SIGN}" == 1 ]; then
    bash "${IRONFOX_SCRIPTS}/sign.sh"
fi
