
# Sources

## Firefox
### https://github.com/mozilla-firefox/firefox
### (This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_148_0_RELEASE)
FIREFOX_COMMIT='b2a8a4ec986ce61fd15ab1db980381d04ba85ada'
FIREFOX_VERSION='148.0'

IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### Version: v148.0
### https://github.com/mozilla/application-services
APPSERVICES_COMMIT='2ff0d7c78e7ca92ce48246d5a7c0af6a13ea5f53'

## firefox-l10n
### https://github.com/mozilla-l10n/firefox-l10n
### NOTE: This repo is updated several times a day...
### so I think best approach here will be for us to just update it alongside new releases
L10N_COMMIT='2424c18f238c59e513ff13c17280f5ef26e1f68b'

## Glean
### Version: v66.2.0
### https://github.com/mozilla/glean
GLEAN_COMMIT='e95d7e50678aaa678b9556f4b8b98cdadc0f1c07'

## microG
### Version: v0.3.13.250932
### https://github.com/microg/GmsCore
GMSCORE_COMMIT='3ba21336181c846630242124176737c05b3e8b6f'

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

### (This is the checksum for android-cmdline-tools.zip)
ANDROID_SDK_SHA512SUM_LINUX='8e4bce8fb1a9a2b83454ab9ea642caa08adc69d93df345238a9c110a29aeb3dd4211ce9464de6d5ce41182c77ad2ff8c1941ed8a0b1f40d267fdfc8a31f461dc'
ANDROID_SDK_SHA512SUM_OSX='375e0594493ade7ab613bacdfbc751c5f004db213b02c6202ac28f4b6174ed9fc5d514b189bbfafd3d9d8c8d7d81b3fb312c0454b79e53ab9d139b90790d2a96'

### This is used for ex. setting microG's compile SDK and target SDK version
ANDROID_SDK_TARGET='36'

## Bundletool
### https://github.com/google/bundletool
BUNDLETOOL_SHA512SUM='50feda5f3f00931bad943a37b7cfc33d8ea53b33bd9bfa83832f612da6e99b72146206695ae25df5044030e305e1d718c833ad51c12b944079c263bba3cbffa0'
BUNDLETOOL_VERSION='1.18.3'

## cbindgen
### https://docs.rs/crate/cbindgen/latest
CBINDGEN_VERSION='0.29.2'

## Gradle (F-Droid)
### https://gitlab.com/fdroid/gradlew-fdroid
GRADLE_COMMIT='996b7829f40f33317d33c1b6ddcffcf976bd6181'
GRADLE_SHA512SUM='0498fff4a729aa2458f2627635507c6e9a9bd3d1e914ac375e10b3b3061654e7f7544461c91a8db0882bfc1d09090d135eada40ee72f37ff9975e0f1116c3d9d'

## Rust
### https://releases.rs/
#RUST_MAJOR_VERSION='1.93'
#RUST_VERSION="${RUST_MAJOR_VERSION}.0"
RUST_MAJOR_VERSION='1.93.1'
RUST_VERSION="${RUST_MAJOR_VERSION}"

## rustup
### https://github.com/rust-lang/rustup/tags
RUSTUP_COMMIT='e4f3ad6f893e56ca10f0a329c401a5eafab69607'
RUSTUP_SHA512SUM='b44833a5cc74448c8ace263bea5499b9dccd0b3b5ad08bbd6c5aafcefe7f421a77d04cdf0e24f1e19de0bf4ff93e170d035665ea10afd3eb228a1633ad13dfaa'
RUSTUP_VERSION='1.28.2'

# For prebuilds
## https://gitlab.com/ironfox-oss/prebuilds
PREBUILDS_COMMIT='5f3e3d5af8d990b57bd43bf2afd4bfb407e5e288'
UNIFFI_LINUX_IRONFOX_COMMIT='5f3e3d5af8d990b57bd43bf2afd4bfb407e5e288'
UNIFFI_LINUX_IRONFOX_REVISION='5'
UNIFFI_LINUX_IRONFOX_SHA512SUM='2821385fbe37af84b7985ce68f683472c7f6038a5cd7d1fc578ac7f9d243d0d352e9a0de12a80827422510784ba470cc8128c197f10454197f23d38db626e407'
UNIFFI_OSX_IRONFOX_COMMIT='74d5b4bc62c3aa4ceab64c41e5185026574a86b6'
UNIFFI_OSX_IRONFOX_REVISION='5'
UNIFFI_OSX_IRONFOX_SHA512SUM='1247ea28c18d37212a9eea3ace3ed4dbe5c192bc07e809ac3422ed17562c851b96a0ea9e5691b72ec84c62f6901fb7767e8d5134be9af6275f4ba15e80fe6314'
WASI_LINUX_IRONFOX_COMMIT='b76a3b2a8f3124e9297036e3b27802a47c0263a4'
WASI_LINUX_IRONFOX_REVISION='4'
WASI_LINUX_IRONFOX_SHA512SUM='98d81e0f47229184fe767fb47906685eec6dd34ad425030e08d1eea42ddec1ebef678530e70dfc954aa2d0904ac44d38a869334c098b0baf9fff1b87233ff31e'
WASI_OSX_IRONFOX_COMMIT='97f5fb17ea756670c452e832ae3fca80d0498a82'
WASI_OSX_IRONFOX_REVISION='3'
WASI_OSX_IRONFOX_SHA512SUM='eb0697f42c9838080fcf23fa0d9c230016212a15725e62e2fafed896751a9fcf8adf508461cf9118c02bff1bcd0791ae1113f13d0cca96de3b8f03244df25a30'
