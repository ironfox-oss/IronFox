#!/bin/bash
#
#    Fennec build scripts
#    Copyright (C) 2020-2024  Andrew Nayenko, Tavi
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

export rootdir=$(dirname $(dirname "$(realpath "$0")"))
export builddir="$rootdir/build"
export patches="$rootdir/patches"

export FDROID_SRCLIB=$(realpath "$rootdir/../srclib")

export android_components="$FDROID_SRCLIB/MozFennec/mobile/android/android-components"
export application_services="$FDROID_SRCLIB/MozAppServices"
export glean="$FDROID_SRCLIB/MozGlean"
export fenix="$FDROID_SRCLIB/MozFennec/mobile/android/fenix"
export mozilla_release="$FDROID_SRCLIB/MozFennec"
export rustup="$FDROID_SRCLIB/rustup"
export wasi="$FDROID_SRCLIB/wasi-sdk"
export gmscore="$FDROID_SRCLIB/gmscore"
export llvm="$FDROID_SRCLIB/llvm"
export llvm_android="$FDROID_SRCLIB/llvm_android"
export toolchain_utils="$FDROID_SRCLIB/toolchain-utils"

export paths_source="true"
