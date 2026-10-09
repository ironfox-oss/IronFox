#!/bin/bash

# Lints IronFox's shell scripts with shellcheck (static analysis) and shfmt
# (formatting). This is the single source of truth used by CI, the pre-commit
# hook, and manual runs.
#
# It is intended to run in a minimal CI container.
#
# Usage:
#   scripts/lint.sh            Lint all tracked shell scripts (CI + manual)
#   scripts/lint.sh --staged   Lint only staged shell scripts (pre-commit hook)
#
# Config lives in .shellcheckrc (checks) and .editorconfig (shfmt formatting),
# both read automatically from the repo root.

set -euo pipefail

# Set-up our environment
readonly IRONFOX_LINTING=1
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

# Ensure we have shellcheck
verify_exec "${IRONFOX_SHELLCHECK}" 'IRONFOX_SHELLCHECK' || exit 1

# Ensure we have shfmt
verify_exec "${IRONFOX_SHFMT}" 'IRONFOX_SHFMT' || exit 1

# Resolve and move to the repo root so relative paths and config discovery
# (.shellcheckrc, .editorconfig) work regardless of the caller's cwd.
pushd "${IRONFOX_ROOT}"

mode='all'
if [[ "${1:-}" == '--staged' ]]; then
  mode='staged'
fi

# Collect target scripts. `git ls-files` naturally excludes generated,
# gitignored files (e.g. scripts/env_local.sh, scripts/env_build.sh).
declare -a targets=()
if [[ "${mode}" == 'staged' ]]; then
  # Ensure we have git
  verify_exec "${IRONFOX_GIT}" 'IRONFOX_GIT' || exit 1

  while IFS= read -r file; do
    [[ -n "${file}" ]] && targets+=("${file}")
  done < <("${IRONFOX_GIT}" diff --cached --name-only --diff-filter=ACM -- 'scripts/*.sh' 'configs/mozconfigs/*.mozconfig' 'configs/mozconfigs/**/*.mozconfig')
else
  # Ensure we have ls
  verify_exec "${IRONFOX_LS}" 'IRONFOX_LS' || exit 1

  while IFS= read -r file; do
    targets+=("${file}")
  done < <("${IRONFOX_LS}" scripts/*.sh configs/mozconfigs/*.mozconfig configs/mozconfigs/**/*.mozconfig)
fi

if [[ ${#targets[@]} -eq 0 ]]; then
  echo 'lint: no shell scripts to check.'
  exit 0
fi

# Ensure the tools are available before running.
missing=0
for tool in shellcheck shfmt; do
  if ! command -v "${tool}" > /dev/null 2>&1; then
    echo "lint: required tool '${tool}' is not installed or not in PATH." >&2
    missing=1
  fi
done
if [[ "${missing}" -ne 0 ]]; then
  echo 'lint: install the missing tool(s) (e.g. run scripts/get_sources.sh shellcheck and scripts/get_sources.sh shfmt) and retry.' >&2
  exit 127
fi

status=0

echo "lint: shellcheck (${#targets[@]} file(s))..."
if ! "${IRONFOX_SHELLCHECK}" -x "${targets[@]}"; then
  status=1
fi

echo 'lint: shfmt formatting check...'
if ! "${IRONFOX_SHFMT}" -d "${targets[@]}"; then
  echo >&2
  echo "lint: formatting issues found above. Fix with:" >&2
  echo "        ls scripts/*.sh configs/mozconfigs/*.mozconfig configs/mozconfigs/**/*.mozconfig | xargs shfmt -w" >&2
  status=1
fi

if [[ "${status}" -eq 0 ]]; then
  echo 'lint: OK'
else
  echo 'lint: FAILED' >&2
fi

popd

exit "${status}"
