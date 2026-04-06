# IronFox CI environment variables

# Set timezone to UTC for consistency
unset TZ
export TZ="UTC"

# Android keystore/app signing
export IRONFOX_KEYSTORE='/opt/IronFox/ironfox-keystore.jks'
export IRONFOX_KEYSTORE_KEY_ALIAS='ironfox'
export IRONFOX_KEYSTORE_KEY_PASS_FILE='/opt/IronFox/ironfox-signing-key.pass'
export IRONFOX_KEYSTORE_PASS_FILE='/opt/IronFox/ironfox-keystore.pass'

# Build date
export IRONFOX_DATE='date'
export IRONFOX_BUILD_DATE_OVERRIDE="${CI_PIPELINE_CREATED_AT}"
export IRONFOX_BUILD_ID_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%Y%m%d%H%M%S")"
export IRONFOX_LOCAL_AC_VERSION_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%s%N")"
export IRONFOX_LOCAL_AS_VERSION_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%s%N")"
export IRONFOX_LOCAL_GLEAN_VERSION_OVERRIDE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%s%N")"

# GeckoView AAR archives
export IRONFOX_GECKOVIEW_AAR_ARM64_DIR="${IRONFOX_EXTERNAL}/geckoview-arm64"
export IRONFOX_GECKOVIEW_AAR_ARM64="${IRONFOX_GECKOVIEW_AAR_ARM64_DIR}/aar/geckoview-arm64-v8a.zip"
export IRONFOX_GECKOVIEW_AAR_ARM_DIR="${IRONFOX_EXTERNAL}/geckoview-arm"
export IRONFOX_GECKOVIEW_AAR_ARM="${IRONFOX_GECKOVIEW_AAR_ARM_DIR}/aar/geckoview-armeabi-v7a.zip"
export IRONFOX_GECKOVIEW_AAR_X86_64_DIR="${IRONFOX_EXTERNAL}/geckoview-x86_64"
export IRONFOX_GECKOVIEW_AAR_X86_64="${IRONFOX_GECKOVIEW_AAR_X86_64_DIR}/aar/geckoview-x86_64.zip"
export IRONFOX_GECKOVIEW_BUNDLE_DIRECT=1

# Log directory
export IRONFOX_LOG_DIR="${IRONFOX_LOG_ARTIFACTS}"

# Safe Browsing
export IRONFOX_SB_GAPI_KEY_FILE='/opt/IronFox/ironfox-sb-gapi.data'

# Skip the prompt to install IronFox via ADB after signing
export IRONFOX_SIGN_SKIP_ADB=1
