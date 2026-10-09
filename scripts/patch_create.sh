#!/bin/bash

set -euo pipefail

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
        exit 1
      fi
      # It isn't a known location, so we sadly have to just fall-back to the PATH
      local -r dirname="$(dirname)"
    fi

    # Set-up our environment
    readonly IRONFOX_ENV_SH="$("${dirname}" $0)/env.sh"
    if [[ ! -f "${IRONFOX_ENV_SH}" ]] || [[ ! -s "${IRONFOX_ENV_SH}" ]]; then
      echo "ERROR: '${IRONFOX_ENV_SH}' is invalid!"
      exit 1
    fi
    source "${IRONFOX_ENV_SH}" || exit 1
  fi
}

# Set-up our environment
setup_env

# Set verbosity
set_verbosity

# Ensure we have git
verify_exec "${IRONFOX_GIT}" 'IRONFOX_GIT' || exit 1

# Ensure we have rm
verify_exec "${IRONFOX_RM}" 'IRONFOX_RM' || exit 1

# Ensure we have sleep
verify_exec "${IRONFOX_SLEEP}" 'IRONFOX_SLEEP' || exit 1

# Ensure we have `IRONFOX_AS`
verify_env "${IRONFOX_AS}" 'IRONFOX_AS' || exit 1

# Ensure we have `IRONFOX_GECKO`
verify_env "${IRONFOX_GECKO}" 'IRONFOX_GECKO' || exit 1

# Ensure we have `IRONFOX_GLEAN`
verify_env "${IRONFOX_GLEAN}" 'IRONFOX_GLEAN' || exit 1

# Ensure we have `IRONFOX_PATCHES`
verify_dir_with_env "${IRONFOX_PATCHES}" 'IRONFOX_PATCHES' || exit 1

# Set timezone to UTC for consistency
unset TZ
export TZ='UTC'

echo -e ""
echo_red_text "Welcome to the IronFox patch creation script!"

echo_green_text "Which (root) project would you like to patch?"
echo "Your options are:"
echo_green_text "1. Application Services - '${IRONFOX_AS}'"
echo_green_text "2. Gecko - '${IRONFOX_GECKO}'"
echo_red_text "3. Glean - '${IRONFOX_GLEAN}'"
read -r -p 'Please enter your desired project: ' PROJECT
case ${PROJECT} in
  "application services" | "application Services" | "Application services" | "Application Services" | "APPLICATION SERVICES" | \
    "application-services" | "app-services" | "as" | "AS" | 1)
    # Ensure we have `IRONFOX_AS`
    verify_dir_with_env "${IRONFOX_AS}" 'IRONFOX_AS' || exit 1

    pushd "${IRONFOX_AS}"
    readonly PROJECT='AS'
    ;;

  "gecko" | "Gecko" | "GECKO" | "firefox" | "Firefox" | "FIREFOX" | "mozilla-central" | "mozilla-release" | 2)
    # Ensure we have `IRONFOX_GECKO`
    verify_dir_with_env "${IRONFOX_GECKO}" 'IRONFOX_GECKO' || exit 1

    pushd "${IRONFOX_GECKO}"
    readonly PROJECT='gecko'
    ;;

  "glean" | "Glean" | "GLEAN" | 3)
    # Ensure we have `IRONFOX_GLEAN`
    verify_dir_with_env "${IRONFOX_GLEAN}" 'IRONFOX_GLEAN' || exit 1

    pushd "${IRONFOX_GLEAN}"
    readonly PROJECT='glean'
    ;;

  *)
    echo_red_text "Invalid option"
    exit 1
    ;;
esac

echo_green_text "What would you like to name your patch?"
echo_red_text "NOTE: Patch names should be prefixed with the component they're targetting, ex:"
echo_green_text "For Android Components: a-c-patch-name"
echo_green_text "For Application Services: a-s-patch-name"
echo_green_text "For Fenix: fenix-patch-name"
echo_green_text "For GeckoView: geckoview-patch-name"
echo_green_text "For anywhere else in the Firefox/Gecko repository: gecko-patch-name"
echo_green_text "For Glean: glean-patch-name"
read -rp 'Please enter your desired patch name: ' PATCH_NAME

# Ensure the patch doesn't already exist
if [[ -f "${IRONFOX_PATCHES}/${PATCH_NAME}.patch" ]]; then
  echo_red_text "WARNING: A Patch with your chosen name already exists"
  read -rp 'Are you sure you want to continue? (y/n): ' OVERWRITE
  case ${OVERWRITE} in
    "y" | "Y" | "yes" | "Yes" | "YES")
      echo_green_text "Removing '${IRONFOX_PATCHES}/${PATCH_NAME}.patch'..."
      "${IRONFOX_RM}" -f "${IRONFOX_PATCHES}/${PATCH_NAME}.patch"
      ;;

    "n" | "N" | "no" | "No" | "NO")
      read -rp 'Please enter a different patch name: ' PATCH_NAME
      ;;

    *)
      echo_red_text "Invalid option"
      exit 1
      ;;
  esac
fi

echo_red_text "Creating patch: '${IRONFOX_PATCHES}/${PATCH_NAME}.patch'..."

# Create temporary branch, named after our patch
"${IRONFOX_GIT}" checkout -b "${PATCH_NAME}"
echo_red_text "Created temporary git branch for our changes..."

echo_green_text "Please now make your desired changes to the target project."
"${IRONFOX_SLEEP}" 5
echo
echo_red_text "Press enter to continue."
read -r

read -rp 'Please enter your desired patch message: ' PATCH_MSG

# Commit our changes
"${IRONFOX_GIT}" commit -am "${PATCH_MSG}" --sign

# Now, create our patch...
"${IRONFOX_GIT}" format-patch -1 --stdout > "${IRONFOX_PATCHES}/${PATCH_NAME}.patch"

# Finally, switch back to the original branch, and remove our temporary branch
"${IRONFOX_GIT}" checkout main
"${IRONFOX_GIT}" branch -D "${PATCH_NAME}"

echo_green_text "SUCCESS: Created patch: '${IRONFOX_PATCHES}/${PATCH_NAME}.patch'! :)"
