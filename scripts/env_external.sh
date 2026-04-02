# IronFox external environment variables

## This is used for converting IronFox-specific environment variables to ones used in external projects.

## CAUTION: Do NOT source this directly!
## Source 'env.sh' instead.

## CAUTION: Do NOT try to configure any of these environment variables directly!
## Use the IronFox equivalent variables (at `env_common.sh`) instead.

# Compiler flags
TARGET_CFLAGS="${IRONFOX_COMPILER_FLAGS}"
TARGET_CXXFLAGS="${IRONFOX_COMPILER_FLAGS}"
export TARGET_CFLAGS
export TARGET_CXXFLAGS

# Gradle flags
GRADLE_FLAGS="${IRONFOX_GRADLE_FLAGS}"
export GRADLE_FLAGS

# Rust flags
CARGO_BUILD_RUSTDOCFLAGS="${IRONFOX_RUST_FLAGS}"
RUSTDOCFLAGS="${IRONFOX_RUST_FLAGS}"
export CARGO_BUILD_RUSTDOCFLAGS
export RUSTDOCFLAGS

# Android SDK
## https://developer.android.com/tools/variables
ANDROID_HOME="${IRONFOX_ANDROID_SDK}"
ANDROID_SDK_ROOT="${IRONFOX_ANDROID_SDK}"
export ANDROID_HOME
export ANDROID_SDK_ROOT

## Android SDK preferences
ANDROID_USER_HOME="${IRONFOX_BUILD}/.android"
export ANDROID_USER_HOME

# Android NDK
ANDROID_NDK_HOME="${IRONFOX_ANDROID_NDK}"
ANDROID_NDK_ROOT="${IRONFOX_ANDROID_NDK}"
export ANDROID_NDK_HOME
export ANDROID_NDK_ROOT

# Gradle cache
CACHEDIR="${IRONFOX_GRADLE_CACHE}"
export CACHEDIR

# Gradle home
GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"
export GRADLE_USER_HOME

# IronFox prebuilds
IRONFOX_PREBUILDS_AWK="${IRONFOX_AWK}"
IRONFOX_PREBUILDS_CARGO_COLORED_OUTPUT="${IRONFOX_CARGO_COLORED_OUTPUT}"
IRONFOX_PREBUILDS_CARGO_PROGRESS_BAR="${IRONFOX_CARGO_PROGRESS_BAR}"
IRONFOX_PREBUILDS_CIPHERS="${IRONFOX_CIPHERS}"
IRONFOX_PREBUILDS_CURL_FLAGS_OVERRIDE=1
IRONFOX_PREBUILDS_CURL_FLAGS="${IRONFOX_CURL_FLAGS}"
IRONFOX_PREBUILDS_MAKE="${IRONFOX_MAKE}"
IRONFOX_PREBUILDS_NPROC="${IRONFOX_NPROC}"
IRONFOX_PREBUILDS_RUSTUP_COLORED_OUTPUT="${IRONFOX_RUSTUP_COLORED_OUTPUT}"
IRONFOX_PREBUILDS_RUSTUP_PROGRESS_BAR="${IRONFOX_RUSTUP_PROGRESS_BAR}"
IRONFOX_PREBUILDS_SED="${IRONFOX_SED}"
IRONFOX_PREBUILDS_TAR="${IRONFOX_TAR}"
export IRONFOX_PREBUILDS_AWK
export IRONFOX_PREBUILDS_CARGO_COLORED_OUTPUT
export IRONFOX_PREBUILDS_CARGO_PROGRESS_BAR
export IRONFOX_PREBUILDS_CIPHERS
export IRONFOX_PREBUILDS_CURL_FLAGS_OVERRIDE
export IRONFOX_PREBUILDS_CURL_FLAGS
export IRONFOX_PREBUILDS_MAKE
export IRONFOX_PREBUILDS_NPROC
export IRONFOX_PREBUILDS_RUSTUP_COLORED_OUTPUT
export IRONFOX_PREBUILDS_RUSTUP_PROGRESS_BAR
export IRONFOX_PREBUILDS_SED
export IRONFOX_PREBUILDS_TAR

# Java home
JAVA_HOME="${IRONFOX_JAVA_HOME}"
export JAVA_HOME

# Java options
GRADLE_OPTS="${IRONFOX_JAVA_OPTS}"
JAVA_OPTS="${IRONFOX_JAVA_OPTS}"
JAVA_TOOL_OPTIONS="${IRONFOX_JAVA_OPTS}"
JDK_JAVA_OPTIONS="${IRONFOX_JAVA_OPTS}"
export GRADLE_OPTS
export JAVA_OPTS
export JAVA_TOOL_OPTIONS
export JDK_JAVA_OPTIONS

# llvm-profdata
LLVM_PROFDATA="${IRONFOX_LLVM_PROFDATA}"
export LLVM_PROFDATA

# Mach
## https://firefox-source-docs.mozilla.org/mach/usage.html#user-settings
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#95
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#284
DISABLE_TELEMETRY=1
MACHRC="${IRONFOX_CONFIGS}/mach/machrc"
MOZCONFIG="${IRONFOX_MOZCONFIGS}/ironfox.mozconfig"
export DISABLE_TELEMETRY
export MACHRC
export MOZCONFIG

# microG
GRADLE_MICROG_VERSION_WITHOUT_GIT=1
export GRADLE_MICROG_VERSION_WITHOUT_GIT

# mozbuild
MOZBUILD_STATE_PATH="${IRONFOX_MOZBUILD}"
export MOZBUILD_STATE_PATH

# No-op Taskcluster
## This should help ensure we don't fetch Mozilla artifacts/prebuilds
TASKCLUSTER_PROXY_URL='https://noop.invalid'
TASKCLUSTER_ROOT_URL='https://noop.invalid'
export TASKCLUSTER_PROXY_URL
export TASKCLUSTER_ROOT_URL

# Node.js
## https://nodejs.org/api/cli.html#environment-variables-1

## Disable compile cache
### https://nodejs.org/api/cli.html#node-disable-compile-cache1
NODE_DISABLE_COMPILE_CACHE=1
export NODE_DISABLE_COMPILE_CACHE

## Disable the system CA root store
### https://nodejs.org/api/cli.html#node-use-system-ca1
NODE_USE_SYSTEM_CA=0
export NODE_USE_SYSTEM_CA

## Do not attempt to use a system proxy
### https://nodejs.org/api/cli.html#node-use-env-proxy1
NODE_USE_ENV_PROXY=0
export NODE_USE_ENV_PROXY

## Enforce certificate validation
### https://nodejs.org/api/cli.html#node-tls-reject-unauthorizedvalue
NODE_TLS_REJECT_UNAUTHORIZED=1
export NODE_TLS_REJECT_UNAUTHORIZED

## Ensure npm always installs production/release modules
NODE_ENV='production'
export NODE_ENV

## Node options
NODE_OPTIONS="${IRONFOX_NODE_OPTIONS}"
npm_config_node_options="${IRONFOX_NODE_OPTIONS}"
export NODE_OPTIONS
export npm_config_node_options

# npm

## Always use our npm config file
## https://docs.npmjs.com/cli/v11/using-npm/config#npmrc-files
NPM_CONFIG_GLOBALCONFIG="${IRONFOX_CONFIGS}/npm/.npmrc"
npm_config_globalconfig="${IRONFOX_CONFIGS}/npm/.npmrc"
export NPM_CONFIG_GLOBALCONFIG
export npm_config_globalconfig

### Always install dependencies properly
npm_config_install_links='true'
export npm_config_install_links

### Disable "funding" nags
npm_config_fund='false'
export npm_config_fund

### Disable submission of audit reports
npm_config_audit='false'
export npm_config_audit

### Enable verbose logging
npm_config_loglevel='verbose'
export npm_config_loglevel

### Enforce SSL key validation
npm_config_strict_ssl='true'
export npm_config_strict_ssl

### Write exact versions to package.json/package_lock.json
npm_config_save_exact='true'
export npm_config_save_exact

### Set cache directory
npm_config_cache="${IRONFOX_NPM_CACHE}"
export npm_config_cache

# NSS
NSS_DIR="${IRONFOX_NSS_DIR}"
NSS_STATIC=1
export NSS_DIR
export NSS_STATIC

# nvm
NVM_DIR="${IRONFOX_NVM}"
export NVM_DIR

## This is necessary to prevent nvm from automatically trying to modify the system PATH
PROFILE='/dev/null'
export PROFILE

# Phoenix
PHOENIX_ANDROID_ONLY=1
PHOENIX_AWK="${IRONFOX_AWK}"
PHOENIX_CIPHERS="${IRONFOX_CIPHERS}"
PHOENIX_CURL_FLAGS="${IRONFOX_CURL_FLAGS}"
PHOENIX_CURL_FLAGS_OVERRIDE=1
PHOENIX_EXTENDED_ONLY=1
PHOENIX_EXTRA_CFG=1
PHOENIX_EXTRA_CFG_FILE="${IRONFOX_BUILD}/tmp/gecko/ironfox-parsed.cfg"
PHOENIX_EXTRA_CFG_OUTPUT_DIR="${IRONFOX_GECKO}/ironfox/prefs"
PHOENIX_EXTRA_EXTENDED_OUTPUT_FILENAME_ANDROID='ironfox'
PHOENIX_EXTRA_POLICIES_ANDROID=1
PHOENIX_EXTRA_POLICIES_FILE_ANDROID="${IRONFOX_PATCHES}/build/gecko/policies.json"
PHOENIX_EXTRA_POLICIES_OUTPUT_DIR_ANDROID="${IRONFOX_GECKO}/ironfox/prefs"
PHOENIX_PYENV_DIR="${IRONFOX_PYENV_DIR}"
PHOENIX_PYTHON="${IRONFOX_PYTHON}"
PHOENIX_PYTHON_DIR="${IRONFOX_PYTHON_DIR}"
PHOENIX_SED="${IRONFOX_SED}"
PHOENIX_SPECS=0
PHOENIX_TAR="${IRONFOX_TAR}"
PHOENIX_UV_CACHE="${IRONFOX_UV_CACHE}"
PHOENIX_UV_DIR="${IRONFOX_UV_DIR}"
PHOENIX_UV_LOCAL="${IRONFOX_UV_LOCAL}"
PHOENIX_UV_PYTHON="${IRONFOX_UV_PYTHON}"
PHOENIX_UV_TOOLS="${IRONFOX_UV_TOOLS}"
export PHOENIX_ANDROID_ONLY
export PHOENIX_AWK
export PHOENIX_CIPHERS
export PHOENIX_CURL_FLAGS
export PHOENIX_CURL_FLAGS_OVERRIDE
export PHOENIX_EXTENDED_ONLY
export PHOENIX_EXTRA_CFG
export PHOENIX_EXTRA_CFG_FILE
export PHOENIX_EXTRA_CFG_OUTPUT_DIR
export PHOENIX_EXTRA_EXTENDED_OUTPUT_FILENAME_ANDROID
export PHOENIX_EXTRA_POLICIES_ANDROID
export PHOENIX_EXTRA_POLICIES_FILE_ANDROID
export PHOENIX_EXTRA_POLICIES_OUTPUT_DIR_ANDROID
export PHOENIX_PYENV_DIR
export PHOENIX_PYTHON
export PHOENIX_PYTHON_DIR
export PHOENIX_SED
export PHOENIX_SPECS
export PHOENIX_TAR
export PHOENIX_UV_CACHE
export PHOENIX_UV_DIR
export PHOENIX_UV_LOCAL
export PHOENIX_UV_PYTHON
export PHOENIX_UV_TOOLS

# Python
## https://docs.python.org/3/using/cmdline.html#environment-variables

## Disable JIT
PYTHON_JIT=0
PYTHON_PERF_JIT_SUPPORT=0
export PYTHON_JIT
export PYTHON_PERF_JIT_SUPPORT

## Disable remote debugging
PYTHON_DISABLE_REMOTE_DEBUG=1
export PYTHON_DISABLE_REMOTE_DEBUG

## Enable performance optimizations
PYTHONOPTIMIZE=1
export PYTHONOPTIMIZE

# Python (Glean)
GLEAN_PYTHON="${IRONFOX_PYTHON}"
GLEAN_PYTHON_WHEELS_DIR="${IRONFOX_GLEAN_PARSER_WHEELS}"
export GLEAN_PYTHON
export GLEAN_PYTHON_WHEELS_DIR

# Rust (cargo)
CARGO="${IRONFOX_CARGO}"
CARGO_HOME="${IRONFOX_CARGO_HOME}"
CARGO_INSTALL_ROOT="${IRONFOX_CARGO_HOME}"
RUSTC="${IRONFOX_RUSTC}"
RUSTDOC="${IRONFOX_RUSTDOC}"
export CARGO
export CARGO_HOME
export CARGO_INSTALL_ROOT
export RUSTC
export RUSTDOC

## Cipher suites
RUSTUP_TLS_CIPHERSUITES="${IRONFOX_CIPHERS}"
export RUSTUP_TLS_CIPHERSUITES

## Disable debug
CARGO_PROFILE_DEV_DEBUG='false'
CARGO_PROFILE_DEV_DEBUG_ASSERTIONS='false'
CARGO_PROFILE_RELEASE_DEBUG='false'
CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS='false'
export CARGO_PROFILE_DEV_DEBUG
export CARGO_PROFILE_DEV_DEBUG_ASSERTIONS
export CARGO_PROFILE_RELEASE_DEBUG
export CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS

## Disable HTTP debugging
CARGO_HTTP_DEBUG='false'
export CARGO_HTTP_DEBUG

## Disable incremental compilation
### (Ensures builds are fresh)
### https://doc.rust-lang.org/cargo/reference/profiles.html#incremental
CARGO_BUILD_INCREMENTAL='false'
CARGO_INCREMENTAL=0
export CARGO_BUILD_INCREMENTAL
export CARGO_INCREMENTAL

## Display progress bars
CARGO_TERM_PROGRESS_WHEN="${IRONFOX_CARGO_PROGRESS_BAR}"
CARGO_TERM_PROGRESS_WIDTH=80
export CARGO_TERM_PROGRESS_WHEN
export CARGO_TERM_PROGRESS_WIDTH

## Enable certificate revocation checks
CARGO_HTTP_CHECK_REVOKE='true'
export CARGO_HTTP_CHECK_REVOKE

## Enable colored output
CARGO_TERM_COLOR="${IRONFOX_CARGO_COLORED_OUTPUT}"
export CARGO_TERM_COLOR

## Enable overflow checks
CARGO_PROFILE_DEV_OVERFLOW_CHECKS='true'
CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS='true'
export CARGO_PROFILE_DEV_OVERFLOW_CHECKS
export CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS

## Enable performance optimizations
CARGO_PROFILE_DEV_LTO='true'
CARGO_PROFILE_DEV_OPT_LEVEL=3
CARGO_PROFILE_RELEASE_LTO='true'
CARGO_PROFILE_RELEASE_OPT_LEVEL=3
export CARGO_PROFILE_DEV_LTO
export CARGO_PROFILE_DEV_OPT_LEVEL
export CARGO_PROFILE_RELEASE_LTO
export CARGO_PROFILE_RELEASE_OPT_LEVEL

## Strip debug info
CARGO_PROFILE_DEV_STRIP='debuginfo'
CARGO_PROFILE_RELEASE_STRIP='debuginfo'
export CARGO_PROFILE_DEV_STRIP
export CARGO_PROFILE_RELEASE_STRIP

# rustup
RUSTUP_HOME="${IRONFOX_RUSTUP_HOME}"
export RUSTUP_HOME

## Display progress bars
RUSTUP_TERM_PROGRESS_WHEN="${IRONFOX_RUSTUP_PROGRESS_BAR}"
export RUSTUP_TERM_PROGRESS_WHEN

## Enable colored output
RUSTUP_TERM_COLOR="${IRONFOX_RUSTUP_COLORED_OUTPUT}"
export RUSTUP_TERM_COLOR

# UnifiedPush-AC
UP_AC_GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"
export UP_AC_GRADLE_USER_HOME

# UV
## https://docs.astral.sh/uv/reference/environment/

## Cache directory
UV_CACHE_DIR="${IRONFOX_UV_LOCAL}/cache"
export UV_CACHE_DIR

## Disable cache
UV_NO_CACHE=1
export UV_NO_CACHE

## Disable the system CA root store
UV_SYSTEM_CERTS='false'
export UV_SYSTEM_CERTS

## Exclude development dependencies
UV_NO_DEV=1
export UV_NO_DEV

## Executables directory
UV_PYTHON_BIN_DIR="${IRONFOX_UV_LOCAL}/bin"
UV_PYTHON_INSTALL_BIN=1
export UV_PYTHON_BIN_DIR
export UV_PYTHON_INSTALL_BIN

## Ignore configuration files
UV_NO_CONFIG=1
export UV_NO_CONFIG

## Ignore env files
UV_NO_ENV_FILE=1
export UV_NO_ENV_FILE

## Location
UV_INSTALL_DIR="${IRONFOX_UV_DIR}"
export UV_INSTALL_DIR

## Prevent automatic downloads/updates
UV_DISABLE_UPDATE=1
UV_PYTHON_DOWNLOADS='manual'
export UV_DISABLE_UPDATE
export UV_PYTHON_DOWNLOADS

## Prevent modifying the system PATH
INSTALLER_NO_MODIFY_PATH=1
UV_NO_MODIFY_PATH=1
UV_UNMANAGED_INSTALL="${IRONFOX_UV_DIR}"
export INSTALLER_NO_MODIFY_PATH
export UV_NO_MODIFY_PATH
export UV_UNMANAGED_INSTALL

## Prevent using the system Python
UV_MANAGED_PYTHON=1
UV_SYSTEM_PYTHON='false'
export UV_MANAGED_PYTHON
export UV_SYSTEM_PYTHON

## Python
UV_PYTHON_CACHE_DIR="${IRONFOX_UV_LOCAL}/python-cache"
UV_PYTHON_INSTALL_MIRROR="file://${IRONFOX_PYTHON_DIR}"
UV_PYTHON_INSTALL_DIR="${IRONFOX_UV_LOCAL}/python"
export UV_PYTHON_CACHE_DIR
export UV_PYTHON_INSTALL_MIRROR
export UV_PYTHON_INSTALL_DIR

## Python environment
UV_PROJECT_ENVIRONMENT="${IRONFOX_PYENV_DIR}"
VIRTUAL_ENV="${IRONFOX_PYENV_DIR}"
export UV_PROJECT_ENVIRONMENT
export VIRTUAL_ENV

## Tools directory
UV_TOOL_BIN_DIR="${IRONFOX_UV_LOCAL}/tools/bin"
UV_TOOL_DIR="${IRONFOX_UV_LOCAL}/tools"
export UV_TOOL_BIN_DIR
export UV_TOOL_DIR

## Pin Python version
UV_PYTHON_CPYTHON_BUILD="${PYTHON_GIT_RELEASE}"
export UV_PYTHON_CPYTHON_BUILD

## Set Node.js bin path
NVM_BIN="${IRONFOX_NVM}/versions/node/v${NODE_VERSION}/bin"
export NVM_BIN

## Set Node.js version
export NODE_VERSION

## Set Rust version
RUSTUP_TOOLCHAIN="${RUST_VERSION}"
export RUSTUP_TOOLCHAIN

## Set Rustup version
export RUSTUP_VERSION
