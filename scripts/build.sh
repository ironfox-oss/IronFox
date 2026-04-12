#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
    bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [ -z "${1+x}" ]; then
    echo_red_text "Usage: $0 arm|arm64|x86_64|bundle" >&1
    exit 1
fi

readonly target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')

# Build IronFox
readonly IRONFOX_FROM_BUILD=1
export IRONFOX_FROM_BUILD
if [ "${IRONFOX_LOG_BUILD}" == 1 ]; then
    readonly BUILD_LOG_FILE="${IRONFOX_LOG_DIR}/build-${target}.log"

    # If the log file already exists, remove it
    if [ -f "${BUILD_LOG_FILE}" ]; then
        rm "${BUILD_LOG_FILE}"
    fi

    # Ensure our log directory exists
    mkdir -vp "${IRONFOX_LOG_DIR}"

    bash -x "${IRONFOX_SCRIPTS}/build-if.sh" "${target}" > >(tee -a "${BUILD_LOG_FILE}") 2>&1
else
    bash -x "${IRONFOX_SCRIPTS}/build-if.sh" "${target}"
fi

# Sign IronFox
if [ "${IRONFOX_SIGN}" == 1 ]; then
    if [ "${IRONFOX_LOG_SIGN}" == 1 ]; then
        readonly SIGN_LOG_FILE="${IRONFOX_LOG_DIR}/sign.log"

        # If the log file already exists, remove it
        if [ -f "${SIGN_LOG_FILE}" ]; then
            rm "${SIGN_LOG_FILE}"
        fi

        # Ensure our log directory exists
        mkdir -vp "${IRONFOX_LOG_DIR}"

        if [ "${IRONFOX_CI}" == 1 ] && [ "${target}" != 'bundle' ]; then
            # CI should only try to sign bundle builds (which create/include all APKs)
            exit 0
        fi

        bash "${IRONFOX_SCRIPTS}/sign.sh" "${target}" > >(tee -a "${SIGN_LOG_FILE}") 2>&1
    else
        bash "${IRONFOX_SCRIPTS}/sign.sh" "${target}"
    fi
fi
