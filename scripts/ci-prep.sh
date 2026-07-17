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
  /bin/bash -x "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

# Include utilities
source "${IRONFOX_UTILS}"

# Set-up target parameters
if [[ -z "${1+x}" ]]; then
  echo_red_text "Usage: $0 android-keystore|s3-artifacts|s3-releases|sb" >&1
  exit 1
fi

readonly ci_prep_target=$(echo "${1}" | "${IRONFOX_AWK}" '{print tolower($0)}')

IRONFOX_CI_PREP_ANDROID_KEYSTORE=0
IRONFOX_CI_PREP_S3_ARTIFACTS=0
IRONFOX_CI_PREP_S3_RELEASES=0
IRONFOX_CI_PREP_SB_GAPI_KEY=0

if [[ "${ci_prep_target}" == 'android-ks' ]]; then
  # Set-up the Android keystore
  IRONFOX_CI_PREP_ANDROID_KEYSTORE=1
elif [[ "${ci_prep_target}" == 's3-artifacts' ]]; then
  # Set-up S3 storage - Artifacts
  IRONFOX_CI_PREP_S3_ARTIFACTS=1
elif [[ "${ci_prep_target}" == 's3-releases' ]]; then
  # Set-up S3 storage - Releases
  IRONFOX_CI_PREP_S3_RELEASES=1
elif [[ "${ci_prep_target}" == 'sb' ]]; then
  # Set-up the Google Safe Browsing API key
  IRONFOX_CI_PREP_SB_GAPI_KEY=1
else
  echo_red_text "ERROR: Invalid target: ${ci_prep_target}\n You must enter one of the following:"
  echo 'Android keystore:               android-keystore'
  echo 'Google Safe Browsing API key:   sb'
  echo 'S3 storage - Artifacts:         s3-artifacts'
  echo 'S3 storage - Releases:          s3-releases'
  exit 1
fi
readonly IRONFOX_CI_PREP_ANDROID_KEYSTORE
readonly IRONFOX_CI_PREP_S3_ARTIFACTS
readonly IRONFOX_CI_PREP_S3_RELEASES
readonly IRONFOX_CI_PREP_SB_GAPI_KEY

# Android keystore
function prep_android_keystore() {
  echo_red_text 'Preparing Android keystore...'

  # First, ensure that environment variables specified externally (from CI) are properly set...

  ## Android keystore key pass
  if [[ -z "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE_KEY_PASS environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_ANDROID_KEYSTORE_KEY_PASS

  ## Android keystore pass
  if [[ -z "${IRONFOX_ANDROID_KEYSTORE_PASS+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE_PASS environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_ANDROID_KEYSTORE_PASS

  ## Android keystore URL
  if [[ -z "${IRONFOX_ANDROID_KEYSTORE_URL+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE_URL environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_ANDROID_KEYSTORE_URL

  ## GitLab CI job token
  ### (We need this to download the Android Keystore)
  if [[ -z "${CI_JOB_TOKEN+x}" ]]; then
    echo_red_text 'ERROR: The CI_JOB_TOKEN environment variable is missing! Aborting...'
    exit 1
  fi
  readonly CI_JOB_TOKEN

  # Now, ensure that our keystore file variables (defined at `env_common.sh`, set at `env_ci.sh`) are properly set...

  if [[ -z "${IRONFOX_ANDROID_KEYSTORE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_ANDROID_KEYSTORE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE environment variable has not been specified! Aborting...'
    exit 1
  fi

  if [[ -z "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  if [[ -z "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE_PASS_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_ANDROID_KEYSTORE_PASS_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  # Create our directories
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_ANDROID_KEYSTORE}")
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}")
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}")

  # Download the Android keystore
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location \
    --request GET \
    --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
    "${IRONFOX_ANDROID_KEYSTORE_URL}" \
    --output "${IRONFOX_ANDROID_KEYSTORE}"

  "${IRONFOX_CHMOD}" 600 "${IRONFOX_ANDROID_KEYSTORE}"

  # Create the keystore key pass file
  "${IRONFOX_TOUCH}" "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}"
  echo -n "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS}" > "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}"

  # Create the keystore pass file
  "${IRONFOX_TOUCH}" "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}"
  echo -n "${IRONFOX_ANDROID_KEYSTORE_PASS}" > "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}"

  # Ensure nothing went wrong...
  if [[ ! -s "${IRONFOX_ANDROID_KEYSTORE}" ]]; then
    echo_red_text "ERROR: Android keystore file ${IRONFOX_ANDROID_KEYSTORE} is empty!"
    exit 1
  fi

  if [[ ! -s "${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE}" ]]; then
    echo_red_text "ERROR: Android keystore key pass file ${IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE} is empty!"
    exit 1
  fi

  if [[ ! -s "${IRONFOX_ANDROID_KEYSTORE_PASS_FILE}" ]]; then
    echo_red_text "ERROR: Android keystore pass file ${IRONFOX_ANDROID_KEYSTORE_PASS_FILE} is empty!"
    exit 1
  fi

  echo_green_text 'SUCCESS: Prepared Android keystore'
}

# S3 storage - Artifacts
function prep_s3_artifacts() {
  echo_red_text 'Preparing S3 storage - Artifacts...'

  # First, ensure that environment variables specified externally (from CI) are properly set...

  ## S3 access key
  if [[ -z "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_ACCESS_KEY environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_ARTIFACTS_S3_ACCESS_KEY

  ## S3 bucket name
  if [[ -z "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_BUCKET_NAME environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_ARTIFACTS_S3_BUCKET_NAME

  ## S3 endpoint
  if [[ -z "${IRONFOX_ARTIFACTS_S3_ENDPOINT+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_ENDPOINT environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_ARTIFACTS_S3_ENDPOINT

  ## S3 secret key
  if [[ -z "${IRONFOX_ARTIFACTS_S3_SECRET_KEY+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_SECRET_KEY environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_ARTIFACTS_S3_SECRET_KEY

  # Now, ensure that our S3 file variables (defined at `env_common.sh`, set at `env_ci.sh`) are properly set...

  if [[ -z "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  if [[ -z "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  if [[ -z "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  if [[ -z "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  # Create our directories
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}")
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}")
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}")
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}")

  # Create the S3 access key file
  "${IRONFOX_TOUCH}" "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}"
  echo -n "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY}" > "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}"

  # Create the S3 bucket name file
  "${IRONFOX_TOUCH}" "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}"
  echo -n "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME}" > "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}"

  # Create the S3 endpoint file
  "${IRONFOX_TOUCH}" "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}"
  echo -n "${IRONFOX_ARTIFACTS_S3_ENDPOINT}" > "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}"

  # Create the S3 secret key file
  "${IRONFOX_TOUCH}" "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}"
  echo -n "${IRONFOX_ARTIFACTS_S3_SECRET_KEY}" > "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}"

  # Ensure nothing went wrong...
  if [[ ! -s "${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE}" ]]; then
    echo_red_text "ERROR: S3 access key file ${IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE} is empty!"
    exit 1
  fi

  if [[ ! -s "${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE}" ]]; then
    echo_red_text "ERROR: S3 bucket name file ${IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE} is empty!"
    exit 1
  fi

  if [[ ! -s "${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE}" ]]; then
    echo_red_text "ERROR: S3 endpoint file ${IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE} is empty!"
    exit 1
  fi

  if [[ ! -s "${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE}" ]]; then
    echo_red_text "ERROR: S3 secret key file ${IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE} is empty!"
    exit 1
  fi

  echo_green_text 'SUCCESS: Prepared S3 storage - Artifacts'
}

# S3 storage - Releases
function prep_s3_releases() {
  echo_red_text 'Preparing S3 storage - Releases...'

  # First, ensure that environment variables specified externally (from CI) are properly set...

  ## S3 access key
  if [[ -z "${IRONFOX_RELEASES_S3_ACCESS_KEY+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_ACCESS_KEY environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_RELEASES_S3_ACCESS_KEY

  ## S3 bucket name
  if [[ -z "${IRONFOX_RELEASES_S3_BUCKET_NAME+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_BUCKET_NAME environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_RELEASES_S3_BUCKET_NAME

  ## S3 endpoint
  if [[ -z "${IRONFOX_RELEASES_S3_ENDPOINT+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_ENDPOINT environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_RELEASES_S3_ENDPOINT

  ## S3 secret key
  if [[ -z "${IRONFOX_RELEASES_S3_SECRET_KEY+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_SECRET_KEY environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_RELEASES_S3_SECRET_KEY

  # Now, ensure that our S3 file variables (defined at `env_common.sh`, set at `env_ci.sh`) are properly set...

  if [[ -z "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_ACCESS_KEY_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_ACCESS_KEY_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  if [[ -z "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_BUCKET_NAME_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_BUCKET_NAME_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  if [[ -z "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_ENDPOINT_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_ENDPOINT_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  if [[ -z "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_SECRET_KEY_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_RELEASES_S3_SECRET_KEY_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  # Create our directories
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}")
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}")
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}")
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}")

  # Create the S3 access key file
  "${IRONFOX_TOUCH}" "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}"
  echo -n "${IRONFOX_RELEASES_S3_ACCESS_KEY}" > "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}"

  # Create the S3 bucket name file
  "${IRONFOX_TOUCH}" "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}"
  echo -n "${IRONFOX_RELEASES_S3_BUCKET_NAME}" > "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}"

  # Create the S3 endpoint file
  "${IRONFOX_TOUCH}" "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}"
  echo -n "${IRONFOX_RELEASES_S3_ENDPOINT}" > "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}"

  # Create the S3 secret key file
  "${IRONFOX_TOUCH}" "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}"
  echo -n "${IRONFOX_RELEASES_S3_SECRET_KEY}" > "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}"

  # Ensure nothing went wrong...
  if [[ ! -s "${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE}" ]]; then
    echo_red_text "ERROR: S3 access key file ${IRONFOX_RELEASES_S3_ACCESS_KEY_FILE} is empty!"
    exit 1
  fi

  if [[ ! -s "${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE}" ]]; then
    echo_red_text "ERROR: S3 bucket name file ${IRONFOX_RELEASES_S3_BUCKET_NAME_FILE} is empty!"
    exit 1
  fi

  if [[ ! -s "${IRONFOX_RELEASES_S3_ENDPOINT_FILE}" ]]; then
    echo_red_text "ERROR: S3 endpoint file ${IRONFOX_RELEASES_S3_ENDPOINT_FILE} is empty!"
    exit 1
  fi

  if [[ ! -s "${IRONFOX_RELEASES_S3_SECRET_KEY_FILE}" ]]; then
    echo_red_text "ERROR: S3 secret key file ${IRONFOX_RELEASES_S3_SECRET_KEY_FILE} is empty!"
    exit 1
  fi

  echo_green_text 'SUCCESS: Prepared S3 storage - Releases'
}

# Google Safe Browsing API key
function prep_sb_gapi_key() {
  echo_red_text 'Preparing Google Safe Browsing API key...'

  # First, ensure that environment variables specified externally (from CI) are properly set...

  if [[ -z "${IRONFOX_SB_GAPI_KEY+x}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_SB_GAPI_KEY environment variable is missing! Aborting...'
    exit 1
  fi
  readonly IRONFOX_SB_GAPI_KEY

  # Now, ensure that our Safe Browsing API key file variable (defined at `env_common.sh`, set at `env_ci.sh`) is properly set...

  if [[ -z "${IRONFOX_SB_GAPI_KEY_FILE}" ]]; then
    echo_red_text 'ERROR: The IRONFOX_SB_GAPI_KEY_FILE environment variable is missing! Aborting...'
    exit 1
  fi

  if [[ "${IRONFOX_SB_GAPI_KEY_FILE}" == 'null' ]]; then
    echo_red_text 'ERROR: The IRONFOX_SB_GAPI_KEY_FILE environment variable has not been specified! Aborting...'
    exit 1
  fi

  # Create our directory
  "${IRONFOX_MKDIR}" -p $("${IRONFOX_DIRNAME}" "${IRONFOX_SB_GAPI_KEY_FILE}")

  # Create the Safe Browsing API key file
  "${IRONFOX_TOUCH}" "${IRONFOX_SB_GAPI_KEY_FILE}"
  "${IRONFOX_CHMOD}" 600 "${IRONFOX_SB_GAPI_KEY_FILE}"
  echo -n "${IRONFOX_SB_GAPI_KEY}" > "${IRONFOX_SB_GAPI_KEY_FILE}"

  # Ensure nothing went wrong...
  if [[ ! -s "${IRONFOX_SB_GAPI_KEY_FILE}" ]]; then
    echo_red_text "ERROR: Google Safe Browsing API key file ${IRONFOX_SB_GAPI_KEY_FILE} is empty!"
    exit 1
  fi

  echo_green_text 'SUCCESS: Prepared Google Safe Browsing API key'
}

# Prepare our secrets...
if [[ "${IRONFOX_CI_PREP_ANDROID_KEYSTORE}" == 1 ]]; then
  prep_android_keystore
elif [[ "${IRONFOX_CI_PREP_S3_ARTIFACTS}" == 1 ]]; then
  prep_s3_artifacts
elif [[ "${IRONFOX_CI_PREP_S3_RELEASES}" == 1 ]]; then
  prep_s3_releases
elif [[ "${IRONFOX_CI_PREP_SB_GAPI_KEY}" == 1 ]]; then
  prep_sb_gapi_key
fi
