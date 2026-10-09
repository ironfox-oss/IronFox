#!/bin/bash

set -euo pipefail

# Set verbosity
set_verbosity

# Include download utilities
verify_file_with_env "${IRONFOX_DOWNLOAD_UTILS}" 'IRONFOX_DOWNLOAD_UTILS' || return 1
source "${IRONFOX_DOWNLOAD_UTILS}" || return 1

if [[ -z "${IRONFOX_FROM_AR_DOWN+x}" ]]; then
  echo_red_text "ERROR: Do not call 'ci-download-artifacts-if.sh' directly! Instead, use 'ci-download-artifacts.sh'." >&1
  return 1
fi

# Ensure we have `IRONFOX_CI`
verify_env "${IRONFOX_CI}" 'IRONFOX_CI' || return 1

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  return 1
fi

# Ensure we have `IRONFOX_CI_ID`
verify_env "${IRONFOX_CI_ID}" 'IRONFOX_CI_ID' || return 1

verify_env "${target_artifact}" 'target_artifact' || {
  echo_red_text "ERROR: Missing target artifact!"
  return 1
}

verify_env "${target_arch}" 'target_arch' || {
  echo_red_text "ERROR: Missing target architecture!"
  return 1
}

# Set-up target parameters
IRONFOX_AR_DOWN_FENIX=0
IRONFOX_AR_DOWN_GECKOVIEW=0

if [[ "${target_artifact}" == 'fenix' ]]; then
  # Download Fenix
  IRONFOX_AR_DOWN_FENIX=1
elif [[ "${target_artifact}" == 'geckoview' ]]; then
  # Push GeckoView
  IRONFOX_AR_DOWN_GECKOVIEW=1
else
  echo_red_text "ERROR: Invalid target: '${target_artifact}'\n You must enter one of the following:"
  echo 'Fenix:      fenix'
  echo 'GeckoView:  geckoview'
  return 1
fi
readonly IRONFOX_AR_DOWN_FENIX
readonly IRONFOX_AR_DOWN_GECKOVIEW

if [[ "${target_arch}" != 'arm64' ]] && [[ "${target_arch}" != 'arm' ]] && [[ "${target_arch}" != 'x86_64' ]] && [[ "${target_arch}" != 'bundle' ]]; then
  echo_red_text "ERROR: Invalid target architecture: ${target_arch}\n You must enter one of the following:"
  echo 'ARM64:      arm64'
  echo 'ARM:        arm'
  echo 'x86_64:     x86_64'
  echo 'Bundle:     bundle'
  return 1
fi
readonly IRONFOX_AR_DOWN_ARCH="${target_arch}"

# Constants

# Base artifacts URL
readonly IRONFOX_ARTIFACTS_URL='https://artifacts.ironfoxoss.org/ironfox'

# Download and verify the SHA512sum of an artifact
function download_artifact() {
  function print_usage() {
    echo "Usage: download_artifact 'pipeline_id' 'artifact_name' 'path/to/download/artifact/to' 'arch'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the pipeline ID to download the artifact from!'
    print_usage
    return 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please provide the name of the artifact to download!'
    print_usage
    return 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text 'ERROR: Please provide the path to download the artifact to!'
    print_usage
    return 1
  fi

  if [[ -z "${4+x}" ]]; then
    echo_red_text 'ERROR: Please provide the architecture of the artifact to download!'
    print_usage
    return 1
  fi

  # Ensure we have cat
  verify_exec "${IRONFOX_CAT}" 'IRONFOX_CAT' || return 1

  # Ensure we have GNU awk
  verify_exec "${IRONFOX_AWK}" 'IRONFOX_AWK' || return 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || return 1

  # Ensure we have shasum
  verify_exec "${IRONFOX_SHASUM}" 'IRONFOX_SHASUM' || return 1

  # Ensure we have xargs
  verify_exec "${IRONFOX_XARGS}" 'IRONFOX_XARGS' || return 1

  # Ensure we have `IRONFOX_CHANNEL`
  verify_env "${IRONFOX_CHANNEL}" 'IRONFOX_CHANNEL' || return 1

  # Ensure we have `IRONFOX_VERSION`
  verify_env "${IRONFOX_VERSION}" 'IRONFOX_VERSION' || return 1

  # Ensure we have `IRONFOX_ARTIFACTS_URL`
  verify_env "${IRONFOX_ARTIFACTS_URL}" 'IIRONFOX_ARTIFACTS_URL' || return 1

  local -r pipeline_id="$1"
  local -r artifact="$2"
  local -r output_dir="$3"
  local -r arch="$4"

  if [[ "${arch}" == 'arm64' ]]; then
    local -r arch_suffix='arm64-v8a'
  elif [[ "${arch}" == 'arm' ]]; then
    local -r arch_suffix='armeabi-v7a'
  elif [[ "${arch}" == 'x86_64' ]]; then
    local -r arch_suffix='x86_64'
  elif [[ "${arch}" == 'universal' ]]; then
    local -r arch_suffix='universal'
  elif [[ "${arch}" != 'bundle' ]]; then
    echo_red_text "ERROR: Unknown architecture: '${arch}'!"
    return 1
  fi

  if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
    local -r if_version="${IRONFOX_VERSION}"
  else
    verify_env "${IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE}" 'IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE' || return 1
    local -r if_version="${IRONFOX_VERSION}.${IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE}"
  fi

  if [[ "${artifact}" == 'fenix' ]]; then
    if [[ "${arch}" == 'bundle' ]]; then
      if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
        local -r target_file="ironfox-${if_version}.apks"
      else
        local -r target_file="ironfox-${IRONFOX_CHANNEL}-${if_version}.apks"
      fi
    else
      if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
        local -r target_file="ironfox-${if_version}-${arch_suffix}.apk"
      else
        local -r target_file="ironfox-${IRONFOX_CHANNEL}-${if_version}-${arch_suffix}.apk"
      fi
    fi
  elif [[ "${artifact}" == 'geckoview' ]]; then
    local -r target_file="geckoview-${arch_suffix}.zip"
  else
    echo_red_text "ERROR: Unknown artifact: '${artifact}'!"
    return 1
  fi

  local -r target_expected_sha512sum="${target_file}-sha512sum.txt"
  local -r target_expected_sha512sum_url="${IRONFOX_ARTIFACTS_URL}/${pipeline_id}/${target_expected_sha512sum}"
  local -r target_file_url="${IRONFOX_ARTIFACTS_URL}/${pipeline_id}/${target_file}"
  local -r output_file="${output_dir}/${target_file}"
  local -r output_expected_sha512sum="${output_dir}/${target_expected_sha512sum}"

  # Download the artifact
  download "${target_file_url}" "${output_file}"

  # Check the SHA512sum
  echo_red_text "Validating SHA512sum for file: '${target_file}'.."
  download "${target_expected_sha512sum_url}" "${output_expected_sha512sum}"
  local -r expected_sha512sum=$("${IRONFOX_CAT}" "${output_expected_sha512sum}" | "${IRONFOX_XARGS}")
  local -r local_sha512sum=$("${IRONFOX_SHASUM}" -a 512 "${output_file}" | "${IRONFOX_AWK}" '{print $1}')
  if [[ "${local_sha512sum}" != "${expected_sha512sum}" ]]; then
    echo_red_text "ERROR: Checksum validation for file failed: '${target_file}'!"
    echo "Expected SHA512sum: '${expected_sha512sum}'"
    echo "Actual SHA512sum:   '${local_sha512sum}'"

    # If checksum validation fails, also just clean-up the files
    "${IRONFOX_RM}" -f "${output_file}"
    "${IRONFOX_RM}" -f "${output_expected_sha512sum}"
    return 1
  fi
  echo_green_text "SUCCESS: Validated checksum for file: '${target_file}'!"
  echo "SHA512sum: '${local_sha512sum}'"
}

if [[ "${IRONFOX_AR_DOWN_FENIX}" == 1 ]]; then
  # Ensure we have `IRONFOX_APK_ARTIFACTS`
  verify_env "${IRONFOX_APK_ARTIFACTS}" 'IRONFOX_APK_ARTIFACTS' || return 1

  # Ensure we have `IRONFOX_APKS_ARTIFACTS`
  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'bundle' ]]; then
    verify_env "${IRONFOX_APKS_ARTIFACTS}" 'IRONFOX_APKS_ARTIFACTS' || return 1
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'arm64' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'fenix' "${IRONFOX_APK_ARTIFACTS}" 'arm64'
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'arm' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'fenix' "${IRONFOX_APK_ARTIFACTS}" 'arm'
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'x86_64' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'fenix' "${IRONFOX_APK_ARTIFACTS}" 'x86_64'
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'bundle' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'fenix' "${IRONFOX_APK_ARTIFACTS}" 'universal'
    download_artifact "${IRONFOX_CI_ID}" 'fenix' "${IRONFOX_APKS_ARTIFACTS}" 'bundle'
  fi
fi

if [[ "${IRONFOX_AR_DOWN_GECKOVIEW}" == 1 ]]; then
  # Ensure we have `IRONFOX_AAR_ARTIFACTS`
  verify_env "${IRONFOX_AAR_ARTIFACTS}" 'IRONFOX_AAR_ARTIFACTS' || return 1

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'arm64' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'geckoview' "${IRONFOX_AAR_ARTIFACTS}" 'arm64'
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'arm' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'geckoview' "${IRONFOX_AAR_ARTIFACTS}" 'arm'
  fi

  if [[ "${IRONFOX_AR_DOWN_ARCH}" == 'x86_64' ]]; then
    download_artifact "${IRONFOX_CI_ID}" 'geckoview' "${IRONFOX_AAR_ARTIFACTS}" 'x86_64'
  fi
fi
