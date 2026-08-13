#!/bin/bash

# This file is expected to be executed in GitLab CI
# DO NOT executed this manually!

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
  export IRONFOX_CI=1
fi
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

# Include utilities
source "${IRONFOX_UTILS}"

# Verify secrets
verify_file_with_env "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" 'IRONFOX_RELEASES_S3_ACCESS_KEY_FILE' || exit 1
verify_file_with_env "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" 'IRONFOX_RELEASES_S3_BUCKET_NAME_FILE' || exit 1
verify_file_with_env "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" 'IRONFOX_RELEASES_S3_ENDPOINT_FILE' || exit 1
verify_file_with_env "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" 'IRONFOX_RELEASES_S3_SECRET_KEY_FILE' || exit 1

# Constants

# Base releases URL
readonly IRONFOX_RELEASES_URL='https://releases.ironfoxoss.org'
readonly IRONFOX_RELEASES_BASE_URL="${IRONFOX_RELEASES_URL}/ironfox/releases/${IRONFOX_VERSION}"

# GitLab
readonly IRONFOX_GITLAB_API_URL='https://gitlab.com/api/v4'
readonly IRONFOX_GITLAB_PROJECT_ID='65779408'
readonly IRONFOX_GITLAB_GENERIC_PACKAGES_URL="${IRONFOX_GITLAB_API_URL}/projects/${IRONFOX_GITLAB_PROJECT_ID}/packages/generic"

# Final release notes file
readonly IRONFOX_RELEASE_NOTES="${IRONFOX_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-release-notes.md"

# Artifacts
readonly IRONFOX_APK_ARM64="${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-arm64-v8a.apk"
readonly IRONFOX_APK_ARM="${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-armeabi-v7a.apk"
readonly IRONFOX_APK_X86_64="${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-x86_64.apk"
readonly IRONFOX_APK_UNIVERSAL="${IRONFOX_APK_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-universal.apk"
readonly IRONFOX_APKSET="${IRONFOX_APKS_ARTIFACTS}/ironfox-${IRONFOX_VERSION}.apks"

# Ensure we have our artifacts
verify_file "${IRONFOX_APK_ARM64}" || exit 1
verify_file "${IRONFOX_APK_ARM}" || exit 1
verify_file "${IRONFOX_APK_X86_64}" || exit 1
verify_file "${IRONFOX_APK_UNIVERSAL}" || exit 1
verify_file "${IRONFOX_APKSET}" || exit 1

# Artifact SHA512sums
readonly IRONFOX_ARM64_SHA512SUM=$("${IRONFOX_SHASUM}" -a 512 "${IRONFOX_APK_ARM64}" | "${IRONFOX_AWK}" '{print $1}')
readonly IRONFOX_ARM_SHA512SUM=$("${IRONFOX_SHASUM}" -a 512 "${IRONFOX_APK_ARM}" | "${IRONFOX_AWK}" '{print $1}')
readonly IRONFOX_X86_64_SHA512SUM=$("${IRONFOX_SHASUM}" -a 512 "${IRONFOX_APK_X86_64}" | "${IRONFOX_AWK}" '{print $1}')
readonly IRONFOX_UNIVERSAL_SHA512SUM=$("${IRONFOX_SHASUM}" -a 512 "${IRONFOX_APK_UNIVERSAL}" | "${IRONFOX_AWK}" '{print $1}')
readonly IRONFOX_BUNDLE_SHA512SUM=$("${IRONFOX_SHASUM}" -a 512 "${IRONFOX_APKSET}" | "${IRONFOX_AWK}" '{print $1}')

function upload_to_package_registry() {
  local -r upload_file="$1"
  local -r upload_package_name="$2"
  local -r upload_file_name="$("${IRONFOX_BASENAME}" "${upload_file}")"
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --no-verbose --header "PRIVATE-TOKEN: ${IRONFOX_GITLAB_CI_API_TOKEN}" \
    --upload-file "${upload_file}" \
    "${IRONFOX_GITLAB_GENERIC_PACKAGES_URL}/${upload_package_name}/${IRONFOX_VERSION}/${upload_file_name}"
}

# Pushes a file to S3
function push_to_s3() {
  function print_usage() {
    echo "Usage: push_to_s3 '/path/to/file' 'path/on/s3'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a file that should be uploaded to S3 storage'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the target path on S3 storage for where the file should be uploaded'
    print_usage
    exit 1
  fi

  local -r push_file="$1"
  local -r s3_path="$2"
  local -r s3_full_path="${s3_path}/$("${IRONFOX_BASENAME}" "${push_file}")"

  # Ensure our file to push is valid
  verify_file "${push_file}" || exit 1

  # Set our MIME type
  case "${push_file}" in
    *.apk)
      local -r mime_type='application/vnd.android.package-archive'
      ;;
    *.apks)
      local -r mime_type='application/vnd.android.package-archive'
      ;;
    *.json)
      local -r mime_type='application/json'
      ;;
    *.md)
      local -r mime_type='text/markdown'
      ;;
    *.txt)
      local -r mime_type='text/plain'
      ;;
    *)
      echo_red_text "ERROR: Unsupported file type: ${push_file}"
      exit 1
      ;;
  esac

  local -r s3_access_key=$("${IRONFOX_CAT}" "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" | "${IRONFOX_XARGS}")
  local -r s3_bucket_name=$("${IRONFOX_CAT}" "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" | "${IRONFOX_XARGS}")
  local -r s3_endpoint=$("${IRONFOX_CAT}" "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" | "${IRONFOX_XARGS}")
  local -r s3_secret_key=$("${IRONFOX_CAT}" "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" | "${IRONFOX_XARGS}")

  if [[ "${s3_path}" == 'root' ]]; then
    local -r s3_target_path="s3://${s3_bucket_name}"
  else
    local -r s3_target_path="s3://${s3_bucket_name}/${s3_full_path}"
  fi

  echo_red_text "Pushing ${push_file} to S3..."
  source "${IRONFOX_PYENV}"
  "${IRONFOX_S3CMD}" ${IRONFOX_S3CMD_FLAGS} --mime-type="${mime_type}" put "${push_file}" "${s3_target_path}" \
    --access_key="${s3_access_key}" \
    --secret_key="${s3_secret_key}" \
    --host="${s3_endpoint}" \
    --host-bucket="${s3_endpoint}"
  echo_green_text "SUCCESS: Pushed ${push_file} to S3"
}

function add_sha512sum() {
  local -r sha512sum_file_in="$1"
  local -r sha512sum_file_name=$("${IRONFOX_BASENAME}" "${sha512sum_file_in}")
  local -r sha512sum_file_path=$("${IRONFOX_DIRNAME}" "${sha512sum_file_in}")

  if [[ -z "${2+x}" ]]; then
    local -r sha512sum_s3path=$("${IRONFOX_BASENAME}" "${sha512sum_file_path}" | "${IRONFOX_AWK}" '{print tolower($0)}')
  else
    local -r sha512sum_s3path="$2"
  fi

  local -r sha512sum_file_out="${sha512sum_file_path}/${sha512sum_file_name}-sha512sum.txt"

  # If there's already a SHA512sum file, remove it
  if [[ -f "${sha512sum_file_out}" ]]; then
    "${IRONFOX_RM}" -f "${sha512sum_file_out}"
  fi

  local -r local_sha512sum=$("${IRONFOX_SHASUM}" -a 512 "${sha512sum_file_in}" | "${IRONFOX_AWK}" '{print $1}')
  echo -n "${local_sha512sum}" > "${sha512sum_file_out}"

  push_to_s3 "${sha512sum_file_out}" "${sha512sum_s3path}"
}

# Extract compressed artifacts
#"${IRONFOX_MKDIR}" -p "${IRONFOX_ARTIFACTS}"
#for archive in "${IRONFOX_ARTIFACTS}"/*.tar.xz; do
#  [[ -f "${archive}" ]] || continue
#  echo "Extracting ${archive}"
#  "${IRONFOX_TAR}" xvJf "${archive}" -C "${IRONFOX_ARTIFACTS}"
#done

"${IRONFOX_MKDIR}" -vp "${IRONFOX_BUILD}"

declare -a assets
function upload_asset() {
  local -r asset_package_name="$1"
  local -r asset_s3_path="$2"
  local -r asset_file="$3"
  local -r asset_file_name="$("${IRONFOX_BASENAME}" "${asset_file}")"

  upload_to_package_registry "${asset_file}" "${asset_package_name}"
  push_to_s3 "${asset_file}" "${asset_s3_path}"
  add_sha512sum "${asset_file}" "${asset_s3_path}"
}

function upload_apk_arm64() {
  upload_asset 'apk' "ironfox/releases/${IRONFOX_VERSION}/arm64-v8a" "${IRONFOX_APK_ARM64}"
  local -r arm64_file_name="$("${IRONFOX_BASENAME}" "${IRONFOX_APK_ARM64}")"
  assets+=("{\"name\": \"${arm64_file_name}\",\"url\": \"${IRONFOX_RELEASES_BASE_URL}/arm64-v8a/${arm64_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${arm64_file_name}\"}")
}

function upload_apk_arm() {
  upload_asset 'apk' "ironfox/releases/${IRONFOX_VERSION}/armeabi-v7a" "${IRONFOX_APK_ARM}"
  local -r arm_file_name="$("${IRONFOX_BASENAME}" "${IRONFOX_APK_ARM}")"
  assets+=("{\"name\": \"${arm_file_name}\",\"url\": \"${IRONFOX_RELEASES_BASE_URL}/armeabi-v7a/${arm_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${arm_file_name}\"}")
}

function upload_apk_x86_64() {
  upload_asset 'apk' "ironfox/releases/${IRONFOX_VERSION}/x86_64" "${IRONFOX_APK_X86_64}"
  local -r x86_64_file_name="$("${IRONFOX_BASENAME}" "${IRONFOX_APK_X86_64}")"
  assets+=("{\"name\": \"${x86_64_file_name}\",\"url\": \"${IRONFOX_RELEASES_BASE_URL}/x86_64/${x86_64_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${x86_64_file_name}\"}")
}

function upload_apk_universal() {
  upload_asset 'apk' "ironfox/releases/${IRONFOX_VERSION}/universal" "${IRONFOX_APK_UNIVERSAL}"
  local -r universal_file_name="$("${IRONFOX_BASENAME}" "${IRONFOX_APK_UNIVERSAL}")"
  assets+=("{\"name\": \"${universal_file_name}\",\"url\": \"${IRONFOX_RELEASES_BASE_URL}/universal/${universal_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${universal_file_name}\"}")
}

function upload_apkset() {
  upload_asset 'apkset' "ironfox/releases/${IRONFOX_VERSION}/bundle" "${IRONFOX_APKSET}"
  local -r bundle_file_name="$("${IRONFOX_BASENAME}" "${IRONFOX_APKSET}")"
  assets+=("{\"name\": \"${bundle_file_name}\",\"url\": \"${IRONFOX_RELEASES_BASE_URL}/bundle/${bundle_file_name}\",\"link_type\": \"package\",\"direct_asset_path\": \"/${bundle_file_name}\"}")
}

# Create release notes
function create_release_notes() {
  # Ensure our changelog (for release-specific changes) exists
  local -r IRONFOX_CHANGELOG_FILE="${IRONFOX_ROOT}/CHANGELOG.md"
  verify_file "${IRONFOX_CHANGELOG_FILE}" || exit 1

  # Ensure our release template exists
  local -r IRONFOX_RELEASE_TEMPLATE="${IRONFOX_TEMPLATES}/release-notes.md"
  verify_file "${IRONFOX_RELEASE_TEMPLATE}" || exit 1

  local -r IRONFOX_RELEASE_NOTES_TEMP="${IRONFOX_TEMP}/ironfox-${IRONFOX_VERSION}-release-notes-temp.md"
  "${IRONFOX_RM}" -f "${IRONFOX_RELEASE_NOTES}" "${IRONFOX_RELEASE_NOTES_TEMP}"

  "${IRONFOX_MKDIR}" -p "${IRONFOX_ARTIFACTS}" "${IRONFOX_TEMP}"
  "${IRONFOX_CP}" -f "${IRONFOX_RELEASE_TEMPLATE}" "${IRONFOX_RELEASE_NOTES_TEMP}"

  # Set our version
  "${IRONFOX_SED}" -i "s|{IRONFOX_VERSION}|${IRONFOX_VERSION}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"

  # Set the previous (current) version
  local -r IRONFOX_PREVIOUS_VERSION=$("${IRONFOX_CAT}" "${IRONFOX_ROOT}/previous_release.txt" | "${IRONFOX_XARGS}")
  "${IRONFOX_SED}" -i "s|{IRONFOX_PREVIOUS_VERSION}|${IRONFOX_PREVIOUS_VERSION}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"

  # Set our SHA512sums
  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM64_SHA512SUM}|${IRONFOX_ARM64_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM_SHA512SUM}|${IRONFOX_ARM_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_X86_64_SHA512SUM}|${IRONFOX_X86_64_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_UNIVERSAL_SHA512SUM}|${IRONFOX_UNIVERSAL_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_BUNDLE_SHA512SUM}|${IRONFOX_BUNDLE_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"

  # Set CI commit + job ID
  "${IRONFOX_SED}" -i "s|{CI_COMMIT_SHA}|${CI_COMMIT_SHA}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{CI_COMMIT_SHORT_SHA}|${CI_COMMIT_SHORT_SHA}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{CI_JOB_ID}|${CI_JOB_ID}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"

  # Add release-specific changes
  local -r IRONFOX_CHANGELOG=$("${IRONFOX_CAT}" "${IRONFOX_CHANGELOG_FILE}")
  {
    echo "# IronFox ${IRONFOX_VERSION}"
    echo '____'
    echo ''
    echo '## Changes'
    echo ''
    "${IRONFOX_CAT}" "${IRONFOX_ROOT}/CHANGELOG.md"
    echo ''
    "${IRONFOX_CAT}" "${IRONFOX_RELEASE_NOTES_TEMP}"
  } >> "${IRONFOX_RELEASE_NOTES}"

  "${IRONFOX_RM}" -f "${IRONFOX_RELEASE_NOTES_TEMP}"

  echo_green_text "SUCCESS: Created release notes for IronFox: ${IRONFOX_VERSION}"
}

# Create our universal updates.json
## (ex. used by Obtainium)
function create_universal_json() {
  "${IRONFOX_CP}" -f "${IRONFOX_TEMPLATES}/updates.json" "${IRONFOX_ROOT}/updates.json"

  "${IRONFOX_SED}" -i "s|{IRONFOX_VERSION}|${IRONFOX_VERSION}|" "${IRONFOX_ROOT}/updates.json"
  "${IRONFOX_SED}" -i "s|ironfox-{IRONFOX_VERSION}|ironfox-${IRONFOX_VERSION}|" "${IRONFOX_ROOT}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM64_SHA512SUM}|${IRONFOX_ARM64_SHA512SUM}|" "${IRONFOX_ROOT}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM_SHA512SUM}|${IRONFOX_ARM_SHA512SUM}|" "${IRONFOX_ROOT}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_X86_64_SHA512SUM}|${IRONFOX_X86_64_SHA512SUM}|" "${IRONFOX_ROOT}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_UNIVERSAL_SHA512SUM}|${IRONFOX_UNIVERSAL_SHA512SUM}|" "${IRONFOX_ROOT}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_BUNDLE_SHA512SUM}|${IRONFOX_BUNDLE_SHA512SUM}|" "${IRONFOX_ROOT}/updates.json"

  push_to_s3 "${IRONFOX_ROOT}/updates.json" 'ironfox/releases'
  add_sha512sum "${IRONFOX_ROOT}/updates.json" 'ironfox/releases'
}

# Upload packages to package registry
upload_apk_arm64
upload_apk_arm
upload_apk_x86_64
upload_apk_universal
upload_apkset

# Update our universal updates.json file
## (ex. used by Obtainium)
create_universal_json

# Because we now upload all releases to releases.ironfoxoss.org, we only want to keep the last 3 releases in ex. F-Droid
## In order to do so, we need to store/upload the current and prior 2 versions of IronFox as text files
"${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${IRONFOX_RELEASES_URL}/ironfox/releases/latest_release.txt" --output "${IRONFOX_ROOT}/current-latest_release.txt"
"${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${IRONFOX_RELEASES_URL}/ironfox/releases/previous_release.txt" --output "${IRONFOX_ROOT}/current-previous_release.txt"

echo -n "${IRONFOX_VERSION}" > "${IRONFOX_ROOT}/latest_release.txt"
"${IRONFOX_CP}" "${IRONFOX_ROOT}/current-latest_release.txt" "${IRONFOX_ROOT}/previous_release.txt"
"${IRONFOX_CP}" "${IRONFOX_ROOT}/current-previous_release.txt" "${IRONFOX_ROOT}/previous_previous_release.txt"

push_to_s3 "${IRONFOX_ROOT}/latest_release.txt" 'ironfox/releases'
add_sha512sum "${IRONFOX_ROOT}/latest_release.txt" 'ironfox/releases'

push_to_s3 "${IRONFOX_ROOT}/previous_release.txt" 'ironfox/releases'
add_sha512sum "${IRONFOX_ROOT}/previous_release.txt" 'ironfox/releases'

push_to_s3 "${IRONFOX_ROOT}/previous_release.txt" 'ironfox/releases'
add_sha512sum "${IRONFOX_ROOT}/previous_previous_release.txt" 'ironfox/releases'

# Create release notes
## (NOTE: This needs to run after we have previous_release.txt above, so that we can properly set the previous version)
create_release_notes

# Push release notes
push_to_s3 "${IRONFOX_RELEASE_NOTES}" "ironfox/releases/${IRONFOX_VERSION}"
add_sha512sum "${IRONFOX_RELEASE_NOTES}" "ironfox/releases/${IRONFOX_VERSION}"

# Add assets to GitLab release
{
  echo "---"
  echo "name: IronFox ${IRONFOX_VERSION}"
  echo "tag-name: v${IRONFOX_VERSION}"
  echo "description: |"
  "${IRONFOX_AWK}" '{print "  " $0}' < "${IRONFOX_RELEASE_NOTES}"
  echo "assets-link:"
  for asset in "${assets[@]}"; do
    echo "  - '${asset}'"
  done
} > "${IRONFOX_BUILD}/release.yml"
