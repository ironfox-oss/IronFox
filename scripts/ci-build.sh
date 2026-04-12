#!/bin/bash

set -euo pipefail

export IRONFOX_CI=1

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
    # Target release
    export IRONFOX_RELEASE=1
fi

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
    bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

readonly ci_target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')

# Function to compress our archives
function compress_archives() {
    if [ "${ci_target}" == 'bundle' ]; then
        local readonly ci_job_artifact="build-final-${ci_target}"
    else
        local readonly ci_job_artifact="build-aar-${ci_target}"
    fi
    bash -x "${IRONFOX_SCRIPTS}/ci-compress.sh" "${ci_job_artifact}"
}

# By default, we know the build hasn't failed...
IRONFOX_CI_BUILD_FAILED=0

# Build IronFox
readonly IRONFOX_FROM_CI_BUILD=1
export IRONFOX_FROM_CI_BUILD
bash -x "${IRONFOX_SCRIPTS}/ci-build-if.sh" "${ci_target}" || IRONFOX_CI_BUILD_FAILED=1

readonly IRONFOX_CI_BUILD_FAILED
export IRONFOX_CI_BUILD_FAILED

# Compress our archives
compress_archives
