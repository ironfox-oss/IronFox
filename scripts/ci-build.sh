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
    ;;
x86_64)
    BUILD_TYPE='apk'
    ;;
arm64)
    BUILD_TYPE='apk'
    ;;
bundle)
    BUILD_TYPE='bundle'
    ;;
*)
    echo "Unknown build variant: '${BUILD_VARIANT}'." >&2
    exit 1
    ;;
esac

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
    # Set uBO assets to production variant
    export IRONFOX_UBO_ASSETS_URL="https://gitlab.com/ironfox-oss/assets/-/raw/main/uBlock/assets.${PRODUCTION_BRANCH}.json"

    echo "Using uBO Assets: ${IRONFOX_UBO_ASSETS_URL}"

    # Target release
    export IRONFOX_RELEASE=1
    echo "Preparing to build IronFox (Release)..."
fi

# Get sources
bash -x ./scripts/get_sources.sh

# Prepare sources
bash -x ./scripts/prebuild.sh "${BUILD_VARIANT}"

source "$(realpath $(dirname "$0"))/env_local.sh"

if [[ "$BUILD_TYPE" == "bundle" ]]; then
    export MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
    export MOZ_ANDROID_FAT_AAR_ARM64_V8A="${IRONFOX_GECKOVIEW_AAR_ARM64_ARTIFACT}"
    export MOZ_ANDROID_FAT_AAR_ARMEABI_V7A="${IRONFOX_GECKOVIEW_AAR_ARM_ARTIFACT}"
    export MOZ_ANDROID_FAT_AAR_X86_64="${IRONFOX_GECKOVIEW_AAR_X86_64_ARTIFACT}"
fi

# Set the build date to the date of commmit to ensure that the
# MOZ_BUILDID is consistent across CI build jobs
export MOZ_BUILD_DATE="$(date -d "${CI_PIPELINE_CREATED_AT}" "+%Y%m%d%H%M%S")"
export IF_BUILD_DATE="${CI_PIPELINE_CREATED_AT}"

# Build
bash -x scripts/build.sh "${BUILD_TYPE}"

if [[ "${BUILD_TYPE}" == "apk" ]]; then
    pushd "${IRONFOX_GECKO}"

    # Create GeckoView AAR archives
    MOZ_AUTOMATION=1 ./mach android archive-geckoview

    if [[ "${BUILD_VARIANT}" == 'arm' ]]; then
        cp -vf "${IRONFOX_GECKOVIEW_AAR_ARM}" "${IRONFOX_GECKOVIEW_AAR_ARM_ARTIFACT}"
    elif [[ "${BUILD_VARIANT}" == 'arm64' ]]; then
        cp -vf "${IRONFOX_GECKOVIEW_AAR_ARM64}" "${IRONFOX_GECKOVIEW_AAR_ARM64_ARTIFACT}"
    elif [[ "${BUILD_VARIANT}" == 'x86_64' ]]; then
        cp -vf "${IRONFOX_GECKOVIEW_AAR_X86_64}" "${IRONFOX_GECKOVIEW_AAR_X86_64_ARTIFACT}"
    fi

    popd

    # Sign APK
    APK_IN="${IRONFOX_OUTPUTS}/ironfox-${IRONFOX_CHANNEL}-${BUILD_VARIANT}-unsigned.apk"
    APK_OUT="${APK_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}-${IRONFOX_TARGET_ABI}.apk"
    "${IRONFOX_ANDROID_SDK}/build-tools/${ANDROID_BUILDTOOLS_VERSION}/apksigner" sign \
      --ks="${KEYSTORE}" \
      --ks-pass="pass:${KEYSTORE_PASS}" \
      --ks-key-alias="${KEYSTORE_KEY_ALIAS}" \
      --key-pass="pass:${KEYSTORE_KEY_PASS}" \
      --out="${APK_OUT}" \
      "${APK_IN}"
fi

if [[ "${BUILD_TYPE}" == "bundle" ]]; then
    # Build signed APK set
    AAB_IN="$(ls "${IRONFOX_GECKO}"/obj/ironfox-${IRONFOX_CHANNEL}-${BUILD_VARIANT}/gradle/build/mobile/android/fenix/app/outputs/bundle/fenixRelease/*.aab)"
    APKS_OUT="${APKS_ARTIFACTS}/IronFox-v${IRONFOX_VERSION}.apks"
    "${IRONFOX_BUNDLETOOL}"/bundletool build-apks \
        --bundle="${AAB_IN}" \
        --output="${APKS_OUT}" \
        --ks="${KEYSTORE}" \
        --ks-pass="pass:${KEYSTORE_PASS}" \
        --ks-key-alias="${KEYSTORE_KEY_ALIAS}" \
        --key-pass="pass:${KEYSTORE_KEY_PASS}"
fi
