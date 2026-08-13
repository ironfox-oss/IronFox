#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

# Include utilities
source "${IRONFOX_UTILS}"

# Set verbosity
if [[ "${IRONFOX_VERBOSE}" == 1 ]]; then
  set -x
else
  set +x
fi

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: $0 should only be called from CI!"
  exit 1
fi

# Get dependencies
echo_red_text 'CI - Downloading dependencies...'
/bin/sudo /bin/dnf update -y --refresh
/bin/sudo /bin/dnf install -y bash curl git make shasum yq
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'uv'
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'python'
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'pyyaml'
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Update the website repo
echo_red_text 'CI - Updating website repo...'
set +x
/bin/bash "${IRONFOX_SCRIPTS}/ci-update-site.sh"
echo_green_text 'CI - SUCCESS: Updated website repo.'
