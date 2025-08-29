#!/bin/bash

## This script is expected to be executed in a CI environment, or possibly in our Docker image instance
## DO NOT execute this manually!

set -eu
set -o pipefail
set -o xtrace

source "$(realpath $(dirname "$0"))/versions.sh"

case "${BUILD_VARIANT}" in
arm)
    BUILD_TYPE='apk'
    BUILD_ABI='armeabi-v7a'
    ;;
x86_64)
    BUILD_TYPE='apk'
    BUILD_ABI='x86_64'
    ;;
arm64)
    BUILD_TYPE='apk'
    BUILD_ABI='arm64-v8a'
    ;;
bundle)
    BUILD_TYPE='bundle'
    ;;
*)
    echo "Unknown build variant: '$BUILD_VARIANT'." >&2
    exit 1
    ;;
esac

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
    # Set uBO assets to production variant
    # shellcheck disable=2183
    IRONFOX_UBO_ASSETS_URL="https://gitlab.com/ironfox-oss/assets/-/raw/main/uBlock/assets.${PRODUCTION_BRANCH}.json"
    export IRONFOX_UBO_ASSETS_URL

    echo "Using uBO Assets: ${IRONFOX_UBO_ASSETS_URL}"
fi

# Setup environment variables. See Dockerfile.
source "/opt/env_docker.sh"

# Setup Android SDK
bash -x ./scripts/setup-android-sdk.sh

# Get sources
bash -x ./scripts/get_sources.sh

# Update environment variables for this build
source "scripts/env_local.sh"

# Prepare sources
bash -x ./scripts/prebuild.sh "$BUILD_VARIANT"

# If we're building an APK set, the following environment variables are required
if [[ "$BUILD_TYPE" == "bundle" ]]; then
    export MOZ_ANDROID_FAT_AAR_ARMEABI_V7A="$AAR_ARTIFACTS/geckoview-armeabi-v7a.aar"
    export MOZ_ANDROID_FAT_AAR_ARM64_V8A="$AAR_ARTIFACTS/geckoview-arm64-v8a.aar"
    export MOZ_ANDROID_FAT_AAR_X86_64="$AAR_ARTIFACTS/geckoview-x86_64.aar"
    export MOZ_ANDROID_FAT_AAR_ARCHITECTURES="armeabi-v7a,arm64-v8a,x86_64"
fi

# Set the build date to the date of commmit to ensure that the
# MOZ_BUILDID is consistent across CI build jobs
export MOZ_BUILD_DATE="$(date -d "$CI_PIPELINE_CREATED_AT" "+%Y%m%d%H%M%S")"
export IF_BUILD_DATE="$CI_PIPELINE_CREATED_AT"

# Build
bash -x scripts/build.sh "$BUILD_TYPE"

if [[ "$BUILD_TYPE" == "apk" ]]; then
    # Copy geckoview AAR
    cp -v "$mozilla_release"/obj/gradle/build/mobile/android/geckoview/outputs/aar/geckoview-release.aar \
        "$AAR_ARTIFACTS/geckoview-${BUILD_ABI}.aar"

    # Sign APK
    APK_IN="$(ls "$mozilla_release"/obj/gradle/build/mobile/android/fenix/app/outputs/apk/fenix/release/*.apk)"
    APK_OUT="$APK_ARTIFACTS/IronFox-v${IRONFOX_VERSION}-${BUILD_ABI}.apk"
    "$ANDROID_HOME/build-tools/$BUILDTOOLS_VERSION/apksigner" sign \
      --ks="$KEYSTORE" \
      --ks-pass="pass:$KEYSTORE_PASS" \
      --ks-key-alias="$KEYSTORE_KEY_ALIAS" \
      --key-pass="pass:$KEYSTORE_KEY_PASS" \
      --out="$APK_OUT" \
      "$APK_IN"
fi

if [[ "$BUILD_TYPE" == "bundle" ]]; then
    # Build signed APK set
    AAB_IN="$(ls "$mozilla_release"/obj/gradle/build/mobile/android/fenix/app/outputs/bundle/fenixRelease/*.aab)"
    APKS_OUT="$APKS_ARTIFACTS/IronFox-v${IRONFOX_VERSION}.apks"
    "$builddir"/bundletool build-apks \
        --bundle="$AAB_IN" \
        --output="$APKS_OUT" \
        --ks="$KEYSTORE" \
        --ks-pass="pass:$KEYSTORE_PASS" \
        --ks-key-alias="$KEYSTORE_KEY_ALIAS" \
        --key-pass="pass:$KEYSTORE_KEY_PASS"
fi
