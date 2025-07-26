#!/bin/bash

# Caution: Should not be sourced directly!
# Use 'env_local.sh' or 'env_fdroid.sh' instead.

# Configure Mach
## https://firefox-source-docs.mozilla.org/mach/usage.html#user-settings
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#95
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#284
export DISABLE_TELEMETRY=1
export MACHRC="$patches/machrc"

IRONFOX_LOCALES=$(<"$patches/locales")
export IRONFOX_LOCALES

export NSS_DIR="$application_services/libs/desktop/linux-x86-64/nss"
export NSS_STATIC=1

export ARTIFACTS="$rootdir/artifacts"
export APK_ARTIFACTS=$ARTIFACTS/apk
export APKS_ARTIFACTS=$ARTIFACTS/apks
export AAR_ARTIFACTS=$ARTIFACTS/aar

mkdir -p "$APK_ARTIFACTS"
mkdir -p "$APKS_ARTIFACTS"
mkdir -p "$AAR_ARTIFACTS"

export env_source="true"

if [[ -z ${CARGO_HOME+x} ]]; then
    export CARGO_HOME=$HOME/.cargo
fi

if [[ -z ${GRADLE_USER_HOME+x} ]]; then
    export GRADLE_USER_HOME=$HOME/.gradle
fi

if [[ -z ${IRONFOX_UBO_ASSETS_URL+x} ]]; then
    # Default to development assets
    # shellcheck disable=SC2059
    IRONFOX_UBO_ASSETS_URL="https://gitlab.com/ironfox-oss/IronFox/-/raw/dev/uBlock/assets.dev.json"
    export IRONFOX_UBO_ASSETS_URL

    echo "Using uBO Assets: ${IRONFOX_UBO_ASSETS_URL}"
fi
