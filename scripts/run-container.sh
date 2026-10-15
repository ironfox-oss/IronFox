#!/bin/bash

set -euo pipefail

readonly script="$(realpath "$0")"
readonly script_dir="$(dirname "${script}")"
readonly root_dir="$(dirname "${script_dir}")"

detect_engine() {
  if [[ -n "${CONTAINER_ENGINE:-}" ]]; then
    if ! command -v "${CONTAINER_ENGINE}" > /dev/null 2>&1; then
      echo "Error: CONTAINER_ENGINE is set to '${CONTAINER_ENGINE}', but it was not found in \$PATH." >&2
      exit 1
    fi
    echo "${CONTAINER_ENGINE}"
    return
  fi

  if command -v podman > /dev/null 2>&1; then
    echo "podman"
  elif command -v docker > /dev/null 2>&1; then
    echo "docker"
  else
    echo "Error: Neither 'podman' nor 'docker' was found in \$PATH." >&2
    echo "Install one of them, or set CONTAINER_ENGINE to your preferred engine." >&2
    exit 1
  fi
}

readonly ENGINE="$(detect_engine)"
readonly IMAGE_NAME="ironfox-builder"
readonly CONTAINER_NAME="ironfox-builder"
readonly CONTAINERFILE_PATH="${root_dir}/Containerfile"

if [[ "${ENGINE}" == *podman* ]]; then
  readonly PROMPT_ICON=$'\xf0\x9f\xa6\xad'
else
  readonly PROMPT_ICON=$'\xf0\x9f\x90\xb3'
fi
readonly PROMPT="\[\033[1;36m\]${PROMPT_ICON}\[\033[0m\] \[\033[1;34m\]\u@ironfox\[\033[0m\]:\[\033[1;33m\]\w\[\033[0m\]\$ "

MOUNT_ARGS=()
COMMAND_ARGS=()
PARSE_COMMAND=false

usage() {
  cat << EOF
IronFox - Container Build Script

USAGE:
  $0 [OPTIONS] [-- COMMAND [ARGS...]]

OPTIONS:
  -v HOST_PATH:CONTAINER_PATH    Mount a volume from host to container
  -h, --help                     Show this help message

ENVIRONMENT:
  CONTAINER_ENGINE    Override auto-detection (e.g. CONTAINER_ENGINE=docker)

EXAMPLES:
  $0                                    # Start interactive shell
  $0 -v /home/user/code:/workspace      # Mount volume and start shell
  $0 -- ls -la                          # Run 'ls -la' in container
  $0 -v ./data:/data -- python app.py   # Mount volume and run command

BEHAVIOR:
- Uses ${ENGINE} as the container engine (auto-detected, or set CONTAINER_ENGINE)
- Builds container image from '${CONTAINERFILE_PATH}' if it doesn't exist
- Creates a persistent container if it doesn't exist
- Automatically mounts the IronFox directory to /app in container
- Starts the container if it's stopped
- Runs interactive shell if no command is provided after --
- Multiple -v options can be used to mount multiple volumes

CONFIGURATION:
- Engine: ${ENGINE}
- Image name: ${IMAGE_NAME}
- Container name: ${CONTAINER_NAME}
- Container file: ${CONTAINERFILE_PATH}
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -v)
      if [[ -z "${2:-}" ]]; then
        echo "Error: -v requires a volume mapping argument (host_path:container_path)"
        exit 1
      fi
      MOUNT_ARGS+=("-v" "$2")
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      PARSE_COMMAND=true
      shift
      break
      ;;
    *)
      echo "Error: Unknown option $1"
      echo "Usage: $0 [-v host_path:container_path] [-- command args...]"
      exit 1
      ;;
  esac
done

if [[ "${PARSE_COMMAND}" == true ]]; then
  COMMAND_ARGS=("$@")
fi

image_exists() {
  "${ENGINE}" image inspect "${IMAGE_NAME}" > /dev/null 2>&1
}

container_exists() {
  "${ENGINE}" container inspect "${CONTAINER_NAME}" > /dev/null 2>&1
}

container_running() {
  [[ "$("${ENGINE}" container inspect -f '{{.State.Running}}' "${CONTAINER_NAME}" 2> /dev/null)" == "true" ]]
}

build_image() {
  echo "Building container image '${IMAGE_NAME}' with ${ENGINE}..."
  if [[ ! -f "${CONTAINERFILE_PATH}" ]]; then
    echo "Error: Container file not found at '${CONTAINERFILE_PATH}'!"
    return 1
  fi
  "${ENGINE}" build -t "${IMAGE_NAME}" -f "${CONTAINERFILE_PATH}" . || return 1
  echo "Container image '${IMAGE_NAME}' built successfully."
}

create_container() {
  echo "Creating container '${CONTAINER_NAME}'..."

  local -r cmd=(
    "${ENGINE}" "run" "-d" "-it"
    "--name" "${CONTAINER_NAME}"
    "-v" "${root_dir}:/app:Z"
    "${MOUNT_ARGS[@]}"
    "${IMAGE_NAME}"
  )

  "${cmd[@]}" || return 1
  echo "Container '${CONTAINER_NAME}' created successfully."
}

start_container() {
  if ! container_running; then
    echo "Starting container '${CONTAINER_NAME}'..."
    "${ENGINE}" start "${CONTAINER_NAME}" || return 1
  fi
}

execute_in_container() {
  local -r cmd=("$@") || return 1

  if [[ ${#cmd[@]} -eq 0 ]]; then
    echo "Starting interactive shell in container '${CONTAINER_NAME}'..."
    "${ENGINE}" exec -it "${CONTAINER_NAME}" /bin/bash -c "export PS1='${PROMPT}' && /bin/bash" || return 1
  else
    echo "Executing command in container '${CONTAINER_NAME}': ${cmd[*]}"
    "${ENGINE}" exec -it "${CONTAINER_NAME}" "${cmd[@]}" || return 1
  fi
}

main() {
  echo "IronFox (${ENGINE})"
  echo "========================"

  if ! image_exists; then
    build_image || return 1
  else
    echo "Container image '${IMAGE_NAME}' already exists."
  fi

  if ! container_exists; then
    create_container || return 1
  else
    echo "Container '${CONTAINER_NAME}' already exists."
  fi

  start_container || return 1
  execute_in_container "${COMMAND_ARGS[@]}" || return 1
}

main || exit 1
