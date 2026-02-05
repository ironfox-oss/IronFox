#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -eu
set -o pipefail
set -o xtrace

echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

echo_green_text() {
	echo -e "\033[32m$1\033[0m"
}

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
    # Target release
    export IRONFOX_RELEASE=1
fi

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Get sources
bash -x "${IRONFOX_SCRIPTS}/get_sources.sh"

# Prepare sources
bash -x "${IRONFOX_SCRIPTS}/prebuild.sh"

# Build
## Using 'bundle' here builds everything
bash -x "${IRONFOX_SCRIPTS}/build.sh" 'bundle'

# Include version info
source "${IRONFOX_VERSIONS}"

# Ensure our artifact directories exist
mkdir -vp "${IRONFOX_ARTIFACTS_AAR}"
mkdir -vp "${IRONFOX_ARTIFACTS_APK}"
mkdir -vp "${IRONFOX_ARTIFACTS_APKS}"

# Copy our GeckoView AAR builds
cp -vf "${IRONFOX_OUTPUTS_GV_AAR_ARM64}" "${IRONFOX_ARTIFACTS_AAR}/geckoview-arm64-v8a.zip"
cp -vf "${IRONFOX_OUTPUTS_GV_AAR_ARM}" "${IRONFOX_ARTIFACTS_AAR}/geckoview-armeabi-v7a.zip"
cp -vf "${IRONFOX_OUTPUTS_GV_AAR_X86_64}" "${IRONFOX_ARTIFACTS_AAR}/geckoview-armeabi-x86_64.zip"

function sign_apk() {
    abi="$1"

    echo_green_text "Signing IronFox (${abi})..."

    APK_IN="${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${abi}-unsigned.apk"
    APK_OUT="${IRONFOX_ARTIFACTS_APK}/IronFox-v${IRONFOX_VERSION}-${abi}.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
        --ks="${KEYSTORE}" \
        --ks-pass="pass:${KEYSTORE_PASS}" \
        --ks-key-alias="${KEYSTORE_KEY_ALIAS}" \
        --key-pass="pass:${KEYSTORE_KEY_PASS}" \
        --out="${APK_OUT}" \
        "${APK_IN}"
}

# Sign ARM64 APK
sign_apk "${IRONFOX_TARGET_ABI_ARM64}"

# Sign ARM APK
sign_apk "${IRONFOX_TARGET_ABI_ARM}"

# Sign x86_64 APK
sign_apk "${IRONFOX_TARGET_ABI_X86_64}"

# Sign universal APK
sign_apk 'universal'

# Build signed APK set
echo_green_text "Creating IronFox bundle..."
AAB_IN="${IRONFOX_OUTPUTS_AAB}/ironfox-${IRONFOX_CHANNEL}.aab"
APKS_OUT="${IRONFOX_ARTIFACTS_APKS}/IronFox-v${IRONFOX_VERSION}.apks"
"${IRONFOX_BUNDLETOOL}" build-apks \
    --bundle="${AAB_IN}" \
    --output="${APKS_OUT}" \
    --ks="${KEYSTORE}" \
    --ks-pass="pass:${KEYSTORE_PASS}" \
    --ks-key-alias="${KEYSTORE_KEY_ALIAS}" \
    --key-pass="pass:${KEYSTORE_KEY_PASS}"
