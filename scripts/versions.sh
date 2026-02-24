
# Sources

## Firefox
### https://github.com/mozilla-firefox/firefox
### (This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_148_0_RELEASE)
FIREFOX_COMMIT='b2a8a4ec986ce61fd15ab1db980381d04ba85ada'
FIREFOX_VERSION='148.0'

IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### https://github.com/mozilla/application-services
APPSERVICES_COMMIT='2ff0d7c78e7ca92ce48246d5a7c0af6a13ea5f53'
APPSERVICES_VERSION='v148.0'

## firefox-l10n
### https://github.com/mozilla-l10n/firefox-l10n
### NOTE: This repo is updated several times a day...
### so I think best approach here will be for us to just update it alongside new releases
L10N_COMMIT='89228d63d5e33a77a15a1d479fb82bfb07ad358f'

## Glean
### https://github.com/mozilla/glean
GLEAN_COMMIT='e95d7e50678aaa678b9556f4b8b98cdadc0f1c07'
GLEAN_VERSION='v66.2.0'

## microG
### https://github.com/microg/GmsCore
GMSCORE_COMMIT='3ba21336181c846630242124176737c05b3e8b6f'
GMSCORE_VERSION='v0.3.13.250932'

## Phoenix
### https://gitlab.com/celenityy/Phoenix
PHOENIX_COMMIT='4514418a570603f7ae0670ad1f42371345ffff45'
PHOENIX_VERSION='2026.02.23.1'

## uniffi-rs (Tor)
### https://gitlab.torproject.org/tpo/applications/uniffi-rs
UNIFFI_COMMIT='9f392cbaa07aaf83160e94ece2a32d3e9fef22e4'
UNIFFI_VERSION='0.29.0'

## UnifiedPush-AC
### https://gitlab.com/ironfox-oss/unifiedpush-ac
UNIFIEDPUSHAC_COMMIT='7ba42eb12d2ac8e7dd21603a79d8a7f4cdfd25f1'

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
GRADLE_COMMIT='996b7829f40f33317d33c1b6ddcffcf976bd6181'

## Rust
### https://releases.rs/
#RUST_MAJOR_VERSION='1.93'
#RUST_VERSION="${RUST_MAJOR_VERSION}.0"
RUST_MAJOR_VERSION='1.93.1'
RUST_VERSION="${RUST_MAJOR_VERSION}"

# For prebuilds
## https://gitlab.com/ironfox-oss/prebuilds
PREBUILDS_COMMIT='5f3e3d5af8d990b57bd43bf2afd4bfb407e5e288'
UNIFFI_LINUX_IRONFOX_COMMIT='5f3e3d5af8d990b57bd43bf2afd4bfb407e5e288'
UNIFFI_LINUX_IRONFOX_REVISION='5'
UNIFFI_OSX_IRONFOX_COMMIT='74d5b4bc62c3aa4ceab64c41e5185026574a86b6'
UNIFFI_OSX_IRONFOX_REVISION='5'
WASI_LINUX_IRONFOX_COMMIT='b76a3b2a8f3124e9297036e3b27802a47c0263a4'
WASI_LINUX_IRONFOX_REVISION='4'
WASI_OSX_IRONFOX_COMMIT='97f5fb17ea756670c452e832ae3fca80d0498a82'
WASI_OSX_IRONFOX_REVISION='3'
