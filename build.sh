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

# shellcheck source=paths.sh
source "$(dirname "$0")/paths.sh"

# We publish the artifacts into a local Maven repository instead of using the
# auto-publication workflow because the latter does not work for Gradle
# plugins (Glean).

# Set up Android SDK
sdkmanager 'build-tools;34.0.0' # for GeckoView
sdkmanager 'ndk;25.2.9519653' # for GleanAS

# Set up Rust
# shellcheck disable=SC1090,SC1091
source "$HOME/.cargo/env"
cargo install --force --vers 0.26.0 cbindgen

# Build WASI SDK
pushd "$wasi"
mkdir -p build/install/wasi
touch build/compiler-rt.BUILT # fool the build system
make \
    PREFIX=/wasi \
    build/wasi-libc.BUILT \
    build/libcxx.BUILT \
    -j"$(nproc)"
popd

# Build microG libraries
pushd "$gmscore"
gradle -x javaDocReleaseGeneration \
    :play-services-ads-identifier:publishToMavenLocal \
    :play-services-base:publishToMavenLocal \
    :play-services-basement:publishToMavenLocal \
    :play-services-fido:publishToMavenLocal \
    :play-services-tasks:publishToMavenLocal
popd

pushd "$glean"
export TARGET_CFLAGS=-DNDEBUG
gradle publishToMavenLocal
popd

pushd "$application_services"
export NSS_DIR="$application_services/libs/desktop/linux-x86-64/nss"
export NSS_STATIC=1
./libs/verify-android-environment.sh
gradle :tooling-nimbus-gradle:publishToMavenLocal
popd

pushd "$mozilla_release"
MOZ_CHROME_MULTILOCALE=$(< "$patches/locales")
export MOZ_CHROME_MULTILOCALE
./mach build
gradle :geckoview:publishWithGeckoBinariesReleasePublicationToMavenLocal
gradle :exoplayer2:publishReleasePublicationToMavenLocal
popd

pushd "$android_components"
# Publish concept-fetch (required by A-S) with auto-publication disabled,
# otherwise automatically triggered publication of A-S will fail
gradle :concept-fetch:publishToMavenLocal
# Enable the auto-publication workflow now that concept-fetch is published
echo "autoPublish.application-services.dir=$application_services" >> local.properties
gradle publishToMavenLocal
popd

pushd "$fenix"
gradle assembleRelease
popd
