#!/bin/bash

# IronFox environment variables

set -euo pipefail

# Set `IRONFOX_ROOT`
function set_root() {
  # If `IRONFOX_ROOT` is already set to a valid directory, we're done
  if [[ -n "${IRONFOX_ROOT+x}" ]] && [[ -d "${IRONFOX_ROOT}" ]]; then
    readonly IRONFOX_ROOT
    return 0
  fi

  # Find dirname
  if [[ -n "${IRONFOX_DIRNAME+x}" ]] && [[ -x "${IRONFOX_DIRNAME}" ]]; then
    local -r dirname="${IRONFOX_DIRNAME}"
  elif [[ -x '/bin/dirname' ]]; then
    local -r dirname='/bin/dirname'
  elif [[ -x '/usr/bin/dirname' ]]; then
    local -r dirname='/usr/bin/dirname'
  else
    if ! command -v dirname > /dev/null 2>&1; then
      echo "ERROR: Missing dirname!" >&2
      exit 1
    fi
    # It isn't a known location, so we sadly have to just fall-back to the PATH
    local -r dirname="$(dirname)"
  fi

  local -r root_txt="$("${dirname}" $0)/root.txt"

  if [[ ! -f "${root_txt}" ]]; then
    readonly IRONFOX_ROOT=$(cd "$("${dirname}" "${BASH_SOURCE[0]}")/.." && pwd)
    if [[ -d "${IRONFOX_ROOT}" ]]; then
      echo -n "${IRONFOX_ROOT}" > "${root_txt}" || exit 1
    else
      echo "ERROR: Unable to find a valid root directory: '${IRONFOX_ROOT}'!"
      exit 1
    fi
  else
    # Find cat
    if [[ -n "${IRONFOX_CAT+x}" ]] && [[ -x "${IRONFOX_CAT}" ]]; then
      local -r cat="${IRONFOX_CAT}"
    elif [[ -x '/bin/cat' ]]; then
      local -r cat='/bin/cat'
    elif [[ -x '/usr/bin/cat' ]]; then
      local -r cat='/usr/bin/cat'
    else
      if ! command -v cat > /dev/null 2>&1; then
        echo "ERROR: Missing cat!" >&2
        exit 1
      fi
      # It isn't a known location, so we sadly have to just fall-back to the PATH
      local -r cat="$(cat)"
    fi

    # Find xargs
    if [[ -n "${IRONFOX_XARGS+x}" ]] && [[ -x "${IRONFOX_XARGS}" ]]; then
      local -r xargs="${IRONFOX_XARGS}"
    elif [[ -x '/bin/xargs' ]]; then
      local -r xargs='/bin/xargs'
    elif [[ -x '/usr/bin/xargs' ]]; then
      local -r xargs='/usr/bin/xargs'
    else
      if ! command -v xargs > /dev/null 2>&1; then
        echo "ERROR: Missing xargs!" >&2
        exit 1
      fi
      # It isn't a known location, so we sadly have to just fall-back to the PATH
      local -r xargs="$(xargs)"
    fi

    readonly IRONFOX_ROOT=$("${cat}" "${root_txt}" | "${xargs}")

    if [[ ! -d "${IRONFOX_ROOT}" ]]; then
      echo "ERROR: Unable to find a valid root directory: '${IRONFOX_ROOT}'!"
      exit 1
    fi
  fi
}

# Add an executable to Phoenix's PATH
## If the executable is not valid, a warning is displayed instead
function add_to_path() {
  function print_usage() {
    echo "Usage: add_to_path '/path/to/PATH' '/path/to/executable' 'executable_env_var' 'executable'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text "ERROR: Please specify the PATH's path!"
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to an executable!'
    print_usage
    exit 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text "ERROR: Please specify the executable's environment variable!"
    print_usage
    exit 1
  fi

  if [[ -z "${4+x}" ]]; then
    echo_red_text 'ERROR: Please specify the executable name!'
    print_usage
    exit 1
  fi

  # Ensure we have ln
  verify_exec "${IRONFOX_LN}" 'IRONFOX_LN' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local -r path="$1"
  local -r exec="$2"
  local -r exec_env="$3"
  local -r exec_name="$4"

  # Create our PATH directory if necessary
  if [[ ! -d "${path}" ]]; then
    "${IRONFOX_MKDIR}" -p "${path}"
  fi

  if verify_env "${exec}" "${exec_env}"; then
    # If our target already exists on the path, remove it
    if [[ -f "${path}/${exec_name}" ]]; then
      "${IRONFOX_RM}" -f "${path}/${exec_name}"
    fi
    "${IRONFOX_LN}" -sf "${exec}" "${path}/${exec_name}"
    echo_green_text "Added '${exec_name}' to PATH (from '${exec_env}')!"
  else
    echo_red_text "WARNING: Unable to add '${exec_name}' to PATH!"
    echo "Please ensure that '${exec_env}' is set to a valid location."
  fi
}

# Add an executable to Phoenix's full PATH
function add_to_full_path() {
  function print_usage() {
    echo "Usage: add_to_full_path '/path/to/executable' 'executable_env_var' 'executable'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to an executable!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text "ERROR: Please specify the executable's environment variable!"
    print_usage
    exit 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text 'ERROR: Please specify the executable name!'
    print_usage
    exit 1
  fi

  # Ensure we have `IRONFOX_PATH`
  verify_env "${IRONFOX_PATH}" 'IRONFOX_PATH' || exit 1

  local -r exec="$1"
  local -r exec_env="$2"
  local -r exec_name="$3"

  add_to_path "${IRONFOX_PATH}" "${exec}" "${exec_env}" "${exec_name}"
}

# Add an executable to Phoenix's lint PATH
function add_to_lint_path() {
  function print_usage() {
    echo "Usage: add_to_lint_path '/path/to/executable' 'executable_env_var' 'executable'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to an executable!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text "ERROR: Please specify the executable's environment variable!"
    print_usage
    exit 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text 'ERROR: Please specify the executable name!'
    print_usage
    exit 1
  fi

  # Ensure we have `IRONFOX_LINT_PATH`
  verify_env "${IRONFOX_LINT_PATH}" 'IRONFOX_LINT_PATH' || exit 1

  local -r exec="$1"
  local -r exec_env="$2"
  local -r exec_name="$3"

  add_to_path "${IRONFOX_LINT_PATH}" "${exec}" "${exec_env}" "${exec_name}"
}

# Set-up the full IronFox PATH
function setup_path() {
  # Ensure we have `IRONFOX_PLATFORM`
  verify_env "${IRONFOX_PLATFORM}" 'IRONFOX_PLATFORM' || exit 1

  add_to_full_path "${IRONFOX_ADB}" 'IRONFOX_ADB' 'adb'
  add_to_full_path "${IRONFOX_ANDROGUARD}" 'IRONFOX_ANDROGUARD' 'androguard'
  add_to_full_path "${IRONFOX_APKSIGNER}" 'IRONFOX_APKSIGNER' 'apksigner'
  add_to_full_path "${IRONFOX_AR}" 'IRONFOX_AR' 'ar'
  add_to_full_path "${IRONFOX_AS}" 'IRONFOX_AS' 'as'
  add_to_full_path "${IRONFOX_AWK}" 'IRONFOX_AWK' 'awk'
  add_to_full_path "${IRONFOX_AWK}" 'IRONFOX_AWK' 'gawk'
  add_to_full_path "${IRONFOX_BASENAME}" 'IRONFOX_BASENAME' 'basename'
  add_to_full_path "${IRONFOX_BASH}" 'IRONFOX_BASH' 'bash'
  add_to_full_path "${IRONFOX_BUNDLETOOL}" 'IRONFOX_BUNDLETOOL' 'bundletool'
  add_to_full_path "${IRONFOX_CARGO}" 'IRONFOX_CARGO' 'cargo'
  add_to_full_path "${IRONFOX_CAT}" 'IRONFOX_CAT' 'cat'
  add_to_full_path "${IRONFOX_CBINDGEN}" 'IRONFOX_CBINDGEN' 'cbindgen'
  add_to_full_path "${IRONFOX_CC}" 'IRONFOX_CC' 'cc'
  add_to_full_path "${IRONFOX_CHMOD}" 'IRONFOX_CHMOD' 'chmod'
  add_to_full_path "${IRONFOX_CLANG}" 'IRONFOX_CLANG' 'clang'
  add_to_full_path "${IRONFOX_CMAKE}" 'IRONFOX_CMAKE' 'cmake'
  add_to_full_path "${IRONFOX_CMP}" 'IRONFOX_CMP' 'cmp'
  add_to_full_path "${IRONFOX_CP}" 'IRONFOX_CP' 'cp'
  add_to_full_path "${IRONFOX_CPLUSPLUS}" 'IRONFOX_CPLUSPLUS' 'c++'
  add_to_full_path "${IRONFOX_CURL}" 'IRONFOX_CURL' 'curl'
  add_to_full_path "${IRONFOX_CUT}" 'IRONFOX_CUT' 'cut'
  add_to_full_path "${IRONFOX_DATE}" 'IRONFOX_DATE' 'date'
  add_to_full_path "${IRONFOX_DATE}" 'IRONFOX_DATE' 'gdate'
  add_to_full_path "${IRONFOX_DIFF}" 'IRONFOX_DIFF' 'diff'
  add_to_full_path "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' 'dirname'
  add_to_full_path "${IRONFOX_ECHO}" 'IRONFOX_ECHO' 'echo'
  add_to_full_path "${IRONFOX_EGREP}" 'IRONFOX_EGREP' 'egrep'
  add_to_full_path "${IRONFOX_EXPR}" 'IRONFOX_EXPR' 'expr'
  add_to_full_path "${IRONFOX_FIND}" 'IRONFOX_FIND' 'find'
  add_to_full_path "${IRONFOX_GIT}" 'IRONFOX_GIT' 'git'
  add_to_full_path "${IRONFOX_GIT_LFS}" 'IRONFOX_GIT_LFS' 'git-lfs'
  add_to_full_path "${IRONFOX_GRADLE}" 'IRONFOX_GRADLE' 'gradle'
  add_to_full_path "${IRONFOX_GREP}" 'IRONFOX_GREP' 'grep'
  add_to_full_path "${IRONFOX_GZIP}" 'IRONFOX_GZIP' 'gzip'
  add_to_full_path "${IRONFOX_HEAD}" 'IRONFOX_HEAD' 'head'
  add_to_full_path "${IRONFOX_HOSTNAME}" 'IRONFOX_HOSTNAME' 'hostname'
  add_to_full_path "${IRONFOX_JAVA}" 'IRONFOX_JAVA' 'java'
  add_to_full_path "${IRONFOX_JQ}" 'IRONFOX_JQ' 'jq'
  add_to_full_path "${IRONFOX_LD}" 'IRONFOX_LD' 'ld'
  add_to_full_path "${IRONFOX_LIBTOOL}" 'IRONFOX_LIBTOOL' 'libtool'
  add_to_full_path "${IRONFOX_LLVM_PROFDATA}" 'IRONFOX_LLVM_PROFDATA' 'llvm-profdata'
  add_to_full_path "${IRONFOX_LN}" 'IRONFOX_LN' 'ln'
  add_to_full_path "${IRONFOX_LS}" 'IRONFOX_LS' 'ls'
  add_to_full_path "${IRONFOX_MACH}" 'IRONFOX_MACH' 'mach'
  add_to_full_path "${IRONFOX_MAKE}" 'IRONFOX_MAKE' 'gmake'
  add_to_full_path "${IRONFOX_MAKE}" 'IRONFOX_MAKE' 'make'
  add_to_full_path "${IRONFOX_MD5SUM}" 'IRONFOX_MD5SUM' 'md5sum'
  add_to_full_path "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' 'mkdir'
  add_to_full_path "${IRONFOX_MKTEMP}" 'IRONFOX_MKTEMP' 'mktemp'
  add_to_full_path "${IRONFOX_M4}" 'IRONFOX_M4' 'm4'
  add_to_full_path "${IRONFOX_MV}" 'IRONFOX_MV' 'mv'
  add_to_full_path "${IRONFOX_NASM}" 'IRONFOX_NASM' 'nasm'
  add_to_full_path "${IRONFOX_NINJA}" 'IRONFOX_NINJA' 'ninja'
  add_to_full_path "${IRONFOX_NODEJS}" 'IRONFOX_NODEJS' 'node'
  add_to_full_path "${IRONFOX_NM}" 'IRONFOX_NM' 'nm'
  add_to_full_path "${IRONFOX_NPM}" 'IRONFOX_NPM' 'npm'
  add_to_full_path "${IRONFOX_OTOOL}" 'IRONFOX_OTOOL' 'otool'
  add_to_full_path "${IRONFOX_PATCH}" 'IRONFOX_PATCH' 'gpatch'
  add_to_full_path "${IRONFOX_PATCH}" 'IRONFOX_PATCH' 'patch'
  add_to_full_path "${IRONFOX_PERL}" 'IRONFOX_PERL' 'perl'
  add_to_full_path "${IRONFOX_PIP}" 'IRONFOX_PIP' 'pip'
  add_to_full_path "${IRONFOX_PWD}" 'IRONFOX_PWD' 'pwd'
  add_to_full_path "${IRONFOX_PYTHON}" 'IRONFOX_PYTHON' 'python'
  add_to_full_path "${IRONFOX_PYTHON}" 'IRONFOX_PYTHON' 'python3'
  add_to_full_path "${IRONFOX_PYTHON}" 'IRONFOX_PYTHON' 'python3.14'
  add_to_full_path "${IRONFOX_REALPATH}" 'IRONFOX_REALPATH' 'realpath'
  add_to_full_path "${IRONFOX_RM}" 'IRONFOX_RM' 'rm'
  add_to_full_path "${IRONFOX_RMDIR}" 'IRONFOX_RMDIR' 'rmdir'
  add_to_full_path "${IRONFOX_RUSTC}" 'IRONFOX_RUSTC' 'rustc'
  add_to_full_path "${IRONFOX_RUSTDOC}" 'IRONFOX_RUSTDOC' 'rustdoc'
  add_to_full_path "${IRONFOX_RUSTUP}" 'IRONFOX_RUSTUP' 'rustup'
  add_to_full_path "${IRONFOX_S3CMD}" 'IRONFOX_S3CMD' 's3cmd'
  add_to_full_path "${IRONFOX_SED}" 'IRONFOX_SED' 'gsed'
  add_to_full_path "${IRONFOX_SED}" 'IRONFOX_SED' 'sed'
  add_to_full_path "${IRONFOX_SH}" 'IRONFOX_SH' 'sh'
  add_to_full_path "${IRONFOX_SHASUM}" 'IRONFOX_SHASUM' 'shasum'
  add_to_full_path "${IRONFOX_SLEEP}" 'IRONFOX_SLEEP' 'sleep'
  add_to_full_path "${IRONFOX_SORT}" 'IRONFOX_SORT' 'sort'
  add_to_full_path "${IRONFOX_STRIP}" 'IRONFOX_STRIP' 'strip'
  add_to_full_path "${IRONFOX_SYSCTL}" 'IRONFOX_SYSCTL' 'sysctl'
  add_to_full_path "${IRONFOX_TAIL}" 'IRONFOX_TAIL' 'tail'
  add_to_full_path "${IRONFOX_TAR}" 'IRONFOX_TAR' 'gtar'
  add_to_full_path "${IRONFOX_TAR}" 'IRONFOX_TAR' 'tar'
  add_to_full_path "${IRONFOX_TEE}" 'IRONFOX_TEE' 'tee'
  add_to_full_path "${IRONFOX_TOUCH}" 'IRONFOX_TOUCH' 'touch'
  add_to_full_path "${IRONFOX_TR}" 'IRONFOX_TR' 'tr'
  add_to_full_path "${IRONFOX_UNAME}" 'IRONFOX_UNAME' 'uname'
  add_to_full_path "${IRONFOX_UNZIP}" 'IRONFOX_UNZIP' 'unzip'
  add_to_full_path "${IRONFOX_UV}" 'IRONFOX_UV' 'uv'
  add_to_full_path "${IRONFOX_WC}" 'IRONFOX_WC' 'wc'
  add_to_full_path "${IRONFOX_WHOAMI}" 'IRONFOX_WHOAMI' 'whoami'
  add_to_full_path "${IRONFOX_XARGS}" 'IRONFOX_XARGS' 'xargs'
  add_to_full_path "${IRONFOX_XZ}" 'IRONFOX_XZ' 'xz'
  add_to_full_path "${IRONFOX_YES}" 'IRONFOX_YES' 'yes'
  add_to_full_path "${IRONFOX_YQ}" 'IRONFOX_YQ' 'yq'

  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
    # OS X-specific
    add_to_full_path "${IRONFOX_DOT_CLEAN}" 'IRONFOX_DOT_CLEAN' 'dot_clean'
    add_to_full_path "${IRONFOX_SW_VERS}" 'IRONFOX_SW_VERS' 'sw_vers'
    add_to_full_path "${IRONFOX_XCRUN}" 'IRONFOX_XCRUN' 'xcrun'
  else
    # Linux-specific
    add_to_full_path "${IRONFOX_GCC}" 'IRONFOX_GCC' 'gcc'
    add_to_full_path "${IRONFOX_NPROC}" 'IRONFOX_NPROC' 'nproc'
  fi

  PATH="${IRONFOX_PATH}"
  export PATH
}

# Set-up a minimal PATH for linting
function setup_lint_path() {
  add_to_lint_path "${IRONFOX_BASH}" 'IRONFOX_BASH' 'bash'
  add_to_lint_path "${IRONFOX_GIT}" 'IRONFOX_GIT' 'git'
  add_to_lint_path "${IRONFOX_LS}" 'IRONFOX_LS' 'ls'
  add_to_lint_path "${IRONFOX_SH}" 'IRONFOX_SH' 'sh'
  add_to_lint_path "${IRONFOX_SHELLCHECK}" 'IRONFOX_SHELLCHECK' 'shellcheck'
  add_to_lint_path "${IRONFOX_SHFMT}" 'IRONFOX_SHFMT' 'shfmt'

  readonly PATH="${IRONFOX_LINT_PATH}"
  export PATH
}

# For CI, ensure external environment variables are set
function setup_ci() {
  # Get our current branch
  if [[ -z "${CI_COMMIT_REF_NAME+x}" ]] || [[ "${CI_COMMIT_REF_NAME}" == "" ]] ||
    [[ "${CI_COMMIT_REF_NAME}" == "null" ]]; then
    echo_red_text "ERROR: Missing current branch! Please set 'CI_COMMIT_REF_NAME'."
    exit 1
  else
    readonly IRONFOX_CURRENT_BRANCH="${CI_COMMIT_REF_NAME}"
    export IRONFOX_CURRENT_BRANCH
  fi

  # Ensure our branches are set
  if [[ -z "${IRONFOX_DEV_BRANCH+x}" ]] || [[ "${IRONFOX_DEV_BRANCH}" == "" ]] ||
    [[ "${IRONFOX_DEV_BRANCH}" == "null" ]]; then
    echo_red_text "ERROR: Missing developer branch! Please set 'IRONFOX_DEV_BRANCH'."
    exit 1
  fi

  if [[ -z "${IRONFOX_PROD_BRANCH+x}" ]] || [[ "${IRONFOX_PROD_BRANCH}" == "" ]] ||
    [[ "${IRONFOX_PROD_BRANCH}" == "null" ]]; then
    echo_red_text "ERROR: Missing production branch! Please set 'IRONFOX_PROD_BRANCH'."
    exit 1
  fi
}

# Remove the legacy `env_local.sh`
function clean_env_local() {
  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  if [[ -f "$(dirname $0)/env_local.sh" ]]; then
    "${IRONFOX_RM}" -f "$(dirname $0)/env_local.sh"
  fi
}

# Set-up our environment
function set_env() {
  if [[ -z "${IRONFOX_SET_ENVS+x}" ]] || [[ "${IRONFOX_SET_ENVS}" != 1 ]]; then
    # Get our root directory
    set_root || exit 1

    # Ensure we have `IRONFOX_ROOT`
    if [[ -z "${IRONFOX_ROOT+x}" ]] || [[ ! -d "${IRONFOX_ROOT}" ]]; then
      echo "ERROR: 'IRONFOX_ROOT' is missing or invalid!"
      exit 1
    fi

    # Do not use the system PATH
    unset PATH || exit 1
    hash -r || exit 1

    # Handle CI-specific logic
    if [[ -n "${IRONFOX_CI+x}" ]]; then
      setup_ci || exit 1
    fi

    source "${IRONFOX_ROOT}/scripts/env_common.sh" || exit 1

    # Include utilities
    if [[ -z "${IRONFOX_UTILS+x}" ]] || [[ ! -f "${IRONFOX_UTILS}" ]] || [[ ! -s "${IRONFOX_UTILS}" ]]; then
      echo "ERROR: 'IRONFOX_UTILS' is missing or invalid!"
      exit 1
    fi
    source "${IRONFOX_UTILS}" || exit 1

    # Set-up our PATH
    if [[ -n "${IRONFOX_LINTING+x}" ]]; then
      setup_lint_path || exit 1
    else
      setup_path || exit 1
    fi

    # Clean-up the old `env_local.sh` (if necessary)
    clean_env_local
  fi
}

# Set-up our environment
set_env
