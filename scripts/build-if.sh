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

# Set-up our environment
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

if [[ -z "${IRONFOX_FROM_BUILD+x}" ]]; then
    echo_red_text 'ERROR: Do not call build-if.sh directly. Instead, use build.sh.' >&1
    exit 1
fi

if [[ ! -f "${IRONFOX_BUILD}/finished-prebuild" ]]; then
    echo_red_text 'ERROR: Do not run build.sh until after you have ran prebuild.sh.'
    exit 1
fi

# Set-up target parameters
readonly build_arch="$1"
readonly build_project="$2"

case "${build_arch}" in
arm64)
    # arm64-v8a
    readonly IRONFOX_TARGET_ARCH='arm64'
    readonly IRONFOX_TARGET_ABI='arm64-v8a'
    readonly IRONFOX_TARGET_PRETTY='ARM64'
    readonly IRONFOX_TARGET_RUST='arm64'
    ;;
arm)
    # armeabi-v7a
    readonly IRONFOX_TARGET_ARCH='arm'
    readonly IRONFOX_TARGET_ABI='armeabi-v7a'
    readonly IRONFOX_TARGET_PRETTY='ARM'
    readonly IRONFOX_TARGET_RUST='arm'
    ;;
x86_64)
    # x86_64
    readonly IRONFOX_TARGET_ARCH='x86_64'
    readonly IRONFOX_TARGET_ABI='x86_64'
    readonly IRONFOX_TARGET_PRETTY='x86_64'
    readonly IRONFOX_TARGET_RUST='x86_64'
    ;;
bundle)
    # arm64-v8a, armeabi-v7a, and x86_64
    readonly IRONFOX_TARGET_ARCH='bundle'
    readonly IRONFOX_TARGET_ABI='arm64-v8a", "armeabi-v7a", "x86_64'
    readonly IRONFOX_TARGET_PRETTY='Bundle'
    readonly IRONFOX_TARGET_RUST='arm64,arm,x86_64'
    ;;
*)
    echo_red_text "Unknown build variant: '$1'" >&2
    exit 1
    ;;
esac
export IRONFOX_TARGET_ARCH
export IRONFOX_TARGET_ABI
export IRONFOX_TARGET_PRETTY

# Handle project-specific arguments
IRONFOX_BUILD_AC_CORE=0
IRONFOX_BUILD_AC_CORE_CONSUMERS=0
IRONFOX_BUILD_AC=0
IRONFOX_BUILD_AC_CONSUMERS=0
IRONFOX_BUILD_AC_DEPS=0
IRONFOX_BUILD_AS=0
IRONFOX_BUILD_AS_CONSUMERS=0
IRONFOX_BUILD_AS_DEPS=0
IRONFOX_BUILD_BUNDLETOOL=0
IRONFOX_BUILD_FENIX=0
IRONFOX_BUILD_FENIX_DEPS=0
IRONFOX_BUILD_GECKO=0
IRONFOX_BUILD_GECKO_CONSUMERS=0
IRONFOX_BUILD_GECKO_DEPS=0
IRONFOX_BUILD_GECKOVIEW=0
IRONFOX_BUILD_GECKOVIEW_CONSUMERS=0
IRONFOX_BUILD_GECKOVIEW_DEPS=0
IRONFOX_BUILD_GLEAN=0
IRONFOX_BUILD_GLEAN_CONSUMERS=0
IRONFOX_BUILD_GLEAN_DEPS=0
IRONFOX_BUILD_LLVM=0
IRONFOX_BUILD_LLVM_CONSUMERS=0
IRONFOX_BUILD_MICROG=0
IRONFOX_BUILD_MICROG_CONSUMERS=0
IRONFOX_BUILD_NIMBUS_FML=0
IRONFOX_BUILD_NIMBUS_FML_CONSUMERS=0
IRONFOX_BUILD_PHOENIX=0
IRONFOX_BUILD_PHOENIX_CONSUMERS=0
IRONFOX_BUILD_UNIFFI=0
IRONFOX_BUILD_UNIFFI_CONSUMERS=0
IRONFOX_BUILD_UP_AC=0
IRONFOX_BUILD_UP_AC_CONSUMERS=0
IRONFOX_BUILD_UP_AC_DEPS=0
IRONFOX_BUILD_WASI=0
IRONFOX_BUILD_WASI_CONSUMERS=0

if [[ "${build_project}" == 'fenix' ]]; then
    # Build Fenix (and its dependencies)
    ## (This is the default, and likely desired behavior in most cases)
    IRONFOX_BUILD_FENIX=1
    IRONFOX_BUILD_FENIX_DEPS=1
elif [[ "${build_project}" == 'ac-core' ]]; then
    # *Only* build core Android Components
    IRONFOX_BUILD_AC_CORE=1
elif [[ "${build_project}" == 'ac' ]]; then
    # *Only* build Android Components (and their dependencies)
    IRONFOX_BUILD_AC=1
    IRONFOX_BUILD_AC_DEPS=1
elif [[ "${build_project}" == 'as' ]]; then
    # *Only* build Application Services (and its dependencies)
    IRONFOX_BUILD_AS=1
    IRONFOX_BUILD_AS_DEPS=1
elif [[ "${build_project}" == 'bundletool' ]]; then
    # *Only* build Bundletool
    IRONFOX_BUILD_BUNDLETOOL=1
elif [[ "${build_project}" == 'gecko' ]]; then
    # *Only* build Gecko (and its dependencies)
    IRONFOX_BUILD_GECKO=1
    IRONFOX_BUILD_GECKO_DEPS=1
elif [[ "${build_project}" == 'geckoview' ]]; then
    # *Only* build GeckoView (and its dependencies)
    ## (ex. used by CI for building GeckoView AARs)
    IRONFOX_BUILD_GECKOVIEW=1
    IRONFOX_BUILD_GECKOVIEW_DEPS=1
elif [[ "${build_project}" == 'glean' ]]; then
    # *Only* build Glean (and its dependencies)
    IRONFOX_BUILD_GLEAN=1
    IRONFOX_BUILD_GLEAN_DEPS=1
elif [[ "${build_project}" == 'llvm' ]]; then
    # *Only* build LLVM
    IRONFOX_BUILD_LLVM=1
elif [[ "${build_project}" == 'microg' ]]; then
    # *Only* build microG
    IRONFOX_BUILD_MICROG=1
elif [[ "${build_project}" == 'nimbus-fml' ]]; then
    # *Only* build nimbus-fml
    IRONFOX_BUILD_NIMBUS_FML=1
elif [[ "${build_project}" == 'phoenix' ]]; then
    # *Only* build Phoenix
    IRONFOX_BUILD_PHOENIX=1
elif [[ "${build_project}" == 'uniffi' ]]; then
    # *Only* build uniffi-bindgen
    IRONFOX_BUILD_UNIFFI=1
elif [[ "${build_project}" == 'up-ac' ]]; then
    # *Only* build UnifiedPush-AC (and its dependencies)
    IRONFOX_BUILD_UP_AC=1
    IRONFOX_BUILD_UP_AC_DEPS=1
elif [[ "${build_project}" == 'wasi' ]]; then
    # *Only* build WASI SDK
    IRONFOX_BUILD_ONLY_WASI=1
elif [[ "${build_project}" == 'rebuild-ac-core' ]]; then
    # Build core Android Components and their consumers
    IRONFOX_BUILD_AC_CORE=1
    IRONFOX_BUILD_AC_CORE_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-ac' ]]; then
    # Build Android Components and their consumers
    IRONFOX_BUILD_AC=1
    IRONFOX_BUILD_AC_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-as' ]]; then
    # Build Application Services and their consumers
    IRONFOX_BUILD_AS=1
    IRONFOX_BUILD_AS_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-fenix' ]]; then
    # *Only* build Fenix
    IRONFOX_BUILD_FENIX=1
elif [[ "${build_project}" == 'rebuild-gecko' ]]; then
    # Build Gecko and its consumers
    IRONFOX_BUILD_GECKO=1
    IRONFOX_BUILD_GECKO_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-geckoview' ]]; then
    # Build GeckoView and its consumers
    IRONFOX_BUILD_GECKOVIEW=1
    IRONFOX_BUILD_GECKOVIEW_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-glean' ]]; then
    # Build Glean and its consumers
    IRONFOX_BUILD_GLEAN=1
    IRONFOX_BUILD_GLEAN_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-llvm' ]]; then
    # Build LLVM and its consumers
    IRONFOX_BUILD_LLVM=1
    IRONFOX_BUILD_LLVM_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-microg' ]]; then
    # Build microG and its consumers
    IRONFOX_BUILD_MICROG=1
    IRONFOX_BUILD_MICROG_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-nimbus-fml' ]]; then
    # Build nimbus-fml and its consumers
    IRONFOX_BUILD_NIMBUS_FML=1
    IRONFOX_BUILD_NIMBUS_FML_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-phoenix' ]]; then
    # Build Phoenix and its consumers
    IRONFOX_BUILD_PHOENIX=1
    IRONFOX_BUILD_PHOENIX_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-uniffi' ]]; then
    # Build uniffi-bindgen and its consumers
    IRONFOX_BUILD_UNIFFI=1
    IRONFOX_BUILD_UNIFFI_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-up-ac' ]]; then
    # Build UnifiedPush-AC and its consumers
    IRONFOX_BUILD_UP_AC=1
    IRONFOX_BUILD_UP_AC_CONSUMERS=1
elif [[ "${build_project}" == 'rebuild-wasi' ]]; then
    # Build WASI SDK and its consumers
    IRONFOX_BUILD_WASI=1
    IRONFOX_BUILD_WASI_CONSUMERS=1
else
    echo_red_text "ERROR: Invalid target project: ${build_project}\n You must enter one of the following:"
    echo 'Fenix:                                fenix (Default)'
    echo 'Android Components (Core):            ac-core'
    echo 'Android Components:                   ac'
    echo 'Application Services:                 as'
    echo 'Bundletool:                           bundletool'
    echo 'Gecko:                                gecko'
    echo 'GeckoView:                            geckoview'
    echo 'Glean:                                glean'
    echo 'LLVM:                                 llvm'
    echo 'microG:                               microg'
    echo 'nimbus-fml:                           nimbus-fml'
    echo 'Phoenix:                              phoenix'
    echo 'uniffi-bindgen:                       uniffi'
    echo 'UnifiedPush-AC:                       up-ac'
    echo 'WASI SDK:                             wasi'
    echo 'Rebuild - Android Components (Core):  rebuild-ac-core'
    echo 'Rebuild - Android Components:         rebuild-ac'
    echo 'Rebuild - Application Services:       rebuild-as'
    echo 'Rebuild - Fenix:                      rebuild-fenix'
    echo 'Rebuild - Gecko:                      rebuild-gecko'
    echo 'Rebuild - GeckoView:                  rebuild-geckoview'
    echo 'Rebuild - Glean:                      rebuild-glean'
    echo 'Rebuild - LLVM:                       rebuild-llvm'
    echo 'Rebuild - microG:                     rebuild-microg'
    echo 'Rebuild - nimbus-fml:                 rebuild-nimbus-fml'
    echo 'Rebuild - Phoenix:                    rebuild-phoenix'
    echo 'Rebuild - uniffi:                     rebuild-uniffi'
    echo 'Rebuild - UnifiedPush-AC:             rebuild-up-ac'
    echo 'Rebuild - WASI SDK:                   rebuild-wasi'
    echo_green_text "TIP: If you're not sure, you *probably* want to stick to the default (fenix)."
    exit 1
fi

# Build projects that consume LLVM, microG, Phoenix, or WASI SDK directly
if [[ "${IRONFOX_BUILD_LLVM_CONSUMERS}" == 1 ]] || [[ "${IRONFOX_BUILD_MICROG_CONSUMERS}" == 1 ]] ||
 [[ "${IRONFOX_BUILD_PHOENIX_CONSUMERS}" == 1 ]] || [[ "${IRONFOX_BUILD_WASI_CONSUMERS}" == 1 ]]; then
    # Build Gecko and its consumers
    IRONFOX_BUILD_GECKO=1
    IRONFOX_BUILD_GECKO_CONSUMERS=1
fi

# Build projects that consume Gecko directly
if [[ "${IRONFOX_BUILD_GECKO_CONSUMERS}" == 1 ]]; then
    # Build GeckoView and its consumers
    IRONFOX_BUILD_GECKOVIEW=1
    IRONFOX_BUILD_GECKOVIEW_CONSUMERS=1
fi

# Build projects that consume Android Components (Core) directly
if [[ "${IRONFOX_BUILD_AC_CORE_CONSUMERS}" == 1 ]]; then
    # Build Application Services and its consumers
    IRONFOX_BUILD_AS=1
    IRONFOX_BUILD_AS_CONSUMERS=1

    # Build UnifiedPush-AC and its consumers
    IRONFOX_BUILD_UP_AC=1
    IRONFOX_BUILD_UP_AC_CONSUMERS=1
fi

# Build projects that consume Android Components (Core) or Application Services directly
if [[ "${IRONFOX_BUILD_AC_CORE_CONSUMERS}" == 1 ]] || [[ "${IRONFOX_BUILD_AS_CONSUMERS}" == 1 ]]; then
    # Build UnifiedPush-AC and its consumers
    IRONFOX_BUILD_UP_AC=1
    IRONFOX_BUILD_UP_AC_CONSUMERS=1
fi

# Build projects that consume Application Services, GeckoView, nimbus-fml, or UnifiedPush-AC directly
if [[ "${IRONFOX_BUILD_AS_CONSUMERS}" == 1 ]] || [[ "${IRONFOX_BUILD_GECKOVIEW_CONSUMERS}" == 1 ]] ||
 [[ "${IRONFOX_BUILD_NIMBUS_FML_CONSUMERS}" == 1 ]] || [[ "${IRONFOX_BUILD_UP_AC_CONSUMERS}" == 1 ]]; then
    # Build Android Components and its consumers
    IRONFOX_BUILD_AC=1
    IRONFOX_BUILD_AC_CONSUMERS=1
fi

# Build projects that consume uniffi-bindgen directly
if [[ "${IRONFOX_BUILD_UNIFFI_CONSUMERS}" == 1 ]]; then
    # Build Glean and its consumers
    IRONFOX_BUILD_GLEAN=1
    IRONFOX_BUILD_GLEAN_CONSUMERS=1
fi

# Build projects that consume Android Components, Glean, nimbus-fml, or UnifiedPush-AC directly
if [[ "${IRONFOX_BUILD_AC_CONSUMERS}" == 1 ]] || [[ "${IRONFOX_BUILD_GLEAN_CONSUMERS}" == 1 ]] ||
 [[ "${IRONFOX_BUILD_NIMBUS_FML_CONSUMERS}" == 1 ]] || [[ "${IRONFOX_BUILD_UP_AC_CONSUMERS}" == 1 ]]; then
    # Build Fenix
    IRONFOX_BUILD_FENIX=1
fi

# Build direct dependencies of Fenix
if [[ "${IRONFOX_BUILD_FENIX_DEPS}" == 1 ]]; then
    # Android Components
    IRONFOX_BUILD_AC=1
    IRONFOX_BUILD_AC_DEPS=1

    # Glean
    IRONFOX_BUILD_GLEAN=1

    # nimbus-fml
    IRONFOX_BUILD_NIMBUS_FML=1

    # UnifiedPush-AC
    IRONFOX_BUILD_UP_AC=1
    IRONFOX_BUILD_UP_AC_DEPS=1

    if [[ "${IRONFOX_NO_PREBUILDS}" == 1 ]]; then
        # Bundletool
        IRONFOX_BUILD_BUNDLETOOL=1
    fi
fi

# Build direct dependencies of Glean
if [[ "${IRONFOX_BUILD_GLEAN_DEPS}" == 1 ]]; then
    if [[ "${IRONFOX_NO_PREBUILDS}" == 1 ]]; then
        # uniffi-bindgen
        IRONFOX_BUILD_UNIFFI=1
    fi
fi

# Build direct dependencies of Android Components
if [[ "${IRONFOX_BUILD_AC_DEPS}" == 1 ]]; then
    # Application Services
    IRONFOX_BUILD_AS=1

    # GeckoView
    IRONFOX_BUILD_GECKOVIEW=1
    IRONFOX_BUILD_GECKOVIEW_DEPS=1

    # nimbus-fml
    IRONFOX_BUILD_NIMBUS_FML=1

    # UnifiedPush-AC
    IRONFOX_BUILD_UP_AC=1
    IRONFOX_BUILD_UP_AC_DEPS=1
fi

# Build direct dependencies of UnifiedPush-AC
if [[ "${IRONFOX_BUILD_UP_AC_DEPS}" == 1 ]]; then
    # Android Components (Core)
    IRONFOX_BUILD_AC_CORE=1

    # Application Services
    IRONFOX_BUILD_AS=1
fi

# Build direct dependencies of Application Services
if [[ "${IRONFOX_BUILD_AS_DEPS}" == 1 ]]; then
    # Android Components (Core)
    IRONFOX_BUILD_AC_CORE=1
fi

# Build direct dependencies of GeckoView
if [[ "${IRONFOX_BUILD_GECKOVIEW_DEPS}" == 1 ]]; then
    # Gecko
    IRONFOX_BUILD_GECKO=1
    IRONFOX_BUILD_GECKO_DEPS=1

    # microG
    IRONFOX_BUILD_MICROG=1
fi

# Build direct dependencies of Gecko
if [[ "${IRONFOX_BUILD_GECKO_DEPS}" == 1 ]]; then
    # microG
    IRONFOX_BUILD_MICROG=1

    # Phoenix
    IRONFOX_BUILD_PHOENIX=1

    if [[ "${IRONFOX_NO_PREBUILDS}" == 1 ]]; then
        # WASI SDK
        IRONFOX_BUILD_WASI=1

        if [[ -n "${FDROID_BUILD+x}" ]]; then
            # LLVM
            IRONFOX_BUILD_LLVM=1
        fi
    fi
fi

readonly IRONFOX_BUILD_AC_CORE
readonly IRONFOX_BUILD_AC_CORE_CONSUMERS
readonly IRONFOX_BUILD_AC
readonly IRONFOX_BUILD_AC_CONSUMERS
readonly IRONFOX_BUILD_AC_DEPS
readonly IRONFOX_BUILD_AS
readonly IRONFOX_BUILD_AS_CONSUMERS
readonly IRONFOX_BUILD_AS_DEPS
readonly IRONFOX_BUILD_BUNDLETOOL
readonly IRONFOX_BUILD_FENIX
readonly IRONFOX_BUILD_FENIX_DEPS
readonly IRONFOX_BUILD_GECKO
readonly IRONFOX_BUILD_GECKO_CONSUMERS
readonly IRONFOX_BUILD_GECKO_DEPS
readonly IRONFOX_BUILD_GECKOVIEW
readonly IRONFOX_BUILD_GECKOVIEW_CONSUMERS
readonly IRONFOX_BUILD_GECKOVIEW_DEPS
readonly IRONFOX_BUILD_GLEAN
readonly IRONFOX_BUILD_GLEAN_CONSUMERS
readonly IRONFOX_BUILD_GLEAN_DEPS
readonly IRONFOX_BUILD_LLVM
readonly IRONFOX_BUILD_LLVM_CONSUMERS
readonly IRONFOX_BUILD_MICROG
readonly IRONFOX_BUILD_MICROG_CONSUMERS
readonly IRONFOX_BUILD_NIMBUS_FML
readonly IRONFOX_BUILD_NIMBUS_FML_CONSUMERS
readonly IRONFOX_BUILD_PHOENIX
readonly IRONFOX_BUILD_PHOENIX_CONSUMERS
readonly IRONFOX_BUILD_UNIFFI
readonly IRONFOX_BUILD_UNIFFI_CONSUMERS
readonly IRONFOX_BUILD_UP_AC
readonly IRONFOX_BUILD_UP_AC_CONSUMERS
readonly IRONFOX_BUILD_UP_AC_DEPS
readonly IRONFOX_BUILD_WASI
readonly IRONFOX_BUILD_WASI_CONSUMERS

# Ensure that critical variables are configured properly
if [[ -z "${IRONFOX_CHANNEL+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_CHANNEL is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ "${IRONFOX_CHANNEL}" != 'release' ]] && [[ "${IRONFOX_CHANNEL}" != 'nightly' ]]; then
    echo_red_text "ERROR: Release channel (${IRONFOX_CHANNEL}) is invalid!"
    echo "Please ensure that IRONFOX_CHANNEL is set to 'release' or 'nightly'."
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${IRONFOX_CHANNEL_PRETTY+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_CHANNEL_PRETTY is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ "${IRONFOX_CHANNEL_PRETTY}" != 'Release' ]] && [[ "${IRONFOX_CHANNEL_PRETTY}" != 'Nightly' ]]; then
    echo_red_text "ERROR: Pretty release channel (${IRONFOX_CHANNEL_PRETTY}) is invalid!"
    echo "Please ensure that IRONFOX_CHANNEL_PRETTY is set to 'Release' or 'Nightly'."
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${IRONFOX_RELEASE+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_RELEASE is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ "${IRONFOX_RELEASE}" != 1 ]] && [[ "${IRONFOX_RELEASE}" != 0 ]]; then
    echo_red_text "ERROR: IRONFOX_RELEASE (${IRONFOX_RELEASE}) is invalid!"
    echo "Please ensure that IRONFOX_RELEASE is set to 1 (for release) or 0 (for nightly)."
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${IRONFOX_NAME+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_NAME is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ "${IRONFOX_NAME}" != 'IronFox' ]] && [[ "${IRONFOX_NAME}" != 'IronFox Nightly' ]]; then
    echo_red_text "ERROR: IRONFOX_NAME (${IRONFOX_NAME}) is invalid!"
    echo "Please ensure that IRONFOX_NAME is set to 'IronFox' or 'IronFox Nightly'."
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${IRONFOX_BUILD+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_BUILD is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_BUILD}" ]]; then
    echo_red_text "ERROR: Build directory (${IRONFOX_BUILD}) is missing!"
    echo 'Please ensure that IRONFOX_BUILD is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${IRONFOX_TEMP+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_TEMP is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_TEMP}" ]]; then
    echo_red_text "ERROR: Temporary directory (${IRONFOX_TEMP}) is missing!"
    echo 'Please ensure that IRONFOX_TEMP is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${IRONFOX_TEMPLATES+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_TEMPLATES is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_TEMPLATES}" ]]; then
    echo_red_text "ERROR: Templates directory (${IRONFOX_TEMPLATES}) is missing!"
    echo 'Please ensure that IRONFOX_TEMPLATES is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

# Fail early if our source directories are missing...

# mozilla-central
if [[ "${IRONFOX_BUILD_GECKO}" == 1 ]] || [[ "${IRONFOX_BUILD_GECKOVIEW}" == 1 ]] || [[ "${IRONFOX_BUILD_AC_CORE}" == 1 ]] ||
 [[ "${IRONFOX_BUILD_AC}" == 1 ]] || [[ "${IRONFOX_BUILD_FENIX}" == 1 ]]; then
    if [[ -z "${IRONFOX_GECKO+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_GECKO is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_GECKO}" ]]; then
        echo_red_text "ERROR: mozilla-central (${IRONFOX_GECKO}) is missing!"
        echo 'Please ensure that IRONFOX_GECKO is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi

    if [[ -z "${IRONFOX_MOZCONFIGS+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_MOZCONFIGS is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_MOZCONFIGS}" ]]; then
        echo_red_text "ERROR: The IronFox mozconfigs directory (${IRONFOX_MOZCONFIGS}) is missing!"
        echo 'Please ensure that IRONFOX_MOZCONFIGS is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Android Components
if [[ "${IRONFOX_BUILD_AC_CORE}" == 1 ]] || [[ "${IRONFOX_BUILD_AC}" == 1 ]]; then
    if [[ -z "${IRONFOX_AC+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_AC is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_AC}" ]]; then
        echo_red_text "ERROR: Android Components (${IRONFOX_AC}) is missing!"
        echo 'Please ensure that IRONFOX_AC is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Fenix
if [[ "${IRONFOX_BUILD_FENIX}" == 1 ]]; then
    if [[ -z "${IRONFOX_FENIX+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_FENIX is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_FENIX}" ]]; then
        echo_red_text "ERROR: Fenix (${IRONFOX_FENIX}) is missing!"
        echo 'Please ensure that IRONFOX_FENIX is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# l10n-central
if [[ "${IRONFOX_BUILD_GECKO}" == 1 ]]; then
    # CI only needs l10n-central if we're producing a bundle...
    if [[ "${IRONFOX_CI}" == 1 ]] && [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        if [[ -z "${IRONFOX_L10N_CENTRAL+x}" ]]; then
            echo_red_text 'ERROR: IRONFOX_L10N_CENTRAL is missing!'
            echo_red_text 'Aborting...'
            exit 1
        fi
        if [[ ! -d "${IRONFOX_L10N_CENTRAL}" ]]; then
            echo_red_text "ERROR: l10n-central (${IRONFOX_L10N_CENTRAL}) is missing!"
            echo 'Please ensure that IRONFOX_L10N_CENTRAL is set to a valid directory.'
            echo_red_text 'Aborting...'
            exit 1
        fi
    fi
fi

# microG
if [[ "${IRONFOX_BUILD_MICROG}" == 1 ]]; then
    if [[ -z "${IRONFOX_GMSCORE+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_GMSCORE is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_GMSCORE}" ]]; then
        echo_red_text "ERROR: microG (${IRONFOX_GMSCORE}) is missing!"
        echo 'Please ensure that IRONFOX_GMSCORE is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Phoenix
if [[ "${IRONFOX_BUILD_PHOENIX}" == 1 ]]; then
    if [[ -z "${IRONFOX_PHOENIX+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_PHOENIX is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_PHOENIX}" ]]; then
        echo_red_text "ERROR: Phoenix (${IRONFOX_PHOENIX}) is missing!"
        echo 'Please ensure that IRONFOX_PHOENIX is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Application Services
if [[ "${IRONFOX_BUILD_AS}" == 1 ]] || [[ "${IRONFOX_BUILD_NIMBUS_FML}" == 1 ]]; then
    if [[ -z "${IRONFOX_AS+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_AS is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_AS}" ]]; then
        echo_red_text "ERROR: Application Services (${IRONFOX_AS}) is missing!"
        echo 'Please ensure that IRONFOX_AS is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# UnifiedPush-AC
if [[ "${IRONFOX_BUILD_UP_AC}" == 1 ]]; then
    if [[ -z "${IRONFOX_UP_AC+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_UP_AC is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_UP_AC}" ]]; then
        echo_red_text "ERROR: UnifiedPush-AC (${IRONFOX_UP_AC}) is missing!"
        echo 'Please ensure that IRONFOX_UP_AC is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Glean
if [[ "${IRONFOX_BUILD_GLEAN}" == 1 ]]; then
    if [[ -z "${IRONFOX_GLEAN+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_GLEAN is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_GLEAN}" ]]; then
        echo_red_text "ERROR: Glean (${IRONFOX_GLEAN}) is missing!"
        echo 'Please ensure that IRONFOX_GLEAN is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Prebuilds repo
if [[ "${IRONFOX_BUILD_UNIFFI}" == 1 ]] || [[ "${IRONFOX_BUILD_WASI}" == 1 ]]; then
    if [[ -z "${IRONFOX_PREBUILDS+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_PREBUILDS is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_PREBUILDS}" ]]; then
        echo_red_text "ERROR: The IronFox prebuilds repository (${IRONFOX_PREBUILDS}) is missing!"
        echo 'Please ensure that IRONFOX_PREBUILDS is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Bundletool
if [[ "${IRONFOX_BUILD_BUNDLETOOL}" == 1 ]]; then
    if [[ -z "${IRONFOX_BUNDLETOOL_DIR+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_BUNDLETOOL_DIR is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_BUNDLETOOL_DIR}" ]]; then
        echo_red_text "ERROR: Bundletool (${IRONFOX_BUNDLETOOL_DIR}) is missing!"
        echo 'Please ensure that IRONFOX_BUNDLETOOL_DIR is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ -z "${IRONFOX_BUNDLETOOL_JAR+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_BUNDLETOOL_JAR is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Now, fail early if our build dependencies are missing...

# Android NDK
if [[ -z "${IRONFOX_ANDROID_NDK+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_ANDROID_NDK is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_ANDROID_NDK}" ]]; then
    echo_red_text "ERROR: Android NDK (${IRONFOX_ANDROID_NDK}) is missing!"
    echo 'Please ensure that IRONFOX_ANDROID_NDK is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

# Android SDK
if [[ -z "${IRONFOX_ANDROID_SDK+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_ANDROID_SDK is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_ANDROID_SDK}" ]]; then
    echo_red_text "ERROR: Android SDK (${IRONFOX_ANDROID_SDK}) is missing!"
    echo 'Please ensure that IRONFOX_ANDROID_SDK is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

# Android SDK Build Tools
if [[ -z "${IRONFOX_ANDROID_SDK_BUILD_TOOLS+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_ANDROID_SDK_BUILD_TOOLS is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_ANDROID_SDK_BUILD_TOOLS}" ]]; then
    echo_red_text "ERROR: Android SDK Build Tools (${IRONFOX_ANDROID_SDK_BUILD_TOOLS}) is missing!"
    echo 'Please ensure that IRONFOX_ANDROID_SDK_BUILD_TOOLS is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

# Android SDK Platform Tools
if [[ -z "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_ANDROID_SDK_PLATFORM_TOOLS is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}" ]]; then
    echo_red_text "ERROR: Android SDK Platform Tools (${IRONFOX_ANDROID_SDK_PLATFORM_TOOLS}) is missing!"
    echo 'Please ensure that IRONFOX_ANDROID_SDK_PLATFORM_TOOLS is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

# GNU awk
if [[ -z "${IRONFOX_AWK+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_AWK is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi

# GNU date
if [[ -z "${IRONFOX_DATE+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_DATE is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi

# GNU sed
if [[ -z "${IRONFOX_SED+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_SED is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi

# Gradle
if [[ -z "${IRONFOX_GRADLE+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_GRADLE is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ -z "${IRONFOX_GRADLE_PY+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_GRADLE_PY is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ -z "${IRONFOX_GRADLE_FLAGS+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_GRADLE_FLAGS is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_GRADLE}" ]]; then
    echo_red_text "ERROR: Gradle (${IRONFOX_GRADLE}) is missing!"
    echo 'Please ensure that IRONFOX_GRADLE is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_GRADLE}" ]]; then
    echo_red_text "ERROR: Gradle (${IRONFOX_GRADLE}) is empty!"
    echo 'Please ensure that IRONFOX_GRADLE is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -x "${IRONFOX_GRADLE}" ]]; then
    echo_red_text "ERROR: Gradle (${IRONFOX_GRADLE}) is not executable!"
    echo 'Please ensure that IRONFOX_GRADLE is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_GRADLE_PY}" ]]; then
    echo_red_text "ERROR: Gradle (${IRONFOX_GRADLE_PY}) is missing!"
    echo 'Please ensure that IRONFOX_GRADLE_PY is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_GRADLE_PY}" ]]; then
    echo_red_text "ERROR: Gradle (${IRONFOX_GRADLE_PY}) is empty!"
    echo 'Please ensure that IRONFOX_GRADLE_PY is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

# Java
if [[ -z "${IRONFOX_JAVA_HOME+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_JAVA_HOME is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ -z "${IRONFOX_JAVA+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_JAVA is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_JAVA_HOME}" ]]; then
    echo_red_text "ERROR: JDK (${IRONFOX_JAVA_HOME}) is missing!"
    echo 'Please ensure that IRONFOX_JAVA_HOME is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_JAVA}" ]]; then
    echo_red_text "ERROR: Java (${IRONFOX_JAVA}) is missing!"
    echo 'Please ensure that IRONFOX_JAVA is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_JAVA}" ]]; then
    echo_red_text "ERROR: Java (${IRONFOX_JAVA}) is empty!"
    echo 'Please ensure that IRONFOX_JAVA is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -x "${IRONFOX_JAVA}" ]]; then
    echo_red_text "ERROR: Java (${IRONFOX_JAVA}) is not executable!"
    echo 'Please ensure that IRONFOX_JAVA is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

## Java 21
if [[ -z "${IRONFOX_JDK_21_HOME+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_JDK_21_HOME is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_JDK_21_HOME}" ]]; then
    echo_red_text "ERROR: JDK 21 (${IRONFOX_JDK_21_HOME}) is missing!"
    echo 'Please ensure that IRONFOX_JDK_21_HOME is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

## Java 17
if [[ -z "${IRONFOX_JDK_17_HOME+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_JDK_17_HOME is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_JDK_17_HOME}" ]]; then
    echo_red_text "ERROR: JDK 17 (${IRONFOX_JDK_17_HOME}) is missing!"
    echo 'Please ensure that IRONFOX_JDK_17_HOME is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

readonly JAVA_VER=$("${IRONFOX_JAVA}" -version 2>&1 | "${IRONFOX_AWK}" -F '"' '/version/ {print $2}' | "${IRONFOX_AWK}" -F '.' '{sub("^$", "0", $2); print $1$2}')
[[ "${JAVA_VER}" -ge 15 ]] || {
    echo_red_text "ERROR: Java 17 or newer must be set as the default JDK!"
    echo_red_text 'Aborting...'
    exit 1
}

# Node.js
if [[ -z "${IRONFOX_NODEJS+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_NODEJS is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_NODEJS}" ]]; then
    echo_red_text "ERROR: Node.js (${IRONFOX_NODEJS}) is missing!"
    echo 'Please ensure that IRONFOX_NODEJS is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_NODEJS}" ]]; then
    echo_red_text "ERROR: Node.js (${IRONFOX_NODEJS}) is empty!"
    echo 'Please ensure that IRONFOX_NODEJS is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -x "${IRONFOX_NODEJS}" ]]; then
    echo_red_text "ERROR: Node.js (${IRONFOX_NODEJS}) is not executable!"
    echo 'Please ensure that IRONFOX_NODEJS is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

# npm
if [[ -z "${IRONFOX_NPM+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_NPM is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_NPM}" ]]; then
    echo_red_text "ERROR: npm (${IRONFOX_NPM}) is missing!"
    echo 'Please ensure that IRONFOX_NPM is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_NPM}" ]]; then
    echo_red_text "ERROR: npm (${IRONFOX_NPM}) is empty!"
    echo 'Please ensure that IRONFOX_NPM is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -x "${IRONFOX_NPM}" ]]; then
    echo_red_text "ERROR: npm (${IRONFOX_NPM}) is not executable!"
    echo 'Please ensure that IRONFOX_NPM is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

# nvm
if [[ -z "${IRONFOX_NVM+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_NVM is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ -z "${IRONFOX_NVM_ENV+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_NVM_ENV is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_NVM}" ]]; then
    echo_red_text "ERROR: nvm (${IRONFOX_NVM}) is missing!"
    echo 'Please ensure that IRONFOX_NVM is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_NVM_ENV}" ]]; then
    echo_red_text "ERROR: nvm environment activation file (${IRONFOX_NVM_ENV}) is missing!"
    echo 'Please ensure that IRONFOX_NVM_ENV is set to a valid file.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_NVM_ENV}" ]]; then
    echo_red_text "ERROR: nvm environment activation file (${IRONFOX_NVM_ENV}) is empty!"
    echo 'Please ensure that IRONFOX_NVM_ENV is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

# Python
if [[ -z "${IRONFOX_PYTHON+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_PYTHON is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_PYTHON}" ]]; then
    echo_red_text "ERROR: Python (${IRONFOX_PYTHON}) is missing!"
    echo 'Please ensure that IRONFOX_PYTHON is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_PYTHON}" ]]; then
    echo_red_text "ERROR: Python (${IRONFOX_PYTHON}) is empty!"
    echo 'Please ensure that IRONFOX_PYTHON is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -x "${IRONFOX_PYTHON}" ]]; then
    echo_red_text "ERROR: Python (${IRONFOX_PYTHON}) is not executable!"
    echo 'Please ensure that IRONFOX_PYTHON is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

# Python (uv) environment
if [[ -z "${IRONFOX_PYENV_DIR+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_PYENV_DIR is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ -z "${IRONFOX_PYENV+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_PYENV is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_PYENV_DIR}" ]]; then
    echo_red_text "ERROR: Python (uv) environment (${IRONFOX_PYENV}) is missing!"
    echo 'Please ensure that IRONFOX_PYENV_DIR is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_PYENV}" ]]; then
    echo_red_text "ERROR: Python (uv) environment activation file (${IRONFOX_PYENV}) is missing!"
    echo 'Please ensure that IRONFOX_PYENV is set to a valid file.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_PYENV}" ]]; then
    echo_red_text "ERROR: Python (uv) environment activation file (${IRONFOX_PYENV}) is empty!"
    echo 'Please ensure that IRONFOX_PYENV is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

## uv
if [[ -z "${IRONFOX_UV+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_PYENV is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_UV}" ]]; then
    echo_red_text "ERROR: uv (${IRONFOX_UV}) is missing!"
    echo 'Please ensure that IRONFOX_UV is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_UV}" ]]; then
    echo_red_text "ERROR: uv (${IRONFOX_UV}) is empty!"
    echo 'Please ensure that IRONFOX_UV is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -x "${IRONFOX_UV}" ]]; then
    echo_red_text "ERROR: uv (${IRONFOX_UV}) is not executable!"
    echo 'Please ensure that IRONFOX_UV is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

# uv local directory
if [[ -z "${IRONFOX_UV_LOCAL+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_UV_LOCAL is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_UV_LOCAL}" ]]; then
    echo_red_text "ERROR: uv local directory (${IRONFOX_UV_LOCAL}) is missing!"
    echo 'Please ensure that IRONFOX_UV_LOCAL is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi

# Rust (cargo) environment
if [[ -z "${IRONFOX_CARGO_HOME+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_CARGO_HOME is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ -z "${IRONFOX_CARGO_ENV+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_CARGO_ENV is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -d "${IRONFOX_CARGO_HOME}" ]]; then
    echo_red_text "ERROR: Rust (cargo) environment (${IRONFOX_CARGO_HOME}) is missing!"
    echo 'Please ensure that IRONFOX_CARGO_HOME is set to a valid directory.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_CARGO_ENV}" ]]; then
    echo_red_text "ERROR: Rust (cargo) environment activation file (${IRONFOX_CARGO_ENV}) is missing!"
    echo 'Please ensure that IRONFOX_CARGO_ENV is set to a valid file.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_CARGO_ENV}" ]]; then
    echo_red_text "ERROR: Rust (cargo) environment activation file (${IRONFOX_CARGO_ENV}) is empty!"
    echo 'Please ensure that IRONFOX_CARGO_ENV is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

## cargo
if [[ -z "${IRONFOX_CARGO+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_CARGO is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -f "${IRONFOX_CARGO}" ]]; then
    echo_red_text "ERROR: cargo (${IRONFOX_CARGO}) is missing!"
    echo 'Please ensure that IRONFOX_CARGO is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -s "${IRONFOX_CARGO}" ]]; then
    echo_red_text "ERROR: cargo (${IRONFOX_CARGO}) is empty!"
    echo 'Please ensure that IRONFOX_CARGO is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi
if [[ ! -x "${IRONFOX_CARGO}" ]]; then
    echo_red_text "ERROR: cargo (${IRONFOX_CARGO}) is not executable!"
    echo 'Please ensure that IRONFOX_CARGO is set to a valid executable.'
    echo_red_text 'Aborting...'
    exit 1
fi

# mach
if [[ "${IRONFOX_BUILD_GECKO}" == 1 ]] || [[ "${IRONFOX_BUILD_GECKOVIEW}" == 1 ]] || [[ "${IRONFOX_BUILD_AC_CORE}" == 1 ]] ||
 [[ "${IRONFOX_BUILD_AC}" == 1 ]] || [[ "${IRONFOX_BUILD_FENIX}" == 1 ]]; then
    if [[ -z "${IRONFOX_MACH+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_MACH is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -f "${IRONFOX_MACH}" ]]; then
        echo_red_text "ERROR: mach (${IRONFOX_MACH}) is missing!"
        echo 'Please ensure that IRONFOX_MACH is set to a valid executable.'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -s "${IRONFOX_MACH}" ]]; then
        echo_red_text "ERROR: mach (${IRONFOX_MACH}) is empty!"
        echo 'Please ensure that IRONFOX_MACH is set to a valid executable.'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -x "${IRONFOX_MACH}" ]]; then
        echo_red_text "ERROR: mach (${IRONFOX_MACH}) is not executable!"
        echo 'Please ensure that IRONFOX_MACH is set to a valid executable.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Glean's Python (uv) environment
if [[ "${IRONFOX_BUILD_GLEAN}" == 1 ]]; then
    if [[ -z "${IRONFOX_GLEAN_PYENV+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_GLEAN_PYENV is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ ! -d "${IRONFOX_GLEAN_PYENV}" ]]; then
        echo_red_text "ERROR: Glean's Python (uv) environment (${IRONFOX_GLEAN_PYENV}) is missing!"
        echo 'Please ensure that IRONFOX_GLEAN_PYENV is set to a valid directory.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

# Safe Browsing API key
if [[ "${IRONFOX_BUILD_GECKO}" == 1 ]]; then
    if [[ -z "${IRONFOX_SB_GAPI_KEY_FILE+x}" ]]; then
        echo_red_text 'ERROR: IRONFOX_SB_GAPI_KEY_FILE is missing!'
        echo_red_text 'Aborting...'
        exit 1
    fi
    if [[ "${IRONFOX_SB_GAPI_KEY_FILE}" == 'null' ]]; then
        echo_red_text 'IRONFOX_SB_GAPI_KEY_FILE environment variable has not been specified! Safe Browsing will not be supported in this build.'
        if [[ "${IRONFOX_CI}" == 1 ]]; then
            # CI should always include Safe Browsing, so always fail if it's missing here
            echo_red_text "ERROR: IRONFOX_SB_GAPI_KEY_FILE has not been set! Aborting..."
            exit 1
        fi
        read -p 'Do you want to continue [y/N] ' -n 1 -r
        echo ''
        if ! [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            echo_red_text 'Aborting...'
            exit 1
        fi
    # Verify that the Safe Browsing key file exists
    elif [[ ! -f "${IRONFOX_SB_GAPI_KEY_FILE}" ]]; then
        echo_red_text "ERROR: Safe Browsing API key file (${IRONFOX_SB_GAPI_KEY_FILE}) does not exist!"
        echo 'Please ensure that IRONFOX_SB_GAPI_KEY_FILE is set to a valid file.'
        echo_red_text 'Aborting...'
        exit 1
    # Verify that the Safe Browsing key file isn't empty
    elif [[ ! -s "${IRONFOX_SB_GAPI_KEY_FILE}" ]]; then
        echo_red_text "ERROR: Safe Browsing API key file (${IRONFOX_SB_GAPI_KEY_FILE}) is empty!"
        echo 'Please ensure that IRONFOX_SB_GAPI_KEY_FILE is set to a valid file.'
        echo_red_text 'Aborting...'
        exit 1
    fi
fi

if [[ -n "${FDROID_BUILD+x}" ]]; then
    source "${IRONFOX_ENV_FDROID}"
fi

source "${IRONFOX_CARGO_ENV}"
source "${IRONFOX_NVM_ENV}"
source "${IRONFOX_PYENV}"

# Include version info
source "${IRONFOX_VERSIONS}"

if [[ -z "${FIREFOX_VERSION+x}" ]]; then
    echo_red_text 'ERROR: FIREFOX_VERSION is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${IRONFOX_VERSION+x}" ]]; then
    echo_red_text 'ERROR: IRONFOX_VERSION is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${APPSERVICES_VERSION+x}" ]]; then
    echo_red_text 'ERROR: APPSERVICES_VERSION is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi

if [[ -z "${GLEAN_VERSION+x}" ]]; then
    echo_red_text 'ERROR: GLEAN_VERSION is missing!'
    echo_red_text 'Aborting...'
    exit 1
fi

# Set timezone to UTC for consistency
unset TZ
export TZ="UTC"

# Functions

# Set-up our build environment
function set_build_env() {
    echo_red_text 'Setting build environment variables...'

    # First, clean our environment
    unset IF_BUILD_ID
    unset IF_BUILD_DATE
    unset IF_LOCAL_AC_VERSION
    unset IF_LOCAL_AC_VERSION_GRADLE
    unset IF_LOCAL_AC_VERSION_STAMP
    unset IF_LOCAL_AS_VERSION
    unset IF_LOCAL_AS_VERSION_GRADLE
    unset IF_LOCAL_AS_VERSION_STAMP
    unset IF_LOCAL_GLEAN_VERSION
    unset IF_LOCAL_GLEAN_VERSION_GRADLE
    unset IF_LOCAL_GLEAN_VERSION_STAMP
    unset MOZ_BUILD_DATE

    # Create our directory
    mkdir -p "${IRONFOX_TEMP}/env"

    local readonly IF_BUILD_DATE="$("${IRONFOX_DATE}" -u +"%Y-%m-%dT%H:%M:%SZ")"
    local readonly IF_LOCAL_VERSION_STAMP="$("${IRONFOX_DATE}" "+%s%N")"

    # Override Gecko(View)'s build ID
    local readonly moz_build_id_file="${IRONFOX_TEMP}/env/moz-build-id.txt"
    if [[ "${IRONFOX_BUILD_ID_OVERRIDE}" != 'null' ]]; then
        local readonly IF_BUILD_ID="${IRONFOX_BUILD_ID_OVERRIDE}"
    elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        local readonly IF_BUILD_ID="$("${IRONFOX_DATE}" -d "${IF_BUILD_DATE}" "+%Y%m%d%H%M%S")"
    else
        local readonly IF_BUILD_ID='null'
    fi

    if [[ "${IF_BUILD_ID}" != 'null' ]]; then
        rm -f "${moz_build_id_file}"
        touch "${moz_build_id_file}"
        echo -n "${IF_BUILD_ID}" > "${moz_build_id_file}"
    fi

    # Override our version for local Android Components substitution
    local IF_LOCAL_AC_VERSION_STAMP='undefined'
    local IF_LOCAL_AC_VERSION_STAMP_TEMP='undefined'
    local readonly ac_version_file="${IRONFOX_TEMP}/env/ac-version.txt"

    # To support rebuilds, if we're *not* currently building Android Components, use the previously set version (if it exists)
    # (If we are building Android Components, we always override the version for substitution)
    if [[ "${IRONFOX_BUILD_AC}" != 1 ]]; then
        if [[ -f "${ac_version_file}" ]] && [[ -s "${ac_version_file}" ]]; then
            local readonly current_ac_version=$(cat "${ac_version_file}" | xargs)
            # Ensure the specified Android Components version has actually been built before re-using it...
            if [[ -d "${IRONFOX_MAVEN_LOCAL}/org/mozilla/components/browser-engine-gecko/0.0.1-local-${FIREFOX_VERSION}-${current_ac_version}" ]]; then
                local readonly IF_LOCAL_AC_VERSION_STAMP="${current_ac_version}"
            fi
        fi
    fi

    if [[ "${IF_LOCAL_AC_VERSION_STAMP}" == 'undefined' ]]; then
        # Next, try to use `IRONFOX_LOCAL_AC_VERSION_OVERRIDE` if it's set
        if [[ "${IRONFOX_LOCAL_AC_VERSION_OVERRIDE}" != 'null' ]]; then
            local readonly IF_LOCAL_AC_VERSION_STAMP_TEMP="${IRONFOX_LOCAL_AC_VERSION_OVERRIDE}"
        # Otherwise, set our own version override
        else
            local readonly IF_LOCAL_AC_VERSION_STAMP_TEMP="${IF_LOCAL_VERSION_STAMP}-SNAPSHOT"
        fi
        rm -f "${ac_version_file}"
        touch "${ac_version_file}"
        echo -n "${IF_LOCAL_AC_VERSION_STAMP_TEMP}" > "${ac_version_file}"
    fi

    # Override our version for local Application Services substitution
    local IF_LOCAL_AS_VERSION_STAMP='undefined'
    local IF_LOCAL_AS_VERSION_STAMP_TEMP='undefined'
    local readonly as_version_file="${IRONFOX_TEMP}/env/as-version.txt"

    # To support rebuilds, if we're *not* currently building Application Services, use the previously set version (if it exists)
    # (If we are building Application Services, we always override the version for substitution)
    if [[ "${IRONFOX_BUILD_AS}" != 1 ]]; then
        if [[ -f "${as_version_file}" ]] && [[ -s "${as_version_file}" ]]; then
            local readonly current_as_version=$(cat "${as_version_file}" | xargs)
            # Ensure the specified Application Services version has actually been built before re-using it...
            if [[ -d "${IRONFOX_MAVEN_LOCAL}/org/mozilla/appservices/full-megazord/0.0.1-SNAPSHOT-${APPSERVICES_VERSION}-${current_as_version}" ]]; then
                local readonly IF_LOCAL_AS_VERSION_STAMP="${current_as_version}"
            fi
        fi
    fi

    if [[ "${IF_LOCAL_AS_VERSION_STAMP}" == 'undefined' ]]; then
        # Next, try to use `IRONFOX_LOCAL_AS_VERSION_OVERRIDE` if it's set
        if [[ "${IRONFOX_LOCAL_AS_VERSION_OVERRIDE}" != 'null' ]]; then
            local readonly IF_LOCAL_AS_VERSION_STAMP_TEMP="${IRONFOX_LOCAL_AS_VERSION_OVERRIDE}"
        # Otherwise, set our own version override
        else
            local readonly IF_LOCAL_AS_VERSION_STAMP_TEMP="${IF_LOCAL_VERSION_STAMP}-SNAPSHOT"
        fi
        rm -f "${as_version_file}"
        touch "${as_version_file}"
        echo -n "${IF_LOCAL_AS_VERSION_STAMP_TEMP}" > "${as_version_file}"
    fi

    # Override our version for local Glean substitution
    local IF_LOCAL_GLEAN_VERSION_STAMP='undefined'
    local IF_LOCAL_GLEAN_VERSION_STAMP_TEMP='undefined'
    local readonly glean_version_file="${IRONFOX_TEMP}/env/glean-version.txt"

    # To support rebuilds, if we're *not* currently building Glean, use the previously set version (if it exists)
    # (If we are building Glean, we always override the version for substitution)
    if [[ "${IRONFOX_BUILD_GLEAN}" != 1 ]]; then
        if [[ -f "${glean_version_file}" ]] && [[ -s "${glean_version_file}" ]]; then
            local readonly current_glean_version=$(cat "${glean_version_file}" | xargs)
            # Ensure the specified Glean version has actually been built before re-using it...
            if [[ -d "${IRONFOX_MAVEN_LOCAL}/org/mozilla/telemetry/glean/0.0.1-SNAPSHOT-${GLEAN_VERSION}-${current_glean_version}" ]] &&
             [[ -d "${IRONFOX_MAVEN_LOCAL}/org/mozilla/telemetry/glean-gradle-plugin/0.0.1-SNAPSHOT-${GLEAN_VERSION}-${current_glean_version}" ]] &&
             [[ -d "${IRONFOX_MAVEN_LOCAL}/org/mozilla/telemetry/glean-native/0.0.1-SNAPSHOT-${GLEAN_VERSION}-${current_glean_version}" ]]; then
                local readonly IF_LOCAL_GLEAN_VERSION_STAMP="${current_glean_version}"
            fi
        fi
    fi

    if [[ "${IF_LOCAL_GLEAN_VERSION_STAMP}" == 'undefined' ]]; then
        # Next, try to use `IRONFOX_LOCAL_GLEAN_VERSION_OVERRIDE` if it's set
        if [[ "${IRONFOX_LOCAL_GLEAN_VERSION_OVERRIDE}" != 'null' ]]; then
            local readonly IF_LOCAL_GLEAN_VERSION_STAMP_TEMP="${IRONFOX_LOCAL_GLEAN_VERSION_OVERRIDE}"
        # Otherwise, set our own version override
        else
            local readonly IF_LOCAL_GLEAN_VERSION_STAMP_TEMP="${IF_LOCAL_VERSION_STAMP}-SNAPSHOT"
        fi
        rm -f "${glean_version_file}"
        touch "${glean_version_file}"
        echo -n "${IF_LOCAL_GLEAN_VERSION_STAMP_TEMP}" > "${glean_version_file}"
    fi

    # Set versions for our local dependency substitutions
    if [[ "${IF_BUILD_ID}" != 'null' ]] && [[ -f "${moz_build_id_file}" ]] && [[ -s "${moz_build_id_file}" ]]; then
        readonly MOZ_BUILD_DATE=$(cat "${moz_build_id_file}" | xargs)
        export MOZ_BUILD_DATE
    fi
    if [[ "${IF_LOCAL_AC_VERSION_STAMP_TEMP}" != 'undefined' ]]; then
        local readonly IF_LOCAL_AC_VERSION_STAMP=$(cat "${ac_version_file}" | xargs)
    fi
    if [[ "${IF_LOCAL_AS_VERSION_STAMP_TEMP}" != 'undefined' ]]; then
        local readonly IF_LOCAL_AS_VERSION_STAMP=$(cat "${as_version_file}" | xargs)
    fi
    if [[ "${IF_LOCAL_GLEAN_VERSION_STAMP_TEMP}" != 'undefined' ]]; then
        local readonly IF_LOCAL_GLEAN_VERSION_STAMP=$(cat "${glean_version_file}" | xargs)
    fi
    readonly IF_LOCAL_AC_VERSION="0.0.1-local-${FIREFOX_VERSION}-${IF_LOCAL_AC_VERSION_STAMP}"
    readonly IF_LOCAL_AC_VERSION_GRADLE="-${FIREFOX_VERSION}-${IF_LOCAL_AC_VERSION_STAMP}"
    readonly IF_LOCAL_AS_VERSION="0.0.1-SNAPSHOT-${APPSERVICES_VERSION}-${IF_LOCAL_AS_VERSION_STAMP}"
    readonly IF_LOCAL_AS_VERSION_GRADLE="${APPSERVICES_VERSION}-${IF_LOCAL_AS_VERSION_STAMP}"
    readonly IF_LOCAL_GLEAN_VERSION="0.0.1-SNAPSHOT-${GLEAN_VERSION}-${IF_LOCAL_GLEAN_VERSION_STAMP}"
    readonly IF_LOCAL_GLEAN_VERSION_GRADLE="${GLEAN_VERSION}-${IF_LOCAL_GLEAN_VERSION_STAMP}"

    echo_green_text 'SUCCESS: Set build environment variables'
}

# Prepare Application Services
function prep_as() {
    echo_red_text 'Preparing Application Services...'

    if [[ -f "${IRONFOX_AS}/local.properties" ]]; then
        rm -f "${IRONFOX_AS}/local.properties"
    fi
    cp -f "${IRONFOX_TEMPLATES}/application-services/local.properties" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_AS}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_AS}/local.properties"

    # Substitute our builds of Android Components
    "${IRONFOX_SED}" -i -e "/^android-components = \"/c\\android-components = \"${IF_LOCAL_AC_VERSION}\"" "${IRONFOX_AS}/gradle/libs.versions.toml"

    echo_green_text 'SUCCESS: Prepared Application Services'
}

# Prepare Fenix
function prep_fenix() {
    echo_red_text 'Preparing Fenix...'

    # Configure ABI + release channel
    if [[ -f "${IRONFOX_FENIX}/app/build.gradle" ]]; then
        rm -f "${IRONFOX_FENIX}/app/build.gradle"
    fi
    cp -f "${IRONFOX_TEMP}/fenix/app/build.gradle" "${IRONFOX_FENIX}/app/build.gradle"

    "${IRONFOX_SED}" -i -e "s/include \"armeabi-v7a\", \"arm64-v8a\", \"x86_64\"/include \"${IRONFOX_TARGET_ABI}\"/" "${IRONFOX_FENIX}/app/build.gradle"

    if [[ "${IRONFOX_TARGET_ARCH}" != 'bundle' ]]; then
        # Universal APKs make no sense for architecture-specific builds...
        "${IRONFOX_SED}" -i -e '/universalApk/s/true/false/' "${IRONFOX_FENIX}/app/build.gradle"
    fi

    if [[ -f "${IRONFOX_FENIX}/app/src/release/res/values/static_strings.xml" ]]; then
        rm -f "${IRONFOX_FENIX}/app/src/release/res/values/static_strings.xml"
    fi
    cp -f "${IRONFOX_TEMP}/fenix/app/src/release/res/values/static_strings.xml" "${IRONFOX_FENIX}/app/src/release/res/values/static_strings.xml"

    if [[ -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml" ]]; then
        rm -f "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    fi
    cp -f "${IRONFOX_TEMP}/fenix/app/src/release/res/xml/shortcuts.xml" "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"

    if [[ -d "${IRONFOX_FENIX}/app/src/main/res" ]]; then
        rm -rf "${IRONFOX_FENIX}/app/src/main/res"
    fi
    cp -rf "${IRONFOX_TEMP}/fenix/app/src/main/res/" "${IRONFOX_FENIX}/app/src/main/res/"

    if [[ "${IRONFOX_RELEASE}" == 1 ]]; then
        "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox"|' "${IRONFOX_FENIX}/app/build.gradle"
        "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    else
        "${IRONFOX_SED}" -i -e 's|applicationIdSuffix ".firefox"|applicationIdSuffix ".ironfox.nightly"|' "${IRONFOX_FENIX}/app/build.gradle"
        "${IRONFOX_SED}" -i -e '/android:targetPackage/s/org.mozilla.firefox/org.ironfoxoss.ironfox.nightly/' "${IRONFOX_FENIX}/app/src/release/res/xml/shortcuts.xml"
    fi

    "${IRONFOX_SED}" -i "s/{IRONFOX_NAME}/${IRONFOX_NAME}/" ${IRONFOX_FENIX}/app/src/*/res/values*/*strings.xml

    echo_green_text 'SUCCESS: Prepared Fenix'
}

# Prepare mozilla-central
function prep_gecko() {
    echo_red_text 'Preparing Gecko...'

    if [[ -f "${IRONFOX_GECKO}/local.properties" ]]; then
        rm -f "${IRONFOX_GECKO}/local.properties"
    fi
    cp -f "${IRONFOX_TEMPLATES}/gecko/local.properties" "${IRONFOX_GECKO}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_MOZCONFIGS}|${IRONFOX_MOZCONFIGS}|" "${IRONFOX_GECKO}/local.properties"

    # Substitute Android Components
    "${IRONFOX_SED}" -i "s|{IF_LOCAL_AC_VERSION}|${IF_LOCAL_AC_VERSION}|" "${IRONFOX_GECKO}/local.properties"

    # Substitute Application Services
    "${IRONFOX_SED}" -i -e "s|val VERSION = .*|val VERSION = \""${IF_LOCAL_AS_VERSION}\""|g" "${IRONFOX_AC}/plugins/dependencies/src/main/java/ApplicationServices.kt"
    "${IRONFOX_SED}" -i "s|{IF_LOCAL_AS_VERSION}|${IF_LOCAL_AS_VERSION}|" "${IRONFOX_GECKO}/local.properties"

    # Substitute Glean
    "${IRONFOX_SED}" -i -e "/^glean = \"/c\\glean = \"${IF_LOCAL_GLEAN_VERSION}\"" "${IRONFOX_GECKO}/gradle/libs.versions.toml"

    # Configure release channel
    if [[ -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html" ]]; then
        rm -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html"
    fi
    cp -f "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages/connection-not-secure.html" "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html"
    "${IRONFOX_SED}" -i "s/{IRONFOX_NAME}/${IRONFOX_NAME}/" "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/connection-not-secure.html"

    if [[ -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html" ]]; then
        rm -f "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html"
    fi
    cp -f "${IRONFOX_TEMP}/gecko/toolkit/content/neterror/supportpages/time-errors.html" "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html"
    "${IRONFOX_SED}" -i "s/{IRONFOX_NAME}/${IRONFOX_NAME}/" "${IRONFOX_GECKO}/toolkit/content/neterror/supportpages/time-errors.html"

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    echo_green_text 'SUCCESS: Prepared Gecko'
}

# Prepare Glean
function prep_glean() {
    echo_red_text 'Preparing Glean...'

    if [[ -f "${IRONFOX_GLEAN}/local.properties" ]]; then
        rm -f "${IRONFOX_GLEAN}/local.properties"
    fi
    cp -f "${IRONFOX_TEMPLATES}/glean/local.properties" "${IRONFOX_GLEAN}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM}|${IRONFOX_PLATFORM}|" "${IRONFOX_GLEAN}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_PLATFORM_ARCH}|${IRONFOX_PLATFORM_ARCH}|" "${IRONFOX_GLEAN}/local.properties"
    "${IRONFOX_SED}" -i "s|{IRONFOX_TARGET_RUST}|${IRONFOX_TARGET_RUST}|" "${IRONFOX_GLEAN}/local.properties"

    # Set Glean's uniffi-bindgen location
    if [[ -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle" ]]; then
        rm -f "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
    fi
    cp -f "${IRONFOX_TEMP}/glean/build.gradle" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"
    "${IRONFOX_SED}" -i "s|{IRONFOX_UNIFFI}|${IRONFOX_UNIFFI}|" "${IRONFOX_GLEAN}/glean-core/android/build.gradle"

    echo_green_text 'SUCCESS: Prepared Glean'
}

# Prepare Phoenix
function prep_phoenix() {
    echo_red_text 'Preparing Phoenix...'
    mkdir -p "${IRONFOX_TEMP}/phoenix"

    if [[ -f "${IRONFOX_TEMP}/phoenix/phoenix-overrides-parsed.cfg" ]]; then
        rm -f "${IRONFOX_TEMP}/phoenix/phoenix-overrides-parsed.cfg"
    fi

    cp -f "${IRONFOX_TEMPLATES}/phoenix/phoenix-overrides.cfg" "${IRONFOX_TEMP}/phoenix/phoenix-overrides-parsed.cfg"
    "${IRONFOX_SED}" -i "s|{IRONFOX_CHANNEL}|${IRONFOX_CHANNEL}|" "${IRONFOX_TEMP}/phoenix/phoenix-overrides-parsed.cfg"
    "${IRONFOX_SED}" -i "s|{IRONFOX_VERSION}|${IRONFOX_VERSION}|" "${IRONFOX_TEMP}/phoenix/phoenix-overrides-parsed.cfg"

    echo_green_text 'SUCCESS: Prepared Phoenix'
}

# Prepare UnifiedPush-AC
function prep_up_ac() {
    echo_red_text 'Preparing UnifiedPush-AC...'

    if [[ -f "${IRONFOX_UP_AC}/local.properties" ]]; then
        rm -f "${IRONFOX_UP_AC}/local.properties"
    fi
    cp -f "${IRONFOX_TEMPLATES}/unifiedpush-ac/local.properties" "${IRONFOX_UP_AC}/local.properties"

    # Substitute our local versions of Android Components and Application Services
    "${IRONFOX_SED}" -i "s|{IF_LOCAL_AC_VERSION}|${IF_LOCAL_AC_VERSION}|" "${IRONFOX_UP_AC}/local.properties"
    "${IRONFOX_SED}" -i "s|{IF_LOCAL_AS_VERSION}|${IF_LOCAL_AS_VERSION}|" "${IRONFOX_UP_AC}/local.properties"

    echo_green_text 'SUCCESS: Prepared UnifiedPush-AC'
}

# Prepare LLVM
function prep_llvm() {
    echo_red_text 'Preparing LLVM...'

    # Set LLVM build targets
    if [[ -f "${IRONFOX_BUILD}/targets_to_build" ]]; then
        rm -f "${IRONFOX_BUILD}/targets_to_build"
    fi
    cp -f "${IRONFOX_TEMPLATES}/llvm/targets_to_build_${IRONFOX_TARGET_ARCH}" "${IRONFOX_BUILD}/targets_to_build"

    echo_green_text 'SUCCESS: Prepared LLVM'
}

# Bundletool
function build_bundletool() {
    echo_red_text 'Building Bundletool...'

    pushd "${IRONFOX_BUNDLETOOL_DIR}"
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JAVA_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JAVA_HOME} assemble
    popd

    cp -f "${IRONFOX_BUNDLETOOL_DIR}/build/libs/bundletool.jar" "${IRONFOX_BUNDLETOOL_JAR}"

    echo_green_text 'SUCCESS: Built Bundletool'
}

# LLVM
function build_llvm() {
    echo_red_text 'Building LLVM...'

    pushd "${llvm}"
    local readonly llvmtarget=$(cat "${IRONFOX_BUILD}/targets_to_build")
    echo_green_text "building llvm for ${llvmtarget}"
    cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=out -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="$llvmtarget" \
        -DLLVM_USE_LINKER=lld -DLLVM_BINUTILS_INCDIR=/usr/include -DLLVM_ENABLE_PLUGINS=FORCE_ON \
        -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu"
    cmake --build build -j"$(nproc)"
    cmake --build build --target install -j"$(nproc)"
    popd

    echo_green_text 'SUCCESS: Built LLVM'
}

# Phoenix
function build_phoenix() {
    echo_red_text 'Building Phoenix...'

    pushd "${IRONFOX_PHOENIX}"
    bash -x "${IRONFOX_PHOENIX}/scripts/build.sh"
    popd

    # Ensure our cfg and policy files don't already exist in mozilla-central
    rm -f "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg" "${IRONFOX_GECKO}/ironfox/prefs/policies.json"

    # Copy our outputs to mozilla-central
    cp "${IRONFOX_PHOENIX}/outputs/android/phoenix.cfg" "${IRONFOX_GECKO}/ironfox/prefs/ironfox.cfg"
    cp "${IRONFOX_PHOENIX}/outputs/android/policies.json" "${IRONFOX_GECKO}/ironfox/prefs/policies.json"

    echo_green_text 'SUCCESS: Built Phoenix'
}

# uniffi-bindgen
function build_uniffi() {
    echo_red_text 'Building uniffi-bindgen...'

    pushd "${IRONFOX_PREBUILDS}"
    bash -x "${IRONFOX_PREBUILDS}/scripts/build.sh" 'uniffi'
    popd

    echo_green_text 'SUCCESS: Built uniffi-bindgen'
}

# WASI SDK
function build_wasi() {
    echo_red_text 'Building WASI SDK...'

    pushd "${IRONFOX_PREBUILDS}"
    bash -x "${IRONFOX_PREBUILDS}/scripts/build.sh" 'wasi'
    popd

    echo_green_text 'SUCCESS: Built WASI SDK'
}

# microG
function build_microg() {
    echo_red_text 'Building microG...'

    pushd "${IRONFOX_GMSCORE}"
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_21_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JAVA_HOME} -x javaDocReleaseGeneration \
        :play-services-base:publishToMavenLocal \
        :play-services-basement:publishToMavenLocal \
        :play-services-fido:publishToMavenLocal \
        :play-services-tasks:publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built microG'
}

# Glean
function build_glean() {
    echo_red_text 'Building Glean...'

    pushd "${IRONFOX_GLEAN}"
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_17_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JDK_17_HOME} -Plocal=${IF_LOCAL_GLEAN_VERSION_GRADLE} :glean-native:publishToMavenLocal
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_17_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JDK_17_HOME} -Plocal=${IF_LOCAL_GLEAN_VERSION_GRADLE} publishToMavenLocal -x createGleanPythonVirtualEnv
    popd

    echo_green_text 'SUCCESS: Built Glean'
}

# Application Services
function build_as() {
    echo_red_text 'Building Application Services...'

    # First, clean our environment
    ## (The presence of CI prevents building libraries from `libs/verify-ci-android-environment.sh`)
    unset CI
    unset JAVA_HOME

    pushd "${IRONFOX_AS}"
    export JAVA_HOME="${IRONFOX_JDK_17_HOME}"
    bash -x "${IRONFOX_AS}/libs/verify-android-environment.sh"
    unset JAVA_HOME
    export JAVA_HOME="${IRONFOX_JAVA_HOME}"

    # Build Application Services
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_17_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JDK_17_HOME} -Plocal=${IF_LOCAL_AS_VERSION_GRADLE} publish
    popd

    echo_green_text 'SUCCESS: Built Application Services'
}

# nimbus-fml
function build_nimbus_fml() {
    echo_red_text 'Building nimbus-fml...'
    pushd "${IRONFOX_AS}/components/support/nimbus-fml"
    "${IRONFOX_CARGO}" build --release
    popd
    echo_green_text 'SUCCESS: Built nimbus-fml'
}

# GeckoView
function _build_geckoview() {
    if [[ -z "${1+x}" ]]; then
        echo_red_text 'ERROR: Please specify a target architecture!'
        exit 1
    fi

    local readonly target_arch="$1"

    # Ensure we have a valid architecture (+ set pretty architecture...)
    case "${target_arch}" in
    arm64)
        local readonly pretty_arch='ARM64'
        ;;
    arm)
        local readonly pretty_arch='ARM'
        ;;
    x86_64)
        local readonly pretty_arch='x86_64'
        ;;
    bundle)
        local readonly pretty_arch='Universal'
        ;;
    *)
        echo_red_text "ERROR: Invalid target architecture: ${target_arch}"
        exit 1
        ;;
    esac

    # First, clean our environment
    unset IRONFOX_MACH_GECKOVIEW_CREATE_AAR
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT
    unset MOZ_AUTOMATION
    unset MOZ_CHROME_MULTILOCALE

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${target_arch}"

    # So, at this point, we either need to publish GeckoView (GV) to our local Maven repo, or create an AAR archive
    # We *typically* just publish GV to our local Maven repo, but we INSTEAD create an AAR archive if:
    # 1. Our current target does NOT match our final target
    # OR:
    # 2. We're in CI and our final target is NOT `bundle`
    # (For reference, the final target is `IRONFOX_TARGET_ARCH`, and the current target is `target_arch`)
    local publish_gv_to_maven_local=1
    if [[ "${target_arch}" != "${IRONFOX_TARGET_ARCH}" ]]; then
        local publish_gv_to_maven_local=0
    elif [[ "${IRONFOX_CI}" == 1 ]] && [[ "${target_arch}" != 'bundle' ]]; then
        local publish_gv_to_maven_local=0
    fi
    local readonly publish_gv_to_maven_local

    # Tell Mach whether we need to create an AAR archive
    if [[ "${publish_gv_to_maven_local}" == 0 ]]; then
        export IRONFOX_MACH_GECKOVIEW_CREATE_AAR=1
    else
        export IRONFOX_MACH_GECKOVIEW_CREATE_AAR=0
    fi

    # Ensure we remove any existing Mach environment cache
    # (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"
    
    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='geckoview'

    # For multi-locale builds
    export MOZ_CHROME_MULTILOCALE="${IRONFOX_LOCALES}"

    pushd "${IRONFOX_GECKO}"

    # Build GeckoView
    echo_red_text "Building GeckoView (${pretty_arch})..."
    "${IRONFOX_MACH}" configure

    if [[ "${publish_gv_to_maven_local}" == 1 ]]; then
        # Publish GeckoView to our local Maven repo
        "${IRONFOX_MACH}" gradle :geckoview:publishReleasePublicationToMavenLocal
    else
        # Create our AAR archives
        "${IRONFOX_MACH}" gradle :machConfigure
        MOZ_AUTOMATION=1 "${IRONFOX_MACH}" android archive-geckoview
        unset MOZ_AUTOMATION

        if [[ "${target_arch}" == 'arm64' ]]; then
            local readonly aar_output="${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM64}"
        elif [[ "${target_arch}" == 'arm' ]]; then
            local readonly aar_output="${IRONFOX_OUTPUTS_GECKOVIEW_AAR_ARM}"
        elif [[ "${target_arch}" == 'x86_64' ]]; then
            local readonly aar_output="${IRONFOX_OUTPUTS_GECKOVIEW_AAR_X86_64}"
        fi

        # Create our AAR output directory
        mkdir -p $(dirname "${aar_output}")

        cp -vf "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${target_arch}/gradle/target.maven.zip" "${aar_output}"
    fi

    echo_green_text "SUCCESS: Built GeckoView (${pretty_arch})"
    popd
}

function build_geckoview() {
    # Determine if we should build ARM64
    local if_build_geckoview_arm64=0
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]]; then
        local if_build_geckoview_arm64=1
    elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]] && [[ "${IRONFOX_GECKOVIEW_BUNDLE_DIRECT}" != 1 ]]; then
        local if_build_geckoview_arm64=1
    fi
    local readonly if_build_geckoview_arm64

    # Determine if we should build ARM
    local if_build_geckoview_arm=0
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm' ]]; then
        local if_build_geckoview_arm=1
    elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]] && [[ "${IRONFOX_GECKOVIEW_BUNDLE_DIRECT}" != 1 ]]; then
        local if_build_geckoview_arm=1
    fi
    local readonly if_build_geckoview_arm

    # Determine if we should build x86_64
    local if_build_geckoview_x86_64=0
    if [[ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]]; then
        local if_build_geckoview_x86_64=1
    elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]] && [[ "${IRONFOX_GECKOVIEW_BUNDLE_DIRECT}" != 1 ]]; then
        local if_build_geckoview_x86_64=1
    fi
    local readonly if_build_geckoview_x86_64

    # ARM64
    if [[ "${if_build_geckoview_arm64}" == 1 ]]; then
        _build_geckoview 'arm64'
    fi

    # ARM
    if [[ "${if_build_geckoview_arm}" == 1 ]]; then
        _build_geckoview 'arm'
    fi

    # x86_64
    if [[ "${if_build_geckoview_x86_64}" == 1 ]]; then
        _build_geckoview 'x86_64'
    fi

    # Bundle (Universal)
    if [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        # First, we need to produce our fat AAR
        ## That process re-uses a lot of the same logic as `_build_gecko`, hence we re-use it
        _build_gecko 'bundle'

        _build_geckoview 'bundle'
    fi
}

# Gecko
function _build_gecko() {
    if [[ -z "${1+x}" ]]; then
        echo_red_text 'ERROR: Please specify a target architecture!'
        exit 1
    fi

    local readonly target_arch="$1"

    # Ensure we have a valid architecture (+ set pretty architecture...)
    case "${target_arch}" in
    arm64)
        local readonly pretty_arch='ARM64'
        ;;
    arm)
        local readonly pretty_arch='ARM'
        ;;
    x86_64)
        local readonly pretty_arch='x86_64'
        ;;
    bundle)
        local readonly pretty_arch='Universal'
        ;;
    *)
        echo_red_text "ERROR: Invalid target architecture: ${target_arch}"
        exit 1
        ;;
    esac

    # First, clean our environment
    ## (MOZ_CHROME_MULTILOCALE will cause a build failure if set...)
    unset IRONFOX_MACH_GECKO_STAGE
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT
    unset MOZ_ANDROID_FAT_AAR_ARM64_V8A
    unset MOZ_ANDROID_FAT_AAR_ARMEABI_V7A
    unset MOZ_ANDROID_FAT_AAR_X86_64
    unset MOZ_CHROME_MULTILOCALE

    if [[ "${target_arch}" != 'bundle' ]]; then
        # Ensure we don't try to unset this here if we're doing a bundle build, because build_geckoview calls and sets this directly
        unset MOZ_ANDROID_FAT_AAR_ARCHITECTURES
    fi

    # If we're producing a bundle, we need to prepare to assemble our fat AAR
    if [[ "${target_arch}" == 'bundle' ]]; then
        # Verify that our ARM64 GeckoView AAR archive exists
        if [[ ! -f "${IRONFOX_GECKOVIEW_AAR_ARM64}" ]]; then
            echo_red_text "ERROR: ARM64 GeckoView AAR archive not found! (${IRONFOX_GECKOVIEW_AAR_ARM64})"
            exit 1
        fi

        # Verify that our ARM64 GeckoView AAR archive is not an empty file
        if [[ ! -s "${IRONFOX_GECKOVIEW_AAR_ARM64}" ]]; then
            echo_red_text "ERROR: ARM64 GeckoView AAR archive is empty! (${IRONFOX_GECKOVIEW_AAR_ARM64})"
            exit 1
        fi

        # Verify that our ARM GeckoView AAR archive exists
        if [[ ! -f "${IRONFOX_GECKOVIEW_AAR_ARM}" ]]; then
            echo_red_text "ERROR: ARM GeckoView AAR archive not found! (${IRONFOX_GECKOVIEW_AAR_ARM})"
            exit 1
        fi

        # Verify that our ARM GeckoView AAR archive is not an empty file
        if [[ ! -s "${IRONFOX_GECKOVIEW_AAR_ARM}" ]]; then
            echo_red_text "ERROR: ARM GeckoView AAR archive is empty! (${IRONFOX_GECKOVIEW_AAR_ARM})"
            exit 1
        fi

        # Verify that our x86_64 GeckoView AAR archive exists
        if [[ ! -f "${IRONFOX_GECKOVIEW_AAR_X86_64}" ]]; then
            echo_red_text "ERROR: x86_64 GeckoView AAR archive not found! (${IRONFOX_GECKOVIEW_AAR_X86_64})"
            exit 1
        fi

        # Verify that our x86_64 GeckoView AAR archive is not an empty file
        if [[ ! -s "${IRONFOX_GECKOVIEW_AAR_X86_64}" ]]; then
            echo_red_text "ERROR: x86_64 GeckoView AAR archive is empty! (${IRONFOX_GECKOVIEW_AAR_X86_64})"
            exit 1
        fi

        if [[ -z "${MOZ_ANDROID_FAT_AAR_ARCHITECTURES+x}" ]]; then
            readonly MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
            export MOZ_ANDROID_FAT_AAR_ARCHITECTURES
        fi

        readonly MOZ_ANDROID_FAT_AAR_ARM64_V8A="${IRONFOX_GECKOVIEW_AAR_ARM64}"
        readonly MOZ_ANDROID_FAT_AAR_ARMEABI_V7A="${IRONFOX_GECKOVIEW_AAR_ARM}"
        readonly MOZ_ANDROID_FAT_AAR_X86_64="${IRONFOX_GECKOVIEW_AAR_X86_64}"
        export MOZ_ANDROID_FAT_AAR_ARM64_V8A
        export MOZ_ANDROID_FAT_AAR_ARMEABI_V7A
        export MOZ_ANDROID_FAT_AAR_X86_64
    fi

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${target_arch}"

    # Determine if we should package Gecko
    # (This should only run if our current target matches our final target OR if we're in CI and our final target is `bundle`)
    local package_gecko=1
    if [[ "${target_arch}" != "${IRONFOX_TARGET_ARCH}" ]]; then
        local package_gecko=0
    elif [[ "${IRONFOX_CI}" == 1 ]] && [[ "${IRONFOX_TARGET_ARCH}" != 'bundle' ]]; then
        local package_gecko=0
    fi
    local readonly package_gecko

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='gecko'

    pushd "${IRONFOX_GECKO}"

    # Build Gecko
    echo_red_text "Building Gecko (${pretty_arch})..."
    export IRONFOX_MACH_GECKO_STAGE='build'
    "${IRONFOX_MACH}" configure
    "${IRONFOX_MACH}" build
    echo_green_text "SUCCESS: Built Gecko (${pretty_arch})"

    # Package Gecko
    if [[ "${package_gecko}" == 1 ]]; then
        echo_red_text "Packaging Gecko (${pretty_arch})..."
        export IRONFOX_MACH_GECKO_STAGE='package'

        if [[ "${target_arch}" != 'bundle' ]]; then
            # If we're building a bundle, no need to re-run mach configure here (since Mach is always set to package for Bundle builds)
            "${IRONFOX_MACH}" configure
        fi

        "${IRONFOX_MACH}" package-multi-locale --locales ${IRONFOX_LOCALES}
        echo_green_text "SUCCESS: Packaged Gecko (${pretty_arch})"
    fi
    popd
}

function build_gecko() {
    # Determine if we should build ARM64
    local if_build_gecko_arm64=0
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]]; then
        local if_build_gecko_arm64=1
    elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]] && [[ "${IRONFOX_GECKOVIEW_BUNDLE_DIRECT}" != 1 ]]; then
        local if_build_gecko_arm64=1
    fi
    local readonly if_build_gecko_arm64

    # Determine if we should build ARM
    local if_build_gecko_arm=0
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm' ]]; then
        local if_build_gecko_arm=1
    elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]] && [[ "${IRONFOX_GECKOVIEW_BUNDLE_DIRECT}" != 1 ]]; then
        local if_build_gecko_arm=1
    fi
    local readonly if_build_gecko_arm

    # Determine if we should build x86_64
    local if_build_gecko_x86_64=0
    if [[ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]]; then
        local if_build_gecko_x86_64=1
    elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]] && [[ "${IRONFOX_GECKOVIEW_BUNDLE_DIRECT}" != 1 ]]; then
        local if_build_gecko_x86_64=1
    fi
    local readonly if_build_gecko_x86_64

    # ARM64
    if [[ "${if_build_gecko_arm64}" == 1 ]]; then
        _build_gecko 'arm64'
    fi

    # ARM
    if [[ "${if_build_gecko_arm}" == 1 ]]; then
        _build_gecko 'arm'
    fi

    # x86_64
    if [[ "${if_build_gecko_x86_64}" == 1 ]]; then
        _build_gecko 'x86_64'
    fi
}

# Android Components (Core)
function build_ac_core() {
    echo_red_text 'Building Android Components (Core)...'

    # First, clean our environment
    ## (The presence of CI causes build failures, due to us removing MARS and friends)
    unset CI
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT

    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='ac-core'

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${IRONFOX_TARGET_ARCH}"

    pushd "${IRONFOX_GECKO}"

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    # Configure Mach
    "${IRONFOX_MACH}" configure

    # Build concept-fetch, concept-base (dependency of support-base), support-base and ui-icons
    ## (Needed by UnifiedPush-AC)
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components :components:concept-fetch:publishToMavenLocal
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components :components:concept-base:publishToMavenLocal
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components :components:support-base:publishToMavenLocal
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components :components:ui-icons:publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built Android Components (Core)'
}

# UnifiedPush-AC
function build_up_ac() {
    echo_red_text 'Building UnifiedPush-AC...'

    pushd "${IRONFOX_UP_AC}"
    "${IRONFOX_GRADLE}" ${IRONFOX_GRADLE_FLAGS} -Dorg.gradle.java.home=${IRONFOX_JDK_17_HOME} -Dorg.gradle.java.installations.paths=${IRONFOX_JDK_17_HOME} publish
    popd

    echo_green_text 'SUCCESS: Built UnifiedPush-AC'
}

# Android Components
function build_ac() {
    echo_red_text 'Building Android Components...'

    # First, clean our environment
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT

    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='android-components'

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${IRONFOX_TARGET_ARCH}"

    pushd "${IRONFOX_GECKO}"

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    # Configure Mach
    "${IRONFOX_MACH}" configure

    # Build Android Components
    "${IRONFOX_MACH}" gradle -Plocal=${IF_LOCAL_AC_VERSION_GRADLE} -p mobile/android/android-components publishToMavenLocal
    popd

    echo_green_text 'SUCCESS: Built Android Components'
}

function build_fenix() {
    # Fenix
    echo_red_text "Building IronFox ${IRONFOX_VERSION}: ${IRONFOX_CHANNEL_PRETTY} (${IRONFOX_TARGET_PRETTY})..."

    # First, clean our environment
    unset IRONFOX_MACH_TARGET_ARCH
    unset IRONFOX_MACH_TARGET_PROJECT

    # Set our target project
    export IRONFOX_MACH_TARGET_PROJECT='fenix'

    # Set our target architecture
    export IRONFOX_MACH_TARGET_ARCH="${IRONFOX_TARGET_ARCH}"

    pushd "${IRONFOX_GECKO}"

    # Ensure we remove any existing Mach environment cache
    ## (To ensure our configurations are properly updated/reflected...)
    rm -rf "${IRONFOX_GECKO}/.gradle/mach-environment-cache"

    # Configure Mach
    "${IRONFOX_MACH}" configure

    # If it's not our first time building Fenix, clean Gradle to ensure our builds are fresh
    if [[ -f "${IRONFOX_TEMP}/built-fenix" ]]; then
        "${IRONFOX_MACH}" gradle -p mobile/android/fenix :app:clean
    fi

    # Build Fenix
    "${IRONFOX_MACH}" gradle -p mobile/android/fenix assembleRelease

    # 1. Export APK for ARM64
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        if [[ "${IRONFOX_SIGN}" == 1 ]]; then
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM64_UNSIGNED}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-arm64-v8a-release-unsigned.apk" "${IRONFOX_OUTPUTS_ARM64_UNSIGNED}"
        else
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM64}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-arm64-v8a-release.apk" "${IRONFOX_OUTPUTS_ARM64}"
        fi
    fi

    # 2. Export APK for ARM
    if [[ "${IRONFOX_TARGET_ARCH}" == 'arm' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        if [[ "${IRONFOX_SIGN}" == 1 ]]; then
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM_UNSIGNED}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-armeabi-v7a-release-unsigned.apk" "${IRONFOX_OUTPUTS_ARM_UNSIGNED}"
        else
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_ARM}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-armeabi-v7a-release.apk" "${IRONFOX_OUTPUTS_ARM}"
        fi
    fi

    # 3. Export APK for x86_64
    if [[ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]] || [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        if [[ "${IRONFOX_SIGN}" == 1 ]]; then
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_X86_64_UNSIGNED}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-x86_64-release-unsigned.apk" "${IRONFOX_OUTPUTS_X86_64_UNSIGNED}"
        else
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_X86_64}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-x86_64-release.apk" "${IRONFOX_OUTPUTS_X86_64}"
        fi
    fi

    # 4. Export universal APK + build and export our AAB
    if [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
        # 4. Export universal APK
        if [[ "${IRONFOX_SIGN}" == 1 ]]; then
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-universal-release-unsigned.apk" "${IRONFOX_OUTPUTS_UNIVERSAL_UNSIGNED}"
        else
            # Create our output directory
            mkdir -p $(dirname "${IRONFOX_OUTPUTS_UNIVERSAL}")

            cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/apk/release/app-universal-release.apk" "${IRONFOX_OUTPUTS_UNIVERSAL}"
        fi

        # 5. Finally, build and export our AAB
        "${IRONFOX_MACH}" gradle -Paab -p mobile/android/fenix bundleRelease

        # Create our output directory
        mkdir -p $(dirname "${IRONFOX_OUTPUTS_BUNDLE_AAB}")

        cp -v "${IRONFOX_GECKO}/obj/ironfox-${IRONFOX_CHANNEL}-${IRONFOX_TARGET_ARCH}/gradle/build/mobile/android/fenix/app/outputs/bundle/release/app-release.aab" "${IRONFOX_OUTPUTS_BUNDLE_AAB}"
    fi
    popd

    echo_green_text "SUCCESS: Built IronFox ${IRONFOX_VERSION}: ${IRONFOX_CHANNEL_PRETTY} (${IRONFOX_TARGET_PRETTY})"

    if [[ ! -f "${IRONFOX_TEMP}/built-fenix" ]]; then
        touch "${IRONFOX_TEMP}/built-fenix"
    fi
}

# Prepare build environment...
## (These need to be performed here instead of in `prebuild.sh`, so that we can account for if users decide to
### change the variables, without them needing to re-run the entire prebuild script...)
echo_red_text 'Preparing your build environment...'

# Set-up our build environment
set_build_env

# Prepare mozilla-central
if [[ "${IRONFOX_BUILD_GECKO}" == 1 ]] || [[ "${IRONFOX_BUILD_GECKOVIEW}" == 1 ]] || [[ "${IRONFOX_BUILD_AC_CORE}" == 1 ]] ||
 [[ "${IRONFOX_BUILD_AC}" == 1 ]] || [[ "${IRONFOX_BUILD_FENIX}" == 1 ]]; then
    prep_gecko
fi

# Prepare Application Services
if [[ "${IRONFOX_BUILD_AS}" == 1 ]]; then
    prep_as
fi

# Prepare Fenix
if [[ "${IRONFOX_BUILD_FENIX}" == 1 ]]; then
    prep_fenix
fi

# Prepare Glean
if [[ "${IRONFOX_BUILD_GLEAN}" == 1 ]]; then
    prep_glean
fi

# Prepare LLVM
if [[ "${IRONFOX_BUILD_LLVM}" == 1 ]]; then
    prep_llvm
fi

# Prepare Phoenix
if [[ "${IRONFOX_BUILD_PHOENIX}" == 1 ]]; then
    prep_phoenix
fi

# Prepare UnifiedPush-AC
if [[ "${IRONFOX_BUILD_UP_AC}" == 1 ]]; then
    prep_up_ac
fi

echo_green_text 'SUCCESS: Prepared build environment'

# Build Phoenix
if [[ "${IRONFOX_BUILD_PHOENIX}" == 1 ]]; then
    build_phoenix
fi

# Build Bundletool
if [[ "${IRONFOX_BUILD_BUNDLETOOL}" == 1 ]]; then
    build_bundletool
fi

# Build microG
if [[ "${IRONFOX_BUILD_MICROG}" == 1 ]]; then
    build_microg
fi

# Build LLVM
if [[ "${IRONFOX_BUILD_LLVM}" == 1 ]]; then
    build_llvm
fi

# Build WASI SDK
if [[ "${IRONFOX_BUILD_WASI}" == 1 ]]; then
    build_wasi
fi

# Build Gecko
if [[ "${IRONFOX_BUILD_GECKO}" == 1 ]]; then
    build_gecko
fi

# If we're targetting a bundle, ensure `MOZ_ANDROID_FAT_AAR_ARCHITECTURES` is always set at this point
## (This is usually set/handled by `build_gecko`, but the presence of this variable also influences other parts of the build process)
if [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]] && [[ -z "${MOZ_ANDROID_FAT_AAR_ARCHITECTURES+x}" ]]; then
    readonly MOZ_ANDROID_FAT_AAR_ARCHITECTURES='arm64-v8a,armeabi-v7a,x86_64'
    export MOZ_ANDROID_FAT_AAR_ARCHITECTURES
fi

# Build GeckoView
if [[ "${IRONFOX_BUILD_GECKOVIEW}" == 1 ]]; then
    build_geckoview
fi

# Ensure `MOZ_CHROME_MULTILOCALE` is always set at this point
## (This is usually set/handled by `build_geckoview`, but the presence of this variable also influences other parts of the build process)
if [[ -z "${MOZ_CHROME_MULTILOCALE+x}" ]]; then
    MOZ_CHROME_MULTILOCALE="${IRONFOX_LOCALES}"
fi
readonly MOZ_CHROME_MULTILOCALE
export MOZ_CHROME_MULTILOCALE

# Build Android Components (Core)
if [[ "${IRONFOX_BUILD_AC_CORE}" == 1 ]]; then
    build_ac_core
fi

# Build Application Services
if [[ "${IRONFOX_BUILD_AS}" == 1 ]]; then
    build_as
fi

# Build UnifiedPush-AC
if [[ "${IRONFOX_BUILD_UP_AC}" == 1 ]]; then
    build_up_ac
fi

# Build nimbus-fml
if [[ "${IRONFOX_BUILD_NIMBUS_FML}" == 1 ]]; then
    build_nimbus_fml
fi

# Build Android Components
if [[ "${IRONFOX_BUILD_AC}" == 1 ]]; then
    build_ac
fi

# Build Glean
if [[ "${IRONFOX_BUILD_GLEAN}" == 1 ]]; then
    build_glean
fi

# Build Fenix
if [[ "${IRONFOX_BUILD_FENIX}" == 1 ]]; then
    build_fenix
fi
