#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -eu
set -o xtrace

rootdir="$(dirname "$0")/.."
rootdir=$(realpath "$rootdir")

# Setup Android SDK
source "$rootdir/scripts/setup-android-sdk.sh"

# Setup paths
source "$rootdir/scripts/paths_local.sh"

# Patch
"$rootdir/scripts/prebuild.sh" "${VERSION_NAME}" "${VERSION_CODE}"

# Print the mozconfig for debugging purposes
echo ""
echo "########################"
cat  "$rootdir/gecko/mozconfig"
echo "########################"
echo ""

# Build
bash "$rootdir/scripts/build.sh"

# Build AAB
pushd "$rootdir/gecko/mobile/android/fenix"
gradle :app:bundleRelease
popd