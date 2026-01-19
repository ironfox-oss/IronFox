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

if [ -z "$1" ]; then
    echo "Usage: $0 apk|bundle" >&1
    exit 1
fi

set -eo pipefail

build_type="$1"

if [ "${build_type}" != "apk" ] && [ "${build_type}" != "bundle" ]; then
    echo "Unknown build type: '${build_type}'" >&1
    echo "Usage: $0 apk|bundle" >&1
    exit 1
fi

if [[ -n "${FDROID_BUILD+x}" ]]; then
    source "$(dirname "$0")/env_fdroid.sh"
fi

source "$(dirname $0)/env_local.sh"
source "${IRONFOX_CARGO_HOME}/env"
source "${IRONFOX_PIP_ENV}/bin/activate"

# Include version info
source "${rootdir}/scripts/versions.sh"

# If variables are defined with a custom `env_override.sh`, let's use those
if [[ -f "${rootdir}/env_override.sh" ]]; then
    source "${rootdir}/env_override.sh"
fi

# Prepare build environment...
## (These need to be performed here instead of in `prebuild.sh`, so that we can account for if users decide to
### change the variables, without them needing to re-run the entire prebuild script...)

## Set environment-specific Gradle properties

### Application Services
if [[ -f "${IRONFOX_AS}/local.properties" ]]; then
    rm -f "${IRONFOX_AS}/local.properties"
fi
cp -f "${patches}/build/application-services/local.properties" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_AC}|${IRONFOX_AC}|" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN}|${IRONFOX_GLEAN}|" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_AS}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_AS}/local.properties"

### Fenix
if [[ -f "${IRONFOX_FENIX}/local.properties" ]]; then
    rm -f "${IRONFOX_FENIX}/local.properties"
fi
cp -f "${patches}/build/fenix/local.properties" "${IRONFOX_FENIX}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_AS}|${IRONFOX_AS}|" "${IRONFOX_FENIX}/local.properties"

### Gecko
if [[ -f "${IRONFOX_GECKO}/local.properties" ]]; then
    rm -f "${IRONFOX_GECKO}/local.properties"
fi
cp -f "${patches}/build/gecko/local.properties" "${IRONFOX_GECKO}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_AC}|${IRONFOX_AC}|" "${IRONFOX_GECKO}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_GLEAN}|${IRONFOX_GLEAN}|" "${IRONFOX_GECKO}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_GECKO}|${IRONFOX_GECKO}|" "${IRONFOX_GECKO}/local.properties"

### Glean
if [[ -f "${IRONFOX_GLEAN}/local.properties" ]]; then
    rm -f "${IRONFOX_GLEAN}/local.properties"
fi
cp -f "${patches}/build/glean/local.properties" "${IRONFOX_GLEAN}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_GLEAN}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_GLEAN}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_GLEAN}/local.properties"

## Set Glean's uniffi-bindgen location
if [[ -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle" ]]; then
    rm -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
fi
cp -f "${builddir}/tmp/glean/build.gradle" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
"${IRONFOX_SED}" -i "s|{IRONFOX_UNIFFI}|${IRONFOX_UNIFFI}|" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"

### unifiedpush-ac
if [[ -f "${IRONFOX_UP_AC}/local.properties" ]]; then
    rm -f "${IRONFOX_UP_AC}/local.properties"
fi
cp -f "${patches}/build/unifiedpush-ac/local.properties" "${IRONFOX_UP_AC}/local.properties"
"${IRONFOX_SED}" -i "s|{IRONFOX_AS}|${IRONFOX_AS}|" "${IRONFOX_UP_AC}/local.properties"

## Set LLVM build targets
if [[ -f "${builddir}/targets_to_build" ]]; then
    rm -f "${builddir}/targets_to_build"
fi
cp -f "${patches}/build/llvm/targets_to_build_${IRONFOX_TARGET_ARCH}" "${builddir}/targets_to_build"

## Configure release channel

### Fenix
if [[ -f "${IRONFOX_FENIX}/app/build.gradle" ]]; then
    rm -f "${IRONFOX_FENIX}/app/build.gradle"
fi

cp -f "${builddir}/tmp/fenix/build.gradle" "${IRONFOX_FENIX}/app/build.gradle"

if [[ -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml" ]]; then
    rm -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
fi

cp -f "${builddir}/tmp/fenix/shortcuts.xml" "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"

if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
    "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
else
    "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox.nightly"|' "${IRONFOX_FENIX}/app/build.gradle"
    "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox.nightly/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
fi

# Begin the build...

# We publish the artifacts into a local Maven repository instead of using the
# auto-publication workflow because the latter does not work for Gradle
# plugins (Glean).

if [[ -n "${FDROID_BUILD+x}" ]]; then

    # Build LLVM
    pushd "${llvm}"

    pushd "${IRONFOX_BUNDLETOOL_DIR}"
    "${IRONFOX_GRADLE}" assemble
    popd

    llvmtarget=$(cat "${builddir}/targets_to_build")
    echo "building llvm for ${llvmtarget}"
    cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=out -DCMAKE_C_COMPILER=clang-20 \
        -DCMAKE_CXX_COMPILER=clang++-20 -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="$llvmtarget" \
        -DLLVM_USE_LINKER=lld -DLLVM_BINUTILS_INCDIR=/usr/include -DLLVM_ENABLE_PLUGINS=FORCE_ON \
        -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
    cmake --build build -j"$(nproc)"
    cmake --build build --target install -j"$(nproc)"
    popd
fi

if [[ "${NO_PREBUILDS}" == 1 ]]; then
    # Build our prebuilds
    pushd "${IRONFOX_PREBUILDS}"
    bash "${IRONFOX_PREBUILDS}/scripts/build.sh"
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

echo "Running ./mach build..."
./mach build
echo "Running ./mach package..."
./mach package
echo "Running ./mach package-multi-locale..."
./mach package-multi-locale --locales ${IRONFOX_GECKO_LOCALES}

export MOZ_CHROME_MULTILOCALE="${IRONFOX_GECKO_LOCALES}"

echo "Running '${IRONFOX_GRADLE}' '${IRONFOX_GRADLE_FLAGS}' -Pofficial -x javadocRelease :geckoview:publishReleasePublicationToMavenLocal..."
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial -x javadocRelease :geckoview:publishReleasePublicationToMavenLocal
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
"${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial publishToMavenLocal
popd

# Fenix
pushd "${IRONFOX_FENIX}"
if [[ "${build_type}" == "apk" ]]; then
    "${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial :app:assembleRelease
    cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/fenix/release/app-fenix-${IRONFOX_TARGET_ABI}-release-unsigned.apk" "${IRONFOX_OUTPUTS}/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}-unsigned.apk"
elif [[ "${build_type}" == "bundle" ]]; then
    "${IRONFOX_GRADLE}" "${IRONFOX_GRADLE_FLAGS}" -Pofficial :app:bundleRelease -Paab
fi
popd
