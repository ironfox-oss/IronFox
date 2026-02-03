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

# Functions
echo_red_text() {
	echo -e "\033[31m$1\033[0m"
}

echo_green_text() {
	echo -e "\033[32m$1\033[0m"
}

if [ -z "${1+x}" ]; then
    echo_red_text "Usage: $0 apk|bundle" >&1
    exit 1
fi

build_type="$1"

if [ "${build_type}" != "apk" ] && [ "${build_type}" != "bundle" ]; then
    echo_red_text "Unknown build type: '${build_type}'" >&1
    echo_red_text "Usage: $0 apk|bundle" >&1
    exit 1
fi

# Set-up our environment
bash -x $(dirname $0)/env.sh
source $(dirname $0)/env.sh

# Configure our build target
source "${IRONFOX_ENV_TARGET}"

if [[ -n "${FDROID_BUILD+x}" ]]; then
    source "${IRONFOX_ENV_FDROID}"
fi

source "${IRONFOX_CARGO_ENV}"
source "${IRONFOX_PIP_ENV}"

# Include version info
source "${IRONFOX_VERSIONS}"

# Prepare build environment...
## (These need to be performed here instead of in `prebuild.sh`, so that we can account for if users decide to
### change the variables, without them needing to re-run the entire prebuild script...)
echo_green_text "Preparing your build environment..."

## Set environment-specific Gradle properties

### Application Services
if [[ -f "${IRONFOX_AS}/local.properties" ]]; then
    rm -f "${IRONFOX_AS}/local.properties"
fi
cp -f "${IRONFOX_PATCHES}/build/application-services/local.properties" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_AC}|${IRONFOX_AC}|" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN}|${IRONFOX_GLEAN}|" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_AS}/local.properties"

### Fenix
if [[ -f "${IRONFOX_FENIX}/local.properties" ]]; then
    rm -f "${IRONFOX_FENIX}/local.properties"
fi
cp -f "${IRONFOX_PATCHES}/build/fenix/local.properties" "${IRONFOX_FENIX}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_AS}|${IRONFOX_AS}|" "${IRONFOX_FENIX}/local.properties"

### Gecko
if [[ -f "${IRONFOX_GECKO}/local.properties" ]]; then
    rm -f "${IRONFOX_GECKO}/local.properties"
fi
cp -f "${IRONFOX_PATCHES}/build/gecko/local.properties" "${IRONFOX_GECKO}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_AC}|${IRONFOX_AC}|" "${IRONFOX_GECKO}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN}|${IRONFOX_GLEAN}|" "${IRONFOX_GECKO}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_GECKO}|${IRONFOX_GECKO}|" "${IRONFOX_GECKO}/local.properties"

### Glean
if [[ -f "${IRONFOX_GLEAN}/local.properties" ]]; then
    rm -f "${IRONFOX_GLEAN}/local.properties"
fi
cp -f "${IRONFOX_PATCHES}/build/glean/local.properties" "${IRONFOX_GLEAN}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_GLEAN}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_GLEAN}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_GLEAN}/local.properties"

## Set Glean's uniffi-bindgen location
if [[ -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle" ]]; then
    rm -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
fi
cp -f "${IRONFOX_BUILD}/tmp/glean/build.gradle" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
"${IRONFOX_SED}" -i "s|{IRONFOX_UNIFFI}|${IRONFOX_UNIFFI}|" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"

### unifiedpush-ac
if [[ -f "${IRONFOX_UP_AC}/local.properties" ]]; then
    rm -f "${IRONFOX_UP_AC}/local.properties"
fi
cp -f "${IRONFOX_PATCHES}/build/unifiedpush-ac/local.properties" "${IRONFOX_UP_AC}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_AS}|${IRONFOX_AS}|" "${IRONFOX_UP_AC}/local.properties"

## Set LLVM build targets
if [[ -f "${IRONFOX_BUILD}/targets_to_build" ]]; then
    rm -f "${IRONFOX_BUILD}/targets_to_build"
fi
cp -f "${IRONFOX_PATCHES}/build/llvm/targets_to_build_${IRONFOX_TARGET_ARCH}" "${IRONFOX_BUILD}/targets_to_build"

## Set our Gecko prefs
if [[ -f "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg" ]]; then
    rm -f "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg"
fi

cp -f "${IRONFOX_PATCHES}/build/gecko/ironfox.cfg" "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg"
"${IRONFOX_SED}" -i "s|{IRONFOX_VERSION}|${IRONFOX_VERSION}|" "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg"

## Configure release channel

### Fenix
if [[ -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml" ]]; then
    rm -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
fi

cp -f "${IRONFOX_BUILD}/tmp/fenix/shortcuts.xml" "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"

if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
    "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
else
    "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox.nightly"|' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox.nightly/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
fi

# Begin the build...
echo_green_text "Building IronFox ${IRONFOX_VERSION}: ${IRONFOX_CHANNEL_PRETTY} (${IRONFOX_TARGET_PRETTY})"

# We publish the artifacts into a local Maven repository instead of using the
# auto-publication workflow because the latter does not work for Gradle
# plugins (Glean).

if [[ -n "${FDROID_BUILD+x}" ]]; then

    # Build LLVM
    pushd "${llvm}"

    pushd "${IRONFOX_BUNDLETOOL}"
    "${IRONFOX_GRADLE}" assemble
    popd

    llvmtarget=$(cat "${IRONFOX_BUILD}/targets_to_build")
    echo_green_text "building llvm for ${llvmtarget}"
    cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=out -DCMAKE_C_COMPILER=clang-20 \
        -DCMAKE_CXX_COMPILER=clang++-20 -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="$llvmtarget" \
        -DLLVM_USE_LINKER=lld -DLLVM_BINUTILS_INCDIR=/usr/include -DLLVM_ENABLE_PLUGINS=FORCE_ON \
        -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
    cmake --build build -j"$(nproc)"
    cmake --build build --target install -j"$(nproc)"
    popd
fi

if [[ "${IRONFOX_NO_PREBUILDS}" == 1 ]]; then
    # Build our prebuilt libraries from source
    pushd "${IRONFOX_PREBUILDS}"
    bash -x "${IRONFOX_PREBUILDS}/scripts/build.sh"
    popd
fi

# Build microG libraries
pushd "${IRONFOX_GMSCORE}"
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Dhttps.protocols=TLSv1.3 -x javaDocReleaseGeneration \
    :play-services-ads-identifier:publishToMavenLocal \
    :play-services-base:publishToMavenLocal \
    :play-services-basement:publishToMavenLocal \
    :play-services-fido:publishToMavenLocal \
    :play-services-tasks:publishToMavenLocal
popd

# Glean
pushd "${IRONFOX_GLEAN}"
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" :glean-native:publishToMavenLocal
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" publishToMavenLocal
popd

# Application Services
pushd "${IRONFOX_AS}"

# When 'CI' environment variable is set to a non-zero value, the 'libs/verify-ci-android-environment.sh' script
# skips building the libraries as they are expected to be already downloaded in a CI environment
# However, we want build those libraries always, so we set CI='' before invoking the script
CI='' bash -c "./libs/verify-android-environment.sh && ${IRONFOX_GRADLE} ${IRONFOX_GRADLE_FLAGS} :tooling-nimbus-gradle:publishToMavenLocal"
popd

# Gecko (Firefox)
pushd "${IRONFOX_GECKO}"

function build_gecko() {
    unset MOZ_CHROME_MULTILOCALE

    echo_green_text "Running ${IRONFOX_MACH} configure..."
    "${IRONFOX_MACH}" configure
    echo_green_text "Running ${IRONFOX_MACH} clobber..."
    "${IRONFOX_MACH}" clobber
    echo_green_text "Running ${IRONFOX_MACH} build..."
    "${IRONFOX_MACH}" build
    echo_green_text "Running ${IRONFOX_MACH} package..."
    "${IRONFOX_MACH}" package
    echo_green_text "Running ${IRONFOX_MACH} package-multi-locale..."
    "${IRONFOX_MACH}" package-multi-locale --locales ${IRONFOX_GECKO_LOCALES}

    export MOZ_CHROME_MULTILOCALE="${IRONFOX_GECKO_LOCALES}"

    echo_green_text "Running '${IRONFOX_GRADLE}' '${IRONFOX_GRADLE_FLAGS}' -Pofficial -x javadocRelease :geckoview:publishReleasePublicationToMavenLocal..."
    "${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial -x javadocRelease :geckoview:publishReleasePublicationToMavenLocal

    if [ "${IRONFOX_TARGET_ARCH_MOZ}" != "${IRONFOX_TARGET_ARCH_MOZ_BUNDLE}" ]; then
        # Create GeckoView AAR archives
        MOZ_AUTOMATION=1 "${IRONFOX_MACH}" android archive-geckoview
        unset MOZ_AUTOMATION
        if [[ "${IRONFOX_TARGET_ARCH_MOZ}" == 'arm' ]]; then
            cp -vf "${IRONFOX_GV_AAR_ARM}" "${IRONFOX_OUTPUTS_GV_AAR_ARM}"
        elif [[ "${IRONFOX_TARGET_ARCH_MOZ}" == 'arm64' ]]; then
            cp -vf "${IRONFOX_GV_AAR_ARM64}" "${IRONFOX_OUTPUTS_GV_AAR_ARM64}"
        elif [[ "${IRONFOX_TARGET_ARCH_MOZ}" == 'x86_64' ]]; then
            cp -vf "${IRONFOX_GV_AAR_X86_64}" "${IRONFOX_OUTPUTS_GV_AAR_X86_64}"
        fi
    fi
}

if [ "${build_type}" == "bundle" ]; then
    unset IRONFOX_TARGET_ARCH_MOZ

    # Write env_build.sh (for setting build date)
    if [[ -f "${IRONFOX_ENV_BUILD}" ]]; then
        rm "${IRONFOX_ENV_BUILD}"
    fi
    BUILD_DATE="$("${IRONFOX_DATE}" -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo "Writing ${IRONFOX_ENV_BUILD}..."
    cat > "${IRONFOX_ENV_BUILD}" << EOF
    export IF_BUILD_DATE="${BUILD_DATE}"
EOF

    # Set build date (to ensure MOZ_BUILDID is consistent across all builds)
    source "${IRONFOX_ENV_BUILD}"
    export MOZ_BUILD_DATE="$("${IRONFOX_DATE}" -d "${IF_BUILD_DATE}" "+%Y%m%d%H%M%S")"

    # 1. Build ARM64
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_ARM64}"
    build_gecko

    # 2. Build ARM
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_ARM}"
    build_gecko

    # 3. Build x86_64
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_X86_64}"
    build_gecko

    # 4. Finally, build our bundle
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_BUNDLE}"
    export MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
    export MOZ_ANDROID_FAT_AAR_ARM64_V8A="${IRONFOX_OUTPUTS_GV_AAR_ARM64}"
    export MOZ_ANDROID_FAT_AAR_ARMEABI_V7A="${IRONFOX_OUTPUTS_GV_AAR_ARM}"
    export MOZ_ANDROID_FAT_AAR_X86_64="${IRONFOX_OUTPUTS_GV_AAR_X86_64}"
    build_gecko
    "${IRONFOX_MACH}" build android-fat-aar-artifact
else
    build_gecko
fi

popd

# Android Components
pushd "${IRONFOX_AC}"

# Publish concept-fetch (required by A-S) with auto-publication disabled,
# otherwise automatically triggered publication of A-S and publications of unifiedpush-ac will fail
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial :components:concept-fetch:publishToMavenLocal

# unifiedpush-ac also needs concept-base (dependency of support-base), support-base and ui-icons
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial :components:concept-base:publishToMavenLocal
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial :components:support-base:publishToMavenLocal
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial :components:ui-icons:publishToMavenLocal
popd

# unifiedpush-ac
pushd "${IRONFOX_UP_AC}"
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" publishToMavenLocal
popd

# Android Components (Part 2...)
pushd "${IRONFOX_AC}"

# Now, enable the auto-publication workflow
echo "## Enable the auto-publication workflow for Application Services" >>"${IRONFOX_GECKO}/local.properties"
echo "autoPublish.application-services.dir=${IRONFOX_AS}" >>"${IRONFOX_GECKO}/local.properties"

function build_ac() {
    "${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial publishToMavenLocal
}

if [ "${build_type}" == "bundle" ]; then
    unset IRONFOX_TARGET_ARCH_MOZ
    unset MOZ_ANDROID_FAT_AAR_ARCHITECTURES

    # 1. Build ARM64
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_ARM64}"
    build_ac

    # 2. Build ARM
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_ARM}"
    build_ac

    # 3. Build x86_64
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_X86_64}"
    build_ac

    # 4. Finally, build our bundle
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_BUNDLE}"
    export MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
    build_ac
else
    build_ac
fi

popd

# Fenix
pushd "${IRONFOX_FENIX}"

function build_fenix() {
    "${IRONFOX_MACH}" configure
    "${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial :app:assembleRelease

    if [ "${build_type}" != "bundle" ]; then
        cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH_MOZ}/gradle/build/mobile/android/fenix/app/outputs/apk/fenix/release/app-fenix-${IRONFOX_TARGET_ABI}-release-unsigned.apk" "${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ABI}-unsigned.apk"
    fi
}

function set_abi() {
    if [[ -f "${IRONFOX_FENIX}/app/build.gradle" ]]; then
        rm -f "${IRONFOX_FENIX}/app/build.gradle"
    fi

    cp -f "${IRONFOX_BUILD}/tmp/fenix/build.gradle" "${IRONFOX_FENIX}/app/build.gradle"

    "${IRONFOX_SED}" -i -e "s/include \".*\"/include \"${IRONFOX_TARGET_ABI}\"/" "${IRONFOX_FENIX}/app/build.gradle"

    if [ "${build_type}" != "bundle" ]; then
        # Universal APKs make no sense under other circumstances, as we're only building the specific target architecture
        # We only build all architectures for bundle builds
        "${IRONFOX_SED}" -i -e '/universalApk/s/true/false/' "${IRONFOX_FENIX}/app/build.gradle"
    fi
}

if [[ "${build_type}" == "bundle" ]]; then
    unset IRONFOX_TARGET_ABI
    unset IRONFOX_TARGET_ARCH_MOZ
    unset MOZ_ANDROID_FAT_AAR_ARCHITECTURES

    # 1. Build ARM64
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_ARM64}"
    export IRONFOX_TARGET_ABI="${IRONFOX_TARGET_ABI_ARM64}"
    set_abi
    build_fenix

    # 2. Build ARM
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_ARM}"
    export IRONFOX_TARGET_ABI="${IRONFOX_TARGET_ABI_ARM}"
    set_abi
    build_fenix

    # 3. Build x86_64
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_X86_64}"
    export IRONFOX_TARGET_ABI="${IRONFOX_TARGET_ABI_X86_64}"
    set_abi
    build_fenix

    # 4. Finally, build our bundle
    export MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
    export IRONFOX_TARGET_ABI="${IRONFOX_TARGET_ABI_BUNDLE}"
    export IRONFOX_TARGET_ARCH_MOZ="${IRONFOX_TARGET_ARCH_MOZ_BUNDLE}"
    set_abi
    build_fenix
    "${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial :app:bundleRelease -Paab

    # Copy AAB output
    cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/bundle/fenixRelease/app-fenix-release.aab" "${IRONFOX_OUTPUTS_AAB}/ironfox-${IRONFOX_CHANNEL}.aab"

    # Copy universal APK
    cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-bundle/gradle/build/mobile/android/fenix/app/outputs/apk/fenix/release/app-fenix-universal-release-unsigned.apk" "${IRONFOX_OUTPUTS_APK}/ironfox-${IRONFOX_CHANNEL}-universal-unsigned.apk"
else
    build_fenix
fi

popd
