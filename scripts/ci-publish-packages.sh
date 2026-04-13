#!/bin/bash

# This file is expected to be executed in GitLab CI
# DO NOT executed this manually!

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
    bash -x "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

if [[ -z "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_ACCESS_KEY_FILE environment variable is missing! Aborting...'
    exit 1
fi

if ! [[ -f "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" ]]; then
    echo_red_text "ERROR: S3 access key file not found! (${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE})"
    echo_green_text "Please ensure the IRONFOX_RELEASES_S3_ACCESS_KEY_FILE environment variable is set to the correct path in which the key file is located."
    echo_red_text "Aborting..."
    exit 1
fi

if ! [[ -s "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" ]]; then
    echo_red_text "ERROR: S3 access key file ${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE} is empty!"
    exit 1
fi

if [[ -z "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_BUCKET_NAME_FILE environment variable is missing! Aborting...'
    exit 1
fi

if ! [[ -f "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" ]]; then
    echo_red_text "ERROR: S3 bucket name file not found! (${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE})"
    echo_green_text "Please ensure the IRONFOX_RELEASES_S3_BUCKET_NAME_FILE environment variable is set to the correct path in which the bucket name file is located."
    echo_red_text "Aborting..."
    exit 1
fi

if ! [[ -s "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" ]]; then
    echo_red_text "ERROR: S3 bucket name file ${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE} is empty!"
    exit 1
fi

if [[ -z "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_ENDPOINT_FILE environment variable is missing! Aborting...'
    exit 1
fi

if ! [[ -f "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" ]]; then
    echo_red_text "ERROR: S3 endpoint file not found! (${IRONFOX_RELEASES_S3_ENDPOINT_FILE})"
    echo_green_text "Please ensure the IRONFOX_RELEASES_S3_ENDPOINT_FILE environment variable is set to the correct path in which the endpoint file is located."
    echo_red_text "Aborting..."
    exit 1
fi

if ! [[ -s "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" ]]; then
    echo_red_text "ERROR: S3 bucket name file ${IRONFOX_RELEASES_S3_ENDPOINT_FILE} is empty!"
    exit 1
fi

if [[ -z "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_SECRET_KEY_FILE environment variable is missing! Aborting...'
    exit 1
fi

if ! [[ -f "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" ]]; then
    echo_red_text "ERROR: S3 secret key file not found! (${IRONFOX_RELEASES_S3_SECRET_KEY_FILE})"
    echo_green_text "Please ensure the IRONFOX_RELEASES_S3_SECRET_KEY_FILE environment variable is set to the correct path in which the key file is located."
    echo_red_text "Aborting..."
    exit 1
fi

if ! [[ -s "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" ]]; then
    echo_red_text "ERROR: S3 secret key file ${IRONFOX_RELEASES_S3_SECRET_KEY_FILE} is empty!"
    exit 1
fi

readonly GENERIC_PACKAGES_URL="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic"

function upload_to_package_registry() {
    local readonly upload_file="$1"
    local readonly upload_package_name="$2"
    local readonly upload_file_name="$(basename "${upload_file}")"
    curl ${IRONFOX_CURL_FLAGS} --header "PRIVATE-TOKEN: ${GITLAB_CI_API_TOKEN}" \
        --upload-file "${upload_file}" \
        "${GENERIC_PACKAGES_URL}/${upload_package_name}/${IRONFOX_VERSION}/${upload_file_name}"
}

function upload_to_s3() {
    local readonly upload_file="$1"
    local readonly s3_path="$2"
    local readonly s3_full_path="${s3_path}/$(basename "${upload_file}")"

    if ! [[ -f "${upload_file}" ]]; then
        echo_red_text "ERROR: File ${upload_file} does not exist!"
        exit 1
    fi

    if ! [[ -s "${upload_file}" ]]; then
        echo_red_text "ERROR: File ${upload_file} is empty!"
        exit 1
    fi

    local readonly s3_access_key=$(cat "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" | xargs)
    local readonly s3_bucket_name=$(cat "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" | xargs)
    local readonly s3_endpoint=$(cat "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" | xargs)
    local readonly s3_secret_key=$(cat "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" | xargs)

    echo_red_text "Uploading ${upload_file} to S3..."
    source "${IRONFOX_PYENV}"
    "${IRONFOX_S3CMD}" ${IRONFOX_S3CMD_FLAGS} put "${upload_file}" "s3://${s3_bucket_name}/${s3_full_path}" \
      --access_key="${s3_access_key}" \
      --secret_key="${s3_secret_key}" \
      --host="${s3_endpoint}" \
      --host-bucket="${s3_endpoint}"
    echo_green_text "SUCCESS: Uploaded ${upload_file} to S3"
}

function add_sha512sum() {
    local readonly sha512sum_file_in="$1"
    local readonly sha512sum_file_name=$(basename "${sha512sum_file_in}")
    local readonly sha512sum_file_path=$(dirname "${sha512sum_file_in}")

    if [[ -z "${2+x}" ]]; then
        local readonly sha512sum_s3path=$(basename "${sha512sum_file_path}" | "${IRONFOX_AWK}" '{print tolower($0)}')
    else
        local readonly sha512sum_s3path="$2"
    fi

    local readonly sha512sum_file_out="${sha512sum_file_path}/${sha512sum_file_name}-sha512sum.txt"

    # If there's already a SHA512sum file, remove it
    if [ -f "${sha512sum_file_out}" ]; then
        rm -f "${sha512sum_file_out}"
    fi

    local readonly local_sha512sum=$(sha512sum "${sha512sum_file_in}" | "${IRONFOX_AWK}" '{print $1}')
    echo -n "${local_sha512sum}" > "${sha512sum_file_out}"

    upload_to_s3 "${sha512sum_file_out}" "${sha512sum_s3path}"
}

# Extract compressed artifacts
mkdir -p "${IRONFOX_ARTIFACTS}"
for archive in "${IRONFOX_ARTIFACTS}"/*.tar.xz; do
    [ -f "${archive}" ] || continue
    echo "Extracting ${archive}"
    "${IRONFOX_TAR}" xvJf "${archive}" -C "${IRONFOX_ARTIFACTS}"
done

readonly BUILD_DIR="${CI_PROJECT_DIR}/build"

mkdir -vp "${BUILD_DIR}"

readonly RELEASE_NOTES_FILE="${BUILD_DIR}/release-notes.md"
readonly CHECKSUMS_FILE="${BUILD_DIR}/asset-checksums.txt"
readonly RELEASE_FILE="${BUILD_DIR}/release.yml"

echo -n "" > "${RELEASE_NOTES_FILE}"
echo -n "" > "${CHECKSUMS_FILE}"

declare -a assets
function upload_asset() {
    local readonly asset_package_name="$1"
    local readonly asset_s3_path="$2"
    local readonly asset_file="$3"
    local readonly asset_file_name="$(basename "${asset_file}")"

    echo "\`${asset_file_name}\`: " >> "${CHECKSUMS_FILE}"
    echo "\`\`\`sh" >> "${CHECKSUMS_FILE}"
    echo "$(sha512sum -b "${asset_file}" | cut -d ' ' -f 1)" >> "${CHECKSUMS_FILE}"
    echo "\`\`\`" >> "${CHECKSUMS_FILE}"
    echo '' >> "${CHECKSUMS_FILE}"
    upload_to_package_registry "${asset_file}" "${asset_package_name}"
    upload_to_s3 "${asset_file}" "${asset_s3_path}"
    add_sha512sum "${asset_file}" "${asset_s3_path}"
}

function upload_apk_arm64() {
    upload_asset 'apk' "ironfox/releases/${IRONFOX_VERSION}/arm64-v8a" "${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-arm64-v8a.apk"
    local readonly arm64_file_name="$(basename "${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-arm64-v8a.apk")"
    assets+=("{\"name\": \"${arm64_file_name}\",\"url\": \"https://releases.ironfoxoss.org/ironfox/releases/${IRONFOX_VERSION}/arm64-v8a/${arm64_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${arm64_file_name}\"}")
}

function upload_apk_arm() {
    upload_asset 'apk' "ironfox/releases/${IRONFOX_VERSION}/armeabi-v7a" "${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-armeabi-v7a.apk"
    local readonly arm_file_name="$(basename "${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-armeabi-v7a.apk")"
    assets+=("{\"name\": \"${arm_file_name}\",\"url\": \"https://releases.ironfoxoss.org/ironfox/releases/${IRONFOX_VERSION}/armeabi-v7a/${arm_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${arm_file_name}\"}")
}

function upload_apk_x86_64() {
    upload_asset 'apk' "ironfox/releases/${IRONFOX_VERSION}/x86_64" "${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-x86_64.apk"
    local readonly x86_64_file_name="$(basename "${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-x86_64.apk")"
    assets+=("{\"name\": \"${x86_64_file_name}\",\"url\": \"https://releases.ironfoxoss.org/ironfox/releases/${IRONFOX_VERSION}/x86_64/${x86_64_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${x86_64_file_name}\"}")
}

function upload_apk_universal() {
    upload_asset 'apk' "ironfox/releases/${IRONFOX_VERSION}/universal" "${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-universal.apk"
    local readonly universal_file_name="$(basename "${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-universal.apk")"
    assets+=("{\"name\": \"${universal_file_name}\",\"url\": \"https://releases.ironfoxoss.org/ironfox/releases/${IRONFOX_VERSION}/universal/${universal_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${universal_file_name}\"}")
}

function upload_apkset() {
    upload_asset 'apkset' "ironfox/releases/${IRONFOX_VERSION}/bundle" "${IRONFOX_APKS_ARTIFACTS}/ironfox-${IRONFOX_VERSION}.apks"
    local readonly bundle_file_name="$(basename "${IRONFOX_APKS_ARTIFACTS}/ironfox-${IRONFOX_VERSION}.apks")"
    assets+=("{\"name\": \"${bundle_file_name}\",\"url\": \"https://releases.ironfoxoss.org/ironfox/releases/${IRONFOX_VERSION}/bundle/${bundle_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${bundle_file_name}\"}")
}

# Upload packages to package registry
upload_apk_arm64
upload_apk_arm
upload_apk_x86_64
upload_apk_universal
upload_apkset

# Because we now upload all releases to releases.ironfoxoss.org, we only want to keep the last 3 releases in ex. F-Droid
## In order to do so, we need to store/upload the current and prior 2 versions of IronFox as text files
curl ${IRONFOX_CURL_FLAGS} -sSL 'https://releases.ironfoxoss.org/ironfox/releases/latest_release.txt' -o "${CI_PROJECT_DIR}/current-latest_release.txt"
curl ${IRONFOX_CURL_FLAGS} -sSL 'https://releases.ironfoxoss.org/ironfox/releases/previous_release.txt' -o "${CI_PROJECT_DIR}/current-previous_release.txt"

echo -n "${IRONFOX_VERSION}" > "${CI_PROJECT_DIR}/latest_release.txt"
cp "${CI_PROJECT_DIR}/current-latest_release.txt" "${CI_PROJECT_DIR}/previous_release.txt"
cp "${CI_PROJECT_DIR}/current-previous_release.txt" "${CI_PROJECT_DIR}/previous_previous_release.txt"

upload_to_s3 "${CI_PROJECT_DIR}/latest_release.txt" 'ironfox/releases'
add_sha512sum "${CI_PROJECT_DIR}/latest_release.txt" 'ironfox/releases'

upload_to_s3 "${CI_PROJECT_DIR}/previous_release.txt" 'ironfox/releases'
add_sha512sum "${CI_PROJECT_DIR}/previous_release.txt" 'ironfox/releases'

upload_to_s3 "${CI_PROJECT_DIR}/previous_release.txt" 'ironfox/releases'
add_sha512sum "${CI_PROJECT_DIR}/previous_previous_release.txt" 'ironfox/releases'

{
    readonly changelog_file="${CI_PROJECT_DIR}/changelogs/${IRONFOX_VERSION}.md"
    if [[ -f "${changelog_file}" ]]; then
        cat "${changelog_file}"
    fi

    echo "# IronFox ${IRONFOX_VERSION}"
    echo '____'
    echo ''

    echo '## Changes'
    echo ''
    echo '- '
    echo ''

    echo '## App Verification'
    echo "To verify the integrity/authenticity of your IronFox installation, in addition to [the checksums](#checksums) provided below, we highly recommend using [\`AppVerifier\`](https://github.com/soupslurpr/AppVerifier):"
    echo ''
    echo "Package ID: \`org.ironfoxoss.ironfox\`"
    echo ''
    echo 'SHA256 hash of signing certificate:'
    echo "\`\`\`sh"
    echo 'C5:E2:91:B5:A5:71:F9:C8:CD:9A:97:99:C2:C9:4E:02:EC:97:03:94:88:93:F2:CA:75:6D:67:B9:42:04:F9:04'
    echo "\`\`\`"
    echo ""

    echo '## Checksums'
    echo ''
    cat ${CHECKSUMS_FILE}
    echo ''

    echo '---'
    echo "_This release was automatically generated by the CI/CD pipeline ([view pipeline](${CI_JOB_URL})) and is guaranteed to be generated from commit [${CI_COMMIT_SHORT_SHA}](${CI_PROJECT_URL}/-/tree/${CI_COMMIT_SHA})._"
    echo ''
} >>"${RELEASE_NOTES_FILE}"

{
    echo "---"
    echo "name: IronFox v${IRONFOX_VERSION}"
    echo "tag-name: v${IRONFOX_VERSION}"
    echo "description: |"
    "${IRONFOX_AWK}" '{print "  " $0}' <"${RELEASE_NOTES_FILE}"
    echo "assets-link:"
    for asset in "${assets[@]}"; do
        echo "  - '${asset}'"
    done
} >"${RELEASE_FILE}"
