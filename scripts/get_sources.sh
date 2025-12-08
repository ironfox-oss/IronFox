#!/usr/bin/env bash

set -euo pipefail

source "$(dirname $0)/versions.sh"

if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM=macos
    PREBUILT_PLATFORM=osx
    # Ensure we use GNU tar on macOS
    TAR=gtar
else
    PLATFORM=linux
    PREBUILT_PLATFORM=linux
    TAR=tar
fi

clone_repo() {
    url="$1"
    path="$2"
    tag="$3"

    if [[ "$url" == "" ]]; then
        echo "URL missing for clone"
        exit 1
    fi

    if [[ "$path" == "" ]]; then
        echo "Path is required for cloning '$url'"
        exit 1
    fi

    if [[ "$tag" == "" ]]; then
        echo "Tag name is required for cloning '$url'"
        exit 1
    fi

    if [[ -f "$path" ]]; then
        echo "'$path' exists and is not a directory"
        exit 1
    fi

    if [[ -d "$path" ]]; then
        echo "'$path' already exists"
        read -p "Do you want to re-clone this repository? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return 0
        fi
    fi

    echo "Cloning $url::$tag"
    git clone --branch "$tag" --depth=1 "$url" "$path"
}

clone_repo_by_revision() {
    url="$1"
    path="$2"
    revision="$3"

    if [[ "$url" == "" ]]; then
        echo "URL missing for clone"
        exit 1
    fi

    if [[ "$path" == "" ]]; then
        echo "Path is required for cloning '$url'"
        exit 1
    fi

    if [[ "$revision" == "" ]]; then
        echo "Revision is required for cloning '$url'"
        exit 1
    fi

    if [[ -f "$path" ]]; then
        echo "'$path' exists and is not a directory"
        exit 1
    fi

    if [[ -d "$path" ]]; then
        echo "'$path' already exists"
        read -p "Do you want to re-clone this repository? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return 0
        fi
    fi

    echo "Cloning $url::$revision"
    git clone --revision="$revision" --depth=1 "$url" "$path"
}

download() {
    local url="$1"
    local filepath="$2"

    if [[ "$url" == "" ]]; then
        echo "URL is required (file: '$filepath')"
        exit 1
    fi

    if [ -f "$filepath" ]; then
        echo "$filepath already exists."
        read -p "Do you want to re-download? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing $filepath..."
            rm -f "$filepath"
        else
            return 0
        fi
    fi

    mkdir -vp "$(dirname "$filepath")"

    echo "Downloading $url"
    wget --https-only --no-cache --secure-protocol=TLSv1_3 --show-progress --verbose "$url" -O "$filepath"
}

# Extract zip removing top level directory
extract_rmtoplevel() {
    local archive_path="$1"
    local to_name="$2"
    local extract_to="${ROOTDIR}/$to_name"

    if ! [[ -f "$archive_path" ]]; then
        echo "Archive '$archive_path' does not exist!"
    fi

    # Create temporary directory for extraction
    local temp_dir=$(mktemp -d)

    # Extract based on file extension
    case "$archive_path" in
        *.zip)
            unzip -q "$archive_path" -d "$temp_dir"
            ;;
        *.tar.gz)
            $TAR xzf "$archive_path" -C "$temp_dir"
            ;;
        *.tar.xz)
            $TAR xJf "$archive_path" -C "$temp_dir"
            ;;
        *.tar.zst)
            $TAR --zstd -xvf "$archive_path" -C "$temp_dir"
            ;;
        *)
            echo "Unsupported archive format: $archive_path"
            rm -rf "$temp_dir"
            exit 1
            ;;
    esac

    local top_dir=$(ls "$temp_dir")
    local to_parent=$(dirname "$extract_to")

    rm -rf "$extract_to"
    mkdir -vp "$to_parent"
    mv "$temp_dir/$top_dir" "$to_parent/$to_name"

    rm -rf "$temp_dir"
}

download_and_extract() {
    local repo_name="$1"
    local url="$2"

    local extension
    if [[ "$url" =~ \.tar\.xz$ ]]; then
        extension=".tar.xz"
    elif [[ "$url" =~ \.tar\.gz$ ]]; then
        extension=".tar.gz"
    elif [[ "$url" =~ \.tar\.zst$ ]]; then
        extension=".tar.zst"
    else
        extension=".zip"
    fi

    local repo_archive="${BUILDDIR}/${repo_name}${extension}"

    download "$url" "$repo_archive"

    if [ ! -f "$repo_archive" ]; then
        echo "Source archive for $repo_name does not exist."
        exit 1
    fi

    echo "Extracting $repo_archive"
    extract_rmtoplevel "$repo_archive" "$repo_name"
    echo
}

mkdir -vp "$BUILDDIR"

if ! [[ -f "$BUILDDIR/bundletool.jar" ]]; then
    echo "Downloading bundletool..."
    download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "$BUILDDIR/bundletool.jar"
fi

if ! [[ -f "$BUILDDIR/bundletool" ]]; then
    echo "Creating bundletool script..."
    {
        echo '#!/bin/bash'
        echo "exec java -jar ${BUILDDIR}/bundletool.jar \"\$@\""
    } > "$BUILDDIR/bundletool"
    chmod +x "$BUILDDIR/bundletool"
fi

echo "'bundletool' is set up at $BUILDDIR/bundletool"

# Clone Glean
echo "Cloning Glean..."
clone_repo "https://github.com/mozilla/glean.git" "$GLEANDIR" "$GLEAN_VERSION"

# Clone MicroG
echo "Cloning microG..."
clone_repo "https://github.com/microg/GmsCore.git" "$GMSCOREDIR" "$GMSCORE_VERSION"

# Download Phoenix
echo "Downloading Phoenix..."
download "https://gitlab.com/celenityy/Phoenix/-/raw/$PHOENIX_VERSION/android/phoenix.js" "$PATCHDIR/gecko-overlay/ironfox/prefs/000-phoenix.js"
download "https://gitlab.com/celenityy/Phoenix/-/raw/$PHOENIX_VERSION/android/phoenix-extended.js" "$PATCHDIR/gecko-overlay/ironfox/prefs/001-phoenix-extended.js"

# Get Tor's no-op UniFFi binding generator
if [[ -n ${FDROID_BUILD+x} ]]; then
    echo "Cloning uniffi-bindgen..."
    clone_repo_by_revision "https://gitlab.torproject.org/tpo/applications/uniffi-rs.git" "$UNIFFIDIR" "$UNIFFI_COMMIT"
elif [[ "$PLATFORM" == "macos" ]]; then
    echo "Downloading prebuilt uniffi-bindgen..."
    download_and_extract "uniffi" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/$UNIFFI_OSX_IRONFOX_COMMIT/uniffi-bindgen/$UNIFFI_VERSION/$PREBUILT_PLATFORM/uniffi-bindgen-$UNIFFI_VERSION-$UNIFFI_OSX_IRONFOX_REVISION-$PREBUILT_PLATFORM.tar.xz"
else
    echo "Downloading prebuilt uniffi-bindgen..."
    download_and_extract "uniffi" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/$UNIFFI_LINUX_IRONFOX_COMMIT/uniffi-bindgen/$UNIFFI_VERSION/$PREBUILT_PLATFORM/uniffi-bindgen-$UNIFFI_VERSION-$UNIFFI_LINUX_IRONFOX_REVISION-$PREBUILT_PLATFORM.tar.xz"
fi

# Get WebAssembly SDK
if [[ -n ${FDROID_BUILD+x} ]]; then
    echo "Cloning wasi-sdk..."
    clone_repo_by_revision "https://github.com/WebAssembly/wasi-sdk.git" "$WASISDKDIR" "$WASI_COMMIT"
    (cd "$WASISDKDIR" && git submodule update --init --depth=64)

    # We need to use a newer clang here, because A: Mozilla dropped support for using below 17, and B: it's just good practice
    ## I'm using 20.1.8 specifically because it's listed in mozilla-central: https://searchfox.org/firefox-main/rev/ac83682a/taskcluster/kinds/fetch/toolchains.yml#392
    rm -rf "$WASISDKDIR/src/llvm-project"
    echo "Cloning llvm..."
    clone_repo_by_revision "https://github.com/llvm/llvm-project.git" "$WASISDKDIR/src/llvm-project" "$LLVM_COMMIT"

    # We also clone Firefox directly, but, this is to ensure that the WASI patch we're using always matches exactly what we're
    ## using at https://gitlab.com/ironfox-oss/prebuilds
    echo "Downloading Firefox's WASI patch..."
    download "https://github.com/mozilla-firefox/firefox/raw/$FIREFOX_WASI_COMMIT/taskcluster/scripts/misc/wasi-sdk.patch" "$BUILDDIR/wasi-sdk.patch"
elif [[ "$PLATFORM" == "macos" ]]; then
    echo "Downloading prebuilt wasi-sdk.."
    download_and_extract "wasi-sdk" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/$WASI_OSX_IRONFOX_COMMIT/wasi-sdk/$WASI_VERSION/$PREBUILT_PLATFORM/wasi-sdk-$WASI_VERSION-$WASI_OSX_IRONFOX_REVISION-$PREBUILT_PLATFORM.tar.xz"
else
    echo "Downloading prebuilt wasi-sdk..."
    download_and_extract "wasi-sdk" "https://gitlab.com/ironfox-oss/prebuilds/-/raw/$WASI_LINUX_IRONFOX_COMMIT/wasi-sdk/$WASI_VERSION/$PREBUILT_PLATFORM/wasi-sdk-$WASI_VERSION-$WASI_LINUX_IRONFOX_REVISION-$PREBUILT_PLATFORM.tar.xz"
fi

# Clone application-services
echo "Cloning application-services..."
clone_repo "https://github.com/mozilla/application-services.git" "$APPSERVICESDIR" "${APPSERVICES_VERSION}"
#git clone --branch "$APPSERVICES_VERSION" --depth=1 https://github.com/mozilla/application-services.git "$APPSERVICESDIR"

# Clone Firefox
echo "Cloning Firefox..."
clone_repo_by_revision "https://github.com/mozilla-firefox/firefox.git" "$GECKODIR" "$FIREFOX_COMMIT"

# Write env_local.sh
echo "Writing ${ENV_SH}..."
cat > "$ENV_SH" << EOF
export patches=${PATCHDIR}
export rootdir=${ROOTDIR}
export builddir="${BUILDDIR}"
export android_components=${ANDROID_COMPONENTS}
export application_services=${APPSERVICESDIR}
export bundletool=${BUNDLETOOLDIR}
export glean=${GLEANDIR}
export fenix=${FENIX}
export mozilla_release=${GECKODIR}
export gmscore=${GMSCOREDIR}
export uniffi=${UNIFFIDIR}
export wasi=${WASISDKDIR}

source "\$rootdir/scripts/env_common.sh"
EOF
