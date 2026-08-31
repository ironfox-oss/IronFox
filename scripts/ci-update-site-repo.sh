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
/bin/sudo /bin/dnf install -y bash curl git make shasum yq || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'uv' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'python' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'pyyaml' || exit 1
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Update the website repo
echo_red_text 'CI - Updating website repo...'
set +x || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-update-site.sh" || exit 1
echo_green_text 'CI - SUCCESS: Updated website repo.'
