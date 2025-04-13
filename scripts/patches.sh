#!/bin/bash

if [[ "$env_source" != "true" ]]; then
    echo "Use 'source scripts/env_local.sh' before calling prebuild or build"
    return 1
fi

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

declare -a PATCH_FILES
# shellcheck disable=SC2207
PATCH_FILES=($(yq '.patches[].file' "$(dirname "$0")"/patches.yaml))

check_patch() {
    patch="$patches/$1"
    if ! [[ -f "$patch" ]]; then
        echo "Patch '$patch' does not exist or is not a file"
        return 1
    fi

    if ! patch -p1 -f --quiet --dry-run <"$patch"; then
        echo "Incompatible patch: '$patch'"
        return 1
    fi
}

check_patches() {
    for patch in "${PATCH_FILES[@]}"; do
        if ! check_patch "$patch"; then
            return 1
        fi
    done
}

test_patches() {
    for patch in "${PATCH_FILES[@]}"; do
        if ! check_patch "$patch">/dev/null 2>&1; then
            printf "${RED}%-45s: FAILED${NC}\n" "$(basename "$patch")"
        else
            printf "${GREEN}%-45s: OK${NC}\n" "$(basename "$patch")"
        fi
    done
}

apply_patch() {
    name="$1"
    echo "Applying patch: $name"
    check_patch "$name" || return 1
    patch -p1 --no-backup-if-mismatch --quiet <"$patches/$name"
    return $?
}

apply_patches() {
    for patch in "${PATCH_FILES[@]}"; do
        if ! apply_patch "$patch"; then
            echo "Failed to apply patch: $patch"
        fi
    done
}

list_patches() {
    for patch in "${PATCH_FILES[@]}"; do
        echo "$patch"
    done
}
