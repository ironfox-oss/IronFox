# shellcheck shell=bash
# IronFox CI environment variables

# Set timezone to UTC for consistency
unset TZ
export TZ='UTC'

if [[ "${IRONFOX_CURRENT_BRANCH}" == "${IRONFOX_PROD_BRANCH}" ]]; then
  # Target release
  export IRONFOX_RELEASE=1
fi

# Android keystore/app signing
export IRONFOX_ANDROID_KEYSTORE='/opt/IronFox/ironfox-android-keystore.jks'
export IRONFOX_ANDROID_KEYSTORE_KEY_ALIAS='ironfox'
export IRONFOX_ANDROID_KEYSTORE_KEY_PASS_FILE='/opt/IronFox/ironfox-android-signing-key-pass.txt'
export IRONFOX_ANDROID_KEYSTORE_PASS_FILE='/opt/IronFox/ironfox-android-keystore-pass.txt'

# Build date
export IRONFOX_DATE='/bin/date'
export IRONFOX_BUILD_DATE_OVERRIDE="${CI_PIPELINE_CREATED_AT}"
export IRONFOX_BUILD_ID_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%Y%m%d%H%M%S")"
export IRONFOX_CORE_TIMESTAMP_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%s%N")"
export IRONFOX_LOCAL_AC_VERSION_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%s%N")"
export IRONFOX_LOCAL_AS_VERSION_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%s%N")"
export IRONFOX_LOCAL_GLEAN_VERSION_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%s%N")"

# GeckoView AAR archives
export IRONFOX_GECKOVIEW_AAR_ARM64="${IRONFOX_AAR_ARTIFACTS}/geckoview-arm64-v8a.zip"
export IRONFOX_GECKOVIEW_AAR_ARM="${IRONFOX_AAR_ARTIFACTS}/geckoview-armeabi-v7a.zip"
export IRONFOX_GECKOVIEW_AAR_X86_64="${IRONFOX_AAR_ARTIFACTS}/geckoview-x86_64.zip"
export IRONFOX_GECKOVIEW_BUNDLE_DIRECT=1

# Log directory
export IRONFOX_LOG_DIR="${IRONFOX_LOG_ARTIFACTS}"

# S3

## Artifacts
export IRONFOX_ARTIFACTS_S3_ACCESS_KEY_FILE='/opt/IronFox/ironfox-artifacts-s3-access-key.txt'
export IRONFOX_ARTIFACTS_S3_BUCKET_NAME_FILE='/opt/IronFox/ironfox-artifacts-s3-bucket-name.txt'
export IRONFOX_ARTIFACTS_S3_ENDPOINT_FILE='/opt/IronFox/ironfox-artifacts-s3-endpoint.txt'
export IRONFOX_ARTIFACTS_S3_SECRET_KEY_FILE='/opt/IronFox/ironfox-artifacts-s3-secret-key.txt'

## Releases
export IRONFOX_RELEASES_S3_ACCESS_KEY_FILE='/opt/IronFox/ironfox-releases-s3-access-key.txt'
export IRONFOX_RELEASES_S3_BUCKET_NAME_FILE='/opt/IronFox/ironfox-releases-s3-bucket-name.txt'
export IRONFOX_RELEASES_S3_ENDPOINT_FILE='/opt/IronFox/ironfox-releases-s3-endpoint.txt'
export IRONFOX_RELEASES_S3_SECRET_KEY_FILE='/opt/IronFox/ironfox-releases-s3-secret-key.txt'

# Safe Browsing
export IRONFOX_SB_GAPI_KEY_FILE='/opt/IronFox/ironfox-sb-gapi-key.txt'

# Skip the prompt to install IronFox via ADB after signing
export IRONFOX_SIGN_SKIP_ADB=1
