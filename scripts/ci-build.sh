#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -eu

rootdir="$(dirname "$0")/.."

# Setup Android SDK
source "$rootdir/scripts/setup-android-sdk.sh"

# Download sources
"$rootdir/scripts/get_sources.sh"

# Setup API key for Google Safe Browsing
mkdir -p "$(dirname "${SB_GAPI_KEY_FILE}")" && echo "${SB_GAPI_KEY}" > "${SB_GAPI_KEY_FILE}"

# Print the mozconfig for debugging purposes
echo ""
echo "########################"
cat  "$rootdir/gecko/mozconfig"
echo "########################"
echo ""

# Setup paths
source "$rootdir/scripts/paths_local.sh"

# Patch
"$rootdir/scripts/prebuild.sh" "${VERSION_NAME}" "${VERSION_CODE}"

# Build
"$rootdir/scripts/build.sh"

# Build AAB
pushd "$rootdir/gecko/mobile/android/fenix"
gradle :app:bundleRelease
popd