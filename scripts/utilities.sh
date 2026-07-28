#!/bin/bash

set -euo pipefail

# Utility functions for frequently performed tasks
# This file MUST NOT contain anything other than function definitions.

function echo_red_text() {
  echo -e "\033[31m$1\033[0m"
}

function echo_green_text() {
  echo -e "\033[32m$1\033[0m"
}

# Verify that an executable (corresponding to an environment variable) exists and is properly set-up
function verify_exec() {
  function print_usage() {
    echo "Usage: verify_exec /path/to/executable 'ENVIRONMENT_VARIABLE_FOR_EXECUTABLE'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify an executable!'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify an environment variable that corresponds to an executable!'
    print_usage
    exit 1
  fi

  local -r exec="$1"
  local -r exec_env="$2"

  if [[ -z "${exec_env+x}" ]]; then
    echo_red_text "ERROR: Environment variable is missing!: ${exec_env}"
    exit 1
  fi

  if [[ ! -f "${exec}" ]]; then
    echo_red_text "ERROR: ${exec} is missing!"
    echo_green_text "Please ensure that environment variable is set to a valid executable: ${exec_env}"
    return 1
  fi

  if [[ ! -s "${exec}" ]]; then
    echo_red_text "ERROR: ${exec} is empty!"
    echo_green_text "Please ensure that environment variable is set to a valid executable: ${exec_env}"
    return 1
  fi

  if [[ ! -x "${exec}" ]]; then
    echo_red_text "ERROR: ${exec} is not executable!"
    echo_green_text "Please ensure that environment variable is set to a valid executable: ${exec_env}"
    return 1
  fi
}

# Verify that a file exists and is not empty
function verify_file() {
  function print_usage() {
    echo "Usage: verify_file /path/to/file"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a file to verify'
    print_usage
    exit 1
  fi

  local -r verify_file="$1"

  if [[ ! -f "${verify_file}" ]]; then
    echo_red_text "ERROR: ${verify_file} does not exist! Aborting..."
    return 1
  fi

  if [[ ! -s "${verify_file}" ]]; then
    echo_red_text "ERROR: ${verify_file} is empty! Aborting..."
    return 1
  fi
}

# Verify that a file (corresponding to an environment variable) exists and is not empty
function verify_file_with_env() {
  function print_usage() {
    echo "Usage: verify_file_with_env /path/to/file 'ENVIRONMENT_VARIABLE_FOR_FILE'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a file to verify'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the environment variable that corresponds to the file to verify'
    print_usage
    exit 1
  fi

  local -r verify_file="$1"
  local -r verify_file_env="$2"

  if [[ -z "${verify_file_env+x}" ]]; then
    echo_red_text "ERROR: Environment variable is missing!: ${verify_file_env}"
    exit 1
  fi

  if [[ "${verify_file}" == 'null' ]]; then
    echo_red_text "ERROR: Environment variable: ${verify_file_env} has not been specified! Aborting..."
    return 1
  fi

  if [[ ! -f "${verify_file}" ]]; then
    echo_red_text "ERROR: ${verify_file_env} is set, but ${verify_file} does not exist! Aborting..."
    return 1
  fi

  if [[ ! -s "${verify_file}" ]]; then
    echo_red_text "ERROR: ${verify_file_env} is set, but ${verify_file} is empty! Aborting..."
    return 1
  fi
}

# Verify that a directory exists
function verify_dir() {
  function print_usage() {
    echo "Usage: verify_dir /path/to/dir"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a directory to verify'
    print_usage
    exit 1
  fi

  local -r verify_dir="$1"

  if [[ ! -d "${verify_dir}" ]]; then
    echo_red_text "ERROR: ${verify_dir} does not exist! Aborting..."
    return 1
  fi
}

# Verify that a directory (corresponding to an environment variable) exists
function verify_dir_with_env() {
  function print_usage() {
    echo "Usage: verify_dir_with_env /path/to/dir 'ENVIRONMENT_VARIABLE_FOR_DIR'"
  }

  if [[ -z "${1+x}" ]]; then
    echo_red_text 'ERROR: Please specify the path to a directory to verify'
    print_usage
    exit 1
  fi

  if [[ -z "${2+x}" ]]; then
    echo_red_text 'ERROR: Please specify the environment variable that corresponds to the directory to verify'
    print_usage
    exit 1
  fi

  local -r verify_dir="$1"
  local -r verify_dir_env="$2"

  if [[ -z "${verify_dir_env+x}" ]]; then
    echo_red_text "ERROR: Environment variable is missing!: ${verify_dir_env}"
    exit 1
  fi

  if [[ ! -d "${verify_dir}" ]]; then
    echo_red_text "ERROR: ${verify_dir_env} is set, but ${verify_dir} does not exist! Aborting..."
    return 1
  fi
}
