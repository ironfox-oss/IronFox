#!/bin/bash

set -euo pipefail

# Set-up our environment
function setup_env() {
  if [[ -z "${IRONFOX_SET_ENVS+x}" ]] || [[ "${IRONFOX_SET_ENVS}" != 1 ]]; then
    # Find dirname
    if [[ -n "${IRONFOX_DIRNAME+x}" ]] && [[ -x "${IRONFOX_DIRNAME}" ]]; then
      local -r dirname="${IRONFOX_DIRNAME}"
    elif [[ -x '/bin/dirname' ]]; then
      local -r dirname='/bin/dirname'
    elif [[ -x '/usr/bin/dirname' ]]; then
      local -r dirname='/usr/bin/dirname'
    else
      if ! command -v dirname > /dev/null 2>&1; then
        echo "ERROR: Missing dirname!" >&2
        exit 1
      fi
      # It isn't a known location, so we sadly have to just fall-back to the PATH
      local -r dirname="$(dirname)"
    fi

    # Set-up our environment
    readonly IRONFOX_ENV_SH="$("${dirname}" $0)/env.sh"
    if [[ ! -f "${IRONFOX_ENV_SH}" ]] || [[ ! -s "${IRONFOX_ENV_SH}" ]]; then
      echo "ERROR: '${IRONFOX_ENV_SH}' is invalid!"
      exit 1
    fi
    source "${IRONFOX_ENV_SH}" || exit 1
  fi
}

# Set-up our environment
setup_env

# Set verbosity
set_verbosity

# Ensure we have `IRONFOX_CI`
verify_env "${IRONFOX_CI}" 'IRONFOX_CI' || exit 1

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  exit 1
fi

# Ensure we have bash
verify_exec "${IRONFOX_BASH}" 'IRONFOX_BASH' || exit 1

# Ensure we have `IRONFOX_CURRENT_BRANCH`
verify_env "${IRONFOX_CURRENT_BRANCH}" 'IRONFOX_CURRENT_BRANCH' || exit 1

# Ensure we have `IRONFOX_DEV_BRANCH`
verify_env "${IRONFOX_DEV_BRANCH}" 'IRONFOX_DEV_BRANCH' || exit 1

# Ensure we have `IRONFOX_PROD_BRANCH`
verify_env "${IRONFOX_PROD_BRANCH}" 'IRONFOX_PROD_BRANCH' || exit 1

# Ensure we have `IRONFOX_SCRIPTS`
verify_dir_with_env "${IRONFOX_SCRIPTS}" 'IRONFOX_SCRIPTS' || exit 1

# Ensure we have our target scripts
readonly IRONFOX_CI_DL_AR_SH="${IRONFOX_SCRIPTS}/ci-download-artifacts.sh"
verify_file "${IRONFOX_CI_DL_AR_SH}" || exit 1

readonly IRONFOX_CI_GET_SOURCES_SH="${IRONFOX_SCRIPTS}/get_sources.sh"
verify_file "${IRONFOX_CI_GET_SOURCES_SH}" || exit 1

readonly IRONFOX_CI_PREP_SH="${IRONFOX_SCRIPTS}/ci-prep.sh"
verify_file "${IRONFOX_CI_PREP_SH}" || exit 1

readonly IRONFOX_CI_PUBLISH_SH="${IRONFOX_SCRIPTS}/ci-publish-packages.sh"
verify_file "${IRONFOX_CI_PUBLISH_SH}" || exit 1

# Ensure we're on the production or dev branch
if [[ "${IRONFOX_CURRENT_BRANCH}" != "${IRONFOX_DEV_BRANCH}" ]] && [[ "${IRONFOX_CURRENT_BRANCH}" != "${IRONFOX_PROD_BRANCH}" ]]; then
  echo_red_text "ERROR: Unable to publish release on branch: '${IRONFOX_CURRENT_BRANCH}'!"
  exit 1
fi

# Set our target
if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
  readonly IRONFOX_PUBLISH_TARGET='release'
else
  readonly IRONFOX_PUBLISH_TARGET='nightly'
fi

# Get dependencies
echo_red_text 'CI - Downloading dependencies...'
/bin/sudo /bin/dnf update -y --refresh || exit 1
/bin/sudo /bin/dnf install -y bash curl jq shasum || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'uv' || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'python' || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 's3cmd' || exit 1
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Get secrets
echo_red_text 'CI - Preparing secrets...'
set +x || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_PREP_SH}" 's3-releases' || exit 1
echo_green_text 'CI - SUCCESS: Prepared secrets.'

# Set verbosity
set_verbosity

# Get artifacts
echo_red_text 'CI - Downloading artifacts...'
"${IRONFOX_BASH}" "${IRONFOX_CI_DL_AR_SH}" 'fenix' 'arm64' || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_DL_AR_SH}" 'fenix' 'arm' || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_DL_AR_SH}" 'fenix' 'x86_64' || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_DL_AR_SH}" 'fenix' 'bundle' || exit 1
echo_green_text 'CI - SUCCESS: Downloaded artifacts.'

# Publish our packages
echo_red_text 'CI - Publishing packages...'
set +x || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_PUBLISH_SH}" "${IRONFOX_PUBLISH_TARGET}" || exit 1
echo_green_text 'CI - SUCCESS: Published packages.'
