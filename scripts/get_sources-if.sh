#!/bin/bash

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [[ -z "${IRONFOX_FROM_SOURCES+x}" ]]; then
  echo_red_text "ERROR: Do not call get_sources-if.sh directly. Instead, use get_sources.sh." >&1
  exit 1
fi

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
source "${IRONFOX_VERSIONS}"

# Back-up (and remove) a file if it exists
function backup_file() {
  local readonly file="$1"
  local readonly file_name="$("${IRONFOX_BASENAME}" "${file}")"
  local readonly backup_file="${IRONFOX_EXTERNAL}/temp/backup/${file_name}"

  if [[ -f "${file}" ]]; then
    "${IRONFOX_RM}" -f "${backup_file}"
    "${IRONFOX_MKDIR}" -p "$("${IRONFOX_DIRNAME}" "${backup_file}")"
    "${IRONFOX_CP}" -f "${file}" "${backup_file}"
    "${IRONFOX_RM}" -f "${file}"
  fi
}

# Back-up (and remove) a directory if it exists
function backup_dir() {
  local readonly dir="$1"
  local readonly dir_name="$("${IRONFOX_BASENAME}" "${dir}")"
  local readonly backup_dir="${IRONFOX_EXTERNAL}/temp/backup/${dir_name}"

  if [[ -d "${dir}" ]]; then
    "${IRONFOX_RM}" -rf "${backup_dir}"
    "${IRONFOX_MKDIR}" -p "$("${IRONFOX_DIRNAME}" "${backup_dir}")"
    "${IRONFOX_CP}" -rf "${dir}/" "${backup_dir}"
    "${IRONFOX_RM}" -rf "${dir}"
  fi
}

# Restore a backed-up file
function restore_file() {
  local readonly file="$1"
  local readonly file_name="$("${IRONFOX_BASENAME}" "${file}")"
  local readonly backed_up_file="${IRONFOX_EXTERNAL}/temp/backup/${file_name}"

  if [[ -f "${backed_up_file}" ]]; then
    "${IRONFOX_RM}" -f "${file}"
    "${IRONFOX_MKDIR}" -p "$("${IRONFOX_DIRNAME}" "${file}")"
    "${IRONFOX_CP}" -f "${backed_up_file}" "${file}"
    "${IRONFOX_RM}" -f "${backed_up_file}"
  fi
}

# Restore a backed-up directory
function restore_dir() {
  local readonly dir="$1"
  local readonly dir_name="$("${IRONFOX_BASENAME}" "${dir}")"
  local readonly backed_up_dir="${IRONFOX_EXTERNAL}/temp/backup/${dir_name}"

  if [[ -d "${backed_up_dir}" ]]; then
    "${IRONFOX_RM}" -rf "${dir}"
    "${IRONFOX_MKDIR}" -p "$("${IRONFOX_DIRNAME}" "${dir}")"
    "${IRONFOX_CP}" -rf "${backed_up_dir}/" "${dir}"
    "${IRONFOX_RM}" -rf "${backed_up_dir}"
  fi
}

# Function to automate updating checksums of dependencies
function update_checksum() {
  local readonly old_checksum="$1"
  local readonly new_checksum="$2"
  local readonly file="$3"
  local readonly checksum_type="$4"

  if [[ "${checksum_type}" == 'md5sum' ]]; then
    local readonly checksum_type_pretty='MD5sum'
  elif [[ "${checksum_type}" == 'sha1sum' ]]; then
    local readonly checksum_type_pretty='SHA1sum'
  elif [[ "${checksum_type}" == 'sha256sum' ]]; then
    local readonly checksum_type_pretty='SHA256sum'
  elif [[ "${checksum_type}" == 'sha512sum' ]]; then
    local readonly checksum_type_pretty='SHA512sum'
  else
    echo_red_text 'ERROR: Unknown checksum type.'
    exit 1
  fi

  if [[ "${old_checksum}" == "${new_checksum}" ]]; then
    echo_red_text 'Checksums match. Skipping...'
    echo "Old checksum: ${old_checksum}"
    echo "New checksum: ${new_checksum}"
  else
    echo_red_text "Updating ${checksum_type_pretty} for ${file}..."
    "${IRONFOX_SED}" -i "s|'${old_checksum}'|'${new_checksum}'|" "${IRONFOX_VERSIONS}"
    echo_green_text "SUCCESS: Updated ${checksum_type_pretty} for ${file}"
  fi
}

function validate_checksum() {
  local readonly expected_checksum="$1"
  local readonly file="$2"
  local readonly checksum_type="$3"

  if [[ "${checksum_type}" == 'md5sum' ]]; then
    local readonly checksum_type_pretty='MD5sum'
    local readonly local_checksum=$("${IRONFOX_MD5SUM}" "${file}" | "${IRONFOX_AWK}" '{print $1}')
  elif [[ "${checksum_type}" == 'sha1sum' ]]; then
    local readonly checksum_type_pretty='SHA1sum'
    local readonly local_checksum=$("${IRONFOX_SHA1SUM}" "${file}" | "${IRONFOX_AWK}" '{print $1}')
  elif [[ "${checksum_type}" == 'sha256sum' ]]; then
    local readonly checksum_type_pretty='SHA256sum'
    local readonly local_checksum=$("${IRONFOX_SHA256SUM}" "${file}" | "${IRONFOX_AWK}" '{print $1}')
  elif [[ "${checksum_type}" == 'sha512sum' ]]; then
    local readonly checksum_type_pretty='SHA512sum'
    local readonly local_checksum=$("${IRONFOX_SHA512SUM}" "${file}" | "${IRONFOX_AWK}" '{print $1}')
  else
    echo_red_text 'ERROR: Unknown checksum type.'
    return 1
  fi

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    update_checksum "${expected_checksum}" "${local_checksum}" "${file}" "${checksum_type}"
  elif [[ "${local_checksum}" != "${expected_checksum}" ]]; then
    echo_red_text 'ERROR: Checksum validation failed.'
    echo "Expected ${checksum_type_pretty}:   ${expected_checksum}"
    echo "Actual ${checksum_type_pretty}:     ${local_checksum}"

    # If checksum validation fails, also just remove the file
    "${IRONFOX_RM}" -f "${file}"

    return 1
  else
    echo_green_text 'SUCCESS: Checksum validated.'
    echo "${checksum_type_pretty}: ${local_checksum}"
  fi
}

function clone_repo() {
  local readonly url="$1"
  local readonly path="$2"
  local readonly revision="$3"

  if [[ "${url}" == "" ]]; then
    echo_red_text "ERROR: URL missing for clone"
    exit 1
  fi

  if [[ "${path}" == "" ]]; then
    echo_red_text "ERROR: Path is required for cloning '${url}'"
    exit 1
  fi

  if [[ "${revision}" == "" ]]; then
    echo_red_text "ERROR: Revision is required for cloning '${url}'"
    exit 1
  fi

  if [[ -f "${path}" ]]; then
    echo_red_text "ERROR: '${path}' exists and is not a directory"
    exit 1
  fi

  if [[ -d "${path}" ]]; then
    echo_red_text "'${path}' already exists"
    read -p "Do you want to re-clone this repository? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      echo_red_text "Removing ${path}..."
      "${IRONFOX_RM}" -rf "${path}"
    else
      return 0
    fi
  fi

  echo_red_text "Cloning ${url}::${revision}..."
  "${IRONFOX_GIT}" clone --revision="${revision}" --depth=1 "${url}" "${path}"
}

function download() {
  local readonly url="$1"
  local readonly file_in="$2"
  local readonly file_name=$("${IRONFOX_BASENAME}" "${file_in}")
  local readonly expected_sha512sum="$3"

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

  if [[ "${url}" == "" ]]; then
    echo_red_text "ERROR: URL is required (file: '${file_in}')"
    IRONFOX_PERFORM_POST_DOWNLOAD=0
    if [[ "${IRONFOX_DOWNLOAD_EXIT}" != 1 ]]; then
      unset IRONFOX_DOWNLOAD_EXIT
      return 1
    else
      exit 1
    fi
  fi

  # If we're doing a checksum update, we download the file to a separate temporary directory, instead of our standard one
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/chksm"
    local readonly file="${IRONFOX_EXTERNAL}/temp/chksm/${file_name}"
  else
    local readonly file="${file_in}"
  fi

  if [[ -f "${file}" ]]; then
    echo_red_text "${file} already exists."
    read -p "Do you want to re-download? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our file
      echo_red_text "Removing ${file}..."
      backup_file "${file}"
    else
      unset IRONFOX_DOWNLOAD_EXIT
      IRONFOX_PERFORM_POST_DOWNLOAD=0
      return 0
    fi
  fi

  # By default, we know nothing has failed...
  local IRONFOX_CHECKSUM_FAILED=0
  local IRONFOX_DOWNLOAD_FAILED=0

  if [[ ! -d "$("${IRONFOX_DIRNAME}" "${file}")" ]]; then
    "${IRONFOX_MKDIR}" -vp "$("${IRONFOX_DIRNAME}" "${file}")"
    local readonly CREATED_DIR_FOR_DL=1
  else
    local readonly CREATED_DIR_FOR_DL=0
  fi

  echo_red_text "Downloading ${url}..."
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${url}" --output "${file}" || local IRONFOX_DOWNLOAD_FAILED=1

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
    # If a directory was created just for this download, remove it
    if [[ "${CREATED_DIR_FOR_DL}" == 1 ]]; then
      "${IRONFOX_RM}" -rf "$("${IRONFOX_DIRNAME}" "${file}")"
    fi
    if [[ "${IRONFOX_DOWNLOAD_EXIT}" != 1 ]]; then
      unset IRONFOX_DOWNLOAD_EXIT
      return 1
    else
      echo_red_text 'ERROR: Download failed! Exiting...'
      exit 1
    fi
  fi
}

# Extract archives
function extract() {
  local readonly archive_path="$1"
  local readonly target_path="$2"
  local readonly temp_repo_name="$3"

  if [[ ! -f "${archive_path}" ]]; then
    echo_red_text "ERROR: Archive '${archive_path}' does not exist!"
  fi

  # If our temporary directory for extraction already exists, delete it
  if [[ -d "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}" ]]; then
    "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
  fi

  # Create temporary directory for extraction
  "${IRONFOX_MKDIR}" -p "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"

  # Extract based on file extension
  case "${archive_path}" in
    *.zip)
      "${IRONFOX_UNZIP}" -q "${archive_path}" -d "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
      ;;
    *.tar.gz)
      "${IRONFOX_TAR}" xzf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
      ;;
    *.tar.xz)
      "${IRONFOX_TAR}" xJf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
      ;;
    *.tar.zst)
      "${IRONFOX_TAR}" --zstd -xvf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
      ;;
    *)
      echo_red_text "ERROR: Unsupported archive format: ${archive_path}"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
      exit 1
      ;;
  esac

  local readonly top_input_dir=$("${IRONFOX_LS}" "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}")
  "${IRONFOX_CP}" -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}/${top_input_dir}/" "${target_path}"
  "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
}

function download_and_extract() {
  local readonly repo_name="$1"
  local readonly url="$2"
  local readonly path="$3"
  local readonly expected_sha512sum="$4"

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
    echo_red_text "'${path}' already exists"
    read -p "Do you want to re-download? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
      echo_red_text "Removing ${path}..."
      backup_dir "${path}"
    else
      IRONFOX_PERFORM_POST_DOWNLOAD=0
      return 0
    fi
  fi

  if [[ "${url}" =~ \.tar\.xz$ ]]; then
    local readonly extension=".tar.xz"
  elif [[ "${url}" =~ \.tar\.gz$ ]]; then
    local readonly extension=".tar.gz"
  elif [[ "${url}" =~ \.tar\.zst$ ]]; then
    local readonly extension=".tar.zst"
  else
    local readonly extension=".zip"
  fi

  # Tell `download` to return instead of exit upon an error
  IRONFOX_DOWNLOAD_EXIT=0

  # By default, we know the download hasn't failed...
  local IRONFOX_DOWNLOAD_FAILED=0

  local readonly repo_archive="${IRONFOX_DOWNLOADS}/${repo_name}${extension}"
  download "${url}" "${repo_archive}" "${expected_sha512sum}" || local IRONFOX_DOWNLOAD_FAILED=1

  # If we're just updating the checksum, we're done, so go ahead and exit
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      exit 1
    else
      return 0
    fi
  fi

  # If the download failed, restore our back-up (if possible) and exit
  if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
    restore_dir "${path}"
    if [[ "${repo_name}" == 'uv' ]]; then
      IRONFOX_PERFORM_POST_DOWNLOAD=0
      return 1
    else
      echo_red_text 'ERROR: Download failed! Exiting...'
      exit 1
    fi
  fi

  echo_red_text "Extracting ${repo_archive}..."
  extract "${repo_archive}" "${path}" "${repo_name}"

  # Clean-up
  "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/backup/${repo_name}"
}

# Get androguard
function get_androguard() {
  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download androguard, but you don't have a Python environment set-up yet."
      exit 1
    fi

    if [[ -d "${IRONFOX_ANDROGUARD}" ]]; then
      echo_red_text "androguard is already installed at ${IRONFOX_ANDROGUARD}"
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

  echo_red_text "Downloading androguard..."
  download_and_extract 'androguard' "https://github.com/androguard/androguard/archive/${ANDROGUARD_COMMIT}.tar.gz" "${IRONFOX_ANDROGUARD_DIR}" "${ANDROGUARD_SHA512SUM}"

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text 'Installing androguard...'
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_ANDROGUARD_DIR}"
    echo_green_text "SUCCESS: Set-up androguard at ${IRONFOX_ANDROGUARD}"
  fi
}

# Get Android NDK
function get_android_ndk() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading the Android NDK (Linux)...'
    download_and_extract 'android-ndk' "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip" "${IRONFOX_ANDROID_NDK}" "${ANDROID_NDK_SHA512SUM_LINUX}"

    echo_red_text 'Downloading the Android NDK (OS X)...'
    download_and_extract 'android-ndk' "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-darwin.zip" "${IRONFOX_ANDROID_NDK}" "${ANDROID_NDK_SHA512SUM_OSX}"
  else
    echo_red_text 'Downloading the Android NDK...'
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      download_and_extract 'android-ndk' "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-darwin.zip" "${IRONFOX_ANDROID_NDK}" "${ANDROID_NDK_SHA512SUM_OSX}"
    else
      download_and_extract 'android-ndk' "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip" "${IRONFOX_ANDROID_NDK}" "${ANDROID_NDK_SHA512SUM_LINUX}"
    fi
    echo_green_text "SUCCESS: Set-up Android NDK at ${IRONFOX_ANDROID_NDK}"
  fi
}

# Get + set-up Android SDK
function get_android_sdk() {
  # This is typically covered by "download_and_extract", but the Android SDK is a special case - we don't download it to IRONFOX_ANDROID_SDK directly
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ -d "${IRONFOX_ANDROID_SDK}" ]]; then
      echo_red_text "Found existing installation at ${IRONFOX_ANDROID_SDK}"
      echo 'Continuing will remove this installation and related data'
      read -p "Do you still want to continue? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
        echo_red_text "Removing ${IRONFOX_ANDROID_SDK}..."
        backup_dir "${IRONFOX_ANDROID_SDK}"
      else
        return 0
      fi
    fi
    "${IRONFOX_MKDIR}" -p "${IRONFOX_ANDROID_SDK}/cmdline-tools"
  fi

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android SDK (Linux)...'
    download "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/${ANDROID_SDK_VERSION}" "${ANDROID_SDK_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android SDK (OS X)...'
    download "https://dl.google.com/android/repository/commandlinetools-mac-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/${ANDROID_SDK_VERSION}" "${ANDROID_SDK_SHA512SUM_OSX}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly ANDROID_SDK_PLATFORM='mac'
    else
      local readonly ANDROID_SDK_PLATFORM='linux'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly ANDROID_SDK_SHA512SUM="${ANDROID_SDK_SHA512SUM_OSX}"
    else
      local readonly ANDROID_SDK_SHA512SUM="${ANDROID_SDK_SHA512SUM_LINUX}"
    fi

    echo_red_text 'Downloading Android SDK...'
    download_and_extract 'android-sdk-cmdline-tools' "https://dl.google.com/android/repository/commandlinetools-${ANDROID_SDK_PLATFORM}-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/${ANDROID_SDK_VERSION}" "${ANDROID_SDK_SHA512SUM}"

    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      # Accept Android SDK licenses
      { "${IRONFOX_YES}" || true; } | "${IRONFOX_ANDROID_SDK}/cmdline-tools/${ANDROID_SDK_VERSION}/bin/sdkmanager" --sdk_root="${IRONFOX_ANDROID_SDK}" --licenses

      echo_green_text "SUCCESS: Set-up Android SDK at ${IRONFOX_ANDROID_SDK}"
    fi
  fi
}

# Get Android SDK Build Tools (latest)
function get_android_sdk_build_tools() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android SDK Build Tools (latest) (Linux)...'
    download "https://dl.google.com/android/repository/build-tools_${ANDROID_SDK_BUILD_TOOLS_VERSION}_linux.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android SDK Build Tools (latest) (OS X)...'
    download "https://dl.google.com/android/repository/build-tools_${ANDROID_SDK_BUILD_TOOLS_VERSION}_macosx.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly ANDROID_SDK_BUILD_TOOLS_PLATFORM='macosx'
    else
      local readonly ANDROID_SDK_BUILD_TOOLS_PLATFORM='linux'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM="${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX}"
    else
      local readonly ANDROID_SDK_BUILD_TOOLS_SHA512SUM="${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX}"
    fi

    echo_red_text 'Downloading Android SDK Build Tools (latest)...'
    download_and_extract 'android-sdk-build-tools' "https://dl.google.com/android/repository/build-tools_${ANDROID_SDK_BUILD_TOOLS_VERSION}_${ANDROID_SDK_BUILD_TOOLS_PLATFORM}.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up Android SDK Build Tools (latest) at ${IRONFOX_ANDROID_SDK_BUILD_TOOLS}"
    fi
  fi
}

# Get Android SDK Build Tools (35)
## (Needed by Glean:
### https://github.com/mozilla/glean/blob/main/docs/dev/android/sdk-ndk-versions.md
### https://github.com/mozilla/glean/blob/main/docs/dev/android/setup-android-build-environment.md)
function get_android_sdk_build_tools_35() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android SDK Build Tools (35.0.0) (Linux)...'
    download "https://dl.google.com/android/repository/build-tools_r35_linux.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android SDK Build Tools (35.0.0) (OS X)...'
    download "https://dl.google.com/android/repository/build-tools_r35_macosx.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly ANDROID_SDK_BUILD_TOOLS_35_PLATFORM='macosx'
    else
      local readonly ANDROID_SDK_BUILD_TOOLS_35_PLATFORM='linux'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM="${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX}"
    else
      local readonly ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM="${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX}"
    fi

    echo_red_text 'Downloading Android SDK Build Tools (35.0.0)...'
    download_and_extract 'android-sdk-build-tools-35' "https://dl.google.com/android/repository/build-tools_r35_${ANDROID_SDK_BUILD_TOOLS_35_PLATFORM}.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up Android SDK Build Tools (35.0.0) at ${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}"
    fi
  fi
}

# Get Android SDK Platform (latest)
function get_android_sdk_platform() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text "ERROR: Unsupported project."
    exit 1
  else
    if [[ ! -d "${IRONFOX_ANDROID_SDK}" ]]; then
      echo_red_text "ERROR: You tried to download the Android SDK Platform (latest), but you don't have the Android SDK set-up yet."
      exit 1
    fi

    if [[ -d "${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}" ]]; then
      echo_red_text "Found existing installation at ${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}"
      echo 'Continuing will remove this installation and related data'
      read -p "Do you still want to continue? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
        echo_red_text "Removing ${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}..."
        backup_dir "${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}"
      else
        return 0
      fi
    fi

    # By default, we know the download hasn't failed...
    local IRONFOX_DOWNLOAD_FAILED=0

    echo_red_text 'Downloading Android SDK Platform (latest)...'
    "${IRONFOX_ANDROID_SDK}/cmdline-tools/${ANDROID_SDK_VERSION}/bin/sdkmanager" "platforms;android-${ANDROID_SDK_PLATFORM_VERSION}" || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-up, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      restore_dir "${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    else
      echo_green_text "SUCCESS: Set-up Android SDK Platform (latest) at ${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}"
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
    if [[ ! -d "${IRONFOX_ANDROID_SDK}" ]]; then
      echo_red_text "ERROR: You tried to download the Android SDK Platform (36), but you don't have the Android SDK set-up yet."
      exit 1
    fi

    if [[ -d "${IRONFOX_ANDROID_SDK}/platforms/android-36" ]]; then
      echo_red_text "Found existing installation at ${IRONFOX_ANDROID_SDK}/platforms/android-36"
      echo 'Continuing will remove this installation and related data'
      read -p "Do you still want to continue? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
        echo_red_text "Removing ${IRONFOX_ANDROID_SDK}/platforms/android-36..."
        backup_dir "${IRONFOX_ANDROID_SDK}/platforms/android-36"
      else
        return 0
      fi
    fi

    # By default, we know the download hasn't failed...
    local IRONFOX_DOWNLOAD_FAILED=0

    echo_red_text 'Downloading Android SDK Platform (36)...'
    "${IRONFOX_ANDROID_SDK}/cmdline-tools/${ANDROID_SDK_VERSION}/bin/sdkmanager" 'platforms;android-36' || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-up, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      restore_dir "${IRONFOX_ANDROID_SDK}/platforms/android-36"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    else
      echo_green_text "SUCCESS: Set-up Android SDK Platform (36) at ${IRONFOX_ANDROID_SDK}/platforms/android-36"
    fi
  fi
}

# Get Android SDK Platform Tools
function get_android_sdk_platform_tools() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Android SDK Platform Tools (Linux)...'
    download "https://dl.google.com/android/repository/platform-tools_r${ANDROID_SDK_PLATFORM_TOOLS_VERSION}-linux.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX}"

    echo_red_text 'Downloading Android SDK Platform Tools (OS X)...'
    download "https://dl.google.com/android/repository/platform-tools_r${ANDROID_SDK_PLATFORM_TOOLS_VERSION}-darwin.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly ANDROID_SDK_PLATFORM_TOOLS_PLATFORM='darwin'
    else
      local readonly ANDROID_SDK_PLATFORM_TOOLS_PLATFORM='linux'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM="${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX}"
    else
      local readonly ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM="${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX}"
    fi

    echo_red_text 'Downloading Android SDK Platform Tools...'
    download_and_extract 'android-sdk-platform-tools' "https://dl.google.com/android/repository/platform-tools_r${ANDROID_SDK_PLATFORM_TOOLS_VERSION}-${ANDROID_SDK_PLATFORM_TOOLS_PLATFORM}.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up Android SDK Platform Tools at ${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}"
    fi
  fi
}

# Get Application Services
function get_as() {
  echo_red_text 'Downloading Application Services...'
  download_and_extract 'application-services' "https://github.com/mozilla/application-services/archive/${APPSERVICES_COMMIT}.tar.gz" "${IRONFOX_AS}" "${APPSERVICES_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Application Services at ${IRONFOX_AS}"
  fi
}

# Get + set-up Bundletool
function get_bundletool() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Bundletool (Source archive)...'
    download_and_extract 'bundletool' "https://github.com/google/bundletool/archive/${BUNDLETOOL_REPO_COMMIT}.tar.gz" "${IRONFOX_BUNDLETOOL_DIR}" "${BUNDLETOOL_REPO_SHA512SUM}"

    echo_red_text 'Downloading Bundletool (Prebuilt)...'
    download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}" "${BUNDLETOOL_SHA512SUM}"
  else
    echo_red_text 'Downloading Bundletool...'
    if [[ "${IRONFOX_NO_PREBUILDS}" == "1" ]]; then
      download_and_extract 'bundletool' "https://github.com/google/bundletool/archive/${BUNDLETOOL_REPO_COMMIT}.tar.gz" "${IRONFOX_BUNDLETOOL_DIR}" "${BUNDLETOOL_REPO_SHA512SUM}"
    else
      download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}" "${BUNDLETOOL_SHA512SUM}"
    fi

    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up Bundletool at ${IRONFOX_BUNDLETOOL_DIR}"
    fi
  fi
}

# Get cbindgen
function get_cbindgen() {
  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ ! -d "${IRONFOX_CARGO_HOME}" ]] || [[ ! -f "${IRONFOX_CARGO_ENV}" ]]; then
      echo_red_text "ERROR: You tried to download cbindgen, but you don't have a Rust environment set-up yet."
      exit 1
    fi

    if [[ -d "${IRONFOX_CARGO_HOME}/bin/cbindgen" ]]; then
      echo_red_text "cbindgen is already installed at ${IRONFOX_CARGO_HOME}/bin/cbindgen."
      read -p "Do you want to re-download it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
        return 0
      fi
    fi
  fi

  echo_red_text "Downloading cbindgen..."
  download_and_extract 'cbindgen' "https://github.com/mozilla/cbindgen/archive/${CBINDGEN_COMMIT}.tar.gz" "${IRONFOX_CBINDGEN_DIR}" "${CBINDGEN_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_CARGO_ENV}"
    echo_red_text 'Installing cbindgen...'
    "${IRONFOX_CARGO}" +"${RUST_VERSION}" install --locked --force --vers "${CBINDGEN_VERSION}" --path "${IRONFOX_CBINDGEN_DIR}" cbindgen
    echo_green_text "SUCCESS: Set-up cbindgen at ${IRONFOX_CARGO_HOME}/bin/cbindgen"
  fi
}

# Get Firefox (Gecko/mozilla-central)
function get_firefox() {
  echo_red_text 'Downloading Firefox...'
  download_and_extract 'gecko' "https://github.com/mozilla-firefox/firefox/archive/${FIREFOX_COMMIT}.tar.gz" "${IRONFOX_GECKO}" "${FIREFOX_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Firefox at ${IRONFOX_GECKO}"
  fi
}

# Get firefox-l10n
function get_firefox_l10n() {
  echo_red_text 'Downloading firefox-l10n...'
  download_and_extract 'l10n-central' "https://github.com/mozilla-l10n/firefox-l10n/archive/${L10N_COMMIT}.tar.gz" "${IRONFOX_L10N_CENTRAL}" "${L10N_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up firefox-l10n at ${IRONFOX_L10N_CENTRAL}"
  fi
}

# Get Glean
function get_glean() {
  echo_red_text 'Downloading Glean...'
  download_and_extract 'glean' "https://github.com/mozilla/glean/archive/${GLEAN_COMMIT}.tar.gz" "${IRONFOX_GLEAN}" "${GLEAN_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Glean at ${IRONFOX_GLEAN}"
  fi
}

# Get Glean Parser
function get_glean_parser() {
  if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
    echo_red_text "ERROR: You tried to download Glean Parser, but you don't have a Python environment set-up yet."
    exit 1
  fi

  if [[ ! -d "${IRONFOX_PIP_DIR}" ]]; then
    echo_red_text "ERROR: You tried to download Glean Parser, but you don't have pip set-up yet."
    exit 1
  fi

  # Set our Glean Parser wheels directory
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    local readonly glean_parser_wheels="${IRONFOX_EXTERNAL}/temp/chksm/glean_parser-wheels"
  else
    local readonly glean_parser_wheels="${IRONFOX_GLEAN_PARSER_WHEELS}"
  fi

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]] && [[ -d "${IRONFOX_PYENV_DIR}/bin/glean_parser" ]]; then
    echo_red_text "Glean Parser is already installed at ${IRONFOX_PYENV_DIR}/bin/glean_parser"
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
  "${IRONFOX_PIP}" download glean-parser=="${GLEAN_PARSER_VERSION}"
  popd

  # Validate SHA512sum
  validate_checksum "${GLEAN_PARSER_SHA512SUM}" "${IRONFOX_GLEAN_PARSER_WHEELS}/glean_parser-${GLEAN_PARSER_VERSION}-py3-none-any.whl" 'sha512sum'

  # Clean-up
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp/chksm"
  fi
}

# Get + set-up F-Droid's Gradle script
function get_gradle() {
  echo_red_text "Downloading F-Droid's Gradle script..."
  download "https://gitlab.com/fdroid/gradlew-fdroid/-/raw/${GRADLE_COMMIT}/gradlew.py" "${IRONFOX_GRADLE_PY}" "${GRADLE_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Gradle at ${IRONFOX_GRADLE_PY}"
  fi
}

# Get GYP
function get_gyp() {
  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download GYP, but you don't have a Python environment set-up yet."
      exit 1
    fi

    if [[ -d "${IRONFOX_PYENV_DIR}/bin/gyp" ]]; then
      echo_red_text "GYP is already installed at ${IRONFOX_PYENV_DIR}/bin/gyp"
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

  echo_red_text "Downloading GYP..."
  download_and_extract 'gyp-next' "https://github.com/nodejs/gyp-next/archive/${GYP_COMMIT}.tar.gz" "${IRONFOX_GYP}" "${GYP_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text 'Installing GYP...'
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_GYP}"
    echo_green_text "SUCCESS: Set-up GYP at ${IRONFOX_PYENV_DIR}/bin/gyp"
  fi
}

# Get JDK (17)
## (Required by GeckoView)
function get_jdk_17() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading JDK (17) (Linux - ARM64)...'
    download "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_aarch64_linux_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading JDK (17) (Linux - x86_64)...'
    download "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_x64_linux_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading JDK (17) (OS X - ARM64)...'
    download "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_aarch64_mac_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading JDK (17) (OS X - x86_64)...'
    download "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_x64_mac_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly JDK_17_PLATFORM='mac'
    else
      local readonly JDK_17_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local readonly JDK_17_ARCH='aarch64'
    else
      local readonly JDK_17_ARCH='x64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly JDK_17_SHA512SUM="${JDK_17_SHA512SUM_OSX_ARM64}"
      else
        local readonly JDK_17_SHA512SUM="${JDK_17_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly JDK_17_SHA512SUM="${JDK_17_SHA512SUM_OSX_X86_64}"
      else
        local readonly JDK_17_SHA512SUM="${JDK_17_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    echo_red_text 'Downloading JDK (17)...'
    download_and_extract 'jdk-17' "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_${JDK_17_ARCH}_${JDK_17_PLATFORM}_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up JDK (17) at ${IRONFOX_JDK_17}"
    fi
  fi
}

# Get JDK (21)
function get_jdk_21() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading JDK (21) (Linux - ARM64)...'
    download "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_aarch64_linux_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading JDK (21) (Linux - x86_64)...'
    download "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_x64_linux_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM_LINUX_X86_64}"
 
    echo_red_text 'Downloading JDK (21) (OS X - ARM64)...'
    download "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_aarch64_mac_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading JDK (21) (OS X - x86_64)...'
    download "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_x64_mac_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly JDK_21_PLATFORM='mac'
    else
      local readonly JDK_21_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local readonly JDK_21_ARCH='aarch64'
    else
      local readonly JDK_21_ARCH='x64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly JDK_21_SHA512SUM="${JDK_21_SHA512SUM_OSX_ARM64}"
      else
        local readonly JDK_21_SHA512SUM="${JDK_21_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly JDK_21_SHA512SUM="${JDK_21_SHA512SUM_OSX_X86_64}"
      else
        local readonly JDK_21_SHA512SUM="${JDK_21_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    echo_red_text 'Downloading JDK (21)...'
    download_and_extract 'jdk-21' "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_${JDK_21_ARCH}_${JDK_21_PLATFORM}_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up JDK (21) at ${IRONFOX_JDK_21}"
    fi
  fi
}

# Get JDK (25)
function get_jdk_25() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading JDK (25) (Linux - ARM64)...'
    download "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_aarch64_linux_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading JDK (25) (Linux - x86_64)...'
    download "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_x64_linux_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading JDK (25) (OS X - ARM64)...'
    download "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_aarch64_mac_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading JDK (25) (OS X - x86_64)...'
    download "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_x64_mac_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly JDK_25_PLATFORM='mac'
    else
      local readonly JDK_25_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local readonly JDK_25_ARCH='aarch64'
    else
      local readonly JDK_25_ARCH='x64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly JDK_25_SHA512SUM="${JDK_25_SHA512SUM_OSX_ARM64}"
      else
        local readonly JDK_25_SHA512SUM="${JDK_25_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly JDK_25_SHA512SUM="${JDK_25_SHA512SUM_OSX_X86_64}"
      else
        local readonly JDK_25_SHA512SUM="${JDK_25_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    echo_red_text 'Downloading JDK (25)...'
    download_and_extract 'jdk-25' "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_${JDK_25_ARCH}_${JDK_25_PLATFORM}_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM}"
    if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up JDK (25) at ${IRONFOX_JDK_25}"
    fi
  fi
}

# Get microG
function get_microg() {
  echo_red_text 'Downloading microG...'
  download_and_extract 'gmscore' "https://github.com/microg/GmsCore/archive/${GMSCORE_COMMIT}.tar.gz" "${IRONFOX_GMSCORE}" "${GMSCORE_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up microG at ${IRONFOX_GMSCORE}"
  fi
}

# Get + set-up Node.js
function get_node() {
  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ -d "${IRONFOX_NVM}" ]]; then
      echo_red_text "The Node.js environment is already set-up at ${IRONFOX_NVM}"
      read -p "Do you want to re-create it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        "${IRONFOX_RM}" -rf "${IRONFOX_NPM_CACHE}" "${IRONFOX_NVM}" "${IRONFOX_ROOT}/node_modules"
      fi
    fi
  fi

  download_and_extract 'nvm' "https://github.com/nvm-sh/nvm/archive/${NVM_COMMIT}.tar.gz" "${IRONFOX_NVM}" "${NVM_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_red_text 'Installing Node.js...'
    source "${IRONFOX_NVM_ENV}"
    nvm install "${NODE_VERSION}"
    nvm alias default "${NODE_VERSION}"
    nvm use "${NODE_VERSION}"
    echo_green_text "SUCCESS: Set-up Node.js environment at ${IRONFOX_NVM}"
  fi
}

# Get npm
function get_npm() {
  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]] && [[ ! -d "${IRONFOX_NVM}" ]]; then
    echo_red_text "ERROR: You tried to download npm, but you don't have a Node.js environment set-up yet."
    exit 1
  fi

  echo_red_text 'Downloading npm...'
  download "https://registry.npmjs.org/npm/-/npm-${NPM_VERSION}.tgz" "${IRONFOX_DOWNLOADS}/npm.tgz" "${NPM_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_red_text 'Installing npm...'
    source "${IRONFOX_NVM_ENV}"
    "${IRONFOX_NPM}" install -g npm@file:"${IRONFOX_DOWNLOADS}/npm.tgz"
    echo_green_text "SUCCESS: Set-up npm at ${IRONFOX_NPM}"
  fi
}

# Get Phoenix
function get_phoenix() {
  echo_red_text 'Downloading Phoenix...'
  download_and_extract 'phoenix' "https://gitlab.com/celenityy/Phoenix/-/archive/${IRONFOX_PHOENIX_COMMIT}/Phoenix-${IRONFOX_PHOENIX_COMMIT}.tar.gz" "${IRONFOX_PHOENIX}" "${IRONFOX_PHOENIX_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up Phoenix at ${IRONFOX_PHOENIX}"
  fi
}

# Get + set-up pip
function get_pip() {
  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download pip, but you don't have a Python environment set-up yet."
      exit 1
    fi
  fi

  echo_red_text 'Downloading pip...'
  download_and_extract 'pip' "https://github.com/pypa/pip/archive/${PIP_COMMIT}.tar.gz" "${IRONFOX_PIP_DIR}" "${PIP_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text 'Installing pip...'
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_PIP_DIR}"
    echo_green_text "SUCCESS: Set-up pip at ${IRONFOX_PIP}"
  fi
}

# Get the IronFox prebuilds repo
function get_prebuilds() {
  echo_red_text 'Downloading the IronFox prebuilds repository...'
  download_and_extract 'prebuilds' "https://gitlab.com/ironfox-oss/prebuilds/-/archive/${PREBUILDS_COMMIT}/prebuilds-${PREBUILDS_COMMIT}.tar.gz" "${IRONFOX_PREBUILDS}" "${PREBUILDS_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    pushd "${IRONFOX_PREBUILDS}"
    echo_red_text 'Downloading prebuild sources...'
    /bin/bash "${IRONFOX_PREBUILDS}/scripts/get_sources.sh"
    popd
    echo_green_text "SUCCESS: Set-up the IronFox prebuilds repository at ${IRONFOX_PREBUILDS}"
  fi
}

# Get Python
function get_python() {
  # If all we're doing is updating the checksum, we don't care about existing installations
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ ! -x "${IRONFOX_UV}" ]]; then
      echo_red_text "ERROR: You tried to download Python, but you're missing uv!"
      exit 1
    fi

    if [[ -d "${IRONFOX_PYENV_DIR}" ]]; then
      echo_red_text "The Python environment is already set-up at ${IRONFOX_PYENV_DIR}"
      read -p "Do you want to re-create it? [y/N] " -n 1 -r
      echo
      if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        # Back-up (in case something goes wrong - ex. checksum validation fails) and remove our directory
        backup_dir "${IRONFOX_PYENV_DIR}"
      fi
    fi

    if [[ -d "${IRONFOX_PYTHON_DIR}" ]]; then
      echo_red_text "Found existing installation at ${IRONFOX_PYTHON_DIR}"
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

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading Python (Linux - ARM64)...'
    download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz" "${PYTHON_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading Python (Linux - x86_64)...'
    download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz" "${PYTHON_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading Python (OS X - ARM64)...'
    download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-apple-darwin-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-apple-darwin-install_only_stripped.tar.gz" "${PYTHON_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading Python (OS X - x86_64)...'
    download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-apple-darwin-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-apple-darwin-install_only_stripped.tar.gz" "${PYTHON_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly PYTHON_PLATFORM='apple-darwin'
    else
      local readonly PYTHON_PLATFORM='unknown-linux-gnu'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local readonly PYTHON_ARCH='aarch64'
    else
      local readonly PYTHON_ARCH='x86_64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly PYTHON_SHA512SUM="${PYTHON_SHA512SUM_OSX_ARM64}"
      else
        local readonly PYTHON_SHA512SUM="${PYTHON_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly PYTHON_SHA512SUM="${PYTHON_SHA512SUM_OSX_X86_64}"
      else
        local readonly PYTHON_SHA512SUM="${PYTHON_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    # Tell `download` to return instead of exit upon an error
    IRONFOX_DOWNLOAD_EXIT=0

    # By default, we know nothing has failed...
    local IRONFOX_DOWNLOAD_FAILED=0
    local IRONFOX_PYENV_FAILED=0
    local IRONFOX_PYTHON_INSTALL_FAILED=0

    echo_red_text 'Downloading Python...'
    download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-${PYTHON_ARCH}-${PYTHON_PLATFORM}-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-${PYTHON_ARCH}-${PYTHON_PLATFORM}-install_only_stripped.tar.gz" "${PYTHON_SHA512SUM}" || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-ups, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      restore_dir "${IRONFOX_PYENV_DIR}"
      restore_dir "${IRONFOX_PYTHON_DIR}"
      restore_dir "${IRONFOX_UV_CACHE}"
      restore_dir "${IRONFOX_UV_PYTHON}"
      restore_dir "${IRONFOX_UV_LOCAL}/python-cache"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    elif [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Downloaded Python to ${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-${PYTHON_ARCH}-${PYTHON_PLATFORM}-install_only_stripped.tar.gz"

      echo_red_text 'Installing Python...'
      "${IRONFOX_UV}" python install "${PYTHON_VERSION}" || local IRONFOX_PYTHON_INSTALL_FAILED=1

      # If the install failed, restore our back-ups, clean-up, and exit
      if [[ "${IRONFOX_PYTHON_INSTALL_FAILED}" == 1 ]]; then
        echo_red_text 'ERROR: Installation failed! Exiting...'
        restore_dir "${IRONFOX_PYENV_DIR}"
        restore_dir "${IRONFOX_PYTHON_DIR}"
        restore_dir "${IRONFOX_UV_CACHE}"
        restore_dir "${IRONFOX_UV_PYTHON}"
        restore_dir "${IRONFOX_UV_LOCAL}/python-cache"
        "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
        exit 1
      fi

      echo_red_text 'Creating Python environment...'
      "${IRONFOX_UV}" venv "${IRONFOX_PYENV_DIR}" || local IRONFOX_PYENV_FAILED=1

      # If the Python env set-up failed, restore our back-up, clean-up, and exit
      if [[ "${IRONFOX_PYENV_FAILED}" == 1 ]]; then
        echo_red_text 'ERROR: Environment set-up failed! Exiting...'
        restore_dir "${IRONFOX_PYENV_DIR}"
        "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
        exit 1
      else
        echo_green_text "SUCCESS: Set-up Python environment at ${IRONFOX_PYENV_DIR}"
      fi
    fi
  fi
}

# Get PyYAML
function get_pyyaml() {
  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download PyYAML, but you don't have a Python environment set-up yet."
      exit 1
    fi

    if [[ -d "${IRONFOX_PYYAML}" ]]; then
      echo_red_text "PyYAML is already downloaded at ${IRONFOX_PYYAML}"
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

  echo_red_text "Downloading PyYAML..."
  download_and_extract 'pyyaml' "https://github.com/yaml/pyyaml/archive/${PYYAML_COMMIT}.tar.gz" "${IRONFOX_PYYAML}" "${PYYAML_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text 'Installing PyYAML...'
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_PYYAML}"
    echo_green_text 'SUCCESS: Set-up PyYAML'
  fi
}

# Get + set-up rust/cargo
function get_rust() {
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]] && [[ -d "${IRONFOX_CARGO_HOME}" ]]; then
    echo_red_text "Found existing installation at ${IRONFOX_CARGO_HOME}"
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

  echo_red_text 'Downloading Rust...'
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    download "https://raw.githubusercontent.com/rust-lang/rustup/${RUSTUP_COMMIT}/rustup-init.sh" "${IRONFOX_DOWNLOADS}/rustup-init.sh" "${RUSTUP_SHA512SUM}"
  else
    # Tell `download` to return instead of exit upon an error
    IRONFOX_DOWNLOAD_EXIT=0

    # By default, we know nothing has failed...
    local IRONFOX_CARGO_ENV_FAILED=0
    local IRONFOX_CARGO_INSTALL_FAILED=0
    local IRONFOX_DOWNLOAD_FAILED=0

    download "https://raw.githubusercontent.com/rust-lang/rustup/${RUSTUP_COMMIT}/rustup-init.sh" "${IRONFOX_DOWNLOADS}/rustup-init.sh" "${RUSTUP_SHA512SUM}" || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-up, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      restore_dir "${IRONFOX_CARGO_HOME}"
      restore_dir "${IRONFOX_RUSTUP_HOME}"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    elif [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_red_text 'Installing Rust...'
      /bin/bash -x "${IRONFOX_DOWNLOADS}/rustup-init.sh" -y --no-modify-path --no-update-default-toolchain --profile=minimal || local IRONFOX_CARGO_INSTALL_FAILED=1

      # If the install failed, restore our back-ups, clean-up, and exit
      if [[ "${IRONFOX_CARGO_INSTALL_FAILED}" == 1 ]]; then
        echo_red_text 'ERROR: Installation failed! Exiting...'
        restore_dir "${IRONFOX_CARGO_HOME}"
        restore_dir "${IRONFOX_RUSTUP_HOME}"
        "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
        exit 1
      fi

      # Source the newly created Rust environment
      source "${IRONFOX_CARGO_ENV}" || local IRONFOX_CARGO_ENV_FAILED=1

      # If we couldn't source our environment, restore our back-ups, clean-up, and exit
      if [[ "${IRONFOX_CARGO_ENV_FAILED}" == 1 ]]; then
        echo_red_text 'ERROR: Could not source environment! Exiting...'
        restore_dir "${IRONFOX_CARGO_HOME}"
        restore_dir "${IRONFOX_RUSTUP_HOME}"
        "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
        exit 1
      fi

      # Set-up Rust
      rustup set profile minimal
      rustup default "${RUST_VERSION}"
      rustup override set "${RUST_VERSION}"
      rustup target add aarch64-linux-android
      rustup target add armv7-linux-androideabi
      rustup target add thumbv7neon-linux-androideabi
      rustup target add x86_64-linux-android

      echo_green_text "SUCCESS: Set-up Rust at ${IRONFOX_CARGO_HOME}"
    fi
  fi
}

# Get s3cmd
function get_s3cmd() {
  # If all we're doing is updating the checksum, we don't care if the environment is prepared
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]]; then
    if [[ ! -d "${IRONFOX_UV_DIR}" ]] || [[ ! -f "${IRONFOX_PYENV}" ]]; then
      echo_red_text "ERROR: You tried to download s3cmd, but you don't have a Python environment set-up yet."
      exit 1
    fi

    if [[ -d "${IRONFOX_S3CMD}" ]]; then
      echo_red_text "s3cmd is already installed at ${IRONFOX_S3CMD}"
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

  echo_red_text "Downloading s3cmd..."
  download_and_extract 's3cmd' "https://github.com/s3tools/s3cmd/archive/${S3CMD_COMMIT}.tar.gz" "${IRONFOX_S3CMD_DIR}" "${S3CMD_SHA512SUM}"

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    source "${IRONFOX_PYENV}"
    echo_red_text 'Installing s3cmd...'
    "${IRONFOX_UV}" pip install --no-editable --strict "${IRONFOX_S3CMD_DIR}"
    echo_green_text "SUCCESS: Set-up s3cmd at ${IRONFOX_S3CMD}"
  fi
}

# Get Tor's no-op UniFFi binding generator
function get_uniffi() {
  # Get uniffi-bindgen for Linux
  if [[ "${IRONFOX_PLATFORM}" == 'linux' ]] || [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading prebuilt uniffi-bindgen (Linux)...'
    download_and_extract 'uniffi' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${PREBUILDS_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/linux/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_IRONFOX_REVISION}-linux.tar.xz" "${IRONFOX_UNIFFI}" "${UNIFFI_LINUX_IRONFOX_SHA512SUM}"
  fi

  # Get uniffi-bindgen for OS X
  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]] || [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading prebuilt uniffi-bindgen (OS X)...'
    download_and_extract 'uniffi' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${PREBUILDS_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/osx/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_IRONFOX_REVISION}-osx.tar.xz" "${IRONFOX_UNIFFI}" "${UNIFFI_OSX_IRONFOX_SHA512SUM}"
  fi

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up the prebuilt uniffi-bindgen at ${IRONFOX_UNIFFI}"
  fi
}

# Get UnifiedPush-AC
function get_up_ac() {
  echo_red_text 'Downloading UnifiedPush-AC...'
  download_and_extract 'unifiedpush-ac' "https://gitlab.com/ironfox-oss/unifiedpush-ac/-/archive/${UNIFIEDPUSHAC_COMMIT}/unifiedpush-ac-${UNIFIEDPUSHAC_COMMIT}.tar.gz" "${IRONFOX_UP_AC}" "${UNIFIEDPUSHAC_SHA512SUM}"
  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up UnifiedPush-AC at ${IRONFOX_UP_AC}"
  fi
}

# Get + set-up uv
function get_uv() {
  # If all we're doing is updating the checksum, we don't care about existing installations
  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]] && [[ -d "${IRONFOX_UV_DIR}" ]]; then
    echo_red_text "Found existing installation at ${IRONFOX_UV_DIR}"
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

  if [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading uv (Linux - ARM64)...'
    download "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-aarch64-unknown-linux-gnu.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM_LINUX_ARM64}"

    echo_red_text 'Downloading uv (Linux - x86_64)...'
    download "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM_LINUX_X86_64}"

    echo_red_text 'Downloading uv (OS X - ARM64)...'
    download "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-aarch64-apple-darwin.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM_OSX_ARM64}"

    echo_red_text 'Downloading uv (OS X - x86_64)...'
    download "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-apple-darwin.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM_OSX_X86_64}"
  else
    # Set our platform
    if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
      local readonly UV_PLATFORM='apple-darwin'
    else
      local readonly UV_PLATFORM='unknown-linux-gnu'
    fi

    # Set our platform architecture
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      local readonly UV_ARCH='aarch64'
    else
      local readonly UV_ARCH='x86_64'
    fi

    # Set our checksum to verify
    if [[ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]]; then
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly UV_SHA512SUM="${UV_SHA512SUM_OSX_ARM64}"
      else
        local readonly UV_SHA512SUM="${UV_SHA512SUM_LINUX_ARM64}"
      fi
    else
      if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
        local readonly UV_SHA512SUM="${UV_SHA512SUM_OSX_X86_64}"
      else
        local readonly UV_SHA512SUM="${UV_SHA512SUM_LINUX_X86_64}"
      fi
    fi

    # Tell `download` to return instead of exit upon an error
    IRONFOX_DOWNLOAD_EXIT=0

    # By default, we know the download hasn't failed...
    local IRONFOX_DOWNLOAD_FAILED=0

    echo_red_text 'Downloading uv...'
    download_and_extract 'uv' "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${UV_ARCH}-${UV_PLATFORM}.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM}" || local IRONFOX_DOWNLOAD_FAILED=1

    # If the download failed, restore our back-up, clean-up, and exit
    if [[ "${IRONFOX_DOWNLOAD_FAILED}" == 1 ]]; then
      echo_red_text 'ERROR: Download failed! Exiting...'
      restore_dir "${IRONFOX_UV_DIR}"
      restore_dir "${IRONFOX_UV_LOCAL}"
      "${IRONFOX_RM}" -rf "${IRONFOX_EXTERNAL}/temp"
      exit 1
    elif [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
      echo_green_text "SUCCESS: Set-up uv at ${IRONFOX_UV}"
    fi
  fi
}

# Get WebAssembly SDK
function get_wasi() {
  # Get WASI SDK for Linux
  if [[ "${IRONFOX_PLATFORM}" == 'linux' ]] || [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading prebuilt WASI SDK (Linux)...'
    download_and_extract 'wasi-sdk' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${PREBUILDS_COMMIT}/wasi-sdk/${WASI_VERSION}/linux/wasi-sdk-${WASI_VERSION}-${WASI_IRONFOX_REVISION}-linux.tar.xz" "${IRONFOX_WASI}" "${WASI_LINUX_IRONFOX_SHA512SUM}"
  fi

  # Get WASI SDK for OS X
  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]] || [[ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]]; then
    echo_red_text 'Downloading prebuilt WASI SDK (OS X)...'
    download_and_extract 'wasi-sdk' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${PREBUILDS_COMMIT}/wasi-sdk/${WASI_VERSION}/osx/wasi-sdk-${WASI_VERSION}-${WASI_IRONFOX_REVISION}-osx.tar.xz" "${IRONFOX_WASI}" "${WASI_OSX_IRONFOX_SHA512SUM}"
  fi

  if [[ "${IRONFOX_PERFORM_POST_DOWNLOAD}" == 1 ]]; then
    echo_green_text "SUCCESS: Set-up the prebuilt WASI SDK at ${IRONFOX_WASI}"
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

if [[ "${IRONFOX_GET_SOURCE_UNIFFI}" == 1 ]]; then
  get_uniffi
fi

if [[ "${IRONFOX_GET_SOURCE_UP_AC}" == 1 ]]; then
  get_up_ac
fi

if [[ "${IRONFOX_GET_SOURCE_WASI}" == 1 ]]; then
  get_wasi
fi
