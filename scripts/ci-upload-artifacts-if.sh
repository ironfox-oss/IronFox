#!/bin/bash

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x || return 1

# Include S3 utilities
verify_file_with_env "${IRONFOX_S3_UTILS}" 'IRONFOX_S3_UTILS' || return 1
source "${IRONFOX_S3_UTILS}" || return 1

if [[ -z "${IRONFOX_FROM_AR_UP+x}" ]]; then
  echo_red_text "ERROR: Do not call 'ci-upload-artifacts-if.sh' directly! Instead, use 'ci-upload-artifacts.sh'." >&1
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

# Verify secrets
verify_file_with_env "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}" 'IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE' || return 1
verify_file_with_env "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}" 'IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE' || return 1
verify_file_with_env "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}" 'IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE' || return 1
verify_file_with_env "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}" 'IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE' || return 1

verify_env "${target_artifact}" 'target_artifact' || {
  echo_red_text "ERROR: Missing target artifact!"
  return 1
}

verify_env "${target_arch}" 'target_arch' || {
  echo_red_text "ERROR: Missing target architecture!"
  return 1
}

# Set-up target parameters
IRONFOX_AR_UP_FENIX=0
IRONFOX_AR_UP_GECKOVIEW=0

if [[ "${target_artifact}" == 'fenix' ]]; then
  # Push Fenix
  IRONFOX_AR_UP_FENIX=1
elif [[ "${target_artifact}" == 'geckoview' ]]; then
  # Push GeckoView
  IRONFOX_AR_UP_GECKOVIEW=1
else
  echo_red_text "ERROR: Invalid artifact: '${target_artifact}'\n You must enter one of the following:"
  echo 'Fenix:      fenix'
  echo 'GeckoView:  geckoview'
  return 1
fi
readonly IRONFOX_AR_UP_FENIX
readonly IRONFOX_AR_UP_GECKOVIEW

if [[ "${target_arch}" != 'arm64' ]] && [[ "${target_arch}" != 'arm' ]] && [[ "${target_arch}" != 'x86_64' ]] && [[ "${target_arch}" != 'bundle' ]]; then
  echo_red_text "ERROR: Invalid target architecture: '${target_arch}'\n You must enter one of the following:"
  echo 'ARM64:      arm64'
  echo 'ARM:        arm'
  echo 'x86_64:     x86_64'
  echo 'Bundle:     bundle'
  return 1
fi
readonly IRONFOX_AR_UP_ARCH="${target_arch}"

# Constants

# Target S3 path
readonly IRONFOX_S3_PATH="ironfox/${IRONFOX_CI_ID}"

# Push a file with a SHA512sum to S3 storage
function push_to_s3() {
  function print_usage() {
    echo "Usage: push_to_s3 '/path/to/file' 'path/on/s3'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a file that should be uploaded to S3 storage!'
    print_usage
    return 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the target path on S3 storage for where the file should be uploaded!'
    print_usage
    return 1
  fi

  local -r push_file="$1"
  local -r s3_path="$2"

  local -r s3_access_key_file="${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}"
  local -r s3_bucket_name_file="${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}"
  local -r s3_endpoint_file="${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}"
  local -r s3_secret_key_file="${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}"

  # Ensure our file to push is valid
  verify_file "${push_file}" || return 1

  # Create and push a SHA512sum for our file to S3 storage
  push_and_add_sha512sum "${push_file}" "${s3_path}" "${s3_access_key_file}" "${s3_bucket_name_file}" "${s3_endpoint_file}" "${s3_secret_key_file}"
}

if [[ "${IRONFOX_AR_UP_FENIX}" == 1 ]]; then
  if [[ "${IRONFOX_AR_UP_ARCH}" == 'arm64' ]] || [[ "${IRONFOX_AR_UP_ARCH}" == 'bundle' ]]; then
    # Ensure we have `IRONFOX_OUTPUTS_ARM64`
    verify_file_with_env "${IRONFOX_OUTPUTS_ARM64}" 'IRONFOX_OUTPUTS_ARM64' || return 1

    push_to_s3 "${IRONFOX_OUTPUTS_ARM64}" "${IRONFOX_S3_PATH}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'arm' ]] || [[ "${IRONFOX_AR_UP_ARCH}" == 'bundle' ]]; then
    # Ensure we have `IRONFOX_OUTPUTS_ARM`
    verify_file_with_env "${IRONFOX_OUTPUTS_ARM}" 'IRONFOX_OUTPUTS_ARM' || return 1

    push_to_s3 "${IRONFOX_OUTPUTS_ARM}" "${IRONFOX_S3_PATH}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'x86_64' ]] || [[ "${IRONFOX_AR_UP_ARCH}" == 'bundle' ]]; then
    # Ensure we have `IRONFOX_OUTPUTS_X86_64`
    verify_file_with_env "${IRONFOX_OUTPUTS_X86_64}" 'IRONFOX_OUTPUTS_X86_64' || return 1

    push_to_s3 "${IRONFOX_OUTPUTS_X86_64}" "${IRONFOX_S3_PATH}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'bundle' ]]; then
    # Ensure we have `IRONFOX_OUTPUTS_BUNDLE`
    verify_file_with_env "${IRONFOX_OUTPUTS_BUNDLE}" 'IRONFOX_OUTPUTS_BUNDLE' || return 1

    # Ensure we have `IRONFOX_OUTPUTS_BUNDLE_AAB`
    verify_file_with_env "${IRONFOX_OUTPUTS_BUNDLE_AAB}" 'IRONFOX_OUTPUTS_BUNDLE_AAB' || return 1

    # Ensure we have `IRONFOX_OUTPUTS_UNIVERSAL`
    verify_file_with_env "${IRONFOX_OUTPUTS_UNIVERSAL}" 'IRONFOX_OUTPUTS_UNIVERSAL' || return 1

    push_to_s3 "${IRONFOX_OUTPUTS_UNIVERSAL}" "${IRONFOX_S3_PATH}"
    push_to_s3 "${IRONFOX_OUTPUTS_BUNDLE}" "${IRONFOX_S3_PATH}"
    push_to_s3 "${IRONFOX_OUTPUTS_BUNDLE_AAB}" "${IRONFOX_S3_PATH}"
  fi
fi

if [[ "${IRONFOX_AR_UP_GECKOVIEW}" == 1 ]]; then
  if [[ "${IRONFOX_AR_UP_ARCH}" == 'arm64' ]]; then
    # Ensure we have `IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64`
    verify_file_with_env "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64}" 'IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64' || return 1

    push_to_s3 "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64}" "${IRONFOX_S3_PATH}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'arm' ]]; then
    # Ensure we have `IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM`
    verify_file_with_env "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM}" 'IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM' || return 1

    push_to_s3 "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM}" "${IRONFOX_S3_PATH}"
  fi

  if [[ "${IRONFOX_AR_UP_ARCH}" == 'x86_64' ]]; then
    # Ensure we have `IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64`
    verify_file_with_env "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64}" 'IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64' || return 1

    push_to_s3 "${IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64}" "${IRONFOX_S3_PATH}"
  fi
fi
