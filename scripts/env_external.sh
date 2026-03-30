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
## https://developer.android.com/tools/variables
export ANDROID_HOME="${IRONFOX_ANDROID_SDK}"
export ANDROID_SDK_ROOT="${IRONFOX_ANDROID_SDK}"

## Android SDK preferences
export ANDROID_USER_HOME="${IRONFOX_BUILD}/.android"

# Android NDK
export ANDROID_NDK_HOME="${IRONFOX_ANDROID_NDK}"
export ANDROID_NDK_ROOT="${IRONFOX_ANDROID_NDK}"

# Gradle cache
export CACHEDIR="${IRONFOX_GRADLE_CACHE}"

# Gradle home
export GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"

# IronFox prebuilds
export IRONFOX_PREBUILDS_AWK="${IRONFOX_AWK}"
export IRONFOX_PREBUILDS_CARGO_COLORED_OUTPUT="${IRONFOX_CARGO_COLORED_OUTPUT}"
export IRONFOX_PREBUILDS_CARGO_PROGRESS_BAR="${IRONFOX_CARGO_PROGRESS_BAR}"
export IRONFOX_PREBUILDS_CURL_FLAGS_OVERRIDE=1
export IRONFOX_PREBUILDS_CURL_FLAGS="${IRONFOX_CURL_FLAGS}"
export IRONFOX_PREBUILDS_MAKE="${IRONFOX_MAKE}"
export IRONFOX_PREBUILDS_NPROC="${IRONFOX_NPROC}"
export IRONFOX_PREBUILDS_RUSTUP_COLORED_OUTPUT="${IRONFOX_RUSTUP_COLORED_OUTPUT}"
export IRONFOX_PREBUILDS_RUSTUP_PROGRESS_BAR="${IRONFOX_RUSTUP_PROGRESS_BAR}"
export IRONFOX_PREBUILDS_SED="${IRONFOX_SED}"
export IRONFOX_PREBUILDS_TAR="${IRONFOX_TAR}"

# Java home
export JAVA_HOME="${IRONFOX_JAVA_HOME}"

# llvm-profdata
export LLVM_PROFDATA="${IRONFOX_LLVM_PROFDATA}"

# Mach
## https://firefox-source-docs.mozilla.org/mach/usage.html#user-settings
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#95
## https://searchfox.org/mozilla-central/rev/f008b9aa/python/mach/mach/telemetry.py#284
export DISABLE_TELEMETRY=1
export MACHRC="${IRONFOX_CONFIGS}/mach/machrc"
export MOZCONFIG="${IRONFOX_MOZCONFIGS}/ironfox.mozconfig"

# microG
export GRADLE_MICROG_VERSION_WITHOUT_GIT=1

# mozbuild
export MOZBUILD_STATE_PATH="${IRONFOX_MOZBUILD}"

# No-op Taskcluster
## This should help ensure we don't fetch Mozilla artifacts/prebuilds
export TASKCLUSTER_PROXY_URL='https://noop.invalid'
export TASKCLUSTER_ROOT_URL='https://noop.invalid'

# Node.js
## https://nodejs.org/api/cli.html#environment-variables-1

## Disable compile cache
### https://nodejs.org/api/cli.html#node-disable-compile-cache1
export NODE_DISABLE_COMPILE_CACHE=1

## Disable the system CA root store
### https://nodejs.org/api/cli.html#node-use-system-ca1
export NODE_USE_SYSTEM_CA=0

## Do not attempt to use a system proxy
### https://nodejs.org/api/cli.html#node-use-env-proxy1
export NODE_USE_ENV_PROXY=0

## Enforce certificate validation
### https://nodejs.org/api/cli.html#node-tls-reject-unauthorizedvalue
export NODE_TLS_REJECT_UNAUTHORIZED=1

## Ensure npm always installs production/release modules
export NODE_ENV='production'

## Node options
export NODE_OPTIONS="${IRONFOX_NODE_OPTIONS}"
export npm_config_node_options="${IRONFOX_NODE_OPTIONS}"

# npm

## Always use our npm config file
## https://docs.npmjs.com/cli/v11/using-npm/config#npmrc-files
export NPM_CONFIG_GLOBALCONFIG="${IRONFOX_CONFIGS}/npm/.npmrc"
export npm_config_globalconfig="${IRONFOX_CONFIGS}/npm/.npmrc"

### Always install dependencies properly
export npm_config_install_links='true'

### Disable "funding" nags
export npm_config_fund='false'

### Disable submission of audit reports
export npm_config_audit='false'

### Enable verbose logging
export npm_config_loglevel='verbose'

### Enforce SSL key validation
export npm_config_strict_ssl='true'

### Write exact versions to package.json/package_lock.json
export npm_config_save_exact='true'

### Set cache directory
export npm_config_cache="${IRONFOX_NPM_CACHE}"

# NSS
export NSS_DIR="${IRONFOX_NSS_DIR}"
export NSS_STATIC=1

# nvm
export NVM_DIR="${IRONFOX_NVM}"

## This is necessary to prevent nvm from automatically trying to modify the system PATH
export PROFILE='/dev/null'

# Phoenix
export PHOENIX_ANDROID_ONLY=1
export PHOENIX_AWK="${IRONFOX_AWK}"
export PHOENIX_CURL_FLAGS="${IRONFOX_CURL_FLAGS}"
export PHOENIX_CURL_FLAGS_OVERRIDE=1
export PHOENIX_EXTENDED_ONLY=1
export PHOENIX_EXTRA_CFG=1
export PHOENIX_EXTRA_CFG_FILE="${IRONFOX_BUILD}/tmp/gecko/ironfox-parsed.cfg"
export PHOENIX_EXTRA_CFG_OUTPUT_DIR="${IRONFOX_GECKO}/ironfox/prefs"
export PHOENIX_EXTRA_EXTENDED_OUTPUT_FILENAME_ANDROID='ironfox'
export PHOENIX_EXTRA_POLICIES_ANDROID=1
export PHOENIX_EXTRA_POLICIES_FILE_ANDROID="${IRONFOX_PATCHES}/build/gecko/policies.json"
export PHOENIX_EXTRA_POLICIES_OUTPUT_DIR_ANDROID="${IRONFOX_GECKO}/ironfox/prefs"
export PHOENIX_PYENV_DIR="${IRONFOX_PYENV_DIR}"
export PHOENIX_PYTHON="${IRONFOX_PYTHON}"
export PHOENIX_PYTHON_DIR="${IRONFOX_PYTHON_DIR}"
export PHOENIX_SED="${IRONFOX_SED}"
export PHOENIX_TAR="${IRONFOX_TAR}"
export PHOENIX_UV_CACHE="${IRONFOX_UV_CACHE}"
export PHOENIX_UV_DIR="${IRONFOX_UV_DIR}"
export PHOENIX_UV_LOCAL="${IRONFOX_UV_LOCAL}"
export PHOENIX_UV_PYTHON="${IRONFOX_UV_PYTHON}"
export PHOENIX_UV_TOOLS="${IRONFOX_UV_TOOLS}"
export PHOENIX_SPECS=0

# Python
## https://docs.python.org/3/using/cmdline.html#environment-variables

## Disable JIT
export PYTHON_JIT=0
export PYTHON_PERF_JIT_SUPPORT=0

## Disable remote debugging
export PYTHON_DISABLE_REMOTE_DEBUG=1

## Enable performance optimizations
export PYTHONOPTIMIZE=1

# Python (Glean)
export GLEAN_PYTHON="${IRONFOX_PYTHON}"
export GLEAN_PYTHON_WHEELS_DIR="${IRONFOX_GLEAN_PARSER_WHEELS}"

# Rust (cargo)
export CARGO="${IRONFOX_CARGO}"
export CARGO_HOME="${IRONFOX_CARGO_HOME}"
export CARGO_INSTALL_ROOT="${IRONFOX_CARGO_HOME}"
export RUSTC="${IRONFOX_RUSTC}"
export RUSTDOC="${IRONFOX_RUSTDOC}"

## Disable debug
export CARGO_PROFILE_DEV_DEBUG='false'
export CARGO_PROFILE_DEV_DEBUG_ASSERTIONS='false'
export CARGO_PROFILE_RELEASE_DEBUG='false'
export CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS='false'

## Disable HTTP debugging
export CARGO_HTTP_DEBUG='false'

## Disable incremental compilation
### (Ensures builds are fresh)
### https://doc.rust-lang.org/cargo/reference/profiles.html#incremental
export CARGO_BUILD_INCREMENTAL='false'
export CARGO_INCREMENTAL=0

## Display progress bars
export CARGO_TERM_PROGRESS_WHEN="${IRONFOX_CARGO_PROGRESS_BAR}"
export CARGO_TERM_PROGRESS_WIDTH=80

## Enable certificate revocation checks
export CARGO_HTTP_CHECK_REVOKE='true'

## Enable colored output
export CARGO_TERM_COLOR="${IRONFOX_CARGO_COLORED_OUTPUT}"

## Enable overflow checks
export CARGO_PROFILE_DEV_OVERFLOW_CHECKS='true'
export CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS='true'

## Enable performance optimizations
export CARGO_PROFILE_DEV_LTO='true'
export CARGO_PROFILE_DEV_OPT_LEVEL=3
export CARGO_PROFILE_RELEASE_LTO='true'
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

# UnifiedPush-AC
export UP_AC_GRADLE_USER_HOME="${IRONFOX_GRADLE_HOME}"

# UV
## https://docs.astral.sh/uv/reference/environment/

## Cache directory
export UV_CACHE_DIR="${IRONFOX_UV_LOCAL}/cache"

## Disable cache
export UV_NO_CACHE=1

## Disable the system CA root store
export UV_SYSTEM_CERTS='false'

## Exclude development dependencies
export UV_NO_DEV=1

## Executables directory
export UV_PYTHON_BIN_DIR="${IRONFOX_UV_LOCAL}/bin"
export UV_PYTHON_INSTALL_BIN=1

## Ignore configuration files
export UV_NO_CONFIG=1

## Ignore env files
export UV_NO_ENV_FILE=1

## Location
export UV_INSTALL_DIR="${IRONFOX_UV_DIR}"

## Prevent automatic downloads/updates
export UV_DISABLE_UPDATE=1
export UV_PYTHON_DOWNLOADS='manual'

## Prevent modifying the system PATH
export INSTALLER_NO_MODIFY_PATH=1
export UV_NO_MODIFY_PATH=1
export UV_UNMANAGED_INSTALL="${IRONFOX_UV_DIR}"

## Prevent using the system Python
export UV_MANAGED_PYTHON=1
export UV_SYSTEM_PYTHON='false'

## Python
export UV_PYTHON_CACHE_DIR="${IRONFOX_UV_LOCAL}/python-cache"
export UV_PYTHON_INSTALL_MIRROR="file://${IRONFOX_PYTHON_DIR}"
export UV_PYTHON_INSTALL_DIR="${IRONFOX_UV_LOCAL}/python"

## Python environment
export UV_PROJECT_ENVIRONMENT="${IRONFOX_PYENV_DIR}"
export VIRTUAL_ENV="${IRONFOX_PYENV_DIR}"

## Tools directory
export UV_TOOL_BIN_DIR="${IRONFOX_UV_LOCAL}/tools/bin"
export UV_TOOL_DIR="${IRONFOX_UV_LOCAL}/tools"

# Include version info
source "${IRONFOX_VERSIONS}"

## Pin Python version
export UV_PYTHON_CPYTHON_BUILD="${PYTHON_GIT_RELEASE}"

## Set Node.js bin path
export NVM_BIN="${IRONFOX_NVM}/versions/node/v${NODE_VERSION}/bin"

## Set Node.js version
export NODE_VERSION="${NODE_VERSION}"

## Set Rust version
export RUSTUP_TOOLCHAIN="${RUST_VERSION}"

## Set Rustup version
export RUSTUP_VERSION="${RUSTUP_VERSION}"
