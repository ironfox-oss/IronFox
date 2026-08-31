#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

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

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  echo_red_text "Usage: $0 arm|arm64|x86_64|bundle" >&1
  exit 1
fi
readonly IRONFOX_CI_BUILD_ARCH=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')

case "${IRONFOX_CI_BUILD_ARCH}" in
  arm64 | arm | x86_64 | bundle) ;;
  *)
    echo_red_text "Unknown build variant: '${IRONFOX_CI_BUILD_ARCH}'." >&2
    exit 1
    ;;
esac

if [[ -z "${2+x}" ]]; then
  readonly IRONFOX_CI_BUILD_PROJECT='fenix'
else
  readonly IRONFOX_CI_BUILD_PROJECT=$(echo "${2}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

# (For now, we only want to build Fenix and GeckoView directly from CI)
case "${IRONFOX_CI_BUILD_PROJECT}" in
  fenix | geckoview) ;;
  *)
    echo_red_text "Unknown build project: '${IRONFOX_CI_BUILD_PROJECT}'." >&2
    exit 1
    ;;
esac

# Get dependencies
echo_red_text 'CI - Downloading dependencies...'
/bin/sudo /bin/dnf update -y --refresh || exit 1
/bin/sudo /bin/dnf install -y bash curl shasum tar || exit 1
if [[ "${IRONFOX_CI_BUILD_PROJECT}" == 'geckoview' ]]; then
  # If we're only building GeckoView, we don't need to download all sources
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'uv' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'python' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-ndk' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-25' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-build-tools' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform-36' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'android-sdk-platform-tools' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'rust' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'cbindgen' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'bundletool' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'firefox' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-17' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'jdk-21' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'gradle' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'gyp' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'microg' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'node' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'npm' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'phoenix' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 's3cmd' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 'wasi' || exit 1
else
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/get_sources.sh" 's3cmd' || exit 1

  # If we're building a Fenix bundle, we also need to download our GeckoView artifacts
  if [[ "${IRONFOX_CI_BUILD_ARCH}" == 'bundle' ]]; then
    /bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'geckoview' 'arm64' || exit 1
    /bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'geckoview' 'arm' || exit 1
    /bin/bash "${IRONFOX_SCRIPTS}/ci-download-artifacts.sh" 'geckoview' 'x86_64' || exit 1
  fi
fi
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Get secrets
echo_red_text 'CI - Preparing secrets...'
set +x || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-prep.sh" 's3-artifacts' || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-prep.sh" 'sb' || exit 1
if [[ "${IRONFOX_CI_BUILD_PROJECT}" == 'fenix' ]]; then
  /bin/bash "${IRONFOX_SCRIPTS}/ci-prep.sh" 'android-ks' || exit 1
fi
echo_green_text 'CI - SUCCESS: Prepared secrets.'

if [[ "${IRONFOX_CI_BUILD_PROJECT}" == 'fenix' ]]; then
  # Fail-fast in case the signing key is unavailable or an empty file
  verify_file_with_env "${IRONFOX_ANDROID_KEYSTORE}" 'IRONFOX_ANDROID_KEYSTORE' || exit 1
fi

# Set verbosity
set_verbosity

# Prepare sources
echo_red_text 'CI - Preparing sources...'
if [[ "${IRONFOX_CI_BUILD_PROJECT}" == 'geckoview' ]]; then
  # If we're only building GeckoView, we don't need to prepare all sources
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" 'firefox' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" 'android-sdk' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" 'microg' || exit 1
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" 'rust' || exit 1
else
  /bin/bash "${IRONFOX_SCRIPTS}/prebuild.sh" || exit 1
fi
echo_green_text 'CI - SUCCESS: Prepared sources.'

# Build
echo_red_text "CI - Building ${IRONFOX_CI_BUILD_PROJECT} (${IRONFOX_CI_BUILD_ARCH}..."
/bin/bash "${IRONFOX_SCRIPTS}/build.sh" "${IRONFOX_CI_BUILD_ARCH}" "${IRONFOX_CI_BUILD_PROJECT}" || exit 1
echo_green_text "CI - SUCCESS: Built ${IRONFOX_CI_BUILD_PROJECT} (${IRONFOX_CI_BUILD_ARCH}"

# Upload artifacts
echo_red_text 'CI - Uploading artifacts...'
set +x || exit 1
/bin/bash "${IRONFOX_SCRIPTS}/ci-upload-artifacts.sh" "${IRONFOX_CI_BUILD_PROJECT}" "${IRONFOX_CI_BUILD_ARCH}" || exit 1
echo_green_text 'CI - SUCCESS: Uploaded artifacts.'
