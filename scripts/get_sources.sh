#!/usr/bin/env bash

set -euo pipefail

FIREFOX_TAG="134.0.1"
WASI_TAG="wasi-sdk-20"
GLEAN_TAG="v62.0.0"
GMSCORE_TAG="v0.3.6.244735"
APPSERVICES_TAG="v134.0"

# Configuration
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_SH="${ROOTDIR}/scripts/env_local.sh"
BUILDDIR="${ROOTDIR}/build"
PATCHDIR="${ROOTDIR}/patches"
GECKODIR="${ROOTDIR}/gecko"
GLEANDIR="${ROOTDIR}/glean"
APPSERVICESDIR="${ROOTDIR}/appservices"
GMSCOREDIR="${ROOTDIR}/gmscore"
WASISDKDIR="${ROOTDIR}/wasi-sdk"
ANDROID_COMPONENTS="${GECKODIR}/mobile/android/android-components"
FENIX="${GECKODIR}/mobile/android/fenix"

download() {
    local url="$1"
    local filepath="$2"

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

    echo "Downloading $url"
    wget "$url" -O "$filepath"
}

# Extract zip removing top level directory
extract_rmtoplevel() {
    local archive_path="$1"
    local to_name="$2"
    local extract_to="${ROOTDIR}/$to_name"

    # Create temporary directory for extraction
    local temp_dir=$(mktemp -d)

    # Extract based on file extension
    case "$archive_path" in
        *.zip)
            unzip -q "$archive_path" -d "$temp_dir"
            ;;
        *.tar.gz)
            tar xzf "$archive_path" -C "$temp_dir"
            ;;
        *.tar.xz)
            tar xJf "$archive_path" -C "$temp_dir"
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
    mkdir -p "$to_parent"
    mv "$temp_dir/$top_dir" "$to_parent/$to_name"

    rm -rf "$temp_dir"
}

do_download() {
    local repo_name="$1"
    local url="$2"

    local extension
    if [[ "$url" =~ \.tar\.xz$ ]]; then
        extension=".tar.xz"
    elif [[ "$url" =~ \.tar\.gz$ ]]; then
        extension=".tar.gz"
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

mkdir -p "$BUILDDIR"

echo "Cloning glean..."
git clone --branch "$GLEAN_TAG" --depth=1 "https://github.com/mozilla/glean" "$GLEANDIR"

echo "Cloning gmscore..."
git clone --branch "$GMSCORE_TAG" --depth=1 "https://github.com/microg/GmsCore" "$GMSCOREDIR"

if [[ -z ${FDROID_BUILD+x} ]]; then
    echo "Downloading prebuilt wasi-sdk..."
    do_download "wasi-sdk" "https://github.com/itsaky/ironfox/releases/download/$WASI_TAG/$WASI_TAG-firefox.tar.xz"
else
    echo "Cloning wasi-sdk..."
    git clone --branch "$WASI_TAG" --depth=1 "https://github.com/WebAssembly/wasi-sdk" "$WASISDKDIR"
    (cd "$WASISDKDIR" && git submodule update --init --depth=1)
fi

echo "Cloning appservices..."
git clone --branch "$APPSERVICES_TAG" --depth=1 "https://github.com/mozilla/application-services" "$APPSERVICESDIR"
(cd "$APPSERVICESDIR" && git submodule update --init --depth=1)

do_download "gecko" "https://archive.mozilla.org/pub/firefox/releases/${FIREFOX_TAG}/source/firefox-${FIREFOX_TAG}.source.tar.xz"

echo "Writing ${ENV_SH}..."
cat > "$ENV_SH" << EOF
export patches=${PATCHDIR}
export rootdir=${ROOTDIR}
export builddir="\$rootdir/build"
export android_components=${ANDROID_COMPONENTS}
export application_services=${APPSERVICESDIR}
export glean=${GLEANDIR}
export fenix=${FENIX}
export mozilla_release=${GECKODIR}
export gmscore=${GMSCOREDIR}
export wasi=${WASISDKDIR}

source "\$rootdir/scripts/env_common.sh"
EOF
