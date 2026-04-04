#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -eu
set -o pipefail
set -o xtrace

source "$(dirname "$0")/utilities.sh"

if [[ -z "${IRONFOX_CI+x}" ]]; then
    echo_red_text "$0 must be run in a CI environment"
    exit 1
fi

artifact_name="${IRONFOX_JOB_ARTIFACT_NAME}.tar.xz"
artifact_path="${IRONFOX_ARTIFACTS}/${artifact_name}"

function ironfox_package_artifacts() {
    includes=$(echo "$IRONFOX_ARTIFACT_INCLUDES" | tr ";" "\n")
    paths=()
    for include in $includes; do
        path="${IRONFOX_ARTIFACTS}/$include"
        if [[ -e "$path" ]]; then
            paths+=("$path")
        else
            echo_red_text "Warning: $path does not exist!"
        fi
    done

    if [[ ${#paths[@]} -eq 0 ]]; then
        echo_red_text "No valid artifact paths found. Creating empty artifact."
        touch "$artifact_path"
        return
    fi

    tar cvJf "$artifact_path" -C "${IRONFOX_ARTIFACTS}" "${paths[@]}"
}

if [[ -z "${IRONFOX_ARTIFACT_INCLUDES}" ]]; then
    echo_red_text "IRONFOX_ARTIFACT_INCLUDES has not been specified. Creating empty artifact."
    touch "$artifact_path"
else
    ironfox_package_artifacts
fi
