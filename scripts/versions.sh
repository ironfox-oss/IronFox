
# Sources

## Firefox
### Version: 151.0.4 (BUILD1)
### https://github.com/mozilla-firefox/firefox
readonly FIREFOX_COMMIT='8144198f707c32b78f738278ebd697a3fb10f146'
readonly FIREFOX_SHA512SUM='8eda66b4210b0143f167091892cd8d4fc1205e0232b99e0070b7b5b18c01f710319f7d5cea5848e1f83742da77b92d88ba5b968c0f6f28355f57596fb85f1e17'
readonly FIREFOX_VERSION='151.0.4'

### IronFox
readonly IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### Version: v151.0.2
### https://github.com/mozilla/application-services
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/mobile/android/android-components/plugins/dependencies/src/main/java/ApplicationServices.kt)
readonly APPSERVICES_COMMIT='3d13b5f0e3abffe2cba93b2de3edf2c4781a7fe5'
readonly APPSERVICES_SHA512SUM='155229c7ea2d850ddba31e4080d1d7f8bdcd51f8b9701355cf9098645048b7de632ac7754e5d93ef7bc67f90edf5db1a96242278f9f31218d9b474aff7f98b48'
readonly APPSERVICES_VERSION='151.0.2'

## firefox-l10n
### https://github.com/mozilla-l10n/firefox-l10n
### NOTE: This repo is updated several times a day...
### so I think best approach here will be for us to just update it alongside new releases
readonly L10N_COMMIT='a96f52c82767590492a6ce702a771f67312550b6'
readonly L10N_SHA512SUM='177151752860f95fe8e6553cd2f3f0344b60cfdfca0812762e27add62114c357d27e0ac9a11f791c34f4c9f147b6e375e35958ff9d59dbc7ffcdbe54867acc7c'

## Glean
### Version: 67.2.0
### https://github.com/mozilla/glean
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/gradle/libs.versions.toml)
readonly GLEAN_COMMIT='0f15ce693d48b8d9c1e9e1e8c7a7000c1ace0cec'
readonly GLEAN_SHA512SUM='ade178c5a72029da7cabc691f7c604abe149a8bc02f6dd0c16090197579bb2d2a757b740e788df54b99f8c378a5ed30a0e8062ed3bfeb04f22e91e5b1a3d0e0d'
readonly GLEAN_VERSION='67.2.0'

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
### Version: 1.0.3
### https://gitlab.com/ironfox-oss/unifiedpush-ac
readonly UNIFIEDPUSHAC_COMMIT='3b8f666aa61a5fb236a403d1afdfc82f07fc4455'
readonly UNIFIEDPUSHAC_SHA512SUM='c95d7c7150d3481938e7cb14adc4faa5cb48fc193d18a3602da3f6e3fd8f137bfd28b77dc9556a8bd92e2f0a59524b80c11f000cc9cbab2bdf707d9059bce945'

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
### Version: 14742923
### https://developer.android.com/tools/releases/cmdline-tools
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android.py
### + https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_REVISION='14742923'
readonly ANDROID_SDK_SHA512SUM_LINUX='b65e830d7655fb39cc9eee669806977f462c49375807ef2c6487fabcc9afdbc210465ce6a1e2429ff95c74ca519d1239daf9a403c30b8d0bdb7a0962af656c8e'
readonly ANDROID_SDK_SHA512SUM_OSX='20fc87470d1850ecbaf254509caca1b45055d72d3d78c9079adbe97ff7754018979a548f0cf145e52f03afd65357a5653f556db15ba569bffd4a143202cca0f8'

## Android SDK Build Tools
### Version: 36.1.0
### https://developer.android.com/tools/releases/build-tools
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_BUILD_TOOLS_VERSION='r36.1'
readonly ANDROID_SDK_BUILD_TOOLS_VERSION_STRING='36.1.0'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX='32a1eea273980a96745ae5e0b141720e5f91c6c6f83f42da4244fad36025d7750521fdf678a7d332afe5946057b498264343c2533ba524967d84347af9cd7ce5'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX='07a78d5f4658c6809220012fc27560cfd8aefcbd29a6414aa309fc54d6df7751b7b1e59964e3942ff9b91030c2611639e2b7d7eb2f77aba1ab0933c015e7c802'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX='b45dc6b7298567f3b45428def0b85584b99b125a3719dfb74a82732bf2b86a0c66161682f3c3d7a50cefaf6e1a2d993975665272e16f00b231a15a9a4512cc1e'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX='991db0bbf23acd212b6be57033cdb3ecd5c8c8da79781a6e4326c046c2079b2827892084ee5f77b1fc5d5ef91fc62a4820d43218d3943f0c43e5c093c58c4999'

## Android SDK Platform
### Version: 36.1
### https://developer.android.com/tools/releases/platforms
### (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_PLATFORM_VERSION='36.1'

## Android SDK Platform Tools
### Version: 36.0.2
### https://developer.android.com/tools/releases/platform-tools
readonly ANDROID_SDK_PLATFORM_TOOLS_VERSION='36.0.2'
readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX='e7a024df013af813157794054a203506dfc7dc776479b82bb83e5ba8a538e8a749b662bf3e05a3822c77dfca9aa221c4ae67e69921f8dfc78fee7acc5bb4e63f'
readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX='1fefcd4ef10740bfbf1e46c4968d879c621315f7616c8eaecd297b3c89af2007a59a1c18f8a89afbd1afeeb9989c2eeb0d3f189e3502e42e62b76c79d69b7385'

### This is used for ex. setting microG's compile SDK and target SDK version
readonly ANDROID_SDK_TARGET='36'

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
### Version: 11.16.0
### https://github.com/npm/cli
readonly NPM_SHA512SUM='03be172fc3b199c7a06433163e459be5b110a6983c1dd6305b7ac10f6b0fa12e1440755a8df6b1064ab2ccb789df0474919fb9c684e322dc57685ede21752ccb'
readonly NPM_VERSION='11.16.0'

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
### Version: 20260602 (3.14.5)
### https://github.com/astral-sh/python-build-standalone
readonly PYTHON_GIT_RELEASE='20260602'
readonly PYTHON_SHA512SUM_LINUX_ARM64='285df86e73b276240538586aa57b35f5ab434f9b37998e4372d064c8c90800ec30f5e09341e2bf147fc43803ed09d37ad496cf76cbf503f870332a64e2aaa353'
readonly PYTHON_SHA512SUM_LINUX_X86_64='585f3a42d16baf752ace084f35dd3cd811e9ca55d60d28aa0d7863701f370f5054a70c3ccb290b22c7f0114a10fad4f42c4fc15d656b6b71ba083ff02ac1efad'
readonly PYTHON_SHA512SUM_OSX_ARM64='0f78253ede6cb2f9bfa8bcfbb520166ba9a12c273be5bb54f815ea095dc7253d11acca90c051968ee11292f2430a586917a42f79cf615d4a174142cc822deaac'
readonly PYTHON_SHA512SUM_OSX_X86_64='856b809a3f90dd88273a93847b43694a9f731372c27d5ca0bea3aeda08e1d01d5c911d0d7a6cea2b95861b7b7fc3b8bbfe7ee200816c7ef02800729d3094d477'
readonly PYTHON_VERSION='3.14.5'

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
### Version: 0.11.19
### https://github.com/astral-sh/uv
readonly UV_SHA512SUM_LINUX_ARM64='2beb0e792d3639a11c3934130fcd22c006ab8bdc9a08217ff17f3171a5db1b999f2840afe7a38eecd0e474336e091ec6f98d8fb9728f72063939d0c7cea3e9a7'
readonly UV_SHA512SUM_LINUX_X86_64='1644ee1ada099974a412c28bca66ecee754391ff928cef73a44fd33cd0588ac37fa04ae5b15ee1a5ee1f6c458582cfe1488a66b35e2ee27a4db44135dd5b1024'
readonly UV_SHA512SUM_OSX_ARM64='c6275c2fbc405f9c5e5a55d80902282110a5163827d75d379c377617fb4895ba1bedb39d43f5f32ab9606262784c1a33506bc2216d7e1c35b4da48463dc0dbb2'
readonly UV_SHA512SUM_OSX_X86_64='f6d3732c116c072259bd4d471ad7756c2879abbb7bebc8191b05b76979c40b1a63ae0ec1340fef998cfac447c1ed6c2cff04cf4298f6729b145d7f2233e19220'
readonly UV_VERSION='0.11.19'

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
