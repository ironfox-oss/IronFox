#!/bin/bash
#
#    IronFox build scripts
#    Copyright (C) 2024-2025  Akash Yadav, celenity
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

if [ "$build_type" != "apk" ] && [ "$build_type" != "bundle" ]; then
    echo "Unknown build type: '$build_type'" >&1
    echo "Usage: $0 apk|bundle" >&1
    exit 1
fi

if [[ -n ${FDROID_BUILD+x} ]]; then
    source "$(dirname "$0")/env_fdroid.sh"
fi

source "$(dirname $0)/env_local.sh"
source "$CARGO_HOME/env"
source "$PIP_ENV/bin/activate"

# If variables are defined with a custom `env_override.sh`, let's use those
if [[ -f "$(dirname $0)/env_override.sh" ]]; then
    source "$(dirname $0)/env_override.sh"
fi

# We publish the artifacts into a local Maven repository instead of using the
# auto-publication workflow because the latter does not work for Gradle
# plugins (Glean).

if [[ -n ${FDROID_BUILD+x} ]]; then

    # Build LLVM
    pushd "$llvm"

    pushd "$bundletool"
    $gradle assemble
    popd

    llvmtarget=$(cat "$builddir/targets_to_build")
    echo "building llvm for $llvmtarget"
    cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=out -DCMAKE_C_COMPILER=clang-20 \
        -DCMAKE_CXX_COMPILER=clang++-20 -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="$llvmtarget" \
        -DLLVM_USE_LINKER=lld -DLLVM_BINUTILS_INCDIR=/usr/include -DLLVM_ENABLE_PLUGINS=FORCE_ON \
        -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
    cmake --build build -j"$(nproc)"
    cmake --build build --target install -j"$(nproc)"
    popd
fi

if [[ "$NO_PREBUILDS" == "1" ]]; then
    # Build our prebuilds
    pushd "$prebuilds"
    bash "$prebuilds/scripts/build.sh"
    popd
fi

# Build microG libraries
pushd "$gmscore"
export GRADLE_MICROG_VERSION_WITHOUT_GIT=1
$gradle -Dhttps.protocols=TLSv1.3 -Dorg.gradle.configuration-cache=false --no-build-cache --no-configuration-cache -x javaDocReleaseGeneration \
    :play-services-ads-identifier:publishToMavenLocal \
    :play-services-base:publishToMavenLocal \
    :play-services-basement:publishToMavenLocal \
    :play-services-fido:publishToMavenLocal \
    :play-services-tasks:publishToMavenLocal
popd

# Glean
pushd "$glean"
export TARGET_CFLAGS='-DNDEBUG'
$gradle -Dorg.gradle.configuration-cache=false --no-build-cache --no-configuration-cache :glean-native:publishToMavenLocal
$gradle -Dorg.gradle.configuration-cache=false --no-build-cache --no-configuration-cache publishToMavenLocal
popd

# Application Services
pushd "$application_services"

# When 'CI' environment variable is set to a non-zero value, the 'libs/verify-ci-android-environment.sh' script
# skips building the libraries as they are expected to be already downloaded in a CI environment
# However, we want build those libraries always, so we set CI='' before invoking the script
CI='' bash -c "./libs/verify-android-environment.sh && $gradle -Dhttps.protocols=TLSv1.3 -Dorg.gradle.configuration-cache=false --no-build-cache --no-configuration-cache :tooling-nimbus-gradle:publishToMavenLocal"
popd

# Gecko (Firefox)
pushd "$mozilla_release"

echo "Running ./mach build..."
./mach build
echo "Running ./mach package..."
./mach package
echo "Running ./mach package-multi-locale..."
./mach package-multi-locale --locales ${IRONFOX_LOCALES}

export MOZ_CHROME_MULTILOCALE="${IRONFOX_LOCALES}"

echo "Running $gradle -Dorg.gradle.configuration-cache=false -Pofficial --no-build-cache --no-configuration-cache -x javadocRelease :geckoview:publishReleasePublicationToMavenLocal..."
$gradle -Dorg.gradle.configuration-cache=false -Pofficial --no-build-cache --no-configuration-cache -x javadocRelease :geckoview:publishReleasePublicationToMavenLocal
popd

# Android Components
pushd "$android_components"
# Publish concept-fetch (required by A-S) with auto-publication disabled,
# otherwise automatically triggered publication of A-S will fail
$gradle -Dorg.gradle.configuration-cache=false -Pofficial --no-build-cache --no-configuration-cache :components:concept-fetch:publishToMavenLocal
# Enable the auto-publication workflow now that concept-fetch is published
echo "## Enable the auto-publication workflow for Application Services" >>"$mozilla_release/local.properties"
echo "autoPublish.application-services.dir=$application_services" >>"$mozilla_release/local.properties"
$gradle -Dorg.gradle.configuration-cache=false -Pofficial --no-build-cache --no-configuration-cache publishToMavenLocal
popd

# Fenix
pushd "$fenix"
if [[ "$build_type" == "apk" ]]; then
    $gradle -Dorg.gradle.configuration-cache=false -Pofficial --no-build-cache --no-configuration-cache :app:assembleRelease
    if [[ "$IRONFOX_RELEASE" == 1 ]]; then
        cp -v "$mozilla_release/obj/gradle/build/mobile/android/fenix/app/outputs/apk/fenix/release/app-fenix-${target_abi}-release-unsigned.apk" "$builddir/outputs/ironfox-release-${target_abi}-unsigned.apk"
    else
        cp -v "$mozilla_release/obj/gradle/build/mobile/android/fenix/app/outputs/apk/fenix/release/app-fenix-${target_abi}-release-unsigned.apk" "$builddir/outputs/ironfox-nightly-${target_abi}-unsigned.apk"
    fi
elif [[ "$build_type" == "bundle" ]]; then
    $gradle -Dorg.gradle.configuration-cache=false -Pofficial --no-build-cache --no-configuration-cache :app:bundleRelease -Paab
fi
popd
