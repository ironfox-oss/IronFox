#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

readonly artifact_name="$1"
readonly artifact_archive="${artifact_name}.tar.xz"
readonly artifact_path="${IRONFOX_ARTIFACTS}/${artifact_archive}"

function ironfox_package_artifacts() {
    # For debugging purposes
    echo "Listing available artifacts"
    find "${IRONFOX_ARTIFACTS}"

    local readonly includes=$(echo "${IRONFOX_ARTIFACT_INCLUDES}" | tr ";" "\n")
    local paths=()
    for include in ${includes}; do
        local path="${IRONFOX_ARTIFACTS}/${include}"
        if [[ -e "${path}" ]]; then
            echo "Including ${path}"
            paths+=("${include}")
        else
            echo_red_text "Warning: ${path} does not exist!"
        fi
    done

    if [[ ${#paths[@]} -eq 0 ]]; then
        echo_red_text "No valid artifact paths found. Creating empty artifact."
        touch "${artifact_path}"
        return
    fi

    mkdir -p "${IRONFOX_ARTIFACTS}"
    tar cvJf "${artifact_path}" -C "${IRONFOX_ARTIFACTS}" "${paths[@]}"
}

if [[ -z "${IRONFOX_ARTIFACT_INCLUDES+x}" ]]; then
    echo_red_text "IRONFOX_ARTIFACT_INCLUDES has not been specified. Creating empty artifact."
    touch "${artifact_path}"
else
    ironfox_package_artifacts
fi

if [ "${IRONFOX_CI_BUILD_FAILED}" == 1 ]; then
    exit 1
fi
