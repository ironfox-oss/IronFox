#!/bin/bash

set -euo pipefail

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
  # Target release
  export IRONFOX_RELEASE=1
fi

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
  export IRONFOX_CI=1
fi
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Set-up target parameters
readonly ci_target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')

if [[ -z "${2+x}" ]]; then
  readonly ci_project='fenix'
else
  readonly ci_project=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# Function to compress our archives
function compress_archives() {
  if [[ "${ci_project}" == 'geckoview' ]]; then
    local -r ci_job_artifact="build-geckoview-${ci_target}"
  elif [[ "${ci_project}" == 'fenix' ]]; then
    local -r ci_job_artifact="build-fenix-${ci_target}"
  fi
  /bin/bash "${IRONFOX_SCRIPTS}/ci-compress.sh" "${ci_job_artifact}"
}

# By default, we know the build hasn't failed...
IRONFOX_CI_BUILD_FAILED=0

# Build IronFox
readonly IRONFOX_FROM_CI_BUILD=1
export IRONFOX_FROM_CI_BUILD
/bin/bash "${IRONFOX_SCRIPTS}/ci-build-if.sh" "${ci_target}" "${ci_project}" || IRONFOX_CI_BUILD_FAILED=1

readonly IRONFOX_CI_BUILD_FAILED
export IRONFOX_CI_BUILD_FAILED

# Compress our archives
#compress_archives
