#!/bin/bash

# Script is used to update the F-Droid repository
# This script is expected to be run in a CI environment
# DO NOT execute this manually!

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
    export IRONFOX_CI=1
fi
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
    bash -x "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

# Include utilities
source "${IRONFOX_UTILS}"

# Function to download an APK for a desired release
function download_release() {
    local readonly version="$1"
    local readonly arch="$2"
    local readonly output_dir="$3"
    local readonly target_apk="ironfox-${version}-${arch}.apk"
    local readonly target_expected_sha512sum="${target_apk}-sha512sum.txt"
    local readonly target_expected_sha512sum_url="https://releases.ironfoxoss.org/ironfox/releases/${version}/${arch}/${target_expected_sha512sum}"
    local readonly target_apk_url="https://releases.ironfoxoss.org/ironfox/releases/${version}/${arch}/${target_apk}"
    local readonly output_apk="${output_dir}/${target_apk}"
    local readonly output_expected_sha512sum="${output_dir}/${target_expected_sha512sum}"

    # Download the APK
    echo_red_text "Downloading ${target_apk} from ${target_apk_url}..."
    curl ${IRONFOX_CURL_FLAGS} -sSL "${target_apk_url}" -o "${output_apk}"
    echo_green_text "SUCCESS: Downloaded ${target_apk}"

    # Check the SHA512sum
    echo_red_text "Validating SHA512sum for ${target_apk}.."
    curl ${IRONFOX_CURL_FLAGS} -sSL "${target_expected_sha512sum_url}" -o "${output_expected_sha512sum}"
    local readonly expected_sha512sum=$(cat "${output_expected_sha512sum}" | xargs)
    local readonly local_sha512sum=$(sha512sum "${output_apk}" | "${IRONFOX_AWK}" '{print $1}')
    if [ "${local_sha512sum}" != "${expected_sha512sum}" ]; then
        echo_red_text 'ERROR: Checksum validation failed.'
        echo "Expected SHA512sum: ${expected_sha512sum}"
        echo "Actual SHA512sum: ${local_sha512sum}"

        # If checksum validation fails, also just clean-up the files
        rm -f "${output_apk}"
        rm -f "${output_expected_sha512sum}"
        exit 1
    fi
    echo_green_text "SUCCESS: Checksum validated for ${target_apk}"
    echo "SHA512sum: ${local_sha512sum}"
}

# Function to download all APKs for a desired release
function download_releases() {
    # ARM64
    download_release "${IRONFOX_VERSION}" 'arm64-v8a' "${REPO_DIR_PATH}"

    # ARM
    download_release "${IRONFOX_VERSION}" 'armeabi-v7a' "${REPO_DIR_PATH}"

    # x86_64
    download_release "${IRONFOX_VERSION}" 'x86_64' "${REPO_DIR_PATH}"
}

git clone --recurse-submodules "https://${IF_CI_USERNAME}:${GITLAB_CI_PUSH_TOKEN}@gitlab.com/${FDROID_REPO_PATH}.git" fdroid
pushd fdroid || { echo "Unable to pushd into 'fdroid'"; exit 1; };
mkdir -vp "${REPO_DIR_PATH}"
git lfs install

# Download all variants of the latest release
download_releases

# Because we now upload releases to releases.ironfoxoss.org, the F-Droid repo doesn't need to store them all anymore
# So to improve performance and reduce size, we can keep only the last 3 releases

curl ${IRONFOX_CURL_FLAGS} -sSL 'https://releases.ironfoxoss.org/ironfox/releases/previous_release.txt' -o "${IRONFOX_ROOT}/previous_release.txt"
curl ${IRONFOX_CURL_FLAGS} -sSL 'https://releases.ironfoxoss.org/ironfox/releases/previous_previous_release.txt' -o "${IRONFOX_ROOT}/previous_previous_release.txt"

readonly previous_version=$(cat "${IRONFOX_ROOT}/previous_release.txt" | xargs)
readonly previous_previous_version=$(cat "${IRONFOX_ROOT}/previous_previous_release.txt" | xargs)

readonly current_apk_arm64="ironfox-${IRONFOX_VERSION}-arm64-v8a.apk"
readonly previous_apk_arm64="ironfox-${previous_version}-arm64-v8a.apk"
readonly previous_previous_apk_arm64="ironfox-${previous_previous_version}-arm64-v8a.apk"

readonly current_apk_arm="ironfox-${IRONFOX_VERSION}-armeabi-v7a.apk"
readonly previous_apk_arm="ironfox-${previous_version}-armeabi-v7a.apk"
readonly previous_previous_apk_arm="ironfox-${previous_previous_version}-armeabi-v7a.apk"

readonly current_apk_x86_64="ironfox-${IRONFOX_VERSION}-x86_64.apk"
readonly previous_apk_x86_64="ironfox-${previous_version}-x86_64.apk"
readonly previous_previous_apk_x86_64="ironfox-${previous_previous_version}-x86_64.apk"

for apk in "${REPO_DIR_PATH}"/*.apk; do
    apk_basename=$(basename "${apk}")
    if [ "${apk_basename}" != "${current_apk_arm64}" ] && [ "${apk_basename}" != "${previous_apk_arm64}" ] &&
     [ "${apk_basename}" != "${previous_previous_apk_arm64}" ] && [ "${apk_basename}" != "${current_apk_arm}" ] &&
     [ "${apk_basename}" != "${previous_apk_arm}" ] && [ "${apk_basename}" != "${previous_previous_apk_arm}" ] &&
     [ "${apk_basename}" != "${current_apk_x86_64}" ] && [ "${apk_basename}" != "${previous_apk_x86_64}" ] &&
     [ "${apk_basename}" != "${previous_previous_apk_x86_64}" ]; then
        rm -vf "${apk}"
    fi
done

source "${IRONFOX_PYENV}"
IFS=":" read -r vercode vername <<< "$("${IRONFOX_PYTHON}" "${IRONFOX_SCRIPTS}/get_latest_version.py" $(ls "${REPO_DIR_PATH}"/*.apk))"

readonly META_FILE_PATH="${META_DIR_PATH}/${META_FILE_NAME}"

"${IRONFOX_SED}" -i \
    -e "s/CurrentVersion: .*/CurrentVersion: \"v${vername}\"/" \
    -e "s/CurrentVersionCode: .*/CurrentVersionCode: ${vercode}/" "${META_FILE_PATH}"

pushd "${META_DIR_PATH}" || { echo "Unable to pushd into '${META_DIR_PATH}'"; exit 1; }

# Update metadata repository
git add "${META_FILE_NAME}"
git commit -m "feat: update for release ${CI_COMMIT_TAG}"
git push origin "HEAD:${META_REPO_BRANCH}"

popd || { echo "Unable to popd from '${META_DIR_PATH}'"; exit 1; }

# Update F-Droid repository
git add "${REPO_DIR_PATH}" "${META_DIR_PATH}"
git commit -m "feat: update for release ${CI_COMMIT_TAG}"
git push origin "HEAD:${FDROID_REPO_BRANCH}"

popd # ignore error
