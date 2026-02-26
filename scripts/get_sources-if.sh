#!/bin/bash

set -euo pipefail

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

if [[ -z "${IRONFOX_FROM_SOURCES+x}" ]]; then
    echo_red_text "ERROR: Do not call get_sources-if.sh directly. Instead, use get_sources.sh." >&1
    exit 1
fi

target="$1"

# Set-up target parameters
IRONFOX_GET_SOURCE_ANDROID_SDK=0
IRONFOX_GET_SOURCE_AS=0
IRONFOX_GET_SOURCE_BUNDLETOOL=0
IRONFOX_GET_SOURCE_CBINDGEN=0
IRONFOX_GET_SOURCE_GECKO=0
IRONFOX_GET_SOURCE_GECKO_L10N=0
IRONFOX_GET_SOURCE_GLEAN=0
IRONFOX_GET_SOURCE_GLEAN_PARSER=0
IRONFOX_GET_SOURCE_GRADLE=0
IRONFOX_GET_SOURCE_GYP=0
IRONFOX_GET_SOURCE_MICROG=0
IRONFOX_GET_SOURCE_PHOENIX=0
IRONFOX_GET_SOURCE_PIP=0
IRONFOX_GET_SOURCE_PREBUILDS=0
IRONFOX_GET_SOURCE_RUST=0
IRONFOX_GET_SOURCE_UP_AC=0

if [ "${target}" == 'android-sdk' ]; then
    # Get Android SDK
    IRONFOX_GET_SOURCE_ANDROID_SDK=1
elif [ "${target}" == 'as' ]; then
    # Get Application Services
    IRONFOX_GET_SOURCE_AS=1
elif [ "${target}" == 'bundletool' ]; then
    # Get + set-up Bundletool
    IRONFOX_GET_SOURCE_BUNDLETOOL=1
elif [ "${target}" == 'cbindgen' ]; then
    # Get cbindgen (from cargo)
    IRONFOX_GET_SOURCE_CBINDGEN=1
elif [ "${target}" == 'firefox' ]; then
    # Get Firefox (Gecko/mozilla-central)
    IRONFOX_GET_SOURCE_GECKO=1
elif [ "${target}" == 'firefox-l10n' ]; then
    # Get firefox-l10n
    IRONFOX_GET_SOURCE_GECKO_L10N=1
elif [ "${target}" == 'glean' ]; then
    # Get Glean
    IRONFOX_GET_SOURCE_GLEAN=1
elif [ "${target}" == 'glean-parser' ]; then
    # Get glean-parser (from pip)
    IRONFOX_GET_SOURCE_GLEAN_PARSER=1
elif [ "${target}" == 'gradle' ]; then
    # Get + set-up Gradle
    IRONFOX_GET_SOURCE_GRADLE=1
elif [ "${target}" == 'gyp' ]; then
    # Get gyp-next (from pip)
    IRONFOX_GET_SOURCE_GYP=1
elif [ "${target}" == 'microg' ]; then
    # Get microG
    IRONFOX_GET_SOURCE_MICROG=1
elif [ "${target}" == 'phoenix' ]; then
    # Get Phoenix
    IRONFOX_GET_SOURCE_PHOENIX=1
elif [ "${target}" == 'pip' ]; then
    # Get + set-up pip
    IRONFOX_GET_SOURCE_PIP=1
elif [ "${target}" == 'prebuilds' ]; then
    # Get IronFox prebuilds
    IRONFOX_GET_SOURCE_PREBUILDS=1
elif [ "${target}" == 'rust' ]; then
    # Get + set-up rust/cargo
    IRONFOX_GET_SOURCE_RUST=1
elif [ "${target}" == 'up-ac' ]; then
    # Get UnifiedPush-AC
    IRONFOX_GET_SOURCE_UP_AC=1
else
    # If no argument is specified (or argument is set to "all"), just get everything
    IRONFOX_GET_SOURCE_ANDROID_SDK=1
    IRONFOX_GET_SOURCE_AS=1
    IRONFOX_GET_SOURCE_BUNDLETOOL=1
    IRONFOX_GET_SOURCE_CBINDGEN=1
    IRONFOX_GET_SOURCE_GECKO=1
    IRONFOX_GET_SOURCE_GECKO_L10N=1
    IRONFOX_GET_SOURCE_GLEAN=1
    IRONFOX_GET_SOURCE_GLEAN_PARSER=1
    IRONFOX_GET_SOURCE_GRADLE=1
    IRONFOX_GET_SOURCE_GYP=1
    IRONFOX_GET_SOURCE_MICROG=1
    IRONFOX_GET_SOURCE_PHOENIX=1
    IRONFOX_GET_SOURCE_PIP=1
    IRONFOX_GET_SOURCE_PREBUILDS=1
    IRONFOX_GET_SOURCE_RUST=1
    IRONFOX_GET_SOURCE_UP_AC=1
fi

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

function clone_repo() {
    url="$1"
    path="$2"
    revision="$3"

    if [[ "${url}" == "" ]]; then
        echo_red_text "ERROR: URL missing for clone"
        exit 1
    fi

    if [[ "${path}" == "" ]]; then
        echo_red_text "ERROR: Path is required for cloning '${url}'"
        exit 1
    fi

    if [[ "${revision}" == "" ]]; then
        echo_red_text "ERROR: Revision is required for cloning '${url}'"
        exit 1
    fi

    if [[ -f "${path}" ]]; then
        echo_red_text "ERROR: '${path}' exists and is not a directory"
        exit 1
    fi

    if [[ -d "${path}" ]]; then
        echo_red_text "'${path}' already exists"
        read -p "Do you want to re-clone this repository? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text "Removing ${path}..."
            rm -rf "${path}"
        else
            return 0
        fi
    fi

    echo_red_text "Cloning ${url}::${revision}..."
    git clone --revision="${revision}" --depth=1 "${url}" "${path}"
}

function download() {
    local url="$1"
    local filepath="$2"

    if [[ "${url}" == "" ]]; then
        echo_red_text "ERROR: URL is required (file: '${filepath}')"
        exit 1
    fi

    if [ -f "${filepath}" ]; then
        echo_red_text "${filepath} already exists."
        read -p "Do you want to re-download? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text "Removing ${filepath}..."
            rm -f "${filepath}"
        else
            return 0
        fi
    fi

    mkdir -vp "$(dirname "${filepath}")"

    echo_red_text "Downloading ${url}..."
    curl ${IRONFOX_CURL_FLAGS} -sSL "${url}" -o "${filepath}"
}

# Extract zip removing top level directory
function extract_rmtoplevel() {
    local archive_path="$1"
    local to_name="$2"
    local extract_to="${IRONFOX_EXTERNAL}/${to_name}"

    if ! [[ -f "${archive_path}" ]]; then
        echo_red_text "ERROR: Archive '${archive_path}' does not exist!"
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
            echo_red_text "ERROR: Unsupported archive format: ${archive_path}"
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

function download_and_extract() {
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
        echo_red_text "ERROR: Source archive for ${repo_name} does not exist."
        exit 1
    fi

    echo_red_text "Extracting ${repo_archive}..."
    extract_rmtoplevel "${repo_archive}" "${repo_name}"
    echo
}

# Get + set-up Android SDK
function get_android_sdk() {
    echo_red_text "Downloading the Android SDK..."
    download_and_extract "android-cmdline-tools" "https://dl.google.com/android/repository/commandlinetools-${ANDROID_SDK_PLATFORM}-${ANDROID_SDK_REVISION}_latest.zip"
    mkdir -vp "${IRONFOX_ANDROID_SDK}/cmdline-tools"
    mv -v "${IRONFOX_EXTERNAL}/android-cmdline-tools" "${IRONFOX_ANDROID_SDK}/cmdline-tools/latest"

    # Accept Android SDK licenses
    { yes || true; } | ${IRONFOX_ANDROID_SDKMANAGER} --sdk_root="${IRONFOX_ANDROID_SDK}" --licenses

    ${IRONFOX_ANDROID_SDKMANAGER} "build-tools;${ANDROID_BUILDTOOLS_VERSION}"
    ${IRONFOX_ANDROID_SDKMANAGER} "ndk;${ANDROID_NDK_REVISION}"
    ${IRONFOX_ANDROID_SDKMANAGER} "platforms;android-${ANDROID_PLATFORM_VERSION}"

    echo_green_text "SUCCESS: Set-up Android SDK at ${IRONFOX_ANDROID_SDK}"
}

# Get Application Services
function get_as() {
    echo_red_text "Cloning Application Services..."
    clone_repo "https://github.com/mozilla/application-services.git" "${IRONFOX_AS}" "${APPSERVICES_COMMIT}"
    echo_green_text "SUCCESS: Set-up Application Services at ${IRONFOX_AS}"
}

# Get + set-up Bundletool
function get_bundletool() {
    echo_red_text "Downloading Bundletool..."
    download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}"

    if ! [[ -f "${IRONFOX_BUNDLETOOL}" ]]; then
        echo_red_text "Creating bundletool script..."
        {
            echo '#!/bin/bash'
            echo "exec java -jar ${IRONFOX_BUNDLETOOL_JAR} \"\$@\""
        } > "${IRONFOX_BUNDLETOOL}"
        chmod +x "${IRONFOX_BUNDLETOOL}"
    fi

    echo_green_text "SUCCESS: Set-up Bundletool at ${IRONFOX_BUNDLETOOL}"
}

# Get cbindgen
function get_cbindgen() {
    if  [ ! -d "${IRONFOX_CARGO_HOME}" ] || [ ! -f "${IRONFOX_CARGO_ENV}" ]; then
        echo_red_text "ERROR: You tried to download cbindgen, but you don't have a Rust environment set-up yet."
        exit 1
    fi

    if [[ -d "${IRONFOX_CARGO_HOME}/bin/cbindgen" ]]; then
        echo_red_text "cbindgen is already installed at ${IRONFOX_CARGO_HOME}/bin/cbindgen."
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        fi
    fi

    source "${IRONFOX_CARGO_ENV}"
    echo_red_text "Downloading cbindgen..."
    cargo +"${RUST_VERSION}" install --force --vers "${CBINDGEN_VERSION}" cbindgen
    echo_green_text "SUCCESS: Set-up cbindgen at ${IRONFOX_CARGO_HOME}/bin/cbindgen"
}

# Get Firefox (Gecko/mozilla-central)
function get_firefox() {
    echo_red_text "Cloning Firefox..."
    clone_repo "https://github.com/mozilla-firefox/firefox.git" "${IRONFOX_GECKO}" "${FIREFOX_COMMIT}"
    echo_green_text "SUCCESS: Set-up Firefox at ${IRONFOX_GECKO}"
}

# Get firefox-l10n
function get_firefox_l10n() {
    echo_red_text "Cloning firefox-l10n..."
    clone_repo "https://github.com/mozilla-l10n/firefox-l10n.git" "${IRONFOX_L10N_CENTRAL}" "${L10N_COMMIT}"
    echo_green_text "SUCCESS: Set-up firefox-l10n at ${IRONFOX_L10N_CENTRAL}"
}

# Get + set-up F-Droid's Gradle script
function get_gradle() {
    echo_red_text "Downloading F-Droid's Gradle script..."
    download "https://gitlab.com/fdroid/gradlew-fdroid/-/raw/${GRADLE_COMMIT}/gradlew.py" "${IRONFOX_GRADLE_DIR}/gradlew.py"

    if ! [[ -f "${IRONFOX_GRADLE}" ]]; then
        echo_red_text "Creating Gradle script..."
        {
            echo '#!/bin/bash'
            echo "exec python3 ${IRONFOX_GRADLE_DIR}/gradlew.py \"\$@\""
        } > "${IRONFOX_GRADLE}"
        chmod +x "${IRONFOX_GRADLE}"
    fi

    echo_green_text "SUCCESS: Set-up Gradle at ${IRONFOX_GRADLE}"
}

# Get Glean
function get_glean() {
    echo_red_text "Cloning Glean..."
    clone_repo "https://github.com/mozilla/glean.git" "${IRONFOX_GLEAN}" "${GLEAN_COMMIT}"
    echo_green_text "SUCCESS: Set-up Glean at ${IRONFOX_GLEAN}"
}

# Get glean-parser
function get_glean_parser() {
    if  [ ! -d "${IRONFOX_PIP_DIR}" ] || [ ! -f "${IRONFOX_PIP_ENV}" ]; then
        echo_red_text "ERROR: You tried to download glean-parser, but you don't have a pip environment set-up yet."
        exit 1
    fi

    if [[ -d "${IRONFOX_PIP_DIR}/bin/glean_parser" ]]; then
        echo_red_text "glean-parser is already installed at ${IRONFOX_PIP_DIR}/bin/glean_parser"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        fi
    fi

    source "${IRONFOX_PIP_ENV}"
    echo_red_text "Downloading glean-parser..."
    pip install glean-parser
    echo_green_text "SUCCESS: Set-up glean-parser at ${IRONFOX_PIP_DIR}/bin/glean_parser"
}

# Get gyp-next
function get_gyp() {
    if  [ ! -d "${IRONFOX_PIP_DIR}" ] || [ ! -f "${IRONFOX_PIP_ENV}" ]; then
        echo_red_text "ERROR: You tried to download gyp-next, but you don't have a pip environment set-up yet."
        exit 1
    fi

    if [[ -d "${IRONFOX_PIP_DIR}/bin/gyp" ]]; then
        echo_red_text "gyp-next is already installed at ${IRONFOX_PIP_DIR}/bin/gyp"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        fi
    fi

    source "${IRONFOX_PIP_ENV}"
    echo_red_text "Downloading gyp-next..."
    pip install gyp-next
    echo_green_text "SUCCESS: Set-up gyp-next at ${IRONFOX_PIP_DIR}/bin/gyp"
}

# Get microG
function get_microg() {
    echo_red_text "Cloning microG..."
    clone_repo "https://github.com/microg/GmsCore.git" "${IRONFOX_GMSCORE}" "${GMSCORE_COMMIT}"
    echo_green_text "SUCCESS: Set-up microG at ${IRONFOX_GMSCORE}"
}

# Get UnifiedPush-AC
function get_up_ac() {
    echo_red_text "Cloning UnifiedPush-AC..."
    clone_repo "https://gitlab.com/ironfox-oss/unifiedpush-ac.git" "${IRONFOX_UP_AC}" "${UNIFIEDPUSHAC_COMMIT}"
    echo_green_text "SUCCESS: Set-up UnifiedPush-AC at ${IRONFOX_UP_AC}"
}

# Get Phoenix
function get_phoenix() {
    echo_red_text "Cloning Phoenix..."
    clone_repo "https://gitlab.com/celenityy/Phoenix.git" "${IRONFOX_PHOENIX}" "${PHOENIX_COMMIT}"
    echo_green_text "SUCCESS: Set-up Phoenix at ${IRONFOX_PHOENIX}"
}

# Get + set-up pip
function get_pip() {
    if [[ -d "${IRONFOX_PIP_DIR}" ]]; then
        echo_red_text "The pip environment is already set-up at ${IRONFOX_PIP_DIR}"
        read -p "Do you want to re-create it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            rm -rf "${IRONFOX_PIP_DIR}"
        fi
    fi

    echo_red_text "Creating pip environment..."
    python3.9 -m venv "${IRONFOX_PIP_DIR}"
    echo_red_text "Updating pip..."
    source "${IRONFOX_PIP_ENV}"
    pip install --upgrade pip
    echo_green_text "SUCCESS: Set-up pip environment at ${IRONFOX_PIP_DIR}"
}

# Get IronFox prebuilds
function get_prebuilds() {
    if [[ "${IRONFOX_NO_PREBUILDS}" == "1" ]]; then
        echo_red_text "Cloning the IronFox prebuilds repository..."
        clone_repo "https://gitlab.com/ironfox-oss/prebuilds.git" "${IRONFOX_PREBUILDS}" "${PREBUILDS_COMMIT}"

        pushd "${IRONFOX_PREBUILDS}"
        echo_red_text "Downloading prebuild sources..."
        bash "${IRONFOX_PREBUILDS}/scripts/get_sources.sh"
        popd

        echo_green_text "SUCCESS: Set-up the IronFox prebuilds repository at ${IRONFOX_PREBUILDS}"
    else
        # Get Tor's no-op UniFFi binding generator
        echo_red_text "Downloading prebuilt uniffi-bindgen..."
        if [[ "${IRONFOX_OS}" == 'osx' ]]; then
            download_and_extract "uniffi" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_OSX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/${PREBUILT_PLATFORM}/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_OSX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
        else
            download_and_extract "uniffi" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_LINUX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/${PREBUILT_PLATFORM}/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_LINUX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
        fi
        echo_green_text "SUCCESS: Set-up the prebuilt uniffi-bindgen at ${IRONFOX_UNIFFI}"

        # Get WebAssembly SDK
        echo_red_text "Downloading prebuilt wasi-sdk..."
        if [[ "${IRONFOX_OS}" == 'osx' ]]; then
            download_and_extract "wasi-sdk" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_OSX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/${PREBUILT_PLATFORM}/wasi-sdk-${WASI_VERSION}-${WASI_OSX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
        else
            download_and_extract "wasi-sdk" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_LINUX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/${PREBUILT_PLATFORM}/wasi-sdk-${WASI_VERSION}-${WASI_LINUX_IRONFOX_REVISION}-${PREBUILT_PLATFORM}.tar.xz"
        fi
        echo_green_text "SUCCESS: Set-up the prebuilt wasi-sdk at ${IRONFOX_WASI}"
    fi
}

# Get + set-up rust/cargo
function get_rust() {
    if [[ -d "${IRONFOX_CARGO_HOME}" ]]; then
        echo_red_text "The Rust environment is already set-up at ${IRONFOX_CARGO_HOME}"
        read -p "Do you want to re-create it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            rm -rf "${IRONFOX_CARGO_HOME}" "${IRONFOX_RUSTUP_HOME}"
        fi
    fi

    echo_red_text "Downloading Rust..."
    curl ${IRONFOX_CURL_FLAGS} -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --no-update-default-toolchain --profile=minimal

    echo_red_text "Creating Rust environment..."
    source "${IRONFOX_CARGO_ENV}"
    rustup set profile minimal
    rustup default "${RUST_VERSION}"
    rustup override set "${RUST_VERSION}"
    rustup target add armv7-linux-androideabi
    rustup target add aarch64-linux-android
    rustup target add thumbv7neon-linux-androideabi
    rustup target add x86_64-linux-android

    echo_green_text "SUCCESS: Set-up Rust environment at ${IRONFOX_CARGO_HOME}"
}

if [ "${IRONFOX_GET_SOURCE_ANDROID_SDK}" == 1 ]; then
    get_android_sdk
fi

if [ "${IRONFOX_GET_SOURCE_AS}" == 1 ]; then
    get_as
fi

# This needs to run before we get cbindgen
if [ "${IRONFOX_GET_SOURCE_RUST}" == 1 ]; then
    get_rust
fi

if [ "${IRONFOX_GET_SOURCE_CBINDGEN}" == 1 ]; then
    get_cbindgen
fi

if [ "${IRONFOX_GET_SOURCE_BUNDLETOOL}" == 1 ]; then
    get_bundletool
fi

if [ "${IRONFOX_GET_SOURCE_GECKO}" == 1 ]; then
    get_firefox
fi

if [ "${IRONFOX_GET_SOURCE_GECKO_L10N}" == 1 ]; then
    get_firefox_l10n
fi

if [ "${IRONFOX_GET_SOURCE_GLEAN}" == 1 ]; then
    get_glean
fi

# This needs to run before we get glean_parser and gyp
if [ "${IRONFOX_GET_SOURCE_PIP}" == 1 ]; then
    get_pip
fi

if [ "${IRONFOX_GET_SOURCE_GLEAN_PARSER}" == 1 ]; then
    get_glean_parser
fi

if [ "${IRONFOX_GET_SOURCE_GRADLE}" == 1 ]; then
    get_gradle
fi

if [ "${IRONFOX_GET_SOURCE_GYP}" == 1 ]; then
    get_gyp
fi

if [ "${IRONFOX_GET_SOURCE_MICROG}" == 1 ]; then
    get_microg
fi

if [ "${IRONFOX_GET_SOURCE_PHOENIX}" == 1 ]; then
    get_phoenix
fi

if [ "${IRONFOX_GET_SOURCE_PREBUILDS}" == 1 ]; then
    get_prebuilds
fi

if [ "${IRONFOX_GET_SOURCE_UP_AC}" == 1 ]; then
    get_up_ac
fi
