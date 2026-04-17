# IronFox external environment variables

## This is used for converting IronFox-specific environment variables to ones used in external projects.

## CAUTION: Do NOT source this directly!
## Source 'env.sh' instead.

## CAUTION: Do NOT try to configure any of these environment variables directly!
## Use the IronFox equivalent variables (at `env_common.sh`) instead.

# Compiler flags
readonly TARGET_CFLAGS="${IRONFOX_COMPILER_FLAGS}"
readonly TARGET_CXXFLAGS="${IRONFOX_COMPILER_FLAGS}"
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
readonly ANDROID_HOME="${IRONFOX_ANDROID_SDK}"
readonly ANDROID_SDK_ROOT="${IRONFOX_ANDROID_SDK}"
export ANDROID_HOME
export ANDROID_SDK_ROOT

## Android SDK preferences
readonly ANDROID_USER_HOME="${IRONFOX_BUILD}/.android"
export ANDROID_USER_HOME

# Android NDK
readonly ANDROID_NDK_HOME="${IRONFOX_ANDROID_NDK}"
readonly ANDROID_NDK_ROOT="${IRONFOX_ANDROID_NDK}"
export ANDROID_NDK_HOME
export ANDROID_NDK_ROOT

# Gradle cache
readonly CACHEDIR="${IRONFOX_GRADLE_CACHE}"
export CACHEDIR

# Gradle home
readonly GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"
export GRADLE_USER_HOME

# IronFox prebuilds
readonly IRONFOX_PREBUILDS_AWK="${IRONFOX_AWK}"
readonly IRONFOX_PREBUILDS_CARGO_COLORED_OUTPUT="${IRONFOX_CARGO_COLORED_OUTPUT}"
readonly IRONFOX_PREBUILDS_CARGO_PROGRESS_BAR="${IRONFOX_CARGO_PROGRESS_BAR}"
readonly IRONFOX_PREBUILDS_CIPHERS="${IRONFOX_CIPHERS}"
readonly IRONFOX_PREBUILDS_CURL_FLAGS_OVERRIDE=1
readonly IRONFOX_PREBUILDS_CURL_FLAGS="${IRONFOX_CURL_FLAGS}"
readonly IRONFOX_PREBUILDS_MAKE="${IRONFOX_MAKE}"
readonly IRONFOX_PREBUILDS_NPROC="${IRONFOX_NPROC}"
readonly IRONFOX_PREBUILDS_RUSTUP_COLORED_OUTPUT="${IRONFOX_RUSTUP_COLORED_OUTPUT}"
readonly IRONFOX_PREBUILDS_RUSTUP_PROGRESS_BAR="${IRONFOX_RUSTUP_PROGRESS_BAR}"
readonly IRONFOX_PREBUILDS_SED="${IRONFOX_SED}"
readonly IRONFOX_PREBUILDS_TAR="${IRONFOX_TAR}"
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
readonly GRADLE_OPTS="${IRONFOX_JAVA_OPTS}"
readonly JAVA_OPTS="${IRONFOX_JAVA_OPTS}"
readonly JAVA_TOOL_OPTIONS="${IRONFOX_JAVA_OPTS}"
readonly JDK_JAVA_OPTIONS="${IRONFOX_JAVA_OPTS}"
export GRADLE_OPTS
export JAVA_OPTS
export JAVA_TOOL_OPTIONS
export JDK_JAVA_OPTIONS

# llvm-profdata
readonly LLVM_PROFDATA="${IRONFOX_LLVM_PROFDATA}"
export LLVM_PROFDATA

# Mach
## https://firefox-source-docs.mozilla.org/mach/usage.html#user-settings
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#95
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#284
readonly DISABLE_TELEMETRY=1
readonly MACHRC="${IRONFOX_CONFIGS}/mach/machrc"
readonly MOZCONFIG="${IRONFOX_MOZCONFIGS}/ironfox.mozconfig"
export DISABLE_TELEMETRY
export MACHRC
export MOZCONFIG

# microG
readonly GRADLE_MICROG_VERSION_WITHOUT_GIT=1
export GRADLE_MICROG_VERSION_WITHOUT_GIT

# mozbuild
readonly MOZBUILD_STATE_PATH="${IRONFOX_MOZBUILD}"
export MOZBUILD_STATE_PATH

# No-op Taskcluster
## This should help ensure we don't fetch Mozilla artifacts/prebuilds
readonly TASKCLUSTER_PROXY_URL='https://noop.invalid'
readonly TASKCLUSTER_ROOT_URL='https://noop.invalid'
export TASKCLUSTER_PROXY_URL
export TASKCLUSTER_ROOT_URL

# Node.js
## https://nodejs.org/api/cli.html#environment-variables-1

## Disable compile cache
### https://nodejs.org/api/cli.html#node-disable-compile-cache1
readonly NODE_DISABLE_COMPILE_CACHE=1
export NODE_DISABLE_COMPILE_CACHE

## Disable the system CA root store
### https://nodejs.org/api/cli.html#node-use-system-ca1
readonly NODE_USE_SYSTEM_CA=0
export NODE_USE_SYSTEM_CA

## Do not attempt to use a system proxy
### https://nodejs.org/api/cli.html#node-use-env-proxy1
readonly NODE_USE_ENV_PROXY=0
export NODE_USE_ENV_PROXY

## Enforce certificate validation
### https://nodejs.org/api/cli.html#node-tls-reject-unauthorizedvalue
readonly NODE_TLS_REJECT_UNAUTHORIZED=1
export NODE_TLS_REJECT_UNAUTHORIZED

## Ensure npm always installs production/release modules
readonly NODE_ENV='production'
export NODE_ENV

## Node options
readonly NODE_OPTIONS="${IRONFOX_NODE_OPTIONS}"
readonly npm_config_node_options="${IRONFOX_NODE_OPTIONS}"
export NODE_OPTIONS
export npm_config_node_options

# npm

## Always use our npm config file
## https://docs.npmjs.com/cli/v11/using-npm/config#npmrc-files
readonly NPM_CONFIG_GLOBALCONFIG="${IRONFOX_CONFIGS}/npm/.npmrc"
readonly npm_config_globalconfig="${IRONFOX_CONFIGS}/npm/.npmrc"
export NPM_CONFIG_GLOBALCONFIG
export npm_config_globalconfig

### Always install dependencies properly
readonly npm_config_install_links='true'
export npm_config_install_links

### Disable "funding" nags
readonly npm_config_fund='false'
export npm_config_fund

### Disable submission of audit reports
readonly npm_config_audit='false'
export npm_config_audit

### Enable verbose logging
readonly npm_config_loglevel='verbose'
export npm_config_loglevel

### Enforce SSL key validation
readonly npm_config_strict_ssl='true'
export npm_config_strict_ssl

### Write exact versions to package.json/package_lock.json
readonly npm_config_save_exact='true'
export npm_config_save_exact

### Set cache directory
readonly npm_config_cache="${IRONFOX_NPM_CACHE}"
export npm_config_cache

# NSS
readonly NSS_DIR="${IRONFOX_NSS_DIR}"
readonly NSS_STATIC=1
export NSS_DIR
export NSS_STATIC

# nvm
readonly NVM_DIR="${IRONFOX_NVM}"
export NVM_DIR

## This is necessary to prevent nvm from automatically trying to modify the system PATH
readonly PROFILE='/dev/null'
export PROFILE

# Phoenix
readonly PHOENIX_ANDROID_ONLY=1
readonly PHOENIX_AWK="${IRONFOX_AWK}"
readonly PHOENIX_CIPHERS="${IRONFOX_CIPHERS}"
readonly PHOENIX_CURL_FLAGS="${IRONFOX_CURL_FLAGS}"
readonly PHOENIX_CURL_FLAGS_OVERRIDE=1
readonly PHOENIX_EXTENDED_ONLY=1
readonly PHOENIX_EXTRA_CFG=1
readonly PHOENIX_EXTRA_CFG_FILE="${IRONFOX_BUILD}/tmp/gecko/ironfox-parsed.cfg"
readonly PHOENIX_EXTRA_CFG_OUTPUT_DIR="${IRONFOX_GECKO}/ironfox/prefs"
readonly PHOENIX_EXTRA_EXTENDED_OUTPUT_FILENAME_ANDROID='ironfox'
readonly PHOENIX_EXTRA_POLICIES_ANDROID=1
readonly PHOENIX_EXTRA_POLICIES_FILE_ANDROID="${IRONFOX_TEMPLATES}/gecko/policies.json"
readonly PHOENIX_EXTRA_POLICIES_OUTPUT_DIR_ANDROID="${IRONFOX_GECKO}/ironfox/prefs"
readonly PHOENIX_PYENV_DIR="${IRONFOX_PYENV_DIR}"
readonly PHOENIX_PYTHON="${IRONFOX_PYTHON}"
readonly PHOENIX_PYTHON_DIR="${IRONFOX_PYTHON_DIR}"
readonly PHOENIX_SED="${IRONFOX_SED}"
readonly PHOENIX_SPECS=0
readonly PHOENIX_TAR="${IRONFOX_TAR}"
readonly PHOENIX_UV_CACHE="${IRONFOX_UV_CACHE}"
readonly PHOENIX_UV_DIR="${IRONFOX_UV_DIR}"
readonly PHOENIX_UV_LOCAL="${IRONFOX_UV_LOCAL}"
readonly PHOENIX_UV_PYTHON="${IRONFOX_UV_PYTHON}"
readonly PHOENIX_UV_TOOLS="${IRONFOX_UV_TOOLS}"
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
readonly PYTHON_JIT=0
readonly PYTHON_PERF_JIT_SUPPORT=0
export PYTHON_JIT
export PYTHON_PERF_JIT_SUPPORT

## Disable remote debugging
readonly PYTHON_DISABLE_REMOTE_DEBUG=1
export PYTHON_DISABLE_REMOTE_DEBUG

## Enable performance optimizations
readonly PYTHONOPTIMIZE=1
export PYTHONOPTIMIZE

# Python (Glean)
readonly GLEAN_PYTHON="${IRONFOX_PYTHON}"
readonly GLEAN_PYTHON_WHEELS_DIR="${IRONFOX_GLEAN_PARSER_WHEELS}"
export GLEAN_PYTHON
export GLEAN_PYTHON_WHEELS_DIR

# Rust (cargo)
readonly CARGO="${IRONFOX_CARGO}"
readonly CARGO_HOME="${IRONFOX_CARGO_HOME}"
readonly CARGO_INSTALL_ROOT="${IRONFOX_CARGO_HOME}"
readonly RUSTC="${IRONFOX_RUSTC}"
readonly RUSTDOC="${IRONFOX_RUSTDOC}"
export CARGO
export CARGO_HOME
export CARGO_INSTALL_ROOT
export RUSTC
export RUSTDOC

## Cipher suites
readonly RUSTUP_TLS_CIPHERSUITES="${IRONFOX_CIPHERS}"
export RUSTUP_TLS_CIPHERSUITES

## Disable debug
readonly CARGO_PROFILE_DEV_DEBUG='false'
readonly CARGO_PROFILE_DEV_DEBUG_ASSERTIONS='false'
readonly CARGO_PROFILE_RELEASE_DEBUG='false'
readonly CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS='false'
export CARGO_PROFILE_DEV_DEBUG
export CARGO_PROFILE_DEV_DEBUG_ASSERTIONS
export CARGO_PROFILE_RELEASE_DEBUG
export CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS

## Disable HTTP debugging
readonly CARGO_HTTP_DEBUG='false'
export CARGO_HTTP_DEBUG

## Disable incremental compilation
### (Ensures builds are fresh)
### https://doc.rust-lang.org/cargo/reference/profiles.html#incremental
readonly CARGO_BUILD_INCREMENTAL='false'
readonly CARGO_INCREMENTAL=0
export CARGO_BUILD_INCREMENTAL
export CARGO_INCREMENTAL

## Display progress bars
readonly CARGO_TERM_PROGRESS_WHEN="${IRONFOX_CARGO_PROGRESS_BAR}"
readonly CARGO_TERM_PROGRESS_WIDTH=80
export CARGO_TERM_PROGRESS_WHEN
export CARGO_TERM_PROGRESS_WIDTH

## Enable certificate revocation checks
readonly CARGO_HTTP_CHECK_REVOKE='true'
export CARGO_HTTP_CHECK_REVOKE

## Enable colored output
readonly CARGO_TERM_COLOR="${IRONFOX_CARGO_COLORED_OUTPUT}"
export CARGO_TERM_COLOR

## Enable overflow checks
readonly CARGO_PROFILE_DEV_OVERFLOW_CHECKS='true'
readonly CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS='true'
export CARGO_PROFILE_DEV_OVERFLOW_CHECKS
export CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS

## Enable performance optimizations
readonly CARGO_PROFILE_DEV_LTO='true'
readonly CARGO_PROFILE_DEV_OPT_LEVEL=3
readonly CARGO_PROFILE_RELEASE_LTO='true'
readonly CARGO_PROFILE_RELEASE_OPT_LEVEL=3
export CARGO_PROFILE_DEV_LTO
export CARGO_PROFILE_DEV_OPT_LEVEL
export CARGO_PROFILE_RELEASE_LTO
export CARGO_PROFILE_RELEASE_OPT_LEVEL

## Strip debug info
readonly CARGO_PROFILE_DEV_STRIP='debuginfo'
readonly CARGO_PROFILE_RELEASE_STRIP='debuginfo'
export CARGO_PROFILE_DEV_STRIP
export CARGO_PROFILE_RELEASE_STRIP

# rustup
readonly RUSTUP_HOME="${IRONFOX_RUSTUP_HOME}"
export RUSTUP_HOME

## Display progress bars
readonly RUSTUP_TERM_PROGRESS_WHEN="${IRONFOX_RUSTUP_PROGRESS_BAR}"
export RUSTUP_TERM_PROGRESS_WHEN

## Enable colored output
readonly RUSTUP_TERM_COLOR="${IRONFOX_RUSTUP_COLORED_OUTPUT}"
export RUSTUP_TERM_COLOR

# UnifiedPush-AC
readonly UP_AC_GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"
export UP_AC_GRADLE_USER_HOME

# UV
## https://docs.astral.sh/uv/reference/environment/

## Cache directory
readonly UV_CACHE_DIR="${IRONFOX_UV_LOCAL}/cache"
export UV_CACHE_DIR

## Disable cache
readonly UV_NO_CACHE=1
export UV_NO_CACHE

## Disable the system CA root store
readonly UV_SYSTEM_CERTS='false'
export UV_SYSTEM_CERTS

## Exclude development dependencies
readonly UV_NO_DEV=1
export UV_NO_DEV

## Executables directory
readonly UV_PYTHON_BIN_DIR="${IRONFOX_UV_LOCAL}/bin"
readonly UV_PYTHON_INSTALL_BIN=1
export UV_PYTHON_BIN_DIR
export UV_PYTHON_INSTALL_BIN

## Ignore configuration files
readonly UV_NO_CONFIG=1
export UV_NO_CONFIG

## Ignore env files
readonly UV_NO_ENV_FILE=1
export UV_NO_ENV_FILE

## Location
readonly UV_INSTALL_DIR="${IRONFOX_UV_DIR}"
export UV_INSTALL_DIR

## Prevent automatic downloads/updates
readonly UV_DISABLE_UPDATE=1
readonly UV_PYTHON_DOWNLOADS='manual'
export UV_DISABLE_UPDATE
export UV_PYTHON_DOWNLOADS

## Prevent modifying the system PATH
readonly INSTALLER_NO_MODIFY_PATH=1
readonly UV_NO_MODIFY_PATH=1
readonly UV_UNMANAGED_INSTALL="${IRONFOX_UV_DIR}"
export INSTALLER_NO_MODIFY_PATH
export UV_NO_MODIFY_PATH
export UV_UNMANAGED_INSTALL

## Prevent using the system Python
readonly UV_MANAGED_PYTHON=1
readonly UV_SYSTEM_PYTHON='false'
export UV_MANAGED_PYTHON
export UV_SYSTEM_PYTHON

## Python
readonly UV_PYTHON_CACHE_DIR="${IRONFOX_UV_LOCAL}/python-cache"
readonly UV_PYTHON_INSTALL_MIRROR="file://${IRONFOX_PYTHON_DIR}"
readonly UV_PYTHON_INSTALL_DIR="${IRONFOX_UV_LOCAL}/python"
export UV_PYTHON_CACHE_DIR
export UV_PYTHON_INSTALL_MIRROR
export UV_PYTHON_INSTALL_DIR

## Python environment
readonly UV_PROJECT_ENVIRONMENT="${IRONFOX_PYENV_DIR}"
readonly VIRTUAL_ENV="${IRONFOX_PYENV_DIR}"
export UV_PROJECT_ENVIRONMENT
export VIRTUAL_ENV

## Tools directory
readonly UV_TOOL_BIN_DIR="${IRONFOX_UV_LOCAL}/tools/bin"
readonly UV_TOOL_DIR="${IRONFOX_UV_LOCAL}/tools"
export UV_TOOL_BIN_DIR
export UV_TOOL_DIR

## Pin Python version
readonly UV_PYTHON_CPYTHON_BUILD="${PYTHON_GIT_RELEASE}"
export UV_PYTHON_CPYTHON_BUILD

## Set Node.js bin path
readonly NVM_BIN="${IRONFOX_NVM}/versions/node/v${NODE_VERSION}/bin"
export NVM_BIN

## Set Node.js version
export NODE_VERSION

## Set Rust version
readonly RUSTUP_TOOLCHAIN="${RUST_VERSION}"
export RUSTUP_TOOLCHAIN

## Set Rustup version
export RUSTUP_VERSION
