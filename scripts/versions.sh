
# Sources

## Firefox
### https://github.com/mozilla-firefox/firefox
### (This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_147_0_2_BUILD1)
FIREFOX_COMMIT='9fc08b8a32cec38350ce7aed268edd4dea28e6d1'
FIREFOX_VERSION='147.0.2'

IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### https://github.com/mozilla/application-services
APPSERVICES_COMMIT='2d12f39543bb9ecb2410b63a092912b811e9fb4d'
APPSERVICES_VERSION='v147.0'

## firefox-l10n
### https://github.com/mozilla-l10n/firefox-l10n
### NOTE: This repo is updated several times a day...
### so I think best approach here will be for us to just update it alongside new releases
L10N_COMMIT='b061ed1b9be6131ace53b748b2a2f3cd4a773f31'

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
PHOENIX_COMMIT='964d320422c481ef5ff31c1a1ae0301e4e1c36e2'
PHOENIX_VERSION='2026.01.21.1'

## uniffi-rs (Tor)
### https://gitlab.torproject.org/tpo/applications/uniffi-rs
UNIFFI_COMMIT='9f392cbaa07aaf83160e94ece2a32d3e9fef22e4'
UNIFFI_VERSION='0.29.0'

## UnifiedPush-AC
### https://gitlab.com/ironfox-oss/unifiedpush-ac
UNIFIEDPUSHAC_COMMIT='c2558fc87bdce300e4aba9d26c99bd714fa08106'

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
RUST_MAJOR_VERSION='1.93'
RUST_VERSION="${RUST_MAJOR_VERSION}.0"
#RUST_MAJOR_VERSION='1.91.1'
#RUST_VERSION="${RUST_MAJOR_VERSION}"

# For prebuilds
## https://gitlab.com/ironfox-oss/prebuilds
PREBUILDS_COMMIT='b76a3b2a8f3124e9297036e3b27802a47c0263a4'
UNIFFI_LINUX_IRONFOX_COMMIT='b76a3b2a8f3124e9297036e3b27802a47c0263a4'
UNIFFI_LINUX_IRONFOX_REVISION='4'
UNIFFI_OSX_IRONFOX_COMMIT='97f5fb17ea756670c452e832ae3fca80d0498a82'
UNIFFI_OSX_IRONFOX_REVISION='4'
WASI_LINUX_IRONFOX_COMMIT='b76a3b2a8f3124e9297036e3b27802a47c0263a4'
WASI_LINUX_IRONFOX_REVISION='4'
WASI_OSX_IRONFOX_COMMIT='97f5fb17ea756670c452e832ae3fca80d0498a82'
WASI_OSX_IRONFOX_REVISION='3'
