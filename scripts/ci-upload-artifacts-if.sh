#!/bin/bash

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
  export IRONFOX_CI=1
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [[ -z "${IRONFOX_FROM_AR_UP+x}" ]]; then
  echo_red_text 'ERROR: Do not call ci-upload-artifacts-if.sh directly. Instead, use ci-upload-artifacts.sh.' >&1
  exit 1
fi

# Verify secrets
verify_file_with_env "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}" 'IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE' || exit 1
verify_file_with_env "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}" 'IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE' || exit 1
verify_file_with_env "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}" 'IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE' || exit 1
verify_file_with_env "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}" 'IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE' || exit 1

readonly up_artifact="$1"

# Set-up target parameters
IRONFOX_AR_UP_FENIX=0
IRONFOX_AR_UP_GECKOVIEW=0

if [[ "${up_artifact}" == 'fenix' ]]; then
  # Push Fenix
  IRONFOX_AR_UP_FENIX=1
elif [[ "${up_artifact}" == 'geckoview' ]]; then
  # Push GeckoView
  IRONFOX_AR_UP_GECKOVIEW=1
else
  echo_red_text "ERROR: Invalid artifact: ${up_artifact}\n You must enter one of the following:"
  echo 'Fenix:      fenix'
  echo 'GeckoView:  geckoview'
  exit 1
fi
readonly IRONFOX_AR_UP_FENIX
readonly IRONFOX_AR_UP_GECKOVIEW

readonly up_arch="$2"

if [[ "${up_arch}" != 'arm64' ]] && [[ "${up_arch}" != 'arm' ]] && [[ "${up_arch}" != 'x86_64' ]] && [[ "${up_arch}" != 'bundle' ]]; then
  echo_red_text "ERROR: Invalid target architecture: ${up_arch}\n You must enter one of the following:"
  echo 'ARM64:      arm64'
  echo 'ARM:        arm'
  echo 'x86_64:     x86_64'
  echo 'Bundle:     bundle'
  exit 1
fi
readonly IRONFOX_AR_UP_ARCH="${up_arch}"

# Pushes a file to S3
function push_file() {
  function print_usage() {
    echo "Usage: push_file '/path/to/file' 'path/on/s3'"
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
    *.log)
      local -r mime_type='text/plain'
      ;;
    *.txt)
      local -r mime_type='text/plain'
      ;;
    *.zip)
      local -r mime_type='application/zip'
      ;;
    *)
      echo_red_text "ERROR: Unsupported file type: ${push_file}"
      exit 1
      ;;
  esac

  local -r s3_access_key=$("${IRONFOX_CAT}" "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}" | "${IRONFOX_XARGS}")
  local -r s3_bucket_name=$("${IRONFOX_CAT}" "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}" | "${IRONFOX_XARGS}")
  local -r s3_endpoint=$("${IRONFOX_CAT}" "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}" | "${IRONFOX_XARGS}")
  local -r s3_secret_key=$("${IRONFOX_CAT}" "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}" | "${IRONFOX_XARGS}")

  if [[ "${s3_path}" == 'root' ]]; then
    local -r s3_target_path="s3://${s3_bucket_name}/ironfox"
  else
    local -r s3_target_path="s3://${s3_bucket_name}/ironfox/${s3_full_path}"
  fi

  echo_red_text "Uploading ${push_file} to S3..."
  source "${IRONFOX_PYENV}"
  "${IRONFOX_S3CMD}" ${IRONFOX_S3CMD_FLAGS} --mime-type="${mime_type}" put "${push_file}" "${s3_target_path}" \
    --access_key="${s3_access_key}" \
    --secret_key="${s3_secret_key}" \
    --host="${s3_endpoint}" \
    --host-bucket="${s3_endpoint}"
  echo_green_text "SUCCESS: Uploaded ${push_file} to S3"
}

# Creates and pushes a SHA512sum for a file to S3
function add_sha512sum() {
  function print_usage() {
    echo "Usage: add_sha512sum '/path/to/file'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a file that a SHA512sum should be created for'
    print_usage
    exit 1
  fi

  local -r sha512sum_file_in="$1"
  local -r sha512sum_file_name=$("${IRONFOX_BASENAME}" "${sha512sum_file_in}")
  local -r sha512sum_file_path=$("${IRONFOX_DIRNAME}" "${sha512sum_file_in}")

  if [[ -z "${2+x}" ]]; then
    local -r sha512sum_s3path=$("${IRONFOX_BASENAME}" "${sha512sum_file_path}" | "${IRONFOX_AWK}" '{print tolower($0)}')
  else
    local -r sha512sum_s3path="$2"
  fi

  # Ensure our file to create a SHA512sum for is valid
  verify_file "${sha512sum_file_in}" || exit 1

  local -r sha512sum_file_out="${sha512sum_file_path}/${sha512sum_file_name}-sha512sum.txt"

  # If there's already a SHA512sum file, remove it
  if [[ -f "${sha512sum_file_out}" ]]; then
    "${IRONFOX_RM}" -f "${sha512sum_file_out}"
  fi

  local -r local_sha512sum=$("${IRONFOX_SHASUM}" -a 512 "${sha512sum_file_in}" | "${IRONFOX_AWK}" '{print $1}')
  echo -n "${local_sha512sum}" > "${sha512sum_file_out}"

  push_file "${sha512sum_file_out}" "${sha512sum_s3path}"
}

# Creates a SHA512sum for and pushes a file to S3
function push_and_add_sha512sum() {
  function print_usage() {
    echo "Usage: push_and_add_sha512sum '/path/to/file' 'path/on/s3'"
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

  local -r file_in="$1"
  local -r s3_path_out="$2"

  # Ensure our file to create a SHA512sum for and push is valid
  verify_file "${file_in}" || exit 1

  # Push our file to S3
  push_file "${file_in}" "${s3_path_out}"

  # Create and push a SHA512sum for our file to S3
  add_sha512sum "${file_in}" "${s3_path_out}"
}

if [[ "${IRONFOX_AR_UP_FENIX}" == 1 ]]; then
  if [[ "${IRONFOX_AR_UP_ARCH}" == 'arm64' ]] || [[ "${IRONFOX_AR_UP_ARCH}" == 'bundle' ]]; then
    push_and_add_sha512sum "${IRONFOX_OUTPUTS_ARM64}" "${CI_PIPELINE_ID}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'arm' ]] || [[ "${IRONFOX_AR_UP_ARCH}" == 'bundle' ]]; then
    push_and_add_sha512sum "${IRONFOX_OUTPUTS_ARM}" "${CI_PIPELINE_ID}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'x86_64' ]] || [[ "${IRONFOX_AR_UP_ARCH}" == 'bundle' ]]; then
    push_and_add_sha512sum "${IRONFOX_OUTPUTS_X86_64}" "${CI_PIPELINE_ID}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'bundle' ]]; then
    push_and_add_sha512sum "${IRONFOX_OUTPUTS_UNIVERSAL}" "${CI_PIPELINE_ID}"
    push_and_add_sha512sum "${IRONFOX_OUTPUTS_BUNDLE}" "${CI_PIPELINE_ID}"
  fi
fi

if [[ "${IRONFOX_AR_UP_GECKOVIEW}" == 1 ]]; then
  if [[ "${IRONFOX_AR_UP_ARCH}" == 'arm64' ]]; then
    push_and_add_sha512sum "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64}" "${CI_PIPELINE_ID}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'arm' ]]; then
    push_and_add_sha512sum "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM}" "${CI_PIPELINE_ID}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'x86_64' ]]; then
    push_and_add_sha512sum "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64}" "${CI_PIPELINE_ID}"
  fi
fi
