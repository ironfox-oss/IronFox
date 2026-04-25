#!/bin/bash

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_SET_ENVS+x}" ]]; then
    bash -x $(dirname $0)/env.sh
fi
source $(dirname $0)/env.sh

# Include utilities
source "${IRONFOX_UTILS}"

# Set-up target parameters
readonly input_file="$1"
readonly output_file="$2"

# First, copy our input file to a temporary location for modification
cp "${input_file}" "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"

# Extract/format our preferences
"${IRONFOX_PYTHON}" "${IRONFOX_SCRIPTS}/extract-contentblocking-prefs.py" "${input_file}" "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"

# "urlclassifier.phishTable" is an edge case - its default value is derived from BuildConfig.MOZILLA_OFFICIAL
"${IRONFOX_SED}" -i -e 's/pref("urlclassifier.phishTable", .*)/pref("urlclassifier.phishTable", "goog-phish-proto,moztest-phish-simple")/' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"

# "urlclassifier.features.cryptomining.blacklistTables" and "urlclassifier.features.fingerprinting.blacklistTables" are also weird
"${IRONFOX_SED}" -i -e 's/pref("urlclassifier.features.cryptomining.blacklistTables", .*)/pref("urlclassifier.features.cryptomining.blacklistTables", "base-cryptomining-track-digest256")/' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i -e 's/pref("urlclassifier.features.fingerprinting.blacklistTables", .*)/pref("urlclassifier.features.fingerprinting.blacklistTables", "base-fingerprinting-track-digest256")/' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"

# Handle Bounce tracking protection values
"${IRONFOX_SED}" -i 's|"BounceTrackingProtectionMode.BOUNCE_TRACKING_PROTECTION_MODE_DISABLED"|0|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"BounceTrackingProtectionMode.BOUNCE_TRACKING_PROTECTION_MODE_ENABLED_DRY_RUN"|3|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"BounceTrackingProtectionMode.BOUNCE_TRACKING_PROTECTION_MODE_ENABLED_STANDBY"|2|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"BounceTrackingProtectionMode.BOUNCE_TRACKING_PROTECTION_MODE_ENABLED"|1|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"

# Handle Cookie banner blocking values
"${IRONFOX_SED}" -i 's|"CookieBannerMode.COOKIE_BANNER_MODE_DISABLED"|0|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"CookieBannerMode.COOKIE_BANNER_MODE_REJECT_OR_ACCEPT"|2|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"CookieBannerMode.COOKIE_BANNER_MODE_REJECT"|1|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"

# Handle Cookie behavior values
"${IRONFOX_SED}" -i 's|"CookieBehavior.ACCEPT_FIRST_PARTY_AND_ISOLATE_OTHERS"|5|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"CookieBehavior.ACCEPT_FIRST_PARTY"|1|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"CookieBehavior.ACCEPT_NONE"|2|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"CookieBehavior.ACCEPT_VISITED"|3|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"
"${IRONFOX_SED}" -i 's|"CookieBehavior.ACCEPT_NON_TRACKERS"|4|' "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"

# Ensure we remove any remaining unwanted lines
cp "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js" "${IRONFOX_BUILD}/tmp/gecko/contentblocking-temp-1.js"
cat "${IRONFOX_BUILD}/tmp/gecko/contentblocking-temp-1.js" | grep -F 'pref("' > "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js"

cp "${IRONFOX_BUILD}/tmp/gecko/contentblocking.js" "${output_file}"
