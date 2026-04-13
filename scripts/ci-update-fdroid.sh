#!/bin/bash

# Script is used to update the F-Droid repository
# This script is expected to be run in a CI environment
# DO NOT execute this manually!

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
    bash -x "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

git clone --recurse-submodules "https://${IF_CI_USERNAME}:${GITLAB_CI_PUSH_TOKEN}@gitlab.com/${FDROID_REPO_PATH}.git" fdroid
pushd fdroid || { echo "Unable to pushd into 'fdroid'"; exit 1; };
mkdir -vp "${REPO_DIR_PATH}"
git lfs install

# Download all assets from the release
curl ${IRONFOX_CURL_FLAGS} --header "PRIVATE-TOKEN: ${GITLAB_CI_API_TOKEN}" \
"${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases/${CI_COMMIT_TAG}/assets/links" \
| jq -c '.[] | select(.name | endswith(".apk") and (endswith("universal.apk") | not))' \
| while read -r asset; do
    name=$(echo "${asset}" | jq -r '.name')
    url=$(echo "${asset}" | jq -r '.direct_asset_url')
    echo "Downloading ${name} from ${url}"
    curl ${IRONFOX_CURL_FLAGS} "${url}" -o "${REPO_DIR_PATH}/${name}"
done

# Because we now upload releases to releases.ironfoxoss.org, the F-Droid repo doesn't need to store them all anymore
# So to improve performance and reduce size, we can keep only the last 3 releases

curl ${IRONFOX_CURL_FLAGS} -sSL 'https://releases.ironfoxoss.org/ironfox/releases/previous_release.txt' -o "${CI_PROJECT_DIR}/previous_release.txt"
curl ${IRONFOX_CURL_FLAGS} -sSL 'https://releases.ironfoxoss.org/ironfox/releases/previous_previous_release.txt' -o "${CI_PROJECT_DIR}/previous_previous_release.txt"

local readonly previous_version=$(cat "${CI_PROJECT_DIR}/previous_release.txt" | xargs)
local readonly previous_previous_version=$(cat "${CI_PROJECT_DIR}/previous_previous_release.txt" | xargs)

local readonly current_apk_arm64="ironfox-${IRONFOX_VERSION}-arm64-v8a.apk"
local readonly previous_apk_arm64="ironfox-${previous_version}-arm64-v8a.apk"
local readonly previous_previous_apk_arm64="ironfox-${previous_previous_version}-arm64-v8a.apk"

local readonly current_apk_arm="ironfox-${IRONFOX_VERSION}-armeabi-v7a.apk"
local readonly previous_apk_arm="ironfox-${previous_version}-armeabi-v7a.apk"
local readonly previous_previous_apk_arm="ironfox-${previous_previous_version}-armeabi-v7a.apk"

local readonly current_apk_x86_64="ironfox-${IRONFOX_VERSION}-x86_64.apk"
local readonly previous_apk_x86_64="ironfox-${previous_version}-x86_64.apk"
local readonly previous_previous_apk_x86_64="ironfox-${previous_previous_version}-x86_64.apk"

for apk in "${REPO_DIR_PATH}"/*.apk; do
    local apk_basename=$(basename "${apk}")
    if [ "${apk_basename}" != "${current_apk_arm64}" ] && [ "${apk_basename}" != "${previous_apk_arm64}" ] &&
     [ "${apk_basename}" != "${previous_previous_apk_arm64}" ] && [ "${apk_basename}" != "${current_apk_arm}" ] &&
     [ "${apk_basename}" != "${previous_apk_arm}" ] && [ "${apk_basename}" != "${previous_previous_apk_arm}" ] &&
     [ "${apk_basename}" != "${current_apk_x86_64}" ] && [ "${apk_basename}" != "${previous_apk_x86_64}" ] &&
     [ "${apk_basename}" != "${previous_previous_apk_x86_64}" ]; then
        rm -vf "${apk}"
    fi
done

IFS=":" read -r vercode vername <<< "$("${CI_PROJECT_DIR}"/scripts/get_latest_version.py $(ls "${REPO_DIR_PATH}"/*.apk))"

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
