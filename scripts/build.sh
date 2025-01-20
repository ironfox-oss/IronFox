#!/bin/bash
#
#    Fennec build scripts
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

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 apk|bundle" >&1
    exit 1
fi

build_type="$1"

if [ "$build_type" != "apk" ] && [ "$build_type" != "bundle" ]; then
    echo "Unknown build type: '$build_type'" >&1
    echo "Usage: $0 apk|bundle" >&1
    exit 1
fi

if [[ -n "${FDROID_BUILD:-}" ]]; then
    source "$(dirname "$0")/env_fdroid.sh"
fi

# shellcheck disable=SC2154
if [[ "$env_source" != "true" ]]; then
    echo "Use 'source scripts/env_local.sh' before calling prebuild or build"
    exit 1
fi

source "$HOME/.cargo/env"

# We publish the artifacts into a local Maven repository instead of using the
# auto-publication workflow because the latter does not work for Gradle
# plugins (Glean).

if [[ -n "${FDROID_BUILD:-}" ]]; then
    # Build LLVM
    # shellcheck disable=SC2154
    pushd "$llvm"

    # shellcheck disable=SC2154
    llvmtarget=$(cat "$builddir/targets_to_build")
    echo "building llvm for $llvmtarget"
    cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=out -DCMAKE_C_COMPILER=clang-16 \
        -DCMAKE_CXX_COMPILER=clang++-16 -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="$llvmtarget" \
        -DLLVM_USE_LINKER=lld -DLLVM_BINUTILS_INCDIR=/usr/include -DLLVM_ENABLE_PLUGINS=FORCE_ON \
        -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
    cmake --build build -j"$(nproc)"
    cmake --build build --target install -j"$(nproc)"
    popd
fi

if [[ -n "${FDROID_BUILD:-}" ]]; then
    # Build WASI SDK
    # shellcheck disable=SC2154
    pushd "$wasi"

    mkdir -p build/install/wasi
    touch build/compiler-rt.BUILT # fool the build system
    make \
        PREFIX=/wasi \
        build/wasi-libc.BUILT \
        build/libcxx.BUILT \
        -j"$(nproc)"
    popd
fi

# Build microG libraries
# shellcheck disable=SC2154
pushd "$gmscore"
if [[ -z "${FDROID_BUILD:-}" ]]; then
    export GRADLE_MICROG_VERSION_WITHOUT_GIT=1
fi
gradle -x javaDocReleaseGeneration \
    :play-services-ads-identifier:publishToMavenLocal \
    :play-services-base:publishToMavenLocal \
    :play-services-basement:publishToMavenLocal \
    :play-services-fido:publishToMavenLocal \
    :play-services-tasks:publishToMavenLocal
popd

# shellcheck disable=SC2154
pushd "$glean"
export TARGET_CFLAGS=-DNDEBUG
gradle publishToMavenLocal
popd

# shellcheck disable=SC2154
pushd "$application_services"

# When 'CI' environment variable is set to a non-zero value, the 'libs/verify-ci-android-environment.sh' script
# skips building the libraries as they are expected to be already downloaded in a CI environment
# However, we want build those libraries always, so we set CI='' before invoking the script
CI='' bash -c './libs/verify-android-environment.sh && gradle :tooling-nimbus-gradle:publishToMavenLocal'
popd

# shellcheck disable=SC2154
pushd "$mozilla_release"

./mach build
gradle :geckoview:publishReleasePublicationToMavenLocal
gradle :exoplayer2:publishReleasePublicationToMavenLocal
popd

# shellcheck disable=SC2154
pushd "$android_components"
# Publish concept-fetch (required by A-S) with auto-publication disabled,
# otherwise automatically triggered publication of A-S will fail
gradle :concept-fetch:publishToMavenLocal
# Enable the auto-publication workflow now that concept-fetch is published
echo "autoPublish.application-services.dir=$application_services" >>local.properties
gradle publishToMavenLocal
popd

# shellcheck disable=SC2154
pushd "$fenix"
if [[ "$build_type" == "apk" ]]; then
    gradle :app:assembleRelease
elif [[ "$build_type" == "bundle" ]]; then
    gradle :app:bundleRelease -Paab
fi
popd