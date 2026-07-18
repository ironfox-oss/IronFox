#!/bin/bash

# IronFox environment variables

set -euo pipefail

if [[ ! -f "$(dirname $0)/env_local.sh" ]]; then
  readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  readonly ENV_LOCAL="${ROOT}/scripts/env_local.sh"

  # Write env_local.sh
  echo "Writing ${ENV_LOCAL}..."
  cat > "${ENV_LOCAL}" << EOF
readonly IRONFOX_ROOT="${ROOT}"
export IRONFOX_ROOT

source "\${IRONFOX_ROOT}/scripts/env_common.sh"
EOF
fi

if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
  source "$(dirname $0)/env_local.sh"

  # Set-up our PATH
  "${IRONFOX_RM}" -rf                             "${IRONFOX_PATH}"
  "${IRONFOX_MKDIR}" -p                           "${IRONFOX_PATH}"

  "${IRONFOX_LN}" -sf "${IRONFOX_ADB}"            "${IRONFOX_PATH}/adb"
  "${IRONFOX_LN}" -sf "${IRONFOX_ANDROGUARD}"     "${IRONFOX_PATH}/androguard"
  "${IRONFOX_LN}" -sf "${IRONFOX_APKSIGNER}"      "${IRONFOX_PATH}/apksigner"
  "${IRONFOX_LN}" -sf "${IRONFOX_AR}"             "${IRONFOX_PATH}/ar"
  "${IRONFOX_LN}" -sf "${IRONFOX_AWK}"            "${IRONFOX_PATH}/awk"
  "${IRONFOX_LN}" -sf "${IRONFOX_AWK}"            "${IRONFOX_PATH}/gawk"
  "${IRONFOX_LN}" -sf "${IRONFOX_BASENAME}"       "${IRONFOX_PATH}/basename"
  "${IRONFOX_LN}" -sf "${IRONFOX_BUNDLETOOL}"     "${IRONFOX_PATH}/bundletool"
  "${IRONFOX_LN}" -sf "${IRONFOX_CARGO}"          "${IRONFOX_PATH}/cargo"
  "${IRONFOX_LN}" -sf "${IRONFOX_CAT}"            "${IRONFOX_PATH}/cat"
  "${IRONFOX_LN}" -sf "${IRONFOX_CBINDGEN}"       "${IRONFOX_PATH}/cbindgen"
  "${IRONFOX_LN}" -sf "${IRONFOX_CC}"             "${IRONFOX_PATH}/cc"
  "${IRONFOX_LN}" -sf "${IRONFOX_CHMOD}"          "${IRONFOX_PATH}/chmod"
  "${IRONFOX_LN}" -sf "${IRONFOX_CLANG}"          "${IRONFOX_PATH}/clang"
  "${IRONFOX_LN}" -sf "${IRONFOX_CMAKE}"          "${IRONFOX_PATH}/cmake"
  "${IRONFOX_LN}" -sf "${IRONFOX_CMP}"            "${IRONFOX_PATH}/cmp"
  "${IRONFOX_LN}" -sf "${IRONFOX_CP}"             "${IRONFOX_PATH}/cp"
  "${IRONFOX_LN}" -sf "${IRONFOX_CPLUSPLUS}"      "${IRONFOX_PATH}/c++"
  "${IRONFOX_LN}" -sf "${IRONFOX_CURL}"           "${IRONFOX_PATH}/curl"
  "${IRONFOX_LN}" -sf "${IRONFOX_CUT}"            "${IRONFOX_PATH}/cut"
  "${IRONFOX_LN}" -sf "${IRONFOX_DATE}"           "${IRONFOX_PATH}/date"
  "${IRONFOX_LN}" -sf "${IRONFOX_DATE}"           "${IRONFOX_PATH}/gdate"
  "${IRONFOX_LN}" -sf "${IRONFOX_DIFF}"           "${IRONFOX_PATH}/diff"
  "${IRONFOX_LN}" -sf "${IRONFOX_DIRNAME}"        "${IRONFOX_PATH}/dirname"
  "${IRONFOX_LN}" -sf "${IRONFOX_ECHO}"           "${IRONFOX_PATH}/echo"
  "${IRONFOX_LN}" -sf "${IRONFOX_EGREP}"          "${IRONFOX_PATH}/egrep"
  "${IRONFOX_LN}" -sf "${IRONFOX_EXPR}"           "${IRONFOX_PATH}/expr"
  "${IRONFOX_LN}" -sf "${IRONFOX_FIND}"           "${IRONFOX_PATH}/find"
  "${IRONFOX_LN}" -sf "${IRONFOX_GIT}"            "${IRONFOX_PATH}/git"
  "${IRONFOX_LN}" -sf "${IRONFOX_GRADLE}"         "${IRONFOX_PATH}/gradle"
  "${IRONFOX_LN}" -sf "${IRONFOX_GREP}"           "${IRONFOX_PATH}/grep"
  "${IRONFOX_LN}" -sf "${IRONFOX_GZIP}"           "${IRONFOX_PATH}/gzip"
  "${IRONFOX_LN}" -sf "${IRONFOX_HEAD}"           "${IRONFOX_PATH}/head"
  "${IRONFOX_LN}" -sf "${IRONFOX_HOSTNAME}"       "${IRONFOX_PATH}/hostname"
  "${IRONFOX_LN}" -sf "${IRONFOX_JAVA}"           "${IRONFOX_PATH}/java"
  "${IRONFOX_LN}" -sf "${IRONFOX_JQ}"             "${IRONFOX_PATH}/jq"
  "${IRONFOX_LN}" -sf "${IRONFOX_LD}"             "${IRONFOX_PATH}/ld"
  "${IRONFOX_LN}" -sf "${IRONFOX_LIBTOOL}"        "${IRONFOX_PATH}/libtool"
  "${IRONFOX_LN}" -sf "${IRONFOX_LLVM_PROFDATA}"  "${IRONFOX_PATH}/llvm-profdata"
  "${IRONFOX_LN}" -sf "${IRONFOX_LN}"             "${IRONFOX_PATH}/ln"
  "${IRONFOX_LN}" -sf "${IRONFOX_LS}"             "${IRONFOX_PATH}/ls"
  "${IRONFOX_LN}" -sf "${IRONFOX_MACH}"           "${IRONFOX_PATH}/mach"
  "${IRONFOX_LN}" -sf "${IRONFOX_MAKE}"           "${IRONFOX_PATH}/gmake"
  "${IRONFOX_LN}" -sf "${IRONFOX_MAKE}"           "${IRONFOX_PATH}/make"
  "${IRONFOX_LN}" -sf "${IRONFOX_MD5SUM}"         "${IRONFOX_PATH}/md5sum"
  "${IRONFOX_LN}" -sf "${IRONFOX_MKDIR}"          "${IRONFOX_PATH}/mkdir"
  "${IRONFOX_LN}" -sf "${IRONFOX_MKTEMP}"         "${IRONFOX_PATH}/mktemp"
  "${IRONFOX_LN}" -sf "${IRONFOX_M4}"             "${IRONFOX_PATH}/m4"
  "${IRONFOX_LN}" -sf "${IRONFOX_MV}"             "${IRONFOX_PATH}/mv"
  "${IRONFOX_LN}" -sf "${IRONFOX_NASM}"           "${IRONFOX_PATH}/nasm"
  "${IRONFOX_LN}" -sf "${IRONFOX_NINJA}"          "${IRONFOX_PATH}/ninja"
  "${IRONFOX_LN}" -sf "${IRONFOX_NODEJS}"         "${IRONFOX_PATH}/node"
  "${IRONFOX_LN}" -sf "${IRONFOX_NM}"             "${IRONFOX_PATH}/nm"
  "${IRONFOX_LN}" -sf "${IRONFOX_NPM}"            "${IRONFOX_PATH}/npm"
  "${IRONFOX_LN}" -sf "${IRONFOX_OTOOL}"          "${IRONFOX_PATH}/otool"
  "${IRONFOX_LN}" -sf "${IRONFOX_PATCH}"          "${IRONFOX_PATH}/gpatch"
  "${IRONFOX_LN}" -sf "${IRONFOX_PATCH}"          "${IRONFOX_PATH}/patch"
  "${IRONFOX_LN}" -sf "${IRONFOX_PERL}"           "${IRONFOX_PATH}/perl"
  "${IRONFOX_LN}" -sf "${IRONFOX_PIP}"            "${IRONFOX_PATH}/pip"
  "${IRONFOX_LN}" -sf "${IRONFOX_PWD}"            "${IRONFOX_PATH}/pwd"
  "${IRONFOX_LN}" -sf "${IRONFOX_PYTHON}"         "${IRONFOX_PATH}/python"
  "${IRONFOX_LN}" -sf "${IRONFOX_PYTHON}"         "${IRONFOX_PATH}/python3"
  "${IRONFOX_LN}" -sf "${IRONFOX_REALPATH}"       "${IRONFOX_PATH}/realpath"
  "${IRONFOX_LN}" -sf "${IRONFOX_RM}"             "${IRONFOX_PATH}/rm"
  "${IRONFOX_LN}" -sf "${IRONFOX_RMDIR}"          "${IRONFOX_PATH}/rmdir"
  "${IRONFOX_LN}" -sf "${IRONFOX_RUSTC}"          "${IRONFOX_PATH}/rustc"
  "${IRONFOX_LN}" -sf "${IRONFOX_RUSTDOC}"        "${IRONFOX_PATH}/rustdoc"
  "${IRONFOX_LN}" -sf "${IRONFOX_RUSTUP}"         "${IRONFOX_PATH}/rustup"
  "${IRONFOX_LN}" -sf "${IRONFOX_S3CMD}"          "${IRONFOX_PATH}/s3cmd"
  "${IRONFOX_LN}" -sf "${IRONFOX_SED}"            "${IRONFOX_PATH}/gsed"
  "${IRONFOX_LN}" -sf "${IRONFOX_SED}"            "${IRONFOX_PATH}/sed"
  "${IRONFOX_LN}" -sf "${IRONFOX_SH}"             "${IRONFOX_PATH}/sh"
  "${IRONFOX_LN}" -sf "${IRONFOX_SHASUM}"         "${IRONFOX_PATH}/shasum"
  "${IRONFOX_LN}" -sf "${IRONFOX_SHA1SUM}"        "${IRONFOX_PATH}/sha1sum"
  "${IRONFOX_LN}" -sf "${IRONFOX_SHA256SUM}"      "${IRONFOX_PATH}/sha256sum"
  "${IRONFOX_LN}" -sf "${IRONFOX_SHA512SUM}"      "${IRONFOX_PATH}/sha512sum"
  "${IRONFOX_LN}" -sf "${IRONFOX_SLEEP}"          "${IRONFOX_PATH}/sleep"
  "${IRONFOX_LN}" -sf "${IRONFOX_SORT}"           "${IRONFOX_PATH}/sort"
  "${IRONFOX_LN}" -sf "${IRONFOX_STRIP}"          "${IRONFOX_PATH}/strip"
  "${IRONFOX_LN}" -sf "${IRONFOX_SYSCTL}"         "${IRONFOX_PATH}/sysctl"
  "${IRONFOX_LN}" -sf "${IRONFOX_TAIL}"           "${IRONFOX_PATH}/tail"
  "${IRONFOX_LN}" -sf "${IRONFOX_TAR}"            "${IRONFOX_PATH}/gtar"
  "${IRONFOX_LN}" -sf "${IRONFOX_TAR}"            "${IRONFOX_PATH}/tar"
  "${IRONFOX_LN}" -sf "${IRONFOX_TEE}"            "${IRONFOX_PATH}/tee"
  "${IRONFOX_LN}" -sf "${IRONFOX_TOUCH}"          "${IRONFOX_PATH}/touch"
  "${IRONFOX_LN}" -sf "${IRONFOX_TR}"             "${IRONFOX_PATH}/tr"
  "${IRONFOX_LN}" -sf "${IRONFOX_UNAME}"          "${IRONFOX_PATH}/uname"
  "${IRONFOX_LN}" -sf "${IRONFOX_UNZIP}"          "${IRONFOX_PATH}/unzip"
  "${IRONFOX_LN}" -sf "${IRONFOX_UV}"             "${IRONFOX_PATH}/uv"
  "${IRONFOX_LN}" -sf "${IRONFOX_WC}"             "${IRONFOX_PATH}/wc"
  "${IRONFOX_LN}" -sf "${IRONFOX_WHICH}"          "${IRONFOX_PATH}/which"
  "${IRONFOX_LN}" -sf "${IRONFOX_WHOAMI}"         "${IRONFOX_PATH}/whoami"
  "${IRONFOX_LN}" -sf "${IRONFOX_XARGS}"          "${IRONFOX_PATH}/xargs"
  "${IRONFOX_LN}" -sf "${IRONFOX_XZ}"             "${IRONFOX_PATH}/xz"
  "${IRONFOX_LN}" -sf "${IRONFOX_YES}"            "${IRONFOX_PATH}/yes"
  "${IRONFOX_LN}" -sf "${IRONFOX_YQ}"             "${IRONFOX_PATH}/yq"

  if [[ "${IRONFOX_PLATFORM}" == 'darwin' ]]; then
    # OS X-specific
    "${IRONFOX_LN}" -sf "${IRONFOX_DOT_CLEAN}"        "${IRONFOX_PATH}/dot_clean"
    "${IRONFOX_LN}" -sf "${IRONFOX_XCRUN}"            "${IRONFOX_PATH}/xcrun"
    "${IRONFOX_LN}" -sf "${IRONFOX_SW_VERS}"          "${IRONFOX_PATH}/sw_vers"
  else
    # Linux-specific
    "${IRONFOX_LN}" -sf "${IRONFOX_NPROC}"            "${IRONFOX_PATH}/nproc"
  fi

  "${IRONFOX_LN}" -sf '/bin/bash'                   "${IRONFOX_PATH}/bash"

  readonly PATH="${IRONFOX_PATH}"
  export PATH
fi
