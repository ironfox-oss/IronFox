#!/bin/bash

set -eo pipefail

source "$(dirname $0)/versions.sh"

# If variables are defined with a custom `env_override.sh`, let's use those
if [[ -f "${ROOTDIR}/env_override.sh" ]]; then
    source "${ROOTDIR}/env_override.sh"
fi

if [[ "${OSTYPE}" == "darwin"* ]]; then
    ANDROID_SDK_PLATFORM=mac
    PLATFORM=macos
    PREBUILT_PLATFORM=osx
    # Ensure we use GNU tar on macOS
    TAR=gtar
else
    ANDROID_SDK_PLATFORM=linux
    PLATFORM=linux
    PREBUILT_PLATFORM=linux
    TAR=tar
fi

clone_repo() {
    url="$1"
    path="$2"
    revision="$3"

    if [[ "${url}" == "" ]]; then
        echo "URL missing for clone"
        exit 1
    fi

    if [[ "${path}" == "" ]]; then
        echo "Path is required for cloning '${url}'"
        exit 1
    fi

    if [[ "${revision}" == "" ]]; then
        echo "Revision is required for cloning '${url}'"
        exit 1
    fi

    if [[ -f "${path}" ]]; then
        echo "'${path}' exists and is not a directory"
        exit 1
    fi

    if [[ -d "${path}" ]]; then
        echo "'${path}' already exists"
        read -p "Do you want to re-clone this repository? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return 0
        fi
    fi

    echo "Cloning ${url}::${revision}"
    git clone --revision="${revision}" --depth=1 "${url}" "${path}"
}

download() {
    local url="$1"
    local filepath="$2"

    if [[ "${url}" == "" ]]; then
        echo "URL is required (file: '${filepath}')"
        exit 1
    fi

    if [ -f "${filepath}" ]; then
        echo "${filepath} already exists."
        read -p "Do you want to re-download? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing ${filepath}..."
            rm -f "${filepath}"
        else
            return 0
        fi
    fi

    mkdir -vp "$(dirname "${filepath}")"

    echo "Downloading ${url}"
    wget --https-only --no-cache --secure-protocol=TLSv1_3 --show-progress --verbose "${url}" -O "${filepath}"
}

# Extract zip removing top level directory
extract_rmtoplevel() {
    local archive_path="$1"
    local to_name="$2"
    local extract_to="${ROOTDIR}/external/${to_name}"

    if ! [[ -f "${archive_path}" ]]; then
        echo "Archive '${archive_path}' does not exist!"
    fi

    # Create temporary directory for extraction
    local temp_dir=$(mktemp -d)

    # Extract based on file extension
    case "${archive_path}" in
        *.zip)
            unzip -q "${archive_path}" -d "${temp_dir}"
            ;;
        *.tar.gz)
            $TAR xzf "$archive_path" -C "${temp_dir}"
            ;;
        *.tar.xz)
            $TAR xJf "$archive_path" -C "${temp_dir}"
            ;;
        *.tar.zst)
            $TAR --zstd -xvf "${archive_path}" -C "${temp_dir}"
            ;;
        *)
            echo "Unsupported archive format: ${archive_path}"
            rm -rf "${temp_dir}"
            exit 1
            ;;
    esac

    local top_dir=$(ls "${temp_dir}")
    local to_parent=$(dirname "${extract_to}")

    rm -rf "${extract_to}"
    mkdir -vp "${to_parent}"
    mv "${temp_dir}/${top_dir}" "${to_parent}/${to_name}"

    rm -rf "${temp_dir}"
}

download_and_extract() {
    local repo_name="$1"
    local url="$2"

    local extension
    if [[ "${url}" =~ \.tar\.xz$ ]]; then
        extension=".tar.xz"
    elif [[ "${url}" =~ \.tar\.gz$ ]]; then
        extension=".tar.gz"
    elif [[ "${url}" =~ \.tar\.zst$ ]]; then
        extension=".tar.zst"
    else
        extension=".zip"
    fi

    local repo_archive="${DOWNLOADSDIR}/${repo_name}${extension}"

    download "${url}" "${repo_archive}"

    if [ ! -f "${repo_archive}" ]; then
        echo "Source archive for ${repo_name} does not exist."
        exit 1
    fi

    echo "Extracting ${repo_archive}"
    extract_rmtoplevel "${repo_archive}" "${repo_name}"
    echo
}

if [[ -z ${JAVA_HOME+x} ]]; then
    if [[ "${OSTYPE}" == "darwin"* ]]; then
        export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"
    else
        export JAVA_HOME="/usr/lib/jvm/temurin-17-jdk"
    fi
    export PATH="${JAVA_HOME}/bin:${PATH}"
fi

echo "Downloading the Android SDK..."
download_and_extract "android-cmdline-tools" "https://dl.google.com/android/repository/commandlinetools-${ANDROID_SDK_PLATFORM}-${ANDROID_SDK_REVISION}_latest.zip"
mkdir -vp "${ANDROIDSDKDIR}/cmdline-tools"
mv -v "${ROOTDIR}/external/android-cmdline-tools" "${ANDROIDSDKDIR}/cmdline-tools/latest"

# Accept Android SDK licenses
SDK_MANAGER="${ANDROIDSDKDIR}/cmdline-tools/latest/bin/sdkmanager"
{ yes || true; } | $SDK_MANAGER --sdk_root="${ANDROIDSDKDIR}" --licenses

$SDK_MANAGER "build-tools;${ANDROID_BUILDTOOLS_VERSION}"
$SDK_MANAGER "ndk;${ANDROID_NDK_REVISION}"
$SDK_MANAGER "platforms;android-${ANDROID_PLATFORM_VERSION}"

echo "Downloading Bundletool..."
download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "${BUNDLETOOLDIR}/bundletool.jar"

if ! [[ -f "${BUNDLETOOLDIR}/bundletool" ]]; then
    echo "Creating bundletool script..."
    {
        echo '#!/bin/bash'
        echo "exec java -jar ${BUNDLETOOLDIR}/bundletool.jar \"\$@\""
    } > "${BUNDLETOOLDIR}/bundletool"
    chmod +x "${BUNDLETOOLDIR}/bundletool"
fi

echo "Bundletool is set up at ${BUNDLETOOLDIR}/bundletool"

echo "Downloading F-Droid's Gradle script..."
download "https://gitlab.com/fdroid/gradlew-fdroid/-/raw/${GRADLE_COMMIT}/gradlew.py" "${GRADLEDIR}/gradlew.py"

if ! [[ -f "${GRADLEDIR}/gradle" ]]; then
    echo "Creating Gradle script..."
    {
        echo '#!/bin/bash'
        echo "exec python3 ${GRADLEDIR}/gradlew.py \"\$@\""
    } > "${GRADLEDIR}/gradle"
    chmod +x "${GRADLEDIR}/gradle"
fi

echo "Gradle is set up at ${GRADLEDIR}/gradle"

# Clone Glean
echo "Cloning Glean..."
clone_repo "https://github.com/mozilla/glean.git" "${GLEANDIR}" "${GLEAN_COMMIT}"

# Clone MicroG
echo "Cloning microG..."
clone_repo "https://github.com/microg/GmsCore.git" "${GMSCOREDIR}" "${GMSCORE_COMMIT}"

# Download Phoenix
echo "Downloading Phoenix..."
download "https://gitlab.com/celenityy/Phoenix/-/raw/${PHOENIX_COMMIT}/android/phoenix.js" "${PATCHDIR}/gecko-overlay/ironfox/prefs/000-phoenix.js"
download "https://gitlab.com/celenityy/Phoenix/-/raw/${PHOENIX_COMMIT}/android/phoenix-extended.js" "${PATCHDIR}/gecko-overlay/ironfox/prefs/001-phoenix-extended.js"

# Clone application-services
echo "Cloning application-services..."
clone_repo "https://github.com/mozilla/application-services.git" "${APPSERVICESDIR}" "${APPSERVICES_COMMIT}"

# Clone firefox-l10n
echo "Cloning firefox-l10n..."
clone_repo "https://github.com/mozilla-l10n/firefox-l10n.git" "${L10NDIR}" "${L10N_COMMIT}"

# Clone Firefox
echo "Cloning Firefox..."
clone_repo "https://github.com/mozilla-firefox/firefox.git" "${GECKODIR}" "${FIREFOX_COMMIT}"

# Prebuilds
if [[ "${NO_PREBUILDS}" == "1" ]]; then
    echo "Cloning the prebuilds build repository..."
    clone_repo "https://gitlab.com/ironfox-oss/prebuilds.git" "${PREBUILDSDIR}" "${PREBUILDS_COMMIT}"

    pushd "${PREBUILDSDIR}"
    echo "Downloading prebuild sources..."
    bash "${PREBUILDSDIR}/scripts/get_sources.sh"
    popd

    UNIFFIDIR="${PREBUILDSDIR}/build/outputs/uniffi-rs/uniffi-rs"
    WASISDKDIR="${PREBUILDSDIR}/build/outputs/wasi-sdk/wasi"
else
    # Get Tor's no-op UniFFi binding generator
    echo "Downloading prebuilt uniffi-bindgen..."
    if [[ "${PLATFORM}" == "macos" ]]; then
        download_and_extract "uniffi" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_OSX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/${PREBUILT_PLATFORM}/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_OSX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
    else
        download_and_extract "uniffi" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_LINUX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/${PREBUILT_PLATFORM}/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_LINUX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
    fi

    # Get WebAssembly SDK
    echo "Downloading prebuilt wasi-sdk..."
    if [[ "${PLATFORM}" == "macos" ]]; then
        download_and_extract "wasi-sdk" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_OSX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/${PREBUILT_PLATFORM}/wasi-sdk-${WASI_VERSION}-${WASI_OSX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
    else
        download_and_extract "wasi-sdk" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_LINUX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/${PREBUILT_PLATFORM}/wasi-sdk-${WASI_VERSION}-${WASI_LINUX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
    fi
fi

# Write env_local.sh
echo "Writing ${ENV_SH}..."
cat > "${ENV_SH}" << EOF
export builddir="${BUILDDIR}"
export outputsdir="${OUTPUTSDIR}"
export patches="${PATCHDIR}"
export rootdir="${ROOTDIR}"
export android_components="${ANDROID_COMPONENTS}"
export android_ndk_dir="${ANDROIDSDKDIR}/ndk/${ANDROID_NDK_REVISION}"
export android_sdk_dir="${ANDROIDSDKDIR}"
export application_services="${APPSERVICESDIR}"
export bundletool="${BUNDLETOOLDIR}"
export fenix="${FENIX}"
export glean="${GLEANDIR}"
export gmscore="${GMSCOREDIR}"
export gradle="${GRADLEDIR}/gradle"
export l10n_central="${L10NDIR}"
export mozilla_release="${GECKODIR}"
export prebuilds="${PREBUILDSDIR}"
export uniffi="${UNIFFIDIR}"
export wasi="${WASISDKDIR}"

export IRONFOX_TARGET_ARCH={IRONFOX_TARGET_ARCH}

source "\${rootdir}/scripts/env_common.sh"
EOF
