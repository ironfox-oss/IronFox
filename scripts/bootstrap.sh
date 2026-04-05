#!/bin/bash

# Script to assist with creation of an IronFox build environment

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
    bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Get our platform, OS, and architecture
source "${IRONFOX_ENV_HELPERS}"

function error_fn() {
	echo
	echo -e "\033[31mSomething went wrong! The script failed.\033[0m"
	echo -e "\033[31mPlease report this (with the output message) to https://gitlab.com/ironfox-oss/IronFox/-/issues\033[0m"
	echo
	exit 1
}

# Install dependencies
echo_green_text "Installing dependencies..."
echo_green_text "Detected operating system: ${IRONFOX_OS}"

# macOS, secureblue
## (Both use Homebrew)
if [[ "${IRONFOX_OS}" == 'osx' ]] || [[ "${IRONFOX_OS}" == 'secureblue' ]]; then
    # Ensure Homebrew is installed
    if [[ -z "${HOMEBREW_PREFIX+x}" ]]; then
        echo_red_text "Homebrew is not installed! Aborting..."
        echo_red_text "Please install Homebrew and try again..."
        echo_green_text "https://brew.sh/"
        exit 1
    fi

    export HOMEBREW_ASK=0

    # Ensure we're up to date
    brew update --force || error_fn
    echo
    brew upgrade --greedy || error_fn
    echo

    if [[ "${IRONFOX_OS}" == 'osx' ]]; then
        # Ensure Xcode command line tools are installed
        if ! /usr/bin/xcode-select -p &> /dev/null; then
            /usr/bin/xcode-select --install || error_fn
            echo
        fi

        # Install OS X dependencies
        brew install \
            coreutils \
            gawk \
            git \
            gnu-sed \
            gnu-tar \
            m4 \
            make \
            xz \
            zlib || error_fn
        echo
    fi
    
    # Install our dependencies...
    brew install \
        cmake \
        jq \
        nasm \
        ninja \
        perl \
        yq || error_fn
    echo

    # For secureblue, we also need clang and zlib-devel
    if [[ "${IRONFOX_OS}" == 'secureblue' ]]; then
        # Ensure we're up to date
        /usr/bin/rpm-ostree refresh-md --force || error_fn
        echo
        /usr/bin/ujust update-system || error_fn
        echo

        # Install clang and zlib-devel
        /usr/bin/rpm-ostree install \
            clang \
            zlib-devel || error_fn
        echo

        # We now unfortunately have to restart the system :/
        echo_red_text "To apply the clang and zlib installations, your system will now reboot."
        /usr/bin/sleep 5 || error_fn
        echo
        echo_green_text "Press enter to continue."
        read
        /usr/bin/systemctl reboot || error_fn
        echo
    fi
# Fedora
elif [[ "${IRONFOX_OS}" == 'fedora' ]]; then
    # Ensure we're up to date
    sudo dnf update -y --refresh || error_fn
    echo

    # Install our dependencies...
    sudo dnf install -y \
        cmake \
        clang \
        gawk \
        git \
        jq \
        m4 \
        make \
        nasm \
        ninja-build \
        patch \
        perl \
        shasum \
        xz \
        yq \
        zlib-devel || error_fn
    echo

# Ubuntu
elif [[ "${IRONFOX_OS}" == 'ubuntu' ]]; then
    # Ensure we're up to date
    sudo apt update || error_fn
    echo
    sudo apt upgrade || error_fn
    echo

    sudo apt install -y \
        apt-transport-https \
        cmake \
        clang-18 \
        git \
        gpg \
        make \
        nasm \
        ninja-build \
        patch \
        perl \
        tar \
        unzip \
        xz-utils \
        yq \
        zlib1g-dev || error_fn
    echo
else
    echo_red_text "Apologies, your operating system is currently not supported."
    echo_red_text "If you think this is a mistake, please let us know!"
    echo_green_text "https://gitlab.com/ironfox-oss/IronFox/-/issues"
    echo_red_text "Otherwise, please try again on a system running the latest version of Fedora, macOS, secureblue, or Ubuntu."
    exit 1
fi
