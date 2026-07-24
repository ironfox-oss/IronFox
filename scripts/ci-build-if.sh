#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
  export IRONFOX_CI=1
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [[ -z "${IRONFOX_FROM_CI_BUILD+x}" ]]; then
  echo_red_text 'ERROR: Do not call ci-build-if.sh directly. Instead, use ci-build.sh.' >&1
  exit 1
fi

# Set verbosity
if [[ "${IRONFOX_VERBOSE}" == 1 ]]; then
  set -x
else
  set +x
fi

readonly ci_build_arch="$1"

case "${ci_build_arch}" in
arm64|arm|x86_64|bundle)
  ;;
*)
  echo_red_text "Unknown build variant: '${ci_build_arch}'." >&2
  exit 1
  ;;
esac

readonly ci_build_project="$2"

# (For now, we only want to build Fenix and GeckoView directly from CI)
case "${ci_build_project}" in
fenix|geckoview)
  ;;
*)
  echo_red_text "Unknown build project: '${ci_build_project}'." >&2
  exit 1
  ;;
esac

if [[ "${ci_build_project}" == 'fenix' ]]; then
  # Fail-fast in case the signing key is unavailable or empty file
  verify_file_with_env "${IRONFOX_ANDROID_KEYSTORE}" 'IRONFOX_ANDROID_KEYSTORE' || exit 1
fi

# Get sources
if [[ "${ci_build_project}" == 'geckoview' ]]; then
  # If we're only building GeckoView, we don't need to download all sources
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'uv'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'python'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-ndk'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-25'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-build-tools'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform-36'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform-tools'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'rust'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'cbindgen'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'bundletool'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'firefox'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-17'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-21'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'gradle'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'gyp'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'microg'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'node'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'npm'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'phoenix'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 's3cmd'
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'wasi'
else
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh"
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 's3cmd'

  # If we're building a Fenix bundle, we also need to download our GeckoView artifacts
  if [[ "${ci_build_arch}" == 'bundle' ]]; then
    /bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'geckoview' 'arm64'
    /bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'geckoview' 'arm'
    /bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'geckoview' 'x86_64'
  fi
fi

# Prepare sources
if [[ "${ci_build_project}" == 'geckoview' ]]; then
  # If we're only building GeckoView, we don't need to prepare all sources
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" 'firefox'
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" 'android-sdk'
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" 'microg'
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" 'rust'
else
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh"
fi

# Build
/bin/bash "${IRONFOX_SCRIPTS}/build.sh" "${ci_build_arch}" "${ci_build_project}"
