#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly NC="\033[0m"

declare -a PATCH_CMD
readonly PATCH_CMD=("${IRONFOX_PATCH}" -p1 --no-backup-if-mismatch)

declare -a PATCH_FILES
declare -a AS_PATCH_FILES
declare -a GLEAN_PATCH_FILES
declare -a UP_AC_PATCH_FILES

readonly PATCH_FILES=($("${IRONFOX_YQ}" '.patches[].file' "$("${IRONFOX_DIRNAME}" "$0")"/patches.yaml))
readonly AS_PATCH_FILES=($("${IRONFOX_YQ}" '.patches[].file' "$("${IRONFOX_DIRNAME}" "$0")"/a-s-patches.yaml))
readonly GLEAN_PATCH_FILES=($("${IRONFOX_YQ}" '.patches[].file' "$("${IRONFOX_DIRNAME}" "$0")"/glean-patches.yaml))
readonly UP_AC_PATCH_FILES=($("${IRONFOX_YQ}" '.patches[].file' "${IRONFOX_UP_AC}"/patches/patches.yaml))

function check_patch() {
  local readonly patch="${IRONFOX_PATCHES}/$1"
  if [[ ! -f "${patch}" ]]; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "'${patch}' does not exist or is not a file"
    return 1
  fi

  if ! "${PATCH_CMD[@]}" --dry-run <"${patch}"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Incompatible patch: '${patch}'"
    return 1
  fi
}

function up_ac_check_patch() {
  local readonly patch="${IRONFOX_UP_AC}/patches/$1"
  if [[ ! -f "${patch}" ]]; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "'${patch}' does not exist or is not a file"
    return 1
  fi

  if ! "${PATCH_CMD[@]}" --dry-run <"${patch}"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Incompatible patch: '${patch}'"
    return 1
  fi
}

function check_patches() {
  for patch in "${PATCH_FILES[@]}"; do
    if ! check_patch "${patch}"; then
      return 1
    fi
  done
}

function a-s_check_patches() {
  for patch in "${AS_PATCH_FILES[@]}"; do
    if ! check_patch "${patch}"; then
      return 1
    fi
  done
}

function glean_check_patches() {
  for patch in "${GLEAN_PATCH_FILES[@]}"; do
    if ! check_patch "${patch}"; then
      return 1
    fi
  done
}

function up_ac_check_patches() {
  for patch in "${UP_AC_PATCH_FILES[@]}"; do
    if ! up_ac_check_patch "${patch}"; then
      return 1
    fi
  done
}

function test_patches() {
  for patch in "${PATCH_FILES[@]}"; do
    if ! check_patch "${patch}" >/dev/null 2>&1; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    else
      printf "${GREEN}✓ %-45s: OK${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    fi
  done
}

function a-s_test_patches() {
  for patch in "${AS_PATCH_FILES[@]}"; do
    if ! check_patch "${patch}" >/dev/null 2>&1; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    else
      printf "${GREEN}✓ %-45s: OK${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    fi
  done
}

function glean_test_patches() {
  for patch in "${GLEAN_PATCH_FILES[@]}"; do
    if ! check_patch "${patch}" >/dev/null 2>&1; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    else
      printf "${GREEN}✓ %-45s: OK${NC}\n" "$("${IRONFOX_BASENAME}"e "${patch}")"
    fi
  done
}

function up_ac_test_patches() {
  for patch in "${UP_AC_PATCH_FILES[@]}"; do
    if ! up_ac_check_patch "${patch}" >/dev/null 2>&1; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    else
      printf "${GREEN}✓ %-45s: OK${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    fi
  done
}

function apply_patch() {
  local readonly name="$1"
  echo "Applying patch: ${name}"
  check_patch "${name}" || return 1
  "${PATCH_CMD[@]}" <"${IRONFOX_PATCHES}/${name}"
  return $?
}

function up_ac_apply_patch() {
  local readonly name="$1"
  echo "Applying patch: ${name}"
  up_ac_check_patch "${name}" || return 1
  "${PATCH_CMD[@]}" <"${IRONFOX_UP_AC}/patches/${name}"
  return $?
}

function apply_patches() {
  for patch in "${PATCH_FILES[@]}"; do
    if ! apply_patch "${patch}"; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
      echo "Failed to apply ${patch}"
      return 1
    fi
  done
}

function a-s_apply_patches() {
  for patch in "${AS_PATCH_FILES[@]}"; do
    if ! apply_patch "${patch}"; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
      echo "Failed to apply ${patch}"
      return 1
    fi
  done
}

function glean_apply_patches() {
  for patch in "${GLEAN_PATCH_FILES[@]}"; do
    if ! apply_patch "${patch}"; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
      echo "Failed to apply ${patch}"
      return 1
    fi
  done
}

function up_ac_apply_patches() {
  for patch in "${UP_AC_PATCH_FILES[@]}"; do
    if ! up_ac_apply_patch "${patch}"; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
      echo "Failed to apply ${patch}"
      return 1
    fi
  done
}

function list_patches() {
  for patch in "${PATCH_FILES[@]}"; do
    echo "${patch}"
  done
}

function a-s_list_patches() {
  for patch in "${AS_PATCH_FILES[@]}"; do
    echo "${patch}"
  done
}

function glean_list_patches() {
  for patch in "${GLEAN_PATCH_FILES[@]}"; do
    echo "${patch}"
  done
}

function up_ac_list_patches() {
  for patch in "${UP_AC_PATCH_FILES[@]}"; do
    echo "${patch}"
  done
}

function slugify() {
  local readonly input="$1"
  echo "${input}" |                  \
    tr '[:upper:]' '[:lower:]' | \
    "${IRONFOX_SED}" -E 's/[^a-z0-9]+/-/g' |  \
    "${IRONFOX_SED}" -E 's/^-+|-+$//g'
}

# Function to rebase a single patch file atomically
# Usage: rebase_patch <compatible_tag> <target_tag> <patch_file_path>
function rebase_patch() {
  local readonly compatible_tag="$1"
  local readonly target_tag="$2"
  local readonly patch_file="$3"

  # Validate inputs
  if [[ -z "${compatible_tag}" || -z "${target_tag}" || -z "${patch_file}" ]]; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Missing required parameters" >&2
    echo "Usage: rebase_patch <compatible_tag> <target_tag> <patch_file_path>" >&2
    return 1
  fi

  if [[ ! -f "${patch_file}" ]]; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Patch file '${patch_file}' does not exist" >&2
    return 1
  fi

  # Store original state for rollback
  local readonly original_branch=$("${IRONFOX_GIT}" rev-parse --abbrev-ref HEAD 2>/dev/null)

  local readonly original_stash_count=$("${IRONFOX_GIT}" stash list | "${IRONFOX_WC}" -l)

  local readonly patch_name=$("${IRONFOX_BASENAME}" "${patch_file}" .patch)

  local readonly branch_name="rebase-${patch_name}"

  function cleanup_and_rollback() {
    echo "Error occurred, rolling back changes..." >&2

    # Check if we're in the middle of a rebase and abort it
    if "${IRONFOX_GIT}" status --porcelain=v1 2>/dev/null | "${IRONFOX_GREP}" -q "^R" ||
     [[ -d "$("${IRONFOX_GIT}" rev-parse --git-dir)/rebase-merge" ]] ||
     [[ -d "$("${IRONFOX_GIT}" rev-parse --git-dir)/rebase-apply" ]]; then
      echo "Aborting rebase in progress..."
      "${IRONFOX_GIT}" rebase --abort 2>/dev/null
    fi

    # Switch back to original branch if it exists
    if [[ -n "${original_branch}" && "${original_branch}" != "HEAD" ]]; then
      "${IRONFOX_GIT}" checkout "${original_branch}" 2>/dev/null
    fi

    # Delete the temporary branch if it was created
    "${IRONFOX_GIT}" branch -D "${branch_name}" 2>/dev/null

    # Restore stashed changes if any were created
    local readonly current_stash_count=$("${IRONFOX_GIT}" stash list | "${IRONFOX_WC}" -l)
    if [[ "${current_stash_count}" -gt "${original_stash_count}" ]]; then
      "${IRONFOX_GIT}" stash pop 2>/dev/null
    fi

    return 1
  }

  # Ensure clean git directory state
  if ! "${IRONFOX_GIT}" diff-index --quiet HEAD --; then
    echo "Stashing uncommitted changes..."
    if ! "${IRONFOX_GIT}" stash push -m "Temporary stash for patch rebase"; then
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
      echo "Failed to stash changes" >&2
      return 1
    fi
  fi

  # Check if tags exist
  if ! "${IRONFOX_GIT}" rev-parse --verify "${compatible_tag}" >/dev/null 2>&1; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Compatible tag '${compatible_tag}' does not exist" >&2
    cleanup_and_rollback
    return 1
  fi

  if ! "${IRONFOX_GIT}" rev-parse --verify "${target_tag}" >/dev/null 2>&1; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Target tag '${target_tag}' does not exist" >&2
    cleanup_and_rollback
    return 1
  fi

  # Checkout the compatible tag
  echo "Checking out compatible tag '${compatible_tag}'..."
  if ! "${IRONFOX_GIT}" checkout "${compatible_tag}"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Failed to checkout compatible tag '${compatible_tag}'" >&2
    cleanup_and_rollback
    return 1
  fi

  # Create and switch to new branch
  echo "Creating branch '${branch_name}'..."
  if ! "${IRONFOX_GIT}" checkout -b "${branch_name}"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Failed to create branch '${branch_name}'" >&2
    cleanup_and_rollback
    return 1
  fi

  # Apply the patch
  echo "Applying patch '${patch_file}'..."
  if ! "${IRONFOX_GIT}" apply "${patch_file}"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Failed to apply '${patch_file}'" >&2
    cleanup_and_rollback
    return 1
  fi

  # Stage all changes
  if ! "${IRONFOX_GIT}" add .; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Failed to stage changes" >&2
    cleanup_and_rollback
    return 1
  fi

  # Commit the changes
  local readonly commit_message="Apply patch $("${IRONFOX_BASENAME}" "${patch_file}") - rebased to ${target_tag}"
  echo "Committing changes..."
  if ! "${IRONFOX_GIT}" commit -m "${commit_message}"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Failed to commit changes" >&2
    cleanup_and_rollback
    return 1
  fi

  # Rebase to target tag
  echo "Rebasing to target tag '${target_tag}'..."
  if ! "${IRONFOX_GIT}" rebase "$target_tag"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Failed to rebase to target tag '${target_tag}'" >&2
    cleanup_and_rollback
    return 1
  fi

  # Update the patch file using git format-patch
  echo "Updating patch file..."
  local readonly temp_patch=$("${IRONFOX_MKTEMP}")
  if ! "${IRONFOX_GIT}" format-patch -1 --stdout >"${temp_patch}"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patc}h")"
    echo "Failed to generate new patch" >&2
    "${IRONFOX_RM}" -f "${temp_patch}"
    cleanup_and_rollback
    return 1
  fi

  # Atomically replace the original patch file
  if ! "${IRONFOX_MV}" "${temp_patch}" "${patch_file}"; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Failed to update patch file" >&2
    "${IRONFOX_RM}" -f "${temp_patch}"
    cleanup_and_rollback
    return 1
  fi

  # Cleanup: switch back to original branch and delete temporary branch
  if [[ -n "${original_branch}" && "${original_branch}" != "HEAD" ]]; then
    "${IRONFOX_GIT}" checkout "${original_branch}"
  else
    "${IRONFOX_GIT}" checkout "${target_tag}"
  fi

  "${IRONFOX_GIT}" branch -D "${branch_name}"

  # Restore stashed changes if any
  local readonly current_stash_count=$("${IRONFOX_GIT}" stash list | "${IRONFOX_WC}" -l)
  if [[ "${current_stash_count}" -gt "${original_stash_count}" ]]; then
    echo "Restoring stashed changes..."
    "${IRONFOX_GIT}" stash pop
  fi

  printf "${GREEN}✓ %-45s: SUCCESS${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
  echo "Rebased patch '${patch_file}' from '${compatible_tag}' to '${target_tag}'"
  return 0
}

# Function to rebase multiple patch files
# Usage: rebase_patches <compatible_tag> <target_tag> <patch_file1> [patch_file2] [...]
function rebase_patches() {
  local readonly compatible_tag="$1"
  local readonly target_tag="$2"

  # Validate inputs
  if [[ -z "${compatible_tag}" || -z "${target_tag}" ]]; then
    printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
    echo "Missing required parameters" >&2
    echo "Usage: rebase_patches <compatible_tag> <target_tag>" >&2
    return 1
  fi

  local success_count=0
  local failure_count=0
  local failed_patches=()

  echo "Starting batch rebase of ${#PATCH_FILES[@]} patch files..."
  echo "Compatible tag: ${compatible_tag}"
  echo "Target tag: ${target_tag}"
  echo "----------------------------------------"

  for patch_file in "${PATCH_FILES[@]}"; do
    echo "Processing: ${patch_file}"

    if rebase_patch "${compatible_tag}" "${target_tag}" "${patch_file}"; then
      printf "${GREEN}✓ %-45s: SUCCESS${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
      ((success_count++))
    else
      printf "${RED}✗ %-45s: FAILED${NC}\n" "$("${IRONFOX_BASENAME}" "${patch}")"
      failed_patches+=("${patch_file}")
      ((failure_count++))
    fi
    echo "----------------------------------------"
  done

  # Summary
  echo "Batch rebase completed:"
  echo "  Successful: ${success_count}"
  echo "  Failed: ${failure_count}"

  if [[ "${failure_count}" -gt 0 ]]; then
    echo "Failed patches:"
    for failed_patch in "${failed_patches[@]}"; do
      echo "  - ${failed_patch}"
    done
    return 1
  fi

  return 0
}
