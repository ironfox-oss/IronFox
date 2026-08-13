#!/bin/bash

# Script is used to update the F-Droid repository
# This script is expected to be run in a CI environment
# DO NOT execute this manually!

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

# Include utilities
source "${IRONFOX_UTILS}"

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: $0 should only be called from CI!"
  exit 1
fi

# Constants

# Base releases URL
readonly IRONFOX_RELEASES_BASE_URL='https://releases.ironfoxoss.org/ironfox/releases'

# fdroid repo
readonly IRONFOX_FDROID_REPO_ROOT="${IRONFOX_EXTERNAL}/fdroid"
readonly IRONFOX_FDROID_REPO="${IRONFOX_FDROID_REPO_ROOT}/fdroid/repo"
readonly IRONFOX_FDROID_REPO_BRANCH='dev'
readonly IRONFOX_FDROID_REPO_PATH='ironfox-oss/fdroid'

# fdroid-metadata repo
readonly IRONFOX_FDROID_METADATA="${IRONFOX_FDROID_REPO_ROOT}/fdroid/metadata"
readonly IRONFOX_FDROID_METADATA_BRANCH='main'
readonly IRONFOX_FDROID_METADATA_FILE_NAME='org.ironfoxoss.ironfox.yml'
readonly IRONFOX_FDROID_METADATA_FILE_PATH="${IRONFOX_FDROID_METADATA}/${IRONFOX_FDROID_METADATA_FILE_NAME}"

# Git
readonly IRONFOX_GIT_EMAIL='ci@ironfoxoss.org'
readonly IRONFOX_GIT_NAME='IronFox CI'
readonly IRONFOX_GIT_USERNAME='ironfox-ci'

# Configure Git
function configure_git() {
  # Ensure we have a push token...
  if [[ -z "${IRONFOX_GITLAB_CI_PUSH_TOKEN+x}" ]]; then
    echo_red_text 'ERROR: Missing GitLab CI Push Token! Please set IRONFOX_GITLAB_CI_PUSH_TOKEN.'
    exit 1
  fi

  echo_red_text 'Configuring Git...'
  "${IRONFOX_GIT}" config --global user.email "${IRONFOX_GIT_EMAIL}"
  "${IRONFOX_GIT}" config --global user.name "${IRONFOX_GIT_NAME}"
  "${IRONFOX_GIT}" config --global url."https://${IRONFOX_GIT_USERNAME}:${IRONFOX_GITLAB_CI_PUSH_TOKEN}@gitlab.com/".insteadOf "https://gitlab.com/"
  echo_green_text 'SUCCESS: Configured Git.'
}

# Function to download an APK for a desired release
function download_release() {
  local -r version="$1"
  local -r arch="$2"
  local -r output_dir="$3"
  local -r target_apk="ironfox-${version}-${arch}.apk"
  local -r target_expected_sha512sum="${target_apk}-sha512sum.txt"
  local -r target_expected_sha512sum_url="${IRONFOX_RELEASES_BASE_URL}/${version}/${arch}/${target_expected_sha512sum}"
  local -r target_apk_url="${IRONFOX_RELEASES_BASE_URL}/${version}/${arch}/${target_apk}"
  local -r output_apk="${output_dir}/${target_apk}"
  local -r output_expected_sha512sum="${output_dir}/${target_expected_sha512sum}"

  # Download the APK
  echo_red_text "Downloading ${target_apk} from ${target_apk_url}..."
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${target_apk_url}" --output "${output_apk}"
  echo_green_text "SUCCESS: Downloaded ${target_apk}"

  # Check the SHA512sum
  echo_red_text "Validating SHA512sum for ${target_apk}.."
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${target_expected_sha512sum_url}" --output "${output_expected_sha512sum}"
  local -r expected_sha512sum=$("${IRONFOX_CAT}" "${output_expected_sha512sum}" | "${IRONFOX_XARGS}")
  local -r local_sha512sum=$("${IRONFOX_SHASUM}" -a 512 "${output_apk}" | "${IRONFOX_AWK}" '{print $1}')
  if [[ "${local_sha512sum}" != "${expected_sha512sum}" ]]; then
    echo_red_text 'ERROR: Checksum validation failed.'
    echo "Expected SHA512sum: ${expected_sha512sum}"
    echo "Actual SHA512sum:   ${local_sha512sum}"

    # If checksum validation fails, also just clean-up the files
    "${IRONFOX_RM}" -f "${output_apk}"
    "${IRONFOX_RM}" -f "${output_expected_sha512sum}"
    exit 1
  fi
  echo_green_text "SUCCESS: Checksum validated for ${target_apk}"
  echo "SHA512sum: ${local_sha512sum}"
}

# Function to download all APKs for a desired release
function download_releases() {
  # ARM64
  download_release "${IRONFOX_VERSION}" 'arm64-v8a' "${IRONFOX_FDROID_REPO}"

  # ARM
  download_release "${IRONFOX_VERSION}" 'armeabi-v7a' "${IRONFOX_FDROID_REPO}"

  # x86_64
  download_release "${IRONFOX_VERSION}" 'x86_64' "${IRONFOX_FDROID_REPO}"
}

# Configure Git
configure_git

# Clone the repo
"${IRONFOX_GIT}" clone --recurse-submodules "https://${IRONFOX_GIT_USERNAME}:${IRONFOX_GITLAB_CI_PUSH_TOKEN}@gitlab.com/${IRONFOX_FDROID_REPO_PATH}.git" "${IRONFOX_FDROID_REPO_ROOT}"
pushd "${IRONFOX_FDROID_REPO_ROOT}" || {
  echo_red_text "ERROR: Unable to pushd into '${IRONFOX_FDROID_REPO_ROOT}'"
  exit 1
}
"${IRONFOX_MKDIR}" -vp "${IRONFOX_FDROID_REPO}"
"${IRONFOX_GIT}" lfs install

# Download all variants of the latest release
download_releases

# Because we now upload releases to releases.ironfoxoss.org, the F-Droid repo doesn't need to store them all anymore
# So to improve performance and reduce size, we can keep only the last 3 releases

"${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${IRONFOX_RELEASES_BASE_URL}/previous_release.txt" --output "${IRONFOX_ROOT}/previous_release.txt"
"${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${IRONFOX_RELEASES_BASE_URL}/previous_previous_release.txt" --output "${IRONFOX_ROOT}/previous_previous_release.txt"

readonly previous_version=$("${IRONFOX_CAT}" "${IRONFOX_ROOT}/previous_release.txt" | "${IRONFOX_XARGS}")
readonly previous_previous_version=$("${IRONFOX_CAT}" "${IRONFOX_ROOT}/previous_previous_release.txt" | "${IRONFOX_XARGS}")

readonly current_apk_arm64="ironfox-${IRONFOX_VERSION}-arm64-v8a.apk"
readonly previous_apk_arm64="ironfox-${previous_version}-arm64-v8a.apk"
readonly previous_previous_apk_arm64="ironfox-${previous_previous_version}-arm64-v8a.apk"

readonly current_apk_arm="ironfox-${IRONFOX_VERSION}-armeabi-v7a.apk"
readonly previous_apk_arm="ironfox-${previous_version}-armeabi-v7a.apk"
readonly previous_previous_apk_arm="ironfox-${previous_previous_version}-armeabi-v7a.apk"

readonly current_apk_x86_64="ironfox-${IRONFOX_VERSION}-x86_64.apk"
readonly previous_apk_x86_64="ironfox-${previous_version}-x86_64.apk"
readonly previous_previous_apk_x86_64="ironfox-${previous_previous_version}-x86_64.apk"

for apk in "${IRONFOX_FDROID_REPO}"/*.apk; do
  apk_basename=$("${IRONFOX_BASENAME}" "${apk}")
  if [[ "${apk_basename}" != "${current_apk_arm64}" ]] && [[ "${apk_basename}" != "${previous_apk_arm64}" ]] &&
    [[ "${apk_basename}" != "${previous_previous_apk_arm64}" ]] && [[ "${apk_basename}" != "${current_apk_arm}" ]] &&
    [[ "${apk_basename}" != "${previous_apk_arm}" ]] && [[ "${apk_basename}" != "${previous_previous_apk_arm}" ]] &&
    [[ "${apk_basename}" != "${current_apk_x86_64}" ]] && [[ "${apk_basename}" != "${previous_apk_x86_64}" ]] &&
    [[ "${apk_basename}" != "${previous_previous_apk_x86_64}" ]]; then
    "${IRONFOX_RM}" -vf "${apk}"
  fi
done

source "${IRONFOX_PYENV}"
IFS=":" read -r vercode vername <<< "$("${IRONFOX_PYTHON}" "${IRONFOX_SCRIPTS}/get_latest_version.py" $("${IRONFOX_LS}" "${IRONFOX_FDROID_REPO}"/*.apk))"

"${IRONFOX_SED}" -i \
  -e "s/CurrentVersion: .*/CurrentVersion: \"v${vername}\"/" \
  -e "s/CurrentVersionCode: .*/CurrentVersionCode: ${vercode}/" "${IRONFOX_FDROID_METADATA_FILE_PATH}"

pushd "${IRONFOX_FDROID_METADATA}" || {
  echo_red_text "ERROR: Unable to pushd into '${IRONFOX_FDROID_METADATA}'"
  exit 1
}

# Update metadata repository
"${IRONFOX_GIT}" add "${IRONFOX_FDROID_METADATA_FILE_NAME}"
"${IRONFOX_GIT}" commit -m "feat: update for release ${IRONFOX_VERSION}" || echo 'Metadata repo already up to date! Not committing anything...'
"${IRONFOX_GIT}" push origin "HEAD:${IRONFOX_FDROID_METADATA_BRANCH}" || echo 'Metadata repo already up to date! Not pushing anything...'

popd || {
  echo_red_text "ERROR: Unable to popd from '${IRONFOX_FDROID_METADATA}'"
  exit 1
}

# Update F-Droid repository
"${IRONFOX_GIT}" add "${IRONFOX_FDROID_REPO}" "${IRONFOX_FDROID_METADATA}"
"${IRONFOX_GIT}" commit -m "feat: update for release ${IRONFOX_VERSION}"
"${IRONFOX_GIT}" push origin "HEAD:${IRONFOX_FDROID_REPO_BRANCH}"

popd # ignore error
