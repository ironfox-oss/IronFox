#!/bin/bash

set -euo pipefail

# Functions
function echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

function echo_green_text() {
	echo -e "\033[32m$1\033[0m"
}

function validate_ks_file() {
    local file
    file="${IRONFOX_KEYSTORE}"

    if ! [[ -f "$file" ]]; then
        echo_red_text "Keystore file ${file} does not exist!"
        exit 1
    fi

    if ! [[ -s "$file"  ]]; then
        echo_red_text "Keystore file ${file} is empty!"
        exit 1
    fi
}

if [ -z "${1+x}" ]; then
    echo_red_text "Usage: $0 arm|arm64|x86_64|bundle" >&1
    exit 1
fi

target="$1"

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Fail-fast in case the signing key is unavailable or empty file
validate_ks_file

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

    bash -x "${IRONFOX_SCRIPTS}/build-if.sh" "${target}" > >(tee -a "${BUILD_LOG_FILE}") 2>&1
else
    bash -x "${IRONFOX_SCRIPTS}/build-if.sh" "${target}"
fi

# Sign IronFox
source "${IRONFOX_ENV_BUILD}"

if [ "${IRONFOX_SIGN}" == 1 ]; then
    if [ "${IRONFOX_LOG_SIGN}" == 1 ]; then
        SIGN_LOG_FILE="${IRONFOX_LOG_DIR}/sign.log"

        # If the log file already exists, remove it
        if [ -f "${SIGN_LOG_FILE}" ]; then
            rm "${SIGN_LOG_FILE}"
        fi

        # Ensure our log directory exists
        mkdir -vp "${IRONFOX_LOG_DIR}"

        if [ "${IRONFOX_CI}" == 1 ] && [ "${IRONFOX_TARGET_ARCH}" != 'bundle' ]; then
            # CI should only try to sign bundle builds (which create/include all APKs)
            exit 0
        fi

        bash -x "${IRONFOX_SCRIPTS}/sign.sh" > >(tee -a "${SIGN_LOG_FILE}") 2>&1
    else
        bash -x "${IRONFOX_SCRIPTS}/sign.sh" "${target}"
    fi
fi
