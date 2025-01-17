#!/bin/bash

# This file is expected to be executed in GitLab CI
# DO NOT executed this manually!

upload_to_package_registry() {
    local file="$1"
    local package_name="$2"
    local file_name="$(basename "$file")"

    curl --header "PRIVATE-TOKEN: $GITLAB_CI_API_TOKEN" \
        --upload-file "$file" \
        "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${package_name}/${VERSION_NAME}/${file_name}"
}

create_asset_link() {
    local name="$1"
    local url="$2"
    
    curl --request POST \
        --header "PRIVATE-TOKEN: $GITLAB_CI_API_TOKEN" \
        --data name="${name}" \
        --data url="${url}" \
        --data direct_asset_path="/${name}" \
        --data link_type="package" \
        "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases/v${VERSION_NAME}/assets/links"
}

export ARTIFACTS=$CI_PROJECT_DIR/artifacts
export APK_ARTIFACTS=$ARTIFACTS/apk
export APKS_ARTIFACTS=$ARTIFACTS/apks

RELEASE_NOTES_FILE=/opt/IronFox/release-notes.md
CHECKSUMS_FILE=/opt/IronFox/asset-checksums

declare -a asset_flags

# Upload packages to package registry
for apk in "$APK_ARTIFACTS"/*.apk; do
    package_name="apk"
    file_name="$(basename "$apk")"
    sha256sum -b "$apk" >> "$CHECKSUMS_FILE"
    upload_to_package_registry "$apk" "$package_name"

    asset_flags+=(--assets-link "{
        \"name\": \"$file_name\",
        \"url\": \"${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${package_name}/${VERSION_NAME}/${file_name}\",
        \"link_type\": \"package\",
        \"direct_asset_path\": \"/${file_name}\"
    }")
done
for apks in "$APKS_ARTIFACTS"/*.apks; do
    package_name="apkset"
    file_name=$(basename "$apks")
    sha256sum -b "$apks" >> "$CHECKSUMS_FILE"
    upload_to_package_registry "$apks" "$package_name"

    asset_flags+=(--assets-link "{
        \"name\": \"$file_name\",
        \"url\": \"${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${package_name}/${VERSION_NAME}/${file_name}\",
        \"link_type\": \"package\",
        \"direct_asset_path\": \"/${file_name}\"
    }")
done

{
    if [[ -f "$CI_PROJECT_DIR/${VERSION_NAME}.md" ]]; then
        cat "$CI_PROJECT_DIR/${VERSION_NAME}.md"
    fi
    echo "## Checksums"
    echo ""
    echo "\`\`\`"
    cat $CHECKSUMS_FILE
    echo ""
    echo "\`\`\`"
    echo ""

    echo "---"
    echo "_This is an automated release created by CI/CD [pipeline]($CI_JOB_URL)._"
    echo ""
} >> $RELEASE_NOTES_FILE

# Create a release
release-cli \
    --server-url "$CI_SERVER_URL" \
    --project-id "$CI_PROJECT_ID" \
    --private-token "$GITLAB_CI_API_TOKEN" \
    create \
    --name "IronFox v${VERSION_NAME}" \
    --description "$(cat $RELEASE_NOTES_FILE)" \
    --tag-name "v${VERSION_NAME}" \
    "${asset_flags[@]}"
