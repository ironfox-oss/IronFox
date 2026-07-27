# Sources

# Firefox
# Version: 153.0 (RELEASE)
# https://github.com/mozilla-firefox/firefox
readonly FIREFOX_COMMIT='f1b6c0f86b96b7e0688c26f65803576f27cdaf88'
readonly FIREFOX_SHA512SUM='8799cd19e37c607729d885d2758951030863c81c9211a3e577d4036f6c0ae04a43730d0b785f65c7969069e2955d080b56981565946eb1a411604a1d4edc875e'
readonly FIREFOX_VERSION='153.0'

# IronFox
readonly IRONFOX_VERSION="${FIREFOX_VERSION}"

# Application Services
# Version: v153.0
# https://github.com/mozilla/application-services
# (for reference: https://github.com/mozilla-firefox/firefox/blob/main/mobile/android/android-components/plugins/dependencies/src/main/java/ApplicationServices.kt)
readonly APPSERVICES_COMMIT='d05bd0f98d77e4c0ca2a11e5bae4f7299212c44b'
readonly APPSERVICES_SHA512SUM='d91df2f2b68b18cbb4188d295e3f23f60564b0799d06db6fc1c3bd0baafc2d9dc13bdad7bcf7e9289b90220a4702a3f9864458c9af5c40a84f7e747f2d1333fc'
readonly APPSERVICES_VERSION='153.0'

# firefox-l10n
# https://github.com/mozilla-l10n/firefox-l10n
# NOTE: This repo is updated several times a day...
# so I think best approach here will be for us to just update it alongside new releases
readonly L10N_COMMIT='c04ba7608e8314ef65c9be265c4b99d39395ae73'
readonly L10N_SHA512SUM='1d43e66f72ddb8486d39122645e8d0878dc3a66dbdd1b067a2b6f05d169dbf497385dfb829a852021b545bbe29af1ff7f9c3426fcc7dd848f8e221f1c22b7b91'

# Glean
# Version: 67.3.2
# https://github.com/mozilla/glean
# (for reference: https://github.com/mozilla-firefox/firefox/blob/main/gradle/libs.versions.toml)
readonly GLEAN_COMMIT='24c647f24faedfe6839c99d18e58df0e288132a8'
readonly GLEAN_SHA512SUM='a80e30355c8b2ef86e999908e01cc510bd9d018c9a9d774714c90468d07ac4b14c8aa919df9093707cede5ed51c29afdbe2e76c4903e7868ce767cf34afe5435'
readonly GLEAN_VERSION='67.3.2'

# Glean Parser
# Version: v19.0.0
# https://github.com/mozilla/glean_parser
readonly GLEAN_PARSER_COMMIT='d87316dd8ce2fa0122d8634660bb71397c2d5820'
readonly GLEAN_PARSER_SHA512SUM='acb6ba017549fe26b0b9af77fea98421509580d8c734adaf6de700e6abd24c7bb3c8a708ec2f8b5793c294dc74d0af09ce53d6042d1814baf4c50afd30bc7cef'
readonly GLEAN_PARSER_VERSION='19.0.0'

# microG
# Version: v0.3.16.252432
# https://github.com/microg/GmsCore
readonly GMSCORE_COMMIT='9a206ae115d6f4d99300def2aea447332ac84260'
readonly GMSCORE_SHA512SUM='b826bd6693b55a4e7844ed773df0015f9f04f502dab50c49c44e5807721918650b0b6cf23a7db5d25312224b2f02e2bdb1edfa1bb8f12dd0023fcd91b71ab275'

# Phoenix
# Version: 2026.07.27.1
# https://gitlab.com/celenityy/Phoenix
readonly IRONFOX_PHOENIX_COMMIT='b33d59609dd3a2fd7df9d77a94e782e074887a36'
readonly IRONFOX_PHOENIX_SHA512SUM='0c871056b033b06be40ae561fa9839b0e6bd5daf2c7dc1031d2560ab42ec0dddca203541798bbb3e348fa24a7c9872fe6db470abe48cde8b8f9b2de032d8183b'

# uniffi-rs (Tor)
# https://gitlab.torproject.org/tpo/applications/uniffi-rs
readonly UNIFFI_VERSION='0.31.0'

# UnifiedPush-AC
# Version: 1.0.5
# https://gitlab.com/ironfox-oss/unifiedpush-ac
readonly UNIFIEDPUSHAC_COMMIT='a925c7dee0d97335a856ba0800a810d9fae8156f'
readonly UNIFIEDPUSHAC_SHA512SUM='56c200efbcdc6f0c0609e8b55a8defe43be313538f79eba8e9b8031d4ceab27d251745795ef09032454a662ee4287d3979954b217fc411dcb652e87fddab0b89'

# WASI SDK
# https://github.com/WebAssembly/wasi-sdk
readonly WASI_VERSION='20'

# Tools

# androguard
# Version: v4.1.4
# https://github.com/androguard/androguard
readonly ANDROGUARD_COMMIT='d594fd39beb934e438a5bf8089b206d5800d81e0'
readonly ANDROGUARD_SHA512SUM='d167b3ca58c073758bd478e68a92f6efe9cc93e14ac4abf52cdadc4917319bdd2fe24ae8c3ba9a584b746ce349247ac853eb7e77eb1125c6a870a199c2b756f2'

# Android NDK
# Version: 29.0.14206865 (r29)
# https://developer.android.com/ndk/downloads
# (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android.py)
readonly ANDROID_NDK_REVISION='29.0.14206865'
readonly ANDROID_NDK_SHA512SUM_LINUX='b55819895a7fa3a0bc7ed411fb55ed15ad9e415b0122a81a4e026c9b696cd266cb4beebb2008cf1d6cac88d38187d52818734f87de793de303653eccb4ca68da'
readonly ANDROID_NDK_SHA512SUM_OSX='4091bc97a03266b869380874cb2d67a35dc74f9bc5f1cde30a3545547355e4ec4f3ebd79a17a19f9228d045f7a176d1e987ce4f787d81a02a044aa909f5ef5cb'
readonly ANDROID_NDK_VERSION='r29'

# Android SDK (Command-Line Tools)
# Version: 20.0 (14742923)
# https://developer.android.com/tools/releases/cmdline-tools
# (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android.py
# + https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_REVISION='14742923'
readonly ANDROID_SDK_VERSION='20.0'
readonly ANDROID_SDK_SHA512SUM_LINUX='b65e830d7655fb39cc9eee669806977f462c49375807ef2c6487fabcc9afdbc210465ce6a1e2429ff95c74ca519d1239daf9a403c30b8d0bdb7a0962af656c8e'
readonly ANDROID_SDK_SHA512SUM_OSX='20fc87470d1850ecbaf254509caca1b45055d72d3d78c9079adbe97ff7754018979a548f0cf145e52f03afd65357a5653f556db15ba569bffd4a143202cca0f8'

# Android SDK Build Tools
# Version: 37.0.0
# https://developer.android.com/tools/releases/build-tools
# (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_BUILD_TOOLS_VERSION='r37'
readonly ANDROID_SDK_BUILD_TOOLS_VERSION_STRING='37.0.0'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX='0c1735b91da1088d824243bef3f5c070ee4d0b9ccc50d2c20d0c5afdeab41a0fd71f785b98d60579091bb48d1a703f9f5ea6775bab4781de51a9df570b9dba98'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX='b3600aee0148835d7074748d5b6b2d56852e73a7f0081956def0d22e21170514bc0984c5dd4a4ed746eed5476e90dac042aeae571954745fbf2d6a239aa51a5e'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX='b45dc6b7298567f3b45428def0b85584b99b125a3719dfb74a82732bf2b86a0c66161682f3c3d7a50cefaf6e1a2d993975665272e16f00b231a15a9a4512cc1e'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX='991db0bbf23acd212b6be57033cdb3ecd5c8c8da79781a6e4326c046c2079b2827892084ee5f77b1fc5d5ef91fc62a4820d43218d3943f0c43e5c093c58c4999'

# Android SDK Platform
# Version: 37.0
# https://developer.android.com/tools/releases/platforms
# (for reference: https://github.com/mozilla-firefox/firefox/blob/main/python/mozboot/mozboot/android-packages.txt)
readonly ANDROID_SDK_PLATFORM_VERSION='37.0'

# Android SDK Platform Tools
# Version: 37.0.1
# https://developer.android.com/tools/releases/platform-tools
readonly ANDROID_SDK_PLATFORM_TOOLS_VERSION='37.0.1'
readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX='990ee47ae823724599679fe56561df31a6056668246390698c94f9b00a5af8e5966bff4c31c8f8b8d11b3c419ea994147d38e2234fa6e881255dbb29ff203449'
readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX='331558dd9bd086a3a990f1bfda84066ff90a7f4231262970f6330186c1213cfd171c54baacf7e4fef8df6aab6c2dc0c1c58abcdc0b7cf4fe4df1032f54c27fc9'

# This is used for setting microG's compile SDK version
readonly MICROG_ANDROID_SDK_COMPILE_VERSION='36'

# This is used for ex. setting microG's target SDK version
readonly ANDROID_SDK_TARGET='37'

# Bundletool
# Version: 1.18.3
# https://github.com/google/bundletool
readonly BUNDLETOOL_REPO_COMMIT='586a43a450712a1067f3d92cf7574dee68226302'
readonly BUNDLETOOL_REPO_SHA512SUM='a72040449b3bd51a29bb562d8686b0338d630be12a5a590a88a753111b887d30f7b32ab256a556157271ed0071fc54b81205efcfd1ef93ccb8142fe41a741345'
readonly BUNDLETOOL_SHA512SUM='50feda5f3f00931bad943a37b7cfc33d8ea53b33bd9bfa83832f612da6e99b72146206695ae25df5044030e305e1d718c833ad51c12b944079c263bba3cbffa0'
readonly BUNDLETOOL_VERSION='1.18.3'

# cbindgen
# Version: v0.29.4
# https://github.com/mozilla/cbindgen
readonly CBINDGEN_COMMIT='b826cb8911488fe8a209d2b693492c0c673e8cca'
readonly CBINDGEN_SHA512SUM='b1d43c6820a210c809a029a3f7ec92720fca9bfa1bfecd5835615124b005dfb63e30fe1463ab071717f83b0928207dfd2a71d93f57642314b5bae92076ceb15f'
readonly CBINDGEN_VERSION='0.29.4'

# Gradle (F-Droid)
# https://gitlab.com/fdroid/gradlew-fdroid
readonly GRADLE_COMMIT='9f31b7ee881e46a5d7d234406c14e5e474bc5fc4'
readonly GRADLE_SHA512SUM='58ddb0a3c5e015ad3f2658729941a76cb84271248265642a7b800e12c13abb5004641be6574b7dde787850cb321c4de2322b2dbef26f1057f1778166bb947210'

# GYP
# Version: v0.22.2
# https://github.com/nodejs/gyp-next
readonly GYP_COMMIT='6a2e12fdc30b521d11f781f986390525a54398bf'
readonly GYP_SHA512SUM='b266341d794354a8816668971bcee8a5d555c82fb3164fd59d89a6c7774e4a123e78786341d4c22d6210ac10d5efb8bd39c27e9462b66b9e47e31d19c6d53335'

# JDK 25 (Temurin)
# Version: 25.0.3+9
# https://github.com/adoptium/temurin25-binaries
readonly JDK_25_REVISION='9'
readonly JDK_25_SHA512SUM_LINUX_ARM64='5720a23247087c7bb61bc9939143466f333fc256c91c401d12022c6f86806a2bf7f6f7d973183cdb0b963ceb86ae0644806f2b91ce6af279c1b9e341d88f5a0d'
readonly JDK_25_SHA512SUM_LINUX_X86_64='b40b97de14d0df0eece463388a605cf572d5e0e10a839d3bf2f85658ace607a66365681f19e22486c72662e3343c71cf0ccbbb570730c321dff12b0c24c0bbae'
readonly JDK_25_SHA512SUM_OSX_ARM64='5f87288c111a286a4d945fb337ae11af95cabd8a0be94f110215a4d4eb4970ab38bd8619ae780a37b2a354b613a9cc31301cde5c520d687f28c6a62b99ac0584'
readonly JDK_25_SHA512SUM_OSX_X86_64='6726ce00765fda7441adf355d266b0c00a00bc9b5d03f9d823dd84b4b7bf36957df3e725b385af10e0dcc9008a85146711479f17f45ba533f8c9518c010e5212'
readonly JDK_25_VERSION='25.0.3'

# JDK 21 (Temurin)
# Version: 21.0.11+10
# https://github.com/adoptium/temurin21-binaries
readonly JDK_21_REVISION='10'
readonly JDK_21_SHA512SUM_LINUX_ARM64='595115ab59958f9c62600f5af5286da498d6e2d9742e34be59899d0b03add9a8d5b667625b81ccbf5a905a33ea734e8dae690a42bae1b9ceb2cf0cedf30201fd'
readonly JDK_21_SHA512SUM_LINUX_X86_64='e8293b3b4e9d55bd13271dd364637a9b19b6e677f4b4384eb6e7583d5c1270fcb183b81cb857e3162cf7ab584bed7cd4ad42d833e218b1223c3ab42b98f2266a'
readonly JDK_21_SHA512SUM_OSX_ARM64='524ea7fc0f544f0804824b776d5d61250168f0f6ef3d860fc6b1bc150a02bb741001ae932a2875f3d6385262fcfe1a4e7ed29bcacc0b5627668df29983b650b5'
readonly JDK_21_SHA512SUM_OSX_X86_64='2cb90849fd2b1f6b77283537aa98d35adde62ad5789c738316abfb2fd427627e7bc8fb739f5d49262173c9631166fa65de1cce75a017877197333b0a458010d2'
readonly JDK_21_VERSION='21.0.11'

# JDK 17 (Temurin)
# Version: 17.0.19+10
# https://github.com/adoptium/temurin17-binaries
# (Required by GeckoView)
readonly JDK_17_REVISION='10'
readonly JDK_17_SHA512SUM_LINUX_ARM64='c72400ca721fa0cfe5c40b928c6b091895cf2c1abf3c9a7d5ed3f3ca2bc899bd9e2dab79de80f068032b503e12509a20f0f67248369f0a77313cd14e719ea43a'
readonly JDK_17_SHA512SUM_LINUX_X86_64='61701218400ec0d64bc624c1a977009bbf3de26cc7f81d2c033e1492d85525d5e00c19800d075980a2e51b8b78f30b4792e71dd9dd6a9763d0582cac6c666d77'
readonly JDK_17_SHA512SUM_OSX_ARM64='41666c70b771693ca5ceb0c7b6bf193f4abe95e98e6311c3baa2cc1cf5d98efd56b3c5eff6401664bcf057bad11f0cf59de5e3d8f27c62afe7d01814e0e21260'
readonly JDK_17_SHA512SUM_OSX_X86_64='c871deedc3ccf0663aa584610c1390d1ae2fac2d472bb1ace111e65fd461b17ef0adf27ad948523be37c40091f717bb5091375b94acfa0a87e12d54055d6d279'
readonly JDK_17_VERSION='17.0.19'

# Node.js
# Version: 26.5.0
# https://nodejs.org/about/previous-releases
# (Used by nvm)
readonly NODE_VERSION='26.5.0'

# npm
# Version: 12.0.1
# https://github.com/npm/cli
readonly NPM_SHA512SUM='2f94fd8bf600416416a934bfc59c4991e8bff7372ef7d842784e2a8b8d48c81555ee645069ddea73625fb8e92dc261feab0188fd5dab6c22fefd46316f5f9140'
readonly NPM_VERSION='12.0.1'

# nvm
# Version: v0.40.5
# https://github.com/nvm-sh/nvm
readonly NVM_COMMIT='1889911f0841e669de0be5bd02c737a3f1fd20fa'
readonly NVM_SHA512SUM='995a6d63ad26294d272910d6bc08851ded1989713ade1051819da4659dbb6285874a12b56d13cb79bf61d3e2c616077e2433747971d85b552ccdb4253062fd40'

# pip
# Version: 26.1.2
# https://github.com/pypa/pip
readonly PIP_COMMIT='31d7d168953668aad85154d6121879d07fbeac27'
readonly PIP_SHA512SUM='df5dfd2b6206cfd6d1c786cb91dd30f08e3e381c3f15c7357174959fa59d7f1cbe8d28415f605d78268a0a60a00d82115efe423f2fe8f53bb246251b05505273'

# Python
# Version: 20260718 (3.14.6)
# https://github.com/astral-sh/python-build-standalone
readonly PYTHON_GIT_RELEASE='20260718'
readonly PYTHON_SHA512SUM_LINUX_ARM64='ae288b1395125c4227fc7ee92b79fa70a757a36eb5766d78c4f459e8906257613754d23f095f13e1186eea8fb3804f5a80eb539edf52128de18682b675697313'
readonly PYTHON_SHA512SUM_LINUX_X86_64='1257da7415c07151db82428188343a148d6bad6de0bba047dd0511d7b44f0906c8e267a527fd95b70af603b707a7b40eb4f1cf1fe4a0c47e5029d9e07a1f09b9'
readonly PYTHON_SHA512SUM_OSX_ARM64='cc4d36c02e429498223b3dff90e1d7d97a97f5fa06a993368ba25963e77c043793ee9ed24f3dfca613330c48f1cd10ca0140e1bd4f2eb768d4e4a036e976032d'
readonly PYTHON_SHA512SUM_OSX_X86_64='1f7769871ea8cc67c571e598e4f009b09a193af9059fa4b5cc5af3ab6b3cdb2ac76914a0e221effa665d3f7b420eb53996ea1b34b267986221478a4bfd56c0ea'
readonly PYTHON_VERSION='3.14.6'

# PyYAML
# Version: 6.0.3
# https://github.com/yaml/pyyaml
readonly PYYAML_COMMIT='49790e73684bebad1df05ef8d828fa12f685bffb'
readonly PYYAML_SHA512SUM='2fd1334af2722c093592f93a5eee01d0b2e26976a12cb2e4859b4271a8fa47ff257d10c91b09bdb2b5aa9415b62693a69d6e6602e997c2bff6711aa02bf43937'

# Rust
# Version: 1.97.0
# https://releases.rs/
readonly RUST_VERSION='1.97.0'

# rustup
# Version: 1.29.0
# https://github.com/rust-lang/rustup/tags
readonly RUSTUP_COMMIT='28d1352dbcb436d3111c3594b9e1588e94950464'
readonly RUSTUP_SHA512SUM='cd9fd64eabc989f19a6a16e9cd2caabe935082e2715b9308150f86d3839c99eb9a7e42a7ef6730c6d956d870638ee89a04dd9e7e14fe243cc165967b7f2918da'
readonly RUSTUP_VERSION='1.29.0'

# s3cmd
# https://github.com/s3tools/s3cmd
readonly S3CMD_COMMIT='cee84f9c539a7bbf5ee73c7bf29a47632119c0c6'
readonly S3CMD_SHA512SUM='b1b7c792265dfa1ccdd40f816e3463617c168e4317acac930b251ce73fcd3b8eb479d966d4ba93fbe8c0cf251bada64bcd9caf30d1e5e94c20a87a36447c1263'

# uv
# Version: 0.11.30
# https://github.com/astral-sh/uv
readonly UV_SHA512SUM_LINUX_ARM64='2361a4f08108286b3cd27e2294c353e3a55865aa3da165fe1fa7a126c3eadca06f6bd879695c07e5cd1760ef9028bd5e9fe2897549a22b14d47887ab2fe69eda'
readonly UV_SHA512SUM_LINUX_X86_64='f306fa7c70b20c35b6c75596474f09878110b1dc804e394da3bc4b8b22828d663f4ed4bbd616d1ff369dafa86b4a940819754e74f102aaa2d45eeff87cb1fb04'
readonly UV_SHA512SUM_OSX_ARM64='b2f7fd5c3f7265816b5e06af5a8f344145930bc92b7db9c8aa797ced6493db38318a3804c26a225312345bcff86c0542ef6782fe800902b34bd6b3b19d08b7ed'
readonly UV_SHA512SUM_OSX_X86_64='f1a0df65c2008923016d87b82f92cfaa03d6d233bce84789061b087200dbef710a3ebcc253349aa04c6d7eb82d8f54a57006f003f7f74a23b544418d3991c9af'
readonly UV_VERSION='0.11.30'

# For prebuilds
# https://gitlab.com/ironfox-oss/prebuilds
readonly PREBUILDS_COMMIT='f8f9ad55f80d2f2f2df381034b3f144a16fb4253'
readonly PREBUILDS_SHA512SUM='5365b4232ed1c25a21f038ffa643ae2cc9c0c79614aa5ad428ac052929fcdfb4b5d35cd38d8f137662321322a73b876f689e1e7d84dfcf37ff3185817dd41dd5'

# uniffi-bindgen
# Version: 10
readonly UNIFFI_IRONFOX_REVISION='10'
readonly UNIFFI_LINUX_IRONFOX_SHA512SUM='b55e23db9d0d38f23d738e5358678a41efa48f8c497ea4e07b959e5398a04de4a3d717d3121aca193f43cc5d34cd2fbf8c993e3de4012b76d2b585b4df629815'
readonly UNIFFI_OSX_IRONFOX_SHA512SUM='eeb558760ae7fa714f098d8f014026c31e9a8d60b21395dfaa696571e51f437b6834182724f880b3003a9550c41e4fbe88b4147204d2faf3a6dc5a888db6774a'

# WASI SDK
# Version: 5
readonly WASI_IRONFOX_REVISION='5'
readonly WASI_LINUX_IRONFOX_SHA512SUM='e827982030baa16e9f3f02992ea33ca0bfeef85a58ef932b8db5f0522a9b48d3d365e2002386ba6b12c1e17c49689d43a85dcc6df884384eb80785cc7907eb27'
readonly WASI_OSX_IRONFOX_SHA512SUM='d867d545de050103a3548deb7e15e7173f2c1ee56334146161105c82fac7172f8e50314ffefa23bf92f180ae0a9a401a28bfde12ea4aac98feea4e72f631e491'
