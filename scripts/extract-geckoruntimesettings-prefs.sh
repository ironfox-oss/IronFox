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
cp "${input_file}" "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js"

# Remove any lines that do NOT contain "new Pref<"
cp "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js" "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings-temp-1.js"
"${IRONFOX_AWK}" '
/new Pref</ { if (!seen++) start=NR; last=NR }
{ lines[NR]=$0 }
END {
if (!seen) exit
for (i=start;i<=last;i++) print lines[i]
}
' "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js" > "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings-temp-1.js"

# Remove remaining lines that don't contain preferences + remove lines containing "PrefWithoutDefault" - we don't care about those...
cat "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings-temp-1.js" | grep -vE 'PrefWithoutDefault' | grep -F ');' | sort | uniq > "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js"
rm -f "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings-temp-1.js"

# Format our remaining prefs
"${IRONFOX_SED}" -i -e 's/.*(/pref(/' "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js"
"${IRONFOX_SED}" -i -E 's/^[[:space:]]*"([^"]*".*);/pref("\1;/' "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js"

# "geckoview.logging" is an edge case - its default value is derived from BuildConfig.DEBUG_BUILD
"${IRONFOX_SED}" -i -e 's/pref("geckoview.logging", .*)/pref("geckoview.logging", "Warn")/' "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js"

# Ensure we remove any remaining unwanted lines
cp "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js" "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings-temp-1.js"
cat "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings-temp-1.js" | grep -F 'pref("' > "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js"

cp "${IRONFOX_BUILD}/tmp/gecko/geckoruntimesettings.js" "${output_file}"
