#!/bin/bash

# This file is expected to be executed in GitLab CI
# DO NOT executed this manually!

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x || exit 1

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash "$(realpath $(dirname "$0"))/env.sh" || exit 1
fi
source "$(realpath $(dirname "$0"))/env.sh" || exit 1

# Include utilities
source "${IRONFOX_UTILS}" || exit 1

# Include download utilities
source "${IRONFOX_DOWNLOAD_UTILS}" || exit 1

# Include S3 utilities
source "${IRONFOX_S3_UTILS}" || exit 1

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  exit 1
fi

# Ensure we have GNU awk
verify_exec "${IRONFOX_AWK}" 'IRONFOX_AWK' || exit 1

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  readonly target='release'
else
  readonly target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')
fi

IRONFOX_PUBLISH_NIGHTLY=0
IRONFOX_PUBLISH_RELEASE=0
if [[ "${target}" == 'nightly' ]]; then
  # Publish IronFox Nightly
  IRONFOX_PUBLISH_NIGHTLY=1
elif [[ "${target}" == 'release' ]]; then
  # Publish IronFox Release
  IRONFOX_PUBLISH_RELEASE=1
else
  echo_red_text "ERROR: Invalid target: ${target}\n You must enter one of the following:"
  echo 'Release: release (Default)'
  echo 'Nightly: nightly'
  exit 1
fi
readonly IRONFOX_PUBLISH_NIGHTLY
readonly IRONFOX_PUBLISH_RELEASE

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
readonly IRONFOX_GITLAB_BRANCH='main'
readonly IRONFOX_GITLAB_PROJECT_ID='65779408'
readonly IRONFOX_GITLAB_GENERIC_PACKAGES_URL="${IRONFOX_GITLAB_API_URL}/projects/${IRONFOX_GITLAB_PROJECT_ID}/packages/generic"

# Final release notes file
readonly IRONFOX_RELEASE_NOTES="${IRONFOX_ARTIFACTS}/ironfox-${IRONFOX_VERSION}-release-notes.md"

# Ensure we have the Nightly version
if [[ "${IRONFOX_PUBLISH_NIGHTLY}" == 1 ]]; then
  if [[ "${IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE}" == "null" ]] || [[ "${IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE}" == "" ]]; then
    echo_red_text "ERROR: Missing IronFox Nightly timestamp! Please set 'IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE'."
    exit 1
  else
    readonly IRONFOX_NIGHTLY_VERSION="${IRONFOX_VERSION}.${IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE}"
  fi
fi

# Artifacts
if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
  readonly IRONFOX_APK_NAME='ironfox'
  readonly IRONFOX_APK_VERSION="${IRONFOX_VERSION}"
else
  readonly IRONFOX_APK_NAME="ironfox-${IRONFOX_CHANNEL}"
  readonly IRONFOX_APK_VERSION="${IRONFOX_NIGHTLY_VERSION}"
fi
readonly IRONFOX_APK_ARM64="${IRONFOX_APK_ARTIFACTS}/${IRONFOX_APK_NAME}-${IRONFOX_APK_VERSION}-arm64-v8a.apk"
readonly IRONFOX_APK_ARM="${IRONFOX_APK_ARTIFACTS}/${IRONFOX_APK_NAME}-${IRONFOX_APK_VERSION}-armeabi-v7a.apk"
readonly IRONFOX_APK_X86_64="${IRONFOX_APK_ARTIFACTS}/${IRONFOX_APK_NAME}-${IRONFOX_APK_VERSION}-x86_64.apk"
readonly IRONFOX_APK_UNIVERSAL="${IRONFOX_APK_ARTIFACTS}/${IRONFOX_APK_NAME}-${IRONFOX_APK_VERSION}-universal.apk"
readonly IRONFOX_APKSET="${IRONFOX_APKS_ARTIFACTS}/${IRONFOX_APK_NAME}-${IRONFOX_APK_VERSION}.apks"

# Set our external CI environment variables

## Commit SHA
if [[ -z "${CI_COMMIT_SHA+x}" ]]; then
  echo_red_text "ERROR: Missing commit SHA! Please set 'CI_COMMIT_SHA'."
  exit 1
else
  readonly IRONFOX_CI_COMMIT="${CI_COMMIT_SHA}"
fi

## Short commit SHA
if [[ -z "${CI_COMMIT_SHORT_SHA+x}" ]]; then
  echo_red_text "ERROR: Missing short commit SHA! Please set 'CI_COMMIT_SHORT_SHA'."
  exit 1
else
  readonly IRONFOX_CI_COMMIT_SHORT="${CI_COMMIT_SHORT_SHA}"
fi

## Job ID
if [[ -z "${CI_JOB_ID+x}" ]]; then
  echo_red_text "ERROR: Missing job ID! Please set 'CI_JOB_ID'."
  exit 1
else
  readonly IRONFOX_CI_JOB_ID="${CI_JOB_ID}"
fi

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

# Push a file with a SHA512sum to S3 storage
function push_to_s3() {
  function print_usage() {
    echo "Usage: push_to_s3 '/path/to/file' 'path/on/s3'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a file that should be uploaded to S3 storage!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the target path on S3 storage for where the file should be uploaded!'
    print_usage
    exit 1
  fi

  local -r push_file="$1"
  local -r s3_path="$2"

  local -r s3_access_key_file="${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}"
  local -r s3_bucket_name_file="${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}"
  local -r s3_endpoint_file="${IRONFOX_RELEASES_S3_ENDPOINT_FILE}"
  local -r s3_secret_key_file="${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}"

  # Ensure our file to push is valid
  verify_file "${push_file}" || exit 1

  # Create and push a SHA512sum for our file to S3 storage
  push_and_add_sha512sum "${push_file}" "${s3_path}" "${s3_access_key_file}" "${s3_bucket_name_file}" "${s3_endpoint_file}" "${s3_secret_key_file}"
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
  download "${IRONFOX_RELEASES_URL}/ironfox/releases/latest_release.txt" "${IRONFOX_TEMP}/previous_release.txt"
  local -r IRONFOX_PREVIOUS_VERSION=$("${IRONFOX_CAT}" "${IRONFOX_TEMP}/previous_release.txt" | "${IRONFOX_XARGS}")
  "${IRONFOX_SED}" -i "s|{IRONFOX_PREVIOUS_VERSION}|${IRONFOX_PREVIOUS_VERSION}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"

  # Set our SHA512sums
  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM64_SHA512SUM}|${IRONFOX_ARM64_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM_SHA512SUM}|${IRONFOX_ARM_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_X86_64_SHA512SUM}|${IRONFOX_X86_64_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_UNIVERSAL_SHA512SUM}|${IRONFOX_UNIVERSAL_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_BUNDLE_SHA512SUM}|${IRONFOX_BUNDLE_SHA512SUM}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"

  # Set CI commit + job ID
  "${IRONFOX_SED}" -i "s|{IRONFOX_CI_COMMIT}|${IRONFOX_CI_COMMIT}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_CI_COMMIT_SHORT}|${IRONFOX_CI_COMMIT_SHORT}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"
  "${IRONFOX_SED}" -i "s|{IRONFOX_CI_JOB_ID}|${IRONFOX_CI_JOB_ID}|g" "${IRONFOX_RELEASE_NOTES_TEMP}"

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

# Upload a release to GitLab's package registry
function upload_to_gitlab_package_registry() {
  function print_usage() {
    echo "Usage: upload_to_gitlab_package_registry '/path/to/release' 'package-name'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a file that should be uploaded to the GitLab package registry!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the desired package name!'
    print_usage
    exit 1
  fi

  # Ensure we have an API token...
  if [[ -z "${IRONFOX_GITLAB_CI_API_TOKEN+x}" ]]; then
    echo_red_text 'ERROR: Missing GitLab CI API Token! Please set IRONFOX_GITLAB_CI_API_TOKEN.'
    exit 1
  fi

  local -r upload_file="$1"
  local -r upload_package_name="$2"
  local -r upload_file_name="$("${IRONFOX_BASENAME}" "${upload_file}")"

  # Ensure our file to upload is valid
  verify_file "${upload_file}" || exit 1

  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --no-verbose --header "PRIVATE-TOKEN: ${IRONFOX_GITLAB_CI_API_TOKEN}" \
    --upload-file "${upload_file}" \
    "${IRONFOX_GITLAB_GENERIC_PACKAGES_URL}/${upload_package_name}/${IRONFOX_VERSION}/${upload_file_name}"
}

# Publish a release to GitLab
function publish_to_gitlab() {
  if [[ ! -f "${IRONFOX_RELEASE_NOTES}" ]]; then
    echo_red_text "ERROR: Missing release notes! (${IRONFOX_RELEASE_NOTES})"
    exit 1
  fi

  # Ensure we have an API token...
  if [[ -z "${IRONFOX_GITLAB_CI_API_TOKEN+x}" ]]; then
    echo_red_text 'ERROR: Missing GitLab CI API Token! Please set IRONFOX_GITLAB_CI_API_TOKEN.'
    exit 1
  fi

  local -r ironfox_release_desc=$("${IRONFOX_CAT}" "${IRONFOX_RELEASE_NOTES}")

  # Attach our assets

  # ironfox-{IRONFOX_VERSION}-arm64-v8a.apk
  local -r IRONFOX_ARM64_APK_NAME="ironfox-${IRONFOX_VERSION}-arm64-v8a.apk"
  local -r IRONFOX_ARM64_APK_URL="${IRONFOX_RELEASES_BASE_URL}/arm64-v8a/${IRONFOX_ARM64_APK_NAME}"
  local -r IRONFOX_ARM64_APK_SHA512SUM_NAME="${IRONFOX_ARM64_APK_NAME}-sha512sum.txt"
  local -r IRONFOX_ARM64_APK_SHA512SUM_URL="${IRONFOX_ARM64_APK_URL}-sha512sum.txt"
  upload_to_gitlab_package_registry "${IRONFOX_APK_ARTIFACTS}/${IRONFOX_ARM64_APK_NAME}" 'apk'
  upload_to_gitlab_package_registry "${IRONFOX_APK_ARTIFACTS}/${IRONFOX_ARM64_APK_SHA512SUM_NAME}" 'apk'

  # ironfox-{IRONFOX_VERSION}-armeabi-v7a.apk
  local -r IRONFOX_ARM_APK_NAME="ironfox-${IRONFOX_VERSION}-armeabi-v7a.apk"
  local -r IRONFOX_ARM_APK_URL="${IRONFOX_RELEASES_BASE_URL}/armeabi-v7a/${IRONFOX_ARM_APK_NAME}"
  local -r IRONFOX_ARM_APK_SHA512SUM_NAME="${IRONFOX_ARM_APK_NAME}-sha512sum.txt"
  local -r IRONFOX_ARM_APK_SHA512SUM_URL="${IRONFOX_ARM_APK_URL}-sha512sum.txt"
  upload_to_gitlab_package_registry "${IRONFOX_APK_ARTIFACTS}/${IRONFOX_ARM_APK_NAME}" 'apk'
  upload_to_gitlab_package_registry "${IRONFOX_APK_ARTIFACTS}/${IRONFOX_ARM_APK_SHA512SUM_NAME}" 'apk'

  # ironfox-{IRONFOX_VERSION}-x86_64.apk
  local -r IRONFOX_X86_64_APK_NAME="ironfox-${IRONFOX_VERSION}-x86_64.apk"
  local -r IRONFOX_X86_64_APK_URL="${IRONFOX_RELEASES_BASE_URL}/x86_64/${IRONFOX_X86_64_APK_NAME}"
  local -r IRONFOX_X86_64_APK_SHA512SUM_NAME="${IRONFOX_X86_64_APK_NAME}-sha512sum.txt"
  local -r IRONFOX_X86_64_APK_SHA512SUM_URL="${IRONFOX_X86_64_APK_URL}-sha512sum.txt"
  upload_to_gitlab_package_registry "${IRONFOX_APK_ARTIFACTS}/${IRONFOX_X86_64_APK_NAME}" 'apk'
  upload_to_gitlab_package_registry "${IRONFOX_APK_ARTIFACTS}/${IRONFOX_X86_64_APK_SHA512SUM_NAME}" 'apk'

  # ironfox-{IRONFOX_VERSION}-universal.apk
  local -r IRONFOX_UNIVERSAL_APK_NAME="ironfox-${IRONFOX_VERSION}-universal.apk"
  local -r IRONFOX_UNIVERSAL_APK_URL="${IRONFOX_RELEASES_BASE_URL}/universal/${IRONFOX_UNIVERSAL_APK_NAME}"
  local -r IRONFOX_UNIVERSAL_APK_SHA512SUM_NAME="${IRONFOX_UNIVERSAL_APK_NAME}-sha512sum.txt"
  local -r IRONFOX_UNIVERSAL_APK_SHA512SUM_URL="${IRONFOX_UNIVERSAL_APK_URL}-sha512sum.txt"
  upload_to_gitlab_package_registry "${IRONFOX_APK_ARTIFACTS}/${IRONFOX_UNIVERSAL_APK_NAME}" 'apk'
  upload_to_gitlab_package_registry "${IRONFOX_APK_ARTIFACTS}/${IRONFOX_UNIVERSAL_APK_SHA512SUM_NAME}" 'apk'

  # ironfox-{IRONFOX_VERSION}.apks
  local -r IRONFOX_APKSET_NAME="ironfox-${IRONFOX_VERSION}.apks"
  local -r IRONFOX_APKSET_URL="${IRONFOX_RELEASES_BASE_URL}/bundle/${IRONFOX_APKSET_NAME}"
  local -r IRONFOX_APKSET_SHA512SUM_NAME="${IRONFOX_APKSET_NAME}-sha512sum.txt"
  local -r IRONFOX_APKSET_SHA512SUM_URL="${IRONFOX_APKSET_URL}-sha512sum.txt"
  upload_to_gitlab_package_registry "${IRONFOX_APKS_ARTIFACTS}/${IRONFOX_APKSET_NAME}" 'apkset'
  upload_to_gitlab_package_registry "${IRONFOX_APKS_ARTIFACTS}/${IRONFOX_APKSET_SHA512SUM_NAME}" 'apkset'

  local -r ironfox_gitlab_release_data="$(
    "${IRONFOX_JQ}" -Rs --arg name "v${IRONFOX_VERSION}" --arg ref "${IRONFOX_GITLAB_BRANCH}" --arg tag "v${IRONFOX_VERSION}" --arg version "${IRONFOX_VERSION}" \
      --arg arm64_apk_name "${IRONFOX_ARM64_APK_NAME}" \
      --arg arm64_apk_url "${IRONFOX_ARM64_APK_URL}" \
      --arg arm64_apk_sha512sum_name "${IRONFOX_ARM64_APK_SHA512SUM_NAME}" \
      --arg arm64_apk_sha512sum_url "${IRONFOX_ARM64_APK_SHA512SUM_URL}" \
      --arg arm_apk_name "${IRONFOX_ARM_APK_NAME}" \
      --arg arm_apk_url "${IRONFOX_ARM_APK_URL}" \
      --arg arm_apk_sha512sum_name "${IRONFOX_ARM_APK_SHA512SUM_NAME}" \
      --arg arm_apk_sha512sum_url "${IRONFOX_ARM_APK_SHA512SUM_URL}" \
      --arg x86_64_apk_name "${IRONFOX_X86_64_APK_NAME}" \
      --arg x86_64_apk_url "${IRONFOX_X86_64_APK_URL}" \
      --arg x86_64_apk_sha512sum_name "${IRONFOX_X86_64_APK_SHA512SUM_NAME}" \
      --arg x86_64_apk_sha512sum_url "${IRONFOX_X86_64_APK_SHA512SUM_URL}" \
      --arg universal_apk_name "${IRONFOX_UNIVERSAL_APK_NAME}" \
      --arg universal_apk_url "${IRONFOX_UNIVERSAL_APK_URL}" \
      --arg universal_apk_sha512sum_name "${IRONFOX_UNIVERSAL_APK_SHA512SUM_NAME}" \
      --arg universal_apk_sha512sum_url "${IRONFOX_UNIVERSAL_APK_SHA512SUM_URL}" \
      --arg apkset_name "${IRONFOX_APKSET_NAME}" \
      --arg apkset_url "${IRONFOX_APKSET_URL}" \
      --arg apkset_sha512sum_name "${IRONFOX_APKSET_SHA512SUM_NAME}" \
      --arg apkset_sha512sum_url "${IRONFOX_APKSET_SHA512SUM_URL}" \
      '{
      name: $name,
      ref: $ref,
      tag_name: $tag,
      assets: {
        links: [
          {
            name: $arm64_apk_name,
            url: $arm64_apk_url,
            link_type: "package"
          },
          {
            name: $arm64_apk_sha512sum_name,
            url: $arm64_apk_sha512sum_url,
            link_type: "package"
          },
          {
            name: $arm_apk_name,
            url: $arm_apk_url,
            link_type: "package"
          },
          {
            name: $arm_apk_sha512sum_name,
            url: $arm_apk_sha512sum_url,
            link_type: "package"
          },
          {
            name: $x86_64_apk_name,
            url: $x86_64_apk_url,
            link_type: "package"
          },
          {
            name: $x86_64_apk_sha512sum_name,
            url: $x86_64_apk_sha512sum_url,
            link_type: "package"
          },
          {
            name: $universal_apk_name,
            url: $universal_apk_url,
            link_type: "package"
          },
          {
            name: $universal_apk_sha512sum_name,
            url: $universal_apk_sha512sum_url,
            link_type: "package"
          },
          {
            name: $apkset_name,
            url: $apkset_url,
            link_type: "package"
          },
          {
            name: $apkset_sha512sum_name,
            url: $apkset_sha512sum_url,
            link_type: "package"
          }
        ]
      },
      description: .
      }' <<< "${ironfox_release_desc}"
  )"

  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --no-verbose --header 'Content-Type: application/json' \
    --header "PRIVATE-TOKEN: ${IRONFOX_GITLAB_CI_API_TOKEN}" \
    --data "${ironfox_gitlab_release_data}" \
    --request POST \
    "${IRONFOX_GITLAB_API_URL}/projects/${IRONFOX_GITLAB_PROJECT_ID}/releases"

  # We're done! :)
  echo_green_text "SUCCESS: Published IronFox: ${IRONFOX_VERSION} to GitLab"
}

# Create the universal updates.json for IronFox - Release
## (ex. used by Obtainium)
function create_release_json() {
  local -r s3_path='ironfox/releases'

  "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}"
  "${IRONFOX_CP}" -f "${IRONFOX_TEMPLATES}/updates.json" "${IRONFOX_TEMP}/updates.json"

  "${IRONFOX_SED}" -i "s|{IRONFOX_VERSION}|${IRONFOX_VERSION}|g" "${IRONFOX_TEMP}/updates.json"

  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM64_SHA512SUM}|${IRONFOX_ARM64_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM_SHA512SUM}|${IRONFOX_ARM_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_X86_64_SHA512SUM}|${IRONFOX_X86_64_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_UNIVERSAL_SHA512SUM}|${IRONFOX_UNIVERSAL_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_BUNDLE_SHA512SUM}|${IRONFOX_BUNDLE_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"

  push_to_s3 "${IRONFOX_TEMP}/updates.json" "${s3_path}"
}

# Create the universal updates.json for IronFox - Nightly
## (ex. used by Obtainium)
function create_nightly_json() {
  local -r s3_path='ironfox/nightly'

  "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}"
  "${IRONFOX_CP}" -f "${IRONFOX_TEMPLATES}/updates-nightly.json" "${IRONFOX_TEMP}/updates.json"

  "${IRONFOX_SED}" -i "s|{IRONFOX_NIGHTLY_VERSION}|${IRONFOX_NIGHTLY_VERSION}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_CI_COMMIT}|${IRONFOX_CI_COMMIT}|g" "${IRONFOX_TEMP}/updates.json"

  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM64_SHA512SUM}|${IRONFOX_ARM64_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_ARM_SHA512SUM}|${IRONFOX_ARM_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_X86_64_SHA512SUM}|${IRONFOX_X86_64_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_UNIVERSAL_SHA512SUM}|${IRONFOX_UNIVERSAL_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_SED}" -i "s|{IRONFOX_BUNDLE_SHA512SUM}|${IRONFOX_BUNDLE_SHA512SUM}|g" "${IRONFOX_TEMP}/updates.json"

  push_to_s3 "${IRONFOX_TEMP}/updates.json" "${s3_path}"
}

# Create our universal updates.json
## (ex. used by Obtainium)
function create_universal_json() {
  # Clean-up
  "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/updates-temp.json"
  "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/updates-temp.json-sha512sum.txt"

  local -r json_file_name='updates.json'
  if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
    local -r json_url="${IRONFOX_RELEASES_URL}/ironfox/nightly/${json_file_name}"
  else
    local -r json_url="${IRONFOX_RELEASES_URL}/ironfox/releases/${json_file_name}"
  fi
  local -r json_expected_sha512sum="${json_file_name}-sha512sum.txt"
  local -r json_expected_sha512sum_url="${json_url}-sha512sum.txt"

  # Download the current updates.json for the opposite channel (so that we can combine the files)
  download "${json_url}" "${IRONFOX_TEMP}/updates-temp.json"

  # Check the SHA512sum
  echo_red_text "Validating SHA512sum for file: '${json_file_name}'.."
  download "${json_expected_sha512sum_url}" "${IRONFOX_TEMP}/updates-temp.json-sha512sum.txt"
  local -r expected_sha512sum=$("${IRONFOX_CAT}" "${IRONFOX_TEMP}/updates-temp.json-sha512sum.txt" | "${IRONFOX_XARGS}")
  local -r local_sha512sum=$("${IRONFOX_SHASUM}" -a 512 "${IRONFOX_TEMP}/updates-temp.json" | "${IRONFOX_AWK}" '{print $1}')
  if [[ "${local_sha512sum}" != "${expected_sha512sum}" ]]; then
    echo_red_text "ERROR: Checksum validation for file failed: '${json_file_name}'!"
    echo "Expected SHA512sum: '${expected_sha512sum}'"
    echo "Actual SHA512sum:   '${local_sha512sum}'"

    # If checksum validation fails, also just clean-up the files
    "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/updates-temp.json"
    "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/updates-temp.json-sha512sum.txt"
    exit 1
  fi
  echo_green_text "SUCCESS: Validated checksum for file: '${json_file_name}'!"
  echo "SHA512sum: '${local_sha512sum}'"

  # Combine the files...
  if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
    "${IRONFOX_JQ}" -s '.[0] * .[1]' "${IRONFOX_TEMP}/updates.json" "${IRONFOX_TEMP}/updates-temp.json" > "${IRONFOX_TEMP}/updates-combined.json"
  else
    "${IRONFOX_JQ}" -s '.[0] * .[1]' "${IRONFOX_TEMP}/updates-temp.json" "${IRONFOX_TEMP}/updates.json" > "${IRONFOX_TEMP}/updates-combined.json"
  fi
  "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_CP}" -f "${IRONFOX_TEMP}/updates-combined.json" "${IRONFOX_TEMP}/updates.json"
  "${IRONFOX_RM}" -f "${IRONFOX_TEMP}/updates-combined.json"

  push_to_s3 "${IRONFOX_TEMP}/updates.json" 'ironfox'
}

# Push IronFox for a desired architecture to S3 storage
function _push_ironfox() {
  function print_usage() {
    echo "Usage: _push_ironfox 'architecture'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the architecture you wou would like to push IronFox for'
    print_usage
    exit 1
  fi

  local -r ironfox_arch="$1"

  if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
    local -r if_version="${IRONFOX_VERSION}"
    local -r s3_path='releases'
  else
    local -r if_version="${IRONFOX_NIGHTLY_VERSION}"
    local -r s3_path='nightly'
  fi

  # Set our build
  if [[ "${ironfox_arch}" == 'bundle' ]]; then
    local -r ironfox_file="${IRONFOX_APKS_ARTIFACTS}/${IRONFOX_APK_NAME}-${if_version}.apks"
    local -r ironfox_file_latest="${IRONFOX_APKS_ARTIFACTS}/${IRONFOX_APK_NAME}-latest.apks"
  else
    local -r ironfox_file="${IRONFOX_APK_ARTIFACTS}/${IRONFOX_APK_NAME}-${if_version}-${ironfox_arch}.apk"
    local -r ironfox_file_latest="${IRONFOX_APK_ARTIFACTS}/${IRONFOX_APK_NAME}-latest-${ironfox_arch}.apk"
  fi

  push_to_s3 "${ironfox_file}" "ironfox/${s3_path}/${if_version}/${ironfox_arch}"

  # Ensure the latest version can always be downloaded from https://releases.ironfoxoss.org/ironfox/releases/latest/{ironfox_arch}/ironfox-latest-{ironfox_arch}.apk (or ironfox-latest.apks for bundles)
  "${IRONFOX_CP}" -f "${ironfox_file}" "${ironfox_file_latest}"
  push_to_s3 "${ironfox_file_latest}" "ironfox/${s3_path}/latest/${ironfox_arch}"
}

# Push IronFox to S3 storage
function push_ironfox() {
  # ARM64
  _push_ironfox 'arm64-v8a'

  # ARM
  _push_ironfox 'armeabi-v7a'

  # x86_64
  _push_ironfox 'x86_64'

  # Universal
  _push_ironfox 'universal'

  # Bundle
  _push_ironfox 'bundle'

  # Get the 2 previous IronFox versions
  if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
    local -r if_version="${IRONFOX_VERSION}"
    local -r s3_channel='releases'
  else
    local -r if_version="${IRONFOX_NIGHTLY_VERSION}"
    local -r s3_channel='nightly'
  fi

  if [[ ! -f "${IRONFOX_TEMP}/previous_release.txt" ]]; then
    # (`previous_release.txt` should already be downloaded from `create_release_notes`, but if it is missing for some reason, download it)
    download "${IRONFOX_RELEASES_URL}/ironfox/${s3_channel}/latest_release.txt" "${IRONFOX_TEMP}/previous_release.txt"
  fi
  download "${IRONFOX_RELEASES_URL}/ironfox/${s3_channel}/previous_release.txt" "${IRONFOX_TEMP}/previous_previous_release.txt"

  # Update the current IronFox version
  "${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}"
  "${IRONFOX_TOUCH}" "${IRONFOX_TEMP}/latest_release.txt"
  echo -n "${if_version}" > "${IRONFOX_TEMP}/latest_release.txt"
  push_to_s3 "${IRONFOX_TEMP}/latest_release.txt" "ironfox/${s3_channel}"

  # Update the 2 previous versions
  push_to_s3 "${IRONFOX_TEMP}/previous_release.txt" "ironfox/${s3_channel}"
  push_to_s3 "${IRONFOX_TEMP}/previous_previous_release.txt" "ironfox/${s3_channel}"

  # Add release notes
  if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
    push_to_s3 "${IRONFOX_RELEASE_NOTES}" "ironfox/${s3_channel}/${IRONFOX_VERSION}"
  fi

  echo_green_text "SUCCESS: Pushed IronFox: ${IRONFOX_VERSION} to ${IRONFOX_RELEASES_URL}"
}

# First, create our release notes
if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
  create_release_notes
fi

# Push IronFox to S3
push_ironfox

# Create a GitLab release
if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
  publish_to_gitlab
fi

# Update our release-specific updates.json file
if [[ "${IRONFOX_PUBLISH_RELEASE}" == 1 ]]; then
  create_release_json
else
  create_nightly_json
fi

# Update our universal updates.json file
## (ex. used by Obtainium)
create_universal_json
