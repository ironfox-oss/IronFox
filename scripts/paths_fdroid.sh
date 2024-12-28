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
export patches="$rootdir/patches"
export android_components=$(realpath ../srclib/MozFennec/mobile/android/android-components)
export application_services=$(realpath ../srclib/MozAppServices)
export glean=$(realpath ../srclib/MozGlean)
export fenix=$(realpath ../srclib/MozFennec/mobile/android/fenix)
export mozilla_release=$(realpath ../srclib/MozFennec)
export rustup=$(realpath ../srclib/rustup)
export wasi=$(realpath ../srclib/wasi-sdk)
export gmscore=$(realpath ../srclib/gmscore)
export llvm=$(realpath ../srclib/llvm)
export llvm_android=$(realpath ../srclib/llvm_android)
export toolchain_utils=$(realpath ../srclib/toolchain-utils)
export fdroid_build="true"
export paths_source="true"
