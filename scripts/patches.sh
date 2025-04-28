#!/bin/bash

if [[ "$env_source" != "true" ]]; then
    echo "Use 'source scripts/env_local.sh' before calling prebuild or build"
    return 1
fi

source "$rootdir/scripts/versions.sh"

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

slugify() {
    local input="$1"
    echo "$input" | \
        tr '[:upper:]' '[:lower:]' | \
        sed -E 's/[^a-z0-9]+/-/g' | \
        sed -E 's/^-+|-+$//g'
}

rebase_patch() {
    name="$1"
    name_slug=$(slugify "$name")

    repo_dir="$2"

    if ! [[ -d "$repo_dir" ]]; then
        echo "'$repo_dir' is not a directory."
        return 1
    fi

    pushd "$repo_dir" || {
        echo "Unable to pushd into '$repo_dir'"
        return 1
    };

    { git checkout release || git reset --hard && git checkout release; } &&
        { git checkout -b "$name_slug" || git checkout "$name_slug" && git reset --hard; } &&
        git reset --hard "$FIREFOX_TAG_NAME" &&
        git apply --3way "$rootdir/patches/$name" &&
        git add . &&
        git commit --signoff -m "fix(patches): update '$name' for '$FIREFOX_TAG_NAME'" &&
        git rebase release &&
        git format-patch HEAD^1 --output="$rootdir/patches/$name" &&
        git checkout release &&
        git branch -D "$name_slug"

    popd || {
        echo "Unable to popd from '$repo_dir'"
        return 1
    };
}
