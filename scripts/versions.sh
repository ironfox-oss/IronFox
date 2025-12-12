#!/bin/bash
# shellcheck disable=SC2034

# Sources

## Firefox
### This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_146_0_RELEASE
FIREFOX_COMMIT="1bff8c2701b6fc4df104208f4e5b80e330426a55"
### This commit corresponds to the latest commit for the WASI SDK patch specifically
### (ex. https://github.com/mozilla-firefox/firefox/blob/1a033a9748a551fc2d100cb6266a1e751effc5df/taskcluster/scripts/misc/wasi-sdk.patch)
FIREFOX_WASI_COMMIT="1a033a9748a551fc2d100cb6266a1e751effc5df"
FIREFOX_VERSION="146.0"

IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
APPSERVICES_COMMIT="9d0f44b0a67b05556a5e1672875395665eb51754"
APPSERVICES_VERSION="v146.0.2"

## Glean
GLEAN_COMMIT="19729353fa93916067c155b9e293c00836a6948a"
GLEAN_VERSION="v66.1.2"

## microG
GMSCORE_COMMIT="f0e24344a2c1c3f17c584d5befcbf783e6780260"
GMSCORE_VERSION="v0.3.10.250932"

## Phoenix
PHOENIX_COMMIT="5b5375277a9596d66b7d38f03fb7d6729831a072"
PHOENIX_VERSION="2025.11.27.1"

## uniffi-rs (Tor)
UNIFFI_COMMIT="9f392cbaa07aaf83160e94ece2a32d3e9fef22e4"
UNIFFI_VERSION="0.29.0"

## UnifiedPush
UNIFIEDPUSH_VERSION="3.1.2"

## WASI SDK
WASI_COMMIT="935fe1acd2fcd7ea4aed2d5ee4527482862b6344"
WASI_VERSION="20"

# Tools

## Bundletool
BUNDLETOOL_VERSION="1.18.2"

## cbindgen
CBINDGEN_VERSION="0.29.2"

## LLVM
### This commit corresponds to https://github.com/llvm/llvm-project/releases/tag/llvmorg-21.1.7
LLVM_COMMIT="292dc2b86f66e39f4b85ec8b185fd8b60f5213ce"

## Rust
#RUST_MAJOR_VERSION="1.91"
#RUST_VERSION="${RUST_MAJOR_VERSION}.0"
RUST_MAJOR_VERSION="1.91.1"
RUST_VERSION="${RUST_MAJOR_VERSION}"

# For prebuilds
UNIFFI_LINUX_IRONFOX_COMMIT="97d7258e8338fb2fe8ba03980c7c1d9ecb6d599f"
UNIFFI_LINUX_IRONFOX_REVISION="2"
UNIFFI_OSX_IRONFOX_COMMIT="de5fa2379dc3b66884622ce3945c7ab39e00d3b3"
UNIFFI_OSX_IRONFOX_REVISION="2"
WASI_LINUX_IRONFOX_COMMIT="6a1e702c91d18666944676aa7568dff7540f1c84"
WASI_LINUX_IRONFOX_REVISION="3"
WASI_OSX_IRONFOX_COMMIT="c0e40b4c08752fc1335ef6e8247e4c840ed4bef4"
WASI_OSX_IRONFOX_REVISION="2"

# Configuration
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_SH="$ROOTDIR/scripts/env_local.sh"
EXTERNALDIR="$ROOTDIR/external"
TMPDIR="$EXTERNALDIR/tmp"
BUILDDIR="$ROOTDIR/build"
PATCHDIR="$ROOTDIR/patches"
GECKODIR="$EXTERNALDIR/gecko"
ANDROID_COMPONENTS="$GECKODIR/mobile/android/android-components"
APPSERVICESDIR="$EXTERNALDIR/application-services"
BUNDLETOOLDIR="$EXTERNALDIR/bundletool"
FENIX="$GECKODIR/mobile/android/fenix"
GLEANDIR="$EXTERNALDIR/glean"
GMSCOREDIR="$EXTERNALDIR/gmscore"
UNIFFIDIR="$EXTERNALDIR/uniffi"
WASIPATCHDIR="$EXTERNALDIR/wasi-patch"
WASISDKDIR="$EXTERNALDIR/wasi-sdk"

# Use GNU Sed on macOS instead of the built-in sed, due to differences in syntax
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED=gsed
else
    SED=sed
fi
