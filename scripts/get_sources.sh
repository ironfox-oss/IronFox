#!/usr/bin/env bash

set -euo pipefail

source "$(dirname $0)/versions.sh"

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

    mkdir -p "$(dirname "$filepath")"

    echo "Downloading $url"
    wget "$url" -O "$filepath"
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

download_and_extract() {
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

if ! [[ -f "$BUILDDIR/bundletool.jar" ]]; then
    echo "Downloading bundletool..."
    wget https://github.com/google/bundletool/releases/download/${BUNDLETOOL_TAG}/bundletool-all-${BUNDLETOOL_TAG}.jar \
        -O "$BUILDDIR/bundletool.jar"
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
clone_repo "https://github.com/mozilla/glean" "$GLEANDIR" "$GLEAN_TAG"

# Clone MicroG
clone_repo "https://github.com/microg/GmsCore" "$GMSCOREDIR" "$GMSCORE_TAG"

# Get WebAssembly SDK
if [[ -z ${FDROID_BUILD+x} ]]; then
    echo "Downloading prebuilt wasi-sdk..."
    download_and_extract "wasi-sdk" "https://github.com/itsaky/ironfox/releases/download/$WASI_TAG/$WASI_TAG-firefox.tar.xz"
else
    echo "Cloning wasi-sdk..."
    clone_repo "https://github.com/WebAssembly/wasi-sdk" "$WASISDKDIR" "$WASI_TAG"
    (cd "$WASISDKDIR" && git submodule update --init --depth=1)
fi

# Clone application-services
echo "Cloning appservices..."
clone_repo "https://github.com/mozilla/application-services" "$APPSERVICESDIR" "$APPSERVICES_TAG"
(cd "$APPSERVICESDIR" && git submodule update --init --depth=1)

# Download Firefox Source
download_and_extract "gecko" "https://archive.mozilla.org/pub/firefox/${FIREFOX_RELEASE_PATH}/source/firefox-${FIREFOX_TAG}.source.tar.xz"
#download_and_extract "gecko" "https://github.com/mozilla-firefox/firefox/archive/refs/tags/${FIREFOX_TAG_NAME}.tar.gz"

# Write env_local.sh
echo "Writing ${ENV_SH}..."
cat > "$ENV_SH" << EOF
export patches=${PATCHDIR}
export rootdir=${ROOTDIR}
export builddir="${BUILDDIR}"
export android_components=${ANDROID_COMPONENTS}
export application_services=${APPSERVICESDIR}
export glean=${GLEANDIR}
export fenix=${FENIX}
export mozilla_release=${GECKODIR}
export gmscore=${GMSCOREDIR}
export wasi=${WASISDKDIR}

source "\$rootdir/scripts/env_common.sh"
EOF
