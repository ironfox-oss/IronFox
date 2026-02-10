#!/bin/bash

set -euo pipefail

# Functions
echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

if [[ -z "${IRONFOX_FROM_SOURCES+x}" ]]; then
    echo_red_text "ERROR: Do not call get_sources-if.sh directly. Instead, use get_sources.sh." >&1
    exit 1
fi

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Include version info
source "${IRONFOX_VERSIONS}"

if [[ "${IRONFOX_OS}" == 'osx' ]]; then
    ANDROID_SDK_PLATFORM='mac'
    PLATFORM='macos'
    PREBUILT_PLATFORM='osx'
else
    ANDROID_SDK_PLATFORM='linux'
    PLATFORM='linux'
    PREBUILT_PLATFORM='linux'
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
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo "Removing ${path}..."
            rm -rf "${path}"
        else
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
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo "Removing ${filepath}..."
            rm -f "${filepath}"
        else
            return 0
        fi
    fi

    mkdir -vp "$(dirname "${filepath}")"

    echo "Downloading ${url}"
    curl ${IRONFOX_CURL_FLAGS} -sSL "${url}" -o "${filepath}"
}

# Extract zip removing top level directory
extract_rmtoplevel() {
    local archive_path="$1"
    local to_name="$2"
    local extract_to="${IRONFOX_EXTERNAL}/${to_name}"

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
            "${IRONFOX_TAR}" xzf "${archive_path}" -C "${temp_dir}"
            ;;
        *.tar.xz)
            "${IRONFOX_TAR}" xJf "${archive_path}" -C "${temp_dir}"
            ;;
        *.tar.zst)
            "${IRONFOX_TAR}" --zstd -xvf "${archive_path}" -C "${temp_dir}"
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

    local repo_archive="${IRONFOX_DOWNLOADS}/${repo_name}${extension}"

    download "${url}" "${repo_archive}"

    if [ ! -f "${repo_archive}" ]; then
        echo "Source archive for ${repo_name} does not exist."
        exit 1
    fi

    echo "Extracting ${repo_archive}"
    extract_rmtoplevel "${repo_archive}" "${repo_name}"
    echo
}

echo "Downloading the Android SDK..."
download_and_extract "android-cmdline-tools" "https://dl.google.com/android/repository/commandlinetools-${ANDROID_SDK_PLATFORM}-${ANDROID_SDK_REVISION}_latest.zip"
mkdir -vp "${IRONFOX_ANDROID_SDK}/cmdline-tools"
mv -v "${IRONFOX_EXTERNAL}/android-cmdline-tools" "${IRONFOX_ANDROID_SDK}/cmdline-tools/latest"

# Accept Android SDK licenses
{ yes || true; } | ${IRONFOX_ANDROID_SDKMANAGER} --sdk_root="${IRONFOX_ANDROID_SDK}" --licenses

${IRONFOX_ANDROID_SDKMANAGER} "build-tools;${ANDROID_BUILDTOOLS_VERSION}"
${IRONFOX_ANDROID_SDKMANAGER} "ndk;${ANDROID_NDK_REVISION}"
${IRONFOX_ANDROID_SDKMANAGER} "platforms;android-${ANDROID_PLATFORM_VERSION}"

echo "Downloading Bundletool..."
download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}"

if ! [[ -f "${IRONFOX_BUNDLETOOL}" ]]; then
    echo "Creating bundletool script..."
    {
        echo '#!/bin/bash'
        echo "exec java -jar ${IRONFOX_BUNDLETOOL_JAR} \"\$@\""
    } > "${IRONFOX_BUNDLETOOL}"
    chmod +x "${IRONFOX_BUNDLETOOL}"
fi

echo "Bundletool is set-up at ${IRONFOX_BUNDLETOOL}"

echo "Downloading F-Droid's Gradle script..."
download "https://gitlab.com/fdroid/gradlew-fdroid/-/raw/${GRADLE_COMMIT}/gradlew.py" "${IRONFOX_GRADLE_DIR}/gradlew.py"

if ! [[ -f "${IRONFOX_GRADLE}" ]]; then
    echo "Creating Gradle script..."
    {
        echo '#!/bin/bash'
        echo "exec python3 ${IRONFOX_GRADLE_DIR}/gradlew.py \"\$@\""
    } > "${IRONFOX_GRADLE}"
    chmod +x "${IRONFOX_GRADLE}"
fi

echo "Gradle is set-up at ${IRONFOX_GRADLE}"

# Clone Glean
echo "Cloning Glean..."
clone_repo "https://github.com/mozilla/glean.git" "${IRONFOX_GLEAN}" "${GLEAN_COMMIT}"

# Clone microG
echo "Cloning microG..."
clone_repo "https://github.com/microg/GmsCore.git" "${IRONFOX_GMSCORE}" "${GMSCORE_COMMIT}"

# Clone unifiedpush-ac
echo "Cloning unifiedpush-ac..."
clone_repo "https://gitlab.com/ironfox-oss/unifiedpush-ac.git" "${IRONFOX_UP_AC}" "${UNIFIEDPUSHAC_COMMIT}"

# Download Phoenix
echo "Downloading Phoenix..."
download "https://gitlab.com/celenityy/Phoenix/-/raw/${PHOENIX_COMMIT}/android/phoenix.js" "${IRONFOX_GECKO_OVERLAY}/ironfox/prefs/000-phoenix.js"
download "https://gitlab.com/celenityy/Phoenix/-/raw/${PHOENIX_COMMIT}/android/phoenix-extended.js" "${IRONFOX_GECKO_OVERLAY}/ironfox/prefs/001-phoenix-extended.js"

# Clone application-services
echo "Cloning application-services..."
clone_repo "https://github.com/mozilla/application-services.git" "${IRONFOX_AS}" "${APPSERVICES_COMMIT}"

# Clone firefox-l10n
echo "Cloning firefox-l10n..."
clone_repo "https://github.com/mozilla-l10n/firefox-l10n.git" "${IRONFOX_L10N_CENTRAL}" "${L10N_COMMIT}"

# Clone Firefox
echo "Cloning Firefox..."
clone_repo "https://github.com/mozilla-firefox/firefox.git" "${IRONFOX_GECKO}" "${FIREFOX_COMMIT}"

# Prebuilds
if [[ "${IRONFOX_NO_PREBUILDS}" == "1" ]]; then
    echo "Cloning the prebuilds build repository..."
    clone_repo "https://gitlab.com/ironfox-oss/prebuilds.git" "${IRONFOX_PREBUILDS}" "${PREBUILDS_COMMIT}"

    pushd "${IRONFOX_PREBUILDS}"
    echo "Downloading prebuild sources..."
    bash "${IRONFOX_PREBUILDS}/scripts/get_sources.sh"
    popd

    UNIFFIDIR="${IRONFOX_PREBUILDS}/build/outputs/uniffi-rs/uniffi-rs"
    WASISDKDIR="${IRONFOX_PREBUILDS}/build/outputs/wasi-sdk/wasi"
else
    # Get Tor's no-op UniFFi binding generator
    echo "Downloading prebuilt uniffi-bindgen..."
    if [[ "${IRONFOX_OS}" == 'osx' ]]; then
        download_and_extract "uniffi" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_OSX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/${PREBUILT_PLATFORM}/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_OSX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
    else
        download_and_extract "uniffi" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_LINUX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/${PREBUILT_PLATFORM}/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_LINUX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
    fi

    # Get WebAssembly SDK
    echo "Downloading prebuilt wasi-sdk..."
    if [[ "${IRONFOX_OS}" == 'osx' ]]; then
        download_and_extract "wasi-sdk" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_OSX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/${PREBUILT_PLATFORM}/wasi-sdk-${WASI_VERSION}-${WASI_OSX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
    else
        download_and_extract "wasi-sdk" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_LINUX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/${PREBUILT_PLATFORM}/wasi-sdk-${WASI_VERSION}-${WASI_LINUX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
    fi
fi
