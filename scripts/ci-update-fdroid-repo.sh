#!/bin/bash

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh

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
/bin/sudo /bin/dnf install -y bash curl git git-lfs jq make shasum
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'uv'
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'python'
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'androguard'
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Update the F-Droid repo
echo_red_text 'CI - Updating F-Droid repo...'
set +x
/bin/bash "${IRONFOX_SCRIPTS}/ci-update-fdroid.sh"
echo_green_text 'CI - SUCCESS: Updated F-Droid repo.'
