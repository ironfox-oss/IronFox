# IronFox build target environment variables

## This is used for configuring the target build/architecture/type.

## CAUTION: Do NOT source this directly!
## Source 'env_target.sh' instead.

if [[ "${IRONFOX_TARGET_ARCH}" == 'arm64' ]]; then
    export IRONFOX_TARGET_ABI='arm64-v8a'
    export IRONFOX_TARGET_RUST='arm64'
elif [[ "${IRONFOX_TARGET_ARCH}" == 'arm' ]]; then
    export IRONFOX_TARGET_ABI='armeabi-v7a'
    export IRONFOX_TARGET_RUST='arm'
elif [[ "${IRONFOX_TARGET_ARCH}" == 'x86_64' ]]; then
    export IRONFOX_TARGET_ABI='x86_64'
    export IRONFOX_TARGET_RUST='x86_64'
elif [[ "${IRONFOX_TARGET_ARCH}" == 'bundle' ]]; then
    export IRONFOX_TARGET_ABI='"arm64-v8a", "armeabi-v7a", "x86_64"'
    export IRONFOX_TARGET_RUST='arm64,arm,x86_64'
fi
