# shellcheck shell=bash

# Set our platform/OS
function set_platform() {
  # Set platform
  unset IRONFOX_PLATFORM
  unset IRONFOX_PLATFORM_PRETTY

  # First, leverage `PHOENIX_HOST_PLATFORM`
  if [[ -n "${PHOENIX_HOST_PLATFORM+x}" ]]; then
    if [[ "${PHOENIX_HOST_PLATFORM}" == 'android' ]] || [[ "${PHOENIX_HOST_PLATFORM}" == 'linux' ]]; then
      readonly IRONFOX_PLATFORM='linux'
    elif [[ "${PHOENIX_HOST_PLATFORM}" == 'osx' ]] || [[ "${PHOENIX_HOST_PLATFORM}" == 'osx-intel' ]]; then
      readonly IRONFOX_PLATFORM='darwin'
    elif [[ "${PHOENIX_HOST_PLATFORM}" == 'windows' ]]; then
      readonly IRONFOX_PLATFORM='windows'
    fi
  fi

  # Check `OSTYPE`
  if [[ -z "${IRONFOX_PLATFORM+x}" ]] && [[ -n "${OSTYPE+x}" ]]; then
    if [[ "${OSTYPE}" == 'cygwin' ]] || [[ "${OSTYPE}" == 'msys' ]] || [[ "${OSTYPE}" == 'win32' ]]; then
      readonly IRONFOX_PLATFORM='windows'
    elif [[ "${OSTYPE}" == "darwin"* ]]; then
      readonly IRONFOX_PLATFORM='darwin'
    elif [[ "${OSTYPE}" == 'linux-android' ]] || [[ "${OSTYPE}" == 'linux-gnu' ]]; then
      readonly IRONFOX_PLATFORM='linux'
    fi
  fi

  # Check `OS`
  if [[ -z "${IRONFOX_PLATFORM+x}" ]] && [[ -n "${OS+x}" ]] && [[ "${OS}" == 'Windows_NT' ]]; then
    readonly IRONFOX_PLATFORM='windows'
  fi

  # Not much else we can do :(
  if [[ -z "${IRONFOX_PLATFORM+x}" ]]; then
    readonly IRONFOX_PLATFORM='unknown'
  fi

  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
    readonly IRONFOX_PLATFORM_PRETTY='Darwin'
  elif [[ "${IRONFOX_PLATFORM}" == 'linux' ]]; then
    readonly IRONFOX_PLATFORM_PRETTY='Linux'
  elif [[ "${IRONFOX_PLATFORM}" == 'windows' ]]; then
    readonly IRONFOX_PLATFORM_PRETTY='Windows'
  elif [[ "${IRONFOX_PLATFORM}" == 'unknown' ]]; then
    readonly IRONFOX_PLATFORM_PRETTY='Unknown'
  else
    echo "ERROR: Invalid platform: '${IRONFOX_PLATFORM}'!"
    return 1
  fi

  # Set OS
  unset IRONFOX_OS
  unset IRONFOX_OS_PRETTY

  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
    readonly IRONFOX_OS='osx'
  elif [[ "${IRONFOX_PLATFORM}" == 'windows' ]]; then
    readonly IRONFOX_OS='windows'
  elif [[ "${IRONFOX_PLATFORM}" == 'linux' ]]; then
    # First, we can check for Android with `PHOENIX_HOST_PLATFORM`
    if [[ -n "${PHOENIX_HOST_PLATFORM+x}" ]] && [[ "${PHOENIX_HOST_PLATFORM}" == 'android' ]]; then
      readonly IRONFOX_OS='android'
    fi

    # We can also check for Android with `OSTYPE`
    if [[ -z "${IRONFOX_OS+x}" ]] && [[ -n "${OSTYPE+x}" ]] && [[ "${OSTYPE}" == 'linux-android' ]]; then
      readonly IRONFOX_OS='android'
    fi

    # Otherwise, we fall back to `/etc/os-release`
    if [[ -z "${IRONFOX_OS+x}" ]] && [[ -f '/etc/os-release' ]] && [[ -s '/etc/os-release' ]]; then
      source '/etc/os-release'
      if [[ -n "${ID+x}" ]]; then
        readonly IRONFOX_OS="${ID+x}"
      fi
    fi
  fi

  # Not much else we can do :(
  if [[ -z "${IRONFOX_OS+x}" ]]; then
    readonly IRONFOX_OS='unknown'
  fi

  if [[ "${IRONFOX_OS}" == 'android' ]]; then
    readonly IRONFOX_OS_PRETTY='Android'
  elif [[ "${IRONFOX_OS}" == 'fedora' ]]; then
    readonly IRONFOX_OS_PRETTY='Fedora'
  elif [[ "${IRONFOX_OS}" == 'osx' ]]; then
    readonly IRONFOX_OS_PRETTY='OS X'
  elif [[ "${IRONFOX_OS}" == 'secureblue' ]]; then
    readonly IRONFOX_OS_PRETTY='Secureblue'
  elif [[ "${IRONFOX_OS}" == 'ubuntu' ]]; then
    readonly IRONFOX_OS_PRETTY='Ubuntu'
  elif [[ "${IRONFOX_OS}" == 'windows' ]]; then
    readonly IRONFOX_OS_PRETTY='Windows'
  elif [[ "${IRONFOX_OS}" == 'unknown' ]]; then
    readonly IRONFOX_OS_PRETTY='Unknown'
  elif [[ "${IRONFOX_PLATFORM}" == 'linux' ]] && [[ -n "${ID+x}" ]]; then
    readonly IRONFOX_OS_PRETTY="${IRONFOX_OS}"
  else
    echo "ERROR: Invalid operating system: '${IRONFOX_OS}'!"
    return 1
  fi
}

# Set our architecture
function set_arch() {
  unset IRONFOX_PLATFORM_ARCH
  unset IRONFOX_PLATFORM_ARCH_PRETTY
  unset IRONFOX_RUST_PLATFORM_ARCH

  # First, if we're on OS X, we can actually try `PHOENIX_HOST_PLATFORM`
  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]] && [[ -n "${PHOENIX_HOST_PLATFORM+x}" ]]; then
    if [[ "${PHOENIX_HOST_PLATFORM}" == 'osx-intel' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='x86_64'
    elif [[ "${PHOENIX_HOST_PLATFORM}" == 'osx' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='arm64'
    fi
  fi

  if [[ -z "${IRONFOX_PLATFORM_ARCH+x}" ]]; then
    # Find uname
    if [[ -n "${IRONFOX_UNAME+x}" ]] && [[ -x "${IRONFOX_UNAME}" ]]; then
      local -r uname="${IRONFOX_UNAME}"
    elif [[ -x '/bin/uname' ]]; then
      local -r uname='/bin/uname'
    elif [[ -x '/usr/bin/uname' ]]; then
      local -r uname='/usr/bin/uname'
    else
      if ! command -v uname > /dev/null 2>&1; then
        echo "ERROR: Missing uname!" >&2
        return 1
      fi
      # It isn't a known location, so we sadly have to just fall-back to the PATH
      local -r uname="$(uname)"
    fi

    # Set architecture
    local -r arch=$("${uname}" -m)
    if [[ "${arch}" == 'aarch64' ]] || [[ "${arch}" == 'aarch64_be' ]] || [[ "${arch}" == 'arm64' ]] || [[ "${arch}" == 'armv8b' ]] ||
      [[ "${arch}" == 'armv8l' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='arm64'
    elif [[ "${arch}" == 'amd64' ]] || [[ "${arch}" == 'x86_64' ]] || [[ "${arch}" == 'x86_64-AT386' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='x86_64'
    elif [[ "${arch}" == 'armv4t' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='armv4'
    elif [[ "${arch}" == 'armv5t' ]] || [[ "${arch}" == 'armv5te' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='armv5'
    elif [[ "${arch}" == 'armv6' ]] || [[ "${arch}" == 'armv6j' ]] || [[ "${arch}" == 'armv6k' ]] || [[ "${arch}" == 'armv6kz' ]] ||
      [[ "${arch}" == 'armv6l' ]] || [[ "${arch}" == 'armv6t2' ]] || [[ "${arch}" == 'armv6z' ]] || [[ "${arch}" == 'armv6zk' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='armv6'
    elif [[ "${arch}" == 'armv7' ]] || [[ "${arch}" == 'armv7l' ]] || [[ "${arch}" == 'armv7ve' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='arm'
    elif [[ "${arch}" == 'i386' ]] || [[ "${arch}" == 'i386-AT38621' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='i386'
    elif [[ "${arch}" == 'i486' ]] || [[ "${arch}" == 'i486-AT38621' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='i486'
    elif [[ "${arch}" == 'i586' ]] || [[ "${arch}" == 'i586-AT38621' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='i586'
    elif [[ "${arch}" == 'i686' ]] || [[ "${arch}" == 'i686-64' ]] || [[ "${arch}" == 'i686-AT386' ]] || [[ "${arch}" == 'i686-AT38621' ]] ||
      [[ "${arch}" == 'i86pc' ]] || [[ "${arch}" == 'x86' ]] || [[ "${arch}" == 'x86pc' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='x86'
    elif [[ "${arch}" == 'ppc' ]] || [[ "${arch}" == 'ppcle' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='ppc'
    elif [[ "${arch}" == 'ppc64' ]] || [[ "${arch}" == 'ppc64le' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='ppc64'
    elif [[ "${arch}" == 'riscv64' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='riscv'
    elif [[ "${arch}" == 's390' ]] || [[ "${arch}" == 's390x' ]]; then
      readonly IRONFOX_PLATFORM_ARCH='s390x'
    fi
  fi

  # Not much else we can do :(
  if [[ -z "${IRONFOX_PLATFORM_ARCH+x}" ]]; then
    readonly IRONFOX_PLATFORM_ARCH='unknown'
  fi

  if [[ "${IRONFOX_PLATFORM_ARCH}" == 'arm' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='ARM'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'arm64' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='ARM64'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'armv4' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='ARMv4'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'armv5' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='ARMv5'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'armv6' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='ARMv6'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'ppc' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='PPC'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'ppc64' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='PPC64'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'riscv' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='RISC-V'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'i386' ]] || [[ "${IRONFOX_PLATFORM_ARCH}" == 'i486' ]] || [[ "${IRONFOX_PLATFORM_ARCH}" == 'i586' ]] ||
    [[ "${IRONFOX_PLATFORM_ARCH}" == 's390x' ]] || [[ "${IRONFOX_PLATFORM_ARCH}" == 'x86' ]] || [[ "${IRONFOX_PLATFORM_ARCH}" == 'x86_64' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY="${IRONFOX_PLATFORM_ARCH}"
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'unknown' ]]; then
    readonly IRONFOX_PLATFORM_ARCH_PRETTY='Unknown'
  else
    echo "ERROR: Invalid architecture: '${IRONFOX_PLATFORM_ARCH}'!"
    return 1
  fi

  # Set the platform architecture for ex. Rust
  if [[ "${IRONFOX_PLATFORM_ARCH}" == 'arm64' ]]; then
    readonly IRONFOX_RUST_PLATFORM_ARCH='aarch64'
  elif [[ "${IRONFOX_PLATFORM_ARCH}" == 'x86_64' ]]; then
    readonly IRONFOX_RUST_PLATFORM_ARCH='x86-64'
  else
    readonly IRONFOX_RUST_PLATFORM_ARCH='unknown'
  fi
}

# Set our platform/OS
set_platform || return 1

# Set our architecture
set_arch || return 1

echo "Detected platform:         '${IRONFOX_PLATFORM_PRETTY}'"
echo "Detected operating system: '${IRONFOX_OS_PRETTY}'"
echo "Detected architecture:     '${IRONFOX_PLATFORM_ARCH_PRETTY}'"
