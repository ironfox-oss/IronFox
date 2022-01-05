#!/bin/bash
#
#    Fennec build scripts
#    Copyright (C) 2020  Matías Zúñiga, Andrew Nayenko
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
JAVA_HOME="$java8" "$ANDROID_HOME/tools/bin/sdkmanager" 'build-tools;30.0.2'
JAVA_HOME="$java8" "$ANDROID_HOME/tools/bin/sdkmanager" 'cmake;3.18.1' # required by WASI SDK

# Set up Rust
"$rustup"/rustup-init.sh -y
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
rustup default 1.56.1
rustup target add thumbv7neon-linux-androideabi
rustup target add armv7-linux-androideabi
rustup target add aarch64-linux-android
cargo install --force --vers 0.20.0 cbindgen

# Set up Python
PYENV_ROOT=$(realpath "$pyenv")
export PATH="$PYENV_ROOT/bin:$PATH"
export PYENV_ROOT
eval "$(pyenv init --path)"
pyenv install 3.9.9
pyenv global 3.9.9

# Build WASI SDK
pushd "$wasi"
mkdir -p build/install/wasi
touch build/compiler-rt.BUILT # fool the build system
make PATH="$ANDROID_HOME/cmake/3.18.1/bin:$PATH" PREFIX=/wasi build -j"$(nproc)"
popd

pushd "$mozilla_release"
export MACH_USE_SYSTEM_PYTHON=yes
./mach build
gradle publishWithGeckoBinariesReleasePublicationToMavenLocal
popd

pushd "$glean_as"
export TARGET_CFLAGS=-DNDEBUG
gradle publishToMavenLocal
popd

pushd "$glean"
gradle publishToMavenLocal
popd

pushd "$android_components_as"
gradle publishToMavenLocal
popd

pushd "$application_services"
export ANDROID_NDK_ROOT="$ANDROID_NDK"
export SQLCIPHER_LIB_DIR="$application_services/libs/desktop/linux-x86-64/sqlcipher/lib"
export SQLCIPHER_INCLUDE_DIR="$application_services/libs/desktop/linux-x86-64/sqlcipher/include"
export NSS_DIR="$application_services/libs/desktop/linux-x86-64/nss"
export NSS_STATIC=1
./libs/verify-android-environment.sh
gradle publishToMavenLocal
popd

pushd "$android_components"
gradle publishToMavenLocal
popd

gradle assembleRelease
