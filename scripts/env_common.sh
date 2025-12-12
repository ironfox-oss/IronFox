#!/bin/bash

# Caution: Should not be sourced directly!
# Use 'env_local.sh' or 'env_fdroid.sh' instead.

if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM=darwin
else
    PLATFORM=linux
fi

# Set architecture
PLATFORM_ARCH=$(uname -m)
if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
    PLATFORM_ARCHITECTURE=aarch64
else
    PLATFORM_ARCHITECTURE=x86-64
fi

# Set locations for GNU make + nproc
if [[ "$PLATFORM" == "darwin" ]]; then
    export MAKE_LIB="gmake"
    export NPROC_LIB="sysctl -n hw.logicalcpu"
else
    export MAKE_LIB="make"
    export NPROC_LIB="nproc"
fi

# Configure Mach
## https://firefox-source-docs.mozilla.org/mach/usage.html#user-settings
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#95
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#284
export DISABLE_TELEMETRY=1
export MACHRC="$patches/machrc"
export MOZCONFIG="$mozilla_release/mozconfig"

# Android SDK
export ANDROID_HOME="$android_sdk_dir"
export ANDROID_NDK="$android_ndk_dir"
export ANDROID_SDK_ROOT="$android_sdk_dir"

IRONFOX_LOCALES=$(<"$patches/locales")
export IRONFOX_LOCALES

export NSS_DIR="$application_services/libs/desktop/$PLATFORM-$PLATFORM_ARCHITECTURE/nss"
export NSS_STATIC=1

export ARTIFACTS="$rootdir/artifacts"
export APK_ARTIFACTS=$ARTIFACTS/apk
export APKS_ARTIFACTS=$ARTIFACTS/apks
export AAR_ARTIFACTS=$ARTIFACTS/aar

mkdir -vp "$APK_ARTIFACTS"
mkdir -vp "$APKS_ARTIFACTS"
mkdir -vp "$AAR_ARTIFACTS"

export env_source="true"

export CARGO_HOME="$builddir/.cargo"
export GRADLE_USER_HOME="$builddir/.gradle"

if [[ -z ${IRONFOX_RELEASE+x} ]]; then
    # Default to a "nightly" dev build
    export IRONFOX_RELEASE=0

    echo "Preparing to build IronFox Nightly..."
fi

if [[ -z ${IRONFOX_UBO_ASSETS_URL+x} ]]; then
    # Default to development assets
    # shellcheck disable=SC2059
    IRONFOX_UBO_ASSETS_URL="https://gitlab.com/ironfox-oss/assets/-/raw/main/uBlock/assets.dev.json"
    export IRONFOX_UBO_ASSETS_URL

    echo "Using uBO Assets: ${IRONFOX_UBO_ASSETS_URL}"
fi
