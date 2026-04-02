
# Set platform
if [[ "${OSTYPE}" == "darwin"* ]]; then
    export IRONFOX_PLATFORM='darwin'
else
    export IRONFOX_PLATFORM='linux'
fi

# Set OS
if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
    export IRONFOX_OS='osx'
elif [[ "${IRONFOX_PLATFORM}" == 'linux' ]]; then
    if [[ -f "/etc/os-release" ]]; then
        source /etc/os-release
        if [[ -n "${ID}" ]]; then
            export IRONFOX_OS="${ID}"
        else
            export IRONFOX_OS='unknown'
        fi
    else
        export IRONFOX_OS='unknown'
    fi
else
    export IRONFOX_OS='unknown'
fi

# Set architecture
PLATFORM_ARCH=$(uname -m)
if [[ "${PLATFORM_ARCH}" == 'arm64' ]]; then
    export IRONFOX_PLATFORM_ARCH='aarch64'
else
    export IRONFOX_PLATFORM_ARCH='x86-64'
fi
