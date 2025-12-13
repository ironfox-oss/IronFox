#!/bin/bash

# Script to assist with creation of an IronFox build environment

set -euo pipefail

error_fn() {
	echo
	echo -e "\033[31mSomething went wrong! The script failed.\033[0m"
	echo -e "\033[31mPlease report this (with the output message) to https://gitlab.com/ironfox-oss/IronFox/-/issues\033[0m"
	echo
	exit 1
}

# Install dependencies
echo "Installing dependencies..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Ensure Homebrew is installed
    if [[ -z "$HOMEBREW_PREFIX" ]]; then
        echo "Homebrew is not installed! Aborting..."
        echo "Please install Homebrew and try again..."
        echo "https://brew.sh/"
        exit 1
    fi

    # Ensure Xcode command line tools are installed
    if ! /usr/bin/xcode-select -p &> /dev/null; then
        /usr/bin/xcode-select --install || error_fn
        echo
    fi

    export HOMEBREW_ASK=0

    # Ensure we're up to date
    brew update || error_fn
    echo
    brew upgrade || error_fn
    echo

    # Install our dependencies...
    brew install \
        cmake \
        gawk \
        git \
        gnu-sed \
        gnu-tar \
        m4 \
        make \
        nasm \
        ninja \
        node \
        perl \
        python@3.9 \
        temurin@17 \
        wget \
        xz \
        yq \
        zlib || error_fn
    echo

elif [[ -f "/etc/os-release" ]]; then
    # We're on Linux, so let's determine the distro
    source /etc/os-release || error_fn
    echo

    # ATM, we support Fedora and Ubuntu
    if [[ "$ID" == "fedora" ]]; then
        # Ensure we're up to date
        sudo dnf update -y --refresh || error_fn
        echo

        # Add + enable the Adoptium Working Group's repository
        sudo dnf install -y adoptium-temurin-java-repository || error_fn
        echo
        sudo dnf config-manager setopt adoptium-temurin-java-repository.enabled=1 || error_fn
        echo
        sudo dnf makecache || error_fn
        echo

        # Install our dependencies...
        sudo dnf install -y \
            cmake \
            clang \
            gawk \
            git \
            gyp \
            m4 \
            make \
            nasm \
            ninja-build \
            patch \
            perl \
            python3.9 \
            shasum \
            temurin-8-jdk \
            temurin-17-jdk \
            wget \
            xz \
            yq \
            zlib-devel || error_fn
        echo

    elif [[ "$ID" == "ubuntu" ]]; then
        # Ensure we're up to date
        sudo apt update || error_fn
        echo
        sudo apt upgrade || error_fn
        echo

        # Add the deadsnakes PPA
        sudo add-apt-repository ppa:deadsnakes/ppa || error_fn
        echo

        # Add + enable the Adoptium Working Group's repository
        wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null || error_fn
        echo
        echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list || error_fn
        echo

        sudo apt update || error_fn
        echo

        sudo apt install -y \
            apt-transport-https \
            cmake \
            clang-18 \
            git \
            gpg \
            gyp \
            make \
            nasm \
            ninja-build \
            patch \
            perl \
            python3.9 \
            tar \
            temurin-8-jdk \
            temurin-17-jdk \
            unzip \
            wget \
            xz-utils \
            yq \
            zlib1g-dev || error_fn
        echo
    else
        echo "Apologies, your Linux distribution is currently not supported."
        echo "If you think this is a mistake, please let us know!"
        echo "https://gitlab.com/ironfox-oss/IronFox/-/issues"
        echo "Otherwise, please try again on a system running the latest version of Fedora, macOS, or Ubuntu."
        exit 1
    fi
else
    echo "Apologies, your operating system is currently not supported."
    echo "If you think this is a mistake, please let us know!"
    echo "https://gitlab.com/ironfox-oss/IronFox/-/issues"
    echo "Otherwise, please try again on a system running the latest version of Fedora, macOS, or Ubuntu."
    exit 1
fi
