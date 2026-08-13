#!/bin/bash

# Script is used to update the ironfoxoss.org website repository.
# This script is not intended to be executed manually!

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
  export IRONFOX_CI=1
fi
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  /bin/bash "$(realpath $(dirname "$0"))/env.sh"
fi
source "$(realpath $(dirname "$0"))/env.sh"

# Include utilities
source "${IRONFOX_UTILS}"

# Constants
readonly IRONFOX_TARGET_REPO="${IRONFOX_EXTERNAL}/ironfoxoss.org"
readonly IRONFOX_TARGET_REPO_BRANCH='dev'
readonly IRONFOX_TARGET_REPO_PATH='ironfox-oss/ironfoxoss.org'

"${IRONFOX_GIT}" clone "https://${IF_CI_USERNAME}:${IRONFOX_GITLAB_CI_PUSH_TOKEN}@gitlab.com/${IRONFOX_TARGET_REPO_PATH}.git" "${IRONFOX_TARGET_REPO}"

pushd "${IRONFOX_TARGET_REPO}"

# Generate documentation for patches
source "${IRONFOX_PYENV}"
"${IRONFOX_PYTHON}" ./scripts/gen_patch_pages.py "${IRONFOX_SCRIPTS}/patches.yaml"

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

  # Update RSS
  "${IRONFOX_RM}" -f ./public/releases/rss.xml

  # The RSS feed only needs to include the last 3 releases
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location 'https://releases.ironfoxoss.org/ironfox/releases/previous_release.txt' --output "${IRONFOX_ROOT}/previous_release.txt"
  "${IRONFOX_CURL}" ${IRONFOX_CURL_FLAGS} --location 'https://releases.ironfoxoss.org/ironfox/releases/previous_previous_release.txt' --output "${IRONFOX_ROOT}/previous_previous_release.txt"

  readonly IRONFOX_PREVIOUS_VERSION=$("${IRONFOX_CAT}" "${IRONFOX_ROOT}/previous_release.txt" | "${IRONFOX_XARGS}")
  readonly IRONFOX_PREVIOUS_PREVIOUS_VERSION=$("${IRONFOX_CAT}" "${IRONFOX_ROOT}/previous_previous_release.txt" | "${IRONFOX_XARGS}")

  for xml in ./rss/releases/*.xml; do
    xml_basename=$("${IRONFOX_BASENAME}" "${xml}")
    if [[ "${xml_basename}" != "${IRONFOX_PREVIOUS_VERSION}.xml" ]] &&
      [[ "${xml_basename}" != "${IRONFOX_PREVIOUS_PREVIOUS_VERSION}.xml" ]]; then
      "${IRONFOX_RM}" -vf "${xml}"
    fi
  done

  # Set timezone to UTC for consistency
  unset TZ
  export TZ='UTC'

  # Set RSS publication date/time
  readonly RSS_DATE="$("${IRONFOX_DATE}" +"%a, %d %b %Y %T")"

  {
    echo '    <item>'
    echo "      <title>IronFox ${IRONFOX_VERSION}</title>"
    echo "      <link>https://ironfoxoss.org/releases/#${IRONFOX_VERSION}</link>"
    echo "      <guid isPermaLink='true'>https://ironfoxoss.org/releases/#${IRONFOX_VERSION}</guid>"
    echo "      <pubDate>${RSS_DATE} GMT</pubDate>"
    echo "      <author>contact@ironfoxoss.org</author>"
    echo "      <enclosure url='https://ironfoxoss.org/ironfox.png' width='604' height='599' length='24128' type='image/png'/>"
    echo "    </item>"
  } >> ./rss/releases/"${IRONFOX_VERSION}.xml"

  {
    "${IRONFOX_CAT}" ./templates/releases.rss.xml
    "${IRONFOX_CAT}" ./rss/releases/"${IRONFOX_VERSION}.xml"

    if [[ -f ./rss/releases/"${IRONFOX_PREVIOUS_VERSION}.xml" ]]; then
      "${IRONFOX_CAT}" ./rss/releases/"${IRONFOX_PREVIOUS_VERSION}.xml"
    fi

    if [[ -f ./rss/releases/"${IRONFOX_PREVIOUS_PREVIOUS_VERSION}.xml" ]]; then
      "${IRONFOX_CAT}" ./rss/releases/"${IRONFOX_PREVIOUS_PREVIOUS_VERSION}.xml"
    fi

    echo '  </channel>'
    echo '</rss>'
  } >> ./public/releases/rss.xml
fi

# Commit changes
"${IRONFOX_GIT}" add rss src public release-notes.md
"${IRONFOX_GIT}" commit -m "feat: update patch docs to reflect ironfox-oss/IronFox@${CI_COMMIT_SHA}" || exit 0
"${IRONFOX_GIT}" push origin "HEAD:${IRONFOX_TARGET_REPO_BRANCH}" || exit 0

popd
