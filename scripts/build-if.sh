#!/bin/bash
#
#    IronFox build scripts
#    Copyright (C) 2024-2026  Akash Yadav, celenity
#
#    Originally based on: Fennec (Mull) build scripts
#    Copyright (C) 2020-2024  Matías Zúñiga, Andrew Nayenko, Tavi
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

set -euo pipefail

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

if [[ -z "${IRONFOX_FROM_BUILD+x}" ]]; then
    echo_red_text 'ERROR: Do not call build-if.sh directly. Instead, use build.sh.' >&1
    exit 1
fi

if [ -z "${1+x}" ]; then
    echo_red_text "Usage: $0 arm|arm64|x86_64|bundle" >&1
    exit 1
fi

# Set-up target parameters
case "$1" in
arm64)
    # arm64-v8a
    export IRONFOX_TARGET_ARCH='arm64'
    export IRONFOX_TARGET_ABI='arm64-v8a'
    export IRONFOX_TARGET_PRETTY='ARM64'
    IRONFOX_TARGET_RUST='arm64'
    ;;
arm)
    # armeabi-v7a
    export IRONFOX_TARGET_ARCH='arm'
    export IRONFOX_TARGET_ABI='armeabi-v7a'
    export IRONFOX_TARGET_PRETTY='ARM'
    IRONFOX_TARGET_RUST='arm'
    ;;
x86_64)
    # x86_64
    export IRONFOX_TARGET_ARCH='x86_64'
    export IRONFOX_TARGET_ABI='x86_64'
    export IRONFOX_TARGET_PRETTY='x86_64'
    IRONFOX_TARGET_RUST='x86_64'
    ;;
bundle)
    # arm64-v8a, armeabi-v7a, and x86_64
    export IRONFOX_TARGET_ARCH='bundle'
    export IRONFOX_TARGET_ABI='arm64-v8a", "armeabi-v7a", "x86_64'
    export IRONFOX_TARGET_PRETTY='Bundle'
    IRONFOX_TARGET_RUST='arm64,arm,x86_64'
    ;;
*)
    echo_red_text "Unknown build variant: '$1'" >&2
    exit 1
    ;;
esac

if [[ -z "${IRONFOX_SB_GAPI_KEY_FILE+x}" ]]; then
    echo_red_text 'IRONFOX_SB_GAPI_KEY_FILE environment variable has not been specified! Safe Browsing will not be supported in this build.'
    read -p 'Do you want to continue [y/N] ' -n 1 -r
    echo ''
    if ! [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

if [[ -n "${FDROID_BUILD+x}" ]]; then
    source "${IRONFOX_ENV_FDROID}"
fi

source "${IRONFOX_CARGO_ENV}"
source "${IRONFOX_PIP_ENV}"

# Include version info
source "${IRONFOX_VERSIONS}"

# Set timezone to UTC for consistency
unset TZ
export TZ="UTC"

# Functions

function set_build_env() {
    echo_red_text 'Setting build environment variables...'

    # Write env_build.sh
    if [[ -f "${IRONFOX_ENV_BUILD}" ]]; then
        rm "${IRONFOX_ENV_BUILD}"
    fi

    if [ "${IRONFOX_CI}" != 1 ] && [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
        # Set build date for bundle builds, to avoid conflicts and ensure that MOZ_BUILDID is consistent across all builds
        ## (CI handles this at `env_ci.sh` instead)
        BUILD_DATE="$("${IRONFOX_DATE}" -u +"%Y-%m-%dT%H:%M:%SZ")"
        cat > "${IRONFOX_ENV_BUILD}" << EOF
    export IF_BUILD_DATE="${BUILD_DATE}"
    export IRONFOX_TARGET_ARCH="${IRONFOX_TARGET_ARCH}"
EOF
    else
        echo "Writing ${IRONFOX_ENV_BUILD}..."
        cat > "${IRONFOX_ENV_BUILD}" << EOF
    export IRONFOX_TARGET_ARCH="${IRONFOX_TARGET_ARCH}"
EOF
    fi

    source "${IRONFOX_ENV_BUILD}"

    if [ "${IRONFOX_CI}" != 1 ] && [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
        export MOZ_BUILD_DATE="$("${IRONFOX_DATE}" -d "${IF_BUILD_DATE}" "+%Y%m%d%H%M%S")"
    fi

    echo_green_text 'SUCCESS: Set build environment variables'
}

function prep_as() {
    # Application Services
    echo_red_text 'Preparing Application Services...'

    if [[ -f "${IRONFOX_AS}/local.properties" ]]; then
        rm -f "${IRONFOX_AS}/local.properties"
    fi
    cp -f "${IRONFOX_PATCHES}/build/application-services/local.properties" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_AC}|${IRONFOX_AC}|" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN}|${IRONFOX_GLEAN}|" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_AS}/local.properties"

    echo_green_text 'SUCCESS: Prepared Application Services'
}

function prep_fenix() {
    # Fenix
    echo_red_text 'Preparing Fenix...'

    if [[ -f "${IRONFOX_FENIX}/local.properties" ]]; then
        rm -f "${IRONFOX_FENIX}/local.properties"
    fi
    cp -f "${IRONFOX_PATCHES}/build/fenix/local.properties" "${IRONFOX_FENIX}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_AS}|${IRONFOX_AS}|" "${IRONFOX_FENIX}/local.properties"

    # Configure ABI + release channel
    if [[ -f "${IRONFOX_FENIX}/app/build.gradle" ]]; then
        rm -f "${IRONFOX_FENIX}/app/build.gradle"
    fi
    cp -f "${IRONFOX_BUILD}/tmp/fenix/build.gradle" "${IRONFOX_FENIX}/app/build.gradle"

    "${IRONFOX_SED}" -i -e "s/include \".*\"/include \"${IRONFOX_TARGET_ABI}\"/" "${IRONFOX_FENIX}/app/build.gradle"

    if [ "${IRONFOX_TARGET_ARCH}" != 'bundle' ]; then
        # Universal APKs make no sense for architecture-specific builds...
        "${IRONFOX_SED}" -i -e '/universalApk/s/true/false/' "${IRONFOX_FENIX}/app/build.gradle"
    fi

    if [[ -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml" ]]; then
        rm -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    fi
    cp -f "${IRONFOX_BUILD}/tmp/fenix/shortcuts.xml" "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"

     if [[ -d "${IRONFOX_FENIX}/app/src/main/res" ]]; then
        rm -rf "${IRONFOX_FENIX}/app/src/main/res"
    fi
    cp -rf "${IRONFOX_BUILD}/tmp/fenix/res/" "${IRONFOX_FENIX}/app/src/main/res/"

    if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
        IRONFOX_NAME='IronFox'
        "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' "${IRONFOX_FENIX}/app/build.gradle"
        "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    else
        IRONFOX_NAME='Ironfox Nightly'
        "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox.nightly"|' "${IRONFOX_FENIX}/app/build.gradle"
        "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox.nightly/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    fi

    "${IRONFOX_SED}" -i "s/{IRONFOX_NAME}/${IRONFOX_NAME}/" ${IRONFOX_FENIX}/app/src/*/res/values*/*strings.xml

    echo_green_text 'SUCCESS: Prepared Fenix'
}

function prep_gecko_prefs() {
    # Prepare our Gecko preferences
    if [[ -f "${IRONFOX_BUILD}/tmp/gecko/ironfox-parsed.cfg" ]]; then
        rm -f "${IRONFOX_BUILD}/tmp/gecko/ironfox-parsed.cfg"
    fi

    cp -f "${IRONFOX_PATCHES}/build/gecko/ironfox.cfg" "${IRONFOX_BUILD}/tmp/gecko/ironfox-parsed.cfg"
    "${IRONFOX_SED}" -i "s|{IRONFOX_VERSION}|${IRONFOX_VERSION}|" "${IRONFOX_BUILD}/tmp/gecko/ironfox-parsed.cfg"
}

function prep_gecko() {
    # Gecko
    echo_red_text 'Preparing Gecko...'

    if [[ -f "${IRONFOX_GECKO}/local.properties" ]]; then
        rm -f "${IRONFOX_GECKO}/local.properties"
    fi
    cp -f "${IRONFOX_PATCHES}/build/gecko/local.properties" "${IRONFOX_GECKO}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_AC}|${IRONFOX_AC}|" "${IRONFOX_GECKO}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN}|${IRONFOX_GLEAN}|" "${IRONFOX_GECKO}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_GECKO}|${IRONFOX_GECKO}|" "${IRONFOX_GECKO}/local.properties"

    # Ensure our cfg file doesn't already exist
    if [[ -f "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg" ]]; then
        rm -f "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg"
    fi

    # Ensure our policies file doesn't already exist
    if [[ -f "${IRONFOX_GECKO}/ironfox/prefs/policies.json" ]]; then
        rm -f "${IRONFOX_GECKO}/ironfox/prefs/policies.json"
    fi

    echo_green_text 'SUCCESS: Prepared Gecko'
}

function prep_glean() {
    # Glean
    echo_red_text 'Preparing Glean...'

    if [[ -f "${IRONFOX_GLEAN}/local.properties" ]]; then
        rm -f "${IRONFOX_GLEAN}/local.properties"
    fi
    cp -f "${IRONFOX_PATCHES}/build/glean/local.properties" "${IRONFOX_GLEAN}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_GLEAN}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_GLEAN}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_GLEAN}/local.properties"

    # Set Glean's uniffi-bindgen location
    if [[ -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle" ]]; then
        rm -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
    fi
    cp -f "${IRONFOX_BUILD}/tmp/glean/build.gradle" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
    "${IRONFOX_SED}" -i "s|{IRONFOX_UNIFFI}|${IRONFOX_UNIFFI}|" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"

    echo_green_text 'SUCCESS: Prepared Glean'
}

function prep_up_ac() {
    # unifiedpush-ac
    echo_red_text 'Preparing UnifiedPush-AC...'

    if [[ -f "${IRONFOX_UP_AC}/local.properties" ]]; then
        rm -f "${IRONFOX_UP_AC}/local.properties"
    fi
    cp -f "${IRONFOX_PATCHES}/build/unifiedpush-ac/local.properties" "${IRONFOX_UP_AC}/local.properties"
    "${IRONFOX_SED}" -i "s|{FIREFOX_VERSION}|${FIREFOX_VERSION}|" "${IRONFOX_UP_AC}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_AS}|${IRONFOX_AS}|" "${IRONFOX_UP_AC}/local.properties"

    echo_green_text 'SUCCESS: Prepared UnifiedPush-AC'
}

function prep_llvm() {
    # LLVM
    echo_red_text 'Preparing LLVM...'

    # Set LLVM build targets
    if [[ -f "${IRONFOX_BUILD}/targets_to_build" ]]; then
        rm -f "${IRONFOX_BUILD}/targets_to_build"
    fi
    cp -f "${IRONFOX_PATCHES}/build/llvm/targets_to_build_${IRONFOX_TARGET_ARCH}" "${IRONFOX_BUILD}/targets_to_build"

    echo_green_text 'SUCCESS: Prepared LLVM'
}

function clean_gradle() {
    # This is used for cleaning Gradle to ensure builds are fresh
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} clean
}

function build_bundletool() {
    # Bundletool
    echo_red_text 'Building Bundletool...'

    pushd "${IRONFOX_BUNDLETOOL}"
    "${IRONFOX_GRADLE}" assemble
    popd

    echo_green_text 'SUCCESS: Built Bundletool'
}

function build_llvm() {
    # LLVM
    echo_red_text 'Building LLVM...'

    pushd "${llvm}"
    llvmtarget=$(cat "${IRONFOX_BUILD}/targets_to_build")
    echo_green_text "building llvm for ${llvmtarget}"
    cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=out -DCMAKE_C_COMPILER=clang-20 \
        -DCMAKE_CXX_COMPILER=clang++-20 -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="$llvmtarget" \
        -DLLVM_USE_LINKER=lld -DLLVM_BINUTILS_INCDIR=/usr/include -DLLVM_ENABLE_PLUGINS=FORCE_ON \
        -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
    cmake --build build -j"$(nproc)"
    cmake --build build --target install -j"$(nproc)"
    popd

    echo_green_text 'SUCCESS: Built LLVM'
}

function build_phoenix() {
    # Build Phoenix...
    echo_red_text 'Building Phoenix...'

    pushd "${IRONFOX_PHOENIX}"
    bash -x "${IRONFOX_PHOENIX}/scripts/build.sh"
    popd

    echo_green_text 'SUCCESS: Built Phoenix'
}

function build_prebuilds() {
    # Build our prebuilt libraries from source
    echo_red_text 'Building prebuilt libraries...'

    pushd "${IRONFOX_PREBUILDS}"
    bash -x "${IRONFOX_PREBUILDS}/scripts/build.sh"
    popd

    echo_green_text 'SUCCESS: Built prebuilt libraries'
}

function build_microg() {
    # microG
    echo_red_text 'Building microG...'

    pushd "${IRONFOX_GMSCORE}"
    clean_gradle

    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dhttps.protocols=TLSv1.3 -x javaDocReleaseGeneration \
        :play-services-base:publishToMavenLocal \
        :play-services-basement:publishToMavenLocal \
        :play-services-fido:publishToMavenLocal \
        :play-services-tasks:publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built microG'
}

function build_glean() {
    # Glean
    echo_red_text 'Building Glean...'

    pushd "${IRONFOX_GLEAN}"
    clean_gradle

    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} :glean-native:publishToMavenLocal
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built Glean'
}

function build_as() {
    # Application Services
    echo_red_text 'Building Application Services...'

    pushd "${IRONFOX_AS}"
    clean_gradle

    # When 'CI' environment variable is set to a non-zero value, the 'libs/verify-ci-android-environment.sh' script
    # skips building the libraries as they are expected to be already downloaded in a CI environment
    # However, we want build those libraries always, so we set CI='' before invoking the script
    CI='' bash -c "./libs/verify-android-environment.sh && ${IRONFOX_GRADLE} ${IRONFOX_GRADLE_FLAGS} :tooling-nimbus-gradle:publishToMavenLocal"
    popd

    echo_green_text 'SUCCESS: Built Application Services'
}

function build_gecko_ind() {
    # Build Gecko
    unset IRONFOX_MACH_BUILD
    unset MOZ_CHROME_MULTILOCALE
    export IRONFOX_MACH_BUILD=1

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure
    "${IRONFOX_MACH}" build
    popd
}

function package_gecko() {
    # Package Gecko
    unset IRONFOX_MACH_BUILD
    export IRONFOX_MACH_BUILD=0
    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure

    # We don't want to clean Gradle here on bundle builds, because doing so will cause it to clean after each architecture is built...
    if [ "${IRONFOX_TARGET_ARCH}" != 'bundle' ]; then
        "${IRONFOX_MACH}" gradle geckoview:clean
    fi

    echo_green_text "Running ${IRONFOX_MACH} package..."
    "${IRONFOX_MACH}" package

    echo_green_text "Running ${IRONFOX_MACH} package-multi-locale..."
    "${IRONFOX_MACH}" package-multi-locale --locales ${IRONFOX_GECKO_LOCALES}

    export MOZ_CHROME_MULTILOCALE="${IRONFOX_GECKO_LOCALES}"

    # Package GeckoView
    ## (MOZ_AUTOMATION is set here to create the AAR zips)
    echo_green_text "Running ${IRONFOX_MACH} android archive-geckoview..."
    MOZ_AUTOMATION=1 "${IRONFOX_MACH}" android archive-geckoview
    unset MOZ_AUTOMATION
    popd
}

# Create our fat GeckoView AAR...
function create_fat_aar() {
    # Fat AAR
    unset IRONFOX_MACH_BUILD
    export IRONFOX_MACH_BUILD=0

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure
    "${IRONFOX_MACH}" build android-fat-aar-artifact
    popd
}

function build_gecko_arm64() {
    # ARM64
    unset IRONFOX_MACH_TARGET_BUNDLE_ARM64
    export IRONFOX_MACH_TARGET_BUNDLE_ARM64=1

    pushd "${IRONFOX_GECKO}"
    echo_red_text 'Building Gecko(View) - ARM64...'
    build_gecko_ind
    echo_green_text 'SUCCESS: Built Gecko(View) - ARM64'

    echo_red_text 'Packaging Gecko(View) - ARM64...'
    package_gecko
    echo_green_text 'SUCCESS: Packaged Gecko(View) - ARM64'
    popd

    cp -vf "${IRONFOX_GV_AAR_ARM64}" "${IRONFOX_OUTPUTS_GV_AAR_ARM64}"

    if [ "${IRONFOX_CI}" == 1 ]; then
        cp -vf "${IRONFOX_OUTPUTS_GV_AAR_ARM64}" "${IRONFOX_AAR_ARTIFACTS}/"
    fi
    unset IRONFOX_MACH_TARGET_BUNDLE_ARM64
    export IRONFOX_MACH_TARGET_BUNDLE_ARM64=0
}

function build_gecko_arm() {
    # ARM
    unset IRONFOX_MACH_TARGET_BUNDLE_ARM
    export IRONFOX_MACH_TARGET_BUNDLE_ARM=1

    pushd "${IRONFOX_GECKO}"
    echo_red_text 'Building Gecko(View) - ARM...'
    build_gecko_ind
    echo_green_text 'SUCCESS: Built Gecko(View) - ARM'

    echo_red_text 'Packaging Gecko - ARM...'
    package_gecko
    echo_green_text 'SUCCESS: Packaged Gecko(View) - ARM'
    popd

    cp -vf "${IRONFOX_GV_AAR_ARM}" "${IRONFOX_OUTPUTS_GV_AAR_ARM}"

    if [ "${IRONFOX_CI}" == 1 ]; then
        cp -vf "${IRONFOX_OUTPUTS_GV_AAR_ARM}" "${IRONFOX_AAR_ARTIFACTS}/"
    fi
    unset IRONFOX_MACH_TARGET_BUNDLE_ARM
    export IRONFOX_MACH_TARGET_BUNDLE_ARM=0
}

function build_gecko_x86_64() {
    # x86_64
    unset IRONFOX_MACH_TARGET_BUNDLE_X86_64
    export IRONFOX_MACH_TARGET_BUNDLE_X86_64=1

    pushd "${IRONFOX_GECKO}"
    echo_red_text 'Building Gecko(View) - x86_64...'
    build_gecko_ind
    echo_green_text 'SUCCESS: Built Gecko(View) - x86_64'

    echo_red_text 'Packaging Gecko(View) - x86_64...'
    package_gecko
    echo_green_text 'SUCCESS: Packaged Gecko(View) - x86_64'
    unset IRONFOX_MACH_TARGET_BUNDLE_X86_64
    export IRONFOX_MACH_TARGET_BUNDLE_X86_64=0
    "${IRONFOX_MACH}" configure
    popd

    cp -vf "${IRONFOX_GV_AAR_X86_64}" "${IRONFOX_OUTPUTS_GV_AAR_X86_64}"

    if [ "${IRONFOX_CI}" == 1 ]; then
        cp -vf "${IRONFOX_OUTPUTS_GV_AAR_X86_64}" "${IRONFOX_AAR_ARTIFACTS}/"
    fi
}

function build_gecko_bundle() {
    # Bundle
    export MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'

    if [ "${IRONFOX_CI}" == 1 ]; then
        export MOZ_ANDROID_FAT_AAR_ARM64_V8A="${IRONFOX_AAR_ARTIFACTS}/geckoview-arm64-v8a.zip"
        export MOZ_ANDROID_FAT_AAR_ARMEABI_V7A="${IRONFOX_AAR_ARTIFACTS}/geckoview-armeabi-v7a.zip"
        export MOZ_ANDROID_FAT_AAR_X86_64="${IRONFOX_AAR_ARTIFACTS}/geckoview-x86_64.zip"
    else
        export MOZ_ANDROID_FAT_AAR_ARM64_V8A="${IRONFOX_OUTPUTS_GV_AAR_ARM64}"
        export MOZ_ANDROID_FAT_AAR_ARMEABI_V7A="${IRONFOX_OUTPUTS_GV_AAR_ARM}"
        export MOZ_ANDROID_FAT_AAR_X86_64="${IRONFOX_OUTPUTS_GV_AAR_X86_64}"
    fi

    pushd "${IRONFOX_GECKO}"
    echo_red_text 'Creating GeckoView fat AAR...'
    create_fat_aar
    echo_green_text 'SUCCESS: Created GeckoView fat AAR'

    echo_red_text 'Building Gecko(View) - Bundle...'
    build_gecko_ind
    echo_green_text 'SUCCESS: Built Gecko(View) - Bundle'

    echo_red_text 'Packaging Gecko(View) - Bundle...'
    package_gecko
    echo_green_text 'SUCCESS: Packaged Gecko(View) - Bundle'
    popd
}

function clobber_gecko_arm64() {
    # Clobber Gecko (ARM64)
    unset IRONFOX_MACH_TARGET_BUNDLE_ARM64
    export IRONFOX_MACH_TARGET_BUNDLE_ARM64=1

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure
    "${IRONFOX_MACH}" clobber
    unset IRONFOX_MACH_TARGET_BUNDLE_ARM64
    export IRONFOX_MACH_TARGET_BUNDLE_ARM64=0
    "${IRONFOX_MACH}" configure
    popd
}

function clobber_gecko_arm() {
    # Clobber Gecko (ARM)
    unset IRONFOX_MACH_TARGET_BUNDLE_ARM
    export IRONFOX_MACH_TARGET_BUNDLE_ARM=1

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure
    "${IRONFOX_MACH}" clobber
    unset IRONFOX_MACH_TARGET_BUNDLE_ARM
    export IRONFOX_MACH_TARGET_BUNDLE_ARM=0
    "${IRONFOX_MACH}" configure
    popd
}

function clobber_gecko_x86_64() {
    # Clobber Gecko (x86_64)
    unset IRONFOX_MACH_TARGET_BUNDLE_X86_64
    export IRONFOX_MACH_TARGET_BUNDLE_X86_64=1

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure
    "${IRONFOX_MACH}" clobber
    unset IRONFOX_MACH_TARGET_BUNDLE_X86_64
    export IRONFOX_MACH_TARGET_BUNDLE_X86_64=0
    "${IRONFOX_MACH}" configure
    popd
}

function clobber_gecko() {
    "${IRONFOX_MACH}" configure
    "${IRONFOX_MACH}" clobber
    if [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ] && [ "${IRONFOX_CI}" != 1 ]; then
        clobber_gecko_arm64
        clobber_gecko_arm
        clobber_gecko_x86_64
    fi
}

function build_gecko() {
    # Gecko (Firefox)
    echo_red_text 'Building Gecko(View)...'
    unset IRONFOX_MACH_TARGET_GECKO
    export IRONFOX_MACH_TARGET_GECKO=1

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure

    # Always clobber to ensure that builds are fresh
    clobber_gecko

    if [ "${IRONFOX_TARGET_ARCH}" != 'bundle' ] || [ "${IRONFOX_CI}" == 1 ]; then
        if [ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]; then
            # Build ARM64
            build_gecko_arm64
        elif [ "${IRONFOX_TARGET_ARCH}" == 'arm' ]; then
            # Build ARM
            build_gecko_arm
        elif [ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]; then
            # Build x86_64
            build_gecko_x86_64
        elif [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
            # Create our bundle + fat AAR...
            build_gecko_bundle
        fi
    elif [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
        # 1. Build ARM64
        build_gecko_arm64

        # 2. Build ARM
        build_gecko_arm

        # 3. Build x86_64
        build_gecko_x86_64

        # 4. Finally, create our bundle + fat AAR...
        build_gecko_bundle
    fi
    unset IRONFOX_MACH_TARGET_GECKO
    export IRONFOX_MACH_TARGET_GECKO=0
    "${IRONFOX_MACH}" configure
    popd

    echo_green_text 'SUCCESS: Built Gecko(View)'
}

function build_ac() {
    # Android Components
    echo_red_text 'Building Android Components (Part 1/2)...'
    unset IRONFOX_MACH_BUILD
    unset IRONFOX_MACH_TARGET_AC
    export IRONFOX_MACH_BUILD=1
    export IRONFOX_MACH_TARGET_AC=1

    # Ensure the CI env variable is not set here - otherwise this will cause build failure in Application Services, thanks to us removing MARS and friends
    unset CI

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure

    # Always clean Gradle to ensure builds are fresh
    "${IRONFOX_MACH}" gradle -p mobile/android/android-components clean

    # Publish concept-fetch (required by A-S) with auto-publication disabled,
    # otherwise automatically triggered publication of A-S and publications of unifiedpush-ac will fail
    "${IRONFOX_MACH}" gradle -p mobile/android/android-components :components:concept-fetch:publishToMavenLocal

    # unifiedpush-ac also needs concept-base (dependency of support-base), support-base and ui-icons
    "${IRONFOX_MACH}" gradle -p mobile/android/android-components :components:concept-base:publishToMavenLocal
    "${IRONFOX_MACH}" gradle -p mobile/android/android-components :components:support-base:publishToMavenLocal
    "${IRONFOX_MACH}" gradle -p mobile/android/android-components :components:ui-icons:publishToMavenLocal

    unset IRONFOX_MACH_TARGET_AC
    export IRONFOX_MACH_TARGET_AC=0
    "${IRONFOX_MACH}" configure
    popd

    echo_green_text 'SUCCESS: Built Android Components (Part 1/2)'
}

function build_up_ac() {
    # unifiedpush-ac
    echo_red_text 'Building UnifiedPush-AC...'

    pushd "${IRONFOX_UP_AC}"
    # Always clean Gradle to ensure builds are fresh
    clean_gradle

    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built UnifiedPush-AC'
}

function build_ac_cont() {
    # Android Components (Part 2...)
    echo_red_text 'Building Android Components (Part 2/2)...'
    unset IRONFOX_MACH_BUILD
    unset IRONFOX_MACH_TARGET_AC
    export IRONFOX_MACH_BUILD=1
    export IRONFOX_MACH_TARGET_AC=1

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure
    # Enable the auto-publication workflow
    echo "## Enable the auto-publication workflow for Application Services" >>"${IRONFOX_GECKO}/local.properties"
    echo "autoPublish.application-services.dir=${IRONFOX_AS}" >>"${IRONFOX_GECKO}/local.properties"
    "${IRONFOX_MACH}" gradle -p mobile/android/android-components publishToMavenLocal
    unset IRONFOX_MACH_TARGET_AC
    export IRONFOX_MACH_TARGET_AC=0
    "${IRONFOX_MACH}" configure
    popd

    echo_green_text 'SUCCESS: Built Android Components (Part 2/2)'
}

function build_fenix() {
    # Fenix
    echo_red_text 'Building Fenix...'
    unset IRONFOX_MACH_BUILD
    unset IRONFOX_MACH_TARGET_FENIX
    export IRONFOX_MACH_BUILD=1
    export IRONFOX_MACH_TARGET_FENIX=1

    pushd "${IRONFOX_GECKO}"
    "${IRONFOX_MACH}" configure

    # Always clean Gradle to ensure builds are fresh
    "${IRONFOX_MACH}" gradle fenix:clean

    # Build our APKs
    "${IRONFOX_MACH}" gradle fenix:assembleRelease

    if [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        # 1. Export APK for ARM64
        if [ "${IRONFOX_SIGN}" == 1 ]; then
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-arm64-v8a-release-unsigned.apk" "${IRONFOX_OUTPUTS_FENIX_ARM64_UNSIGNED}"
        else
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-arm64-v8a-release.apk" "${IRONFOX_OUTPUTS_FENIX_ARM64_UNSIGNED}"
        fi

        # 2. Export APK for ARM
        if [ "${IRONFOX_SIGN}" == 1 ]; then
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-armeabi-v7a-release-unsigned.apk" "${IRONFOX_OUTPUTS_FENIX_ARM_UNSIGNED}"
        else
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-armeabi-v7a-release.apk" "${IRONFOX_OUTPUTS_FENIX_ARM_UNSIGNED}"
        fi

        # 3. Export APK for x86_64
        if [ "${IRONFOX_SIGN}" == 1 ]; then
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-x86_64-release-unsigned.apk" "${IRONFOX_OUTPUTS_FENIX_X86_64_UNSIGNED}"
        else
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-x86_64-release.apk" "${IRONFOX_OUTPUTS_FENIX_X86_64_UNSIGNED}"
        fi

        # 4. Export universal APK
        if [ "${IRONFOX_SIGN}" == 1 ]; then
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-universal-release-unsigned.apk" "${IRONFOX_OUTPUTS_FENIX_UNIVERSAL_UNSIGNED}"
        else
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-universal-release.apk" "${IRONFOX_OUTPUTS_FENIX_UNIVERSAL_UNSIGNED}"
        fi

        # 5. Finally, build and export our AAB
        "${IRONFOX_MACH}" gradle -Paab fenix:bundleRelease
        cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/bundle/fenixRelease/app-fenix-release.aab" "${IRONFOX_OUTPUTS_FENIX_AAB}"
    else
        # Export APK
        if [ "${IRONFOX_SIGN}" == 1 ]; then
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-${IRONFOX_TARGET_ABI}-release-unsigned.apk" "${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ABI}.apk"
        else
            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/fenix-${IRONFOX_TARGET_ABI}-release.apk" "${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ABI}.apk"
        fi
    fi
    unset IRONFOX_MACH_TARGET_FENIX
    export IRONFOX_MACH_TARGET_FENIX=0
    "${IRONFOX_MACH}" configure
    popd

    echo_green_text 'SUCCESS: Built Fenix'
}

# Prepare build environment...
## (These need to be performed here instead of in `prebuild.sh`, so that we can account for if users decide to
### change the variables, without them needing to re-run the entire prebuild script...)
echo_red_text 'Preparing your build environment...'

set_build_env
prep_as
prep_gecko
prep_gecko_prefs
prep_glean
prep_llvm

if [ "${IRONFOX_CI}" != 1 ] || [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
    prep_fenix
    prep_up_ac
fi

## Create CI artifact directories if necessary
if [ "${IRONFOX_CI}" == 1 ]; then
    mkdir -vp "${IRONFOX_AAR_ARTIFACTS}"
    mkdir -vp "${IRONFOX_APK_ARTIFACTS}"
    mkdir -vp "${IRONFOX_APKS_ARTIFACTS}"
fi

echo_green_text 'SUCCESS: Prepared build environment'

# Begin the build...
echo_red_text "Building IronFox ${IRONFOX_VERSION}: ${IRONFOX_CHANNEL_PRETTY} (${IRONFOX_TARGET_PRETTY})..."

if [[ -n "${FDROID_BUILD+x}" ]]; then
    build_bundletool
    build_llvm
fi

if [[ "${IRONFOX_NO_PREBUILDS}" == 1 ]]; then
    build_prebuilds
fi

build_microg
build_phoenix
build_glean
build_as
build_gecko

if [ "${IRONFOX_CI}" != 1 ] || [ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]; then
    build_ac
    build_up_ac
    build_ac_cont
    build_fenix
    echo_green_text "SUCCESS: Built IronFox ${IRONFOX_VERSION}: ${IRONFOX_CHANNEL_PRETTY} (${IRONFOX_TARGET_PRETTY})"
fi
