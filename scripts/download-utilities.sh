#!/bin/bash

set -euo pipefail

# Download utility functions

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash $(dirname $0)/env.sh || exit 1
fi
source $(dirname $0)/env.sh || exit 1

# Include utilities
source "${IRONFOX_UTILS}" || exit 1

# Download a file
function download() {
  function print_usage() {
    echo "Usage: download 'https://totally.legit.url/file' 'path/to/file'"
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

  # Ensure we have basename
  verify_exec "${IRONFOX_BASENAME}" 'IRONFOX_BASENAME' || exit 1

  # Ensure we have curl
  verify_exec "${IRONFOX_CURL}" 'IRONFOX_CURL' || exit 1

  # Ensure we have dirname
  verify_exec "${IRONFOX_DIRNAME}" 'IRONFOX_DIRNAME' || exit 1

  # Ensure we have mkdir
  verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  # Ensure we have our curl flags
  if [[ -z "${IRONFOX_CURL_FLAGS+x}" ]] || [[ "${IRONFOX_CURL_FLAGS}" == "" ]]; then
    echo_red_text "ERROR: 'IRONFOX_CURL_FLAGS' is missing!"
    exit 1
  fi

  local -r url="$1"
  local -r output_file="$2"
  local -r file_name=$("${IRONFOX_BASENAME}" "${output_file}")
  local -r file_dir=$("${IRONFOX_DIRNAME}" "${output_file}")

  # Ensure the URL is valid
  if [[ "${url}" == "" ]]; then
    echo_red_text "ERROR: URL is required (file: '${output_file}')!"
    exit 1
  fi

  # Enforce HTTPS
  case "${url}" in
    https://*) ;;
    *)
      echo_red_text "ERROR: URL must use HTTPS (URL: '${url}')!"
      exit 1
      ;;
  esac

  # Check if the file already exists
  if [[ -f "${output_file}" ]]; then
    echo_red_text "File already exists: '${output_file}'!"
    read -p "Do you want to re-download? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      echo_red_text "Removing file: '${output_file}'..."
      "${IRONFOX_RM}" -f "${output_file}"
      echo_green_text "SUCCESS: Removed file: '${output_file}'!"
    else
      return 0
    fi
  fi

  # By default, we know the download has not failed...
  local download_failed=0

  # If necessary, create the target file directory
  if [[ ! -d "${file_dir}" ]]; then
    "${IRONFOX_MKDIR}" -vp "${file_dir}"
    local -r created_dl_dir=1
  else
    local -r created_dl_dir=0
  fi

  echo_red_text "Downloading file: '${file_name}' from URL: '${url}' to destination: '${output_file}'..."
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "${url}" --output "${output_file}" || local download_failed=1

  # Ensure the file we just downloaded is valid
  if [[ "${download_failed}" != 1 ]]; then
    verify_file "${output_file}" || local download_failed=1
  fi

  # If the download failed, clean-up and return
  if [[ "${download_failed}" == 1 ]]; then
    # If a directory was created just for this download, remove it
    if [[ "${created_dl_dir}" == 1 ]]; then
      "${IRONFOX_RM}" -rf "${file_dir}"
    fi
    echo_red_text "ERROR: Unable to download file: '${file_name}' from URL: '${url}' to destination: '${output_file}'!"
    return 1
  else
    echo_green_text "SUCCESS: Downloaded file: '${file_name}' from URL: '${url}' to destination: '${output_file}'!"
  fi
}

# Clone a git repository
function clone_git_repo() {
  function print_usage() {
    echo "Usage: clone_git_repo 'https://totally.legit.url/repo.git' 'path/to/repo' 'revision'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please provide the URL for the repo to clone!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please provide the output directory!'
    print_usage
    exit 1
  fi

  if [[ -z "${3+x}" ]]; then
    echo_red_text 'ERROR: Please specify the revision to clone the repo at!'
    print_usage
    exit 1
  fi

  # Ensure we have git
  verify_exec "${IRONFOX_GIT}" 'IRONFOX_GIT' || exit 1

  # Ensure we have rm
  verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

  local url="$1"
  local -r path="$2"
  local -r revision="$3"

  # Handle additional arguments
  local depth=1
  local silent=0
  local submodules=0

  if [[ -n "${4+x}" ]]; then
    if [[ "${4}" == '--silent' ]]; then
      local silent=1
    elif [[ "${4}" == '--submodules' ]]; then
      local submodules=1
    elif [[ "${4}" == '--depth' ]]; then
      if [[ -n "${5+x}" ]] && [[ "${5}" != "" ]]; then
        local depth="$5"
      else
        echo_red_text "ERROR: Missing value for '--depth'!"
        exit 1
      fi
    else
      echo_red_text "ERROR: Unknown argument: '$4'!"
      exit 1
    fi
  fi

  if [[ -n "${5+x}" ]] && [[ "${4}" != '--depth' ]]; then
    if [[ "${5}" == '--silent' ]]; then
      local silent=1
    elif [[ "${5}" == '--submodules' ]]; then
      local submodules=1
    elif [[ "${5}" == '--depth' ]]; then
      if [[ -n "${6+x}" ]] && [[ "${6}" != "" ]]; then
        local depth="$6"
      else
        echo_red_text "ERROR: Missing value for '--depth'!"
        exit 1
      fi
    else
      echo_red_text "ERROR: Unknown argument: '$5'!"
      exit 1
    fi
  fi

  if [[ -n "${6+x}" ]] && [[ "${5}" != '--depth' ]]; then
    if [[ "${6}" == '--silent' ]]; then
      local silent=1
    elif [[ "${6}" == '--submodules' ]]; then
      local submodules=1
    else
      echo_red_text "ERROR: Unknown argument: '$6'!"
      exit 1
    fi
  fi

  if [[ -n "${7+x}" ]] && [[ "${6}" != '--depth' ]]; then
    if [[ "${7}" == '--silent' ]]; then
      local silent=1
    elif [[ "${7}" == '--submodules' ]]; then
      local submodules=1
    else
      echo_red_text "ERROR: Unknown argument: '$7'!"
      exit 1
    fi
  fi

  # Ensure the URL is valid
  if [[ "${url}" == "" ]]; then
    echo_red_text "ERROR: Missing URL for repo to clone!"
    exit 1
  fi

  # Ensure the URL scheme is HTTPS or SSH
  case "${url}" in
    https://* | ssh://*) ;;
    *)
      echo_red_text "ERROR: URL must use HTTPS or SSH (URL: '${url}')!"
      exit 1
      ;;
  esac

  # If .git is missing from the end of the URL, add it
  case "${url}" in
    *.git)
      local -r url="${url}"
      ;;
    *)
      local -r url="${url}.git"
      ;;
  esac

  # Ensure the target path is valid
  if [[ "${path}" == "" ]]; then
    echo_red_text "ERROR: Path is required for cloning '${url}'!"
    exit 1
  fi

  # Ensure the revision is valid
  if [[ "${revision}" == "" ]]; then
    echo_red_text "ERROR: Revision is required for cloning '${url}'!"
    exit 1
  fi

  # Ensure the target path doesn't already exist as a file
  if [[ -f "${path}" ]]; then
    echo_red_text "ERROR: Path exists and is not a directory: '${path}'!"
    exit 1
  fi

  # Check if the target directory already exists
  if [[ -d "${path}" ]]; then
    echo_red_text "Path already exists: '${path}'!"
    read -p "Do you want to re-clone this repository? [y/N] " -n 1 -r
    echo
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      echo_red_text "Removing path: '${path}'..."
      "${IRONFOX_RM}" -rf "${path}"
      echo_green_text "SUCCESS: Removed path: '${path}'!"
    else
      return 0
    fi
  fi

  # By default, we know the clone has not failed...
  local clone_failed=0

  # Set the URL to display
  if [[ "${silent}" == 1 ]]; then
    ## (If we're in silent mode, we do not display the URL to ensure we don't ex. leak secrets from CI)
    local -r display_url='null'
  elif [[ "${revision}" == 'no-revision' ]]; then
    local -r display_url="${url}"
  else
    local -r display_url="${url}::${revision}"
  fi

  if [[ "${display_url}" == 'null' ]]; then
    echo_red_text "Cloning repository to path: '${path}'..."
  else
    echo_red_text "Cloning repository from URL: '${display_url}' to path: '${path}'..."
  fi

  # If `no-revision` is specified for the revision, we don't clone the repo with a specific revision
  # This is undocumented because it's *generally* not recommended/supported, though there are exceptions where it can be useful/necessary
  if [[ "${revision}" == 'no-revision' ]]; then
    if [[ "${submodules}" == 1 ]]; then
      "${IRONFOX_GIT}" clone "${url}" "${path}" --depth="${depth}" --recurse-submodules || local clone_failed=1
    else
      "${IRONFOX_GIT}" clone "${url}" "${path}" --depth="${depth}" || local clone_failed=1
    fi
  else
    if [[ "${submodules}" == 1 ]]; then
      "${IRONFOX_GIT}" clone "${url}" "${path}" --depth="${depth}" --revision="${revision}" --recurse-submodules || local clone_failed=1
    else
      "${IRONFOX_GIT}" clone "${url}" "${path}" --depth="${depth}" --revision="${revision}" || local clone_failed=1
    fi
  fi

  # Ensure the repo we just cloned is valid
  if [[ "${clone_failed}" != 1 ]] && [[ ! -d "${path}" ]]; then
    local clone_failed=1
  fi

  # If the clone failed, return
  if [[ "${clone_failed}" == 1 ]]; then
    if [[ "${display_url}" == 'null' ]]; then
      echo_red_text "ERROR: Unable to clone repository to path: '${path}'!"
    else
      echo_red_text "ERROR: Unable to clone repository from URL: '${display_url}' to path: '${path}'!"
    fi
    return 1
  else
    if [[ "${display_url}" == 'null' ]]; then
      echo_green_text "SUCCESS: Cloned repository to path: '${path}'!"
    else
      echo_green_text "SUCCESS: Cloned repository from URL: '${display_url}' to path: '${path}'!"
    fi
  fi
}
