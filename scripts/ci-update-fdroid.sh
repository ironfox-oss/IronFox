#!/bin/bash

# Script is used to update the F-Droid
# This script is expected to be run in a CI environment
# DO NOT execute this manually!

set -eu

git clone --recurse-submodules "https://$IF_CI_USERNAME:$GITLAB_CI_PUSH_TOKEN@gitlab.com/$FDROID_REPO_PATH.git" fdroid
pushd fdroid || { echo "Unable to pushd into 'fdroid'"; exit 1; };
mkdir -p "$REPO_DIR_PATH"
git lfs install

# Download all assets from the release
curl --header "PRIVATE-TOKEN: $GITLAB_CI_API_TOKEN" \
"${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases/${CI_COMMIT_TAG}/assets/links" \
| jq -c '.[] | select(.name | endswith(".apk"))' \
| while read -r asset; do
    name=$(echo "$asset" | jq -r '.name')
    url=$(echo "$asset" | jq -r '.direct_asset_url')
    echo "Downloading $name from $url"
    curl -L --header "PRIVATE-TOKEN: $GITLAB_CI_API_TOKEN" "$url" -o "$REPO_DIR_PATH/$name"
done

# shellcheck disable=SC2046
IFS=":" read -r vercode vername <<< "$("$CI_PROJECT_DIR"/scripts/get_latest_version.py $(ls "$REPO_DIR_PATH"/*.apk))"

META_FILE_PATH="$META_DIR_PATH/$META_FILE_NAME"

sed -i \
    -e "s/CurrentVersion: .*/CurrentVersion: \"v$vername\"/" \
    -e "s/CurrentVersionCode: .*/CurrentVersionCode: $vercode/" "$META_FILE_PATH"

pushd "$META_DIR_PATH" || { echo "Unable to pushd into '$META_DIR_PATH'"; exit 1; }

# Update metadata repository
git add "$META_FILE_NAME"
git commit -m "feat: update for release ${CI_COMMIT_TAG}"
git push origin "HEAD:$META_REPO_BRANCH"

popd || { echo "Unable to popd from '$META_DIR_PATH'"; exit 1; }

# Update F-Droid repository
git add "$REPO_DIR_PATH" "$META_DIR_PATH"
git commit -m "feat: update for release ${CI_COMMIT_TAG}"
git push origin "HEAD:$FDROID_REPO_BRANCH"

popd # ignore error
