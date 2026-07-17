#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  echo_red_text "Usage: $0 arm|arm64|x86_64|bundle" >&1
  exit 1
fi

readonly target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')

if [[ -z "${2+x}" ]]; then
  readonly project='fenix'
else
  readonly project=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# Build IronFox
readonly IRONFOX_FROM_BUILD=1
export IRONFOX_FROM_BUILD
if [[ "${IRONFOX_LOG_BUILD}" == 1 ]]; then
  readonly BUILD_LOG_FILE="${IRONFOX_LOG_DIR}/build-${target}.log"

  # If the log file already exists, remove it
  if [[ -f "${BUILD_LOG_FILE}" ]]; then
    "${IRONFOX_RM}" "${BUILD_LOG_FILE}"
  fi

  # Ensure our log directory exists
  "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

  /bin/bash -x "${IRONFOX_SCRIPTS}/build-if.sh" "${target}" "${project}" > >("${IRONFOX_TEE}" -a "${BUILD_LOG_FILE}") 2>&1
else
  /bin/bash -x "${IRONFOX_SCRIPTS}/build-if.sh" "${target}" "${project}"
fi

# We should only try to sign IronFox if we actually built Fenix, so check that first
## (All `rebuild-` targets eventually build Fenix, because eventually Fenix consumes everything...)
if [[ "${project}" == 'fenix' ]] || [[ "${project}" == 'rebuild-ac-core' ]] || [[ "${project}" == 'rebuild-ac' ]] ||
 [[ "${project}" == 'rebuild-as' ]] || [[ "${project}" == 'rebuild-fenix' ]] || [[ "${project}" == 'rebuild-gecko' ]] ||
 [[ "${project}" == 'rebuild-geckoview' ]] || [[ "${project}" == 'rebuild-glean' ]] || [[ "${project}" == 'rebuild-ironfox-core' ]] ||
 [[ "${project}" == 'rebuild-llvm' ]] || [[ "${project}" == 'rebuild-microg' ]] || [[ "${project}" == 'rebuild-nimbus-fml' ]] ||
 [[ "${project}" == 'rebuild-phoenix' ]] || [[ "${project}" == 'rebuild-uniffi' ]] || [[ "${project}" == 'rebuild-up-ac' ]] ||
 [[ "${project}" == 'rebuild-wasi' ]]; then
  readonly IRONFOX_BUILT_FENIX=1
else
  readonly IRONFOX_BUILT_FENIX=0
fi

# Sign IronFox
if [[ "${IRONFOX_SIGN}" == 1 ]] && [[ "${IRONFOX_BUILT_FENIX}" == 1 ]]; then
  if [[ "${IRONFOX_LOG_SIGN}" == 1 ]]; then
    readonly SIGN_LOG_FILE="${IRONFOX_LOG_DIR}/sign.log"

    # If the log file already exists, remove it
    if [[ -f "${SIGN_LOG_FILE}" ]]; then
      "${IRONFOX_RM}" "${SIGN_LOG_FILE}"
    fi

    # Ensure our log directory exists
    "${IRONFOX_MKDIR}" -vp "${IRONFOX_LOG_DIR}"

    /bin/bash "${IRONFOX_SCRIPTS}/sign.sh" "${target}" > >("${IRONFOX_TEE}" -a "${SIGN_LOG_FILE}") 2>&1
  else
    /bin/bash "${IRONFOX_SCRIPTS}/sign.sh" "${target}"
  fi
fi
