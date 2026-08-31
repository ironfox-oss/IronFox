#!/bin/bash

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh || exit 1

# Include utilities
source "${IRONFOX_UTILS}" || exit 1

# Set verbosity
set_verbosity

# Include download utilities
source "${IRONFOX_DOWNLOAD_UTILS}" || exit 1

# Include file utilities
source "${IRONFOX_FILE_UTILS}" || exit 1

if [[ -z "${IRONFOX_FROM_SOURCES+x}" ]]; then
  echo_red_text "ERROR: Do not call 'get_sources-if.sh' directly! Instead, use 'get_sources.sh'." >&1
  exit 1
fi

# Ensure we have rm
verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

readonly target="$1"
readonly mode="$2"

# Set-up target parameters
IRONFOX_GET_SOURCE_ANDROGUARD=0
IRONFOX_GET_SOURCE_ANDROID_NDK=0
IRONFOX_GET_SOURCE_ANDROID_SDK=0
IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS=0
IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35=0
IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM=0
IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36=0
IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS=0
IRONFOX_GET_SOURCE_AS=0
IRONFOX_GET_SOURCE_BUNDLETOOL=0
IRONFOX_GET_SOURCE_CBINDGEN=0
IRONFOX_GET_SOURCE_GECKO=0
IRONFOX_GET_SOURCE_GECKO_L10N=0
IRONFOX_GET_SOURCE_GLEAN=0
IRONFOX_GET_SOURCE_GLEAN_PARSER=0
IRONFOX_GET_SOURCE_GRADLE=0
IRONFOX_GET_SOURCE_GYP=0
IRONFOX_GET_SOURCE_JDK_17=0
IRONFOX_GET_SOURCE_JDK_21=0
IRONFOX_GET_SOURCE_JDK_25=0
IRONFOX_GET_SOURCE_MICROG=0
IRONFOX_GET_SOURCE_NODE=0
IRONFOX_GET_SOURCE_NPM=0
IRONFOX_GET_SOURCE_PHOENIX=0
IRONFOX_GET_SOURCE_PIP=0
IRONFOX_GET_SOURCE_PREBUILDS=0
IRONFOX_GET_SOURCE_PYTHON=0
IRONFOX_GET_SOURCE_PYYAML=0
IRONFOX_GET_SOURCE_RUST=0
IRONFOX_GET_SOURCE_S3CMD=0
IRONFOX_GET_SOURCE_SHELLCHECK=0
IRONFOX_GET_SOURCE_SHFMT=0
IRONFOX_GET_SOURCE_UNIFFI=0
IRONFOX_GET_SOURCE_UP_AC=0
IRONFOX_GET_SOURCE_UV=0
IRONFOX_GET_SOURCE_WASI=0

if [[ "${target}" == 'androguard' ]]; then
  # Get androguard
  ## NOTE: This isn't installed if "all" is used below, as it's only used in CI and targeted specifically when it's needed
  IRONFOX_GET_SOURCE_ANDROGUARD=1
elif [[ "${target}" == 'android-ndk' ]]; then
  # Get Android NDK
  IRONFOX_GET_SOURCE_ANDROID_NDK=1
elif [[ "${target}" == 'android-sdk' ]]; then
  # Get Android SDK
  IRONFOX_GET_SOURCE_ANDROID_SDK=1
elif [[ "${target}" == 'android-sdk-build-tools' ]]; then
  # Get Android SDK Build Tools (latest)
  IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS=1
elif [[ "${target}" == 'android-sdk-build-tools-35' ]]; then
  # Get Android SDK Build Tools (35) (Required by Glean)
  IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35=1
elif [[ "${target}" == 'android-sdk-platform' ]]; then
  # Get Android SDK Platform (latest)
  IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM=1
elif [[ "${target}" == 'android-sdk-platform-36' ]]; then
  # Get Android SDK Platform (36)
  IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36=1
elif [[ "${target}" == 'android-sdk-platform-tools' ]]; then
  # Get Android SDK Platform Tools
  IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS=1
elif [[ "${target}" == 'as' ]]; then
  # Get Application Services
  IRONFOX_GET_SOURCE_AS=1
elif [[ "${target}" == 'bundletool' ]]; then
  # Get + set-up Bundletool
  IRONFOX_GET_SOURCE_BUNDLETOOL=1
elif [[ "${target}" == 'cbindgen' ]]; then
  # Get cbindgen
  IRONFOX_GET_SOURCE_CBINDGEN=1
elif [[ "${target}" == 'firefox' ]]; then
  # Get Firefox (Gecko/mozilla-central)
  IRONFOX_GET_SOURCE_GECKO=1
elif [[ "${target}" == 'firefox-l10n' ]]; then
  # Get firefox-l10n
  IRONFOX_GET_SOURCE_GECKO_L10N=1
elif [[ "${target}" == 'glean' ]]; then
  # Get Glean
  IRONFOX_GET_SOURCE_GLEAN=1
elif [[ "${target}" == 'glean-parser' ]]; then
  # Get glean-parser
  IRONFOX_GET_SOURCE_GLEAN_PARSER=1
elif [[ "${target}" == 'gradle' ]]; then
  # Get + set-up Gradle
  IRONFOX_GET_SOURCE_GRADLE=1
elif [[ "${target}" == 'gyp' ]]; then
  # Get gyp-next
  IRONFOX_GET_SOURCE_GYP=1
elif [[ "${target}" == 'jdk-17' ]]; then
  # Get OpenJDK (17) (Required by GeckoView)
  IRONFOX_GET_SOURCE_JDK_17=1
elif [[ "${target}" == 'jdk-21' ]]; then
  # Get OpenJDK (21)
  IRONFOX_GET_SOURCE_JDK_21=1
elif [[ "${target}" == 'jdk-25' ]]; then
  # Get OpenJDK (25)
  IRONFOX_GET_SOURCE_JDK_25=1
elif [[ "${target}" == 'microg' ]]; then
  # Get microG
  IRONFOX_GET_SOURCE_MICROG=1
elif [[ "${target}" == 'node' ]]; then
  # Get + set-up Node.js
  IRONFOX_GET_SOURCE_NODE=1
elif [[ "${target}" == 'npm' ]]; then
  # Get + set-up npm
  IRONFOX_GET_SOURCE_NPM=1
elif [[ "${target}" == 'phoenix' ]]; then
  # Get Phoenix
  IRONFOX_GET_SOURCE_PHOENIX=1
elif [[ "${target}" == 'prebuilds' ]]; then
  # Get the IronFox prebuilds repo
  IRONFOX_GET_SOURCE_PREBUILDS=1
elif [[ "${target}" == 'pip' ]]; then
  # Get + set-up pip
  IRONFOX_GET_SOURCE_PIP=1
elif [[ "${target}" == 'python' ]]; then
  # Get Python
  IRONFOX_GET_SOURCE_PYTHON=1
elif [[ "${target}" == 'pyyaml' ]]; then
  # Get PyYAML
  ## NOTE: This isn't installed if "all" is used below, as it's only used in CI and targeted specifically when it's needed
  IRONFOX_GET_SOURCE_PYYAML=1
elif [[ "${target}" == 'rust' ]]; then
  # Get + set-up rust/cargo
  IRONFOX_GET_SOURCE_RUST=1
elif [[ "${target}" == 's3cmd' ]]; then
  # Get s3cmd
  ## NOTE: This isn't installed if "all" is used below, as it's only used in CI and targeted specifically when it's needed
  IRONFOX_GET_SOURCE_S3CMD=1
elif [[ "${target}" == 'shellcheck' ]]; then
  # Get shellcheck
  IRONFOX_GET_SOURCE_SHELLCHECK=1
elif [[ "${target}" == 'shfmt' ]]; then
  # Get shfmt
  IRONFOX_GET_SOURCE_SHFMT=1
elif [[ "${target}" == 'uniffi' ]]; then
  # Get uniffi
  IRONFOX_GET_SOURCE_UNIFFI=1
elif [[ "${target}" == 'up-ac' ]]; then
  # Get UnifiedPush-AC
  IRONFOX_GET_SOURCE_UP_AC=1
elif [[ "${target}" == 'uv' ]]; then
  # Get + set-up uv
  IRONFOX_GET_SOURCE_UV=1
elif [[ "${target}" == 'wasi' ]]; then
  # Get WASI SDK
  IRONFOX_GET_SOURCE_WASI=1
elif [[ "${target}" == 'all' ]]; then
  # If no argument is specified (or argument is set to "all"), just get everything
  IRONFOX_GET_SOURCE_ANDROID_NDK=1
  IRONFOX_GET_SOURCE_ANDROID_SDK=1
  IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS=1
  IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35=1
  IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM=1
  IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36=1
  IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS=1
  IRONFOX_GET_SOURCE_AS=1
  IRONFOX_GET_SOURCE_BUNDLETOOL=1
  IRONFOX_GET_SOURCE_CBINDGEN=1
  IRONFOX_GET_SOURCE_GECKO=1
  IRONFOX_GET_SOURCE_GECKO_L10N=1
  IRONFOX_GET_SOURCE_GLEAN=1
  IRONFOX_GET_SOURCE_GLEAN_PARSER=1
  IRONFOX_GET_SOURCE_GRADLE=1
  IRONFOX_GET_SOURCE_GYP=1
  IRONFOX_GET_SOURCE_JDK_17=1
  IRONFOX_GET_SOURCE_JDK_21=1
  IRONFOX_GET_SOURCE_JDK_25=1
  IRONFOX_GET_SOURCE_MICROG=1
  IRONFOX_GET_SOURCE_NODE=1
  IRONFOX_GET_SOURCE_NPM=1
  IRONFOX_GET_SOURCE_PHOENIX=1
  IRONFOX_GET_SOURCE_PIP=1
  IRONFOX_GET_SOURCE_PYTHON=1
  IRONFOX_GET_SOURCE_RUST=1
  IRONFOX_GET_SOURCE_UP_AC=1
  IRONFOX_GET_SOURCE_UV=1

  # CI only uses shellcheck and shfmt in the `lint` stage (where they're retrieved directly)
  # If git is missing, we know the user isn't contributing (at least from this repo directly), so we don't need to download them in
  # those cases either
  if [[ -x "${IRONFOX_GIT}" ]] && [[ "${IRONFOX_CI}" != 1 ]]; then
    IRONFOX_GET_SOURCE_SHELLCHECK=1
    IRONFOX_GET_SOURCE_SHFMT=1
  fi

  if [[ "${IRONFOX_NO_PREBUILDS}" == 1 ]]; then
    # If IRONFOX_NO_PREBUILDS is true, we need to get the Prebuilds repo (so that they can be built from source)
    IRONFOX_GET_SOURCE_PREBUILDS=1
  else
    # Otherwise,by default, we can just download the prebuilds directly
    IRONFOX_GET_SOURCE_UNIFFI=1
    IRONFOX_GET_SOURCE_WASI=1
  fi
else
  echo_red_text "ERROR: Invalid target: ${target}\n You must enter one of the following:"
  echo 'All:                              all (Default)'
  echo 'androguard:                       androguard'
  echo 'Android NDK:                      android-ndk'
  echo 'Android SDK:                      android-sdk'
  echo 'Android SDK Build Tools (latest): android-sdk-build-tools'
  echo 'Android SDK Build Tools (35.0.0): android-sdk-build-tools-35'
  echo 'Android SDK Platform (latest):    android-sdk-platform'
  echo 'Android SDK Platform (36):        android-sdk-platform-36'
  echo 'Android SDK Platform Tools:       android-sdk-platform-tools'
  echo 'Application Services:             as'
  echo 'Bundletool:                       bundletool'
  echo 'cbindgen:                         cbindgen'
  echo 'Firefox (Gecko/mozilla-central):  firefox'
  echo 'firefox-l10n (l10n-central):      firefox-l10n'
  echo 'Glean:                            glean'
  echo 'Glean Parser:                     glean-parser'
  echo 'Gradle:                           gradle'
  echo 'GYP:                              gyp'
  echo 'JDK (17):                         jdk-17'
  echo 'JDK (21):                         jdk-21'
  echo 'JDK (25):                         jdk-25'
  echo 'microG:                           microg'
  echo 'Node.js:                          node'
  echo 'npm:                              npm'
  echo 'Phoenix:                          phoenix'
  echo 'pip:                              pip'
  echo 'Prebuilds repo:                   prebuilds'
  echo 'Python:                           python'
  echo 'PyYAML:                           pyyaml'
  echo 'Rust:                             rust'
  echo 's3cmd:                            s3cmd'
  echo 'shellcheck:                       shellcheck'
  echo 'shfmt:                            shfmt'
  echo 'UnifiedPush-AC:                   up-ac'
  echo 'uniffi-bindgen:                   uniffi'
  echo 'uv:                               uv'
  echo 'WASI SDK:                         wasi'
  exit 1
fi

readonly IRONFOX_GET_SOURCE_ANDROGUARD
readonly IRONFOX_GET_SOURCE_ANDROID_NDK
readonly IRONFOX_GET_SOURCE_ANDROID_SDK
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS
readonly IRONFOX_GET_SOURCE_AS
readonly IRONFOX_GET_SOURCE_BUNDLETOOL
readonly IRONFOX_GET_SOURCE_CBINDGEN
readonly IRONFOX_GET_SOURCE_GECKO
readonly IRONFOX_GET_SOURCE_GECKO_L10N
readonly IRONFOX_GET_SOURCE_GLEAN
readonly IRONFOX_GET_SOURCE_GLEAN_PARSER
readonly IRONFOX_GET_SOURCE_GRADLE
readonly IRONFOX_GET_SOURCE_GYP
readonly IRONFOX_GET_SOURCE_JDK_17
readonly IRONFOX_GET_SOURCE_JDK_21
readonly IRONFOX_GET_SOURCE_JDK_25
readonly IRONFOX_GET_SOURCE_MICROG
readonly IRONFOX_GET_SOURCE_NODE
readonly IRONFOX_GET_SOURCE_NPM
readonly IRONFOX_GET_SOURCE_PHOENIX
readonly IRONFOX_GET_SOURCE_PIP
readonly IRONFOX_GET_SOURCE_PREBUILDS
readonly IRONFOX_GET_SOURCE_PYTHON
readonly IRONFOX_GET_SOURCE_PYYAML
readonly IRONFOX_GET_SOURCE_RUST
readonly IRONFOX_GET_SOURCE_S3CMD
readonly IRONFOX_GET_SOURCE_SHELLCHECK
readonly IRONFOX_GET_SOURCE_SHFMT
readonly IRONFOX_GET_SOURCE_UNIFFI
readonly IRONFOX_GET_SOURCE_UP_AC
readonly IRONFOX_GET_SOURCE_UV
readonly IRONFOX_GET_SOURCE_WASI

# If the 'checksum-update' argument is specified, in addition to downloading the dependencies as usual,
## we're also updating their checksums
IRONFOX_GET_SOURCE_CHECKSUM_UPDATE=0
if [[ "${mode}" == 'checksum-update' ]]; then
  if [[ "${IRONFOX_CI}" != 1 ]]; then
    IRONFOX_GET_SOURCE_CHECKSUM_UPDATE=1
  else
    echo_red_text 'ERROR: CI should never automatically update checksums.'
    exit 1
  fi
elif [[ "${mode}" != 'download' ]]; then
  echo_red_text "ERROR: Invalid mode: ${mode}\n You must enter one of the following:"
  echo 'Download:                     download (Default)'
  echo 'Download + update checksums:  checksum-update'
  exit 1
fi
readonly IRONFOX_GET_SOURCE_CHECKSUM_UPDATE

# Include version info
source "${IRONFOX_VERSIONS}" || exit 1

# Back-up (and remove) a file if it exists
function backup_file() {
  function print_usage() {
    echo "Usage: backup_file 'path/to/file'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the file path!'
    print_usage
    exit 1
  fi

  # Ensure we have basename
  verify_exec "${IRONFOX_BASENAME}" 'IRONFOX_BASENAME' || exit 1

  # Ensure we have cp
  verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || exit 1

  # Ensure we have dirname
  verify_exec "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local -r file="$1"
  local -r file_name="$("${IRONFOX_BASENAME}" "${file}")"
  local -r backup_file="${IRONFOX_EXTERNAL}/temp/backup/${file_name}"

  if [[ -f "${file}" ]]; then
    "${IRONFOX_RM}" -f "${backup_file}"
    "${IRONFOX_MKDIR}" -p "$("${IRONFOX_DIRNAME}" "${backup_file}")"
    "${IRONFOX_CP}" -f "${file}" "${backup_file}"
    "${IRONFOX_RM}" -f "${file}"
  fi
}

# Back-up (and remove) a directory if it exists
function backup_dir() {
  function print_usage() {
    echo "Usage: backup_dir 'path/to/directory'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the directory path!'
    print_usage
    exit 1
  fi

  # Ensure we have basename
  verify_exec "${IRONFOX_BASENAME}" 'IRONFOX_BASENAME' || exit 1

  # Ensure we have cp
  verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || exit 1

  # Ensure we have dirname
  verify_exec "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local -r dir="$1"
  local -r dir_name="$("${IRONFOX_BASENAME}" "${dir}")"
  local -r backup_dir="${IRONFOX_EXTERNAL}/temp/backup/${dir_name}"

  if [[ -d "${dir}" ]]; then
    "${IRONFOX_RM}" -rf "${backup_dir}"
    "${IRONFOX_MKDIR}" -p "$("${IRONFOX_DIRNAME}" "${backup_dir}")"
    "${IRONFOX_CP}" -rf "${dir}/" "${backup_dir}"
    "${IRONFOX_RM}" -rf "${dir}"
  fi
}

# Restore a backed-up file
function restore_file() {
  function print_usage() {
    echo "Usage: restore_file 'path/to/file'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the file path!'
    print_usage
    exit 1
  fi

  # Ensure we have basename
  verify_exec "${IRONFOX_BASENAME}" 'IRONFOX_BASENAME' || exit 1

  # Ensure we have cp
  verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || exit 1

  # Ensure we have dirname
  verify_exec "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local -r file="$1"
  local -r file_name="$("${IRONFOX_BASENAME}" "${file}")"
  local -r backed_up_file="${IRONFOX_EXTERNAL}/temp/backup/${file_name}"

  if [[ -f "${backed_up_file}" ]]; then
    "${IRONFOX_RM}" -f "${file}"
    "${IRONFOX_MKDIR}" -p "$("${IRONFOX_DIRNAME}" "${file}")"
    "${IRONFOX_CP}" -f "${backed_up_file}" "${file}"
    "${IRONFOX_RM}" -f "${backed_up_file}"
  fi
}

# Restore a backed-up directory
function restore_dir() {
  function print_usage() {
    echo "Usage: restore_dir 'path/to/directory'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the directory path!'
    print_usage
    exit 1
  fi

  # Ensure we have basename
  verify_exec "${IRONFOX_BASENAME}" 'IRONFOX_BASENAME' || exit 1

  # Ensure we have cp
  verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || exit 1

  # Ensure we have dirname
  verify_exec "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local -r dir="$1"
  local -r dir_name="$("${IRONFOX_BASENAME}" "${dir}")"
  local -r backed_up_dir="${IRONFOX_EXTERNAL}/temp/backup/${dir_name}"

  if [[ -d "${backed_up_dir}" ]]; then
    "${IRONFOX_RM}" -rf "${dir}"
    "${IRONFOX_MKDIR}" -p "$("${IRONFOX_DIRNAME}" "${dir}")"
    "${IRONFOX_CP}" -rf "${backed_up_dir}/" "${dir}"
    "${IRONFOX_RM}" -rf "${backed_up_dir}"
  fi
}

# Update the checksum of a file
function update_checksum() {
  function print_usage() {
    echo "Usage: update_checksum 'current_checksum' 'new_checksum' 'path/to/file' 'checksum_type'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text "ERROR: Please provide the file's current checksum!"
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text "ERROR: Please provide the file's new checksum!"
    print_usage
    exit 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text 'ERROR: Please provide the file path!'
    print_usage
    exit 1
  fi

  if [[ -z "${4+x}" ]]; then
    echo_red_text 'ERROR: Please provide the checksum type!'
    print_usage
    exit 1
  fi

  # Ensure we have GNU sed
  verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || exit 1

  # Ensure we can update `versions.sh`
  verify_file "${IRONFOX_VERSIONS}" || exit 1

  local -r old_checksum="$1"
  local -r new_checksum="$2"
  local -r file="$3"
  local -r checksum_type="$4"

  if [[ "${checksum_type}" == 'md5sum' ]]; then
    local -r checksum_type_pretty='MD5sum'
  elif [[ "${checksum_type}" == 'sha1sum' ]]; then
    local -r checksum_type_pretty='SHA1sum'
  elif [[ "${checksum_type}" == 'sha256sum' ]]; then
    local -r checksum_type_pretty='SHA256sum'
  elif [[ "${checksum_type}" == 'sha512sum' ]]; then
    local -r checksum_type_pretty='SHA512sum'
  else
    echo_red_text "ERROR: Unsupported checksum type: '${checksum_type}'!"
    exit 1
  fi

  if [[ "${old_checksum}" == "${new_checksum}" ]]; then
    echo_red_text "Checksums for file: '${file}' already match! Skipping..."
    echo "Old ${checksum_type_pretty}: '${old_checksum}'"
    echo "New ${checksum_type_pretty}: '${new_checksum}'"
  else
    echo_red_text "Updating ${checksum_type_pretty} for file: '${file}'..."
    "${IRONFOX_SED}" -i "s|'${old_checksum}'|'${new_checksum}'|g" "${IRONFOX_VERSIONS}"
    echo_green_text "SUCCESS: Updated ${checksum_type_pretty} for file: '${file}'!"
  fi
}

# Validate the checksum of a file
function validate_checksum() {
  function print_usage() {
    echo "Usage: validate_checksum 'expected_checksum' 'path/to/file' 'checksum_type'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text "ERROR: Please provide the file's expected checksum!"
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please provide the file path!'
    print_usage
    exit 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text 'ERROR: Please provide the checksum type!'
    print_usage
    exit 1
  fi

  # Ensure we have GNU awk
  verify_exec "${IRONFOX_AWK}" 'IRONFOX_AWK' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local -r expected_checksum="$1"
  local -r file="$2"
  local -r checksum_type="$3"

  if [[ "${checksum_type}" == 'md5sum' ]]; then
    # Ensure we have md5sum
    verify_exec "${IRONFOX_MD5SUM}" 'IRONFOX_MD5SUM' || exit 1
  else
    # Ensure we have shasum
    verify_exec "${IRONFOX_SHASUM}" 'IRONFOX_SHASUM' || exit 1
  fi

  if [[ "${checksum_type}" == 'md5sum' ]]; then
    local -r checksum_type_pretty='MD5sum'
    local -r local_checksum=$("${IRONFOX_MD5SUM}" "${file}" | "${IRONFOX_AWK}" '{print $1}')
  elif [[ "${checksum_type}" == 'sha1sum' ]]; then
    local -r checksum_type_pretty='SHA1sum'
    local -r local_checksum=$("${IRONFOX_SHASUM}" -a 1 "${file}" | "${IRONFOX_AWK}" '{print $1}')
  elif [[ "${checksum_type}" == 'sha256sum' ]]; then
    local -r checksum_type_pretty='SHA256sum'
    local -r local_checksum=$("${IRONFOX_SHASUM}" -a 256 "${file}" | "${IRONFOX_AWK}" '{print $1}')
  elif [[ "${checksum_type}" == 'sha512sum' ]]; then
    local -r checksum_type_pretty='SHA512sum'
    local -r local_checksum=$("${IRONFOX_SHASUM}" -a 512 "${file}" | "${IRONFOX_AWK}" '{print $1}')
  else
    echo_red_text "ERROR: Unsupported checksum type: '${checksum_type}'!"
    exit 1
  fi

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    update_checksum "${expected_checksum}" "${local_checksum}" "${file}" "${checksum_type}"
  elif [[ "${local_checksum}" != "${expected_checksum}" ]]; then
    echo_red_text "ERROR: Checksum (${checksum_type_pretty}) validation for file failed: '${file}'!"
    echo "Expected ${checksum_type_pretty}:   '${expected_checksum}'"
    echo "Actual ${checksum_type_pretty}:     '${local_checksum}'"

    # If checksum validation fails, also just remove the file
    "${IRONFOX_RM}" -f "${file}"

    exit 1
  else
    echo_green_text "SUCCESS: Validated checksum (${checksum_type_pretty}) for file: '${file}'!"
    echo "${checksum_type_pretty}: '${local_checksum}'"
  fi
}

# Download and verify the SHA512sum of a file
function download_file() {
  function print_usage() {
    echo "Usage: download_file 'https://totally.real.url/file' 'path/to/file' 'file_sha512sum'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the URL for the file to download!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please provide the output file path!'
    print_usage
    exit 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text "ERROR: Please provide the file's SHA512sum!"
    print_usage
    exit 1
  fi

  # Ensure we have basename
  verify_exec "${IRONFOX_BASENAME}" 'IRONFOX_BASENAME' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local -r url="$1"
  local -r file_in="$2"
  local -r file_name=$("${IRONFOX_BASENAME}" "${file_in}")
  local -r expected_sha512sum="$3"

  # By default, we want to exit upon an error
  if [[ -z "${IRONFOX_DOWNLOAD_EXIT+x}" ]]; then
    IRONFOX_DOWNLOAD_EXIT=1
  fi

  # By default, we want to perform post-download actions for sources
  ## (this includes things like ex. installing a dependency or creating/setting-up an environment)
  ## This isn't desired in some cases, like if we're updating checksums, or a user just cancels the download
  unset IRONFOX_PERFORM_POST_DOWNLOAD
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    ## If we're just updating a checksum, we should never perform post-download actions
    IRONFOX_PERFORM_POST_DOWNLOAD=0
  else
    IRONFOX_PERFORM_POST_DOWNLOAD=1
  fi

  # If we're doing a checksum update, we download the file to a separate temporary directory, instead of our standard one
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/chksm"
    local -r file="${IRONFOX_EXTERNAL}/temp/chksm/${file_name}"
  else
    local -r file="${file_in}"
  fi

  if [[ -f "${file}" ]]; then
    echo_red_text "File already exists: '${file}'!"
    read -p "Do you want to re-download? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our file
      echo_red_text "Removing file: '${file}'..."
      backup_file "${file}"
      echo_green_text "SUCCESS: Removed file: '${file}'!"
    else
      unset IRONFOX_DOWNLOAD_EXIT
      IRONFOX_PERFORM_POST_DOWNLOAD=0
      return 0
    fi
  fi

  # By default, we know nothing has failed...
  local IRONFOX_CHECKSUM_FAILED=0
  local IRONFOX_DOWNLOAD_FAILED=0

  # Download our file
  download "${url}" "${file}" || local IRONFOX_DOWNLOAD_FAILED=1

  # Verify (or update) SHA512sum
  validate_checksum "${expected_sha512sum}" "${file}" 'sha512sum' || local IRONFOX_CHECKSUM_FAILED=1

  # If we're just updating the checksum, we're done, so go ahead and exit
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      exit 1
    elif [[ "${IRONFOX_CHECKSUM_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Failed to update checksum! Exiting...'
      exit 1
    else
      return 0
    fi
  fi

  # If the download (or checksum validation) failed, restore our back-up
  if [[ "${IRONFOX_CHECKSUM_FAILED}" == 1 ]] || [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
    if [[ -f "${IRONFOX_EXTERNAL}/temp/backup/${file_name}" ]]; then
      restore_file "${file}"
    fi
  fi

  # Clean-up
  "${IRONFOX_RM}" -f "${IRONFOX_EXTERNAL}/temp/backup/${file_name}"
  "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/chksm"

  # If the download (or checksum validation) failed, exit
  if [[ "${IRONFOX_CHECKSUM_FAILED}" == 1 ]] || [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
    if [[ "${IRONFOX_DOWNLOAD_EXIT}" != 1 ]]; then
      unset IRONFOX_DOWNLOAD_EXIT
      return 1
    else
      echo_red_text 'ERROR: Download failed! Exiting...'
      exit 1
    fi
  fi
}

# Download and extract an archive
function download_and_extract() {
  function print_usage() {
    echo "Usage: download_and_extract 'https://totally.real.url/archive' 'path/to/extract/archive/to' 'archive_sha512sum'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the URL for the archive to download!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please provide the path that the archive should be extracted to!'
    print_usage
    exit 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text "ERROR: Please provide the archive's SHA512sum!"
    print_usage
    exit 1
  fi

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local -r url="$1"
  local -r path="$2"
  local -r expected_sha512sum="$3"

  # By default, we want to perform post-download actions for sources
  ## (this includes things like ex. installing a dependency or creating/setting-up an environment)
  ## This isn't desired in some cases, like if we're updating checksums, or a user just cancels the download
  unset IRONFOX_PERFORM_POST_DOWNLOAD
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    ## If we're just updating a checksum, we should never perform post-download actions
    IRONFOX_PERFORM_POST_DOWNLOAD=0
  else
    IRONFOX_PERFORM_POST_DOWNLOAD=1
  fi

  if [[ -d "${path}" ]] && [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    echo_red_text "Path already exists: '${path}'!"
    read -p "Do you want to re-download? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
      echo_red_text "Removing path: '${path}'..."
      backup_dir "${path}"
      echo_green_text "SUCCESS: Removed path: '${path}'!"
    else
      IRONFOX_PERFORM_POST_DOWNLOAD=0
      return 0
    fi
  fi

  if [[ "${url}" =~ \.tar\.xz$ ]]; then
    local -r extension=".tar.xz"
  elif [[ "${url}" =~ \.tar\.gz$ ]]; then
    local -r extension=".tar.gz"
  elif [[ "${url}" =~ \.tar\.zst$ ]]; then
    local -r extension=".tar.zst"
  else
    local -r extension=".zip"
  fi

  # Tell `download` to return instead of exit upon an error
  IRONFOX_DOWNLOAD_EXIT=0

  # By default, we know the download hasn't failed...
  local IRONFOX_DOWNLOAD_FAILED=0

  # Set a temporary archive name
  local -r temp_archive_path_name=$("${IRONFOX_BASENAME}" "${path}")
  local -r temp_archive_path="${IRONFOX_DOWNLOADS}/${temp_archive_path_name}${extension}"

  # Download the archive
  download_file "${url}" "${temp_archive_path}" "${expected_sha512sum}" || local IRONFOX_DOWNLOAD_FAILED=1

  # If we're just updating the checksum, we're done, so go ahead and exit
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text "ERROR: Download for archive failed: '${url}'!"
      exit 1
    else
      return 0
    fi
  fi

  # If the download failed, restore our back-up (if possible) and exit
  if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
    restore_dir "${path}"
    if [[ "${temp_archive_path_name}" == 'uv' ]]; then
      IRONFOX_PERFORM_POST_DOWNLOAD=0
      return 1
    else
      echo_red_text "ERROR: Download for archive failed: '${url}'!"
      exit 1
    fi
  fi

  # Extract the archive
  extract_archive "${temp_archive_path}" "${path}"

  # Clean-up
  "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/backup/${temp_archive_path_name}"
}

# Get androguard
function get_androguard() {
  # Ensure we have `IRONFOX_ANDROGUARD_COMMIT`
  if [[ -z "${IRONFOX_ANDROGUARD_COMMIT+x}" ]] || [[ "${IRONFOX_ANDROGUARD_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_ANDROGUARD_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_ANDROGUARD_SHA512SUM`
  if [[ -z "${IRONFOX_ANDROGUARD_SHA512SUM+x}" ]] || [[ "${IRONFOX_ANDROGUARD_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_ANDROGUARD_SHA512SUM' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have uv
    verify_exec "${IRONFOX_UV}" 'IRONFOX_UV' || {
      echo_red_text "ERROR: Unable to download and install s3cmd without uv!"
      exit 1
    }

    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download androguard, but you don't have a Python environment set-up yet."
      exit 1
    fi

    if [[ -d "${IRONFOX_ANDROGUARD}" ]]; then
      echo_red_text "androguard is already installed at path: '${IRONFOX_ANDROGUARD}'!"
      read -p "Do you want to re-download it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
        return 0
      else
        source "${IRONFOX_PYENV}"
        "${IRONFOX_UV}" pip uninstall androguard
      fi
    fi
  fi

  echo_red_text "Downloading androguard to path: '${IRONFOX_ANDROGUARD_DIR}'..."
  download_and_extract "https://github.com/androguard/androguard/archive/${IRONFOX_ANDROGUARD_COMMIT}.tar.gz" "${IRONFOX_ANDROGUARD_DIR}" "${IRONFOX_ANDROGUARD_SHA512SUM}"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text "Installing androguard to path: '${IRONFOX_ANDROGUARD}'..."
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_ANDROGUARD_DIR}"
    echo_green_text "SUCCESS: Set-up androguard at path: '${IRONFOX_ANDROGUARD}'!"
  fi
}

# Get Android NDK
function get_android_ndk() {
  # Ensure we have `IRONFOX_ANDROID_NDK_VERSION`
  if [[ -z "${IRONFOX_ANDROID_NDK_VERSION+x}" ]] || [[ "${IRONFOX_ANDROID_NDK_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_ANDROID_NDK_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://dl.google.com/android/repository"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android NDK (Linux)...'
    download_and_extract "${base_url}/android-ndk-${IRONFOX_ANDROID_NDK_VERSION}-linux.zip" "${IRONFOX_ANDROID_NDK}" "${IRONFOX_ANDROID_NDK_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android NDK (OS X)...'
    download_and_extract "${base_url}/android-ndk-${IRONFOX_ANDROID_NDK_VERSION}-darwin.zip" "${IRONFOX_ANDROID_NDK}" "${IRONFOX_ANDROID_NDK_SHA512SUM_OSX}"
  else
    echo_red_text "Downloading Android NDK to path: '${IRONFOX_ANDROID_NDK}'..."
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      download_and_extract "${base_url}/android-ndk-${IRONFOX_ANDROID_NDK_VERSION}-darwin.zip" "${IRONFOX_ANDROID_NDK}" "${IRONFOX_ANDROID_NDK_SHA512SUM_OSX}"
    else
      download_and_extract "${base_url}/android-ndk-${IRONFOX_ANDROID_NDK_VERSION}-linux.zip" "${IRONFOX_ANDROID_NDK}" "${IRONFOX_ANDROID_NDK_SHA512SUM_LINUX}"
    fi
    echo_green_text "SUCCESS: Set-up Android NDK at path: '${IRONFOX_ANDROID_NDK}'!"
  fi
}

# Get + set-up Android SDK
function get_android_sdk() {
  # Ensure we have `IRONFOX_ANDROID_SDK_REVISION`
  if [[ -z "${IRONFOX_ANDROID_SDK_REVISION+x}" ]] || [[ "${IRONFOX_ANDROID_SDK_REVISION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_ANDROID_SDK_REVISION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_ANDROID_SDK_VERSION`
  if [[ -z "${IRONFOX_ANDROID_SDK_VERSION+x}" ]] || [[ "${IRONFOX_ANDROID_SDK_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_ANDROID_SDK_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://dl.google.com/android/repository"

  # This is typically covered by "download_and_extract", but the Android SDK is a special case - we don't download it to IRONFOX_ANDROID_SDK directly
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have mkdir
    verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

    if [[ -d "${IRONFOX_ANDROID_SDK}" ]]; then
      echo_red_text "Found existing installation at path: '${IRONFOX_ANDROID_SDK}'!"
      echo 'Continuing will remove this installation and related data.'
      read -p "Do you still want to continue? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
        echo_red_text "Removing path: '${IRONFOX_ANDROID_SDK}'..."
        backup_dir "${IRONFOX_ANDROID_SDK}"
        echo_green_text "SUCCESS: Removed path: '${IRONFOX_ANDROID_SDK}'!"
      else
        return 0
      fi
    fi
    "${IRONFOX_MKDIR}" -p "${IRONFOX_ANDROID_SDK}/cmdline-tools"
  fi

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android SDK (Linux)...'
    download_file "${base_url}/commandlinetools-linux-${IRONFOX_ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/${IRONFOX_ANDROID_SDK_VERSION}" "${IRONFOX_ANDROID_SDK_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android SDK (OS X)...'
    download_file "${base_url}/commandlinetools-mac-${IRONFOX_ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/${IRONFOX_ANDROID_SDK_VERSION}" "${IRONFOX_ANDROID_SDK_SHA512SUM_OSX}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_ANDROID_SDK_PLATFORM='mac'
    else
      local -r IRONFOX_ANDROID_SDK_PLATFORM='linux'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_ANDROID_SDK_SHA512SUM="${IRONFOX_ANDROID_SDK_SHA512SUM_OSX}"
    else
      local -r IRONFOX_ANDROID_SDK_SHA512SUM="${IRONFOX_ANDROID_SDK_SHA512SUM_LINUX}"
    fi

    echo_red_text "Downloading Android SDK to path: '${IRONFOX_ANDROID_SDK}'..."
    download_and_extract "${base_url}/commandlinetools-${IRONFOX_ANDROID_SDK_PLATFORM}-${IRONFOX_ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/${IRONFOX_ANDROID_SDK_VERSION}" "${IRONFOX_ANDROID_SDK_SHA512SUM}"

    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      # Accept Android SDK licenses
      { "${IRONFOX_YES}" || true; } | "${IRONFOX_ANDROID_SDK}/cmdline-tools/${IRONFOX_ANDROID_SDK_VERSION}/bin/sdkmanager" --sdk_root="${IRONFOX_ANDROID_SDK}" --licenses

      echo_green_text "SUCCESS: Set-up Android SDK at path: '${IRONFOX_ANDROID_SDK}'!"
    fi
  fi
}

# Get Android SDK Build Tools (latest)
function get_android_sdk_build_tools() {
  # Ensure we have `IRONFOX_ANDROID_SDK_BUILD_TOOLS_VERSION`
  if [[ -z "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_VERSION+x}" ]] || [[ "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_ANDROID_SDK_BUILD_TOOLS_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://dl.google.com/android/repository"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android SDK Build Tools (latest) (Linux)...'
    download_file "${base_url}/build-tools_${IRONFOX_ANDROID_SDK_BUILD_TOOLS_VERSION}_linux.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android SDK Build Tools (latest) (OS X)...'
    download_file "${base_url}/build-tools_${IRONFOX_ANDROID_SDK_BUILD_TOOLS_VERSION}_macosx.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_ANDROID_SDK_BUILD_TOOLS_PLATFORM='macosx'
    else
      local -r IRONFOX_ANDROID_SDK_BUILD_TOOLS_PLATFORM='linux'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_ANDROID_SDK_BUILD_TOOLS_SHA512SUM="${IRONFOX_ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX}"
    else
      local -r IRONFOX_ANDROID_SDK_BUILD_TOOLS_SHA512SUM="${IRONFOX_ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX}"
    fi

    echo_red_text "Downloading Android SDK Build Tools (latest) to path: '${IRONFOX_ANDROID_SDK_BUILD_TOOLS}'..."
    download_and_extract "${base_url}/build-tools_${IRONFOX_ANDROID_SDK_BUILD_TOOLS_VERSION}_${IRONFOX_ANDROID_SDK_BUILD_TOOLS_PLATFORM}.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up Android SDK Build Tools (latest) at path: '${IRONFOX_ANDROID_SDK_BUILD_TOOLS}'!"
    fi
  fi
}

# Get Android SDK Build Tools (35)
## (Needed by Glean:
### https://github.com/mozilla/glean/blob/main/docs/dev/android/sdk-ndk-versions.md
### https://github.com/mozilla/glean/blob/main/docs/dev/android/setup-android-build-environment.md)
function get_android_sdk_build_tools_35() {
  # Base download URL
  local -r base_url="https://dl.google.com/android/repository"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android SDK Build Tools (35.0.0) (Linux)...'
    download_file "${base_url}/build-tools_r35_linux.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android SDK Build Tools (35.0.0) (OS X)...'
    download_file "${base_url}/build-tools_r35_macosx.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_PLATFORM='macosx'
    else
      local -r IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_PLATFORM='linux'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM="${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX}"
    else
      local -r IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM="${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX}"
    fi

    echo_red_text "Downloading Android SDK Build Tools (35.0.0) to path: '${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}'..."
    download_and_extract "${base_url}/build-tools_r35_${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_PLATFORM}.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up Android SDK Build Tools (35.0.0) at path: '${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}'!"
    fi
  fi
}

# Get Android SDK Platform (latest)
function get_android_sdk_platform() {
  # Ensure we have `IRONFOX_ANDROID_SDK_PLATFORM_VERSION`
  if [[ -z "${IRONFOX_ANDROID_SDK_PLATFORM_VERSION+x}" ]] || [[ "${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_ANDROID_SDK_PLATFORM_VERSION' is missing!"
    exit 1
  fi

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text "ERROR: Unsupported project."
    exit 1
  else
    # Ensure we have rm
    verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

    if [[ ! -d "${IRONFOX_ANDROID_SDK}" ]]; then
      echo_red_text "ERROR: You tried to download the Android SDK Platform (latest), but you don't have the Android SDK set-up yet!"
      exit 1
    fi

    if [[ -d "${IRONFOX_ANDROID_SDK}/platforms/android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}" ]]; then
      echo_red_text "Found existing installation at path: '${IRONFOX_ANDROID_SDK}/platforms/android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}'!"
      echo 'Continuing will remove this installation and related data'
      read -p "Do you still want to continue? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
        echo_red_text "Removing path: '${IRONFOX_ANDROID_SDK}/platforms/android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}'..."
        backup_dir "${IRONFOX_ANDROID_SDK}/platforms/android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}"
        echo_green_text "SUCCESS: Removed path: '${IRONFOX_ANDROID_SDK}/platforms/android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}'!"
      else
        return 0
      fi
    fi

    # By default, we know the download hasn't failed...
    local IRONFOX_DOWNLOAD_FAILED=0

    echo_red_text "Downloading Android SDK Platform (latest) to path: '${IRONFOX_ANDROID_SDK}/platforms/android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}'..."
    "${IRONFOX_ANDROID_SDK}/cmdline-tools/${IRONFOX_ANDROID_SDK_VERSION}/bin/sdkmanager" "platforms;android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}" || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-up, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      restore_dir "${IRONFOX_ANDROID_SDK}/platforms/android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    else
      echo_green_text "SUCCESS: Set-up Android SDK Platform (latest) at path: '${IRONFOX_ANDROID_SDK}/platforms/android-${IRONFOX_ANDROID_SDK_PLATFORM_VERSION}'!"
    fi
  fi
}

# Get Android SDK Platform (36)
## (Needed by microG and Glean:
### https://github.com/mozilla/glean/blob/main/docs/dev/android/sdk-ndk-versions.md
### https://github.com/mozilla/glean/blob/main/docs/dev/android/setup-android-build-environment.md)
function get_android_sdk_platform_36() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text "ERROR: Unsupported project."
    exit 1
  else
    # Ensure we have rm
    verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

    if [[ ! -d "${IRONFOX_ANDROID_SDK}" ]]; then
      echo_red_text "ERROR: You tried to download the Android SDK Platform (36), but you don't have the Android SDK set-up yet!"
      exit 1
    fi

    if [[ -d "${IRONFOX_ANDROID_SDK}/platforms/android-36" ]]; then
      echo_red_text "Found existing installation at path: '${IRONFOX_ANDROID_SDK}/platforms/android-36'!"
      echo 'Continuing will remove this installation and related data'
      read -p "Do you still want to continue? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
        echo_red_text "Removing path: '${IRONFOX_ANDROID_SDK}/platforms/android-36'..."
        backup_dir "${IRONFOX_ANDROID_SDK}/platforms/android-36"
        echo_green_text "SUCCESS: Removed path: '${IRONFOX_ANDROID_SDK}/platforms/android-36'!"
      else
        return 0
      fi
    fi

    # By default, we know the download hasn't failed...
    local IRONFOX_DOWNLOAD_FAILED=0

    echo_red_text "Downloading Android SDK Platform (36) to path: '${IRONFOX_ANDROID_SDK}/platforms/android-36'..."
    "${IRONFOX_ANDROID_SDK}/cmdline-tools/${IRONFOX_ANDROID_SDK_VERSION}/bin/sdkmanager" 'platforms;android-36' || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-up, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      restore_dir "${IRONFOX_ANDROID_SDK}/platforms/android-36"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    else
      echo_green_text "SUCCESS: Set-up Android SDK Platform (36) at path: '${IRONFOX_ANDROID_SDK}/platforms/android-36'!"
    fi
  fi
}

# Get Android SDK Platform Tools
function get_android_sdk_platform_tools() {
  # Ensure we have `IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_VERSION`
  if [[ -z "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_VERSION+x}" ]] || [[ "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://dl.google.com/android/repository"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android SDK Platform Tools (Linux)...'
    download_file "${base_url}/platform-tools_r${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_VERSION}-linux.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android SDK Platform Tools (OS X)...'
    download_file "${base_url}/platform-tools_r${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_VERSION}-darwin.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_PLATFORM='darwin'
    else
      local -r IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_PLATFORM='linux'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM="${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX}"
    else
      local -r IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM="${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX}"
    fi

    echo_red_text "Downloading Android SDK Platform Tools to path: '${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}'..."
    download_and_extract "${base_url}/platform-tools_r${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_VERSION}-${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_PLATFORM}.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up Android SDK Platform Tools at path: '${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}'!"
    fi
  fi
}

# Get Application Services
function get_as() {
  # Ensure we have `IRONFOX_AS_COMMIT`
  if [[ -z "${IRONFOX_AS_COMMIT+x}" ]] || [[ "${IRONFOX_AS_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_AS_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_AS_SHA512SUM`
  if [[ -z "${IRONFOX_AS_SHA512SUM+x}" ]] || [[ "${IRONFOX_AS_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_AS_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading Application Services to path: '${IRONFOX_AS}'..."
  download_and_extract "https://github.com/mozilla/application-services/archive/${IRONFOX_AS_COMMIT}.tar.gz" "${IRONFOX_AS}" "${IRONFOX_AS_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Application Services at path: '${IRONFOX_AS}'!"
  fi
}

# Get + set-up Bundletool
function get_bundletool() {
  # Ensure we have `IRONFOX_BUNDLETOOL_VERSION`
  if [[ -z "${IRONFOX_BUNDLETOOL_VERSION+x}" ]] || [[ "${IRONFOX_BUNDLETOOL_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_BUNDLETOOL_VERSION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_BUNDLETOOL_SHA512SUM`
  if [[ -z "${IRONFOX_BUNDLETOOL_SHA512SUM+x}" ]] || [[ "${IRONFOX_BUNDLETOOL_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_BUNDLETOOL_SHA512SUM' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_BUNDLETOOL_REPO_COMMIT`
  if [[ -z "${IRONFOX_BUNDLETOOL_REPO_COMMIT+x}" ]] || [[ "${IRONFOX_BUNDLETOOL_REPO_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_BUNDLETOOL_REPO_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_BUNDLETOOL_REPO_SHA512SUM`
  if [[ -z "${IRONFOX_BUNDLETOOL_REPO_SHA512SUM+x}" ]] || [[ "${IRONFOX_BUNDLETOOL_REPO_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_BUNDLETOOL_REPO_SHA512SUM' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://github.com/google/bundletool"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Bundletool (Source archive)...'
    download_and_extract "${base_url}/archive/${IRONFOX_BUNDLETOOL_REPO_COMMIT}.tar.gz" "${IRONFOX_BUNDLETOOL_DIR}" "${IRONFOX_BUNDLETOOL_REPO_SHA512SUM}"

    echo_red_text 'Downloading Bundletool (Prebuilt)...'
    download_file "${base_url}/releases/download/${IRONFOX_BUNDLETOOL_VERSION}/bundletool-all-${IRONFOX_BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}" "${IRONFOX_BUNDLETOOL_SHA512SUM}"
  else
    echo_red_text "Downloading Bundletool to path: '${IRONFOX_BUNDLETOOL_DIR}'..."
    if [[ "${IRONFOX_NO_PREBUILDS}" == "1" ]]; then
      download_and_extract "${base_url}/archive/${IRONFOX_BUNDLETOOL_REPO_COMMIT}.tar.gz" "${IRONFOX_BUNDLETOOL_DIR}" "${IRONFOX_BUNDLETOOL_REPO_SHA512SUM}"
    else
      download_file "${base_url}/releases/download/${IRONFOX_BUNDLETOOL_VERSION}/bundletool-all-${IRONFOX_BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}" "${IRONFOX_BUNDLETOOL_SHA512SUM}"
    fi

    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up Bundletool at path: '${IRONFOX_BUNDLETOOL_DIR}'!"
    fi
  fi
}

# Get cbindgen
function get_cbindgen() {
  # Ensure we have `IRONFOX_CBINDGEN_COMMIT`
  if [[ -z "${IRONFOX_CBINDGEN_COMMIT+x}" ]] || [[ "${IRONFOX_CBINDGEN_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_CBINDGEN_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_CBINDGEN_SHA512SUM`
  if [[ -z "${IRONFOX_CBINDGEN_SHA512SUM+x}" ]] || [[ "${IRONFOX_CBINDGEN_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_CBINDGEN_SHA512SUM' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_CBINDGEN_VERSION`
  if [[ -z "${IRONFOX_CBINDGEN_VERSION+x}" ]] || [[ "${IRONFOX_CBINDGEN_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_CBINDGEN_VERSION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_RUST_VERSION`
  if [[ -z "${IRONFOX_RUST_VERSION+x}" ]] || [[ "${IRONFOX_RUST_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_RUST_VERSION' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have cargo
    verify_exec "${IRONFOX_CARGO}" 'IRONFOX_CARGO' || {
      echo_red_text "ERROR: Unable to download and install cbindgen without cargo!"
      exit 1
    }

    if [[ ! -d "${IRONFOX_CARGO_HOME}" ]] || [[ ! -f "${IRONFOX_CARGO_ENV}" ]]; then
      echo_red_text "ERROR: You tried to download cbindgen, but you don't have a Rust environment set-up yet!"
      exit 1
    fi

    if [[ -d "${IRONFOX_CARGO_HOME}/bin/cbindgen" ]]; then
      echo_red_text "cbindgen is already installed at path: '${IRONFOX_CARGO_HOME}/bin/cbindgen'!"
      read -p "Do you want to re-download it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
        return 0
      fi
    fi
  fi

  echo_red_text "Downloading cbindgen to path: '${IRONFOX_CBINDGEN_DIR}'..."
  download_and_extract "https://github.com/mozilla/cbindgen/archive/${IRONFOX_CBINDGEN_COMMIT}.tar.gz" "${IRONFOX_CBINDGEN_DIR}" "${IRONFOX_CBINDGEN_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_CARGO_ENV}"
    echo_red_text 'Installing cbindgen...'
    "${IRONFOX_CARGO}" +"${IRONFOX_RUST_VERSION}" install --locked --force --vers "${IRONFOX_CBINDGEN_VERSION}" --path "${IRONFOX_CBINDGEN_DIR}" cbindgen
    echo_green_text "SUCCESS: Set-up cbindgen at path: '${IRONFOX_CARGO_HOME}/bin/cbindgen'!"
  fi
}

# Get Firefox (Gecko/mozilla-central)
function get_firefox() {
  # Ensure we have `IRONFOX_GECKO_COMMIT`
  if [[ -z "${IRONFOX_GECKO_COMMIT+x}" ]] || [[ "${IRONFOX_GECKO_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GECKO_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_GECKO_SHA512SUM`
  if [[ -z "${IRONFOX_GECKO_SHA512SUM+x}" ]] || [[ "${IRONFOX_GECKO_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GECKO_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading Firefox to path: '${IRONFOX_GECKO}'..."
  download_and_extract "https://github.com/mozilla-firefox/firefox/archive/${IRONFOX_GECKO_COMMIT}.tar.gz" "${IRONFOX_GECKO}" "${IRONFOX_GECKO_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Firefox at path: '${IRONFOX_GECKO}'!"
  fi
}

# Get firefox-l10n
function get_firefox_l10n() {
  # Ensure we have `IRONFOX_L10N_CENTRAL_COMMIT`
  if [[ -z "${IRONFOX_L10N_CENTRAL_COMMIT+x}" ]] || [[ "${IRONFOX_L10N_CENTRAL_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_L10N_CENTRAL_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_L10N_CENTRAL_SHA512SUM`
  if [[ -z "${IRONFOX_L10N_CENTRAL_SHA512SUM+x}" ]] || [[ "${IRONFOX_L10N_CENTRAL_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_L10N_CENTRAL_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading firefox-l10n to path: '${IRONFOX_L10N_CENTRAL}'..."
  download_and_extract "https://github.com/mozilla-l10n/firefox-l10n/archive/${IRONFOX_L10N_CENTRAL_COMMIT}.tar.gz" "${IRONFOX_L10N_CENTRAL}" "${IRONFOX_L10N_CENTRAL_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up firefox-l10n at path: '${IRONFOX_L10N_CENTRAL}'!"
  fi
}

# Get Glean
function get_glean() {
  # Ensure we have `IRONFOX_GLEAN_COMMIT`
  if [[ -z "${IRONFOX_GLEAN_COMMIT+x}" ]] || [[ "${IRONFOX_GLEAN_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GLEAN_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_GLEAN_SHA512SUM`
  if [[ -z "${IRONFOX_GLEAN_SHA512SUM+x}" ]] || [[ "${IRONFOX_GLEAN_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GLEAN_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading Glean to path: '${IRONFOX_GLEAN}'..."
  download_and_extract "https://github.com/mozilla/glean/archive/${IRONFOX_GLEAN_COMMIT}.tar.gz" "${IRONFOX_GLEAN}" "${IRONFOX_GLEAN_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Glean at path: '${IRONFOX_GLEAN}'!"
  fi
}

# Get Glean Parser
function get_glean_parser() {
  # Ensure we have `IRONFOX_GLEAN_PARSER_VERSIONT`
  if [[ -z "${IRONFOX_GLEAN_PARSER_VERSION+x}" ]] || [[ "${IRONFOX_GLEAN_PARSER_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GLEAN_PARSER_VERSION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_GLEAN_PARSER_SHA512SUM`
  if [[ -z "${IRONFOX_GLEAN_PARSER_SHA512SUM+x}" ]] || [[ "${IRONFOX_GLEAN_PARSER_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GLEAN_PARSER_SHA512SUM' is missing!"
    exit 1
  fi

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  # Ensure we have uv
  verify_exec "${IRONFOX_UV}" 'IRONFOX_UV' || {
    echo_red_text "ERROR: Unable to download Glean parser without uv!"
    exit 1
  }

  if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
    echo_red_text "ERROR: You tried to download Glean Parser, but you don't have a Python environment set-up yet!"
    exit 1
  fi

  # Ensure we have pip
  verify_exec "${IRONFOX_PIP}" 'IRONFOX_PIP' || {
    echo_red_text "ERROR: Unable to download Glean parser without pip!"
    exit 1
  }

  if [[ ! -d "${IRONFOX_PIP_DIR}" ]]; then
    echo_red_text "ERROR: You tried to download Glean Parser, but you don't have pip set-up yet!"
    exit 1
  fi

  # Set our Glean Parser wheels directory
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    local -r glean_parser_wheels="${IRONFOX_EXTERNAL}/temp/chksm/glean_parser-wheels"
  else
    local -r glean_parser_wheels="${IRONFOX_GLEAN_PARSER_WHEELS}"
  fi

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]] && [[ -d "${IRONFOX_PYENV_DIR}/bin/glean_parser" ]]; then
    echo_red_text "Glean Parser is already installed at path: '${IRONFOX_PYENV_DIR}/bin/glean_parser'!"
    read -p "Do you want to re-download it? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
      return 0
    else
      source "${IRONFOX_PYENV}"
      "${IRONFOX_UV}" pip uninstall glean-parser

      # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
      backup_dir "${glean_parser_wheels}"
    fi
  fi

  "${IRONFOX_MKDIR}" -p "${glean_parser_wheels}"
  source "${IRONFOX_PYENV}"
  echo_red_text 'Downloading Glean Parser wheels...'
  pushd "${IRONFOX_GLEAN_PARSER_WHEELS}"
  "${IRONFOX_PIP}" download glean-parser=="${IRONFOX_GLEAN_PARSER_VERSION}"
  popd

  # Validate SHA512sum
  validate_checksum "${IRONFOX_GLEAN_PARSER_SHA512SUM}" "${IRONFOX_GLEAN_PARSER_WHEELS}/glean_parser-${IRONFOX_GLEAN_PARSER_VERSION}-py3-none-any.whl" 'sha512sum'

  # Clean-up
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/chksm"
  fi
}

# Get + set-up F-Droid's Gradle script
function get_gradle() {
  # Ensure we have `IRONFOX_GRADLE_COMMIT`
  if [[ -z "${IRONFOX_GRADLE_COMMIT+x}" ]] || [[ "${IRONFOX_GRADLE_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GRADLE_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_GRADLE_SHA512SUM`
  if [[ -z "${IRONFOX_GRADLE_SHA512SUM+x}" ]] || [[ "${IRONFOX_GRADLE_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GRADLE_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading F-Droid's Gradle script to path: '${IRONFOX_GRADLE_PY}'..."
  download_file "https://gitlab.com/fdroid/gradlew-fdroid/-/raw/${IRONFOX_GRADLE_COMMIT}/gradlew.py" "${IRONFOX_GRADLE_PY}" "${IRONFOX_GRADLE_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Gradle at path: '${IRONFOX_GRADLE_PY}'!"
  fi
}

# Get GYP
function get_gyp() {
  # Ensure we have `IRONFOX_GYP_COMMIT`
  if [[ -z "${IRONFOX_GYP_COMMIT+x}" ]] || [[ "${IRONFOX_GYP_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GYP_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_GYP_SHA512SUM`
  if [[ -z "${IRONFOX_GYP_SHA512SUM+x}" ]] || [[ "${IRONFOX_GYP_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GYP_SHA512SUM' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have uv
    verify_exec "${IRONFOX_UV}" 'IRONFOX_UV' || {
      echo_red_text "ERROR: Unable to download and install GYP without uv!"
      exit 1
    }

    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download GYP, but you don't have a Python environment set-up yet!"
      exit 1
    fi

    if [[ -d "${IRONFOX_PYENV_DIR}/bin/gyp" ]]; then
      echo_red_text "GYP is already installed at path: '${IRONFOX_PYENV_DIR}/bin/gyp'!"
      read -p "Do you want to re-download it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
        return 0
      else
        source "${IRONFOX_PYENV}"
        "${IRONFOX_UV}" pip uninstall gyp-next
      fi
    fi
  fi

  echo_red_text "Downloading GYP to path: '${IRONFOX_GYP}'..."
  download_and_extract "https://github.com/nodejs/gyp-next/archive/${IRONFOX_GYP_COMMIT}.tar.gz" "${IRONFOX_GYP}" "${IRONFOX_GYP_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text "Installing GYP to path: '${IRONFOX_PYENV_DIR}/bin/gyp'..."
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_GYP}"
    echo_green_text "SUCCESS: Set-up GYP at path: '${IRONFOX_PYENV_DIR}/bin/gyp'!"
  fi
}

# Get JDK (17)
## (Required by GeckoView)
function get_jdk_17() {
  # Ensure we have `IRONFOX_JDK_17_REVISION`
  if [[ -z "${IRONFOX_JDK_17_REVISION+x}" ]] || [[ "${IRONFOX_JDK_17_REVISION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_JDK_17_REVISION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_JDK_17_VERSION`
  if [[ -z "${IRONFOX_JDK_17_VERSION+x}" ]] || [[ "${IRONFOX_JDK_17_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_JDK_17_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://github.com/adoptium/temurin17-binaries/releases/download"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading JDK (17) (Linux - ARM64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_17_VERSION}%2B${IRONFOX_JDK_17_REVISION}/OpenJDK17U-jdk_aarch64_linux_hotspot_${IRONFOX_JDK_17_VERSION}_${IRONFOX_JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${IRONFOX_JDK_17_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading JDK (17) (Linux - x86_64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_17_VERSION}%2B${IRONFOX_JDK_17_REVISION}/OpenJDK17U-jdk_x64_linux_hotspot_${IRONFOX_JDK_17_VERSION}_${IRONFOX_JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${IRONFOX_JDK_17_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading JDK (17) (OS X - ARM64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_17_VERSION}%2B${IRONFOX_JDK_17_REVISION}/OpenJDK17U-jdk_aarch64_mac_hotspot_${IRONFOX_JDK_17_VERSION}_${IRONFOX_JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${IRONFOX_JDK_17_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading JDK (17) (OS X - x86_64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_17_VERSION}%2B${IRONFOX_JDK_17_REVISION}/OpenJDK17U-jdk_x64_mac_hotspot_${IRONFOX_JDK_17_VERSION}_${IRONFOX_JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${IRONFOX_JDK_17_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_JDK_17_PLATFORM='mac'
    else
      local -r IRONFOX_JDK_17_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local -r IRONFOX_JDK_17_ARCH='aarch64'
    else
      local -r IRONFOX_JDK_17_ARCH='x64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_JDK_17_SHA512SUM="${IRONFOX_JDK_17_SHA512SUM_OSX_ARM64}"
      else
        local -r IRONFOX_JDK_17_SHA512SUM="${IRONFOX_JDK_17_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_JDK_17_SHA512SUM="${IRONFOX_JDK_17_SHA512SUM_OSX_X86_64}"
      else
        local -r IRONFOX_JDK_17_SHA512SUM="${IRONFOX_JDK_17_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    echo_red_text "Downloading JDK (17) to path: '${IRONFOX_JDK_17}'..."
    download_and_extract "${base_url}/jdk-${IRONFOX_JDK_17_VERSION}%2B${IRONFOX_JDK_17_REVISION}/OpenJDK17U-jdk_${IRONFOX_JDK_17_ARCH}_${IRONFOX_JDK_17_PLATFORM}_hotspot_${IRONFOX_JDK_17_VERSION}_${IRONFOX_JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${IRONFOX_JDK_17_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up JDK (17) at path: '${IRONFOX_JDK_17}'!"
    fi
  fi
}

# Get JDK (21)
function get_jdk_21() {
  # Ensure we have `IRONFOX_JDK_21_REVISION`
  if [[ -z "${IRONFOX_JDK_21_REVISION+x}" ]] || [[ "${IRONFOX_JDK_21_REVISION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_JDK_21_REVISION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_JDK_21_VERSION`
  if [[ -z "${IRONFOX_JDK_21_VERSION+x}" ]] || [[ "${IRONFOX_JDK_21_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_JDK_21_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://github.com/adoptium/temurin21-binaries/releases/download"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading JDK (21) (Linux - ARM64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_21_VERSION}%2B${IRONFOX_JDK_21_REVISION}/OpenJDK21U-jdk_aarch64_linux_hotspot_${IRONFOX_JDK_21_VERSION}_${IRONFOX_JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${IRONFOX_JDK_21_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading JDK (21) (Linux - x86_64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_21_VERSION}%2B${IRONFOX_JDK_21_REVISION}/OpenJDK21U-jdk_x64_linux_hotspot_${IRONFOX_JDK_21_VERSION}_${IRONFOX_JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${IRONFOX_JDK_21_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading JDK (21) (OS X - ARM64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_21_VERSION}%2B${IRONFOX_JDK_21_REVISION}/OpenJDK21U-jdk_aarch64_mac_hotspot_${IRONFOX_JDK_21_VERSION}_${IRONFOX_JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${IRONFOX_JDK_21_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading JDK (21) (OS X - x86_64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_21_VERSION}%2B${IRONFOX_JDK_21_REVISION}/OpenJDK21U-jdk_x64_mac_hotspot_${IRONFOX_JDK_21_VERSION}_${IRONFOX_JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${IRONFOX_JDK_21_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_JDK_21_PLATFORM='mac'
    else
      local -r IRONFOX_JDK_21_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local -r IRONFOX_JDK_21_ARCH='aarch64'
    else
      local -r IRONFOX_JDK_21_ARCH='x64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_JDK_21_SHA512SUM="${IRONFOX_JDK_21_SHA512SUM_OSX_ARM64}"
      else
        local -r IRONFOX_JDK_21_SHA512SUM="${IRONFOX_JDK_21_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_JDK_21_SHA512SUM="${IRONFOX_JDK_21_SHA512SUM_OSX_X86_64}"
      else
        local -r IRONFOX_JDK_21_SHA512SUM="${IRONFOX_JDK_21_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    echo_red_text "Downloading JDK (21) to path: '${IRONFOX_JDK_21}'..."
    download_and_extract "${base_url}/jdk-${IRONFOX_JDK_21_VERSION}%2B${IRONFOX_JDK_21_REVISION}/OpenJDK21U-jdk_${IRONFOX_JDK_21_ARCH}_${IRONFOX_JDK_21_PLATFORM}_hotspot_${IRONFOX_JDK_21_VERSION}_${IRONFOX_JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${IRONFOX_JDK_21_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up JDK (21) at path: '${IRONFOX_JDK_21}'!"
    fi
  fi
}

# Get JDK (25)
function get_jdk_25() {
  # Ensure we have `IRONFOX_JDK_25_REVISION`
  if [[ -z "${IRONFOX_JDK_25_REVISION+x}" ]] || [[ "${IRONFOX_JDK_25_REVISION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_JDK_25_REVISION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_JDK_25_VERSION`
  if [[ -z "${IRONFOX_JDK_25_VERSION+x}" ]] || [[ "${IRONFOX_JDK_25_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_JDK_25_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://github.com/adoptium/temurin25-binaries/releases/download"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading JDK (25) (Linux - ARM64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_25_VERSION}%2B${IRONFOX_JDK_25_REVISION}/OpenJDK25U-jdk_aarch64_linux_hotspot_${IRONFOX_JDK_25_VERSION}_${IRONFOX_JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${IRONFOX_JDK_25_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading JDK (25) (Linux - x86_64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_25_VERSION}%2B${IRONFOX_JDK_25_REVISION}/OpenJDK25U-jdk_x64_linux_hotspot_${IRONFOX_JDK_25_VERSION}_${IRONFOX_JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${IRONFOX_JDK_25_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading JDK (25) (OS X - ARM64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_25_VERSION}%2B${IRONFOX_JDK_25_REVISION}/OpenJDK25U-jdk_aarch64_mac_hotspot_${IRONFOX_JDK_25_VERSION}_${IRONFOX_JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${IRONFOX_JDK_25_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading JDK (25) (OS X - x86_64)...'
    download_file "${base_url}/jdk-${IRONFOX_JDK_25_VERSION}%2B${IRONFOX_JDK_25_REVISION}/OpenJDK25U-jdk_x64_mac_hotspot_${IRONFOX_JDK_25_VERSION}_${IRONFOX_JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${IRONFOX_JDK_25_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_JDK_25_PLATFORM='mac'
    else
      local -r IRONFOX_JDK_25_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local -r IRONFOX_JDK_25_ARCH='aarch64'
    else
      local -r IRONFOX_JDK_25_ARCH='x64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_JDK_25_SHA512SUM="${IRONFOX_JDK_25_SHA512SUM_OSX_ARM64}"
      else
        local -r IRONFOX_JDK_25_SHA512SUM="${IRONFOX_JDK_25_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_JDK_25_SHA512SUM="${IRONFOX_JDK_25_SHA512SUM_OSX_X86_64}"
      else
        local -r IRONFOX_JDK_25_SHA512SUM="${IRONFOX_JDK_25_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    echo_red_text "Downloading JDK (25) to path: '${IRONFOX_JDK_25}'..."
    download_and_extract "${base_url}/jdk-${IRONFOX_JDK_25_VERSION}%2B${IRONFOX_JDK_25_REVISION}/OpenJDK25U-jdk_${IRONFOX_JDK_25_ARCH}_${IRONFOX_JDK_25_PLATFORM}_hotspot_${IRONFOX_JDK_25_VERSION}_${IRONFOX_JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${IRONFOX_JDK_25_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up JDK (25) at path: '${IRONFOX_JDK_25}'!"
    fi
  fi
}

# Get microG
function get_microg() {
  # Ensure we have `IRONFOX_GMSCORE_COMMIT`
  if [[ -z "${IRONFOX_GMSCORE_COMMIT+x}" ]] || [[ "${IRONFOX_GMSCORE_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GMSCORE_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_GMSCORE_SHA512SUM`
  if [[ -z "${IRONFOX_GMSCORE_SHA512SUM+x}" ]] || [[ "${IRONFOX_GMSCORE_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_GMSCORE_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading microG to path: '${IRONFOX_GMSCORE}'..."
  download_and_extract "https://github.com/microg/GmsCore/archive/${IRONFOX_GMSCORE_COMMIT}.tar.gz" "${IRONFOX_GMSCORE}" "${IRONFOX_GMSCORE_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up microG at path: '${IRONFOX_GMSCORE}'!"
  fi
}

# Get + set-up Node.js
function get_node() {
  # Ensure we have `IRONFOX_NVM_COMMIT`
  if [[ -z "${IRONFOX_NVM_COMMIT+x}" ]] || [[ "${IRONFOX_NVM_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_NVM_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_NVM_SHA512SUM`
  if [[ -z "${IRONFOX_NVM_SHA512SUM+x}" ]] || [[ "${IRONFOX_NVM_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_NVM_SHA512SUM' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have rm
    verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

    if [[ -d "${IRONFOX_NVM}" ]]; then
      echo_red_text "The Node.js environment is already set-up at path: '${IRONFOX_NVM}'!"
      read -p "Do you want to re-create it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        "${IRONFOX_RM}" -rf "${IRONFOX_NPM_CACHE}" "${IRONFOX_NVM}" "${IRONFOX_ROOT}/node_modules"
      fi
    fi
  fi

  download_and_extract "https://github.com/nvm-sh/nvm/archive/${IRONFOX_NVM_COMMIT}.tar.gz" "${IRONFOX_NVM}" "${IRONFOX_NVM_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_red_text 'Installing Node.js...'
    source "${IRONFOX_NVM_ENV}"
    nvm install "${IRONFOX_NODE_VERSION}"
    nvm alias default "${IRONFOX_NODE_VERSION}"
    nvm use "${IRONFOX_NODE_VERSION}"
    echo_green_text "SUCCESS: Set-up Node.js environment at path: '${IRONFOX_NVM}'!"
  fi
}

# Get npm
function get_npm() {
  # Ensure we have `IRONFOX_NPM_VERSION`
  if [[ -z "${IRONFOX_NPM_VERSION+x}" ]] || [[ "${IRONFOX_NPM_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_NPM_VERSION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_NPM_SHA512SUM`
  if [[ -z "${IRONFOX_NPM_SHA512SUM+x}" ]] || [[ "${IRONFOX_NPM_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_NPM_SHA512SUM' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]] && [[ ! -d "${IRONFOX_NVM}" ]]; then
    echo_red_text "ERROR: You tried to download npm, but you don't have a Node.js environment set-up yet."
    exit 1
  fi

  echo_red_text 'Downloading npm...'
  download_file "https://registry.npmjs.org/npm/-/npm-${IRONFOX_NPM_VERSION}.tgz" "${IRONFOX_DOWNLOADS}/npm.tgz" "${IRONFOX_NPM_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_red_text 'Installing npm...'
    source "${IRONFOX_NVM_ENV}"
    "${IRONFOX_NPM}" install -g npm@file:"${IRONFOX_DOWNLOADS}/npm.tgz"
    echo_green_text "SUCCESS: Set-up npm at path: '${IRONFOX_NPM}'!"
  fi
}

# Get Phoenix
function get_phoenix() {
  # Ensure we have `IRONFOX_PHOENIX_COMMIT`
  if [[ -z "${IRONFOX_PHOENIX_COMMIT+x}" ]] || [[ "${IRONFOX_PHOENIX_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PHOENIX_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_PHOENIX_SHA512SUM`
  if [[ -z "${IRONFOX_PHOENIX_SHA512SUM+x}" ]] || [[ "${IRONFOX_PHOENIX_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PHOENIX_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading Phoenix to path: '${IRONFOX_PHOENIX}'..."
  download_and_extract "https://gitlab.com/celenityy/Phoenix/-/archive/${IRONFOX_PHOENIX_COMMIT}/Phoenix-${IRONFOX_PHOENIX_COMMIT}.tar.gz" "${IRONFOX_PHOENIX}" "${IRONFOX_PHOENIX_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Phoenix at path: '${IRONFOX_PHOENIX}'!"
  fi
}

# Get + set-up pip
function get_pip() {
  # Ensure we have `IRONFOX_PIP_COMMIT`
  if [[ -z "${IRONFOX_PIP_COMMIT+x}" ]] || [[ "${IRONFOX_PIP_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PIP_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_PIP_SHA512SUM`
  if [[ -z "${IRONFOX_PIP_SHA512SUM+x}" ]] || [[ "${IRONFOX_PIP_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PIP_SHA512SUM' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have uv
    verify_exec "${IRONFOX_UV}" 'IRONFOX_UV' || {
      echo_red_text "ERROR: Unable to download and install pip without uv!"
      exit 1
    }

    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download pip, but you don't have a Python environment set-up yet!"
      exit 1
    fi
  fi

  echo_red_text "Downloading pip to path: '${IRONFOX_PIP_DIR}'..."
  download_and_extract "https://github.com/pypa/pip/archive/${IRONFOX_PIP_COMMIT}.tar.gz" "${IRONFOX_PIP_DIR}" "${IRONFOX_PIP_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text "Installing pip to path: '${IRONFOX_PIP}'..."
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_PIP_DIR}"
    echo_green_text "SUCCESS: Set-up pip at path: '${IRONFOX_PIP}'!"
  fi
}

# Get the IronFox prebuilds repo
function get_prebuilds() {
  # Ensure we have `IRONFOX_PREBUILDS_COMMIT`
  if [[ -z "${IRONFOX_PREBUILDS_COMMIT+x}" ]] || [[ "${IRONFOX_PREBUILDS_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PREBUILDS_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_PREBUILDS_SHA512SUM`
  if [[ -z "${IRONFOX_PREBUILDS_SHA512SUM+x}" ]] || [[ "${IRONFOX_PREBUILDS_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PREBUILDS_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading the IronFox prebuilds repository to path: '${IRONFOX_PREBUILDS}'..."
  download_and_extract "https://gitlab.com/ironfox-oss/prebuilds/-/archive/${IRONFOX_PREBUILDS_COMMIT}/prebuilds-${IRONFOX_PREBUILDS_COMMIT}.tar.gz" "${IRONFOX_PREBUILDS}" "${IRONFOX_PREBUILDS_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    pushd "${IRONFOX_PREBUILDS}"
    echo_red_text 'Downloading prebuild sources...'
    /bin/bash "${IRONFOX_PREBUILDS}/scripts/get_sources.sh" || exit 1
    popd
    echo_green_text "SUCCESS: Set-up the IronFox prebuilds repository at path: '${IRONFOX_PREBUILDS}'!"
  fi
}

# Get Python
function get_python() {
  # Ensure we have `IRONFOX_PYTHON_GIT_RELEASE`
  if [[ -z "${IRONFOX_PYTHON_GIT_RELEASE+x}" ]] || [[ "${IRONFOX_PYTHON_GIT_RELEASE}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PYTHON_GIT_RELEASE' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_PYTHON_VERSION`
  if [[ -z "${IRONFOX_PYTHON_VERSION+x}" ]] || [[ "${IRONFOX_PYTHON_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PYTHON_VERSION' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care about existing installations
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have rm
    verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

    # Ensure we have uv
    verify_exec "${IRONFOX_UV}" 'IRONFOX_UV' || {
      echo_red_text "ERROR: Unable to download and install Python without uv!"
      exit 1
    }

    if [[ -d "${IRONFOX_PYENV_DIR}" ]]; then
      echo_red_text "The Python environment is already set-up at path: '${IRONFOX_PYENV_DIR}'!"
      read -p "Do you want to re-create it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
        backup_dir "${IRONFOX_PYENV_DIR}"
      fi
    fi

    if [[ -d "${IRONFOX_PYTHON_DIR}" ]]; then
      echo_red_text "Found existing installation at path: '${IRONFOX_PYTHON_DIR}'!"
      echo 'Continuing will remove this installation and related data'
      read -p "Do you still want to continue? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directories
        backup_dir "${IRONFOX_PYENV_DIR}"
        backup_dir "${IRONFOX_PYTHON_DIR}"
        backup_dir "${IRONFOX_UV_CACHE}"
        backup_dir "${IRONFOX_UV_LOCAL}/python-cache"
        backup_dir "${IRONFOX_UV_PYTHON}"
      else
        return 0
      fi
    fi
  fi

  # Base download URL
  local -r base_url="https://github.com/astral-sh/python-build-standalone/releases/download/${IRONFOX_PYTHON_GIT_RELEASE}"

  # Base output path
  local -r base_output="${IRONFOX_PYTHON_DIR}/${IRONFOX_PYTHON_GIT_RELEASE}"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Python (Linux - ARM64)...'
    download_file "${base_url}/cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz" "${base_output}/cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading Python (Linux - x86_64)...'
    download_file "${base_url}/cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz" "${base_output}/cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading Python (OS X - ARM64)...'
    download_file "${base_url}/cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-aarch64-apple-darwin-install_only_stripped.tar.gz" "${base_output}/cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-aarch64-apple-darwin-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading Python (OS X - x86_64)...'
    download_file "${base_url}/cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-x86_64-apple-darwin-install_only_stripped.tar.gz" "${base_output}/cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-x86_64-apple-darwin-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_SHA512SUM_OSX_X86_64}"
  else
    # Ensure we have rm
    verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_PYTHON_PLATFORM='apple-darwin'
    else
      local -r IRONFOX_PYTHON_PLATFORM='unknown-linux-gnu'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local -r IRONFOX_PYTHON_ARCH='aarch64'
    else
      local -r IRONFOX_PYTHON_ARCH='x86_64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_PYTHON_SHA512SUM="${IRONFOX_PYTHON_SHA512SUM_OSX_ARM64}"
      else
        local -r IRONFOX_PYTHON_SHA512SUM="${IRONFOX_PYTHON_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_PYTHON_SHA512SUM="${IRONFOX_PYTHON_SHA512SUM_OSX_X86_64}"
      else
        local -r IRONFOX_PYTHON_SHA512SUM="${IRONFOX_PYTHON_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    # Tell `download` to return instead of exit upon an error
    IRONFOX_DOWNLOAD_EXIT=0

    # By default, we know nothing has failed...
    local IRONFOX_DOWNLOAD_FAILED=0
    local IRONFOX_PYENV_FAILED=0
    local IRONFOX_PYTHON_INSTALL_FAILED=0

    local -r dl_archive="cpython-${IRONFOX_PYTHON_VERSION}+${IRONFOX_PYTHON_GIT_RELEASE}-${IRONFOX_PYTHON_ARCH}-${IRONFOX_PYTHON_PLATFORM}-install_only_stripped.tar.gz"
    local -r dl_output="${base_output}/${dl_archive}"
    local -r dl_url="${base_url}/${dl_archive}"

    echo_red_text 'Downloading Python...'
    download_file "${dl_url}" "${dl_output}" "${IRONFOX_PYTHON_SHA512SUM}" || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-ups, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text "ERROR: Download for Python to path: '${dl_output}' failed!"
      restore_dir "${IRONFOX_PYENV_DIR}"
      restore_dir "${IRONFOX_PYTHON_DIR}"
      restore_dir "${IRONFOX_UV_CACHE}"
      restore_dir "${IRONFOX_UV_PYTHON}"
      restore_dir "${IRONFOX_UV_LOCAL}/python-cache"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    elif [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Downloaded Python to path: '${dl_output}'!"

      echo_red_text 'Installing Python...'
      "${IRONFOX_UV}" python install "${IRONFOX_PYTHON_VERSION}" || local IRONFOX_PYTHON_INSTALL_FAILED=1

      # If the install failed, restore our back-ups, clean-up, and exit
      if [[ "${IRONFOX_PYTHON_INSTALL_FAILED}" == 1 ]]; then
        echo_red_text "ERROR: Unable to install Python from path: '${dl_output}'!"
        restore_dir "${IRONFOX_PYENV_DIR}"
        restore_dir "${IRONFOX_PYTHON_DIR}"
        restore_dir "${IRONFOX_UV_CACHE}"
        restore_dir "${IRONFOX_UV_PYTHON}"
        restore_dir "${IRONFOX_UV_LOCAL}/python-cache"
        "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
        exit 1
      fi

      echo_red_text "Creating Python environment at path: '${IRONFOX_PYENV_DIR}'..."
      "${IRONFOX_UV}" venv "${IRONFOX_PYENV_DIR}" || local IRONFOX_PYENV_FAILED=1

      # If the Python env set-up failed, restore our back-up, clean-up, and exit
      if [[ "${IRONFOX_PYENV_FAILED}" == 1 ]]; then
        echo_red_text "ERROR: Unable to set-up Python environment at path: '${IRONFOX_PYENV_DIR}'!"
        restore_dir "${IRONFOX_PYENV_DIR}"
        "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
        exit 1
      else
        echo_green_text "SUCCESS: Set-up Python environment at path: '${IRONFOX_PYENV_DIR}'!"
      fi
    fi
  fi
}

# Get PyYAML
function get_pyyaml() {
  # Ensure we have `IRONFOX_PYYAML_COMMIT`
  if [[ -z "${IRONFOX_PYYAML_COMMIT+x}" ]] || [[ "${IRONFOX_PYYAML_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PYYAML_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_PYYAML_SHA512SUM`
  if [[ -z "${IRONFOX_PYYAML_SHA512SUM+x}" ]] || [[ "${IRONFOX_PYYAML_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PYYAML_SHA512SUM' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have uv
    verify_exec "${IRONFOX_UV}" 'IRONFOX_UV' || {
      echo_red_text "ERROR: Unable to download and install PyYAML without uv!"
      exit 1
    }

    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download PyYAML, but you don't have a Python environment set-up yet!"
      exit 1
    fi

    if [[ -d "${IRONFOX_PYYAML}" ]]; then
      echo_red_text "PyYAML is already downloaded at path: '${IRONFOX_PYYAML}'!"
      read -p "Do you want to re-download it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
        return 0
      else
        source "${IRONFOX_PYENV}"
        "${IRONFOX_UV}" pip uninstall pyyaml
      fi
    fi
  fi

  echo_red_text "Downloading PyYAML to path: '${IRONFOX_PYYAML}'..."
  download_and_extract "https://github.com/yaml/pyyaml/archive/${IRONFOX_PYYAML_COMMIT}.tar.gz" "${IRONFOX_PYYAML}" "${IRONFOX_PYYAML_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text 'Installing PyYAML...'
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_PYYAML}"
    echo_green_text "SUCCESS: Set-up PyYAML at path: '${IRONFOX_PYYAML}'!"
  fi
}

# Get + set-up rust/cargo
function get_rust() {
  # Ensure we have `IRONFOX_RUSTUP_COMMIT`
  if [[ -z "${IRONFOX_RUSTUP_COMMIT+x}" ]] || [[ "${IRONFOX_RUSTUP_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_RUSTUP_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_RUSTUP_SHA512SUM`
  if [[ -z "${IRONFOX_RUSTUP_SHA512SUM+x}" ]] || [[ "${IRONFOX_RUSTUP_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_RUSTUP_SHA512SUM' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_RUST_VERSION`
  if [[ -z "${IRONFOX_RUST_VERSION+x}" ]] || [[ "${IRONFOX_RUST_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_RUST_VERSION' is missing!"
    exit 1
  fi

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]] && [[ -d "${IRONFOX_CARGO_HOME}" ]]; then
    echo_red_text "Found existing installation at path: '${IRONFOX_CARGO_HOME}'!"
    echo 'Continuing will remove this installation and related data'
    read -p "Do you still want to continue? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directories
      backup_dir "${IRONFOX_CARGO_HOME}"
      backup_dir "${IRONFOX_RUSTUP_HOME}"
    else
      return 0
    fi
  fi

  # Base download URL
  local -r base_url="https://raw.githubusercontent.com/rust-lang/rustup/${IRONFOX_RUSTUP_COMMIT}/rustup-init.sh"

  # rustup-init.sh
  local -r rustup_init_sh="${IRONFOX_DOWNLOADS}/rustup-init.sh"

  echo_red_text 'Downloading Rust...'
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    download_file "${base_url}" "${rustup_init_sh}" "${IRONFOX_RUSTUP_SHA512SUM}"
  else
    # Ensure we have rm
    verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

    # Tell `download` to return instead of exit upon an error
    IRONFOX_DOWNLOAD_EXIT=0

    # By default, we know nothing has failed...
    local IRONFOX_CARGO_ENV_FAILED=0
    local IRONFOX_CARGO_INSTALL_FAILED=0
    local IRONFOX_DOWNLOAD_FAILED=0

    download_file "${base_url}" "${rustup_init_sh}" "${IRONFOX_RUSTUP_SHA512SUM}" || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-up, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text "ERROR: Download for Rust failed!"
      restore_dir "${IRONFOX_CARGO_HOME}"
      restore_dir "${IRONFOX_RUSTUP_HOME}"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    elif [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_red_text "Installing Rust to path: '${IRONFOX_CARGO_HOME}'..."
      /bin/bash -x "${rustup_init_sh}" -y --no-modify-path --no-update-default-toolchain --profile=minimal || local IRONFOX_CARGO_INSTALL_FAILED=1

      # If the install failed, restore our back-ups, clean-up, and exit
      if [[ "${IRONFOX_CARGO_INSTALL_FAILED}" == 1 ]]; then
        echo_red_text "ERROR: Installation of Rust to path: '${IRONFOX_CARGO_HOME}' failed!"
        restore_dir "${IRONFOX_CARGO_HOME}"
        restore_dir "${IRONFOX_RUSTUP_HOME}"
        "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
        exit 1
      fi

      # Source the newly created Rust environment
      source "${IRONFOX_CARGO_ENV}" || local IRONFOX_CARGO_ENV_FAILED=1

      # If we couldn't source our environment, restore our back-ups, clean-up, and exit
      if [[ "${IRONFOX_CARGO_ENV_FAILED}" == 1 ]]; then
        echo_red_text "ERROR: Failed to source Rust environment: '${IRONFOX_CARGO_ENV}'!"
        restore_dir "${IRONFOX_CARGO_HOME}"
        restore_dir "${IRONFOX_RUSTUP_HOME}"
        "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
        exit 1
      fi

      # Set-up Rust
      rustup set profile minimal
      rustup default "${IRONFOX_RUST_VERSION}"
      rustup override set "${IRONFOX_RUST_VERSION}"
      rustup target add aarch64-linux-android
      rustup target add armv7-linux-androideabi
      rustup target add thumbv7neon-linux-androideabi
      rustup target add x86_64-linux-android

      echo_green_text "SUCCESS: Set-up Rust at path: '${IRONFOX_CARGO_HOME}'!"
    fi
  fi
}

# Get s3cmd
function get_s3cmd() {
  # Ensure we have `IRONFOX_S3CMD_COMMIT`
  if [[ -z "${IRONFOX_S3CMD_COMMIT+x}" ]] || [[ "${IRONFOX_S3CMD_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_S3CMD_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_S3CMD_SHA512SUM`
  if [[ -z "${IRONFOX_S3CMD_SHA512SUM+x}" ]] || [[ "${IRONFOX_S3CMD_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_S3CMD_SHA512SUM' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have uv
    verify_exec "${IRONFOX_UV}" 'IRONFOX_UV' || {
      echo_red_text "ERROR: Unable to download and install s3cmd without uv!"
      exit 1
    }

    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download s3cmd, but you don't have a Python environment set-up yet!"
      exit 1
    fi

    if [[ -d "${IRONFOX_S3CMD}" ]]; then
      echo_red_text "s3cmd is already installed at path: '${IRONFOX_S3CMD}'!"
      read -p "Do you want to re-download it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
        return 0
      else
        source "${IRONFOX_PYENV}"
        "${IRONFOX_UV}" pip uninstall s3cmd
      fi
    fi
  fi

  echo_red_text "Downloading s3cmd to path: '${IRONFOX_S3CMD_DIR}'..."
  download_and_extract "https://github.com/s3tools/s3cmd/archive/${IRONFOX_S3CMD_COMMIT}.tar.gz" "${IRONFOX_S3CMD_DIR}" "${IRONFOX_S3CMD_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text "Installing s3cmd to path: '${IRONFOX_S3CMD}'..."
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_S3CMD_DIR}"
    echo_green_text "SUCCESS: Set-up s3cmd at path: '${IRONFOX_S3CMD}'!"
  fi
}

# Get shellcheck
function get_shellcheck() {
  # Ensure we have `IRONFOX_SHELLCHECK_VERSION`
  if [[ -z "${IRONFOX_SHELLCHECK_VERSION+x}" ]] || [[ "${IRONFOX_SHELLCHECK_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_SHELLCHECK_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://github.com/koalaman/shellcheck/releases/download/${IRONFOX_SHELLCHECK_VERSION}"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading shellcheck (Linux - ARM64)...'
    download_file "${base_url}/shellcheck-${IRONFOX_SHELLCHECK_VERSION}.linux.aarch64.tar.xz" "${IRONFOX_SHELLCHECK_DIR}" "${IRONFOX_SHELLCHECK_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading shellcheck (Linux - x86_64)...'
    download_file "${base_url}/shellcheck-${IRONFOX_SHELLCHECK_VERSION}.linux.x86_64.tar.xz" "${IRONFOX_SHELLCHECK_DIR}" "${IRONFOX_SHELLCHECK_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading shellcheck (OS X - ARM64)...'
    download_file "${base_url}/shellcheck-${IRONFOX_SHELLCHECK_VERSION}.darwin.aarch64.tar.xz" "${IRONFOX_SHELLCHECK_DIR}" "${IRONFOX_SHELLCHECK_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading shellcheck (OS X - x86_64)...'
    download_file "${base_url}/shellcheck-${IRONFOX_SHELLCHECK_VERSION}.darwin.x86_64.tar.xz" "${IRONFOX_SHELLCHECK_DIR}" "${IRONFOX_SHELLCHECK_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_SHELLCHECK_PLATFORM='darwin'
    else
      local -r IRONFOX_SHELLCHECK_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local -r IRONFOX_SHELLCHECK_ARCH='aarch64'
    else
      local -r IRONFOX_SHELLCHECK_ARCH='x86_64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_SHELLCHECK_SHA512SUM="${IRONFOX_SHELLCHECK_SHA512SUM_OSX_ARM64}"
      else
        local -r IRONFOX_SHELLCHECK_SHA512SUM="${IRONFOX_SHELLCHECK_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_SHELLCHECK_SHA512SUM="${IRONFOX_SHELLCHECK_SHA512SUM_OSX_X86_64}"
      else
        local -r IRONFOX_SHELLCHECK_SHA512SUM="${IRONFOX_SHELLCHECK_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    echo_red_text "Downloading shellcheck to path: '${IRONFOX_SHELLCHECK_DIR}'..."
    download_and_extract "${base_url}/shellcheck-${IRONFOX_SHELLCHECK_VERSION}.${IRONFOX_SHELLCHECK_PLATFORM}.${IRONFOX_SHELLCHECK_ARCH}.tar.xz" "${IRONFOX_SHELLCHECK_DIR}" "${IRONFOX_SHELLCHECK_SHA512SUM}"

    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      # Set-up the linting pre-commit hook
      if [[ "${IRONFOX_CI}" != 1 ]] && [[ -x "${IRONFOX_GIT}" ]] && [[ ! -f "${IRONFOX_BUILD}/set-hook" ]]; then
        /bin/bash "${IRONFOX_SCRIPTS}/lint-hook.sh"
      fi

      echo_green_text "SUCCESS: Set-up shellcheck at path: '${IRONFOX_SHELLCHECK}'!"
    fi
  fi
}

# Get shfmt
function get_shfmt() {
  # Ensure we have `IRONFOX_SHFMT_VERSION`
  if [[ -z "${IRONFOX_SHFMT_VERSION+x}" ]] || [[ "${IRONFOX_SHFMT_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_SHFMT_VERSION' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care about existing installations
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    # Ensure we have chmod
    verify_exec "${IRONFOX_CHMOD}" 'IRONFOX_CHMOD' || exit 1
  fi

  # Base download URL
  local -r base_url="https://github.com/mvdan/sh/releases/download/${IRONFOX_SHFMT_VERSION}"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading shfmt (Linux - ARM64)...'
    download_file "${base_url}/shfmt_${IRONFOX_SHFMT_VERSION}_linux_arm64" "${IRONFOX_SHFMT}" "${IRONFOX_SHFMT_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading shfmt (Linux - x86_64)...'
    download_file "${base_url}/shfmt_${IRONFOX_SHFMT_VERSION}_linux_amd64" "${IRONFOX_SHFMT}" "${IRONFOX_SHFMT_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading shfmt (OS X - ARM64)...'
    download_file "${base_url}/shfmt_${IRONFOX_SHFMT_VERSION}_darwin_arm64" "${IRONFOX_SHFMT}" "${IRONFOX_SHFMT_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading shfmt (OS X - x86_64)...'
    download_file "${base_url}/shfmt_${IRONFOX_SHFMT_VERSION}_darwin_amd64" "${IRONFOX_SHFMT}" "${IRONFOX_SHFMT_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_SHFMT_PLATFORM='darwin'
    else
      local -r IRONFOX_SHFMT_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local -r IRONFOX_SHFMT_ARCH='arm64'
    else
      local -r IRONFOX_SHFMT_ARCH='amd64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_SHFMT_SHA512SUM="${IRONFOX_SHFMT_SHA512SUM_OSX_ARM64}"
      else
        local -r IRONFOX_SHFMT_SHA512SUM="${IRONFOX_SHFMT_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_SHFMT_SHA512SUM="${IRONFOX_SHFMT_SHA512SUM_OSX_X86_64}"
      else
        local -r IRONFOX_SHFMT_SHA512SUM="${IRONFOX_SHFMT_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    echo_red_text "Downloading shfmt to path: '${IRONFOX_SHFMT}'..."
    download_file "${base_url}/shfmt_${IRONFOX_SHFMT_VERSION}_${IRONFOX_SHFMT_PLATFORM}_${IRONFOX_SHFMT_ARCH}" "${IRONFOX_SHFMT}" "${IRONFOX_SHFMT_SHA512SUM}"

    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      "${IRONFOX_CHMOD}" +x "${IRONFOX_SHFMT}"

      # Set-up the linting pre-commit hook
      if [[ "${IRONFOX_CI}" != 1 ]] && [[ -x "${IRONFOX_GIT}" ]] && [[ ! -f "${IRONFOX_BUILD}/set-hook" ]]; then
        /bin/bash "${IRONFOX_SCRIPTS}/lint-hook.sh"
      fi

      echo_green_text "SUCCESS: Set-up shfmt at path: '${IRONFOX_SHFMT}'!"
    fi
  fi
}

# Get Tor's no-op UniFFi binding generator
function get_uniffi() {
  # Ensure we have `IRONFOX_PREBUILDS_COMMIT`
  if [[ -z "${IRONFOX_PREBUILDS_COMMIT+x}" ]] || [[ "${IRONFOX_PREBUILDS_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PREBUILDS_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_UNIFFI_IRONFOX_REVISION`
  if [[ -z "${IRONFOX_UNIFFI_IRONFOX_REVISION+x}" ]] || [[ "${IRONFOX_UNIFFI_IRONFOX_REVISION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_UNIFFI_IRONFOX_REVISION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_UNIFFI_VERSION`
  if [[ -z "${IRONFOX_UNIFFI_VERSION+x}" ]] || [[ "${IRONFOX_UNIFFI_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_UNIFFI_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://gitlab.com/ironfox-oss/prebuilds/-/raw/${IRONFOX_PREBUILDS_COMMIT}/uniffi-bindgen/${IRONFOX_UNIFFI_VERSION}"

  # Get uniffi-bindgen for Linux
  if [[ "${IRONFOX_PLATFORM}" == 'linux' ]] || [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading prebuilt uniffi-bindgen (Linux)...'
    download_and_extract "${base_url}/linux/uniffi-bindgen-${IRONFOX_UNIFFI_VERSION}-${IRONFOX_UNIFFI_IRONFOX_REVISION}-linux.tar.xz" "${IRONFOX_UNIFFI}" "${IRONFOX_UNIFFI_LINUX_IRONFOX_SHA512SUM}"
  fi

  # Get uniffi-bindgen for OS X
  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]] || [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading prebuilt uniffi-bindgen (OS X)...'
    download_and_extract "${base_url}/osx/uniffi-bindgen-${IRONFOX_UNIFFI_VERSION}-${IRONFOX_UNIFFI_IRONFOX_REVISION}-osx.tar.xz" "${IRONFOX_UNIFFI}" "${IRONFOX_UNIFFI_OSX_IRONFOX_SHA512SUM}"
  fi

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up the prebuilt uniffi-bindgen at path: '${IRONFOX_UNIFFI}'!"
  fi
}

# Get UnifiedPush-AC
function get_up_ac() {
  # Ensure we have `IRONFOX_UP_AC_COMMIT`
  if [[ -z "${IRONFOX_UP_AC_COMMIT+x}" ]] || [[ "${IRONFOX_UP_AC_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_UP_AC_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_UP_AC_SHA512SUM`
  if [[ -z "${IRONFOX_UP_AC_SHA512SUM+x}" ]] || [[ "${IRONFOX_UP_AC_SHA512SUM}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_UP_AC_SHA512SUM' is missing!"
    exit 1
  fi

  echo_red_text "Downloading UnifiedPush-AC to path: '${IRONFOX_UP_AC}'..."
  download_and_extract "https://gitlab.com/ironfox-oss/unifiedpush-ac/-/archive/${IRONFOX_UP_AC_COMMIT}/unifiedpush-ac-${IRONFOX_UP_AC_COMMIT}.tar.gz" "${IRONFOX_UP_AC}" "${IRONFOX_UP_AC_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up UnifiedPush-AC at path: '${IRONFOX_UP_AC}'!"
  fi
}

# Get + set-up uv
function get_uv() {
  # Ensure we have `IRONFOX_UV_VERSION`
  if [[ -z "${IRONFOX_UV_VERSION+x}" ]] || [[ "${IRONFOX_UV_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_UV_VERSION' is missing!"
    exit 1
  fi

  # If all we're doing is updating the checksum, we don't care about existing installations
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]] && [[ -d "${IRONFOX_UV_DIR}" ]]; then
    echo_red_text "Found existing installation at path: '${IRONFOX_UV_DIR}'!"
    echo 'Continuing will remove this installation and related data'
    read -p "Do you still want to continue? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directories
      backup_dir "${IRONFOX_UV_DIR}"
      backup_dir "${IRONFOX_UV_LOCAL}"
    else
      return 0
    fi
  fi

  # Base download URL
  local -r base_url="https://github.com/astral-sh/uv/releases/download/${IRONFOX_UV_VERSION}"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading uv (Linux - ARM64)...'
    download_file "${base_url}/uv-aarch64-unknown-linux-gnu.tar.gz" "${IRONFOX_UV_DIR}" "${IRONFOX_UV_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading uv (Linux - x86_64)...'
    download_file "${base_url}/uv-x86_64-unknown-linux-gnu.tar.gz" "${IRONFOX_UV_DIR}" "${IRONFOX_UV_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading uv (OS X - ARM64)...'
    download_file "${base_url}/uv-aarch64-apple-darwin.tar.gz" "${IRONFOX_UV_DIR}" "${IRONFOX_UV_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading uv (OS X - x86_64)...'
    download_file "${base_url}/uv-x86_64-apple-darwin.tar.gz" "${IRONFOX_UV_DIR}" "${IRONFOX_UV_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local -r IRONFOX_UV_PLATFORM='apple-darwin'
    else
      local -r IRONFOX_UV_PLATFORM='unknown-linux-gnu'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local -r IRONFOX_UV_ARCH='aarch64'
    else
      local -r IRONFOX_UV_ARCH='x86_64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_UV_SHA512SUM="${IRONFOX_UV_SHA512SUM_OSX_ARM64}"
      else
        local -r IRONFOX_UV_SHA512SUM="${IRONFOX_UV_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local -r IRONFOX_UV_SHA512SUM="${IRONFOX_UV_SHA512SUM_OSX_X86_64}"
      else
        local -r IRONFOX_UV_SHA512SUM="${IRONFOX_UV_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    # Tell `download` to return instead of exit upon an error
    IRONFOX_DOWNLOAD_EXIT=0

    # By default, we know the download hasn't failed...
    local IRONFOX_DOWNLOAD_FAILED=0

    echo_red_text "Downloading uv to path: '${IRONFOX_UV_DIR}'..."
    download_and_extract "${base_url}/uv-${IRONFOX_UV_ARCH}-${IRONFOX_UV_PLATFORM}.tar.gz" "${IRONFOX_UV_DIR}" "${IRONFOX_UV_SHA512SUM}" || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-up, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text "ERROR: Download for uv to path: '${IRONFOX_UV_DIR}' failed!"
      restore_dir "${IRONFOX_UV_DIR}"
      restore_dir "${IRONFOX_UV_LOCAL}"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    elif [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up uv at path: '${IRONFOX_UV}'!"
    fi
  fi
}

# Get WebAssembly SDK
function get_wasi() {
  # Ensure we have `IRONFOX_PREBUILDS_COMMIT`
  if [[ -z "${IRONFOX_PREBUILDS_COMMIT+x}" ]] || [[ "${IRONFOX_PREBUILDS_COMMIT}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_PREBUILDS_COMMIT' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_WASI_IRONFOX_REVISION`
  if [[ -z "${IRONFOX_WASI_IRONFOX_REVISION+x}" ]] || [[ "${IRONFOX_WASI_IRONFOX_REVISION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_WASI_IRONFOX_REVISION' is missing!"
    exit 1
  fi

  # Ensure we have `IRONFOX_WASI_VERSION`
  if [[ -z "${IRONFOX_WASI_VERSION+x}" ]] || [[ "${IRONFOX_WASI_VERSION}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_WASI_VERSION' is missing!"
    exit 1
  fi

  # Base download URL
  local -r base_url="https://gitlab.com/ironfox-oss/prebuilds/-/raw/${IRONFOX_PREBUILDS_COMMIT}/wasi-sdk/${IRONFOX_WASI_VERSION}"

  # Get WASI SDK for Linux
  if [[ "${IRONFOX_PLATFORM}" == 'linux' ]] || [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading prebuilt WASI SDK (Linux)...'
    download_and_extract "${base_url}/linux/wasi-sdk-${IRONFOX_WASI_VERSION}-${IRONFOX_WASI_IRONFOX_REVISION}-linux.tar.xz" "${IRONFOX_WASI}" "${IRONFOX_WASI_LINUX_IRONFOX_SHA512SUM}"
  fi

  # Get WASI SDK for OS X
  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]] || [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading prebuilt WASI SDK (OS X)...'
    download_and_extract "${base_url}/osx/wasi-sdk-${IRONFOX_WASI_VERSION}-${IRONFOX_WASI_IRONFOX_REVISION}-osx.tar.xz" "${IRONFOX_WASI}" "${IRONFOX_WASI_OSX_IRONFOX_SHA512SUM}"
  fi

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up the prebuilt WASI SDK at path: '${IRONFOX_WASI}'!"
  fi
}

# Clean-up
"${IRONFOX_RM}" -rf "${IRONFOX_DOWNLOADS}"
"${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"

# These need to run before we get androguard, glean_parser, gyp, PyYAML, and s3cmd
if [[ "${IRONFOX_GET_SOURCE_UV}" == 1 ]]; then
  get_uv
fi

if [[ "${IRONFOX_GET_SOURCE_PYTHON}" == 1 ]]; then
  get_python
fi

if [[ "${IRONFOX_GET_SOURCE_ANDROGUARD}" == 1 ]]; then
  get_androguard
fi

if [[ "${IRONFOX_GET_SOURCE_ANDROID_NDK}" == 1 ]]; then
  get_android_ndk
fi

# This needs to run before we get the Android SDK
if [[ "${IRONFOX_GET_SOURCE_JDK_25}" == 1 ]]; then
  get_jdk_25
fi

if [[ "${IRONFOX_GET_SOURCE_ANDROID_SDK}" == 1 ]]; then
  get_android_sdk
fi

if [[ "${IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS}" == 1 ]]; then
  get_android_sdk_build_tools
fi

if [[ "${IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35}" == 1 ]]; then
  get_android_sdk_build_tools_35
fi

if [[ "${IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM}" == 1 ]]; then
  get_android_sdk_platform
fi

if [[ "${IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36}" == 1 ]]; then
  get_android_sdk_platform_36
fi

if [[ "${IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS}" == 1 ]]; then
  get_android_sdk_platform_tools
fi

if [[ "${IRONFOX_GET_SOURCE_AS}" == 1 ]]; then
  get_as
fi

# This needs to run before we get cbindgen
if [[ "${IRONFOX_GET_SOURCE_RUST}" == 1 ]]; then
  get_rust
fi

if [[ "${IRONFOX_GET_SOURCE_CBINDGEN}" == 1 ]]; then
  get_cbindgen
fi

if [[ "${IRONFOX_GET_SOURCE_BUNDLETOOL}" == 1 ]]; then
  get_bundletool
fi

if [[ "${IRONFOX_GET_SOURCE_GECKO}" == 1 ]]; then
  get_firefox
fi

if [[ "${IRONFOX_GET_SOURCE_GECKO_L10N}" == 1 ]]; then
  get_firefox_l10n
fi

if [[ "${IRONFOX_GET_SOURCE_GLEAN}" == 1 ]]; then
  get_glean
fi

if [[ "${IRONFOX_GET_SOURCE_JDK_17}" == 1 ]]; then
  get_jdk_17
fi

if [[ "${IRONFOX_GET_SOURCE_JDK_21}" == 1 ]]; then
  get_jdk_21
fi

# This needs to be run before we get glean_parser
if [[ "${IRONFOX_GET_SOURCE_PIP}" == 1 ]]; then
  get_pip
fi

if [[ "${IRONFOX_GET_SOURCE_GLEAN_PARSER}" == 1 ]]; then
  get_glean_parser
fi

if [[ "${IRONFOX_GET_SOURCE_GRADLE}" == 1 ]]; then
  get_gradle
fi

if [[ "${IRONFOX_GET_SOURCE_GYP}" == 1 ]]; then
  get_gyp
fi

if [[ "${IRONFOX_GET_SOURCE_MICROG}" == 1 ]]; then
  get_microg
fi

if [[ "${IRONFOX_GET_SOURCE_NODE}" == 1 ]]; then
  get_node
fi

if [[ "${IRONFOX_GET_SOURCE_NPM}" == 1 ]]; then
  get_npm
fi

if [[ "${IRONFOX_GET_SOURCE_PHOENIX}" == 1 ]]; then
  get_phoenix
fi

if [[ "${IRONFOX_GET_SOURCE_PREBUILDS}" == 1 ]]; then
  get_prebuilds
fi

if [[ "${IRONFOX_GET_SOURCE_PYYAML}" == 1 ]]; then
  get_pyyaml
fi

if [[ "${IRONFOX_GET_SOURCE_S3CMD}" == 1 ]]; then
  get_s3cmd
fi

if [[ "${IRONFOX_GET_SOURCE_SHELLCHECK}" == 1 ]]; then
  get_shellcheck
fi

if [[ "${IRONFOX_GET_SOURCE_SHFMT}" == 1 ]]; then
  get_shfmt
fi

if [[ "${IRONFOX_GET_SOURCE_UNIFFI}" == 1 ]]; then
  get_uniffi
fi

if [[ "${IRONFOX_GET_SOURCE_UP_AC}" == 1 ]]; then
  get_up_ac
fi

if [[ "${IRONFOX_GET_SOURCE_WASI}" == 1 ]]; then
  get_wasi
fi
