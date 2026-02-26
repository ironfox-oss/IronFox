# IronFox external environment variables

## This is used for converting IronFox-specific environment variables to ones used in external projects.

## CAUTION: Do NOT source this directly!
## Source 'env.sh' instead.

## CAUTION: Do NOT try to configure any of these environment variables directly!
## Use the IronFox equivalent variables (at `env_common.sh`) instead.

# Compiler flags
export TARGET_CFLAGS="${IRONFOX_COMPILER_FLAGS}"
export TARGET_CXXFLAGS="${IRONFOX_COMPILER_FLAGS}"

# Gradle flags
export GRADLE_FLAGS="${IRONFOX_GRADLE_FLAGS}"

# Rust flags
export CARGO_BUILD_RUSTDOCFLAGS="${IRONFOX_RUST_FLAGS}"
export RUSTDOCFLAGS="${IRONFOX_RUST_FLAGS}"

# Android SDK
export ANDROID_HOME="${IRONFOX_ANDROID_SDK}"
export ANDROID_SDK_ROOT="${IRONFOX_ANDROID_SDK}"
export PATH="${IRONFOX_ANDROID_SDK}/cmdline-tools/latest/bin:${PATH}"

# Android NDK
export ANDROID_NDK_HOME="${IRONFOX_ANDROID_NDK}"
export ANDROID_NDK_ROOT="${IRONFOX_ANDROID_NDK}"

# Gradle cache
export CACHEDIR="${IRONFOX_GRADLE_CACHE}"

# Gradle home
export GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"

# Java home
export JAVA_HOME="${IRONFOX_JAVA_HOME}"
export PATH="${IRONFOX_JAVA_HOME}/bin:${PATH}"

# llvm-profdata
export LLVM_PROFDATA="${IRONFOX_LLVM_PROFDATA}"

# Mach
## https://firefox-source-docs.mozilla.org/mach/usage.html#user-settings
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#95
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#284
export DISABLE_TELEMETRY=1
export MACHRC="${IRONFOX_PATCHES}/machrc"
export MOZCONFIG="${IRONFOX_GECKO}/mozconfig"

# microG
export GRADLE_MICROG_VERSION_WITHOUT_GIT=1

# mozbuild
export MOZBUILD_STATE_PATH="${IRONFOX_MOZBUILD}"

# No-op Taskcluster
## This should help ensure we don't fetch Mozilla artifacts/prebuilds
export TASKCLUSTER_PROXY_URL='https://noop.invalid'
export TASKCLUSTER_ROOT_URL='https://noop.invalid'

# NSS
export NSS_DIR="${IRONFOX_NSS_DIR}"
export NSS_STATIC=1

# Phoenix
export PHOENIX_ANDROID_ONLY=1
export PHOENIX_EXTENDED_ONLY=1
export PHOENIX_EXTRA_CFG=1
export PHOENIX_EXTRA_CFG_FILE="${IRONFOX_BUILD}/tmp/gecko/ironfox-parsed.cfg"
export PHOENIX_EXTRA_CFG_OUTPUT_DIR="${IRONFOX_GECKO}/ironfox/prefs"
export PHOENIX_EXTRA_EXTENDED_OUTPUT_FILENAME_ANDROID='ironfox'
export PHOENIX_EXTRA_POLICIES_ANDROID=1
export PHOENIX_EXTRA_POLICIES_FILE_ANDROID="${IRONFOX_PATCHES}/build/gecko/policies.json"
export PHOENIX_EXTRA_POLICIES_OUTPUT_DIR_ANDROID="${IRONFOX_GECKO}/ironfox/prefs"
export PHOENIX_SPECS=0

# Python (Glean)
export GLEAN_PYTHON="$(which python)"

# Rust (cargo)
export CARGO="${IRONFOX_CARGO}"
export CARGO_HOME="${IRONFOX_CARGO_HOME}"
export CARGO_INSTALL_ROOT="${IRONFOX_CARGO_HOME}"
export RUSTC="${IRONFOX_RUSTC}"
export RUSTDOC="${IRONFOX_RUSTDOC}"
export PATH="${IRONFOX_CARGO_HOME}/bin:${PATH}"

## Disable debug
export CARGO_PROFILE_DEV_DEBUG=false
export CARGO_PROFILE_DEV_DEBUG_ASSERTIONS=false
export CARGO_PROFILE_RELEASE_DEBUG=false
export CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS=false

## Disable HTTP debugging
export CARGO_HTTP_DEBUG=false

## Display progress bars
export CARGO_TERM_PROGRESS_WHEN="${IRONFOX_CARGO_PROGRESS_BAR}"
export CARGO_TERM_PROGRESS_WIDTH=80

## Enable certificate revocation checks
export CARGO_HTTP_CHECK_REVOKE=true

## Enable colored output
export CARGO_TERM_COLOR="${IRONFOX_CARGO_COLORED_OUTPUT}"

## Enable overflow checks
export CARGO_PROFILE_DEV_OVERFLOW_CHECKS=true
export CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS=true

## Enable performance optimizations
export CARGO_PROFILE_DEV_LTO=true
export CARGO_PROFILE_DEV_OPT_LEVEL=3
export CARGO_PROFILE_RELEASE_LTO=true
export CARGO_PROFILE_RELEASE_OPT_LEVEL=3

## Strip debug info
export CARGO_PROFILE_DEV_STRIP='debuginfo'
export CARGO_PROFILE_RELEASE_STRIP='debuginfo'

# rustup
export RUSTUP_HOME="${IRONFOX_RUSTUP_HOME}"

## Display progress bars
export RUSTUP_TERM_PROGRESS_WHEN="${IRONFOX_RUSTUP_PROGRESS_BAR}"

## Enable colored output
export RUSTUP_TERM_COLOR="${IRONFOX_RUSTUP_COLORED_OUTPUT}"

# Include version info
source "${IRONFOX_VERSIONS}"

## Set Rust version
export RUSTUP_TOOLCHAIN="${RUST_VERSION}"

# unifiedpush-ac
export UP_AC_GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"
