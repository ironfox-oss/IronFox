
# Sources

## Firefox
### https://github.com/mozilla-firefox/firefox
### (This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_150_0_2_BUILD2)
readonly FIREFOX_COMMIT='d269b4d95b09f236970f9e749fb8b77c8fae230c'
readonly FIREFOX_SHA512SUM='28cbd85f6029569f970d7b27a904aaadc9b358df00837f0381df9e82ec7e6a8d1298193458db3c8a4f831c8dc8ab93bda5d76739ea1da7a4c3d42b000f7d2df3'
readonly FIREFOX_VERSION='150.0.2'

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
readonly L10N_COMMIT='fdbbb2096a0d362020ba53ace9579e950ee0f9c7'
readonly L10N_SHA512SUM='87723ac6da8827fecd632bf14a81e338a0987eb106d6ca54ae08451b0d1e6ec2def0e74ef2444afdc2d61ef3092b36b1f536dbd8acd4a0a802e4bdb7b8c8a60e'

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
### (This commit corresponds to https://github.com/adoptium/temurin25-binaries/releases/tag/jdk-25.0.2%2B10)
readonly JDK_25_REVISION='10'
readonly JDK_25_SHA512SUM_LINUX_ARM64='f1d3ccec3e1f1bed9d632f14b9223709d6e5c2e0d922125d068870dd3016492a2ca8f08924d4a9d0dc5eb2159fa09efee366a748fd0093475baf29e5c70c781a'
readonly JDK_25_SHA512SUM_LINUX_X86_64='29043fde119a031c2ca8d57aed445fedd9e7f74608fcdc7a809076ba84cfd1c31f08de2ecccf352e159fdcd1cae172395ed46363007552ff242057826c81ab3a'
readonly JDK_25_SHA512SUM_OSX_ARM64='f15a4ae987c1da6e9d12afafde3a95c5ac8c0f35617b6b49e9de1ba0d8eb886d6c1b3f6492dfa0de44996e5a5cde41e6240e05568ec563498a7471c8bd94c044'
readonly JDK_25_SHA512SUM_OSX_X86_64='76d05d952ea451e0f0872e20895d7e65eb501dcd60b7e376819a489e2a7fdc758dfccc098f5b17024bb8a8b633240d84a50021628ab7a5525abc7d3cd09765a4'
readonly JDK_25_VERSION='25.0.2'

## JDK 21 (Temurin)
### https://github.com/adoptium/temurin21-binaries
### (This commit corresponds to https://github.com/adoptium/temurin21-binaries/releases/tag/jdk-21.0.10%2B7)
readonly JDK_21_REVISION='7'
readonly JDK_21_SHA512SUM_LINUX_ARM64='c9ea02a6fafdb8704ceb0308f4ef1809caf4b878d20504b70da0ea34008da25bc55affa7c9830e192578fe81c2fdf52f4b33cfcfae755550970aa454fb0b0cbc'
readonly JDK_21_SHA512SUM_LINUX_X86_64='51ee705322ebd5d54f22d8566c752f711eb18072dfffc037a8e68f0db8539505d68b65e352f6208ae2d4458d6e07ec3c06d3685247e7a4b36785306b674d8227'
readonly JDK_21_SHA512SUM_OSX_ARM64='19761231eb3310e265a8f3313ed8d38954dcf79f07e2c2c33bdd25a891ad01a2e11b8d6159605a03806620aa2737225b172b12349f5fb0115917e39d5ce95eae'
readonly JDK_21_SHA512SUM_OSX_X86_64='f6299f986746f5cf78a52ba0ee3e22506e006bfef51b213a8e4cb56848747682791240f9bc8d756e224bffc26e35399665e70634a17bf53730a8c6d8aa48a401'
readonly JDK_21_VERSION='21.0.10'

## JDK 17 (Temurin)
### https://github.com/adoptium/temurin17-binaries
### (This commit corresponds to https://github.com/adoptium/temurin17-binaries/releases/tag/jdk-17.0.18%2B8)
### (Required by GeckoView)
readonly JDK_17_REVISION='8'
readonly JDK_17_SHA512SUM_LINUX_ARM64='ce632aab5965d60cde210bcfd6bb3a41f956e51eb87f4ca28a523c5614fcf9a18a8fe89fb1ee2424a40d7bf39afb3a3c69aaec60a0871f81c66622d5355febfa'
readonly JDK_17_SHA512SUM_LINUX_X86_64='fb40a864b5bc43f037f0209729c2319ef15f58a3830970ceff44f4e1cfe6fc4dcac0628d6afe6713acecffd1bc357325b6026185f3efeb9dcc767c2437c61dbc'
readonly JDK_17_SHA512SUM_OSX_ARM64='91b1d64b9865fa62466e52f9fd3a2bdb0ddf62d3a678f4fa4f471ba621aea17c51a35f29e86091deaddcc3afa0a14b658487b4f919b64a259bde0df8563a8aae'
readonly JDK_17_SHA512SUM_OSX_X86_64='f214734251b6662737e08fd8bdb3a351466ff10eb776a2f338e3ccea93d7f01d2578acd1f716aa9a08d152b3c0cd4d2487ae35acee395ade4ab3507cfadbe018'
readonly JDK_17_VERSION='17.0.18'

## Node.js
### https://nodejs.org/about/previous-releases
### (Used by nvm)
readonly NODE_VERSION='26.0.0'

## npm
### https://github.com/npm/cli
readonly NPM_SHA512SUM='ea37d9cea2bc11f5869d379941ef9b80cc78220884667ee4d5e338184f1213cd41de261c879d9d55230ed610b63a735b14b230cefc14914c6c38e7143c6d9723'
readonly NPM_VERSION='11.14.0'

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
readonly PYTHON_GIT_RELEASE='20260504'
readonly PYTHON_SHA512SUM_LINUX_ARM64='38458d2636253f0d11bc7cb17d69897d6af0c1357ac0ac578079d2662e5e7aecea6545f9f2b362f9fc70b7003f5d471018d02fb87dc0ae1961926ca06dbbb93f'
readonly PYTHON_SHA512SUM_LINUX_X86_64='f962a9dc6c6d3943adff88e82de7f283f4739a04ef9fab3aebb365f82faaba3893f2cb7ca9701596d05acd8cb12c2f4e3b1d1e9ad21fa5fb846ce6a22a8b2db6'
readonly PYTHON_SHA512SUM_OSX_ARM64='4fa947116ecf034270f1dc4ebe6ca80f58d58ac56c1e4f925d83a3f4ae6733031c26bac79b6e699ab840325ec26596320e2270f02b880a3317bbd2db359dfaf5'
readonly PYTHON_SHA512SUM_OSX_X86_64='281fd64af10d381c66d713f8e67a4af225fb87a2a0580949c2350ebdb415397613c4c933b3dac418ea717eccb1d69a3402bb1d39093516ea00790dc6fe87568a'
readonly PYTHON_VERSION='3.14.5rc1'

## PyYAML
### https://github.com/yaml/pyyaml
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
readonly UV_SHA512SUM_LINUX_ARM64='22f4eb36445d83c74b1a7fe97268ec201b925cdc192887e03890e7a1d572393309d6b2101e0a7230152a105f8da26879547858baf83ddae03d873d5f586d05c5'
readonly UV_SHA512SUM_LINUX_X86_64='a775b95f84b441e2b722fcc336a87022161cc91dd3584a6f54dbe1cabf7ea71b5e3391398ac88616acf072603945bc62b31f71e304047d8f0baa40504884685e'
readonly UV_SHA512SUM_OSX_ARM64='b656946a331f7e96fcafd5ffcead81e39f585a8f9228059de358a897a39a67d0fdc9b7d1a6fa0e7d2b045b5039b5bbbb08658735c9edc818d1837451dff462ec'
readonly UV_SHA512SUM_OSX_X86_64='27f0e0c3dd40753d02357ab38815e1378814ff221ec042e4f017a6f4fd0420e88622caeab1ba70ba4dcf0c98ecde03460c48df79e933368bd82432c401717ec8'
readonly UV_VERSION='0.11.11'

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
