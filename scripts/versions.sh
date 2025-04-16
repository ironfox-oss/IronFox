#!/bin/bash

FIREFOX_TAG="137.0.2"
FIREFOX_RELEASE_PATH="releases/${FIREFOX_TAG}"
#FIREFOX_RC_BUILD_NAME="build2"
#FIREFOX_RELEASE_PATH="candidates/${FIREFOX_TAG}-candidates/${FIREFOX_RC_BUILD_NAME}"
WASI_TAG="wasi-sdk-20"
GLEAN_TAG="v63.1.0"
GMSCORE_TAG="v0.3.6.244735"
APPSERVICES_TAG="release-v137"
BUNDLETOOL_TAG="1.18.0"

# Configuration
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_SH="${ROOTDIR}/scripts/env_local.sh"
BUILDDIR="${ROOTDIR}/build"
PATCHDIR="${ROOTDIR}/patches"
GECKODIR="${ROOTDIR}/gecko"
GLEANDIR="${ROOTDIR}/glean"
APPSERVICESDIR="${ROOTDIR}/appservices"
GMSCOREDIR="${ROOTDIR}/gmscore"
WASISDKDIR="${ROOTDIR}/wasi-sdk"
ANDROID_COMPONENTS="${GECKODIR}/mobile/android/android-components"
FENIX="${GECKODIR}/mobile/android/fenix"
