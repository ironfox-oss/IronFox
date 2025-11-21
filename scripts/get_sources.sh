#!/usr/bin/env bash

set -euo pipefail

source "$(dirname $0)/versions.sh"

if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM=macos
else
    PLATFORM=linux
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
            tar xzf "$archive_path" -C "$temp_dir"
            ;;
        *.tar.xz)
            tar xJf "$archive_path" -C "$temp_dir"
            ;;
        *.tar.zst)
            tar --zstd -xvf "$archive_path" -C "$temp_dir"
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
download "https://gitlab.com/celenityy/Phoenix/-/raw/$PHOENIX_VERSION/android/phoenix.js" "$PATCHDIR/preferences/phoenix.js"
download "https://gitlab.com/celenityy/Phoenix/-/raw/$PHOENIX_VERSION/android/phoenix-extended.js" "$PATCHDIR/preferences/phoenix-extended.js"

# Get WebAssembly SDK
if [[ -n ${FDROID_BUILD+x} ]]; then
    echo "Cloning wasi-sdk..."
    clone_repo "https://github.com/WebAssembly/wasi-sdk.git" "$WASISDKDIR" "$WASI_VERSION"
    (cd "$WASISDKDIR" && git submodule update --init --depth=64)
elif [[ "$PLATFORM" == "macos" ]]; then
    echo "Downloading prebuilt wasi-sdk..."
    download "https://github.com/celenityy/wasi-sdk/releases/download/$WASI_VERSION/$WASI_VERSION-firefox-osx.tar.xz" "$BUILDDIR/wasi-sdk.tar.xz"
    mkdir -vp "$WASISDKDIR"
    tar xJf "$BUILDDIR/wasi-sdk.tar.xz" -C "$WASISDKDIR"
else
    echo "Downloading prebuilt wasi-sdk..."
    download_and_extract "wasi-sdk" "https://github.com/itsaky/ironfox/releases/download/$WASI_VERSION/$WASI_VERSION-firefox.tar.xz"
fi

# Get Tor's no-op UniFFi binding generator
if [[ "$PLATFORM" == "macos" ]]; then
    # Do nothing here, unfortunately this doesn't appear to work on macOS ATM
    ## We don't ship or build releases from macOS; and regardless, we still stub Glean's Kotlin code through our glean-overlay, disable it entirely, etc - so, while this isn't ideal, it's not the end of the world - the biggest implication here is probably just extra space
    echo "macOS: Doing nothing..."
else
    if [[ -n ${FDROID_BUILD+x} ]]; then
        echo "Cloning uniffi-bindgen..."
        clone_repo "https://gitlab.torproject.org/tpo/applications/uniffi-rs.git" "$UNIFFIDIR" "$UNIFFI_VERSION"
    else
        echo "Downloading prebuilt uniffi-bindgen..."
        download_and_extract "uniffi" "https://tb-build-06.torproject.org/~tb-builder/tor-browser-build/out/uniffi-rs/uniffi-rs-$UNIFFI_REVISION.tar.zst"
    fi
fi

# Clone application-services
echo "Cloning application-services..."
clone_repo "https://github.com/mozilla/application-services.git" "$APPSERVICESDIR" "${APPSERVICES_VERSION}"
# git clone --branch "$APPSERVICES_VERSION" --depth=1 https://github.com/mozilla/application-services.git "$APPSERVICESDIR"

# Clone Firefox
echo "Cloning Firefox..."
clone_repo "https://github.com/mozilla-firefox/firefox.git" "$GECKODIR" "${FIREFOX_RELEASE_TAG}"

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
