#!/bin/bash

set -euo pipefail

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Include version info
source "${IRONFOX_VERSIONS}"

# Set timezone to UTC for consistency
unset TZ
export TZ="UTC"

echo -e ""
echo_red_text "Welcome to the IronFox patch creation script!"

echo_green_text "Which (root) project would you like to patch?"
echo "Your options are:"
echo_green_text "1. Application Services - ${IRONFOX_AS}"
echo_green_text "2. Gecko - ${IRONFOX_GECKO}"
echo_red_text "3. Glean - ${IRONFOX_GLEAN}"
read -p 'Please enter your desired project: ' PROJECT
case ${PROJECT} in
	"application services" | "application Services" | "Application services" | "Application Services" | "APPLICATION SERVICES" | "application-services" | "app-services" | "as" | "AS" | 1)
		pushd "${IRONFOX_AS}"
        PROJECT='AS'
		;;

	"gecko" | "Gecko" | "GECKO" | "firefox" | "Firefox" | "FIREFOX" | "mozilla-central" | "mozilla-release" | 2)
		pushd "${IRONFOX_GECKO}"
        PROJECT='gecko'
		;;

	"glean" | "Glean" | "GLEAN" | 3)
		pushd "${IRONFOX_GLEAN}"
        PROJECT='glean'
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
read -p 'Please enter your desired patch name: ' PATCH_NAME

# Ensure the patch doesn't already exist
if [ -f "${IRONFOX_PATCHES}/${PATCH_NAME}.patch" ]; then
    echo_red_text "WARNING: A Patch with your chosen name already exists"
    read -p 'Are you sure you want to continue? (y/n): ' OVERWRITE
    case ${OVERWRITE} in
	"y" | "Y" | "yes" | "Yes" | "YES")
		echo_green_text "Removing ${IRONFOX_PATCHES}/${PATCH_NAME}.patch..."
        rm -f "${IRONFOX_PATCHES}/${PATCH_NAME}.patch"
		;;

	"n" | "N" | "no" | "No" | "NO")
		read -p 'Please enter a different patch name: ' PATCH_NAME
		;;

	*)
		echo_red_text "Invalid option"
		exit 1
		;;
esac
fi

echo_red_text "Creating patch..."

# Create temporary branch, named after our patch
git checkout -b "${PATCH_NAME}"
echo_red_text "Created temporary git branch for our changes..."

echo_green_text "Please now make your desired changes to the target project."
sleep 5
echo
echo_red_text "Press enter to continue."
read

read -p 'Please enter your desired patch message: ' PATCH_MSG

# Commit our changes
git commit -am "${PATCH_MSG}" --sign

# Now, create our patch...
git format-patch -1 --stdout >"${IRONFOX_PATCHES}/${PATCH_NAME}.patch"

# Finally, switch back to the original branch, and remove our temporary branch
if [ "${PROJECT}" == 'AS' ]; then
    git checkout "${APPSERVICES_COMMIT}"
elif [ "${PROJECT}" == 'glean' ]; then
    git checkout "${GLEAN_COMMIT}"
else
    git checkout "${FIREFOX_COMMIT}"
fi
git branch -D "${PATCH_NAME}"

echo_green_text "SUCCESS: Created patch: ${IRONFOX_PATCHES}/${PATCH_NAME}.patch :)"
