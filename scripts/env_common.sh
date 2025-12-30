
# Caution: Should not be sourced directly!
# Use 'env_local.sh' or 'env_fdroid.sh' instead.

# Set platform
if [[ "${OSTYPE}" == "darwin"* ]]; then
    export IRONFOX_PLATFORM='darwin'
else
    export IRONFOX_PLATFORM='linux'
fi

# Set architecture
PLATFORM_ARCH=$(uname -m)
if [[ "${PLATFORM_ARCH}" == 'arm64' ]]; then
    export IRONFOX_PLATFORM_ARCH='aarch64'
else
    export IRONFOX_PLATFORM_ARCH='x86-64'
fi

# Get our current commit
## (This is ex. displayed at `about:buildconfig` in Gecko/Firefox)
export IRONFOX_REVISION="$(git log -1 --format="%H" | tail -n 1)"

# Outputs directory
if [[ -z ${IRONFOX_OUTPUTS+x} ]]; then
    export IRONFOX_OUTPUTS="${outputsdir}"
fi

# Android NDK
if [[ -z ${IRONFOX_ANDROID_NDK+x} ]]; then
    export IRONFOX_ANDROID_NDK="${android_ndk_dir}"
fi
export ANDROID_NDK_HOME="${IRONFOX_ANDROID_NDK}"
export ANDROID_NDK_ROOT="${IRONFOX_ANDROID_NDK}"

# Android SDK
if [[ -z ${IRONFOX_ANDROID_SDK+x} ]]; then
    export IRONFOX_ANDROID_SDK="${android_sdk_dir}"
fi
export ANDROID_HOME="${IRONFOX_ANDROID_SDK}"
export ANDROID_SDK_ROOT="${IRONFOX_ANDROID_SDK}"

# Application Services
if [[ -z ${IRONFOX_AS+x} ]]; then
    export IRONFOX_AS="${application_services}"
fi

# Bundletool
if [[ -z ${IRONFOX_BUNDLETOOl+x} ]]; then
    export IRONFOX_BUNDLETOOL="${bundletool}"
fi

# Gecko
if [[ -z ${IRONFOX_GECKO+x} ]]; then
    export IRONFOX_GECKO="${mozilla_release}"
fi

## Android Components
export IRONFOX_AC="${IRONFOX_GECKO}/mobile/android/android-components"

## Fenix
export IRONFOX_FENIX="${IRONFOX_GECKO}/mobile/android/fenix"

# Gecko locales
if [[ -z ${IRONFOX_LOCALES+x} ]]; then
    export IRONFOX_LOCALES=$(<"${patches}/locales")
fi

# Glean
if [[ -z ${IRONFOX_GLEAN+x} ]]; then
    export IRONFOX_GLEAN="${glean}"
fi

# GNU make
if [[ -z ${IRONFOX_MAKE+x} ]]; then
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        export IRONFOX_MAKE='gmake'
    else
        export IRONFOX_MAKE='make'
    fi
fi

# GNU sed
if [[ -z ${IRONFOX_SED+x} ]]; then
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        export IRONFOX_SED='gsed'
    else
        export IRONFOX_SED='sed'
    fi
fi

# Gradle
if [[ -z ${IRONFOX_GRADLE+x} ]]; then
    export IRONFOX_GRADLE="${gradle}"
fi

if [[ -z ${IRONFOX_GRADLE_CACHE+x} ]]; then
    export IRONFOX_GRADLE_CACHE="${builddir}/gradle/cache"
fi
export CACHEDIR="${IRONFOX_GRADLE_CACHE}"

if [[ -z ${IRONFOX_GRADLE_HOME+x} ]]; then
    export IRONFOX_GRADLE_HOME="${builddir}/.gradle"
fi
export GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"

# Home
## (ex. used by our mozconfigs for setting the local Maven repo)
if [[ -z ${IRONFOX_HOME+x} ]]; then
    export IRONFOX_HOME="${HOME}"
fi

# Java
if [[ -z ${IRONFOX_JAVA_HOME+x} ]]; then
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        export IRONFOX_JAVA_HOME='/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home'
    else
        export IRONFOX_JAVA_HOME='/usr/lib/jvm/temurin-17-jdk'
    fi
fi
export JAVA_HOME="${IRONFOX_JAVA_HOME}"
export PATH="${IRONFOX_JAVA_HOME}/bin:${PATH}"

# libclang
if [[ -z ${IRONFOX_LIBCLANG+x} ]]; then
    if [[ "${IRONFOX_PLATFORM}" == "darwin" ]]; then
        export IRONFOX_LIBCLANG="${IRONFOX_ANDROID_NDK}/toolchains/llvm/prebuilt/${IRONFOX_PLATFORM}-x86_64/lib"
    else
        export IRONFOX_LIBCLANG="${IRONFOX_ANDROID_NDK}/toolchains/llvm/prebuilt/${IRONFOX_PLATFORM}-x86_64/musl/lib"
    fi
fi

# Mach
## https://firefox-source-docs.mozilla.org/mach/usage.html#user-settings
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#95
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#284
export DISABLE_TELEMETRY=1
export MACHRC="${patches}/machrc"
export MOZCONFIG="${mozilla_release}/mozconfig"

# microG
if [[ -z ${IRONFOX_GMSCORE+x} ]]; then
    export IRONFOX_GMSCORE="${gmscore}"
fi
export GRADLE_MICROG_VERSION_WITHOUT_GIT=1

# mozbuild
if [[ -z ${IRONFOX_MOZBUILD+x} ]]; then
    export IRONFOX_MOZBUILD="${builddir}/.mozbuild"
fi
export MOZBUILD_STATE_PATH="${IRONFOX_MOZBUILD}"

# nproc
if [[ -z ${IRONFOX_NPROC+x} ]]; then
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        export IRONFOX_NPROC='sysctl -n hw.logicalcpu'
    else
        export IRONFOX_NPROC='nproc'
    fi
fi

# NSS
if [[ -z ${IRONFOX_NSS_DIR+x} ]]; then
    export IRONFOX_NSS_DIR="${application_services}/libs/desktop/${IRONFOX_PLATFORM}-${IRONFOX_PLATFORM_ARCH}/nss"
fi
export NSS_DIR="${IRONFOX_NSS_DIR}"
export NSS_STATIC=1

# IronFox prebuilds
if [[ -z ${IRONFOX_PREBUILDS+x} ]]; then
    export IRONFOX_PREBUILDS="${prebuilds}"
fi

# Python (pip)
if [[ -z ${IRONFOX_PIP_ENV+x} ]]; then
    export IRONFOX_PIP_ENV="${builddir}/pyenv"
fi

## For macOS, ensure that Python 3.9 is in PATH
if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
    export PATH="${PATH}:$(brew --prefix)/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/bin"
fi

# Rust (cargo)
if [[ -z ${IRONFOX_CARGO_HOME+x} ]]; then
    export IRONFOX_CARGO_HOME="${builddir}/.cargo"
fi
export CARGO_HOME="${IRONFOX_CARGO_HOME}"

# uniffi-bindgen
if [[ -z ${IRONFOX_UNIFFI+x} ]]; then
    export IRONFOX_UNIFFI="${uniffi}"
fi

# WASI SDK
if [[ -z ${IRONFOX_WASI+x} ]]; then
    export IRONFOX_WASI="${wasi}"
fi

# Curl flags
IRONFOX_CURL_FLAGS_DEFAULT='--doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error'
if [[ -z ${IRONFOX_CURL_FLAGS+x} ]]; then
    export IRONFOX_CURL_FLAGS="${IRONFOX_CURL_FLAGS_DEFAULT}"
else
    export IRONFOX_CURL_FLAGS="${IRONFOX_CURL_FLAGS_DEFAULT} ${IRONFOX_CURL_FLAGS}"
fi

# Compiler flags
IRONFOX_COMPILER_FLAGS_DEFAULT='-DNDEBUG -O3 -fstack-clash-protection -fstack-protector-strong -ftrivial-auto-var-init=zero -fwrapv'
if [[ -z ${IRONFOX_COMPILER_FLAGS+x} ]]; then
    export IRONFOX_COMPILER_FLAGS="${IRONFOX_COMPILER_FLAGS_DEFAULT}"
else
    export IRONFOX_COMPILER_FLAGS="${IRONFOX_COMPILER_FLAGS_DEFAULT} ${IRONFOX_COMPILER_FLAGS}"
fi
export TARGET_CFLAGS="${IRONFOX_COMPILER_FLAGS}"

# Gradle flags
IRONFOX_GRADLE_FLAGS_DEFAULT='-Dorg.gradle.configuration-cache=false --no-build-cache --no-configuration-cache'
if [[ -z ${IRONFOX_GRADLE_FLAGS+x} ]]; then
    export IRONFOX_GRADLE_FLAGS="${IRONFOX_GRADLE_FLAGS_DEFAULT}"
else
    export IRONFOX_GRADLE_FLAGS="${IRONFOX_GRADLE_FLAGS_DEFAULT} ${IRONFOX_GRADLE_FLAGS}"
fi

# Rust flags
IRONFOX_RUST_FLAGS_DEFAULT='-Cdebug-assertions=false -Copt-level=3 -Crelro-level=full'
if [[ -z ${IRONFOX_RUST_FLAGS+x} ]]; then
    export IRONFOX_RUST_FLAGS="${IRONFOX_RUST_FLAGS_DEFAULT}"
else
    export IRONFOX_RUST_FLAGS="${IRONFOX_RUST_FLAGS_DEFAULT} ${IRONFOX_RUST_FLAGS}"
fi

export ARTIFACTS="${rootdir}/artifacts"
export APK_ARTIFACTS=${ARTIFACTS}/apk
export APKS_ARTIFACTS=${ARTIFACTS}/apks
export AAR_ARTIFACTS=${ARTIFACTS}/aar

mkdir -vp "${APK_ARTIFACTS}"
mkdir -vp "${APKS_ARTIFACTS}"
mkdir -vp "${AAR_ARTIFACTS}"

if [[ -z ${IRONFOX_RELEASE+x} ]]; then
    # Default to a "nightly" dev build
    export IRONFOX_RELEASE=0

    echo "Preparing to build IronFox Nightly..."
fi

# Set release channel
if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
    export IRONFOX_CHANNEL='release'
else
    export IRONFOX_CHANNEL='nightly'
fi

if [[ -z ${IRONFOX_UBO_ASSETS_URL+x} ]]; then
    # Default to development assets
    export IRONFOX_UBO_ASSETS_URL="https://gitlab.com/ironfox-oss/assets/-/raw/main/uBlock/assets.dev.json"

    echo "Using uBO Assets: ${IRONFOX_UBO_ASSETS_URL}"
fi

# Set target ABI
if [[ "${IRONFOX_TARGET_ARCH}" == 'arm' ]]; then
    export IRONFOX_TARGET_ABI='armeabi-v7a'
    export IRONFOX_TARGET_RUST='arm'
fi
if [[ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]]; then
    export IRONFOX_TARGET_ABI='arm64-v8a'
    export IRONFOX_TARGET_RUST='arm64'
fi
if [[ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]]; then
    export IRONFOX_TARGET_ABI='x86_64'
    export IRONFOX_TARGET_RUST='x86_64'
fi
if [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
    export IRONFOX_TARGET_ABI='"arm64-v8a", "armeabi-v7a", "x86_64"'
    export IRONFOX_TARGET_RUST='arm64,arm,x86_64'
fi
