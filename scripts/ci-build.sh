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

# Build IronFox
readonly IRONFOX_FROM_CI_BUILD=1
export IRONFOX_FROM_CI_BUILD
bash -x "${IRONFOX_SCRIPTS}/ci-build-if.sh" "${ci_target}" || true

# Compress our archives
if [ $? -ne 0 ]; then
    compress_archives
    # If something went wrong, we still need to exit 1 so that GitLab won't think the CI succeeded...
    exit 1
else
    compress_archives
fi
