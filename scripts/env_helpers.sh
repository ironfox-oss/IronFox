
# Set platform
if [[ "${OSTYPE}" == "darwin"* ]]; then
    IRONFOX_PLATFORM='darwin'
else
    IRONFOX_PLATFORM='linux'
fi
export IRONFOX_PLATFORM

# Set OS
if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
    IRONFOX_OS='osx'
elif [[ "${IRONFOX_PLATFORM}" == 'linux' ]]; then
    if [[ -f "/etc/os-release" ]]; then
        source /etc/os-release
        if [[ -n "${ID}" ]]; then
            IRONFOX_OS="${ID}"
        else
            IRONFOX_OS='unknown'
        fi
    else
        IRONFOX_OS='unknown'
    fi
else
    IRONFOX_OS='unknown'
fi
export IRONFOX_OS

# Set architecture
PLATFORM_ARCH=$(uname -m)
if [[ "${PLATFORM_ARCH}" == 'arm64' ]]; then
    IRONFOX_PLATFORM_ARCH='aarch64'
else
    IRONFOX_PLATFORM_ARCH='x86-64'
fi
export IRONFOX_PLATFORM_ARCH
