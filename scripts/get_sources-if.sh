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
    PLATFORM='macos'
    PREBUILT_PLATFORM='osx'
else
    PLATFORM='linux'
    PREBUILT_PLATFORM='linux'
fi

function validate_sha512sum() {
    expected_sha512sum="$1"
    file="$2"

    local_sha512sum=$(sha512sum "${file}" | "${IRONFOX_AWK}" '{print $1}')
    if [ "${local_sha512sum}" != "${expected_sha512sum}" ]; then
        echo_red_text 'ERROR: Checksum validation failed.'
        echo "Expected SHA512sum: ${expected_sha512sum}"
        echo "Actual SHA512sum: ${local_sha512sum}"

        # If checksum validation fails, also just remove the file
        rm -f "${file}"

        exit 1
    else
        echo_green_text 'SUCCESS: Checksum validated.'
        echo "SHA512sum: ${local_sha512sum}"
    fi
}

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

# Extract archives
function extract() {
    local archive_path="$1"
    local target_path="$2"
    local temp_repo_name="$3"

    if ! [[ -f "${archive_path}" ]]; then
        echo_red_text "ERROR: Archive '${archive_path}' does not exist!"
    fi

    # If our temporary directory for extraction already exists, delete it
    if [[ -d "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}" ]]; then
        rm -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
    fi

    # Create temporary directory for extraction
    mkdir -p "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"

    # Extract based on file extension
    case "${archive_path}" in
        *.zip)
            unzip -q "${archive_path}" -d "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            ;;
        *.tar.gz)
            "${IRONFOX_TAR}" xzf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            ;;
        *.tar.xz)
            "${IRONFOX_TAR}" xJf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            ;;
        *.tar.zst)
            "${IRONFOX_TAR}" --zstd -xvf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            ;;
        *)
            echo_red_text "ERROR: Unsupported archive format: ${archive_path}"
            rm -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            exit 1
            ;;
    esac

    local top_input_dir=$(ls "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}")
    cp -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}/${top_input_dir}"/ "${target_path}"
    rm -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
}

function download_and_extract() {
    local repo_name="$1"
    local url="$2"
    local path="$3"
    local expected_sha512sum="$4"

    if [[ -d "${path}" ]]; then
        echo_red_text "'${path}' already exists"
        read -p "Do you want to re-download? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text "Removing ${path}..."
            rm -rf "${path}"
        else
            return 0
        fi
    fi

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

    # Before extracting, verify SHA512sum...
    validate_sha512sum "${expected_sha512sum}" "${repo_archive}"

    echo_red_text "Extracting ${repo_archive}..."
    extract "${repo_archive}" "${path}" "${repo_name}"
    echo
}

# Get + set-up Android SDK
function get_android_sdk() {
    echo_red_text 'Downloading the Android SDK...'

    # This is typically covered by "download_and_extract", but the Android SDK is a special case - we don't download it to IRONFOX_ANDROID_SDK directly
    if [[ -d "${IRONFOX_ANDROID_SDK}" ]]; then
        echo_red_text "'${IRONFOX_ANDROID_SDK}' already exists"
        read -p "Do you want to re-download? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text "Removing ${IRONFOX_ANDROID_SDK}..."
            rm -rf "${IRONFOX_ANDROID_SDK}"
        else
            return 0
        fi
    fi
    mkdir -vp "${IRONFOX_ANDROID_SDK}/cmdline-tools"

    if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
        download_and_extract 'android-cmdline-tools' "https://dl.google.com/android/repository/commandlinetools-mac-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/latest" "${ANDROID_SDK_SHA512SUM_OSX}"
    else
        download_and_extract 'android-cmdline-tools' "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/latest" "${ANDROID_SDK_SHA512SUM_LINUX}"
    fi

    # Accept Android SDK licenses
    { yes || true; } | ${IRONFOX_ANDROID_SDKMANAGER} --sdk_root="${IRONFOX_ANDROID_SDK}" --licenses

    ${IRONFOX_ANDROID_SDKMANAGER} "build-tools;${ANDROID_BUILDTOOLS_VERSION}"
    ${IRONFOX_ANDROID_SDKMANAGER} "ndk;${ANDROID_NDK_REVISION}"
    ${IRONFOX_ANDROID_SDKMANAGER} "platforms;android-${ANDROID_PLATFORM_VERSION}"

    # These are currently required for Glean...
    ## for reference:
    ### https://github.com/mozilla/glean/blob/main/docs/dev/android/sdk-ndk-versions.md
    ### https://github.com/mozilla/glean/blob/main/docs/dev/android/setup-android-build-environment.md
    ${IRONFOX_ANDROID_SDKMANAGER} 'build-tools;35.0.0'
    ${IRONFOX_ANDROID_SDKMANAGER} 'platforms;android-36'

    echo_green_text "SUCCESS: Set-up Android SDK at ${IRONFOX_ANDROID_SDK}"
}

# Get Application Services
function get_as() {
    echo_red_text 'Downloading Application Services...'
    download_and_extract 'application-services' "https://github.com/mozilla/application-services/archive/${APPSERVICES_COMMIT}.tar.gz" "${IRONFOX_AS}" "${APPSERVICES_SHA512SUM}"
    echo_green_text "SUCCESS: Set-up Application Services at ${IRONFOX_AS}"
}

# Get + set-up Bundletool
function get_bundletool() {
    echo_red_text 'Downloading Bundletool...'
    download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}"

    # Validate SHA512sum
    validate_sha512sum "${BUNDLETOOL_SHA512SUM}" "${IRONFOX_BUNDLETOOL_JAR}"

    if ! [[ -f "${IRONFOX_BUNDLETOOL}" ]]; then
        echo_red_text 'Creating bundletool script...'
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

    echo_red_text "Downloading cbindgen..."
    download_and_extract 'cbindgen' "https://github.com/mozilla/cbindgen/archive/${CBINDGEN_COMMIT}.tar.gz" "${IRONFOX_CBINDGEN}" "${CBINDGEN_SHA512SUM}"

    source "${IRONFOX_CARGO_ENV}"
    echo_red_text 'Installing cbindgen...'
    cargo +"${RUST_VERSION}" install --locked --force --vers "${CBINDGEN_VERSION}" --path "${IRONFOX_CBINDGEN}" cbindgen
    echo_green_text "SUCCESS: Set-up cbindgen at ${IRONFOX_CARGO_HOME}/bin/cbindgen"
}

# Get Firefox (Gecko/mozilla-central)
function get_firefox() {
    echo_red_text 'Downloading Firefox...'
    download_and_extract 'gecko' "https://github.com/mozilla-firefox/firefox/archive/${FIREFOX_COMMIT}.tar.gz" "${IRONFOX_GECKO}" "${FIREFOX_SHA512SUM}"

    # Because we use MOZ_AUTOMATION for certain parts of the build, we need to initialize a Git repository
    ## The Git repository isn't already created, due to our method of downloading and verifying the archive
    pushd "${IRONFOX_GECKO}"
    git init
    popd

    echo_green_text "SUCCESS: Set-up Firefox at ${IRONFOX_GECKO}"
}

# Get firefox-l10n
function get_firefox_l10n() {
    echo_red_text 'Downloading firefox-l10n...'
    download_and_extract 'l10n-central' "https://github.com/mozilla-l10n/firefox-l10n/archive/${L10N_COMMIT}.tar.gz" "${IRONFOX_L10N_CENTRAL}" "${L10N_SHA512SUM}"
    echo_green_text "SUCCESS: Set-up firefox-l10n at ${IRONFOX_L10N_CENTRAL}"
}

# Get + set-up F-Droid's Gradle script
function get_gradle() {
    echo_red_text "Downloading F-Droid's Gradle script..."
    download "https://gitlab.com/fdroid/gradlew-fdroid/-/raw/${GRADLE_COMMIT}/gradlew.py" "${IRONFOX_GRADLE_DIR}/gradlew.py"

    # Validate SHA512sum
    validate_sha512sum "${GRADLE_SHA512SUM}" "${IRONFOX_GRADLE_DIR}/gradlew.py"

    if ! [[ -f "${IRONFOX_GRADLE}" ]]; then
        echo_red_text 'Creating Gradle script...'
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
    echo_red_text 'Downloading Glean...'
    download_and_extract 'glean' "https://github.com/mozilla/glean/archive/${GLEAN_COMMIT}.tar.gz" "${IRONFOX_GLEAN}" "${GLEAN_SHA512SUM}"
    echo_green_text "SUCCESS: Set-up Glean at ${IRONFOX_GLEAN}"
}

# Get Glean Parser
function get_glean_parser() {
    if  [ ! -d "${IRONFOX_PIP_DIR}" ] || [ ! -f "${IRONFOX_PIP_ENV}" ]; then
        echo_red_text "ERROR: You tried to download Glean Parser, but you don't have a pip environment set-up yet."
        exit 1
    fi

    if [[ -d "${IRONFOX_PIP_DIR}/bin/glean_parser" ]]; then
        echo_red_text "Glean Parser is already installed at ${IRONFOX_PIP_DIR}/bin/glean_parser"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        else
            source "${IRONFOX_PIP_ENV}"
            pip uninstall glean-parser
        fi
    fi

    if [[ -d "${IRONFOX_GLEAN_PARSER_WHEELS}" ]]; then
        echo_red_text "Glean Parser wheels are already downloaded at ${IRONFOX_GLEAN_PARSER_WHEELS}"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        else
            rm -rf "${IRONFOX_GLEAN_PARSER_WHEELS}"
        fi
    fi
    mkdir -p "${IRONFOX_GLEAN_PARSER_WHEELS}"

    source "${IRONFOX_PIP_ENV}"
    echo_red_text 'Downloading Glean Parser wheels...'
    pushd "${IRONFOX_GLEAN_PARSER_WHEELS}"
    pip download glean-parser=="${GLEAN_PARSER_VERSION}"
    popd

    # Validate SHA512sum
    validate_sha512sum "${GLEAN_PARSER_SHA512SUM}" "${IRONFOX_GLEAN_PARSER_WHEELS}/glean_parser-${GLEAN_PARSER_VERSION}-py3-none-any.whl"
}

# Get GYP
function get_gyp() {
    if  [ ! -d "${IRONFOX_PIP_DIR}" ] || [ ! -f "${IRONFOX_PIP_ENV}" ]; then
        echo_red_text "ERROR: You tried to download GYP, but you don't have a pip environment set-up yet."
        exit 1
    fi

    if [[ -d "${IRONFOX_PIP_DIR}/bin/gyp" ]]; then
        echo_red_text "GYP is already installed at ${IRONFOX_PIP_DIR}/bin/gyp"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        else
            source "${IRONFOX_PIP_ENV}"
            pip uninstall gyp-next
        fi
    fi

    echo_red_text "Downloading GYP..."
    download_and_extract 'gyp-next' "https://github.com/nodejs/gyp-next/archive/${GYP_COMMIT}.tar.gz" "${IRONFOX_GYP}" "${GYP_SHA512SUM}"

    # For the pip install to work, we need to initialize a Git repository
    ## The Git repository isn't already created, due to our method of downloading and verifying the archive
    pushd "${IRONFOX_GYP}"
    git init
    popd

    source "${IRONFOX_PIP_ENV}"
    echo_red_text 'Installing GYP...'
    pip install "${IRONFOX_GYP}"
    echo_green_text "SUCCESS: Set-up GYP at ${IRONFOX_PIP_DIR}/bin/gyp"
}

# Get microG
function get_microg() {
    echo_red_text 'Downloading microG...'
    download_and_extract 'gmscore' "https://github.com/microg/GmsCore/archive/${GMSCORE_COMMIT}.tar.gz" "${IRONFOX_GMSCORE}" "${GMSCORE_SHA512SUM}"
    echo_green_text "SUCCESS: Set-up microG at ${IRONFOX_GMSCORE}"
}

# Get UnifiedPush-AC
function get_up_ac() {
    echo_red_text 'Downloading UnifiedPush-AC...'
    download_and_extract 'unifiedpush-ac' "https://gitlab.com/ironfox-oss/unifiedpush-ac/-/archive/${UNIFIEDPUSHAC_COMMIT}/unifiedpush-ac-${UNIFIEDPUSHAC_COMMIT}.tar.gz" "${IRONFOX_UP_AC}" "${UNIFIEDPUSHAC_SHA512SUM}"
    echo_green_text "SUCCESS: Set-up UnifiedPush-AC at ${IRONFOX_UP_AC}"
}

# Get Phoenix
function get_phoenix() {
    echo_red_text 'Downloading Phoenix...'
    download_and_extract 'phoenix' "https://gitlab.com/celenityy/Phoenix/-/archive/${PHOENIX_COMMIT}/Phoenix-${PHOENIX_COMMIT}.tar.gz" "${IRONFOX_PHOENIX}" "${PHOENIX_SHA512SUM}"
    echo_green_text "SUCCESS: Set-up Phoenix at ${IRONFOX_PHOENIX}"
}

# Get + set-up pip
function get_pip() {
    if [[ -d "${IRONFOX_PIP_DIR}" ]]; then
        echo_red_text "The pip environment is already set-up at ${IRONFOX_PIP_DIR}"
        read -p "Do you want to re-create it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            rm -rf "${IRONFOX_PIP_DIR}" "${IRONFOX_PIP}"
        fi
    fi

    echo_red_text 'Creating pip environment...'
    python3.9 -m venv "${IRONFOX_PIP_DIR}"

    echo_red_text 'Downloading pip...'
    download_and_extract 'pip' "https://github.com/pypa/pip/archive/${PIP_COMMIT}.tar.gz" "${IRONFOX_PIP}" "${PIP_SHA512SUM}"

    # For the pip install to work, we need to initialize a Git repository
    ## The Git repository isn't already created, due to our method of downloading and verifying the archive
    pushd "${IRONFOX_PIP}"
    git init
    popd

    source "${IRONFOX_PIP_ENV}"
    echo_red_text 'Installing pip...'
    pip install "${IRONFOX_PIP}"
    echo_green_text "SUCCESS: Set-up pip environment at ${IRONFOX_PIP_DIR}"
}

# Get IronFox prebuilds
function get_prebuilds() {
    if [[ "${IRONFOX_NO_PREBUILDS}" == "1" ]]; then
        echo_red_text 'Downloading the IronFox prebuilds repository...'
        download_and_extract 'prebuilds' "https://gitlab.com/ironfox-oss/prebuilds/-/archive/${PREBUILDS_COMMIT}/prebuilds-${PREBUILDS_COMMIT}.tar.gz" "${IRONFOX_PREBUILDS}" "${PREBUILDS_SHA512SUM}"

        pushd "${IRONFOX_PREBUILDS}"
        echo_red_text 'Downloading prebuild sources...'
        bash "${IRONFOX_PREBUILDS}/scripts/get_sources.sh"
        popd

        echo_green_text "SUCCESS: Set-up the IronFox prebuilds repository at ${IRONFOX_PREBUILDS}"
    else
        # Get Tor's no-op UniFFi binding generator
        echo_red_text 'Downloading prebuilt uniffi-bindgen...'
        if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
            download_and_extract 'uniffi' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_OSX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/osx/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_OSX_IRONFOX_REVISION}-osx.tar.xz" "${IRONFOX_UNIFFI}" "${UNIFFI_OSX_IRONFOX_SHA512SUM}"
        else
            download_and_extract 'uniffi' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_LINUX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/linux/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_LINUX_IRONFOX_REVISION}-linux.tar.xz" "${IRONFOX_UNIFFI}" "${UNIFFI_LINUX_IRONFOX_SHA512SUM}"
        fi
        echo_green_text "SUCCESS: Set-up the prebuilt uniffi-bindgen at ${IRONFOX_UNIFFI}"

        # Get WebAssembly SDK
        echo_red_text 'Downloading prebuilt wasi-sdk...'
        if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
            download_and_extract 'wasi-sdk' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_OSX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/osx/wasi-sdk-${WASI_VERSION}-${WASI_OSX_IRONFOX_REVISION}-osx.tar.xz" "${IRONFOX_WASI}" "${WASI_OSX_IRONFOX_SHA512SUM}"
        else
            download_and_extract 'wasi-sdk' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_LINUX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/linux/wasi-sdk-${WASI_VERSION}-${WASI_LINUX_IRONFOX_REVISION}-linux.tar.xz" "${IRONFOX_WASI}" "${WASI_LINUX_IRONFOX_SHA512SUM}"
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

    echo_red_text 'Downloading Rust...'
    download "https://raw.githubusercontent.com/rust-lang/rustup/${RUSTUP_COMMIT}/rustup-init.sh" "${IRONFOX_DOWNLOADS}/rustup-init.sh"

    # Validate SHA512sum
    validate_sha512sum "${RUSTUP_SHA512SUM}" "${IRONFOX_DOWNLOADS}/rustup-init.sh"

    bash -x "${IRONFOX_DOWNLOADS}/rustup-init.sh" -y --no-modify-path --no-update-default-toolchain --profile=minimal

    echo_red_text 'Creating Rust environment...'
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
