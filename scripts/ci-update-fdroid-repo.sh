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
readonly IRONFOX_CI_GET_SOURCES_SH="${IRONFOX_SCRIPTS}/get_sources.sh"
verify_file "${IRONFOX_CI_GET_SOURCES_SH}" || exit 1

readonly IRONFOX_CI_FDROID_SH="${IRONFOX_SCRIPTS}/ci-update-fdroid.sh"
verify_file "${IRONFOX_CI_FDROID_SH}" || exit 1

# Ensure we're on the production or dev branch
if [[ "${IRONFOX_CURRENT_BRANCH}" != "${IRONFOX_DEV_BRANCH}" ]] && [[ "${IRONFOX_CURRENT_BRANCH}" != "${IRONFOX_PROD_BRANCH}" ]]; then
  echo_red_text "ERROR: Unable to publish release to F-Droid on branch: '${IRONFOX_CURRENT_BRANCH}'!"
  exit 1
fi

# Get dependencies
echo_red_text 'CI - Downloading dependencies...'
/bin/sudo /bin/dnf update -y --refresh || exit 1
/bin/sudo /bin/dnf install -y bash curl git git-lfs jq make shasum || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'uv' || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'python' || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'androguard' || exit 1
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Update the F-Droid repo
echo_red_text 'CI - Updating F-Droid repo...'
set +x || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_FDROID_SH}" || exit 1
echo_green_text 'CI - SUCCESS: Updated F-Droid repo.'
