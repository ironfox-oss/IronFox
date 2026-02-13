# IronFox CI environment variables

# Android keystore/app signing
export IRONFOX_KEYSTORE='/opt/IronFox/ironfox-keystore.jks'
export IRONFOX_KEYSTORE_KEY_ALIAS='ironfox'
export IRONFOX_KEYSTORE_KEY_PASS_FILE='/opt/IronFox/ironfox-signing-key.pass'
export IRONFOX_KEYSTORE_PASS_FILE='/opt/IronFox/ironfox-keystore.pass'

# Build date
export IF_BUILD_DATE="${CI_PIPELINE_CREATED_AT}"
export MOZ_BUILD_DATE="$("${IRONFOX_DATE}" -d "${CI_PIPELINE_CREATED_AT}" "+%Y%m%d%H%M%S")"

# Safe Browsing
export IRONFOX_SB_GAPI_KEY_FILE='/opt/IronFox/ironfox-sb-gapi.data'
