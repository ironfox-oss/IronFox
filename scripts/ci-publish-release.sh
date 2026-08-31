#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash "$(realpath $(dirname "$0"))/env.sh" || exit 1
fi
source "$(realpath $(dirname "$0"))/env.sh" || exit 1

# Include utilities
source "${IRONFOX_UTILS}" || exit 1

# Set verbosity
set_verbosity

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  exit 1
fi

# Get dependencies
echo_red_text 'CI - Downloading dependencies...'
/bin/sudo /bin/dnf update -y --refresh || exit 1
/bin/sudo /bin/dnf install -y bash curl jq shasum || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'uv' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'python' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 's3cmd' || exit 1
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Get secrets
echo_red_text 'CI - Preparing secrets...'
set +x || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-prep.sh" 's3-releases' || exit 1
echo_green_text 'CI - SUCCESS: Prepared secrets.'

# Set verbosity
set_verbosity

# Get artifacts
echo_red_text 'CI - Downloading artifacts...'
/bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'fenix' 'arm64' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'fenix' 'arm' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'fenix' 'x86_64' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'fenix' 'bundle' || exit 1
echo_green_text 'CI - SUCCESS: Downloaded artifacts.'

# Publish our packages
echo_red_text 'CI - Publishing packages...'
set +x || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-publish-packages.sh" || exit 1
echo_green_text 'CI - SUCCESS: Published packages.'
