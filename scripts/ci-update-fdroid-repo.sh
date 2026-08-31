#!/bin/bash

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh || exit 1

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
/bin/sudo /bin/dnf install -y bash curl git git-lfs jq make shasum || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'uv' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'python' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'androguard' || exit 1
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Update the F-Droid repo
echo_red_text 'CI - Updating F-Droid repo...'
set +x || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-update-fdroid.sh" || exit 1
echo_green_text 'CI - SUCCESS: Updated F-Droid repo.'
