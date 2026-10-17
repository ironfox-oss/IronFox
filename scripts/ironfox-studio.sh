#!/bin/bash
#
# Launch Android Studio with IronFox's build environment.
#
# Usage: ironfox-studio [project]
#
# Projects opened from the Gecko tree, each from the directory IronFox itself builds it from:
#   fenix         Fenix (default)
#   ironfox-core  IronFox Core
#   ac            Android Components
#   ac-core       Android Components (core only)
#   geckoview     GeckoView (opened from the Gecko root)
#
# Standalone projects, opened from their own directory:
#   as            Application Services
#   glean         Glean
#   microg        microG (gmscore)
#
# Close Studio before running this: a running instance keeps its own environment and ignores the one set up here.
#
# Environment overrides:
#   IRONFOX_STUDIO               Studio launcher to run (default: studio)
#   IRONFOX_MACH_TARGET_ARCH     arm64, arm, x86_64 or bundle (default: arm64)

set -euo pipefail

# Exported before sourcing env.sh so it does not look for root.txt next to this script
IRONFOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export IRONFOX_ROOT

function usage() {
  sed -n '3,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

readonly project="${1:-fenix}"
case "${project}" in
  -h | --help | help)
    usage
    exit 0
    ;;
esac

# Resolved before sourcing env.sh, which replaces PATH
studio="$(command -v "${IRONFOX_STUDIO:-studio}" || true)"
readonly studio
if [[ -z "${studio}" ]]; then
  echo "ERROR: '${IRONFOX_STUDIO:-studio}' was not found! Add it to your PATH or set IRONFOX_STUDIO." >&2
  exit 1
fi

source "${IRONFOX_ROOT}/scripts/env.sh"

# Studio's Gradle sync does not receive the -D flags IronFox passes on the command line, so without this it
# looks for the locally built Glean and Application Services artifacts in ~/.m2 and fails to find them
function write_gradle_properties() {
  local -r file="${IRONFOX_GRADLE_HOME}/gradle.properties"
  mkdir -p "${IRONFOX_GRADLE_HOME}"
  touch "${file}"
  sed -i '/^# BEGIN ironfox-studio$/,/^# END ironfox-studio$/d' "${file}"
  cat >> "${file}" << PROPERTIES
# BEGIN ironfox-studio
systemProp.maven.repo.local=${IRONFOX_MAVEN_LOCAL}
systemProp.ndk.dir=${IRONFOX_ANDROID_NDK}
systemProp.android.builder.sdkDownload=false
# END ironfox-studio
PROPERTIES
}

write_gradle_properties

case "${project}" in
  fenix) gecko_target='fenix' gecko_subdir='mobile/android/fenix' ;;
  ironfox-core) gecko_target='ironfox-core' gecko_subdir='ironfox/android' ;;
  ac) gecko_target='android-components' gecko_subdir='mobile/android/android-components' ;;
  ac-core) gecko_target='ac-core' gecko_subdir='mobile/android/android-components' ;;
  geckoview) gecko_target='geckoview' gecko_subdir='' ;;
  as) standalone_dir="${IRONFOX_AS}" ;;
  glean) standalone_dir="${IRONFOX_GLEAN}" ;;
  microg) standalone_dir="${IRONFOX_GMSCORE}" ;;
  *)
    echo "ERROR: Unknown project '${project}'!" >&2
    usage >&2
    exit 1
    ;;
esac

if [[ -n "${gecko_target+x}" ]]; then
  export IRONFOX_MACH_TARGET_ARCH="${IRONFOX_MACH_TARGET_ARCH:-arm64}"
  export IRONFOX_MACH_TARGET_PROJECT="${gecko_target}"
  readonly project_dir="${IRONFOX_GECKO}${gecko_subdir:+/${gecko_subdir}}"
else
  readonly project_dir="${standalone_dir}"
fi

if [[ ! -d "${project_dir}" ]]; then
  echo "ERROR: '${project_dir}' does not exist! Fetch the sources for '${project}' first." >&2
  exit 1
fi

exec "${studio}" "${project_dir}"
