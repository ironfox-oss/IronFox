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
        if ! check_patch "$patch" >/dev/null 2>&1; then
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
    echo "$input" |                  \
        tr '[:upper:]' '[:lower:]' | \
        sed -E 's/[^a-z0-9]+/-/g' |  \
        sed -E 's/^-+|-+$//g'
}

# Function to rebase a single patch file atomically
# Usage: rebase_patch <compatible_tag> <target_tag> <patch_file_path>
rebase_patch() {
    local compatible_tag="$1"
    local target_tag="$2"
    local patch_file="$3"

    # Validate inputs
    if [[ -z "$compatible_tag" || -z "$target_tag" || -z "$patch_file" ]]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: rebase_patch <compatible_tag> <target_tag> <patch_file_path>" >&2
        return 1
    fi

    if [[ ! -f "$patch_file" ]]; then
        echo "Error: Patch file '$patch_file' does not exist" >&2
        return 1
    fi

    # Store original state for rollback
    local original_branch
    original_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    local original_stash_count
    original_stash_count=$(git stash list | wc -l)

    local patch_name
    patch_name=$(basename "$patch_file" .patch)

    local branch_name="rebase-${patch_name}"

    cleanup_and_rollback() {
        echo "Error occurred, rolling back changes..." >&2

        # Check if we're in the middle of a rebase and abort it
        if git status --porcelain=v1 2>/dev/null | grep -q "^R" ||
            [[ -d "$(git rev-parse --git-dir)/rebase-merge" ]] ||
            [[ -d "$(git rev-parse --git-dir)/rebase-apply" ]]; then
            echo "Aborting rebase in progress..."
            git rebase --abort 2>/dev/null
        fi

        # Switch back to original branch if it exists
        if [[ -n "$original_branch" && "$original_branch" != "HEAD" ]]; then
            git checkout "$original_branch" 2>/dev/null
        fi

        # Delete the temporary branch if it was created
        git branch -D "$branch_name" 2>/dev/null

        # Restore stashed changes if any were created
        local current_stash_count
        current_stash_count=$(git stash list | wc -l)
        if [[ $current_stash_count -gt $original_stash_count ]]; then
            git stash pop 2>/dev/null
        fi

        return 1
    }

    # Ensure clean git directory state
    if ! git diff-index --quiet HEAD --; then
        echo "Stashing uncommitted changes..."
        if ! git stash push -m "Temporary stash for patch rebase"; then
            echo "Error: Failed to stash changes" >&2
            return 1
        fi
    fi

    # Check if tags exist
    if ! git rev-parse --verify "$compatible_tag" >/dev/null 2>&1; then
        echo "Error: Compatible tag '$compatible_tag' does not exist" >&2
        cleanup_and_rollback
        return 1
    fi

    if ! git rev-parse --verify "$target_tag" >/dev/null 2>&1; then
        echo "Error: Target tag '$target_tag' does not exist" >&2
        cleanup_and_rollback
        return 1
    fi

    # Checkout the compatible tag
    echo "Checking out compatible tag '$compatible_tag'..."
    if ! git checkout "$compatible_tag"; then
        echo "Error: Failed to checkout compatible tag '$compatible_tag'" >&2
        cleanup_and_rollback
        return 1
    fi

    # Create and switch to new branch
    echo "Creating branch '$branch_name'..."
    if ! git checkout -b "$branch_name"; then
        echo "Error: Failed to create branch '$branch_name'" >&2
        cleanup_and_rollback
        return 1
    fi

    # Apply the patch
    echo "Applying patch '$patch_file'..."
    if ! git apply "$patch_file"; then
        echo "Error: Failed to apply patch '$patch_file'" >&2
        cleanup_and_rollback
        return 1
    fi

    # Stage all changes
    if ! git add .; then
        echo "Error: Failed to stage changes" >&2
        cleanup_and_rollback
        return 1
    fi

    # Commit the changes
    local commit_message
    commit_message="Apply patch $(basename "$patch_file") - rebased to $target_tag"
    echo "Committing changes..."
    if ! git commit -m "$commit_message"; then
        echo "Error: Failed to commit changes" >&2
        cleanup_and_rollback
        return 1
    fi

    # Rebase to target tag
    echo "Rebasing to target tag '$target_tag'..."
    if ! git rebase "$target_tag"; then
        echo "Error: Failed to rebase to target tag '$target_tag'" >&2
        cleanup_and_rollback
        return 1
    fi

    # Update the patch file using git format-patch
    echo "Updating patch file..."
    local temp_patch
    temp_patch=$(mktemp)
    if ! git format-patch -1 --stdout >"$temp_patch"; then
        echo "Error: Failed to generate new patch" >&2
        rm -f "$temp_patch"
        cleanup_and_rollback
        return 1
    fi

    # Atomically replace the original patch file
    if ! mv "$temp_patch" "$patch_file"; then
        echo "Error: Failed to update patch file" >&2
        rm -f "$temp_patch"
        cleanup_and_rollback
        return 1
    fi

    # Cleanup: switch back to original branch and delete temporary branch
    if [[ -n "$original_branch" && "$original_branch" != "HEAD" ]]; then
        git checkout "$original_branch"
    else
        git checkout "$target_tag"
    fi

    git branch -D "$branch_name"

    # Restore stashed changes if any
    local current_stash_count
    current_stash_count=$(git stash list | wc -l)
    if [[ $current_stash_count -gt $original_stash_count ]]; then
        echo "Restoring stashed changes..."
        git stash pop
    fi

    echo "Successfully rebased patch '$patch_file' from '$compatible_tag' to '$target_tag'"
    return 0
}

# Function to rebase multiple patch files
# Usage: rebase_patches <compatible_tag> <target_tag> <patch_file1> [patch_file2] [...]
rebase_patches() {
    local compatible_tag="$1"
    local target_tag="$2"
    shift 2
    local patch_files=("$@")

    # Validate inputs
    if [[ -z "$compatible_tag" || -z "$target_tag" || ${#patch_files[@]} -eq 0 ]]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: rebase_patches <compatible_tag> <target_tag> <patch_file1> [patch_file2] [...]" >&2
        return 1
    fi

    local success_count=0
    local failure_count=0
    local failed_patches=()

    echo "Starting batch rebase of ${#patch_files[@]} patch files..."
    echo "Compatible tag: $compatible_tag"
    echo "Target tag: $target_tag"
    echo "----------------------------------------"

    for patch_file in "${patch_files[@]}"; do
        echo "Processing: $patch_file"

        if rebase_patch "$compatible_tag" "$target_tag" "$patch_file"; then
            echo "✓ Success: $patch_file"
            ((success_count++))
        else
            echo "✗ Failed: $patch_file"
            failed_patches+=("$patch_file")
            ((failure_count++))
        fi
        echo "----------------------------------------"
    done

    # Summary
    echo "Batch rebase completed:"
    echo "  Successful: $success_count"
    echo "  Failed: $failure_count"

    if [[ $failure_count -gt 0 ]]; then
        echo "Failed patches:"
        for failed_patch in "${failed_patches[@]}"; do
            echo "  - $failed_patch"
        done
        return 1
    fi

    return 0
}
