#!/bin/bash

# Script to configure a git pre-commit hook for linting

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

# Ensure we have git
verify_exec "${IRONFOX_GIT}" 'IRONFOX_GIT' || exit 1

# Ensure we have mkdir
verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

# Ensure we have rm
verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

# Ensure we have touch
verify_exec "${IRONFOX_TOUCH}" 'IRONFOX_TOUCH' || exit 1

# Ensure we have `IRONFOX_BUILD`
verify_env "${IRONFOX_BUILD}" 'IRONFOX_BUILD' || exit 1

# Check if the hook has already been set-up
if [[ -f "${IRONFOX_BUILD}/set-hook" ]]; then
  echo_red_text 'It looks like the git pre-commit hook has already been set-up!'
  read -p "Are you sure you want to continue? [y/N] " -n 1 -r
  echo
  if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
    exit 0
  else
    "${IRONFOX_RM}" -f "${IRONFOX_BUILD}/set-hook"
  fi
fi

# Enable the pre-commit hook so shell scripts are linted (shellcheck + shfmt)
# before each commit. CI enforces the same checks, so this is just a fast local
# safeguard (and is bypassable with `git commit --no-verify`).
echo_red_text 'Configuring git pre-commit hook...'
"${IRONFOX_GIT}" -C "${IRONFOX_ROOT}" config core.hooksPath scripts/git-hooks
echo_green_text 'SUCCESS: Configured git pre-commit hook'

# Indicate that the hook has been set-up
"${IRONFOX_MKDIR}" -p "${IRONFOX_BUILD}"
"${IRONFOX_TOUCH}" "${IRONFOX_BUILD}/set-hook"
