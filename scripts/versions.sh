
# Sources

## Firefox
### https://github.com/mozilla-firefox/firefox
### (This commit corresponds to https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX-ANDROID_149_0_2_RELEASE)
readonly FIREFOX_COMMIT='d8bbe6c514825d2de3f47a26c177b3b523d4e459'
readonly FIREFOX_SHA512SUM='94f8a3824aba13d847b36a0509a56e0128d58a4d27f874b83cef2518491e8cc176741919c71cb1de9e77a4d3eeb4ab6c7a36fb9dea2275d7a46d9860b5e92751'
readonly FIREFOX_VERSION='149.0.2'

readonly IRONFOX_VERSION="${FIREFOX_VERSION}"

## Application Services
### https://github.com/mozilla/application-services
readonly APPSERVICES_COMMIT='c19ea2c24eb2f116dae170f5f82054d325e94a42'
readonly APPSERVICES_SHA512SUM='087de733cf9bbef46678c18a51f6b87a4a2fe92b62db57f68fb118ee05d9c497506883ec41696c04b156a47a1304cbdaa823128d7dcf42f1fa659ae188175f6c'
readonly APPSERVICES_VERSION='149.0'

## firefox-l10n
### https://github.com/mozilla-l10n/firefox-l10n
### NOTE: This repo is updated several times a day...
### so I think best approach here will be for us to just update it alongside new releases
readonly L10N_COMMIT='2c1fd95a5ad5c78ab96d8cf05ddc3047287b2a36'
readonly L10N_SHA512SUM='1769898b0340b97e82c241dc78c9a7be8ae7a991210828da4ed9b8e2e10fad89d74c2676f53f28918473b5483506c341a44c0b6f787f6c26ca0ed2076baccbc8'

## Glean
### https://github.com/mozilla/glean
readonly GLEAN_COMMIT='a793015bad500379ec5480e280ac2631178a2013'
readonly GLEAN_SHA512SUM='bc5602f409c392ce929ab62fe8d3ad3bd2f84e6821bae9c091b2f557230849bd27a244aa268b6c286a6a8a609c801b08bb23831dd2380eb5bf93dd375206a075'
readonly GLEAN_VERSION='67.0.0'

## Glean Parser
### Version: v18.2.0
### https://github.com/mozilla/glean_parser
readonly GLEAN_PARSER_COMMIT='39c9b070d429983db233e7435ae7dfe69f48a543'
readonly GLEAN_PARSER_SHA512SUM='3c856424aef82f1d793e7b2ed78df175e4bb445dc05e8a0b75752a6ed2aa1cbc097d0f355e13bf6f5b5aec9f3d53df53a23763c51f4a3747b57b80d45d37033d'
readonly GLEAN_PARSER_VERSION='18.2.0'

## GYP
### Version: v0.22.0
### https://github.com/nodejs/gyp-next
readonly GYP_COMMIT='2b1e2243251b1d990e592be85c3a61b8d9a11a1e'
readonly GYP_SHA512SUM='a8a5d6997084bf2276711982dcea63ca6ac921a5a5e65a262539acf8803444e7326337a7e1361e45f8c2f9250603b27f8158b276bc77c20b37221745e6f4fa4d'

## microG
### Version: v0.3.14.250932
### https://github.com/microg/GmsCore
readonly GMSCORE_COMMIT='a5e0d9719a0f0e3a4a8dc032a6d67199ac497782'
readonly GMSCORE_SHA512SUM='27d96a993574e0f4f5c67c59bfafefbc6701c3484a5097a604388843a3fcb5df0415867b52a48bff16e27e695f9fd8d7de25f2f1b19b8ce0c11bd12c364032ad'

## Phoenix
### https://gitlab.com/celenityy/Phoenix
readonly PHOENIX_COMMIT='9a7e49256837ce1928265734be1ea110c76b8aa4'
readonly PHOENIX_SHA512SUM='4f89e53d23275a70621bad771047462195d668b9da3e5eda7191a09401681826416bd9a803e1b3dedfe70415d68d1bb7bde19c1396edae6f76847d11ecba4dbb'
readonly PHOENIX_VERSION='2026.03.31.1'

## uniffi-rs (Tor)
### https://gitlab.torproject.org/tpo/applications/uniffi-rs
readonly UNIFFI_VERSION='0.31.0'

## UnifiedPush-AC
### Version: 1.0.1
### https://gitlab.com/ironfox-oss/unifiedpush-ac
readonly UNIFIEDPUSHAC_COMMIT='5b0bd320723dd31c2c25ae3573650a8221eef89a'
readonly UNIFIEDPUSHAC_SHA512SUM='92653a1b1a36b9482abebf916080e41621915f4c11ee1453890525c0888ef977f7caa6bc4d73c2c1b682dfa0b74010002c44cbe5eb9bcaffbd600cc960663e3c'

## WASI SDK
### https://github.com/WebAssembly/wasi-sdk
readonly WASI_VERSION='20'

# Tools

## Android NDK
### https://developer.android.com/ndk/downloads
readonly ANDROID_NDK_REVISION='29.0.14206865'
readonly ANDROID_NDK_SHA512SUM_LINUX='b55819895a7fa3a0bc7ed411fb55ed15ad9e415b0122a81a4e026c9b696cd266cb4beebb2008cf1d6cac88d38187d52818734f87de793de303653eccb4ca68da'
readonly ANDROID_NDK_SHA512SUM_OSX='4091bc97a03266b869380874cb2d67a35dc74f9bc5f1cde30a3545547355e4ec4f3ebd79a17a19f9228d045f7a176d1e987ce4f787d81a02a044aa909f5ef5cb'
readonly ANDROID_NDK_VERSION='r29'

## Android SDK (Command-Line Tools)
### https://developer.android.com/tools/releases/cmdline-tools
### (for reference: https://searchfox.org/firefox-main/source/python/mozboot/mozboot/android.py)
readonly ANDROID_SDK_REVISION='13114758'
readonly ANDROID_SDK_SHA512SUM_LINUX='8e4bce8fb1a9a2b83454ab9ea642caa08adc69d93df345238a9c110a29aeb3dd4211ce9464de6d5ce41182c77ad2ff8c1941ed8a0b1f40d267fdfc8a31f461dc'
readonly ANDROID_SDK_SHA512SUM_OSX='375e0594493ade7ab613bacdfbc751c5f004db213b02c6202ac28f4b6174ed9fc5d514b189bbfafd3d9d8c8d7d81b3fb312c0454b79e53ab9d139b90790d2a96'

## Android SDK Build Tools
### https://developer.android.com/tools/releases/build-tools
readonly ANDROID_SDK_BUILD_TOOLS_VERSION='r36.1'
readonly ANDROID_SDK_BUILD_TOOLS_VERSION_STRING='36.1.0'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX='32a1eea273980a96745ae5e0b141720e5f91c6c6f83f42da4244fad36025d7750521fdf678a7d332afe5946057b498264343c2533ba524967d84347af9cd7ce5'
readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX='07a78d5f4658c6809220012fc27560cfd8aefcbd29a6414aa309fc54d6df7751b7b1e59964e3942ff9b91030c2611639e2b7d7eb2f77aba1ab0933c015e7c802'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX='b45dc6b7298567f3b45428def0b85584b99b125a3719dfb74a82732bf2b86a0c66161682f3c3d7a50cefaf6e1a2d993975665272e16f00b231a15a9a4512cc1e'
readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX='991db0bbf23acd212b6be57033cdb3ecd5c8c8da79781a6e4326c046c2079b2827892084ee5f77b1fc5d5ef91fc62a4820d43218d3943f0c43e5c093c58c4999'

## Android SDK Platform
### https://developer.android.com/tools/releases/platforms
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
### (Used by nvm)
readonly NODE_VERSION='25.8.1'

## npm
### https://github.com/npm/cli
readonly NPM_SHA512SUM='cdca14b85d647b3192028d02aadbe82d75f79a446aceea9874be98e6d768f20ebd3555770a48d0e9906106007877bbc690f715e9372f2e2dc644a3c3157fb14c'
readonly NPM_VERSION='11.12.1'

## nvm
### Version: v0.40.4
### https://github.com/nvm-sh/nvm
readonly NVM_COMMIT='62387b8f92aa012d48202747fd75c40850e5e261'
readonly NVM_SHA512SUM='7b88477aa7400050cea6dda3cd197dad7d030fd951cd9aca945c04159fdb98ea3bbdda8a2b1c0761d1cd5d3893c669370b493727298f3b8440f97452fd229abc'

## pip
### Version: 26.0.1
### https://github.com/pypa/pip
### (This commit corresponds to https://github.com/pypa/pip/releases/tag/26.0.1)
readonly PIP_COMMIT='5fe4ea4f24cd9756316a4b5ef05daa15d84f7d0c'
readonly PIP_SHA512SUM='3fca339b7c2596581fcf9691b8ef43664b4d0b25494b30eebda803586134c160a06db128437c2fcce9708e26d6ef9450af2e5d9fe0e724d56f65cfb7dda45e7a'

## Python
### https://github.com/astral-sh/python-build-standalone
readonly PYTHON_GIT_RELEASE='20260408'
readonly PYTHON_SHA512SUM_LINUX_ARM64='734a9a75056849e2f6504cf1e568f171131a3dc51bbe58b1e45a8023519f5895a1767d35ea558d9bee41600a6f5a1e50c007ebeedf0f8843091d9fbba7860775'
readonly PYTHON_SHA512SUM_LINUX_X86_64='d62700ebf742484efbb791e00ac665793451207adf6e66affc6a3a85503a5de651ee871c99343c9b33a39165615c0990834a7b7ea52030fa1653bd048fd7bad4'
readonly PYTHON_SHA512SUM_OSX_ARM64='1baa419f8054fb69133a20cc6e1b556fae9d88767f4228c7adb486de67dcd5c5834c379e7e01ca9cc5bca88426f6b7c11be16894e9d874291e0099c2d806f9c4'
readonly PYTHON_SHA512SUM_OSX_X86_64='e22084f3f37847fb836588a3c9625073154a5db5236687212b29bf0f542379dc5a1b2a0ea471ba7441b906cf91811dfc0715fa160302fff0f477b8e8afb7da37'
readonly PYTHON_VERSION='3.14.4'

## Rust
### https://releases.rs/
# RUST_MAJOR_VERSION='1.94'
# RUST_VERSION="${RUST_MAJOR_VERSION}.0"
readonly RUST_MAJOR_VERSION='1.94.1'
readonly RUST_VERSION="${RUST_MAJOR_VERSION}"

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
readonly UV_SHA512SUM_LINUX_ARM64='5cc2568cfa1d816592202a373e5066b7d815b9cd4c2dcba9aaa21a6491e94b02830383c0c090ac2deed342b23cf7cdbd53795875d301930484f9094c60ff058c'
readonly UV_SHA512SUM_LINUX_X86_64='3198b87d735d8a9b2e4fcd4977812892896bd1d9582c7170469414a115a8d1be2130cce71e53dbb4ef3f35192d6be905106a9f2ed8ffdec8fc020528f5689a80'
readonly UV_SHA512SUM_OSX_ARM64='0e04de5453f51b2730d8a97ade2cc4e5f6c553d33064aab7a8a8484ca68ebae89c16a9661dc648fe6a0b82532770ab16b0a6034a91d9201a9ca3b2200cfe86c4'
readonly UV_SHA512SUM_OSX_X86_64='e85ef8c68f7f19ebf033e4e81c696a176b2ac408b054de8425b6dd2633054d1c8440f9be05e781e7e9de5b71efb1faf1c034b08bcbb24df9c75fcb3419f58324'
readonly UV_VERSION='0.11.6'

# For prebuilds
## https://gitlab.com/ironfox-oss/prebuilds
readonly PREBUILDS_COMMIT='241af63561e4b4c9cf14d67d585f498a53bbf501'
readonly PREBUILDS_SHA512SUM='12780ab9fb64eb1884753efe3332b135b1c4511087e693932ffc8832143d8c162b3ac8bb7c8bbf06aa30caf2667fa101ffa9c38595a7fe99aecda292e27f4247'
readonly UNIFFI_LINUX_IRONFOX_COMMIT='241af63561e4b4c9cf14d67d585f498a53bbf501'
readonly UNIFFI_LINUX_IRONFOX_REVISION='8'
readonly UNIFFI_LINUX_IRONFOX_SHA512SUM='16f1a822943ed5c6d83cb52bd941449d7d81e7ed01ae3870775eed2030e0198a1047075f61e2d639db8da87dd021051f1a967f64b419869d2b363253b71ca580'
readonly UNIFFI_OSX_IRONFOX_COMMIT='355f1d4ed384c726525e635b6c0a0e11823b25ba'
readonly UNIFFI_OSX_IRONFOX_REVISION='8'
readonly UNIFFI_OSX_IRONFOX_SHA512SUM='e4df533aae8157270f973b7d0a01d2fc619fa570955684b62ad9c3261a141e312c3dff0d2f1f283f90d0053afeaf36016a44c3491e6fe0c69696da97ddf4e13a'
readonly WASI_LINUX_IRONFOX_COMMIT='b76a3b2a8f3124e9297036e3b27802a47c0263a4'
readonly WASI_LINUX_IRONFOX_REVISION='4'
readonly WASI_LINUX_IRONFOX_SHA512SUM='98d81e0f47229184fe767fb47906685eec6dd34ad425030e08d1eea42ddec1ebef678530e70dfc954aa2d0904ac44d38a869334c098b0baf9fff1b87233ff31e'
readonly WASI_OSX_IRONFOX_COMMIT='97f5fb17ea756670c452e832ae3fca80d0498a82'
readonly WASI_OSX_IRONFOX_REVISION='3'
readonly WASI_OSX_IRONFOX_SHA512SUM='eb0697f42c9838080fcf23fa0d9c230016212a15725e62e2fafed896751a9fcf8adf508461cf9118c02bff1bcd0791ae1113f13d0cca96de3b8f03244df25a30'
