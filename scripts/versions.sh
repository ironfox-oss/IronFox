
# Sources

## Firefox
### https://github.com/mozilla-firefox/firefox
### (This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_147_0_1_RELEASE)
FIREFOX_COMMIT='4eb5a4f7e5a3bea3de2e2bfc541e1bc122731518'
FIREFOX_VERSION='147.0.1'

IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### https://github.com/mozilla/application-services
APPSERVICES_COMMIT='2d12f39543bb9ecb2410b63a092912b811e9fb4d'
APPSERVICES_VERSION='v147.0'

## firefox-l10n
### https://github.com/mozilla-l10n/firefox-l10n
### NOTE: This repo is updated several times a day...
### so I think best approach here will be for us to just update it alongside new releases
L10N_COMMIT='3f2e9e1197b245f8a1817884eefacd6d45025216'

## Glean
### https://github.com/mozilla/glean
GLEAN_COMMIT='e95d7e50678aaa678b9556f4b8b98cdadc0f1c07'
GLEAN_VERSION='v66.2.0'

## microG
### https://github.com/microg/GmsCore
GMSCORE_COMMIT='cbb8dcfbe8e6155ef6e2276636a94f902041485f'
GMSCORE_VERSION='v0.3.12.250932'

## Phoenix
### https://gitlab.com/celenityy/Phoenix
PHOENIX_COMMIT='f09568c8a71af4fe42dd43c6f711c67daf605f1e'
PHOENIX_VERSION='2025.12.23.1'

## uniffi-rs (Tor)
### https://gitlab.torproject.org/tpo/applications/uniffi-rs
UNIFFI_COMMIT='9f392cbaa07aaf83160e94ece2a32d3e9fef22e4'
UNIFFI_VERSION='0.29.0'

## UnifiedPush-AC
### https://gitlab.com/ironfox-oss/unifiedpush-ac
UNIFIEDPUSHAC_COMMIT='2fc2a497cb801d30ac16a9b674785a31a748ff47'

## WASI SDK
### https://github.com/WebAssembly/wasi-sdk
WASI_COMMIT='935fe1acd2fcd7ea4aed2d5ee4527482862b6344'
WASI_VERSION='20'

# Tools

## Android SDK
### (for reference: https://searchfox.org/firefox-main/source/python/mozboot/mozboot/android.py)
ANDROID_BUILDTOOLS_VERSION='36.1.0'
ANDROID_NDK_REVISION='29.0.14206865' # r29
ANDROID_PLATFORM_VERSION='36.1'
ANDROID_SDK_REVISION='13114758'

### This is used for ex. setting microG's compile SDK and target SDK version
ANDROID_SDK_TARGET='36'

## Bundletool
### https://github.com/google/bundletool
BUNDLETOOL_VERSION='1.18.3'

## cbindgen
### https://docs.rs/crate/cbindgen/latest
CBINDGEN_VERSION='0.29.2'

## Gradle (F-Droid)
### https://gitlab.com/fdroid/gradlew-fdroid
GRADLE_COMMIT='e55f371891e02a45ee65d18cabc81aaf665c96d0'

## Rust
### https://releases.rs/
RUST_MAJOR_VERSION='1.92'
RUST_VERSION="${RUST_MAJOR_VERSION}.0"
#RUST_MAJOR_VERSION='1.91.1'
#RUST_VERSION="${RUST_MAJOR_VERSION}"

# For prebuilds
## https://gitlab.com/ironfox-oss/prebuilds
PREBUILDS_COMMIT='99e7b9dc73ee4e899204a18a29c47a9b52c00947'
UNIFFI_LINUX_IRONFOX_COMMIT='3f26e5e5078ff6c8b8be42d9b0df274cf75cad8d'
UNIFFI_LINUX_IRONFOX_REVISION='3'
UNIFFI_OSX_IRONFOX_COMMIT='ec829cd1df6cf08618e0c7a3594776a9cc6a90e3'
UNIFFI_OSX_IRONFOX_REVISION='3'
WASI_LINUX_IRONFOX_COMMIT='6a1e702c91d18666944676aa7568dff7540f1c84'
WASI_LINUX_IRONFOX_REVISION='3'
WASI_OSX_IRONFOX_COMMIT='c0e40b4c08752fc1335ef6e8247e4c840ed4bef4'
WASI_OSX_IRONFOX_REVISION='2'
