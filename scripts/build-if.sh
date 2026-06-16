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
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [[ -z "${IRONFOX_FROM_BUILD+x}" ]]; then
    echo_red_text 'ERROR: Do not call build-if.sh directly. Instead, use build.sh.' >&1
    exit 1
fi

if [[ ! -f "${IRONFOX_BUILD}/finished-prebuild" ]]; then
    echo_red_text 'ERROR: Do not run build.sh until after you have ran prebuild.sh.'
    exit 1
fi

# Set-up target parameters
readonly build_arch="$1"
readonly build_project="$2"

case "${build_arch}" in
arm64)
    # arm64-v8a
    readonly IRONFOX_TARGET_ARCH='arm64'
    readonly IRONFOX_TARGET_ABI='arm64-v8a'
    readonly IRONFOX_TARGET_PRETTY='ARM64'
    readonly IRONFOX_TARGET_RUST='arm64'
    ;;
arm)
    # armeabi-v7a
    readonly IRONFOX_TARGET_ARCH='arm'
    readonly IRONFOX_TARGET_ABI='armeabi-v7a'
    readonly IRONFOX_TARGET_PRETTY='ARM'
    readonly IRONFOX_TARGET_RUST='arm'
    ;;
x86_64)
    # x86_64
    readonly IRONFOX_TARGET_ARCH='x86_64'
    readonly IRONFOX_TARGET_ABI='x86_64'
    readonly IRONFOX_TARGET_PRETTY='x86_64'
    readonly IRONFOX_TARGET_RUST='x86_64'
    ;;
bundle)
    # arm64-v8a, armeabi-v7a, and x86_64
    readonly IRONFOX_TARGET_ARCH='bundle'
    readonly IRONFOX_TARGET_ABI='arm64-v8a", "armeabi-v7a", "x86_64'
    readonly IRONFOX_TARGET_PRETTY='Bundle'
    readonly IRONFOX_TARGET_RUST='arm64,arm,x86_64'
    ;;
*)
    echo_red_text "Unknown build variant: '$1'" >&2
    exit 1
    ;;
esac
export IRONFOX_TARGET_ARCH
export IRONFOX_TARGET_ABI
export IRONFOX_TARGET_PRETTY

# If a project-specific argument is specified, we only build that project
## (ex. used by CI for building GeckoView AARs)
IRONFOX_BUILD_GECKOVIEW_ONLY=0
if [[ "${build_project}" == 'geckoview' ]]; then
    IRONFOX_BUILD_GECKOVIEW_ONLY=1
elif [[ "${build_project}" != 'all' ]]; then
    echo_red_text "ERROR: Invalid target project: ${build_project}\n You must enter one of the following:"
    echo 'All:          all (Default)'
    echo 'GeckoView:    geckoview'
    exit 1
fi
readonly IRONFOX_BUILD_GECKOVIEW_ONLY

# Ensure IRONFOX_CHANNEL is properly set
if [[ "${IRONFOX_CHANNEL}" != 'release' ]] && [[ "${IRONFOX_CHANNEL}" != 'nightly' ]]; then
    echo_red_text "ERROR: Invalid release channel (IRONFOX_CHANNEL): ${IRONFOX_CHANNEL}"
    exit 1
fi

if [[ ! -d "${IRONFOX_ANDROID_SDK}" ]]; then
    echo_red_text "\$IRONFOX_ANDROID_SDK($IRONFOX_ANDROID_SDK) does not exist."
    exit 1
fi

if [[ ! -d "${IRONFOX_ANDROID_NDK}" ]]; then
    echo_red_text "\$IRONFOX_ANDROID_NDK($IRONFOX_ANDROID_NDK) does not exist."
    exit 1
fi

readonly JAVA_VER=$("${IRONFOX_JAVA}" -version 2>&1 | "${IRONFOX_AWK}" -F '"' '/version/ {print $2}' | "${IRONFOX_AWK}" -F '.' '{sub("^$", "0", $2); print $1$2}')
[[ "${JAVA_VER}" -ge 15 ]] || {
    echo_red_text "Java 17 or newer must be set as default JDK"
    exit 1
}

if [[ "${IRONFOX_SB_GAPI_KEY_FILE}" == 'null' ]]; then
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
source "${IRONFOX_NVM_ENV}"
source "${IRONFOX_PYENV}"

# Include version info
source "${IRONFOX_VERSIONS}"

if [[ -z "${FIREFOX_VERSION}" ]]; then
    echo_red_text "\$FIREFOX_VERSION is not set! Aborting..."
    exit 1
fi

if [[ -z "${IRONFOX_VERSION}" ]]; then
    echo_red_text "\$IRONFOX_VERSION is not set! Aborting..."
    exit 1
fi

# Set timezone to UTC for consistency
unset TZ
export TZ="UTC"

# Functions

# Set-up our build environment
function set_build_env() {
    echo_red_text 'Setting build environment variables...'

    # First, clean our environment
    unset IF_BUILD_ID
    unset IF_LOCAL_AC_VERSION_STAMP
    unset IF_LOCAL_AS_VERSION_STAMP
    unset IF_LOCAL_GLEAN_VERSION_STAMP
    unset MOZ_BUILD_DATE

    # Write env_build.sh
    if [[ -f "${IRONFOX_ENV_BUILD}" ]]; then
        rm "${IRONFOX_ENV_BUILD}"
    fi

    local readonly IF_BUILD_DATE="$("${IRONFOX_DATE}" -u +"%Y-%m-%dT%H:%M:%SZ")"
    local readonly IF_LOCAL_VERSION_STAMP="$("${IRONFOX_DATE}" "+%s%N")"

    # Override Gecko(View)'s build ID (if desired)
    if [[ "${IRONFOX_BUILD_ID_OVERRIDE}" != 'null' ]]; then
        IF_BUILD_ID="${IRONFOX_BUILD_ID_OVERRIDE}"
    elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        IF_BUILD_ID="$("${IRONFOX_DATE}" -d "${IF_BUILD_DATE}" "+%Y%m%d%H%M%S")"
    else
        IF_BUILD_ID='null'
    fi

    # Override our version for local Android Components substitution (if desired)
    if [[ "${IRONFOX_LOCAL_AC_VERSION_OVERRIDE}" != 'null' ]]; then
        IF_LOCAL_AC_VERSION_STAMP="${IRONFOX_LOCAL_AC_VERSION_OVERRIDE}"
    else
        IF_LOCAL_AC_VERSION_STAMP="${IF_LOCAL_VERSION_STAMP}-SNAPSHOT"
    fi

    # Override our version for local Application Services substitution (if desired)
    if [[ "${IRONFOX_LOCAL_AS_VERSION_OVERRIDE}" != 'null' ]]; then
        IF_LOCAL_AS_VERSION_STAMP="${IRONFOX_LOCAL_AS_VERSION_OVERRIDE}"
    else
        IF_LOCAL_AS_VERSION_STAMP="${IF_LOCAL_VERSION_STAMP}-SNAPSHOT"
    fi

    # Override our version for local Glean substitution (if desired)
    if [[ "${IRONFOX_LOCAL_GLEAN_VERSION_OVERRIDE}" != 'null' ]]; then
        IF_LOCAL_GLEAN_VERSION_STAMP="${IRONFOX_LOCAL_GLEAN_VERSION_OVERRIDE}"
    else
        IF_LOCAL_GLEAN_VERSION_STAMP="${IF_LOCAL_VERSION_STAMP}-SNAPSHOT"
    fi

    echo "Writing ${IRONFOX_ENV_BUILD}..."
    cat > "${IRONFOX_ENV_BUILD}" << EOF
readonly IF_BUILD_ID="${IF_BUILD_ID}"
readonly IF_LOCAL_AC_VERSION_STAMP="${IF_LOCAL_AC_VERSION_STAMP}"
readonly IF_LOCAL_AS_VERSION_STAMP="${IF_LOCAL_AS_VERSION_STAMP}"
readonly IF_LOCAL_GLEAN_VERSION_STAMP="${IF_LOCAL_GLEAN_VERSION_STAMP}"
EOF

    source "${IRONFOX_ENV_BUILD}"

    # Set Gecko(View)'s build ID
    if [[ "${IF_BUILD_ID}" != 'null' ]]; then
        readonly MOZ_BUILD_DATE="${IF_BUILD_ID}"
        export MOZ_BUILD_DATE
    fi

    # Set versions for our local dependency substitutions
    readonly IF_LOCAL_AC_VERSION="0.0.1-local-${FIREFOX_VERSION}-${IF_LOCAL_AC_VERSION_STAMP}"
    readonly IF_LOCAL_AC_VERSION_GRADLE="-${FIREFOX_VERSION}-${IF_LOCAL_AC_VERSION_STAMP}"
    readonly IF_LOCAL_AS_VERSION="0.0.1-SNAPSHOT-${APPSERVICES_VERSION}-${IF_LOCAL_AS_VERSION_STAMP}"
    readonly IF_LOCAL_AS_VERSION_GRADLE="${APPSERVICES_VERSION}-${IF_LOCAL_AS_VERSION_STAMP}"
    readonly IF_LOCAL_GLEAN_VERSION="0.0.1-SNAPSHOT-${GLEAN_VERSION}-${IF_LOCAL_GLEAN_VERSION_STAMP}"
    readonly IF_LOCAL_GLEAN_VERSION_GRADLE="${GLEAN_VERSION}-${IF_LOCAL_GLEAN_VERSION_STAMP}"

    echo_green_text 'SUCCESS: Set build environment variables'
}

# Prepare Application Services
function prep_as() {
    echo_red_text 'Preparing Application Services...'

    if [[ -f "${IRONFOX_AS}/local.properties" ]]; then
        rm -f "${IRONFOX_AS}/local.properties"
    fi
    cp -f "${IRONFOX_TEMPLATES}/application-services/local.properties" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_AS}/local.properties"

    # Substitute our builds of Android Components
    "${IRONFOX_SED}" -i -e "/^android-components = \"/c\\android-components = \"${IF_LOCAL_AC_VERSION}\"" "${IRONFOX_AS}/gradle/libs.versions.toml"

    echo_green_text 'SUCCESS: Prepared Application Services'
}

# Prepare Fenix
function prep_fenix() {
    echo_red_text 'Preparing Fenix...'

    # Configure ABI + release channel
    if [[ -f "${IRONFOX_FENIX}/app/build.gradle" ]]; then
        rm -f "${IRONFOX_FENIX}/app/build.gradle"
    fi
    cp -f "${IRONFOX_BUILD}/tmp/fenix/app/build.gradle" "${IRONFOX_FENIX}/app/build.gradle"

    "${IRONFOX_SED}" -i -e "s/include \"armeabi-v7a\", \"arm64-v8a\", \"x86_64\"/include \"${IRONFOX_TARGET_ABI}\"/" "${IRONFOX_FENIX}/app/build.gradle"

    if [[ "${IRONFOX_TARGET_ARCH}" != 'bundle' ]]; then
        # Universal APKs make no sense for architecture-specific builds...
        "${IRONFOX_SED}" -i -e '/universalApk/s/true/false/' "${IRONFOX_FENIX}/app/build.gradle"
    fi

    if [[ -f "${IRONFOX_FENIX}/app/src/release/res/values/static_strings.xml" ]]; then
        rm -f "${IRONFOX_FENIX}/app/src/release/res/values/static_strings.xml"
    fi
    cp -f "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/values/static_strings.xml" "${IRONFOX_FENIX}/app/src/release/res/values/static_strings.xml"

    if [[ -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml" ]]; then
        rm -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    fi
    cp -f "${IRONFOX_BUILD}/tmp/fenix/app/src/release/res/xml/shortcuts.xml" "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"

    if [[ -d "${IRONFOX_FENIX}/app/src/main/res" ]]; then
        rm -rf "${IRONFOX_FENIX}/app/src/main/res"
    fi
    cp -rf "${IRONFOX_BUILD}/tmp/fenix/app/src/main/res/" "${IRONFOX_FENIX}/app/src/main/res/"

    if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
        "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' "${IRONFOX_FENIX}/app/build.gradle"
        "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    else
        "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox.nightly"|' "${IRONFOX_FENIX}/app/build.gradle"
        "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox.nightly/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    fi

    "${IRONFOX_SED}" -i "s/{IRONFOX_NAME}/${IRONFOX_NAME}/" ${IRONFOX_FENIX}/app/src/*/res/values*/*strings.xml

    echo_green_text 'SUCCESS: Prepared Fenix'
}

# Prepare mozilla-central
function prep_gecko() {
    echo_red_text 'Preparing Gecko...'

    if [[ -f "${IRONFOX_GECKO}/local.properties" ]]; then
        rm -f "${IRONFOX_GECKO}/local.properties"
    fi
    cp -f "${IRONFOX_TEMPLATES}/gecko/local.properties" "${IRONFOX_GECKO}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_MOZCONFIGS}|${IRONFOX_MOZCONFIGS}|" "${IRONFOX_GECKO}/local.properties"

    # Substitute Android Components
    "${IRONFOX_SED}" -i "s|{IF_LOCAL_AC_VERSION}|${IF_LOCAL_AC_VERSION}|" "${IRONFOX_GECKO}/local.properties"

    # Substitute Application Services
    "${IRONFOX_SED}" -i -e "s|val VERSION = .*|val VERSION = \""${IF_LOCAL_AS_VERSION}\""|g" "${IRONFOX_AC}/plugins/dependencies/src/main/java/ApplicationServices.kt"
    "${IRONFOX_SED}" -i "s|{IF_LOCAL_AS_VERSION}|${IF_LOCAL_AS_VERSION}|" "${IRONFOX_GECKO}/local.properties"

    # Substitute Glean
    "${IRONFOX_SED}" -i -e "/^glean = \"/c\\glean = \"${IF_LOCAL_GLEAN_VERSION}\"" "${IRONFOX_GECKO}/gradle/libs.versions.toml"

    # Configure release channel
    if [[ -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html" ]]; then
        rm -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html"
    fi
    cp -f "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages/connection-not-secure.html" "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html"
    "${IRONFOX_SED}" -i "s/{IRONFOX_NAME}/${IRONFOX_NAME}/" "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html"

    if [[ -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html" ]]; then
        rm -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html"
    fi
    cp -f "${IRONFOX_BUILD}/tmp/gecko/toolkit/content/neterror/supportpages/time-errors.html" "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html"
    "${IRONFOX_SED}" -i "s/{IRONFOX_NAME}/${IRONFOX_NAME}/" "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html"

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    echo_green_text 'SUCCESS: Prepared Gecko'
}

# Prepare Glean
function prep_glean() {
    echo_red_text 'Preparing Glean...'

    if [[ -f "${IRONFOX_GLEAN}/local.properties" ]]; then
        rm -f "${IRONFOX_GLEAN}/local.properties"
    fi
    cp -f "${IRONFOX_TEMPLATES}/glean/local.properties" "${IRONFOX_GLEAN}/local.properties"
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

# Prepare Phoenix
function prep_phoenix() {
    echo_red_text 'Preparing Phoenix...'
    mkdir -p "${IRONFOX_BUILD}/tmp/phoenix"

    if [[ -f "${IRONFOX_BUILD}/tmp/phoenix/phoenix-overrides-parsed.cfg" ]]; then
        rm -f "${IRONFOX_BUILD}/tmp/phoenix/phoenix-overrides-parsed.cfg"
    fi

    cp -f "${IRONFOX_TEMPLATES}/phoenix/phoenix-overrides.cfg" "${IRONFOX_BUILD}/tmp/phoenix/phoenix-overrides-parsed.cfg"
    "${IRONFOX_SED}" -i "s|{IRONFOX_CHANNEL}|${IRONFOX_CHANNEL}|" "${IRONFOX_BUILD}/tmp/phoenix/phoenix-overrides-parsed.cfg"
    "${IRONFOX_SED}" -i "s|{IRONFOX_VERSION}|${IRONFOX_VERSION}|" "${IRONFOX_BUILD}/tmp/phoenix/phoenix-overrides-parsed.cfg"

    # Ensure our cfg file doesn't already exist in mozilla-central
    if [[ -f "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg" ]]; then
        rm -f "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg"
    fi

    # Ensure our policies file doesn't already exist in mozilla-central
    if [[ -f "${IRONFOX_GECKO}/ironfox/prefs/policies.json" ]]; then
        rm -f "${IRONFOX_GECKO}/ironfox/prefs/policies.json"
    fi

    echo_green_text 'SUCCESS: Prepared Phoenix'
}

# Prepare UnifiedPush-AC
function prep_up_ac() {
    echo_red_text 'Preparing UnifiedPush-AC...'

    if [[ -f "${IRONFOX_UP_AC}/local.properties" ]]; then
        rm -f "${IRONFOX_UP_AC}/local.properties"
    fi
    cp -f "${IRONFOX_TEMPLATES}/unifiedpush-ac/local.properties" "${IRONFOX_UP_AC}/local.properties"

    # Substitute our local versions of Android Components and Application Services
    "${IRONFOX_SED}" -i "s|{IF_LOCAL_AC_VERSION}|${IF_LOCAL_AC_VERSION}|" "${IRONFOX_UP_AC}/local.properties"
    "${IRONFOX_SED}" -i "s|{IF_LOCAL_AS_VERSION}|${IF_LOCAL_AS_VERSION}|" "${IRONFOX_UP_AC}/local.properties"

    echo_green_text 'SUCCESS: Prepared UnifiedPush-AC'
}

# Prepare LLVM
function prep_llvm() {
    echo_red_text 'Preparing LLVM...'

    # Set LLVM build targets
    if [[ -f "${IRONFOX_BUILD}/targets_to_build" ]]; then
        rm -f "${IRONFOX_BUILD}/targets_to_build"
    fi
    cp -f "${IRONFOX_TEMPLATES}/llvm/targets_to_build_${IRONFOX_TARGET_ARCH}" "${IRONFOX_BUILD}/targets_to_build"

    echo_green_text 'SUCCESS: Prepared LLVM'
}

# Bundletool
function build_bundletool() {
    echo_red_text 'Building Bundletool...'

    pushd "${IRONFOX_BUNDLETOOL_DIR}"
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JAVA_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JAVA_HOME} assemble
    popd

    cp -f "${IRONFOX_BUNDLETOOL_DIR}/build/libs/bundletool.jar" "${IRONFOX_BUNDLETOOL_JAR}"

    echo_green_text 'SUCCESS: Built Bundletool'
}

# LLVM
function build_llvm() {
    echo_red_text 'Building LLVM...'

    pushd "${llvm}"
    local readonly llvmtarget=$(cat "${IRONFOX_BUILD}/targets_to_build")
    echo_green_text "building llvm for ${llvmtarget}"
    cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=out -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="$llvmtarget" \
        -DLLVM_USE_LINKER=lld -DLLVM_BINUTILS_INCDIR=/usr/include -DLLVM_ENABLE_PLUGINS=FORCE_ON \
        -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
    cmake --build build -j"$(nproc)"
    cmake --build build --target install -j"$(nproc)"
    popd

    echo_green_text 'SUCCESS: Built LLVM'
}

# Phoenix
function build_phoenix() {
    echo_red_text 'Building Phoenix...'

    pushd "${IRONFOX_PHOENIX}"
    bash -x "${IRONFOX_PHOENIX}/scripts/build.sh"
    popd

    # Copy our outputs to mozilla-central
    cp "${IRONFOX_PHOENIX}/outputs/android/phoenix.cfg" "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg"
    cp "${IRONFOX_PHOENIX}/outputs/android/policies.json" "${IRONFOX_GECKO}/ironfox/prefs/policies.json"

    echo_green_text 'SUCCESS: Built Phoenix'
}

# Build our prebuilt libraries from source
function build_prebuilds() {
    echo_red_text 'Building prebuilt libraries...'

    pushd "${IRONFOX_PREBUILDS}"
    bash -x "${IRONFOX_PREBUILDS}/scripts/build.sh"
    popd

    echo_green_text 'SUCCESS: Built prebuilt libraries'
}

# microG
function build_microg() {
    echo_red_text 'Building microG...'

    pushd "${IRONFOX_GMSCORE}"
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_21_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JAVA_HOME} -x javaDocReleaseGeneration \
        :play-services-base:publishToMavenLocal \
        :play-services-basement:publishToMavenLocal \
        :play-services-fido:publishToMavenLocal \
        :play-services-tasks:publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built microG'
}

# Glean
function build_glean() {
    echo_red_text 'Building Glean...'

    pushd "${IRONFOX_GLEAN}"
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_17_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JDK_17_HOME} -Plocal=${IF_LOCAL_GLEAN_VERSION_GRADLE} :glean-native:publishToMavenLocal
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_17_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JDK_17_HOME} -Plocal=${IF_LOCAL_GLEAN_VERSION_GRADLE} publishToMavenLocal -x createGleanPythonVirtualEnv
    popd

    echo_green_text 'SUCCESS: Built Glean'
}

# Application Services
function build_as() {
    echo_red_text 'Building Application Services...'

    # First, clean our environment
    ## (The presence of CI prevents building libraries from `libs/verify-ci-android-environment.sh`)
    unset CI
    unset JAVA_HOME

    pushd "${IRONFOX_AS}"
    export JAVA_HOME="${IRONFOX_JDK_17_HOME}"
    bash -x "${IRONFOX_AS}/libs/verify-android-environment.sh"
    unset JAVA_HOME
    export JAVA_HOME="${IRONFOX_JAVA_HOME}"

    # Build Application Services
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_17_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JDK_17_HOME} -Plocal=${IF_LOCAL_AS_VERSION_GRADLE} publish
    popd

    echo_green_text 'SUCCESS: Built Application Services'
}

# nimbus-fml
function build_nimbus_fml() {
    echo_red_text 'Building nimbus-fml...'
    pushd "${IRONFOX_AS}/components/support/nimbus-fml"
    "${IRONFOX_CARGO}" build --release
    popd
    echo_green_text 'SUCCESS: Built nimbus-fml'
}

# GeckoView
function _build_geckoview() {
    if [[ -z "${1+x}" ]]; then
        echo_red_text 'ERROR: Please specify a target architecture!'
        exit 1
    fi

    local readonly target_arch="$1"

    # Ensure we have a valid architecture (+ set pretty architecture...)
    case "${target_arch}" in
    arm64)
        local readonly pretty_arch='ARM64'
        ;;
    arm)
        local readonly pretty_arch='ARM'
        ;;
    x86_64)
        local readonly pretty_arch='x86_64'
        ;;
    bundle)
        local readonly pretty_arch='Universal'
        ;;
    *)
        echo_red_text "ERROR: Invalid target architecture: ${target_arch}"
        exit 1
        ;;
    esac

    # First, clean our environment
    unset IRONFOX_MACH_GECKOVIEW_CREATE_AAR
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT
    unset MOZ_AUTOMATION
    unset MOZ_CHROME_MULTILOCALE

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${target_arch}"

    # So, at this point, we either need to publish GeckoView (GV) to our local Maven repo, or create an AAR archive
    # We *typically* just publish GV to our local Maven repo, but we INSTEAD create an AAR archive if:
    # 1. Our current target does NOT match our final target
    # OR:
    # 2. We're in CI and our final target is NOT `bundle`
    # (For reference, the final target is `IRONFOX_TARGET_ARCH`, and the current target is `target_arch`)
    local publish_gv_to_maven_local=1
    if [[ "${target_arch}" != "${IRONFOX_TARGET_ARCH}" ]]; then
        local publish_gv_to_maven_local=0
    elif [[ "${IRONFOX_CI}" == 1 ]] && [[ "${target_arch}" != 'bundle' ]]; then
        local publish_gv_to_maven_local=0
    fi
    local readonly publish_gv_to_maven_local

    # Tell Mach whether we need to create an AAR archive
    if [[ "${publish_gv_to_maven_local}" == 0 ]]; then
        export IRONFOX_MACH_GECKOVIEW_CREATE_AAR=1
    else
        export IRONFOX_MACH_GECKOVIEW_CREATE_AAR=0
    fi

    # Ensure we remove any existing Mach environment cache
    # (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"
    
    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='geckoview'

    # For multi-locale builds
    export MOZ_CHROME_MULTILOCALE="${IRONFOX_LOCALES}"

    pushd "${IRONFOX_GECKO}"

    # Build GeckoView
    echo_red_text "Building GeckoView (${pretty_arch})..."
    "${IRONFOX_MACH}" configure

    if [[ "${publish_gv_to_maven_local}" == 1 ]]; then
        # Publish GeckoView to our local Maven repo
        "${IRONFOX_MACH}" gradle :geckoview:publishReleasePublicationToMavenLocal
    else
        # Create our AAR archives
        "${IRONFOX_MACH}" gradle :machConfigure
        MOZ_AUTOMATION=1 "${IRONFOX_MACH}" android archive-geckoview
        unset MOZ_AUTOMATION

        if [[ "${target_arch}" == 'arm64' ]]; then
            local readonly aar_output="${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64}"
        elif [[ "${target_arch}" == 'arm' ]]; then
            local readonly aar_output="${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM}"
        elif [[ "${target_arch}" == 'x86_64' ]]; then
            local readonly aar_output="${IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64}"
        fi

        # Create our AAR output directory
        mkdir -p $(dirname "${aar_output}")

        cp -vf "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${target_arch}/gradle/target.maven.zip" "${aar_output}"
    fi

    echo_green_text "SUCCESS: Built GeckoView (${pretty_arch})"
    popd
}

function build_geckoview() {
    # ARM64
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        _build_geckoview 'arm64'
    fi

    # ARM
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        _build_geckoview 'arm'
    fi

    # x86_64
    if [[ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        _build_geckoview 'x86_64'
    fi

    # Bundle (Universal)
    if [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        # First, we need to produce our fat AAR
        ## That process re-uses a lot of the same logic as `_build_gecko`, hence we re-use it
        _build_gecko 'bundle'

        _build_geckoview 'bundle'
    fi
}

# Gecko
function _build_gecko() {
    if [[ -z "${1+x}" ]]; then
        echo_red_text 'ERROR: Please specify a target architecture!'
        exit 1
    fi

    local readonly target_arch="$1"

    # Ensure we have a valid architecture (+ set pretty architecture...)
    case "${target_arch}" in
    arm64)
        local readonly pretty_arch='ARM64'
        ;;
    arm)
        local readonly pretty_arch='ARM'
        ;;
    x86_64)
        local readonly pretty_arch='x86_64'
        ;;
    bundle)
        local readonly pretty_arch='Universal'
        ;;
    *)
        echo_red_text "ERROR: Invalid target architecture: ${target_arch}"
        exit 1
        ;;
    esac

    # First, clean our environment
    ## (MOZ_CHROME_MULTILOCALE will cause a build failure if set...)
    unset IRONFOX_MACH_GECKO_STAGE
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT
    unset MOZ_ANDROID_FAT_AAR_ARCHITECTURES
    unset MOZ_ANDROID_FAT_AAR_ARM64_V8A
    unset MOZ_ANDROID_FAT_AAR_ARMEABI_V7A
    unset MOZ_ANDROID_FAT_AAR_X86_64
    unset MOZ_CHROME_MULTILOCALE

    # If we're producing a bundle, we need to prepare to assemble our fat AAR
    if [[ "${target_arch}" == 'bundle' ]]; then
        # Verify that our ARM64 GeckoView AAR archive exists
        if [[ ! -f "${IRONFOX_GECKOVIEW_AAR_ARM64}" ]]; then
            echo_red_text "ERROR: ARM64 GeckoView AAR archive not found! (${IRONFOX_GECKOVIEW_AAR_ARM64})"
            exit 1
        fi

        # Verify that our ARM64 GeckoView AAR archive is not an empty file
        if [[ ! -s "${IRONFOX_GECKOVIEW_AAR_ARM64}" ]]; then
            echo_red_text "ERROR: ARM64 GeckoView AAR archive is empty! (${IRONFOX_GECKOVIEW_AAR_ARM64})"
            exit 1
        fi

        # Verify that our ARM GeckoView AAR archive exists
        if [[ ! -f "${IRONFOX_GECKOVIEW_AAR_ARM}" ]]; then
            echo_red_text "ERROR: ARM GeckoView AAR archive not found! (${IRONFOX_GECKOVIEW_AAR_ARM})"
            exit 1
        fi

        # Verify that our ARM GeckoView AAR archive is not an empty file
        if [[ ! -s "${IRONFOX_GECKOVIEW_AAR_ARM}" ]]; then
            echo_red_text "ERROR: ARM GeckoView AAR archive is empty! (${IRONFOX_GECKOVIEW_AAR_ARM})"
            exit 1
        fi

        # Verify that our x86_64 GeckoView AAR archive exists
        if [[ ! -f "${IRONFOX_GECKOVIEW_AAR_X86_64}" ]]; then
            echo_red_text "ERROR: x86_64 GeckoView AAR archive not found! (${IRONFOX_GECKOVIEW_AAR_X86_64})"
            exit 1
        fi

        # Verify that our x86_64 GeckoView AAR archive is not an empty file
        if [[ ! -s "${IRONFOX_GECKOVIEW_AAR_X86_64}" ]]; then
            echo_red_text "ERROR: x86_64 GeckoView AAR archive is empty! (${IRONFOX_GECKOVIEW_AAR_X86_64})"
            exit 1
        fi

        readonly MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
        readonly MOZ_ANDROID_FAT_AAR_ARM64_V8A="${IRONFOX_GECKOVIEW_AAR_ARM64}"
        readonly MOZ_ANDROID_FAT_AAR_ARMEABI_V7A="${IRONFOX_GECKOVIEW_AAR_ARM}"
        readonly MOZ_ANDROID_FAT_AAR_X86_64="${IRONFOX_GECKOVIEW_AAR_X86_64}"
        export MOZ_ANDROID_FAT_AAR_ARCHITECTURES
        export MOZ_ANDROID_FAT_AAR_ARM64_V8A
        export MOZ_ANDROID_FAT_AAR_ARMEABI_V7A
        export MOZ_ANDROID_FAT_AAR_X86_64
    fi

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${target_arch}"

    # Determine if we should package Gecko
    # (This should only run if our current target matches our final target OR if we're in CI and our final target is `bundle`)
    local package_gecko=1
    if [[ "${target_arch}" != "${IRONFOX_TARGET_ARCH}" ]]; then
        local package_gecko=0
    elif [[ "${IRONFOX_CI}" == 1 ]] && [[ "${IRONFOX_TARGET_ARCH}" != 'bundle' ]]; then
        local package_gecko=0
    fi
    local readonly package_gecko

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='gecko'

    pushd "${IRONFOX_GECKO}"

    # Build Gecko
    echo_red_text "Building Gecko (${pretty_arch})..."
    export IRONFOX_MACH_GECKO_STAGE='build'
    "${IRONFOX_MACH}" configure
    "${IRONFOX_MACH}" build
    echo_green_text "SUCCESS: Built Gecko (${pretty_arch})"

    # Package Gecko
    if [[ "${package_gecko}" == 1 ]]; then
        echo_red_text "Packaging Gecko (${pretty_arch})..."
        export IRONFOX_MACH_GECKO_STAGE='package'

        if [[ "${target_arch}" != 'bundle' ]]; then
            # If we're building a bundle, no need to re-run mach configure here (since Mach is always set to package for Bundle builds)
            "${IRONFOX_MACH}" configure
        fi

        "${IRONFOX_MACH}" package-multi-locale --locales ${IRONFOX_LOCALES}
        echo_green_text "SUCCESS: Packaged Gecko (${pretty_arch})"
    fi
    popd
}

function build_gecko() {
    # ARM64
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        _build_gecko 'arm64'
    fi

    # ARM
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        _build_gecko 'arm'
    fi

    # x86_64
    if [[ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        _build_gecko 'x86_64'
    fi
}

# Android Components (Core)
function build_ac_core() {
    echo_red_text 'Building Android Components (Core)...'

    # First, clean our environment
    ## (The presence of CI causes build failures, due to us removing MARS and friends)
    unset CI
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT

    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='ac-core'

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${IRONFOX_TARGET_ARCH}"

    pushd "${IRONFOX_GECKO}"

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    # Configure Mach
    "${IRONFOX_MACH}" configure

    # Build concept-fetch, concept-base (dependency of support-base), support-base and ui-icons
    ## (Needed by UnifiedPush-AC)
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components :components:concept-fetch:publishToMavenLocal
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components :components:concept-base:publishToMavenLocal
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components :components:support-base:publishToMavenLocal
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components :components:ui-icons:publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built Android Components (Core)'
}

# UnifiedPush-AC
function build_up_ac() {
    echo_red_text 'Building UnifiedPush-AC...'

    pushd "${IRONFOX_UP_AC}"
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_17_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JDK_17_HOME} publish
    popd

    echo_green_text 'SUCCESS: Built UnifiedPush-AC'
}

# Android Components
function build_ac() {
    echo_red_text 'Building Android Components...'

    # First, clean our environment
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT

    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='android-components'

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${IRONFOX_TARGET_ARCH}"

    pushd "${IRONFOX_GECKO}"

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    # Configure Mach
    "${IRONFOX_MACH}" configure

    # Build Android Components
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built Android Components'
}

function build_fenix() {
    # Fenix
    echo_red_text "Building Fenix (${IRONFOX_TARGET_ARCH})..."

    # First, clean our environment
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT

    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='fenix'

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${IRONFOX_TARGET_ARCH}"

    pushd "${IRONFOX_GECKO}"

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    # Configure Mach
    "${IRONFOX_MACH}" configure

    # Build Fenix
    "${IRONFOX_MACH}" gradle -p mobile/android/fenix assembleRelease

    # 1. Export APK for ARM64
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        if [[ "${IRONFOX_SIGN}" == 1 ]]; then
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM64_UNSIGNED}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-arm64-v8a-release-unsigned.apk" "${IRONFOX_OUTPUTS_ARM64_UNSIGNED}"
        else
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM64}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-arm64-v8a-release.apk" "${IRONFOX_OUTPUTS_ARM64}"
        fi
    fi

    # 2. Export APK for ARM
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        if [[ "${IRONFOX_SIGN}" == 1 ]]; then
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM_UNSIGNED}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-armeabi-v7a-release-unsigned.apk" "${IRONFOX_OUTPUTS_ARM_UNSIGNED}"
        else
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-armeabi-v7a-release.apk" "${IRONFOX_OUTPUTS_ARM}"
        fi
    fi

    # 3. Export APK for x86_64
    if [[ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        if [[ "${IRONFOX_SIGN}" == 1 ]]; then
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_X86_64_UNSIGNED}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-x86_64-release-unsigned.apk" "${IRONFOX_OUTPUTS_X86_64_UNSIGNED}"
        else
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_X86_64}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-x86_64-release.apk" "${IRONFOX_OUTPUTS_X86_64}"
        fi
    fi

    # 4. Export universal APK + build and export our AAB
    if [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        # 4. Export universal APK
        if [[ "${IRONFOX_SIGN}" == 1 ]]; then
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-universal-release-unsigned.apk" "${IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED}"
        else
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_UNIVERSAL}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-universal-release.apk" "${IRONFOX_OUTPUTS_UNIVERSAL}"
        fi

        # 5. Finally, build and export our AAB
        "${IRONFOX_MACH}" gradle -Paab -p mobile/android/fenix bundleRelease

        # Create our output directory
        mkdir -p $(dirname "${IRONFOX_OUTPUTS_BUNDLE_AAB}")

        cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/bundle/release/app-release.aab" "${IRONFOX_OUTPUTS_BUNDLE_AAB}"
    fi
    popd

    echo_green_text "SUCCESS: Built Fenix (${IRONFOX_TARGET_ARCH})"
}

# Prepare build environment...
## (These need to be performed here instead of in `prebuild.sh`, so that we can account for if users decide to
### change the variables, without them needing to re-run the entire prebuild script...)
echo_red_text 'Preparing your build environment...'

# Set-up our build environment
set_build_env

# Prepare mozilla-central
prep_gecko

# Prepare Phoenix
prep_phoenix

# Prepare LLVM
prep_llvm

if [[ "${IRONFOX_BUILD_GECKOVIEW_ONLY}" != 1 ]]; then
    # Prepare Application Services
    prep_as

    # Prepare Fenix
    prep_fenix

    # Prepare Glean
    prep_glean

    # Prepare UnifiedPush-AC
    prep_up_ac
fi

echo_green_text 'SUCCESS: Prepared build environment'

# Begin the build...
echo_red_text "Building IronFox ${IRONFOX_VERSION}: ${IRONFOX_CHANNEL_PRETTY} (${IRONFOX_TARGET_PRETTY})..."

if [[ -n "${FDROID_BUILD+x}" ]]; then
    # Build LLVM
    build_llvm
fi

if [[ "${IRONFOX_NO_PREBUILDS}" == 1 ]]; then
    # Build uniffi-bindgen + WASI SDK
    build_prebuilds
    if [[ "${IRONFOX_BUILD_GECKOVIEW_ONLY}" != 1 ]]; then
        # Build Bundletool
        build_bundletool
    fi
fi

# Build microG
build_microg

# Build Phoenix
build_phoenix

# Build Gecko
build_gecko

# Build GeckoView
build_geckoview

if [[ "${IRONFOX_BUILD_GECKOVIEW_ONLY}" != 1 ]]; then
    # Ensure MOZ_CHROME_MULTILOCALE is always set at this point
    if [[ -z "${MOZ_CHROME_MULTILOCALE+x}" ]]; then
        MOZ_CHROME_MULTILOCALE="${IRONFOX_LOCALES}"
    fi
    readonly MOZ_CHROME_MULTILOCALE
    export MOZ_CHROME_MULTILOCALE

    # If we're building a bundle, ensure MOZ_ANDROID_FAT_AAR_ARCHITECTURES is always set at this point
    if [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]] && [[ -z "${MOZ_ANDROID_FAT_AAR_ARCHITECTURES+x}" ]]; then
        readonly MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
        export MOZ_ANDROID_FAT_AAR_ARCHITECTURES
    fi

    # Build Android Components (Core)
    build_ac_core

    # Build Application Services
    build_as

    # Build UnifiedPush-AC
    build_up_ac

    # Build nimbus-fml
    build_nimbus_fml

    # Build Android Components
    build_ac

    # Build Glean
    build_glean

    # Build Fenix
    build_fenix

    echo_green_text "SUCCESS: Built IronFox ${IRONFOX_VERSION}: ${IRONFOX_CHANNEL_PRETTY} (${IRONFOX_TARGET_PRETTY})"
fi
