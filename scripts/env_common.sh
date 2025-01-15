#!/bin/bash

# Caution: Should not be sourced directly!
# Use 'env_local.sh' or 'env_fdroid.sh' instead.

MOZ_CHROME_MULTILOCALE=$(<"$patches/locales")
export MOZ_CHROME_MULTILOCALE

export NSS_DIR="$application_services/libs/desktop/linux-x86-64/nss"
export NSS_STATIC=1

export env_source="true"