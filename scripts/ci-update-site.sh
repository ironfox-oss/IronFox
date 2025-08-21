#!/bin/bash

# Script is used to update the ironfoxoss.org website repository.
# This script is not intended to be executed manually!

set -eu

source "$(realpath $(dirname "$0"))/versions.sh"

git clone "https://$IF_CI_USERNAME:$GITLAB_CI_PUSH_TOKEN@gitlab.com/$TARGET_REPO_PATH.git" target-repo
cd target-repo || { echo "Unable to cd into target-repo"; exit 1; };

# Generate documentation for patches
./scripts/gen_patch_pages.py ../scripts/patches.yaml

# Update version name
sed -i "s/IRONFOX_VERSION = .*/IRONFOX_VERSION = \"${IRONFOX_VERSION}\";/g" \
    ./src/version.ts

# Commit changes
git add src
git commit -m "feat: update patch docs to reflect ironfox-oss/IronFox@$CI_COMMIT_SHA"
git push origin "HEAD:$TARGET_REPO_BRANCH"
