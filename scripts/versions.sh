
# Sources

## Firefox
### https://github.com/mozilla-firefox/firefox
### (This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_146_0_RELEASE)
FIREFOX_COMMIT="1bff8c2701b6fc4df104208f4e5b80e330426a55"
### This commit corresponds to the latest commit for the WASI SDK patch specifically
### (ex. https://github.com/mozilla-firefox/firefox/blob/1a033a9748a551fc2d100cb6266a1e751effc5df/taskcluster/scripts/misc/wasi-sdk.patch)
FIREFOX_WASI_COMMIT="1a033a9748a551fc2d100cb6266a1e751effc5df"
FIREFOX_VERSION="146.0"

IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### https://github.com/mozilla/application-services
APPSERVICES_COMMIT="9d0f44b0a67b05556a5e1672875395665eb51754"
APPSERVICES_VERSION="v146.0.2"

## Glean
### https://github.com/mozilla/glean
GLEAN_COMMIT="19729353fa93916067c155b9e293c00836a6948a"
GLEAN_VERSION="v66.1.2"

## microG
### https://github.com/microg/GmsCore
GMSCORE_COMMIT="34048e6a47914ef38cb65654cde4b67d9b28f3b5"
GMSCORE_VERSION="v0.3.11.250932"

## Phoenix
### https://gitlab.com/celenityy/Phoenix
PHOENIX_COMMIT="5b5375277a9596d66b7d38f03fb7d6729831a072"
PHOENIX_VERSION="2025.11.27.1"

## uniffi-rs (Tor)
### https://gitlab.torproject.org/tpo/applications/uniffi-rs
UNIFFI_COMMIT="9f392cbaa07aaf83160e94ece2a32d3e9fef22e4"
UNIFFI_VERSION="0.29.0"

## UnifiedPush
### https://codeberg.org/UnifiedPush/android-connector
UNIFIEDPUSH_VERSION="3.1.2"

## WASI SDK
### https://github.com/WebAssembly/wasi-sdk
WASI_COMMIT="935fe1acd2fcd7ea4aed2d5ee4527482862b6344"
WASI_VERSION="20"

# Tools

## Android SDK
### (for reference: https://searchfox.org/firefox-main/source/python/mozboot/mozboot/android.py)
ANDROID_BUILDTOOLS_VERSION="36.0.0"
ANDROID_NDK_REVISION="29.0.14206865"
ANDROID_PLATFORM_VERSION="36"
ANDROID_SDK_REVISION="13114758"

## Bundletool
### https://github.com/google/bundletool
BUNDLETOOL_VERSION="1.18.3"

## cbindgen
### https://docs.rs/crate/cbindgen/latest
CBINDGEN_VERSION="0.29.2"

## Gradle (F-Droid)
### https://gitlab.com/fdroid/gradlew-fdroid
GRADLE_COMMIT="e55f371891e02a45ee65d18cabc81aaf665c96d0"

## LLVM
### https://github.com/llvm/llvm-project
### (This commit corresponds to https://github.com/llvm/llvm-project/releases/tag/llvmorg-21.1.7)
LLVM_COMMIT="292dc2b86f66e39f4b85ec8b185fd8b60f5213ce"

## Rust
### https://releases.rs/
RUST_MAJOR_VERSION="1.92"
RUST_VERSION="${RUST_MAJOR_VERSION}.0"
#RUST_MAJOR_VERSION="1.91.1"
#RUST_VERSION="${RUST_MAJOR_VERSION}"

# For prebuilds
## https://gitlab.com/ironfox-oss/prebuilds
UNIFFI_LINUX_IRONFOX_COMMIT="3f26e5e5078ff6c8b8be42d9b0df274cf75cad8d"
UNIFFI_LINUX_IRONFOX_REVISION="3"
UNIFFI_OSX_IRONFOX_COMMIT="ec829cd1df6cf08618e0c7a3594776a9cc6a90e3"
UNIFFI_OSX_IRONFOX_REVISION="3"
WASI_LINUX_IRONFOX_COMMIT="6a1e702c91d18666944676aa7568dff7540f1c84"
WASI_LINUX_IRONFOX_REVISION="3"
WASI_OSX_IRONFOX_COMMIT="c0e40b4c08752fc1335ef6e8247e4c840ed4bef4"
WASI_OSX_IRONFOX_REVISION="2"

# Configuration
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_SH="$ROOTDIR/scripts/env_local.sh"
EXTERNALDIR="$ROOTDIR/external"
BUILDDIR="$ROOTDIR/build"
PATCHDIR="$ROOTDIR/patches"
TMPDIR="$EXTERNALDIR/tmp"
ANDROIDSDKDIR="$EXTERNALDIR/android-sdk"
APPSERVICESDIR="$EXTERNALDIR/application-services"
BUNDLETOOLDIR="$EXTERNALDIR/bundletool"
GECKODIR="$EXTERNALDIR/gecko"
ANDROID_COMPONENTS="$GECKODIR/mobile/android/android-components"
FENIX="$GECKODIR/mobile/android/fenix"
GLEANDIR="$EXTERNALDIR/glean"
GMSCOREDIR="$EXTERNALDIR/gmscore"
GRADLEDIR="$EXTERNALDIR/gradle"
UNIFFIDIR="$EXTERNALDIR/uniffi"
WASIPATCHDIR="$EXTERNALDIR/wasi-patch"
WASISDKDIR="$EXTERNALDIR/wasi-sdk"

# Use GNU Sed on macOS instead of the built-in sed, due to differences in syntax
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED=gsed
else
    SED=sed
fi
