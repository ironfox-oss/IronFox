
# Sources

## Firefox
### https://github.com/mozilla-firefox/firefox
### (This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_150_0_3_RELEASE)
readonly FIREFOX_COMMIT='a077abc2b0f43ed7cc59a8bfcd873e683500d23a'
readonly FIREFOX_SHA512SUM='59a7efd87cd66fb5cafa3d3ca45f94b0388c14e22a6f40cd608729bf6ed1d557c0a67ba6958735eff0c316bd145040161a476a226967d4f1f9f884831f8e829d'
readonly FIREFOX_VERSION='150.0.3'

readonly IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### https://github.com/mozilla/application-services
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/mobile/android/android-components/plugins/dependencies/src/main/java/ApplicationServices.kt)
readonly APPSERVICES_COMMIT='28e78b69f083c6879f39966dd58e58c2ea5db3d5'
readonly APPSERVICES_SHA512SUM='4e0bc24afde9f311b124e325c2c6cbcd22f3479e2504e29c8cdc91366736e74def9af8c853d6fcb1eba36be7e16eda9e1e9af6392748c514e3c01bc2e26ff076'
readonly APPSERVICES_VERSION='150.0.1'

## firefox-l10n
### https://github.com/mozilla-l10n/firefox-l10n
### NOTE: This repo is updated several times a day...
### so I think best approach here will be for us to just update it alongside new releases
readonly L10N_COMMIT='4db52ae666a85fcf69b98aadcb38bc1917b93dc0'
readonly L10N_SHA512SUM='5499dcec38e1cfc784da5665a32fdadcaebd753585bb808fe132e278c36b254925ab3d52d4084158ff385d00faa798eeea12a356a855cf65f304c648478bb80e'

## Glean
### https://github.com/mozilla/glean
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/gradle/libs.versions.toml)
readonly GLEAN_COMMIT='667af08fa308ff8924ab9cd95f05d7887758c330'
readonly GLEAN_SHA512SUM='a60da8666c7c3187b3602b5da0c74315f73f534e13cc6faa41b1f63909af97cc474bac5a92f4549ede90dba5c1acea11ae6c41526638283fe2e84b103946ed6b'
readonly GLEAN_VERSION='67.1.0'

## Glean Parser
### Version: v18.2.0
### https://github.com/mozilla/glean_parser
readonly GLEAN_PARSER_COMMIT='39c9b070d429983db233e7435ae7dfe69f48a543'
readonly GLEAN_PARSER_SHA512SUM='3c856424aef82f1d793e7b2ed78df175e4bb445dc05e8a0b75752a6ed2aa1cbc097d0f355e13bf6f5b5aec9f3d53df53a23763c51f4a3747b57b80d45d37033d'
readonly GLEAN_PARSER_VERSION='18.2.0'

## GYP
### Version: v0.22.1
### https://github.com/nodejs/gyp-next
readonly GYP_COMMIT='91c8e14b561ed375dcdc3951e271c84f635eddb7'
readonly GYP_SHA512SUM='87e54e9e8f6a585438f2f24105c342d7809e29780c972082684df05ffc65fd7815d9f72ecbbe9e71c7e81399be1d46a7306fd650e97b59f6e067bea7eaaa3e70'

## microG
### Version: v0.3.15.250932
### https://github.com/microg/GmsCore
readonly GMSCORE_COMMIT='352f2d72fa52c6c3c4fdd79d575a071a0da72ad1'
readonly GMSCORE_SHA512SUM='da38003f346cb7e86ce7bca89316e0c1d7c760b9312dd9505e63e0f6ef652563da102960e657cd37341d59d6ea00094a57837137d6835bafefe3c59d0839d4e9'

## Phoenix
### https://gitlab.com/celenityy/Phoenix
readonly PHOENIX_COMMIT='9ad10b5e54831a97a9c01cde09ea2351706d19dc'
readonly PHOENIX_SHA512SUM='aaa70de11014e4e24e4787a6e9e000739c0266f30f3766f0ef86196e5f04b1e335921dff8d16b9ccce52f6f0c9c24f9b85d994dfd78f4aa20a31f279906933b7'
readonly PHOENIX_VERSION='2026.04.27.1'

## uniffi-rs (Tor)
### https://gitlab.torproject.org/tpo/applications/uniffi-rs
readonly UNIFFI_VERSION='0.31.0'

## UnifiedPush-AC
### Version: 1.0.2
### https://gitlab.com/ironfox-oss/unifiedpush-ac
readonly UNIFIEDPUSHAC_COMMIT='31b4fdfdfa8aeb7e7c93f405a351438ffe82fff6'
readonly UNIFIEDPUSHAC_SHA512SUM='1a3fb43e137268db7bdd1b0d2bcd5149b795c63e4ab0225dab7f5a7928bda306b4f09a502da56f70f8f84f1e5aaf8f3ffe8256ffc54ce100904af3d7204f779e'

## WASI SDK
### https://github.com/WebAssembly/wasi-sdk
readonly WASI_VERSION='20'

# Tools

## androguard
### https://github.com/androguard/androguard
readonly ANDROGUARD_COMMIT='dd458bead6165975c3ef0b1b78eaf2450e4889d9'
readonly ANDROGUARD_SHA512SUM='b277363110c1984b43cb99b59685849551b7e5ec66c7a9783ea06ac4324d558094ee7e840695bada51d01fa690df34c0d02417001ddf087bec30adc205270166'

## Android NDK
### https://developer.android.com/ndk/downloads
readonly ANDROID_NDK_REVISION='29.0.14206865'
readonly ANDROID_NDK_SHA512SUM_LINUX='b55819895a7fa3a0bc7ed411fb55ed15ad9e415b0122a81a4e026c9b696cd266cb4beebb2008cf1d6cac88d38187d52818734f87de793de303653eccb4ca68da'
readonly ANDROID_NDK_SHA512SUM_OSX='4091bc97a03266b869380874cb2d67a35dc74f9bc5f1cde30a3545547355e4ec4f3ebd79a17a19f9228d045f7a176d1e987ce4f787d81a02a044aa909f5ef5cb'
readonly ANDROID_NDK_VERSION='r29'

## Android SDK (Command-Line Tools)
### https://developer.android.com/tools/releases/cmdline-tools
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android.py
### + https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_REVISION='14742923'
readonly ANDROID_SDK_SHA512SUM_LINUX='b65e830d7655fb39cc9eee669806977f462c49375807ef2c6487fabcc9afdbc210465ce6a1e2429ff95c74ca519d1239daf9a403c30b8d0bdb7a0962af656c8e'
readonly ANDROID_SDK_SHA512SUM_OSX='20fc87470d1850ecbaf254509caca1b45055d72d3d78c9079adbe97ff7754018979a548f0cf145e52f03afd65357a5653f556db15ba569bffd4a143202cca0f8'

## Android SDK Build Tools
### https://developer.android.com/tools/releases/build-tools
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_BUILD_TOOLS_VERSION='r36.1'
readonly ANDROID_SDK_BUILD_TOOLS_VERSION_STRING='36.1.0'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX='32a1eea273980a96745ae5e0b141720e5f91c6c6f83f42da4244fad36025d7750521fdf678a7d332afe5946057b498264343c2533ba524967d84347af9cd7ce5'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX='07a78d5f4658c6809220012fc27560cfd8aefcbd29a6414aa309fc54d6df7751b7b1e59964e3942ff9b91030c2611639e2b7d7eb2f77aba1ab0933c015e7c802'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX='b45dc6b7298567f3b45428def0b85584b99b125a3719dfb74a82732bf2b86a0c66161682f3c3d7a50cefaf6e1a2d993975665272e16f00b231a15a9a4512cc1e'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX='991db0bbf23acd212b6be57033cdb3ecd5c8c8da79781a6e4326c046c2079b2827892084ee5f77b1fc5d5ef91fc62a4820d43218d3943f0c43e5c093c58c4999'

## Android SDK Platform
### https://developer.android.com/tools/releases/platforms
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_PLATFORM_VERSION='36.1'

## Android SDK Platform Tools
### https://developer.android.com/tools/releases/platform-tools
readonly ANDROID_SDK_PLATFORM_TOOLS_VERSION='36.0.2'
readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX='e7a024df013af813157794054a203506dfc7dc776479b82bb83e5ba8a538e8a749b662bf3e05a3822c77dfca9aa221c4ae67e69921f8dfc78fee7acc5bb4e63f'
readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX='1fefcd4ef10740bfbf1e46c4968d879c621315f7616c8eaecd297b3c89af2007a59a1c18f8a89afbd1afeeb9989c2eeb0d3f189e3502e42e62b76c79d69b7385'

### This is used for ex. setting microG's compile SDK and target SDK version
readonly ANDROID_SDK_TARGET='36'

## Bundletool
### https://github.com/google/bundletool
### (This commit corresponds to https://github.com/google/bundletool/releases/tag/1.18.3)
readonly BUNDLETOOL_REPO_COMMIT='586a43a450712a1067f3d92cf7574dee68226302'
readonly BUNDLETOOL_REPO_SHA512SUM='a72040449b3bd51a29bb562d8686b0338d630be12a5a590a88a753111b887d30f7b32ab256a556157271ed0071fc54b81205efcfd1ef93ccb8142fe41a741345'
readonly BUNDLETOOL_SHA512SUM='50feda5f3f00931bad943a37b7cfc33d8ea53b33bd9bfa83832f612da6e99b72146206695ae25df5044030e305e1d718c833ad51c12b944079c263bba3cbffa0'
readonly BUNDLETOOL_VERSION='1.18.3'

## cbindgen
### https://docs.rs/crate/cbindgen/latest
### (This commit corresponds to https://github.com/mozilla/cbindgen/releases/tag/v0.29.2)
readonly CBINDGEN_COMMIT='76f41c090c0587d940a0ef81a41c8b995f074926'
readonly CBINDGEN_SHA512SUM='8363f69fc103343acc2b2545d833df6da876c8591f664b0f7ce6ebac28ce516e72cc615df4d2c07b93c646ed122b8a48c4a34b03c363d2d795c3013321c3fc5c'
readonly CBINDGEN_VERSION='0.29.2'

## Gradle (F-Droid)
### https://gitlab.com/fdroid/gradlew-fdroid
readonly GRADLE_COMMIT='996b7829f40f33317d33c1b6ddcffcf976bd6181'
readonly GRADLE_SHA512SUM='0498fff4a729aa2458f2627635507c6e9a9bd3d1e914ac375e10b3b3061654e7f7544461c91a8db0882bfc1d09090d135eada40ee72f37ff9975e0f1116c3d9d'

## JDK 25 (Temurin)
### https://github.com/adoptium/temurin25-binaries
### (This commit corresponds to https://github.com/adoptium/temurin25-binaries/releases/tag/jdk-25.0.3%2B9)
readonly JDK_25_REVISION='9'
readonly JDK_25_SHA512SUM_LINUX_ARM64='5720a23247087c7bb61bc9939143466f333fc256c91c401d12022c6f86806a2bf7f6f7d973183cdb0b963ceb86ae0644806f2b91ce6af279c1b9e341d88f5a0d'
readonly JDK_25_SHA512SUM_LINUX_X86_64='b40b97de14d0df0eece463388a605cf572d5e0e10a839d3bf2f85658ace607a66365681f19e22486c72662e3343c71cf0ccbbb570730c321dff12b0c24c0bbae'
readonly JDK_25_SHA512SUM_OSX_ARM64='5f87288c111a286a4d945fb337ae11af95cabd8a0be94f110215a4d4eb4970ab38bd8619ae780a37b2a354b613a9cc31301cde5c520d687f28c6a62b99ac0584'
readonly JDK_25_SHA512SUM_OSX_X86_64='6726ce00765fda7441adf355d266b0c00a00bc9b5d03f9d823dd84b4b7bf36957df3e725b385af10e0dcc9008a85146711479f17f45ba533f8c9518c010e5212'
readonly JDK_25_VERSION='25.0.3'

## JDK 21 (Temurin)
### https://github.com/adoptium/temurin21-binaries
### (This commit corresponds to https://github.com/adoptium/temurin21-binaries/releases/tag/jdk-21.0.11%2B10)
readonly JDK_21_REVISION='10'
readonly JDK_21_SHA512SUM_LINUX_ARM64='595115ab59958f9c62600f5af5286da498d6e2d9742e34be59899d0b03add9a8d5b667625b81ccbf5a905a33ea734e8dae690a42bae1b9ceb2cf0cedf30201fd'
readonly JDK_21_SHA512SUM_LINUX_X86_64='e8293b3b4e9d55bd13271dd364637a9b19b6e677f4b4384eb6e7583d5c1270fcb183b81cb857e3162cf7ab584bed7cd4ad42d833e218b1223c3ab42b98f2266a'
readonly JDK_21_SHA512SUM_OSX_ARM64='524ea7fc0f544f0804824b776d5d61250168f0f6ef3d860fc6b1bc150a02bb741001ae932a2875f3d6385262fcfe1a4e7ed29bcacc0b5627668df29983b650b5'
readonly JDK_21_SHA512SUM_OSX_X86_64='2cb90849fd2b1f6b77283537aa98d35adde62ad5789c738316abfb2fd427627e7bc8fb739f5d49262173c9631166fa65de1cce75a017877197333b0a458010d2'
readonly JDK_21_VERSION='21.0.11'

## JDK 17 (Temurin)
### https://github.com/adoptium/temurin17-binaries
### (This commit corresponds to https://github.com/adoptium/temurin17-binaries/releases/tag/jdk-17.0.19%2B10)
### (Required by GeckoView)
readonly JDK_17_REVISION='10'
readonly JDK_17_SHA512SUM_LINUX_ARM64='c72400ca721fa0cfe5c40b928c6b091895cf2c1abf3c9a7d5ed3f3ca2bc899bd9e2dab79de80f068032b503e12509a20f0f67248369f0a77313cd14e719ea43a'
readonly JDK_17_SHA512SUM_LINUX_X86_64='61701218400ec0d64bc624c1a977009bbf3de26cc7f81d2c033e1492d85525d5e00c19800d075980a2e51b8b78f30b4792e71dd9dd6a9763d0582cac6c666d77'
readonly JDK_17_SHA512SUM_OSX_ARM64='41666c70b771693ca5ceb0c7b6bf193f4abe95e98e6311c3baa2cc1cf5d98efd56b3c5eff6401664bcf057bad11f0cf59de5e3d8f27c62afe7d01814e0e21260'
readonly JDK_17_SHA512SUM_OSX_X86_64='c871deedc3ccf0663aa584610c1390d1ae2fac2d472bb1ace111e65fd461b17ef0adf27ad948523be37c40091f717bb5091375b94acfa0a87e12d54055d6d279'
readonly JDK_17_VERSION='17.0.19'

## Node.js
### https://nodejs.org/about/previous-releases
### (Used by nvm)
readonly NODE_VERSION='26.1.0'

## npm
### https://github.com/npm/cli
readonly NPM_SHA512SUM='6a8a4d67478497a2dbc6815cad72e64c43f33413717e242756047d466241ab39bee61e691683a64658e94496ec5f1a1c05e4a5ec62dcc773280dfd949443a367'
readonly NPM_VERSION='11.14.1'

## nvm
### Version: v0.40.4
### https://github.com/nvm-sh/nvm
readonly NVM_COMMIT='62387b8f92aa012d48202747fd75c40850e5e261'
readonly NVM_SHA512SUM='7b88477aa7400050cea6dda3cd197dad7d030fd951cd9aca945c04159fdb98ea3bbdda8a2b1c0761d1cd5d3893c669370b493727298f3b8440f97452fd229abc'

## pip
### Version: 26.1.1
### https://github.com/pypa/pip
### (This commit corresponds to https://github.com/pypa/pip/releases/tag/26.1.1)
readonly PIP_COMMIT='4432a371c6471e6a93c3eb39b3e9ab2b876b13b9'
readonly PIP_SHA512SUM='495e78520f7c903c336ce2a0a5f3e0aba0f2871e8d0c7492201d79fba22952554c3d361539bf7d656f2b6524ea11b8b263b78a5756bf2e69eecc35c1f5aeb379'

## Python
### https://github.com/astral-sh/python-build-standalone
readonly PYTHON_GIT_RELEASE='20260510'
readonly PYTHON_SHA512SUM_LINUX_ARM64='2b63d6cd1aa82c3329b93c771e46028c311b0d8b9ddb24d72e58566d3729d15aedea3f5794e878febe9378b6b83d9084f104a6f11c962a4770e7a01bbb350280'
readonly PYTHON_SHA512SUM_LINUX_X86_64='04e04c763fe103822627e4da29015c7c6976c836573ead03a7ed1e1a7eea053ba5c8a4119fd568f3f41ff45ef1614fae40f0de87bead4756d8922bc03bb24146'
readonly PYTHON_SHA512SUM_OSX_ARM64='f9a64cfbc8706b7f6d22a463879b27086ff929350a69c47917f8e3cd9185e8fbd219fe1b368de79a90895f0fe55636f7a0c49cac03f2c40943388c792e7afe9b'
readonly PYTHON_SHA512SUM_OSX_X86_64='28d38843ee3be61a4bdcac150a8b3512d75911fd6869bd4196a677240b10ec60d11dec2a93c106f3a7e9659920e092056b7eb977b0926435193c1e76b593d131'
readonly PYTHON_VERSION='3.14.5'

## PyYAML
### Version: 6.0.3
### https://github.com/yaml/pyyaml
### (This commit corresponds to https://github.com/yaml/pyyaml/releases/tag/6.0.3)
readonly PYYAML_COMMIT='49790e73684bebad1df05ef8d828fa12f685bffb'
readonly PYYAML_SHA512SUM='2fd1334af2722c093592f93a5eee01d0b2e26976a12cb2e4859b4271a8fa47ff257d10c91b09bdb2b5aa9415b62693a69d6e6602e997c2bff6711aa02bf43937'

## Rust
### https://releases.rs/
readonly RUST_MAJOR_VERSION='1.95'
readonly RUST_VERSION="${RUST_MAJOR_VERSION}.0"
#readonly RUST_MAJOR_VERSION='1.94.1'
#readonly RUST_VERSION="${RUST_MAJOR_VERSION}"

## rustup
### https://github.com/rust-lang/rustup/tags
readonly RUSTUP_COMMIT='28d1352dbcb436d3111c3594b9e1588e94950464'
readonly RUSTUP_SHA512SUM='cd9fd64eabc989f19a6a16e9cd2caabe935082e2715b9308150f86d3839c99eb9a7e42a7ef6730c6d956d870638ee89a04dd9e7e14fe243cc165967b7f2918da'
readonly RUSTUP_VERSION='1.29.0'

## s3cmd
### https://github.com/s3tools/s3cmd
readonly S3CMD_COMMIT='cee84f9c539a7bbf5ee73c7bf29a47632119c0c6'
readonly S3CMD_SHA512SUM='b1b7c792265dfa1ccdd40f816e3463617c168e4317acac930b251ce73fcd3b8eb479d966d4ba93fbe8c0cf251bada64bcd9caf30d1e5e94c20a87a36447c1263'

## uv
### https://github.com/astral-sh/uv
readonly UV_SHA512SUM_LINUX_ARM64='6f9924ae6570a49fe731db9c8cc8ea61be0e3142b6edb33e66407eeb76a44ad0b3930e6844c7d3699fcbc37232a989baddaf47c1facc4696300b939d71948e30'
readonly UV_SHA512SUM_LINUX_X86_64='340c3a71956b21cf8acc45f63065515b87ba37f90991b82dc913ec080a5b49a49e79367ab4a65c775cd5869b78986e2b90c9075ccd0395689fb20174169d87d2'
readonly UV_SHA512SUM_OSX_ARM64='2d39ddc46f98ce299708cae6099b7c1403576a4ef3745f915f37ec28fb3578ad22368f31a505bf0fbb3e8e8e0fd46b01b088827177570b090fc2c473010107e1'
readonly UV_SHA512SUM_OSX_X86_64='7e65063fed24253305041848d99e2a342896ec96432b4e7748974654bee3162717e33fd46d42efbc5a6e03b687c09fd8c05b3747345e8cbeef6efac5ad959cf5'
readonly UV_VERSION='0.11.13'

# For prebuilds
## https://gitlab.com/ironfox-oss/prebuilds
readonly PREBUILDS_COMMIT='c4e26779a2e270fdc9cbf1ebdf553390110812f2'
readonly PREBUILDS_SHA512SUM='c58868a5fd92dd349d74bc37f123842f503f32d4c94fa894f56a9f534783bd6c69ed5230b042d644927cfc67963ffcf0e5d146c5602ecf683a53557414d371fe'
readonly UNIFFI_LINUX_IRONFOX_COMMIT='c4e26779a2e270fdc9cbf1ebdf553390110812f2'
readonly UNIFFI_LINUX_IRONFOX_REVISION='9'
readonly UNIFFI_LINUX_IRONFOX_SHA512SUM='b5f3457659f276c464d4e9ba6953f175d48c98f6b6f612a68e2f3625989e1961cf336538165bc046d52cb3db223e6739186a8ea80218bcd48390175990c48880'
readonly UNIFFI_OSX_IRONFOX_COMMIT='2923784a8fba97fb21a2998c8a7f729ae97621f6'
readonly UNIFFI_OSX_IRONFOX_REVISION='9'
readonly UNIFFI_OSX_IRONFOX_SHA512SUM='feadd643d650c849667ea7ad70974538f6b84d7d7f779b7ba40137a95520e6b10573706f1206f09ed44591a80f41144bdb360a5aeb298d8ce53969dbd20c3d5d'
readonly WASI_LINUX_IRONFOX_COMMIT='b76a3b2a8f3124e9297036e3b27802a47c0263a4'
readonly WASI_LINUX_IRONFOX_REVISION='4'
readonly WASI_LINUX_IRONFOX_SHA512SUM='98d81e0f47229184fe767fb47906685eec6dd34ad425030e08d1eea42ddec1ebef678530e70dfc954aa2d0904ac44d38a869334c098b0baf9fff1b87233ff31e'
readonly WASI_OSX_IRONFOX_COMMIT='97f5fb17ea756670c452e832ae3fca80d0498a82'
readonly WASI_OSX_IRONFOX_REVISION='3'
readonly WASI_OSX_IRONFOX_SHA512SUM='eb0697f42c9838080fcf23fa0d9c230016212a15725e62e2fafed896751a9fcf8adf508461cf9118c02bff1bcd0791ae1113f13d0cca96de3b8f03244df25a30'
