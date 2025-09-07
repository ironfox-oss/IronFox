#!/bin/bash

# IronFox - Docker build script

set -euo pipefail

script="$(realpath "$0")"
script_dir="$(dirname "$script")"
root_dir="$(dirname "$script_dir")"

# Configuration
IMAGE_NAME="ironfox-builder"
CONTAINER_NAME="ironfox-builder"
DOCKERFILE_PATH="$root_dir/Dockerfile"
PROMPT='\[\033[1;36m\]🐳\[\033[0m\] \[\033[1;34m\]\u@ironfox\[\033[0m\]:\[\033[1;33m\]\w\[\033[0m\]\$ '

# Initialize variables
MOUNT_ARGS=()
COMMAND_ARGS=()
PARSE_COMMAND=false

usage() {
    cat << EOF
IronFox - Docker Build Script

USAGE:
    $0 [OPTIONS] [-- COMMAND [ARGS...]]

OPTIONS:
    -v HOST_PATH:CONTAINER_PATH    Mount a volume from host to container
    -h, --help                     Show this help message

EXAMPLES:
    $0                                    # Start interactive shell
    $0 -v /home/user/code:/workspace      # Mount volume and start shell
    $0 -- ls -la                          # Run 'ls -la' in container
    $0 -v ./data:/data -- python app.py   # Mount volume and run Python script

BEHAVIOR:
- Builds Docker image from '${DOCKERFILE_PATH}' if it doesn't exist
- Creates a persistent container if it doesn't exist
- Automatically mounts the IronFox directory to /app in container
- Starts the container if it's stopped
- Runs interactive shell if no command is provided after --
- Multiple -v options can be used to mount multiple volumes

CONFIGURATION:
- Image name: $IMAGE_NAME
- Container name: $CONTAINER_NAME
- Dockerfile path: $DOCKERFILE_PATH
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v)
            if [[ -z "$2" ]]; then
                echo "Error: -v requires a volume mapping argument (host_path:container_path)"
                exit 1
            fi
            MOUNT_ARGS+=("-v" "$2")
            shift 2
            ;;
        -h)
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

if [[ "$PARSE_COMMAND" == true ]]; then
    COMMAND_ARGS=("$@")
fi

image_exists() {
    docker image inspect "$IMAGE_NAME" >/dev/null 2>&1
}

container_exists() {
    docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1
}

container_running() {
    [[ "$(docker container inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null)" == "true" ]]
}

build_image() {
    echo "Building Docker image '$IMAGE_NAME'..."
    if [[ ! -f "$DOCKERFILE_PATH" ]]; then
        echo "Error: Dockerfile not found at $DOCKERFILE_PATH"
        exit 1
    fi
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
    echo "Docker image '$IMAGE_NAME' built successfully."
}

create_container() {
    echo "Creating container '$CONTAINER_NAME'..."
    
    local docker_cmd=(
        "docker" "run" "-d" "-it"
        "--name" "$CONTAINER_NAME"
        "-v" "$root_dir:/app"
        "${MOUNT_ARGS[@]}"
        "$IMAGE_NAME"
    )
    
    "${docker_cmd[@]}"
    echo "Container '$CONTAINER_NAME' created successfully."
}

start_container() {
    if ! container_running; then
        echo "Starting container '$CONTAINER_NAME'..."
        docker start "$CONTAINER_NAME"
    fi
}

execute_in_container() {
    local cmd=("$@")
    
    if [[ ${#cmd[@]} -eq 0 ]]; then
        echo "Starting interactive shell in container '$CONTAINER_NAME'..."
        docker exec -it "$CONTAINER_NAME" /opt/entrypoint.sh /bin/bash -c "export PS1='$PROMPT' && /bin/bash"
    else
        echo "Executing command in container '$CONTAINER_NAME': ${cmd[*]}"
        docker exec -it "$CONTAINER_NAME" "${cmd[@]}"
    fi
}

main() {
    echo "IronFox"
    echo "========================"
    
    if ! image_exists; then
        build_image
    else
        echo "Docker image '$IMAGE_NAME' already exists."
    fi
    
    if ! container_exists; then
        create_container
    else
        echo "Container '$CONTAINER_NAME' already exists."
    fi
    
    start_container
    execute_in_container "${COMMAND_ARGS[@]}"
}

main
