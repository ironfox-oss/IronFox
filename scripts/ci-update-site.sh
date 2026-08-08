#!/bin/bash

# Script is used to update the ironfoxoss.org website repository.
# This script is not intended to be executed manually!

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
  export IRONFOX_CI=1
fi
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

# Set verbosity
if [[ "${IRONFOX_VERBOSE}" == 1 ]]; then
  set -x
else
  set +x
fi

"${IRONFOX_GIT}" clone "https://${IF_CI_USERNAME}:${GITLAB_CI_PUSH_TOKEN}@gitlab.com/${TARGET_REPO_PATH}.git" target-repo
cd target-repo || {
  echo "Unable to cd into target-repo"
  exit 1
}

# Generate documentation for patches
source "${IRONFOX_PYENV}"
"${IRONFOX_PYTHON}" ./scripts/gen_patch_pages.py ../scripts/patches.yaml

if [[ "${CI_COMMIT_REF_NAME}" == "${PRODUCTION_BRANCH}" ]]; then
  # Update version name
  "${IRONFOX_SED}" -i "s/IRONFOX_VERSION = .*/IRONFOX_VERSION = \"${IRONFOX_VERSION}\";/g" \
    ./src/version.ts

  # Update release notes
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location "https://releases.ironfoxoss.org/ironfox/releases/${IRONFOX_VERSION}/ironfox-${IRONFOX_VERSION}-release-notes.md" --output "${IRONFOX_VERSION}-temp.md"

  "${IRONFOX_CP}" -f ./release-notes.md ./release-notes-temp.md
  "${IRONFOX_RM}" -f ./release-notes.md

  "${IRONFOX_SED}" -i "s|# IronFox ${IRONFOX_VERSION}||g" "${IRONFOX_VERSION}-temp.md"
  {
    echo "<div id='${IRONFOX_VERSION}'>"
    echo "  <h1>${IRONFOX_VERSION}</h1>"
    echo "</div>"
    "${IRONFOX_CAT}" "${IRONFOX_VERSION}-temp.md"
    echo ''
  } >> "${IRONFOX_VERSION}.md"
  "${IRONFOX_RM}" -f "${IRONFOX_VERSION}-temp.md"

  "${IRONFOX_CAT}" "${IRONFOX_VERSION}.md" ./release-notes-temp.md > ./release-notes.md
  "${IRONFOX_RM}" -f "${IRONFOX_VERSION}.md"
  "${IRONFOX_RM}" -f ./release-notes-temp.md

  "${IRONFOX_RM}" -f ./src/content/docs/releases.mdx
  {
    echo '---'
    echo 'title: IronFox releases'
    echo '---'
    echo ''
    echo 'import { IRONFOX_VERSION } from "../../version.ts";'
    echo 'import MarkdownLayout from "../../layouts/MarkdownLayout.astro";'
    echo ''
    echo '<MarkdownLayout>'
    echo ''
    echo '> Latest release: <a href={`https://ironfoxoss.org/releases/#${IRONFOX_VERSION}`} rel="noopener noreferrer me">{IRONFOX_VERSION}</a>'
    echo ''
    "${IRONFOX_CAT}" ./release-notes.md
    echo '</MarkdownLayout>'
  } >> ./src/content/docs/releases.mdx
fi

# Commit changes
"${IRONFOX_GIT}" add src release-notes.md
"${IRONFOX_GIT}" commit -m "feat: update patch docs to reflect ironfox-oss/IronFox@${CI_COMMIT_SHA}"
"${IRONFOX_GIT}" push origin "HEAD:${TARGET_REPO_BRANCH}"
