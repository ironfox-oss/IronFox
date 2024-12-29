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

export FDROID_SRCLIB="../../srclib"

export android_components=$(realpath $FDROID_SRCLIB/MozFennec/mobile/android/android-components)
export application_services=$(realpath $FDROID_SRCLIB/MozAppServices)
export glean=$(realpath $FDROID_SRCLIB/MozGlean)
export fenix=$(realpath $FDROID_SRCLIB/MozFennec/mobile/android/fenix)
export mozilla_release=$(realpath $FDROID_SRCLIB/MozFennec)
export rustup=$(realpath $FDROID_SRCLIB/rustup)
export wasi=$(realpath $FDROID_SRCLIB/wasi-sdk)
export gmscore=$(realpath $FDROID_SRCLIB/gmscore)
export llvm=$(realpath $FDROID_SRCLIB/llvm)
export llvm_android=$(realpath $FDROID_SRCLIB/llvm_android)
export toolchain_utils=$(realpath $FDROID_SRCLIB/toolchain-utils)

export paths_source="true"