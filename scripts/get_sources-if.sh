#!/bin/bash

set -euo pipefail

# Set-up our environment
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [[ -z "${IRONFOX_FROM_SOURCES+x}" ]]; then
    echo_red_text "ERROR: Do not call get_sources-if.sh directly. Instead, use get_sources.sh." >&1
    exit 1
fi

readonly target="$1"
readonly mode="$2"

# Set-up target parameters
IRONFOX_GET_SOURCE_ANDROID_NDK=0
IRONFOX_GET_SOURCE_ANDROID_SDK=0
IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS=0
IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35=0
IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM=0
IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36=0
IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS=0
IRONFOX_GET_SOURCE_AS=0
IRONFOX_GET_SOURCE_BUNDLETOOL=0
IRONFOX_GET_SOURCE_CBINDGEN=0
IRONFOX_GET_SOURCE_GECKO=0
IRONFOX_GET_SOURCE_GECKO_L10N=0
IRONFOX_GET_SOURCE_GLEAN=0
IRONFOX_GET_SOURCE_GLEAN_PARSER=0
IRONFOX_GET_SOURCE_GRADLE=0
IRONFOX_GET_SOURCE_GYP=0
IRONFOX_GET_SOURCE_JDK_17=0
IRONFOX_GET_SOURCE_JDK_21=0
IRONFOX_GET_SOURCE_JDK_25=0
IRONFOX_GET_SOURCE_MICROG=0
IRONFOX_GET_SOURCE_NODE=0
IRONFOX_GET_SOURCE_NPM=0
IRONFOX_GET_SOURCE_PHOENIX=0
IRONFOX_GET_SOURCE_PIP=0
IRONFOX_GET_SOURCE_PREBUILDS=0
IRONFOX_GET_SOURCE_PYTHON=0
IRONFOX_GET_SOURCE_RUST=0
IRONFOX_GET_SOURCE_S3CMD=0
IRONFOX_GET_SOURCE_UNIFFI=0
IRONFOX_GET_SOURCE_UP_AC=0
IRONFOX_GET_SOURCE_UV=0
IRONFOX_GET_SOURCE_WASI=0

if [ "${target}" == 'android-ndk' ]; then
    # Get Android NDK
    IRONFOX_GET_SOURCE_ANDROID_NDK=1
elif [ "${target}" == 'android-sdk' ]; then
    # Get Android SDK
    IRONFOX_GET_SOURCE_ANDROID_SDK=1
elif [ "${target}" == 'android-sdk-build-tools' ]; then
    # Get Android SDK Build Tools (latest)
    IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS=1
elif [ "${target}" == 'android-sdk-build-tools-35' ]; then
    # Get Android SDK Build Tools (35) (Required by Glean)
    IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35=1
elif [ "${target}" == 'android-sdk-platform' ]; then
    # Get Android SDK Platform (latest)
    IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM=1
elif [ "${target}" == 'android-sdk-platform-36' ]; then
    # Get Android SDK Platform (36)
    IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36=1
elif [ "${target}" == 'android-sdk-platform-tools' ]; then
    # Get Android SDK Platform Tools
    IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS=1
elif [ "${target}" == 'as' ]; then
    # Get Application Services
    IRONFOX_GET_SOURCE_AS=1
elif [ "${target}" == 'bundletool' ]; then
    # Get + set-up Bundletool
    IRONFOX_GET_SOURCE_BUNDLETOOL=1
elif [ "${target}" == 'cbindgen' ]; then
    # Get cbindgen
    IRONFOX_GET_SOURCE_CBINDGEN=1
elif [ "${target}" == 'firefox' ]; then
    # Get Firefox (Gecko/mozilla-central)
    IRONFOX_GET_SOURCE_GECKO=1
elif [ "${target}" == 'firefox-l10n' ]; then
    # Get firefox-l10n
    IRONFOX_GET_SOURCE_GECKO_L10N=1
elif [ "${target}" == 'glean' ]; then
    # Get Glean
    IRONFOX_GET_SOURCE_GLEAN=1
elif [ "${target}" == 'glean-parser' ]; then
    # Get glean-parser
    IRONFOX_GET_SOURCE_GLEAN_PARSER=1
elif [ "${target}" == 'gradle' ]; then
    # Get + set-up Gradle
    IRONFOX_GET_SOURCE_GRADLE=1
elif [ "${target}" == 'gyp' ]; then
    # Get gyp-next
    IRONFOX_GET_SOURCE_GYP=1
elif [ "${target}" == 'jdk-17' ]; then
    # Get OpenJDK (17) (Required by GeckoView)
    IRONFOX_GET_SOURCE_JDK_17=1
elif [ "${target}" == 'jdk-21' ]; then
    # Get OpenJDK (21)
    IRONFOX_GET_SOURCE_JDK_21=1
elif [ "${target}" == 'jdk-25' ]; then
    # Get OpenJDK (25)
    IRONFOX_GET_SOURCE_JDK_25=1
elif [ "${target}" == 'microg' ]; then
    # Get microG
    IRONFOX_GET_SOURCE_MICROG=1
elif [ "${target}" == 'node' ]; then
    # Get + set-up Node.js
    IRONFOX_GET_SOURCE_NODE=1
elif [ "${target}" == 'npm' ]; then
    # Get + set-up npm
    IRONFOX_GET_SOURCE_NPM=1
elif [ "${target}" == 'phoenix' ]; then
    # Get Phoenix
    IRONFOX_GET_SOURCE_PHOENIX=1
elif [ "${target}" == 'prebuilds' ]; then
    # Get the IronFox prebuilds repo
    IRONFOX_GET_SOURCE_PREBUILDS=1
elif [ "${target}" == 'pip' ]; then
    # Get + set-up pip
    IRONFOX_GET_SOURCE_PIP=1
elif [ "${target}" == 'python' ]; then
    # Get Python
    IRONFOX_GET_SOURCE_PYTHON=1
elif [ "${target}" == 'rust' ]; then
    # Get + set-up rust/cargo
    IRONFOX_GET_SOURCE_RUST=1
elif [ "${target}" == 's3cmd' ]; then
    # Get s3cmd
    ## NOTE: This isn't installed if "all" is used below, as it's only used in CI and targeted specifically when it's needed
    IRONFOX_GET_SOURCE_S3CMD=1
elif [ "${target}" == 'uniffi' ]; then
    # Get uniffi
    IRONFOX_GET_SOURCE_UNIFFI=1
elif [ "${target}" == 'up-ac' ]; then
    # Get UnifiedPush-AC
    IRONFOX_GET_SOURCE_UP_AC=1
elif [ "${target}" == 'uv' ]; then
    # Get + set-up uv
    IRONFOX_GET_SOURCE_UV=1
elif [ "${target}" == 'wasi' ]; then
    # Get WASI SDK
    IRONFOX_GET_SOURCE_WASI=1
elif [ "${target}" == 'all' ]; then
    # If no argument is specified (or argument is set to "all"), just get everything
    IRONFOX_GET_SOURCE_ANDROID_NDK=1
    IRONFOX_GET_SOURCE_ANDROID_SDK=1
    IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS=1
    IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35=1
    IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM=1
    IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36=1
    IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS=1
    IRONFOX_GET_SOURCE_AS=1
    IRONFOX_GET_SOURCE_BUNDLETOOL=1
    IRONFOX_GET_SOURCE_CBINDGEN=1
    IRONFOX_GET_SOURCE_GECKO=1
    IRONFOX_GET_SOURCE_GECKO_L10N=1
    IRONFOX_GET_SOURCE_GLEAN=1
    IRONFOX_GET_SOURCE_GLEAN_PARSER=1
    IRONFOX_GET_SOURCE_GRADLE=1
    IRONFOX_GET_SOURCE_GYP=1
    IRONFOX_GET_SOURCE_JDK_17=1
    IRONFOX_GET_SOURCE_JDK_21=1
    IRONFOX_GET_SOURCE_JDK_25=1
    IRONFOX_GET_SOURCE_MICROG=1
    IRONFOX_GET_SOURCE_NODE=1
    IRONFOX_GET_SOURCE_NPM=1
    IRONFOX_GET_SOURCE_PHOENIX=1
    IRONFOX_GET_SOURCE_PIP=1
    IRONFOX_GET_SOURCE_PYTHON=1
    IRONFOX_GET_SOURCE_RUST=1
    IRONFOX_GET_SOURCE_UP_AC=1
    IRONFOX_GET_SOURCE_UV=1

    if [ "${IRONFOX_NO_PREBUILDS}" == 1 ]; then
        # If IRONFOX_NO_PREBUILDS is true, we need to get the Prebuilds repo (so that they can be built from source)
        IRONFOX_GET_SOURCE_PREBUILDS=1
    else
        # Otherwise,by default, we can just download the prebuilds directly
        IRONFOX_GET_SOURCE_UNIFFI=1
        IRONFOX_GET_SOURCE_WASI=1
    fi
else
    echo_red_text "ERROR: Invalid target: ${target}\n You must enter one of the following:"
    echo 'All:                              all (Default)'
    echo 'Android NDK:                      android-ndk'
    echo 'Android SDK:                      android-sdk'
    echo 'Android SDK Build Tools (latest): android-sdk-build-tools'
    echo 'Android SDK Build Tools (35.0.0): android-sdk-build-tools-35'
    echo 'Android SDK Platform (latest):    android-sdk-platform'
    echo 'Android SDK Platform (36):        android-sdk-platform-36'
    echo 'Android SDK Platform Tools:       android-sdk-platform-tools'
    echo 'Application Services:             as'
    echo 'Bundletool:                       bundletool'
    echo 'cbindgen:                         cbindgen'
    echo 'Firefox (Gecko/mozilla-central):  firefox'
    echo 'firefox-l10n (l10n-central):      firefox-l10n'
    echo 'Glean:                            glean'
    echo 'Glean Parser:                     glean-parser'
    echo 'Gradle:                           gradle'
    echo 'GYP:                              gyp'
    echo 'JDK (17):                         jdk-17'
    echo 'JDK (21):                         jdk-21'
    echo 'JDK (25):                         jdk-25'
    echo 'microG:                           microg'
    echo 'Node.js:                          node'
    echo 'npm:                              npm'
    echo 'Phoenix:                          phoenix'
    echo 'pip:                              pip'
    echo 'Prebuilds repo:                   prebuilds'
    echo 'Python:                           python'
    echo 'Rust:                             rust'
    echo 's3cmd:                            s3cmd'
    echo 'UnifiedPush-AC:                   up-ac'
    echo 'uniffi-bindgen:                   uniffi'
    echo 'uv:                               uv'
    echo 'WASI SDK:                         wasi'
    exit 1
fi

readonly IRONFOX_GET_SOURCE_ANDROID_NDK
readonly IRONFOX_GET_SOURCE_ANDROID_SDK
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36
readonly IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS
readonly IRONFOX_GET_SOURCE_AS
readonly IRONFOX_GET_SOURCE_BUNDLETOOL
readonly IRONFOX_GET_SOURCE_CBINDGEN
readonly IRONFOX_GET_SOURCE_GECKO
readonly IRONFOX_GET_SOURCE_GECKO_L10N
readonly IRONFOX_GET_SOURCE_GLEAN
readonly IRONFOX_GET_SOURCE_GLEAN_PARSER
readonly IRONFOX_GET_SOURCE_GRADLE
readonly IRONFOX_GET_SOURCE_GYP
readonly IRONFOX_GET_SOURCE_JDK_17
readonly IRONFOX_GET_SOURCE_JDK_21
readonly IRONFOX_GET_SOURCE_JDK_25
readonly IRONFOX_GET_SOURCE_MICROG
readonly IRONFOX_GET_SOURCE_NODE
readonly IRONFOX_GET_SOURCE_NPM
readonly IRONFOX_GET_SOURCE_PHOENIX
readonly IRONFOX_GET_SOURCE_PIP
readonly IRONFOX_GET_SOURCE_PREBUILDS
readonly IRONFOX_GET_SOURCE_PYTHON
readonly IRONFOX_GET_SOURCE_RUST
readonly IRONFOX_GET_SOURCE_S3CMD
readonly IRONFOX_GET_SOURCE_UNIFFI
readonly IRONFOX_GET_SOURCE_UP_AC
readonly IRONFOX_GET_SOURCE_UV
readonly IRONFOX_GET_SOURCE_WASI

# If the 'checksum-update' argument is specified, in addition to downloading the dependencies as usual,
## we're also updating their checksums
IRONFOX_GET_SOURCE_CHECKSUM_UPDATE=0
if [ "${mode}" == 'checksum-update' ]; then
    if [ "${IRONFOX_CI}" != 1 ]; then
        IRONFOX_GET_SOURCE_CHECKSUM_UPDATE=1
    else
        echo_red_text 'ERROR: CI should never automatically update checksums.'
        exit 1
    fi
elif [ "${mode}" != 'download' ]; then
    echo_red_text "ERROR: Invalid mode: ${mode}\n You must enter one of the following:"
    echo 'Download:                     download (Default)'
    echo 'Download + update checksums:  checksum-update'
    exit 1
fi
readonly IRONFOX_GET_SOURCE_CHECKSUM_UPDATE

# Include version info
source "${IRONFOX_VERSIONS}"

# Function to automate updating SHA512sums of dependencies
function update_sha512sum() {
    local readonly old_sha512sum="$1"
    local readonly new_sha512sum="$2"
    local readonly file="$3"

    if [ "${old_sha512sum}" == "${ANDROID_NDK_SHA512SUM_LINUX}" ]; then
        echo_red_text 'Updating SHA512sum for Android NDK (Linux)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_NDK_SHA512SUM_LINUX='.*'|ANDROID_NDK_SHA512SUM_LINUX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android NDK (Linux)'
    elif [ "${old_sha512sum}" == "${ANDROID_NDK_SHA512SUM_OSX}" ]; then
        echo_red_text 'Updating SHA512sum for Android NDK (OS X)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_NDK_SHA512SUM_OSX='.*'|ANDROID_NDK_SHA512SUM_OSX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android NDK (OS X)'
    elif [ "${old_sha512sum}" == "${ANDROID_SDK_SHA512SUM_LINUX}" ]; then
        echo_red_text 'Updating SHA512sum for Android SDK (Linux)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_SDK_SHA512SUM_LINUX='.*'|ANDROID_SDK_SHA512SUM_LINUX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android SDK (Linux)'
    elif [ "${old_sha512sum}" == "${ANDROID_SDK_SHA512SUM_OSX}" ]; then
        echo_red_text 'Updating SHA512sum for Android SDK (OS X)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_SDK_SHA512SUM_OSX='.*'|ANDROID_SDK_SHA512SUM_OSX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android SDK (OS X)'
    elif [ "${old_sha512sum}" == "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX}" ]; then
        echo_red_text 'Updating SHA512sum for Android SDK Build Tools (latest) (Linux)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX='.*'|ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android SDK Build Tools (latest) (Linux)'
    elif [ "${old_sha512sum}" == "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX}" ]; then
        echo_red_text 'Updating SHA512sum for Android SDK Build Tools (latest) (OS X)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX='.*'|ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android SDK Build Tools (latest) (OS X)'
    elif [ "${old_sha512sum}" == "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX}" ]; then
        echo_red_text 'Updating SHA512sum for Android SDK Build Tools (35.0.0) (Linux)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX='.*'|ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android SDK Build Tools (35.0.0) (Linux)'
    elif [ "${old_sha512sum}" == "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX}" ]; then
        echo_red_text 'Updating SHA512sum for Android SDK Build Tools (35.0.0) (OS X)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX='.*'|ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android SDK Build Tools (35.0.0) (OS X)'
    elif [ "${old_sha512sum}" == "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX}" ]; then
        echo_red_text 'Updating SHA512sum for Android SDK Platform Tools (Linux)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX='.*'|ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android SDK Platform Tools (Linux)'
    elif [ "${old_sha512sum}" == "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX}" ]; then
        echo_red_text 'Updating SHA512sum for Android SDK Platform Tools (OS X)...'
        "${IRONFOX_SED}" -i -e "s|ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX='.*'|ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Android SDK Platform Tools (OS X)'
    elif [ "${old_sha512sum}" == "${APPSERVICES_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for Application Services...'
        "${IRONFOX_SED}" -i -e "s|APPSERVICES_SHA512SUM='.*'|APPSERVICES_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Application Services'
    elif [ "${old_sha512sum}" == "${BUNDLETOOL_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for Bundletool...'
        "${IRONFOX_SED}" -i -e "s|BUNDLETOOL_SHA512SUM='.*'|BUNDLETOOL_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Bundletool'
    elif [ "${old_sha512sum}" == "${BUNDLETOOL_REPO_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for Bundletool (repository)...'
        "${IRONFOX_SED}" -i -e "s|BUNDLETOOL_REPO_SHA512SUM='.*'|BUNDLETOOL_REPO_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Bundletool (repository)'
    elif [ "${old_sha512sum}" == "${CBINDGEN_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for cbindgen...'
        "${IRONFOX_SED}" -i -e "s|CBINDGEN_SHA512SUM='.*'|CBINDGEN_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for cbindgen'
    elif [ "${old_sha512sum}" == "${FIREFOX_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for Firefox...'
        "${IRONFOX_SED}" -i -e "s|FIREFOX_SHA512SUM='.*'|FIREFOX_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Firefox'
    elif [ "${old_sha512sum}" == "${GLEAN_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for Glean...'
        "${IRONFOX_SED}" -i -e "s|GLEAN_SHA512SUM='.*'|GLEAN_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Glean'
    elif [ "${old_sha512sum}" == "${GLEAN_PARSER_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for Glean Parser...'
        "${IRONFOX_SED}" -i -e "s|GLEAN_PARSER_SHA512SUM='.*'|GLEAN_PARSER_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Glean Parser'
    elif [ "${old_sha512sum}" == "${GMSCORE_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for microG...'
        "${IRONFOX_SED}" -i -e "s|GMSCORE_SHA512SUM='.*'|GMSCORE_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for microG'
    elif [ "${old_sha512sum}" == "${GRADLE_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for F-Droid Gradle script...'
        "${IRONFOX_SED}" -i -e "s|GRADLE_SHA512SUM='.*'|GRADLE_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for F-Droid Gradle script'
    elif [ "${old_sha512sum}" == "${GYP_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for GYP...'
        "${IRONFOX_SED}" -i -e "s|GYP_SHA512SUM='.*'|GYP_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for GYP'
    elif [ "${old_sha512sum}" == "${JDK_17_SHA512SUM_LINUX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (17) (Linux - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_17_SHA512SUM_LINUX_ARM64='.*'|JDK_17_SHA512SUM_LINUX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (17) (Linux - ARM64)'
    elif [ "${old_sha512sum}" == "${JDK_17_SHA512SUM_LINUX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (17) (Linux - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_17_SHA512SUM_LINUX_X86_64='.*'|JDK_17_SHA512SUM_LINUX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (17) (Linux - x86_64)'
    elif [ "${old_sha512sum}" == "${JDK_17_SHA512SUM_OSX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (17) (OS X - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_17_SHA512SUM_OSX_ARM64='.*'|JDK_17_SHA512SUM_OSX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (17) (OS X - ARM64)'
    elif [ "${old_sha512sum}" == "${JDK_17_SHA512SUM_OSX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (17) (OS X - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_17_SHA512SUM_OSX_X86_64='.*'|JDK_17_SHA512SUM_OSX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (17) (OS X - x86_64)'
    elif [ "${old_sha512sum}" == "${JDK_21_SHA512SUM_LINUX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (21) (Linux - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_21_SHA512SUM_LINUX_ARM64='.*'|JDK_21_SHA512SUM_LINUX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (21) (Linux - ARM64)'
    elif [ "${old_sha512sum}" == "${JDK_21_SHA512SUM_LINUX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (21) (Linux - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_21_SHA512SUM_LINUX_X86_64='.*'|JDK_21_SHA512SUM_LINUX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (21) (Linux - x86_64)'
    elif [ "${old_sha512sum}" == "${JDK_21_SHA512SUM_OSX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (21) (OS X - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_21_SHA512SUM_OSX_ARM64='.*'|JDK_21_SHA512SUM_OSX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (21) (OS X - ARM64)'
    elif [ "${old_sha512sum}" == "${JDK_21_SHA512SUM_OSX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (21) (OS X - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_21_SHA512SUM_OSX_X86_64='.*'|JDK_21_SHA512SUM_OSX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (21) (OS X - x86_64)'
    elif [ "${old_sha512sum}" == "${JDK_25_SHA512SUM_LINUX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (25) (Linux - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_25_SHA512SUM_LINUX_ARM64='.*'|JDK_25_SHA512SUM_LINUX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (25) (Linux - ARM64)'
    elif [ "${old_sha512sum}" == "${JDK_25_SHA512SUM_LINUX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (25) (Linux - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_25_SHA512SUM_LINUX_X86_64='.*'|JDK_25_SHA512SUM_LINUX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (25) (Linux - x86_64)'
    elif [ "${old_sha512sum}" == "${JDK_25_SHA512SUM_OSX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (25) (OS X - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_25_SHA512SUM_OSX_ARM64='.*'|JDK_25_SHA512SUM_OSX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (25) (OS X - ARM64)'
    elif [ "${old_sha512sum}" == "${JDK_25_SHA512SUM_OSX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for JDK (25) (OS X - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|JDK_25_SHA512SUM_OSX_X86_64='.*'|JDK_25_SHA512SUM_OSX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for JDK (25) (OS X - x86_64)'
    elif [ "${old_sha512sum}" == "${L10N_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for firefox-l10n...'
        "${IRONFOX_SED}" -i -e "s|L10N_SHA512SUM='.*'|L10N_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for firefox-l10n'
    elif [ "${old_sha512sum}" == "${NPM_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for npm...'
        "${IRONFOX_SED}" -i -e "s|NPM_SHA512SUM='.*'|NPM_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for npm'
    elif [ "${old_sha512sum}" == "${NVM_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for nvm...'
        "${IRONFOX_SED}" -i -e "s|NVM_SHA512SUM='.*'|NVM_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for nvm'
    elif [ "${old_sha512sum}" == "${PHOENIX_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for Phoenix...'
        "${IRONFOX_SED}" -i -e "s|PHOENIX_SHA512SUM='.*'|PHOENIX_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Phoenix'
    elif [ "${old_sha512sum}" == "${PIP_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for pip...'
        "${IRONFOX_SED}" -i -e "s|PIP_SHA512SUM='.*'|PIP_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for pip'
    elif [ "${old_sha512sum}" == "${PYTHON_SHA512SUM_LINUX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for Python (Linux - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|PYTHON_SHA512SUM_LINUX_ARM64='.*'|PYTHON_SHA512SUM_LINUX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Python (Linux - ARM64)'
    elif [ "${old_sha512sum}" == "${PYTHON_SHA512SUM_LINUX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for Python (Linux - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|PYTHON_SHA512SUM_LINUX_X86_64='.*'|PYTHON_SHA512SUM_LINUX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Python (Linux - x86_64)'
    elif [ "${old_sha512sum}" == "${PYTHON_SHA512SUM_OSX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for Python (OS X - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|PYTHON_SHA512SUM_OSX_ARM64='.*'|PYTHON_SHA512SUM_OSX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Python (OS X - ARM64)'
    elif [ "${old_sha512sum}" == "${PYTHON_SHA512SUM_OSX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for Python (OS X - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|PYTHON_SHA512SUM_OSX_X86_64='.*'|PYTHON_SHA512SUM_OSX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for Python (OS X - x86_64)'
    elif [ "${old_sha512sum}" == "${RUSTUP_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for rustup...'
        "${IRONFOX_SED}" -i -e "s|RUSTUP_SHA512SUM='.*'|RUSTUP_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for rustup'
    elif [ "${old_sha512sum}" == "${S3CMD_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for s3cmd...'
        "${IRONFOX_SED}" -i -e "s|S3CMD_SHA512SUM='.*'|S3CMD_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for s3cmd'
    elif [ "${old_sha512sum}" == "${UV_SHA512SUM_LINUX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for uv (Linux - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|UV_SHA512SUM_LINUX_ARM64='.*'|UV_SHA512SUM_LINUX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for uv (Linux - ARM64)'
    elif [ "${old_sha512sum}" == "${UV_SHA512SUM_LINUX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for uv (Linux - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|UV_SHA512SUM_LINUX_X86_64='.*'|UV_SHA512SUM_LINUX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for uv (Linux - x86_64)'
    elif [ "${old_sha512sum}" == "${UV_SHA512SUM_OSX_ARM64}" ]; then
        echo_red_text 'Updating SHA512sum for uv (OS X - ARM64)...'
        "${IRONFOX_SED}" -i -e "s|UV_SHA512SUM_OSX_ARM64='.*'|UV_SHA512SUM_OSX_ARM64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for uv (OS X - ARM64)'
    elif [ "${old_sha512sum}" == "${UV_SHA512SUM_OSX_X86_64}" ]; then
        echo_red_text 'Updating SHA512sum for uv (OS X - x86_64)...'
        "${IRONFOX_SED}" -i -e "s|UV_SHA512SUM_OSX_X86_64='.*'|UV_SHA512SUM_OSX_X86_64='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for uv (OS X - x86_64)'
    elif [ "${old_sha512sum}" == "${PREBUILDS_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for the IronFox prebuilds repo...'
        "${IRONFOX_SED}" -i -e "s|PREBUILDS_SHA512SUM='.*'|PREBUILDS_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for the IronFox prebuilds repo'
    elif [ "${old_sha512sum}" == "${UNIFFI_LINUX_IRONFOX_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for uniffi-bindgen (Linux)...'
        "${IRONFOX_SED}" -i -e "s|UNIFFI_LINUX_IRONFOX_SHA512SUM='.*'|UNIFFI_LINUX_IRONFOX_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for uniffi-bindgen (Linux)'
    elif [ "${old_sha512sum}" == "${UNIFFI_OSX_IRONFOX_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for uniffi-bindgen (OS X)...'
        "${IRONFOX_SED}" -i -e "s|UNIFFI_OSX_IRONFOX_SHA512SUM='.*'|UNIFFI_OSX_IRONFOX_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for uniffi-bindgen (OS X)'
    elif [ "${old_sha512sum}" == "${UNIFIEDPUSHAC_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for UnifiedPush-AC...'
        "${IRONFOX_SED}" -i -e "s|UNIFIEDPUSHAC_SHA512SUM='.*'|UNIFIEDPUSHAC_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for UnifiedPush-AC'
    elif [ "${old_sha512sum}" == "${WASI_LINUX_IRONFOX_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for WASI SDK (Linux)...'
        "${IRONFOX_SED}" -i -e "s|WASI_LINUX_IRONFOX_SHA512SUM='.*'|WASI_LINUX_IRONFOX_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for WASI SDK (Linux)'
    elif [ "${old_sha512sum}" == "${WASI_OSX_IRONFOX_SHA512SUM}" ]; then
        echo_red_text 'Updating SHA512sum for WASI SDK (OS X)...'
        "${IRONFOX_SED}" -i -e "s|WASI_OSX_IRONFOX_SHA512SUM='.*'|WASI_OSX_IRONFOX_SHA512SUM='"${new_sha512sum}"'|g" "${IRONFOX_VERSIONS}"
        echo_green_text 'SUCCESS: Updated SHA512sum for WASI SDK (OS X)'
    fi

    rm "${file}"
}

function validate_sha512sum() {
    local readonly expected_sha512sum="$1"
    local readonly file="$2"

    local readonly local_sha512sum=$(sha512sum "${file}" | "${IRONFOX_AWK}" '{print $1}')

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        update_sha512sum "${expected_sha512sum}" "${local_sha512sum}" "${file}"
    elif [ "${local_sha512sum}" != "${expected_sha512sum}" ]; then
        echo_red_text 'ERROR: Checksum validation failed.'
        echo "Expected SHA512sum: ${expected_sha512sum}"
        echo "Actual SHA512sum: ${local_sha512sum}"

        # If checksum validation fails, also just remove the file
        rm -f "${file}"

        exit 1
    else
        echo_green_text 'SUCCESS: Checksum validated.'
        echo "SHA512sum: ${local_sha512sum}"
    fi
}

function clone_repo() {
    local readonly url="$1"
    local readonly path="$2"
    local readonly revision="$3"

    if [[ "${url}" == "" ]]; then
        echo_red_text "ERROR: URL missing for clone"
        exit 1
    fi

    if [[ "${path}" == "" ]]; then
        echo_red_text "ERROR: Path is required for cloning '${url}'"
        exit 1
    fi

    if [[ "${revision}" == "" ]]; then
        echo_red_text "ERROR: Revision is required for cloning '${url}'"
        exit 1
    fi

    if [[ -f "${path}" ]]; then
        echo_red_text "ERROR: '${path}' exists and is not a directory"
        exit 1
    fi

    if [[ -d "${path}" ]]; then
        echo_red_text "'${path}' already exists"
        read -p "Do you want to re-clone this repository? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text "Removing ${path}..."
            rm -rf "${path}"
        else
            return 0
        fi
    fi

    echo_red_text "Cloning ${url}::${revision}..."
    git clone --revision="${revision}" --depth=1 "${url}" "${path}"
}

function download() {
    local readonly url="$1"
    local readonly filepath="$2"

    if [[ "${url}" == "" ]]; then
        echo_red_text "ERROR: URL is required (file: '${filepath}')"
        exit 1
    fi

    if [ -f "${filepath}" ]; then
        echo_red_text "${filepath} already exists."
        read -p "Do you want to re-download? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text "Removing ${filepath}..."
            rm -f "${filepath}"
        else
            return 0
        fi
    fi

    mkdir -vp "$(dirname "${filepath}")"

    echo_red_text "Downloading ${url}..."
    curl ${IRONFOX_CURL_FLAGS} -sSL "${url}" -o "${filepath}"
}

# Extract archives
function extract() {
    local readonly archive_path="$1"
    local readonly target_path="$2"
    local readonly temp_repo_name="$3"

    if ! [[ -f "${archive_path}" ]]; then
        echo_red_text "ERROR: Archive '${archive_path}' does not exist!"
    fi

    # If our temporary directory for extraction already exists, delete it
    if [[ -d "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}" ]]; then
        rm -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
    fi

    # Create temporary directory for extraction
    mkdir -p "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"

    # Extract based on file extension
    case "${archive_path}" in
        *.zip)
            unzip -q "${archive_path}" -d "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            ;;
        *.tar.gz)
            "${IRONFOX_TAR}" xzf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            ;;
        *.tar.xz)
            "${IRONFOX_TAR}" xJf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            ;;
        *.tar.zst)
            "${IRONFOX_TAR}" --zstd -xvf "${archive_path}" -C "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            ;;
        *)
            echo_red_text "ERROR: Unsupported archive format: ${archive_path}"
            rm -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
            exit 1
            ;;
    esac

    local readonly top_input_dir=$(ls "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}")
    cp -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}/${top_input_dir}"/ "${target_path}"
    rm -rf "${IRONFOX_EXTERNAL}/temp/${temp_repo_name}"
}

function download_and_extract() {
    local readonly repo_name="$1"
    local readonly url="$2"
    local readonly path="$3"
    local readonly expected_sha512sum="$4"

    if [[ -d "${path}" ]]; then
        echo_red_text "'${path}' already exists"
        read -p "Do you want to re-download? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text "Removing ${path}..."
            rm -rf "${path}"
        else
            return 0
        fi
    fi

    if [[ "${url}" =~ \.tar\.xz$ ]]; then
        local readonly extension=".tar.xz"
    elif [[ "${url}" =~ \.tar\.gz$ ]]; then
        local readonly extension=".tar.gz"
    elif [[ "${url}" =~ \.tar\.zst$ ]]; then
        local readonly extension=".tar.zst"
    else
        local readonly extension=".zip"
    fi

    local readonly repo_archive="${IRONFOX_DOWNLOADS}/${repo_name}${extension}"

    download "${url}" "${repo_archive}"

    if [ ! -f "${repo_archive}" ]; then
        echo_red_text "ERROR: Source archive for ${repo_name} does not exist."
        exit 1
    fi

    # Before extracting, verify SHA512sum...
    validate_sha512sum "${expected_sha512sum}" "${repo_archive}"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_red_text "Extracting ${repo_archive}..."
        extract "${repo_archive}" "${path}" "${repo_name}"
        echo
    fi
}

# Get Android NDK
function get_android_ndk() {
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading the Android NDK (Linux)...'
        download_and_extract 'android-ndk' "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip" "${IRONFOX_ANDROID_NDK}" "${ANDROID_NDK_SHA512SUM_LINUX}"

        echo_red_text 'Downloading the Android NDK (OS X)...'
        download_and_extract 'android-ndk' "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-darwin.zip" "${IRONFOX_ANDROID_NDK}" "${ANDROID_NDK_SHA512SUM_OSX}"
    else
        echo_red_text 'Downloading the Android NDK...'
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            download_and_extract 'android-ndk' "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-darwin.zip" "${IRONFOX_ANDROID_NDK}" "${ANDROID_NDK_SHA512SUM_OSX}"
        else
            download_and_extract 'android-ndk' "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip" "${IRONFOX_ANDROID_NDK}" "${ANDROID_NDK_SHA512SUM_LINUX}"
        fi
        echo_green_text "SUCCESS: Set-up Android NDK at ${IRONFOX_ANDROID_NDK}"
    fi
}

# Get + set-up Android SDK
function get_android_sdk() {
    # This is typically covered by "download_and_extract", but the Android SDK is a special case - we don't download it to IRONFOX_ANDROID_SDK directly
    if [[ -d "${IRONFOX_ANDROID_SDK}" ]]; then
        echo_red_text "'${IRONFOX_ANDROID_SDK}' already exists"
        read -p "Do you want to re-download? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text "Removing ${IRONFOX_ANDROID_SDK}..."
            rm -rf "${IRONFOX_ANDROID_SDK}"
        else
            return 0
        fi
    fi
    mkdir -p "${IRONFOX_ANDROID_SDK}/cmdline-tools"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading the Android SDK (Linux)...'
        download_and_extract 'android-sdk-cmdline-tools' "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/latest" "${ANDROID_SDK_SHA512SUM_LINUX}"

        echo_red_text 'Downloading the Android SDK (OS X)...'
        download_and_extract 'android-sdk-cmdline-tools' "https://dl.google.com/android/repository/commandlinetools-mac-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/latest" "${ANDROID_SDK_SHA512SUM_OSX}"
    else
        echo_red_text 'Downloading the Android SDK...'
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            download_and_extract 'android-sdk-cmdline-tools' "https://dl.google.com/android/repository/commandlinetools-mac-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/latest" "${ANDROID_SDK_SHA512SUM_OSX}"
        else
            download_and_extract 'android-sdk-cmdline-tools' "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_REVISION}_latest.zip" "${IRONFOX_ANDROID_SDK}/cmdline-tools/latest" "${ANDROID_SDK_SHA512SUM_LINUX}"
        fi

        # Accept Android SDK licenses
        { yes || true; } | ${IRONFOX_ANDROID_SDKMANAGER} --sdk_root="${IRONFOX_ANDROID_SDK}" --licenses

        echo_green_text "SUCCESS: Set-up Android SDK at ${IRONFOX_ANDROID_SDK}"
    fi
}

# Get Android SDK Build Tools (latest)
function get_android_sdk_build_tools() {
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading Android SDK Build Tools (latest) (Linux)...'
        download_and_extract 'android-sdk-build-tools' "https://dl.google.com/android/repository/build-tools_${ANDROID_SDK_BUILD_TOOLS_VERSION}_linux.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX}"

        echo_red_text 'Downloading Android SDK Build Tools (latest) (OS X)...'
        download_and_extract 'android-sdk-build-tools' "https://dl.google.com/android/repository/build-tools_${ANDROID_SDK_BUILD_TOOLS_VERSION}_macosx.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX}"
    else
        echo_red_text 'Downloading Android SDK Build Tools (latest)...'
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            download_and_extract 'android-sdk-build-tools' "https://dl.google.com/android/repository/build-tools_${ANDROID_SDK_BUILD_TOOLS_VERSION}_macosx.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_OSX}"
        else
            download_and_extract 'android-sdk-build-tools' "https://dl.google.com/android/repository/build-tools_${ANDROID_SDK_BUILD_TOOLS_VERSION}_linux.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" "${ANDROID_SDK_BUILD_TOOLS_SHA512SUM_LINUX}"
        fi
        echo_green_text "SUCCESS: Set-up Android SDK Build Tools (latest) at ${IRONFOX_ANDROID_SDK_BUILD_TOOLS}"
    fi
}

# Get Android SDK Build Tools (35)
## (Needed by Glean:
### https://github.com/mozilla/glean/blob/main/docs/dev/android/sdk-ndk-versions.md
### https://github.com/mozilla/glean/blob/main/docs/dev/android/setup-android-build-environment.md)
function get_android_sdk_build_tools_35() {
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading Android SDK Build Tools (35.0.0) (Linux)...'
        download_and_extract 'android-sdk-build-tools-35' "https://dl.google.com/android/repository/build-tools_r35_linux.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX}"

        echo_red_text 'Downloading Android SDK Build Tools (35.0.0) (OS X)...'
        download_and_extract 'android-sdk-build-tools-35' "https://dl.google.com/android/repository/build-tools_r35_macosx.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX}"
    else
        echo_red_text 'Downloading Android SDK Build Tools (35.0.0)...'
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            download_and_extract 'android-sdk-build-tools-35' "https://dl.google.com/android/repository/build-tools_r35_macosx.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_OSX}"
        else
            download_and_extract 'android-sdk-build-tools-35' "https://dl.google.com/android/repository/build-tools_r35_linux.zip" "${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}" "${ANDROID_SDK_BUILD_TOOLS_35_SHA512SUM_LINUX}"
        fi
        echo_green_text "SUCCESS: Set-up Android SDK Build Tools (35.0.0) at ${IRONFOX_ANDROID_SDK_BUILD_TOOLS_35}"
    fi
}

# Get Android SDK Platform (latest)
function get_android_sdk_platform() {
    if  [ ! -d "${IRONFOX_ANDROID_SDK}" ]; then
        echo_red_text "ERROR: You tried to download the Android SDK Platform (latest), but you don't have the Android SDK set-up yet."
        exit 1
    fi

    if [[ -d "${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}" ]]; then
        echo_red_text "Android SDK Platform (latest) is already installed at ${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        else
            rm -rf "${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}"
        fi
    fi

    echo_red_text 'Downloading Android SDK Platform (latest)...'

    ${IRONFOX_ANDROID_SDKMANAGER} "platforms;android-${ANDROID_SDK_PLATFORM_VERSION}"

    echo_green_text "SUCCESS: Set-up Android SDK Platform (latest) at ${IRONFOX_ANDROID_SDK}/platforms/android-${ANDROID_SDK_PLATFORM_VERSION}"
}

# Get Android SDK Platform (36)
## (Needed by Glean:
### https://github.com/mozilla/glean/blob/main/docs/dev/android/sdk-ndk-versions.md
### https://github.com/mozilla/glean/blob/main/docs/dev/android/setup-android-build-environment.md)
function get_android_sdk_platform_36() {
    if  [ ! -d "${IRONFOX_ANDROID_SDK}" ]; then
        echo_red_text "ERROR: You tried to download the Android SDK Platform (36), but you don't have the Android SDK set-up yet."
        exit 1
    fi

    if [[ -d "${IRONFOX_ANDROID_SDK}/platforms/android-36" ]]; then
        echo_red_text "Android SDK Platform (36) is already installed at ${IRONFOX_ANDROID_SDK}/platforms/android-36"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        else
            rm -rf "${IRONFOX_ANDROID_SDK}/platforms/android-36"
        fi
    fi

    echo_red_text 'Downloading Android SDK Platform (36)...'

    ${IRONFOX_ANDROID_SDKMANAGER} 'platforms;android-36'

    echo_green_text "SUCCESS: Set-up Android SDK Platform (36) at ${IRONFOX_ANDROID_SDK}/platforms/android-36"
}

# Get Android SDK Platform Tools
function get_android_sdk_platform_tools() {
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading Android SDK Platform Tools (Linux)...'
        download_and_extract 'android-sdk-platform-tools' "https://dl.google.com/android/repository/platform-tools_r${ANDROID_SDK_PLATFORM_TOOLS_VERSION}-linux.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX}"

        echo_red_text 'Downloading Android SDK Platform Tools (OS X)...'
        download_and_extract 'android-sdk-platform-tools' "https://dl.google.com/android/repository/platform-tools_r${ANDROID_SDK_PLATFORM_TOOLS_VERSION}-darwin.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX}"
    else
        echo_red_text 'Downloading Android SDK Platform Tools...'
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            download_and_extract 'android-sdk-platform-tools' "https://dl.google.com/android/repository/platform-tools_r${ANDROID_SDK_PLATFORM_TOOLS_VERSION}-darwin.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_OSX}"
        else
            download_and_extract 'android-sdk-platform-tools' "https://dl.google.com/android/repository/platform-tools_r${ANDROID_SDK_PLATFORM_TOOLS_VERSION}-linux.zip" "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" "${ANDROID_SDK_PLATFORM_TOOLS_SHA512SUM_LINUX}"
        fi
        echo_green_text "SUCCESS: Set-up Android SDK Platform Tools at ${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}"
    fi
}

# Get Application Services
function get_as() {
    echo_red_text 'Downloading Application Services...'
    download_and_extract 'application-services' "https://github.com/mozilla/application-services/archive/${APPSERVICES_COMMIT}.tar.gz" "${IRONFOX_AS}" "${APPSERVICES_SHA512SUM}"
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_green_text "SUCCESS: Set-up Application Services at ${IRONFOX_AS}"
    fi
}

# Get + set-up Bundletool
function get_bundletool() {
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading Bundletool (Source archive)...'
        download_and_extract 'bundletool' "https://github.com/google/bundletool/archive/${BUNDLETOOL_REPO_COMMIT}.tar.gz" "${IRONFOX_BUNDLETOOL_DIR}" "${BUNDLETOOL_REPO_SHA512SUM}"

        echo_red_text 'Downloading Bundletool (Prebuilt)...'
        download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}"

        # "Validate" (Update) SHA512sum
        validate_sha512sum "${BUNDLETOOL_SHA512SUM}" "${IRONFOX_BUNDLETOOL_JAR}"
    else
        echo_red_text 'Downloading Bundletool...'
        if [[ "${IRONFOX_NO_PREBUILDS}" == "1" ]]; then
            download_and_extract 'bundletool' "https://github.com/google/bundletool/archive/${BUNDLETOOL_REPO_COMMIT}.tar.gz" "${IRONFOX_BUNDLETOOL_DIR}" "${BUNDLETOOL_REPO_SHA512SUM}"
        else
            download "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" "${IRONFOX_BUNDLETOOL_JAR}"

            # Validate SHA512sum
            validate_sha512sum "${BUNDLETOOL_SHA512SUM}" "${IRONFOX_BUNDLETOOL_JAR}"
        fi

        echo_green_text "SUCCESS: Set-up Bundletool at ${IRONFOX_BUNDLETOOL_DIR}"
    fi
}

# Get cbindgen
function get_cbindgen() {
    # If all we're doing is updating the checksum, we don't care if the environment is prepared
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        if  [ ! -d "${IRONFOX_CARGO_HOME}" ] || [ ! -f "${IRONFOX_CARGO_ENV}" ]; then
            echo_red_text "ERROR: You tried to download cbindgen, but you don't have a Rust environment set-up yet."
            exit 1
        fi

        if [[ -d "${IRONFOX_CARGO_HOME}/bin/cbindgen" ]]; then
            echo_red_text "cbindgen is already installed at ${IRONFOX_CARGO_HOME}/bin/cbindgen."
            read -p "Do you want to re-download it? [y/N] " -n 1 -r
            echo
            if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
                return 0
            fi
        fi
    fi

    echo_red_text "Downloading cbindgen..."
    download_and_extract 'cbindgen' "https://github.com/mozilla/cbindgen/archive/${CBINDGEN_COMMIT}.tar.gz" "${IRONFOX_CBINDGEN}" "${CBINDGEN_SHA512SUM}"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        source "${IRONFOX_CARGO_ENV}"
        echo_red_text 'Installing cbindgen...'
        cargo +"${RUST_VERSION}" install --locked --force --vers "${CBINDGEN_VERSION}" --path "${IRONFOX_CBINDGEN}" cbindgen
        echo_green_text "SUCCESS: Set-up cbindgen at ${IRONFOX_CARGO_HOME}/bin/cbindgen"
    fi
}

# Get Firefox (Gecko/mozilla-central)
function get_firefox() {
    echo_red_text 'Downloading Firefox...'
    download_and_extract 'gecko' "https://github.com/mozilla-firefox/firefox/archive/${FIREFOX_COMMIT}.tar.gz" "${IRONFOX_GECKO}" "${FIREFOX_SHA512SUM}"

    # Because we use MOZ_AUTOMATION for certain parts of the build, we need to initialize a Git repository
    ## The Git repository isn't already created, due to our method of downloading and verifying the archive
    ## This doesn't matter if we're just updating the checksum though
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        pushd "${IRONFOX_GECKO}"
        git init
        popd

        echo_green_text "SUCCESS: Set-up Firefox at ${IRONFOX_GECKO}"
    fi
}

# Get firefox-l10n
function get_firefox_l10n() {
    echo_red_text 'Downloading firefox-l10n...'
    download_and_extract 'l10n-central' "https://github.com/mozilla-l10n/firefox-l10n/archive/${L10N_COMMIT}.tar.gz" "${IRONFOX_L10N_CENTRAL}" "${L10N_SHA512SUM}"
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_green_text "SUCCESS: Set-up firefox-l10n at ${IRONFOX_L10N_CENTRAL}"
    fi
}

# Get Glean
function get_glean() {
    echo_red_text 'Downloading Glean...'
    download_and_extract 'glean' "https://github.com/mozilla/glean/archive/${GLEAN_COMMIT}.tar.gz" "${IRONFOX_GLEAN}" "${GLEAN_SHA512SUM}"
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_green_text "SUCCESS: Set-up Glean at ${IRONFOX_GLEAN}"
    fi
}

# Get Glean Parser
function get_glean_parser() {
    if  [ ! -d "${IRONFOX_UV_DIR}" ] || [ ! -f "${IRONFOX_PYENV}" ]; then
        echo_red_text "ERROR: You tried to download Glean Parser, but you don't have a uv environment set-up yet."
        exit 1
    fi

    if  [ ! -d "${IRONFOX_PIP_DIR}" ]; then
        echo_red_text "ERROR: You tried to download Glean Parser, but you don't have pip set-up yet."
        exit 1
    fi

    if [[ -d "${IRONFOX_PYENV_DIR}/bin/glean_parser" ]]; then
        echo_red_text "Glean Parser is already installed at ${IRONFOX_PYENV_DIR}/bin/glean_parser"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        else
            source "${IRONFOX_PYENV}"
            "${IRONFOX_UV}" pip uninstall glean-parser
        fi
    fi

    if [[ -d "${IRONFOX_GLEAN_PARSER_WHEELS}" ]]; then
        echo_red_text "Glean Parser wheels are already downloaded at ${IRONFOX_GLEAN_PARSER_WHEELS}"
        read -p "Do you want to re-download it? [y/N] " -n 1 -r
        echo
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        else
            rm -rf "${IRONFOX_GLEAN_PARSER_WHEELS}"
        fi
    fi
    mkdir -p "${IRONFOX_GLEAN_PARSER_WHEELS}"

    source "${IRONFOX_PYENV}"
    echo_red_text 'Downloading Glean Parser wheels...'
    pushd "${IRONFOX_GLEAN_PARSER_WHEELS}"
    "${IRONFOX_PIP}" download glean-parser=="${GLEAN_PARSER_VERSION}"
    popd

    # Validate SHA512sum
    validate_sha512sum "${GLEAN_PARSER_SHA512SUM}" "${IRONFOX_GLEAN_PARSER_WHEELS}/glean_parser-${GLEAN_PARSER_VERSION}-py3-none-any.whl"
}

# Get + set-up F-Droid's Gradle script
function get_gradle() {
    echo_red_text "Downloading F-Droid's Gradle script..."
    download "https://gitlab.com/fdroid/gradlew-fdroid/-/raw/${GRADLE_COMMIT}/gradlew.py" "${IRONFOX_GRADLE_PY}"

    # Validate SHA512sum
    validate_sha512sum "${GRADLE_SHA512SUM}" "${IRONFOX_GRADLE_PY}"
}

# Get GYP
function get_gyp() {
    # If all we're doing is updating the checksum, we don't care if the environment is prepared
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        if  [ ! -d "${IRONFOX_UV_DIR}" ] || [ ! -f "${IRONFOX_PYENV}" ]; then
            echo_red_text "ERROR: You tried to download GYP, but you don't have a uv environment set-up yet."
            exit 1
        fi

        if [[ -d "${IRONFOX_PYENV_DIR}/bin/gyp" ]]; then
            echo_red_text "GYP is already installed at ${IRONFOX_PYENV_DIR}/bin/gyp"
            read -p "Do you want to re-download it? [y/N] " -n 1 -r
            echo
            if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
                return 0
            else
                source "${IRONFOX_PYENV}"
                "${IRONFOX_UV}" pip uninstall gyp-next
            fi
        fi
    fi

    echo_red_text "Downloading GYP..."
    download_and_extract 'gyp-next' "https://github.com/nodejs/gyp-next/archive/${GYP_COMMIT}.tar.gz" "${IRONFOX_GYP}" "${GYP_SHA512SUM}"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        source "${IRONFOX_PYENV}"
        echo_red_text 'Installing GYP...'
        "${IRONFOX_UV}" pip install --strict "${IRONFOX_GYP}"
        echo_green_text "SUCCESS: Set-up GYP at ${IRONFOX_PYENV_DIR}/bin/gyp"
    fi
}

# Get JDK (17)
## (Required by GeckoView)
function get_jdk_17() {
    # Set our platform
    if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
        local readonly JDK_17_PLATFORM='mac'
    else
        local readonly JDK_17_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        local readonly JDK_17_ARCH='aarch64'
    else
        local readonly JDK_17_ARCH='x64'
    fi

    # Set our checksum to verify
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly JDK_17_SHA512SUM="${JDK_17_SHA512SUM_OSX_ARM64}"
        else
            local readonly JDK_17_SHA512SUM="${JDK_17_SHA512SUM_LINUX_ARM64}"
        fi
    else
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly JDK_17_SHA512SUM="${JDK_17_SHA512SUM_OSX_X86_64}"
        else
            local readonly JDK_17_SHA512SUM="${JDK_17_SHA512SUM_LINUX_X86_64}"
        fi
    fi

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading JDK (17) (Linux - ARM64)...'
        download_and_extract 'jdk-17' "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_aarch64_linux_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM_LINUX_ARM64}"

        echo_red_text 'Downloading JDK (17) (Linux - x86_64)...'
        download_and_extract 'jdk-17' "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_x64_linux_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM_LINUX_X86_64}"

        echo_red_text 'Downloading JDK (17) (OS X - ARM64)...'
        download_and_extract 'jdk-17' "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_aarch64_mac_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM_OSX_ARM64}"

        echo_red_text 'Downloading JDK (17) (OS X - x86_64)...'
        download_and_extract 'jdk-17' "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_x64_mac_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM_OSX_X86_64}"
    else
        echo_red_text 'Downloading JDK (17)...'
        download_and_extract 'jdk-17' "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION}%2B${JDK_17_REVISION}/OpenJDK17U-jdk_${JDK_17_ARCH}_${JDK_17_PLATFORM}_hotspot_${JDK_17_VERSION}_${JDK_17_REVISION}.tar.gz" "${IRONFOX_JDK_17}" "${JDK_17_SHA512SUM}"
        echo_green_text "SUCCESS: Set-up JDK (17) at ${IRONFOX_JDK_17}"
    fi
}

# Get JDK (21)
function get_jdk_21() {
    # Set our platform
    if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
        local readonly JDK_21_PLATFORM='mac'
    else
        local readonly JDK_21_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        local readonly JDK_21_ARCH='aarch64'
    else
        local readonly JDK_21_ARCH='x64'
    fi

    # Set our checksum to verify
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly JDK_21_SHA512SUM="${JDK_21_SHA512SUM_OSX_ARM64}"
        else
            local readonly JDK_21_SHA512SUM="${JDK_21_SHA512SUM_LINUX_ARM64}"
        fi
    else
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly JDK_21_SHA512SUM="${JDK_21_SHA512SUM_OSX_X86_64}"
        else
            local readonly JDK_21_SHA512SUM="${JDK_21_SHA512SUM_LINUX_X86_64}"
        fi
    fi

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading JDK (21) (Linux - ARM64)...'
        download_and_extract 'jdk-21' "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_aarch64_linux_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM_LINUX_ARM64}"

        echo_red_text 'Downloading JDK (21) (Linux - x86_64)...'
        download_and_extract 'jdk-21' "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_x64_linux_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM_LINUX_X86_64}"
 
        echo_red_text 'Downloading JDK (21) (OS X - ARM64)...'
        download_and_extract 'jdk-21' "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_aarch64_mac_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM_OSX_ARM64}"

        echo_red_text 'Downloading JDK (21) (OS X - x86_64)...'
        download_and_extract 'jdk-21' "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_x64_mac_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM_OSX_X86_64}"
    else
        echo_red_text 'Downloading JDK (21)...'
        download_and_extract 'jdk-21' "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK_21_VERSION}%2B${JDK_21_REVISION}/OpenJDK21U-jdk_${JDK_21_ARCH}_${JDK_21_PLATFORM}_hotspot_${JDK_21_VERSION}_${JDK_21_REVISION}.tar.gz" "${IRONFOX_JDK_21}" "${JDK_21_SHA512SUM}"
        echo_green_text "SUCCESS: Set-up JDK (21) at ${IRONFOX_JDK_21}"
    fi
}

# Get JDK (25)
function get_jdk_25() {
    # Set our platform
    if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
        local readonly JDK_25_PLATFORM='mac'
    else
        local readonly JDK_25_PLATFORM='linux'
    fi

    # Set our platform architecture
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        local readonly JDK_25_ARCH='aarch64'
    else
        local readonly JDK_25_ARCH='x64'
    fi

    # Set our checksum to verify
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly JDK_25_SHA512SUM="${JDK_25_SHA512SUM_OSX_ARM64}"
        else
            local readonly JDK_25_SHA512SUM="${JDK_25_SHA512SUM_LINUX_ARM64}"
        fi
    else
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly JDK_25_SHA512SUM="${JDK_25_SHA512SUM_OSX_X86_64}"
        else
            local readonly JDK_25_SHA512SUM="${JDK_25_SHA512SUM_LINUX_X86_64}"
        fi
    fi

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading JDK (25) (Linux - ARM64)...'
        download_and_extract 'jdk-25' "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_aarch64_linux_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM_LINUX_ARM64}"

        echo_red_text 'Downloading JDK (25) (Linux - x86_64)...'
        download_and_extract 'jdk-25' "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_x64_linux_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM_LINUX_X86_64}"

        echo_red_text 'Downloading JDK (25) (OS X - ARM64)...'
        download_and_extract 'jdk-25' "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_aarch64_mac_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM_OSX_ARM64}"

        echo_red_text 'Downloading JDK (25) (OS X - x86_64)...'
        download_and_extract 'jdk-25' "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_x64_mac_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM_OSX_X86_64}"
    else
        echo_red_text 'Downloading JDK (25)...'
        download_and_extract 'jdk-25' "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-${JDK_25_VERSION}%2B${JDK_25_REVISION}/OpenJDK25U-jdk_${JDK_25_ARCH}_${JDK_25_PLATFORM}_hotspot_${JDK_25_VERSION}_${JDK_25_REVISION}.tar.gz" "${IRONFOX_JDK_25}" "${JDK_25_SHA512SUM}"
        echo_green_text "SUCCESS: Set-up JDK (25) at ${IRONFOX_JDK_25}"
    fi
}

# Get microG
function get_microg() {
    echo_red_text 'Downloading microG...'
    download_and_extract 'gmscore' "https://github.com/microg/GmsCore/archive/${GMSCORE_COMMIT}.tar.gz" "${IRONFOX_GMSCORE}" "${GMSCORE_SHA512SUM}"
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_green_text "SUCCESS: Set-up microG at ${IRONFOX_GMSCORE}"
    fi
}

# Get + set-up Node.js
function get_node() {
    # If all we're doing is updating the checksum, we don't care if the environment is prepared
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        if [[ -d "${IRONFOX_NVM}" ]]; then
            echo_red_text "The Node.js environment is already set-up at ${IRONFOX_NVM}"
            read -p "Do you want to re-create it? [y/N] " -n 1 -r
            echo
            if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
                rm -rf "${IRONFOX_NPM_CACHE}" "${IRONFOX_NVM}" "${IRONFOX_ROOT}/node_modules"
            fi
        fi
    fi

    download_and_extract 'nvm' "https://github.com/nvm-sh/nvm/archive/${NVM_COMMIT}.tar.gz" "${IRONFOX_NVM}" "${NVM_SHA512SUM}"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_red_text 'Installing Node.js...'
        source "${IRONFOX_NVM_ENV}"
        nvm install "${NODE_VERSION}"
        nvm alias default "${NODE_VERSION}"
        nvm use "${NODE_VERSION}"

        echo_green_text "SUCCESS: Set-up Node.js environment at ${IRONFOX_NVM}"
    fi
}

# Get npm
function get_npm() {
    # If all we're doing is updating the checksum, we don't care if the environment is prepared
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        if  [ ! -d "${IRONFOX_NVM}" ]; then
            echo_red_text "ERROR: You tried to download npm, but you don't have a Node.js environment set-up yet."
            exit 1
        fi
    fi

    echo_red_text 'Downloading npm...'
    download "https://registry.npmjs.org/npm/-/npm-${NPM_VERSION}.tgz" "${IRONFOX_DOWNLOADS}/npm.tgz"

    # Validate SHA512sum
    validate_sha512sum "${NPM_SHA512SUM}" "${IRONFOX_DOWNLOADS}/npm.tgz"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_red_text 'Installing npm...'
        source "${IRONFOX_NVM_ENV}"
        "${IRONFOX_NPM}" install -g npm@file:"${IRONFOX_DOWNLOADS}/npm.tgz"
        echo_green_text "SUCCESS: Set-up npm at ${IRONFOX_NPM}"
    fi
}

# Get Phoenix
function get_phoenix() {
    echo_red_text 'Downloading Phoenix...'
    download_and_extract 'phoenix' "https://gitlab.com/celenityy/Phoenix/-/archive/${PHOENIX_COMMIT}/Phoenix-${PHOENIX_COMMIT}.tar.gz" "${IRONFOX_PHOENIX}" "${PHOENIX_SHA512SUM}"
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_green_text "SUCCESS: Set-up Phoenix at ${IRONFOX_PHOENIX}"
    fi
}

# Get + set-up pip
function get_pip() {
    # If all we're doing is updating the checksum, we don't care if the environment is prepared
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        if  [ ! -d "${IRONFOX_UV_DIR}" ] || [ ! -f "${IRONFOX_PYENV}" ]; then
            echo_red_text "ERROR: You tried to download pip, but you don't have a uv environment set-up yet."
            exit 1
        fi
    fi

    echo_red_text 'Downloading pip...'
    download_and_extract 'pip' "https://github.com/pypa/pip/archive/${PIP_COMMIT}.tar.gz" "${IRONFOX_PIP_DIR}" "${PIP_SHA512SUM}"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        source "${IRONFOX_PYENV}"
        echo_red_text 'Installing pip...'
        "${IRONFOX_UV}" pip install "${IRONFOX_PIP_DIR}"
        echo_green_text "SUCCESS: Set-up pip at ${IRONFOX_PIP}"
    fi
}

# Get the IronFox prebuilds repo
function get_prebuilds() {
    echo_red_text 'Downloading the IronFox prebuilds repository...'
    download_and_extract 'prebuilds' "https://gitlab.com/ironfox-oss/prebuilds/-/archive/${PREBUILDS_COMMIT}/prebuilds-${PREBUILDS_COMMIT}.tar.gz" "${IRONFOX_PREBUILDS}" "${PREBUILDS_SHA512SUM}"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        pushd "${IRONFOX_PREBUILDS}"
        echo_red_text 'Downloading prebuild sources...'
        bash "${IRONFOX_PREBUILDS}/scripts/get_sources.sh"
        popd
        echo_green_text "SUCCESS: Set-up the IronFox prebuilds repository at ${IRONFOX_PREBUILDS}"
    fi
}

# Get Python
function get_python() {
    # Set our platform
    if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
        local readonly PYTHON_PLATFORM='apple-darwin'
    else
        local readonly PYTHON_PLATFORM='unknown-linux-gnu'
    fi

    # Set our platform architecture
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        local readonly PYTHON_ARCH='aarch64'
    else
        local readonly PYTHON_ARCH='x86_64'
    fi

    # Set our checksum to verify
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly PYTHON_SHA512SUM="${PYTHON_SHA512SUM_OSX_ARM64}"
        else
            local readonly PYTHON_SHA512SUM="${PYTHON_SHA512SUM_LINUX_ARM64}"
        fi
    else
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly PYTHON_SHA512SUM="${PYTHON_SHA512SUM_OSX_X86_64}"
        else
            local readonly PYTHON_SHA512SUM="${PYTHON_SHA512SUM_LINUX_X86_64}"
        fi
    fi

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading Python (Linux - ARM64)...'
        download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz"

        # "Validate" (Update) SHA512sum
        validate_sha512sum "${PYTHON_SHA512SUM_LINUX_ARM64}" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz"

        echo_red_text 'Downloading Python (Linux - x86_64)...'
        download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz"

        # "Validate" (Update) SHA512sum
        validate_sha512sum "${PYTHON_SHA512SUM_LINUX_X86_64}" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz"

        echo_red_text 'Downloading Python (OS X - ARM64)...'
        download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-apple-darwin-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-apple-darwin-install_only_stripped.tar.gz"

        # "Validate" (Update) SHA512sum
        validate_sha512sum "${PYTHON_SHA512SUM_OSX_ARM64}" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-aarch64-apple-darwin-install_only_stripped.tar.gz"

        echo_red_text 'Downloading Python (OS X - x86_64)...'
        download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-apple-darwin-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-apple-darwin-install_only_stripped.tar.gz"

        # "Validate" (Update) SHA512sum
        validate_sha512sum "${PYTHON_SHA512SUM_OSX_X86_64}" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-x86_64-apple-darwin-install_only_stripped.tar.gz"
    else
        echo_red_text 'Downloading Python...'
        download "https://github.com/astral-sh/python-build-standalone/releases/download/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-${PYTHON_ARCH}-${PYTHON_PLATFORM}-install_only_stripped.tar.gz" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-${PYTHON_ARCH}-${PYTHON_PLATFORM}-install_only_stripped.tar.gz"

        # Validate SHA512sum
        validate_sha512sum "${PYTHON_SHA512SUM}" "${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-${PYTHON_ARCH}-${PYTHON_PLATFORM}-install_only_stripped.tar.gz"

        echo_green_text "SUCCESS: Downloaded Python to ${IRONFOX_PYTHON_DIR}/${PYTHON_GIT_RELEASE}/cpython-${PYTHON_VERSION}+${PYTHON_GIT_RELEASE}-${PYTHON_ARCH}-${PYTHON_PLATFORM}-install_only_stripped.tar.gz"
    fi
}

# Get + set-up rust/cargo
function get_rust() {
    # If all we're doing is updating the checksum, we don't care if the environment is prepared
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        if [[ -d "${IRONFOX_CARGO_HOME}" ]]; then
            echo_red_text "The Rust environment is already set-up at ${IRONFOX_CARGO_HOME}"
            read -p "Do you want to re-create it? [y/N] " -n 1 -r
            echo
            if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
                rm -rf "${IRONFOX_CARGO_HOME}" "${IRONFOX_RUSTUP_HOME}"
            fi
        fi
    fi

    echo_red_text 'Downloading Rust...'
    download "https://raw.githubusercontent.com/rust-lang/rustup/${RUSTUP_COMMIT}/rustup-init.sh" "${IRONFOX_DOWNLOADS}/rustup-init.sh"

    # Validate SHA512sum
    validate_sha512sum "${RUSTUP_SHA512SUM}" "${IRONFOX_DOWNLOADS}/rustup-init.sh"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        bash -x "${IRONFOX_DOWNLOADS}/rustup-init.sh" -y --no-modify-path --no-update-default-toolchain --profile=minimal

        echo_red_text 'Creating Rust environment...'
        source "${IRONFOX_CARGO_ENV}"
        rustup set profile minimal
        rustup default "${RUST_VERSION}"
        rustup override set "${RUST_VERSION}"
        rustup target add aarch64-linux-android
        rustup target add armv7-linux-androideabi
        rustup target add thumbv7neon-linux-androideabi
        rustup target add x86_64-linux-android

        echo_green_text "SUCCESS: Set-up Rust environment at ${IRONFOX_CARGO_HOME}"
    fi
}

# Get s3cmd
function get_s3cmd() {
    # If all we're doing is updating the checksum, we don't care if the environment is prepared
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        if  [ ! -d "${IRONFOX_UV_DIR}" ] || [ ! -f "${IRONFOX_PYENV}" ]; then
            echo_red_text "ERROR: You tried to download s3cmd, but you don't have a uv environment set-up yet."
            exit 1
        fi

        if [[ -d "${IRONFOX_PYENV_DIR}/bin/s3cmd" ]]; then
            echo_red_text "s3cmd is already installed at ${IRONFOX_PYENV_DIR}/bin/s3cmd"
            read -p "Do you want to re-download it? [y/N] " -n 1 -r
            echo
            if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
                return 0
            else
                source "${IRONFOX_PYENV}"
                "${IRONFOX_UV}" pip uninstall s3cmd
            fi
        fi
    fi

    echo_red_text "Downloading s3cmd..."
    download_and_extract 's3cmd' "https://github.com/s3tools/s3cmd/archive/${S3CMD_COMMIT}.tar.gz" "${IRONFOX_S3CMD_DIR}" "${S3CMD_SHA512SUM}"

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        source "${IRONFOX_PYENV}"
        echo_red_text 'Installing s3cmd...'
        "${IRONFOX_UV}" pip install --strict "${IRONFOX_S3CMD_DIR}"
        echo_green_text "SUCCESS: Set-up s3cmd at ${IRONFOX_S3CMD}"
    fi
}

# Get Tor's no-op UniFFi binding generator
function get_uniffi() {
    # Get uniffi-bindgen for Linux
    if [ "${IRONFOX_PLATFORM}" == 'linux' ] || [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading prebuilt uniffi-bindgen (Linux)...'
        download_and_extract 'uniffi' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_LINUX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/linux/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_LINUX_IRONFOX_REVISION}-linux.tar.xz" "${IRONFOX_UNIFFI}" "${UNIFFI_LINUX_IRONFOX_SHA512SUM}"
    fi

    # Get uniffi-bindgen for OS X
    if [ "${IRONFOX_PLATFORM}" == 'darwin' ] || [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading prebuilt uniffi-bindgen (OS X)...'
        download_and_extract 'uniffi' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${UNIFFI_OSX_IRONFOX_COMMIT}/uniffi-bindgen/${UNIFFI_VERSION}/osx/uniffi-bindgen-${UNIFFI_VERSION}-${UNIFFI_OSX_IRONFOX_REVISION}-osx.tar.xz" "${IRONFOX_UNIFFI}" "${UNIFFI_OSX_IRONFOX_SHA512SUM}"
    fi

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_green_text "SUCCESS: Set-up the prebuilt uniffi-bindgen at ${IRONFOX_UNIFFI}"
    fi
}

# Get UnifiedPush-AC
function get_up_ac() {
    echo_red_text 'Downloading UnifiedPush-AC...'
    download_and_extract 'unifiedpush-ac' "https://gitlab.com/ironfox-oss/unifiedpush-ac/-/archive/${UNIFIEDPUSHAC_COMMIT}/unifiedpush-ac-${UNIFIEDPUSHAC_COMMIT}.tar.gz" "${IRONFOX_UP_AC}" "${UNIFIEDPUSHAC_SHA512SUM}"
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_green_text "SUCCESS: Set-up UnifiedPush-AC at ${IRONFOX_UP_AC}"
    fi
}

# Get + set-up uv
function get_uv() {
    # If all we're doing is updating the checksum, we don't care if the environment is prepared
    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        if  [ ! -d "${IRONFOX_PYTHON_DIR}" ]; then
            echo_red_text "ERROR: You tried to download uv, but you don't have Python downloaded yet."
            exit 1
        fi

        if [[ -d "${IRONFOX_PYENV_DIR}" ]]; then
            echo_red_text "The uv environment is already set-up at ${IRONFOX_PYENV_DIR}"
            read -p "Do you want to re-create it? [y/N] " -n 1 -r
            echo
            if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
                rm -rf "${IRONFOX_PYENV_DIR}" "${IRONFOX_UV_DIR}" "${IRONFOX_UV_LOCAL}"
            fi
        fi
    fi

    # Set our platform
    if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
        local readonly UV_PLATFORM='apple-darwin'
    else
        local readonly UV_PLATFORM='unknown-linux-gnu'
    fi

    # Set our platform architecture
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        local readonly UV_ARCH='aarch64'
    else
        local readonly UV_ARCH='x86_64'
    fi

    # Set our checksum to verify
    if [ "${IRONFOX_PLATFORM_ARCH}" == 'aarch64' ]; then
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly UV_SHA512SUM="${UV_SHA512SUM_OSX_ARM64}"
        else
            local readonly UV_SHA512SUM="${UV_SHA512SUM_LINUX_ARM64}"
        fi
    else
        if [ "${IRONFOX_PLATFORM}" == 'darwin' ]; then
            local readonly UV_SHA512SUM="${UV_SHA512SUM_OSX_X86_64}"
        else
            local readonly UV_SHA512SUM="${UV_SHA512SUM_LINUX_X86_64}"
        fi
    fi

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading uv (Linux - ARM64)...'
        download_and_extract 'uv' "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-aarch64-unknown-linux-gnu.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM_LINUX_ARM64}"

        echo_red_text 'Downloading uv (Linux - x86_64)...'
        download_and_extract 'uv' "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM_LINUX_X86_64}"

        echo_red_text 'Downloading uv (OS X - ARM64)...'
        download_and_extract 'uv' "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-aarch64-apple-darwin.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM_OSX_ARM64}"

        echo_red_text 'Downloading uv (OS X - x86_64)...'
        download_and_extract 'uv' "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-apple-darwin.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM_OSX_X86_64}"
    else
        echo_red_text 'Downloading uv...'
        download_and_extract 'uv' "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${UV_ARCH}-${UV_PLATFORM}.tar.gz" "${IRONFOX_UV_DIR}" "${UV_SHA512SUM}"

        echo_red_text 'Installing Python...'
        "${IRONFOX_UV}" python install "${PYTHON_VERSION}"

        echo_red_text 'Creating uv environment...'
        "${IRONFOX_UV}" venv "${IRONFOX_PYENV_DIR}"
        echo_green_text "SUCCESS: Set-up uv environment at ${IRONFOX_PYENV_DIR}"
    fi
}

# Get WebAssembly SDK
function get_wasi() {
    # Get WASI SDK for Linux
    if [ "${IRONFOX_PLATFORM}" == 'linux' ] || [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading prebuilt WASI SDK (Linux)...'
        download_and_extract 'wasi-sdk' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_LINUX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/linux/wasi-sdk-${WASI_VERSION}-${WASI_LINUX_IRONFOX_REVISION}-linux.tar.xz" "${IRONFOX_WASI}" "${WASI_LINUX_IRONFOX_SHA512SUM}"
    fi

    # Get WASI SDK for OS X
    if [ "${IRONFOX_PLATFORM}" == 'darwin' ] || [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" == 1 ]; then
        echo_red_text 'Downloading prebuilt WASI SDK (OS X)...'
        download_and_extract 'wasi-sdk' "https://gitlab.com/ironfox-oss/prebuilds/-/raw/${WASI_OSX_IRONFOX_COMMIT}/wasi-sdk/${WASI_VERSION}/osx/wasi-sdk-${WASI_VERSION}-${WASI_OSX_IRONFOX_REVISION}-osx.tar.xz" "${IRONFOX_WASI}" "${WASI_OSX_IRONFOX_SHA512SUM}"
    fi

    if [ "${IRONFOX_GET_SOURCE_CHECKSUM_UPDATE}" != 1 ]; then
        echo_green_text "SUCCESS: Set-up the prebuilt WASI SDK at ${IRONFOX_WASI}"
    fi
}

if [ "${IRONFOX_GET_SOURCE_ANDROID_NDK}" == 1 ]; then
    get_android_ndk
fi

# This needs to run before we get the Android SDK
if [ "${IRONFOX_GET_SOURCE_JDK_25}" == 1 ]; then
    get_jdk_25
fi

if [ "${IRONFOX_GET_SOURCE_ANDROID_SDK}" == 1 ]; then
    get_android_sdk
fi

if [ "${IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS}" == 1 ]; then
    get_android_sdk_build_tools
fi

if [ "${IRONFOX_GET_SOURCE_ANDROID_SDK_BUILD_TOOLS_35}" == 1 ]; then
    get_android_sdk_build_tools_35
fi

if [ "${IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM}" == 1 ]; then
    get_android_sdk_platform
fi

if [ "${IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_36}" == 1 ]; then
    get_android_sdk_platform_36
fi

if [ "${IRONFOX_GET_SOURCE_ANDROID_SDK_PLATFORM_TOOLS}" == 1 ]; then
    get_android_sdk_platform_tools
fi

if [ "${IRONFOX_GET_SOURCE_AS}" == 1 ]; then
    get_as
fi

# This needs to run before we get cbindgen
if [ "${IRONFOX_GET_SOURCE_RUST}" == 1 ]; then
    get_rust
fi

if [ "${IRONFOX_GET_SOURCE_CBINDGEN}" == 1 ]; then
    get_cbindgen
fi

if [ "${IRONFOX_GET_SOURCE_BUNDLETOOL}" == 1 ]; then
    get_bundletool
fi

if [ "${IRONFOX_GET_SOURCE_GECKO}" == 1 ]; then
    get_firefox
fi

if [ "${IRONFOX_GET_SOURCE_GECKO_L10N}" == 1 ]; then
    get_firefox_l10n
fi

if [ "${IRONFOX_GET_SOURCE_GLEAN}" == 1 ]; then
    get_glean
fi

if [ "${IRONFOX_GET_SOURCE_JDK_17}" == 1 ]; then
    get_jdk_17
fi

if [ "${IRONFOX_GET_SOURCE_JDK_21}" == 1 ]; then
    get_jdk_21
fi

# These need to run before we get glean_parser, gyp, and s3cmd
if [ "${IRONFOX_GET_SOURCE_PYTHON}" == 1 ]; then
    get_python
fi

if [ "${IRONFOX_GET_SOURCE_UV}" == 1 ]; then
    get_uv
fi

# This needs to be run before we get glean_parser
if [ "${IRONFOX_GET_SOURCE_PIP}" == 1 ]; then
    get_pip
fi

if [ "${IRONFOX_GET_SOURCE_GLEAN_PARSER}" == 1 ]; then
    get_glean_parser
fi

if [ "${IRONFOX_GET_SOURCE_GRADLE}" == 1 ]; then
    get_gradle
fi

if [ "${IRONFOX_GET_SOURCE_GYP}" == 1 ]; then
    get_gyp
fi

if [ "${IRONFOX_GET_SOURCE_MICROG}" == 1 ]; then
    get_microg
fi

if [ "${IRONFOX_GET_SOURCE_NODE}" == 1 ]; then
    get_node
fi

if [ "${IRONFOX_GET_SOURCE_NPM}" == 1 ]; then
    get_npm
fi

if [ "${IRONFOX_GET_SOURCE_PHOENIX}" == 1 ]; then
    get_phoenix
fi

if [ "${IRONFOX_GET_SOURCE_PREBUILDS}" == 1 ]; then
    get_prebuilds
fi

if [ "${IRONFOX_GET_SOURCE_S3CMD}" == 1 ]; then
    get_s3cmd
fi

if [ "${IRONFOX_GET_SOURCE_UNIFFI}" == 1 ]; then
    get_uniffi
fi

if [ "${IRONFOX_GET_SOURCE_UP_AC}" == 1 ]; then
    get_up_ac
fi

if [ "${IRONFOX_GET_SOURCE_WASI}" == 1 ]; then
    get_wasi
fi
