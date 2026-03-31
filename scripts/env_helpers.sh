
# Set platform
if [[ "${OSTYPE}" == "darwin"* ]]; then
    readonly IRONFOX_PLATFORM='darwin'
else
    readonly IRONFOX_PLATFORM='linux'
fi
export IRONFOX_PLATFORM

# Set OS
if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
    readonly IRONFOX_OS='osx'
elif [[ "${IRONFOX_PLATFORM}" == 'linux' ]]; then
    if [[ -f "/etc/os-release" ]]; then
        source /etc/os-release
        if [[ -n "${ID}" ]]; then
            readonly IRONFOX_OS="${ID}"
        else
            readonly IRONFOX_OS='unknown'
        fi
    else
        readonly IRONFOX_OS='unknown'
    fi
else
    readonly IRONFOX_OS='unknown'
fi
export IRONFOX_OS

# Set architecture
readonly PLATFORM_ARCH=$(uname -m)
if [[ "${PLATFORM_ARCH}" == 'arm64' ]]; then
    readonly IRONFOX_PLATFORM_ARCH='aarch64'
else
    readonly IRONFOX_PLATFORM_ARCH='x86-64'
fi
export IRONFOX_PLATFORM_ARCH
