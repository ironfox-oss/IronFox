#!/bin/bash

# Script to assist with creation of an IronFox build environment

set -euo pipefail

echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

echo_green_text() {
	echo -e "\033[32m$1\033[0m"
}

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Get our platform, OS, and architecture
source "${IRONFOX_ENV_HELPERS}"

error_fn() {
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
            gawk \
            git \
            gnu-sed \
            gnu-tar \
            m4 \
            make \
            temurin@17 \
            xz \
            zlib || error_fn
        echo
    fi
    
    # Install our dependencies...
    brew install \
        cmake \
        nasm \
        ninja \
        node \
        perl \
        python@3.9 \
        yq || error_fn
    echo

    # For secureblue, we also need to install our JDKs,
    ## which we unfortunately can't just get from Homebrew like we do for OS X
    ## We also need clang and zlib-devel
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

        # Now, add + enable the Adoptium Working Group's repository
        /usr/bin/run0 /usr/bin/curl ${IRONFOX_CURL_FLAGS} --output-dir "/etc/yum.repos.d/" --remote-name https://src.fedoraproject.org/rpms/adoptium-temurin-java-repository/raw/6a468beba6d45d2b29e729196a8dbb12e96e3c33/f/adoptium-temurin-java-repository.repo || error_fn
        echo
        /usr/bin/run0 /usr/bin/chmod 644 /etc/yum.repos.d/adoptium-temurin-java-repository.repo || error_fn
        echo
        /usr/bin/run0 "${IRONFOX_SED}" -i -e '/enabled/s/0/1/' /etc/yum.repos.d/adoptium-temurin-java-repository.repo || error_fn
        echo
        /usr/bin/rpm-ostree refresh-md --force || error_fn
        echo

        # Install our JDKs
        /usr/bin/rpm-ostree install \
            temurin-8-jdk \
            temurin-17-jdk || error_fn
        echo

        # We now unfortunately have to restart the system :/
        echo_red_text "To apply the clang, JDK, and zlib installations, your system will now reboot."
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
