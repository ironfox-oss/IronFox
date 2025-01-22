#!/bin/bash

# Script is used to update the F-Droid
# This script is expected to be run in a CI environment
# DO NOT execute this manually!

git clone "https://oauth2:$GITLAB_CI_PUSH_TOKEN@gitlab.com/$TARGET_REPO_PATH.git" target-repo
cd target-repo || { echo "Unable to cd into target-repo"; exit 1; };
mkdir -p "$REPO_DIR"

# Download all assets from the release
curl --header "PRIVATE-TOKEN: $GITLAB_CI_API_TOKEN" \
"${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases/${CI_COMMIT_TAG}/assets/links" \
| jq -c '.[] | select(.name | endswith(".apk"))' \
| while read -r asset; do
    name=$(echo "$asset" | jq -r '.name')
    url=$(echo "$asset" | jq -r '.direct_asset_url')
    echo "Downloading $name from $url"
    curl -L --header "PRIVATE-TOKEN: $GITLAB_CI_API_TOKEN" "$url" -o "$REPO_DIR/$name"
done

IFS=":" read -r vercode vername <<< "$("$CI_PROJECT_DIR"/scripts/get_latest_version.py "$(ls "$REPO_DIR"/*.apk)")"

sed -i \
    -e "s/CurrentVersion: .*/CurrentVersion: \"$vername\"/" \
    -e "s/CurrentVersionCode: .*/CurrentVersionCode: $vercode/" "$META_FILE"

git add "$REPO_DIR" "$META_FILE"
git commit -m "feat: update for release ${CI_COMMIT_TAG}"
git push origin "HEAD:$TARGET_REPO_BRANCH"