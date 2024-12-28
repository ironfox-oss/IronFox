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

readonly patches=$(dirname "$(realpath "$0")")
readonly android_components=$(realpath ../srclib/MozFennec/mobile/android/android-components)
readonly application_services=$(realpath ../srclib/MozAppServices)
readonly glean=$(realpath ../srclib/MozGlean)
readonly fenix=$(realpath ../srclib/MozFennec/mobile/android/fenix)
readonly mozilla_release=$(realpath ../srclib/MozFennec)
readonly rustup=$(realpath ../srclib/rustup)
readonly wasi=$(realpath ../srclib/wasi-sdk)
readonly gmscore=$(realpath ../srclib/gmscore)
readonly llvm=$(realpath ../srclib/llvm)
readonly llvm_android=$(realpath ../srclib/llvm_android)
readonly toolchain_utils=$(realpath ../srclib/toolchain-utils)
readonly fdroid_build="true"
