#!/bin/bash

# Caution: Should not be sourced directly!
# Use 'env_local.sh' or 'env_fdroid.sh' instead.

# Allow users to install unsigned extensions
# We still require extensions to be signed by default - this just allows users to disable this requirement via `xpinstall.signatures.required` in their `about:config` if desired (though NOT recommended)
# https://gitlab.com/ironfox-oss/IronFox/-/issues/41

MOZ_REQUIRE_SIGNING=
export MOZ_REQUIRE_SIGNING

MOZ_CHROME_MULTILOCALE=$(<"$patches/locales")
export MOZ_CHROME_MULTILOCALE

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
