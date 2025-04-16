#!/bin/bash

# Script is used to update the ironfoxoss.org website repository.
# This script is not intended to be executed manually!

set -eu

git clone "https://oauth2:$GITLAB_CI_PUSH_TOKEN@gitlab.com/$TARGET_REPO_PATH.git" target-repo
cd target-repo || { echo "Unable to cd into target-repo"; exit 1; };

# Generate documentation for patches
./scripts/gen_patch_pages.py ../scripts/patches.yaml

# Update version name
sed -i "s/IRONFOX_VERSION = .*/IRONFOX_VERSION = \"${VERSION_NAME}\";/g" \
    ./src/version.ts

# Commit changes
git add src
git commit -m "feat: update for release ${CI_COMMIT_TAG}"
git push origin "HEAD:$TARGET_REPO_BRANCH"
