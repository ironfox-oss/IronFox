
# Sources

## Firefox
### Version: 152.0.2 (RELEASE)
### https://github.com/mozilla-firefox/firefox
readonly FIREFOX_COMMIT='e784efd49da7cd69805f55f3353b65ff430441a1'
readonly FIREFOX_SHA512SUM='54e8e5128cab75e78cf2180f0b1ee5d18a697f00a7621e877af205f6ccc7423637718eb3fd489a9b435ab7c71b1ab199b1aa53ca5ea8aadd1486116cef9cdff2'
readonly FIREFOX_VERSION='152.0.2'

### IronFox
readonly IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### Version: v152.0
### https://github.com/mozilla/application-services
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/mobile/android/android-components/plugins/dependencies/src/main/java/ApplicationServices.kt)
readonly APPSERVICES_COMMIT='6e01445f7aa3d714920c808a83a92a0fccb5087c'
readonly APPSERVICES_SHA512SUM='d568e676ffba9e6f72bd70d06af633e169d3bb4fde1cf59687f0af43a02f629c13ae4dcfaadb7e75ebd806fe7fba8cb99576a8bf0444b00b8a8550511ef7b373'
readonly APPSERVICES_VERSION='152.0'

## firefox-l10n
### https://github.com/mozilla-l10n/firefox-l10n
### NOTE: This repo is updated several times a day...
### so I think best approach here will be for us to just update it alongside new releases
readonly L10N_COMMIT='69ebbebdfc3ac686ac663c086c5cc503048ae737'
readonly L10N_SHA512SUM='bb0d7355fb79738c65ceacb6b1d1abe5e29fb7f8eeaba034881e24060fef46324e6eddb5274273b0080c96d85e4cf0405a524e23c467f31981a76491daa857bc'

## Glean
### Version: 67.3.2
### https://github.com/mozilla/glean
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/gradle/libs.versions.toml)
readonly GLEAN_COMMIT='24c647f24faedfe6839c99d18e58df0e288132a8'
readonly GLEAN_SHA512SUM='a80e30355c8b2ef86e999908e01cc510bd9d018c9a9d774714c90468d07ac4b14c8aa919df9093707cede5ed51c29afdbe2e76c4903e7868ce767cf34afe5435'
readonly GLEAN_VERSION='67.3.2'

## Glean Parser
### Version: v19.0.0
### https://github.com/mozilla/glean_parser
readonly GLEAN_PARSER_COMMIT='d87316dd8ce2fa0122d8634660bb71397c2d5820'
readonly GLEAN_PARSER_SHA512SUM='acb6ba017549fe26b0b9af77fea98421509580d8c734adaf6de700e6abd24c7bb3c8a708ec2f8b5793c294dc74d0af09ce53d6042d1814baf4c50afd30bc7cef'
readonly GLEAN_PARSER_VERSION='19.0.0'

## microG
### Version: v0.3.15.250932
### https://github.com/microg/GmsCore
readonly GMSCORE_COMMIT='352f2d72fa52c6c3c4fdd79d575a071a0da72ad1'
readonly GMSCORE_SHA512SUM='da38003f346cb7e86ce7bca89316e0c1d7c760b9312dd9505e63e0f6ef652563da102960e657cd37341d59d6ea00094a57837137d6835bafefe3c59d0839d4e9'

## Phoenix
### Version: 2026.06.10.1
### https://gitlab.com/celenityy/Phoenix
readonly PHOENIX_COMMIT='d3cc0d78b3533d409e181c8c0fec6964c835cf54'
readonly PHOENIX_SHA512SUM='c810c41554420f7d52f9680a281b1c72c79940e6cbb122f7d36d5501e101fcb68eb146f3ec2865e8d15a5a5fdc00817c5af8f248406a1a4ec1dfa0f7ac96f296'
readonly PHOENIX_VERSION='2026.06.10.1'

## uniffi-rs (Tor)
### https://gitlab.torproject.org/tpo/applications/uniffi-rs
readonly UNIFFI_VERSION='0.31.0'

## UnifiedPush-AC
### Version: 1.0.4
### https://gitlab.com/ironfox-oss/unifiedpush-ac
readonly UNIFIEDPUSHAC_COMMIT='217e9393aecacf4a0eece06d18cd168644413b36'
readonly UNIFIEDPUSHAC_SHA512SUM='ca8fd4e77293aeb2ed90dbf78cec3c173f35f1e4a3880ff046556ec13ee3df0765be0c5eec3cb6f4b0c881feeb02fd81a6a28b12f6d032719a8c523aab4a80e3'

## WASI SDK
### https://github.com/WebAssembly/wasi-sdk
readonly WASI_VERSION='20'

# Tools

## androguard
### Version: v4.1.4
### https://github.com/androguard/androguard
readonly ANDROGUARD_COMMIT='d594fd39beb934e438a5bf8089b206d5800d81e0'
readonly ANDROGUARD_SHA512SUM='d167b3ca58c073758bd478e68a92f6efe9cc93e14ac4abf52cdadc4917319bdd2fe24ae8c3ba9a584b746ce349247ac853eb7e77eb1125c6a870a199c2b756f2'

## Android NDK
### Version: 29.0.14206865 (r29)
### https://developer.android.com/ndk/downloads
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android.py)
readonly ANDROID_NDK_REVISION='29.0.14206865'
readonly ANDROID_NDK_SHA512SUM_LINUX='b55819895a7fa3a0bc7ed411fb55ed15ad9e415b0122a81a4e026c9b696cd266cb4beebb2008cf1d6cac88d38187d52818734f87de793de303653eccb4ca68da'
readonly ANDROID_NDK_SHA512SUM_OSX='4091bc97a03266b869380874cb2d67a35dc74f9bc5f1cde30a3545547355e4ec4f3ebd79a17a19f9228d045f7a176d1e987ce4f787d81a02a044aa909f5ef5cb'
readonly ANDROID_NDK_VERSION='r29'

## Android SDK (Command-Line Tools)
### Version: 20.0 (14742923)
### https://developer.android.com/tools/releases/cmdline-tools
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android.py
### + https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_REVISION='14742923'
readonly ANDROID_SDK_VERSION='20.0'
readonly ANDROID_SDK_SHA512SUM_LINUX='b65e830d7655fb39cc9eee669806977f462c49375807ef2c6487fabcc9afdbc210465ce6a1e2429ff95c74ca519d1239daf9a403c30b8d0bdb7a0962af656c8e'
readonly ANDROID_SDK_SHA512SUM_OSX='20fc87470d1850ecbaf254509caca1b45055d72d3d78c9079adbe97ff7754018979a548f0cf145e52f03afd65357a5653f556db15ba569bffd4a143202cca0f8'

## Android SDK Build Tools
### Version: 37.0.0
### https://developer.android.com/tools/releases/build-tools
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_BUILD_TOOLS_VERSION='r37'
readonly ANDROID_SDK_BUILD_TOOLS_VERSION_STRING='37.0.0'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX='0c1735b91da1088d824243bef3f5c070ee4d0b9ccc50d2c20d0c5afdeab41a0fd71f785b98d60579091bb48d1a703f9f5ea6775bab4781de51a9df570b9dba98'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX='b3600aee0148835d7074748d5b6b2d56852e73a7f0081956def0d22e21170514bc0984c5dd4a4ed746eed5476e90dac042aeae571954745fbf2d6a239aa51a5e'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX='b45dc6b7298567f3b45428def0b85584b99b125a3719dfb74a82732bf2b86a0c66161682f3c3d7a50cefaf6e1a2d993975665272e16f00b231a15a9a4512cc1e'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX='991db0bbf23acd212b6be57033cdb3ecd5c8c8da79781a6e4326c046c2079b2827892084ee5f77b1fc5d5ef91fc62a4820d43218d3943f0c43e5c093c58c4999'

## Android SDK Platform
### Version: 37.0
### https://developer.android.com/tools/releases/platforms
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_PLATFORM_VERSION='37.0'

## Android SDK Platform Tools
### Version: 37.0.0
### https://developer.android.com/tools/releases/platform-tools
readonly ANDROID_SDK_PLATFORM_TOOLS_VERSION='37.0.0'
readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX='9c5589319d3668ec0dcce0dbcd9fbd0f8c49e59f9004604f9d501ea626972e099579bfff202bf9a0586083e0fdd6f4f5d566a41fc33bf1702a862403e0fdfd38'
readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX='a093db8388d4b8a212476c014eedb2b3d757d57dcc5b25ca3e38d556562129e5e6be264f8b9d8409df909f894f055cc7eb9ce27fa6de041a34f9419f247bb950'

### This is used for setting microG's compile SDK version
readonly MICROG_ANDROID_SDK_COMPILE_VERSION='36'

### This is used for ex. setting microG's target SDK version
readonly ANDROID_SDK_TARGET='37'

## Bundletool
### Version: 1.18.3
### https://github.com/google/bundletool
readonly BUNDLETOOL_REPO_COMMIT='586a43a450712a1067f3d92cf7574dee68226302'
readonly BUNDLETOOL_REPO_SHA512SUM='a72040449b3bd51a29bb562d8686b0338d630be12a5a590a88a753111b887d30f7b32ab256a556157271ed0071fc54b81205efcfd1ef93ccb8142fe41a741345'
readonly BUNDLETOOL_SHA512SUM='50feda5f3f00931bad943a37b7cfc33d8ea53b33bd9bfa83832f612da6e99b72146206695ae25df5044030e305e1d718c833ad51c12b944079c263bba3cbffa0'
readonly BUNDLETOOL_VERSION='1.18.3'

## cbindgen
### Version: v0.29.3
### https://github.com/mozilla/cbindgen
readonly CBINDGEN_COMMIT='b5f2a978302e86fa06659a945a26c1b8b9aa9b8d'
readonly CBINDGEN_SHA512SUM='f89a6887a1f4e0c7ef57247577b7be8eac4159843ff9cccf917d14af03d41ad005d25ca1f4dbf70e61cdd50d268ac1f5b2b0125488f564f175fe8a0a5c121d7f'
readonly CBINDGEN_VERSION='0.29.3'

## Gradle (F-Droid)
### https://gitlab.com/fdroid/gradlew-fdroid
readonly GRADLE_COMMIT='9f31b7ee881e46a5d7d234406c14e5e474bc5fc4'
readonly GRADLE_SHA512SUM='58ddb0a3c5e015ad3f2658729941a76cb84271248265642a7b800e12c13abb5004641be6574b7dde787850cb321c4de2322b2dbef26f1057f1778166bb947210'

## GYP
### Version: v0.22.2
### https://github.com/nodejs/gyp-next
readonly GYP_COMMIT='6a2e12fdc30b521d11f781f986390525a54398bf'
readonly GYP_SHA512SUM='b266341d794354a8816668971bcee8a5d555c82fb3164fd59d89a6c7774e4a123e78786341d4c22d6210ac10d5efb8bd39c27e9462b66b9e47e31d19c6d53335'

## JDK 25 (Temurin)
### Version: 25.0.3+9
### https://github.com/adoptium/temurin25-binaries
readonly JDK_25_REVISION='9'
readonly JDK_25_SHA512SUM_LINUX_ARM64='5720a23247087c7bb61bc9939143466f333fc256c91c401d12022c6f86806a2bf7f6f7d973183cdb0b963ceb86ae0644806f2b91ce6af279c1b9e341d88f5a0d'
readonly JDK_25_SHA512SUM_LINUX_X86_64='b40b97de14d0df0eece463388a605cf572d5e0e10a839d3bf2f85658ace607a66365681f19e22486c72662e3343c71cf0ccbbb570730c321dff12b0c24c0bbae'
readonly JDK_25_SHA512SUM_OSX_ARM64='5f87288c111a286a4d945fb337ae11af95cabd8a0be94f110215a4d4eb4970ab38bd8619ae780a37b2a354b613a9cc31301cde5c520d687f28c6a62b99ac0584'
readonly JDK_25_SHA512SUM_OSX_X86_64='6726ce00765fda7441adf355d266b0c00a00bc9b5d03f9d823dd84b4b7bf36957df3e725b385af10e0dcc9008a85146711479f17f45ba533f8c9518c010e5212'
readonly JDK_25_VERSION='25.0.3'

## JDK 21 (Temurin)
### Version: 21.0.11+10
### https://github.com/adoptium/temurin21-binaries
readonly JDK_21_REVISION='10'
readonly JDK_21_SHA512SUM_LINUX_ARM64='595115ab59958f9c62600f5af5286da498d6e2d9742e34be59899d0b03add9a8d5b667625b81ccbf5a905a33ea734e8dae690a42bae1b9ceb2cf0cedf30201fd'
readonly JDK_21_SHA512SUM_LINUX_X86_64='e8293b3b4e9d55bd13271dd364637a9b19b6e677f4b4384eb6e7583d5c1270fcb183b81cb857e3162cf7ab584bed7cd4ad42d833e218b1223c3ab42b98f2266a'
readonly JDK_21_SHA512SUM_OSX_ARM64='524ea7fc0f544f0804824b776d5d61250168f0f6ef3d860fc6b1bc150a02bb741001ae932a2875f3d6385262fcfe1a4e7ed29bcacc0b5627668df29983b650b5'
readonly JDK_21_SHA512SUM_OSX_X86_64='2cb90849fd2b1f6b77283537aa98d35adde62ad5789c738316abfb2fd427627e7bc8fb739f5d49262173c9631166fa65de1cce75a017877197333b0a458010d2'
readonly JDK_21_VERSION='21.0.11'

## JDK 17 (Temurin)
### Version: 17.0.19+10
### https://github.com/adoptium/temurin17-binaries
### (Required by GeckoView)
readonly JDK_17_REVISION='10'
readonly JDK_17_SHA512SUM_LINUX_ARM64='c72400ca721fa0cfe5c40b928c6b091895cf2c1abf3c9a7d5ed3f3ca2bc899bd9e2dab79de80f068032b503e12509a20f0f67248369f0a77313cd14e719ea43a'
readonly JDK_17_SHA512SUM_LINUX_X86_64='61701218400ec0d64bc624c1a977009bbf3de26cc7f81d2c033e1492d85525d5e00c19800d075980a2e51b8b78f30b4792e71dd9dd6a9763d0582cac6c666d77'
readonly JDK_17_SHA512SUM_OSX_ARM64='41666c70b771693ca5ceb0c7b6bf193f4abe95e98e6311c3baa2cc1cf5d98efd56b3c5eff6401664bcf057bad11f0cf59de5e3d8f27c62afe7d01814e0e21260'
readonly JDK_17_SHA512SUM_OSX_X86_64='c871deedc3ccf0663aa584610c1390d1ae2fac2d472bb1ace111e65fd461b17ef0adf27ad948523be37c40091f717bb5091375b94acfa0a87e12d54055d6d279'
readonly JDK_17_VERSION='17.0.19'

## Node.js
### Version: 26.3.0
### https://nodejs.org/about/previous-releases
### (Used by nvm)
readonly NODE_VERSION='26.3.0'

## npm
### Version: 11.17.0
### https://github.com/npm/cli
readonly NPM_SHA512SUM='3eeaf18997b11070d313849268b23766b9db0068997dec9471073170fe43fa17f2b4d0337bf0f52330ee2274e7f5754b21b01052742e48f5c9c74d8b1e32ef43'
readonly NPM_VERSION='11.17.0'

## nvm
### Version: v0.40.5
### https://github.com/nvm-sh/nvm
readonly NVM_COMMIT='1889911f0841e669de0be5bd02c737a3f1fd20fa'
readonly NVM_SHA512SUM='995a6d63ad26294d272910d6bc08851ded1989713ade1051819da4659dbb6285874a12b56d13cb79bf61d3e2c616077e2433747971d85b552ccdb4253062fd40'

## pip
### Version: 26.1.2
### https://github.com/pypa/pip
readonly PIP_COMMIT='31d7d168953668aad85154d6121879d07fbeac27'
readonly PIP_SHA512SUM='df5dfd2b6206cfd6d1c786cb91dd30f08e3e381c3f15c7357174959fa59d7f1cbe8d28415f605d78268a0a60a00d82115efe423f2fe8f53bb246251b05505273'

## Python
### Version: 20260610 (3.14.6)
### https://github.com/astral-sh/python-build-standalone
readonly PYTHON_GIT_RELEASE='20260610'
readonly PYTHON_SHA512SUM_LINUX_ARM64='3b5ec16f521278b0b9932c14c9dc2d3213daf09e929c5eaaed04343078c760a5d82f552933a3289a8680e0c969b87947109c1437ea29270990b899cb823c2bd3'
readonly PYTHON_SHA512SUM_LINUX_X86_64='5b130b97cae14a36fdb00aa672a14b0df9dfd4cceb326c5f43444e9c66401b65cb05d54b4efd6503139e2852ea60ed6ff5cbef8d2ea09328f451cdaac3f1945c'
readonly PYTHON_SHA512SUM_OSX_ARM64='9660802577ad6c032c52e416719631f25edf748c9d2a4271bea16e9d96cbe3df906cc897ef8f7a54074e9ecf466f04670d28761b2a71af3b937241e0eb7ce6ab'
readonly PYTHON_SHA512SUM_OSX_X86_64='a1e6312168c9439c0f99161fd2091e35b1bb31fcf41cf36330780000a951980e6f75678e0b095aac3b16e83fd09591027dd2597640bb34a1751d850a194269a0'
readonly PYTHON_VERSION='3.14.6'

## PyYAML
### Version: 6.0.3
### https://github.com/yaml/pyyaml
readonly PYYAML_COMMIT='49790e73684bebad1df05ef8d828fa12f685bffb'
readonly PYYAML_SHA512SUM='2fd1334af2722c093592f93a5eee01d0b2e26976a12cb2e4859b4271a8fa47ff257d10c91b09bdb2b5aa9415b62693a69d6e6602e997c2bff6711aa02bf43937'

## Rust
### Version: 1.96.0
### https://releases.rs/
readonly RUST_VERSION='1.96.0'

## rustup
### Version: 1.29.0
### https://github.com/rust-lang/rustup/tags
readonly RUSTUP_COMMIT='28d1352dbcb436d3111c3594b9e1588e94950464'
readonly RUSTUP_SHA512SUM='cd9fd64eabc989f19a6a16e9cd2caabe935082e2715b9308150f86d3839c99eb9a7e42a7ef6730c6d956d870638ee89a04dd9e7e14fe243cc165967b7f2918da'
readonly RUSTUP_VERSION='1.29.0'

## s3cmd
### https://github.com/s3tools/s3cmd
readonly S3CMD_COMMIT='cee84f9c539a7bbf5ee73c7bf29a47632119c0c6'
readonly S3CMD_SHA512SUM='b1b7c792265dfa1ccdd40f816e3463617c168e4317acac930b251ce73fcd3b8eb479d966d4ba93fbe8c0cf251bada64bcd9caf30d1e5e94c20a87a36447c1263'

## uv
### Version: 0.11.23
### https://github.com/astral-sh/uv
readonly UV_SHA512SUM_LINUX_ARM64='130fe955bb0e71272fd43ec88dd5f89c9b74d6f896bcbec972f9fb04ef60f061e2740495e984b6e176f344c6276979fb96bb0ae53bfa9e8c56b6f5c85aa2f102'
readonly UV_SHA512SUM_LINUX_X86_64='d923598f0699e7536050c7b5a7f4ea6d690c5b1c03dfa726409a977b719e80ed0948d8aa37fc0887914fe26dd55859cce14936b010ee2d1ee4bca42c10ec51cc'
readonly UV_SHA512SUM_OSX_ARM64='2a49950b3ce874adce897624b837099bf876c408c3b07891637632a2899e4ce9c3e45c801f27bdaf7c0f0547ab9049d2ac0af1b6d92c214895e6574b3d0d8bae'
readonly UV_SHA512SUM_OSX_X86_64='0ad500f4614d660753d8f2b40cd8562b52e5fefd70b79f826e9c81bccfd9a2a13039761edffcd79ab4a79d7d9f38391855461f274c4c049cebdb6a8855109196'
readonly UV_VERSION='0.11.23'

# For prebuilds
## https://gitlab.com/ironfox-oss/prebuilds
readonly PREBUILDS_COMMIT='c4e26779a2e270fdc9cbf1ebdf553390110812f2'
readonly PREBUILDS_SHA512SUM='c58868a5fd92dd349d74bc37f123842f503f32d4c94fa894f56a9f534783bd6c69ed5230b042d644927cfc67963ffcf0e5d146c5602ecf683a53557414d371fe'

## uniffi-bindgen (Linux)
### Version: 9
readonly UNIFFI_LINUX_IRONFOX_COMMIT='c4e26779a2e270fdc9cbf1ebdf553390110812f2'
readonly UNIFFI_LINUX_IRONFOX_REVISION='9'
readonly UNIFFI_LINUX_IRONFOX_SHA512SUM='b5f3457659f276c464d4e9ba6953f175d48c98f6b6f612a68e2f3625989e1961cf336538165bc046d52cb3db223e6739186a8ea80218bcd48390175990c48880'

## uniffi-bindgen (OS X)
### Version: 9
readonly UNIFFI_OSX_IRONFOX_COMMIT='2923784a8fba97fb21a2998c8a7f729ae97621f6'
readonly UNIFFI_OSX_IRONFOX_REVISION='9'
readonly UNIFFI_OSX_IRONFOX_SHA512SUM='feadd643d650c849667ea7ad70974538f6b84d7d7f779b7ba40137a95520e6b10573706f1206f09ed44591a80f41144bdb360a5aeb298d8ce53969dbd20c3d5d'

## WASI SDK (Linux)
### Version: 4
readonly WASI_LINUX_IRONFOX_COMMIT='b76a3b2a8f3124e9297036e3b27802a47c0263a4'
readonly WASI_LINUX_IRONFOX_REVISION='4'
readonly WASI_LINUX_IRONFOX_SHA512SUM='98d81e0f47229184fe767fb47906685eec6dd34ad425030e08d1eea42ddec1ebef678530e70dfc954aa2d0904ac44d38a869334c098b0baf9fff1b87233ff31e'

## WASI SDK (OS X)
### Version: 3
readonly WASI_OSX_IRONFOX_COMMIT='97f5fb17ea756670c452e832ae3fca80d0498a82'
readonly WASI_OSX_IRONFOX_REVISION='3'
readonly WASI_OSX_IRONFOX_SHA512SUM='eb0697f42c9838080fcf23fa0d9c230016212a15725e62e2fafed896751a9fcf8adf508461cf9118c02bff1bcd0791ae1113f13d0cca96de3b8f03244df25a30'
