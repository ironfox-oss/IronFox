#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -euo pipefail

# Set-up our environment
function setup_env() {
  if [[ -z "${IRONFOX_SET_ENVS+x}" ]] || [[ "${IRONFOX_SET_ENVS}" != 1 ]]; then
    # Find dirname
    if [[ -n "${IRONFOX_DIRNAME+x}" ]] && [[ -x "${IRONFOX_DIRNAME}" ]]; then
      local -r dirname="${IRONFOX_DIRNAME}"
    elif [[ -x '/bin/dirname' ]]; then
      local -r dirname='/bin/dirname'
    elif [[ -x '/usr/bin/dirname' ]]; then
      local -r dirname='/usr/bin/dirname'
    else
      if ! command -v dirname > /dev/null 2>&1; then
        echo "ERROR: Missing dirname!" >&2
        exit 1
      fi
      # It isn't a known location, so we sadly have to just fall-back to the PATH
      local -r dirname="$(dirname)"
    fi

    # Set-up our environment
    readonly IRONFOX_ENV_SH="$("${dirname}" $0)/env.sh"
    if [[ ! -f "${IRONFOX_ENV_SH}" ]] || [[ ! -s "${IRONFOX_ENV_SH}" ]]; then
      echo "ERROR: '${IRONFOX_ENV_SH}' is invalid!"
      exit 1
    fi
    source "${IRONFOX_ENV_SH}" || exit 1
  fi
}

# Set-up our environment
setup_env

# Set verbosity
set_verbosity

# Ensure we have `IRONFOX_CI`
verify_env "${IRONFOX_CI}" 'IRONFOX_CI' || exit 1

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  exit 1
fi

# Ensure we have bash
verify_exec "${IRONFOX_BASH}" 'IRONFOX_BASH' || exit 1

# Ensure we have GNU awk
verify_exec "${IRONFOX_AWK}" 'IRONFOX_AWK' || exit 1

# Ensure we have `IRONFOX_SCRIPTS`
verify_dir_with_env "${IRONFOX_SCRIPTS}" 'IRONFOX_SCRIPTS' || exit 1

# Ensure we have our target scripts
readonly IRONFOX_CI_BUILD_SH="${IRONFOX_SCRIPTS}/build.sh"
verify_file "${IRONFOX_CI_BUILD_SH}" || exit 1

readonly IRONFOX_CI_DL_AR_SH="${IRONFOX_SCRIPTS}/ci-download-artifacts.sh"
verify_file "${IRONFOX_CI_DL_AR_SH}" || exit 1

readonly IRONFOX_CI_GET_SOURCES_SH="${IRONFOX_SCRIPTS}/get_sources.sh"
verify_file "${IRONFOX_CI_GET_SOURCES_SH}" || exit 1

readonly IRONFOX_CI_PREBUILD_SH="${IRONFOX_SCRIPTS}/prebuild.sh"
verify_file "${IRONFOX_CI_PREBUILD_SH}" || exit 1

readonly IRONFOX_CI_PREP_SH="${IRONFOX_SCRIPTS}/ci-prep.sh"
verify_file "${IRONFOX_CI_PREP_SH}" || exit 1

readonly IRONFOX_CI_UP_AR_SH="${IRONFOX_SCRIPTS}/ci-upload-artifacts.sh"
verify_file "${IRONFOX_CI_UP_AR_SH}" || exit 1

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
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'uv' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'python' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'android-ndk' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'jdk-25' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'android-sdk' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'android-sdk-build-tools' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'android-sdk-platform' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'android-sdk-platform-36' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'android-sdk-platform-tools' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'rust' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'cbindgen' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'bundletool' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'firefox' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'jdk-17' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'jdk-21' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'gradle' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'gyp' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'microg' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'node' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'npm' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'phoenix' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 's3cmd' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 'wasi' || exit 1
else
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_GET_SOURCES_SH}" 's3cmd' || exit 1

  # If we're building a Fenix bundle, we also need to download our GeckoView artifacts
  if [[ "${IRONFOX_CI_BUILD_ARCH}" == 'bundle' ]]; then
    "${IRONFOX_BASH}" "${IRONFOX_CI_DL_AR_SH}" 'geckoview' 'arm64' || exit 1
    "${IRONFOX_BASH}" "${IRONFOX_CI_DL_AR_SH}" 'geckoview' 'arm' || exit 1
    "${IRONFOX_BASH}" "${IRONFOX_CI_DL_AR_SH}" 'geckoview' 'x86_64' || exit 1
  fi
fi
echo_green_text 'CI - SUCCESS: Downloaded dependencies.'

# Get secrets
echo_red_text 'CI - Preparing secrets...'
set +x || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_PREP_SH}" 's3-artifacts' || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_PREP_SH}" 'sb' || exit 1
if [[ "${IRONFOX_CI_BUILD_PROJECT}" == 'fenix' ]]; then
  "${IRONFOX_BASH}" "${IRONFOX_CI_PREP_SH}" 'android-ks' || exit 1
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
  "${IRONFOX_BASH}" "${IRONFOX_CI_PREBUILD_SH}" 'firefox' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_PREBUILD_SH}" 'android-sdk' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_PREBUILD_SH}" 'microg' || exit 1
  "${IRONFOX_BASH}" "${IRONFOX_CI_PREBUILD_SH}" 'rust' || exit 1
else
  "${IRONFOX_BASH}" "${IRONFOX_CI_PREBUILD_SH}" || exit 1
fi
echo_green_text 'CI - SUCCESS: Prepared sources.'

# Build
echo_red_text "CI - Building ${IRONFOX_CI_BUILD_PROJECT} (${IRONFOX_CI_BUILD_ARCH}..."
"${IRONFOX_BASH}" "${IRONFOX_CI_BUILD_SH}" "${IRONFOX_CI_BUILD_ARCH}" "${IRONFOX_CI_BUILD_PROJECT}" || exit 1
echo_green_text "CI - SUCCESS: Built ${IRONFOX_CI_BUILD_PROJECT} (${IRONFOX_CI_BUILD_ARCH}"

# Upload artifacts
echo_red_text 'CI - Uploading artifacts...'
set +x || exit 1
"${IRONFOX_BASH}" "${IRONFOX_CI_UP_AR_SH}" "${IRONFOX_CI_BUILD_PROJECT}" "${IRONFOX_CI_BUILD_ARCH}" || exit 1
echo_green_text 'CI - SUCCESS: Uploaded artifacts.'
