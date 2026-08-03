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
export IRONFOX_LINTING
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Set verbosity
if [[ "${IRONFOX_VERBOSE}" == 1 ]]; then
  set -x
else
  set +x
fi

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
  while IFS= read -r file; do
    [[ -n "${file}" ]] && targets+=("${file}")
  done < <("${IRONFOX_GIT}" diff --cached --name-only --diff-filter=ACM -- 'scripts/*.sh')
else
  while IFS= read -r file; do
    targets+=("${file}")
  done < <("${IRONFOX_GIT}" ls-files 'scripts/*.sh')
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
  echo "        git ls-files 'scripts/*.sh' | xargs shfmt -w" >&2
  status=1
fi

if [[ "${status}" -eq 0 ]]; then
  echo 'lint: OK'
else
  echo 'lint: FAILED' >&2
fi

popd

exit "${status}"
