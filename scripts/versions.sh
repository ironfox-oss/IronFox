#!/bin/bash

# Sources
FIREFOX_TAG="138.0.1"
FIREFOX_TAG_NAME="FIREFOX_${FIREFOX_TAG//./_}_RELEASE"
FIREFOX_RELEASE_PATH="releases/${FIREFOX_TAG}"
#FIREFOX_RC_BUILD_NAME="build1"
#FIREFOX_TAG_NAME="FIREFOX_${FIREFOX_TAG//./_}_${FIREFOX_RC_BUILD_NAME^^}"
#FIREFOX_RELEASE_PATH="candidates/${FIREFOX_TAG}-candidates/${FIREFOX_RC_BUILD_NAME}"
WASI_TAG="wasi-sdk-20"
GLEAN_TAG="v63.1.0"
GMSCORE_TAG="v0.3.7.250932"
APPSERVICES_TAG="release-v138"

# Tools
BUNDLETOOL_TAG="1.18.0"
RUST_VERSION="1.83.0"
CBINDGEN_VERSION="0.28.0"

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
