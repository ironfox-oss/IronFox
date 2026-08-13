#!/bin/bash

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Include version info
source "${IRONFOX_VERSIONS}"

if [[ -z "${IRONFOX_FROM_AR_DOWN+x}" ]]; then
  echo_red_text 'ERROR: Do not call ci-download-artifacts-if.sh directly. Instead, use ci-download-artifacts.sh.' >&1
  exit 1
fi

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

if [[ -z "${IRONFOX_CI_ID+x}" ]]; then
  echo_red_text 'ERROR: Missing CI ID! Please set IRONFOX_CI_ID.'
  exit 1
fi

readonly down_artifact="$1"

# Set-up target parameters
IRONFOX_AR_DOWN_FENIX=0
IRONFOX_AR_DOWN_GECKOVIEW=0

if [[ "${down_artifact}" == 'fenix' ]]; then
  # Download Fenix
  IRONFOX_AR_DOWN_FENIX=1
elif [[ "${down_artifact}" == 'geckoview' ]]; then
  # Push GeckoView
  IRONFOX_AR_DOWN_GECKOVIEW=1
else
  echo_red_text "ERROR: Invalid artifact: ${down_artifact}\n You must enter one of the following:"
  echo 'Fenix:      fenix'
  echo 'GeckoView:  geckoview'
  exit 1
fi
readonly IRONFOX_AR_DOWN_FENIX
readonly IRONFOX_AR_DOWN_GECKOVIEW

readonly down_arch="$2"

if [[ "${down_arch}" != 'arm64' ]] && [[ "${down_arch}" != 'arm' ]] && [[ "${down_arch}" != 'x86_64' ]] && [[ "${down_arch}" != 'bundle' ]]; then
  echo_red_text "ERROR: Invalid target architecture: ${down_arch}\n You must enter one of the following:"
  echo 'ARM64:      arm64'
  echo 'ARM:        arm'
  echo 'x86_64:     x86_64'
  echo 'Bundle:     bundle'
  exit 1
fi
readonly IRONFOX_AR_DOWN_ARCH="${down_arch}"

# Function to download and verify the SHA512sum of an artifact
function download_artifact() {
  local -r pipeline_id="$1"
  local -r artifact="$2"
  local -r arch="$3"
  local -r output_dir="$4"

  if [[ "${arch}" == 'arm64' ]]; then
    local -r arch_suffix='arm64-v8a'
  elif [[ "${arch}" == 'arm' ]]; then
    local -r arch_suffix='armeabi-v7a'
  elif [[ "${arch}" == 'x86_64' ]]; then
    local -r arch_suffix='x86_64'
  elif [[ "${arch}" == 'universal' ]]; then
    local -r arch_suffix='universal'
  fi

  if [[ "${artifact}" == 'fenix' ]]; then
    if [[ "${arch}" == 'bundle' ]]; then
      if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
        local -r target_file="ironfox-${IRONFOX_VERSION}.apks"
      else
        local -r target_file="ironfox-${IRONFOX_CHANNEL}-${IRONFOX_VERSION}.apks"
      fi
    else
      if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
        local -r target_file="ironfox-${IRONFOX_VERSION}-${arch_suffix}.apk"
      else
        local -r target_file="ironfox-${IRONFOX_CHANNEL}-${IRONFOX_VERSION}-${arch_suffix}.apk"
      fi
    fi
  elif [[ "${artifact}" == 'geckoview' ]]; then
    local -r target_file="geckoview-${arch_suffix}.zip"
  fi

  local -r target_expected_sha512sum="${target_file}-sha512sum.txt"
  local -r target_expected_sha512sum_url="https://artifacts.ironfoxoss.org/ironfox/${pipeline_id}/${target_expected_sha512sum}"
  local -r target_file_url="https://artifacts.ironfoxoss.org/ironfox/${pipeline_id}/${target_file}"
  local -r output_file="${output_dir}/${target_file}"
  local -r output_expected_sha512sum="${output_dir}/${target_expected_sha512sum}"

  # Download the artifact
  "${IRONFOX_MKDIR}" -p "${output_dir}"
  echo_red_text "Downloading ${target_file} from ${target_file_url}..."
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${target_file_url}" --output "${output_file}"
  echo_green_text "SUCCESS: Downloaded ${target_file}"

  # Check the SHA512sum
  echo_red_text "Validating SHA512sum for ${target_file}.."
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${target_expected_sha512sum_url}" --output "${output_expected_sha512sum}"
  local -r expected_sha512sum=$("${IRONFOX_CAT}" "${output_expected_sha512sum}" | "${IRONFOX_XARGS}")
  local -r local_sha512sum=$("${IRONFOX_SHASUM}" -a 512 "${output_file}" | "${IRONFOX_AWK}" '{print $1}')
  if [[ "${local_sha512sum}" != "${expected_sha512sum}" ]]; then
    echo_red_text 'ERROR: Checksum validation failed.'
    echo "Expected SHA512sum: ${expected_sha512sum}"
    echo "Actual SHA512sum:   ${local_sha512sum}"

    # If checksum validation fails, also just clean-up the files
    "${IRONFOX_RM}" -f "${output_file}"
    "${IRONFOX_RM}" -f "${output_expected_sha512sum}"
    exit 1
  fi
  echo_green_text "SUCCESS: Checksum validated for ${target_file}"
  echo "SHA512sum: ${local_sha512sum}"
}

if [[ "${IRONFOX_AR_DOWN_FENIX}" == 1 ]]; then
  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'arm64' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'fenix' 'arm64' "${IRONFOX_APK_ARTIFACTS}"
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'arm' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'fenix' 'arm' "${IRONFOX_APK_ARTIFACTS}"
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'x86_64' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'fenix' 'x86_64' "${IRONFOX_APK_ARTIFACTS}"
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'bundle' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'fenix' 'universal' "${IRONFOX_APK_ARTIFACTS}"
    download_artifact "${IRONFOX_CI_ID}" 'fenix' 'bundle' "${IRONFOX_APKS_ARTIFACTS}"
  fi
fi

if [[ "${IRONFOX_AR_DOWN_GECKOVIEW}" == 1 ]]; then
  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'arm64' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'geckoview' 'arm64' "${IRONFOX_AAR_ARTIFACTS}"
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'arm' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'geckoview' 'arm' "${IRONFOX_AAR_ARTIFACTS}"
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'x86_64' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'geckoview' 'x86_64' "${IRONFOX_AAR_ARTIFACTS}"
  fi
fi
