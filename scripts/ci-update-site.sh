#!/bin/bash

# Script is used to update the ironfoxoss.org website repository.
# This script is not intended to be executed manually!

set -euo pipefail

# Ensure this is never ran with xtrace...
set +x || exit 1

# Set-up our environment
function setup_env() {
  if [[ -z "${IRONFOX_SET_ENVS+x}" ]] || [[ "${IRONFOX_SET_ENVS}" != 1 ]]; then
    # Find dirname
    if [[ -n "${IRONFOX_DIRNAME+x}" ]] && [[ -x "${IRONFOX_DIRNAME}" ]]; then
      local -r dirname="${IRONFOX_DIRNAME}"
    elif [[ -x '/bin/dirname' ]]; then
      local -r dirname='/bin/dirname'
    elif [[ -x '/usr/bin/dirname' ]]; then
      local -r dirname='/usr/bin/dirname'
    else
      if ! command -v dirname > /dev/null 2>&1; then
        echo "ERROR: Missing dirname!" >&2
        return 1
      fi
      # It isn't a known location, so we sadly have to just fall-back to the PATH
      local -r dirname="$(dirname)"
    fi

    # Set-up our environment
    readonly IRONFOX_ENV_SH="$("${dirname}" $0)/env.sh"
    if [[ ! -f "${IRONFOX_ENV_SH}" ]] || [[ ! -s "${IRONFOX_ENV_SH}" ]]; then
      echo "ERROR: '${IRONFOX_ENV_SH}' is invalid!"
      return 1
    fi
    source "${IRONFOX_ENV_SH}" || return 1
  fi
}

# Set-up our environment
setup_env || exit 1

# Include download utilities
verify_file_with_env "${IRONFOX_DOWNLOAD_UTILS}" 'IRONFOX_DOWNLOAD_UTILS' || exit 1
source "${IRONFOX_DOWNLOAD_UTILS}" || exit 1

# Ensure we have `IRONFOX_CI`
verify_env "${IRONFOX_CI}" 'IRONFOX_CI' || exit 1

if [[ "${IRONFOX_CI}" != 1 ]]; then
  echo_red_text "ERROR: '$0' should only be called from CI!"
  exit 1
fi

# Ensure we have basename
verify_exec "${IRONFOX_BASENAME}" 'IRONFOX_BASENAME' || exit 1

# Ensure we have cat
verify_exec "${IRONFOX_CAT}" 'IRONFOX_CAT' || exit 1

# Ensure we have cp
verify_exec "${IRONFOX_CP}" 'IRONFOX_CP' || exit 1

# Ensure we have git
verify_exec "${IRONFOX_GIT}" 'IRONFOX_GIT' || exit 1

# Ensure we have GNU sed
verify_exec "${IRONFOX_SED}" 'IRONFOX_SED' || exit 1

# Ensure we have mkdir
verify_exec "${IRONFOX_MKDIR}" 'IRONFOX_MKDIR' || exit 1

# Ensure we have Python
verify_exec "${IRONFOX_PYTHON}" 'IRONFOX_PYTHON' || exit 1

# Ensure we have rm
verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

# Ensure we have touch
verify_exec "${IRONFOX_TOUCH}" 'IRONFOX_TOUCH' || exit 1

# Ensure we have xargs
verify_exec "${IRONFOX_XARGS}" 'IRONFOX_XARGS' || exit 1

# Ensure we have `IRONFOX_EXTERNAL`
verify_env "${IRONFOX_EXTERNAL}" 'IRONFOX_EXTERNAL' || exit 1

# Ensure we have `IRONFOX_VERSION`
verify_env "${IRONFOX_VERSION}" 'IRONFOX_VERSION' || exit 1

# Ensure we have `IRONFOX_TEMP`
verify_env "${IRONFOX_TEMP}" 'IRONFOX_TEMP' || exit 1

# Ensure we have `IRONFOX_SCRIPTS`
verify_dir_with_env "${IRONFOX_SCRIPTS}" 'IRONFOX_SCRIPTS' || exit 1

# Ensure we can source our Python environment
verify_file_with_env "${IRONFOX_PYENV}" 'IRONFOX_PYENV' || exit 1

# Constants

# Base URL
readonly IRONFOX_BASE_URL='https://ironfoxoss.org'

# Base releases URL
if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
  readonly IRONFOX_RELEASES_S3_PATH='releases'
else
  readonly IRONFOX_RELEASES_S3_PATH='nightly'
fi
readonly IRONFOX_RELEASES_BASE_URL="https://releases.ironfoxoss.org/ironfox/${IRONFOX_RELEASES_S3_PATH}"

# Git
readonly IRONFOX_GIT_EMAIL='ci@ironfoxoss.org'
readonly IRONFOX_GIT_NAME='IronFox CI'
readonly IRONFOX_GIT_USERNAME='ironfox-ci'

# Git repo
readonly IRONFOX_SITE_REPO="${IRONFOX_EXTERNAL}/ironfoxoss.org"
readonly IRONFOX_SITE_REPO_BRANCH='dev'
readonly IRONFOX_SITE_REPO_PATH='ironfox-oss/ironfoxoss.org'

# RSS email address
readonly IRONFOX_RSS_EMAIL='contact@ironfoxoss.org'

# Release version
if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
  readonly IRONFOX_RELEASE_VERSION="${IRONFOX_VERSION}"
else
  verify_env "${IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE}" 'IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE' || exit 1
  readonly IRONFOX_RELEASE_VERSION="${IRONFOX_VERSION}.${IRONFOX_NIGHTLY_TIMESTAMP_OVERRIDE}"
fi

# Release page URL
if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
  readonly IRONFOX_RELEASE_PAGE_URL="${IRONFOX_BASE_URL}/releases"
else
  readonly IRONFOX_RELEASE_PAGE_URL="${IRONFOX_RELEASES_BASE_URL}/${IRONFOX_RELEASE_VERSION}/universal/ironfox-nightly-${IRONFOX_RELEASE_VERSION}-universal.apk"
fi

# Set our external CI environment variables

## Commit SHA
verify_env "${CI_COMMIT_SHA}" 'CI_COMMIT_SHA' || exit 1
readonly IRONFOX_CI_COMMIT="${CI_COMMIT_SHA}"

# Configure Git
function configure_git() {
  # Ensure we have a push token...
  verify_env "${IRONFOX_GITLAB_CI_PUSH_TOKEN}" 'IRONFOX_GITLAB_CI_PUSH_TOKEN' || return 1

  # Ensure we have `IRONFOX_GIT_EMAIL`
  verify_env "${IRONFOX_GIT_EMAIL}" 'IRONFOX_GIT_EMAIL' || return 1

  # Ensure we have `IRONFOX_GIT_NAME`
  verify_env "${IRONFOX_GIT_NAME}" 'IRONFOX_GIT_NAME' || return 1

  # Ensure we have `IRONFOX_GIT_USERNAME`
  verify_env "${IRONFOX_GIT_USERNAME}" 'IRONFOX_GIT_USERNAME' || return 1

  echo_red_text 'Configuring Git...'
  "${IRONFOX_GIT}" config --global user.email "${IRONFOX_GIT_EMAIL}" || return 1
  "${IRONFOX_GIT}" config --global user.name "${IRONFOX_GIT_NAME}" || return 1
  "${IRONFOX_GIT}" config --global url."https://${IRONFOX_GIT_USERNAME}:${IRONFOX_GITLAB_CI_PUSH_TOKEN}@gitlab.com/".insteadOf "https://gitlab.com/" || return 1
  echo_green_text 'SUCCESS: Configured Git.'
}

configure_git || exit 1

# Clone the repo
clone_git_repo "https://${IRONFOX_GIT_USERNAME}:${IRONFOX_GITLAB_CI_PUSH_TOKEN}@gitlab.com/${IRONFOX_SITE_REPO_PATH}.git" "${IRONFOX_SITE_REPO}" 'no-revision' --silent || exit 1

pushd "${IRONFOX_SITE_REPO}" || exit 1

# Generate documentation for patches
source "${IRONFOX_PYENV}" || exit 1
"${IRONFOX_PYTHON}" ./scripts/gen_patch_pages.py "${IRONFOX_SCRIPTS}/patches.yaml" || exit 1

if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
  # Update version name
  "${IRONFOX_SED}" -i "s/IRONFOX_VERSION = .*/IRONFOX_VERSION = \"${IRONFOX_RELEASE_VERSION}\";/g" \
    ./src/version.ts || exit 1

  # Update release notes
  download "${IRONFOX_RELEASES_BASE_URL}/${IRONFOX_RELEASE_VERSION}/ironfox-${IRONFOX_RELEASE_VERSION}-release-notes.md" "${IRONFOX_RELEASE_VERSION}-temp.md" || exit 1

  "${IRONFOX_CP}" -f ./release-notes.md ./release-notes-temp.md || exit 1
  "${IRONFOX_RM}" -f ./release-notes.md || exit 1

  "${IRONFOX_SED}" -i "s|# IronFox ${IRONFOX_RELEASE_VERSION}||g" "${IRONFOX_RELEASE_VERSION}-temp.md" || exit 1
  {
    echo "<div id='${IRONFOX_RELEASE_VERSION}'>" || exit 1
    echo "  <h1>${IRONFOX_RELEASE_VERSION}</h1>" || exit 1
    echo "</div>" || exit 1
    "${IRONFOX_CAT}" "${IRONFOX_RELEASE_VERSION}-temp.md" || exit 1
    echo '' || exit 1
  } >> "${IRONFOX_RELEASE_VERSION}.md" || exit 1
  "${IRONFOX_RM}" -f "${IRONFOX_RELEASE_VERSION}-temp.md"

  "${IRONFOX_CAT}" "${IRONFOX_RELEASE_VERSION}.md" ./release-notes-temp.md > ./release-notes.md || exit 1
  "${IRONFOX_RM}" -f "${IRONFOX_RELEASE_VERSION}.md"
  "${IRONFOX_RM}" -f ./release-notes-temp.md

  "${IRONFOX_RM}" -f ./src/content/docs/releases.mdx || exit 1
  {
    echo '---' || exit 1
    echo 'title: IronFox releases' || exit 1
    echo '---' || exit 1
    echo '' || exit 1
    echo 'import { IRONFOX_VERSION } from "../../version.ts";' || exit 1
    echo 'import MarkdownLayout from "../../layouts/MarkdownLayout.astro";' || exit 1
    echo '' || exit 1
    echo '<MarkdownLayout>' || exit 1
    echo '' || exit 1
    echo '> Latest release: <a href={`https://ironfoxoss.org/releases/#${IRONFOX_VERSION}`} rel="noopener noreferrer me">{IRONFOX_VERSION}</a>' || exit 1
    echo '' || exit 1
    "${IRONFOX_CAT}" ./release-notes.md || exit 1
    echo '</MarkdownLayout>' || exit 1
  } >> ./src/content/docs/releases.mdx || exit 1
fi

# Update RSS
if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
  readonly if_rss_path='releases'
else
  readonly if_rss_path='nightly'
fi
"${IRONFOX_RM}" -f ./public/"${if_rss_path}"/rss.xml || exit 1
"${IRONFOX_MKDIR}" -p ./public/"${if_rss_path}" || exit 1

# The RSS feed only needs to include the last 3 releases
"${IRONFOX_MKDIR}" -p "${IRONFOX_TEMP}"
download "${IRONFOX_RELEASES_BASE_URL}/previous_release.txt" "${IRONFOX_TEMP}/previous_release.txt" || exit 1
download "${IRONFOX_RELEASES_BASE_URL}/previous_previous_release.txt" "${IRONFOX_TEMP}/previous_previous_release.txt" || exit 1

readonly IRONFOX_PREVIOUS_VERSION=$("${IRONFOX_CAT}" "${IRONFOX_TEMP}/previous_release.txt" | "${IRONFOX_XARGS}")
readonly IRONFOX_PREVIOUS_PREVIOUS_VERSION=$("${IRONFOX_CAT}" "${IRONFOX_TEMP}/previous_previous_release.txt" | "${IRONFOX_XARGS}")

for xml in ./rss/"${if_rss_path}"/*.xml; do
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
readonly IRONFOX_RSS_DATE="$("${IRONFOX_DATE}" +"%a, %d %b %Y %T")"

"${IRONFOX_MKDIR}" -p ./rss/"${if_rss_path}"
if [[ -f ./rss/"${if_rss_path}/${IRONFOX_RELEASE_VERSION}.xml" ]]; then
  echo_red_text "ERROR: '${if_rss_path}/${IRONFOX_RELEASE_VERSION}.xml' already exists!"
  exit 1
fi
"${IRONFOX_TOUCH}" ./rss/"${if_rss_path}/${IRONFOX_RELEASE_VERSION}.xml"
{
  echo '    <item>' || exit 1
  echo "      <title>IronFox ${IRONFOX_RELEASE_VERSION}</title>" || exit 1
  echo "      <link>${IRONFOX_RELEASE_PAGE_URL}/#${IRONFOX_RELEASE_VERSION}</link>" || exit 1
  echo "      <guid isPermaLink='true'>${IRONFOX_RELEASE_PAGE_URL}/#${IRONFOX_RELEASE_VERSION}</guid>" || exit 1
  echo "      <pubDate>${IRONFOX_RSS_DATE} GMT</pubDate>" || exit 1
  echo "      <author>${IRONFOX_RSS_EMAIL}</author>" || exit 1
  echo "      <enclosure url='${IRONFOX_BASE_URL}/ironfox.png' width='604' height='599' length='24128' type='image/png'/>" || exit 1
  echo "    </item>" || exit 1
} >> ./rss/"${if_rss_path}/${IRONFOX_RELEASE_VERSION}.xml" || exit 1

{
  "${IRONFOX_CAT}" ./templates/"${if_rss_path}.rss.xml" || exit 1
  "${IRONFOX_CAT}" ./rss/"${if_rss_path}/${IRONFOX_RELEASE_VERSION}.xml" || exit 1

  if [[ -f ./rss/"${if_rss_path}/${IRONFOX_PREVIOUS_VERSION}.xml" ]]; then
    "${IRONFOX_CAT}" ./rss/"${if_rss_path}/${IRONFOX_PREVIOUS_VERSION}.xml" || exit 1
  fi

  if [[ -f ./rss/"${if_rss_path}/${IRONFOX_PREVIOUS_PREVIOUS_VERSION}.xml" ]]; then
    "${IRONFOX_CAT}" ./rss/"${if_rss_path}/${IRONFOX_PREVIOUS_PREVIOUS_VERSION}.xml" || exit 1
  fi

  echo '  </channel>' || exit 1
  echo '</rss>' || exit 1
} >> ./public/"${if_rss_path}"/rss.xml || exit 1

# Indicate our target release channel (so that `ci-update-git.repo.sh` can handle it properly...)
"${IRONFOX_RM}" -f "${IRONFOX_SITE_REPO}/target-release" "${IRONFOX_SITE_REPO}/target-nightly" || exit 1
if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
  "${IRONFOX_TOUCH}" "${IRONFOX_SITE_REPO}/target-release" || exit 1
  "${IRONFOX_GIT}" add "${IRONFOX_SITE_REPO}/target-release" || exit 1
else
  "${IRONFOX_TOUCH}" "${IRONFOX_SITE_REPO}/target-nightly" || exit 1
  "${IRONFOX_GIT}" add "${IRONFOX_SITE_REPO}/target-nightly" || exit 1
fi

# Commit changes
"${IRONFOX_GIT}" add rss src public release-notes.md || exit 1
"${IRONFOX_GIT}" commit -m "feat: update patch docs to reflect ironfox-oss/IronFox@${IRONFOX_CI_COMMIT}" || exit 0
"${IRONFOX_GIT}" push origin "HEAD:${IRONFOX_SITE_REPO_BRANCH}" || exit 0

popd || exit 1
