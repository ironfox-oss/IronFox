#!/bin/bash

if [[ "$env_source" != "true" ]]; then
    echo "Use 'source scripts/env_local.sh' before calling prebuild or build"
    return 1
fi

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

declare -a PATCH_FILES
PATCH_FILES=(
    # Remove Mozilla repositories substitution and explicitly add the required ones
    "gecko-localize_maven.patch"

    # Replace GMS with microG client library
    "gecko-liberate.patch"

    # Patch the use of proprietary and tracking libraries
    "fenix-liberate.patch"

    # Make it IronFox...
    "branding.patch"

    # Disable "Sent from Firefox" footer/link sharing
    "disable-link-sharing.patch"

    # Enable about:config
    "enable-aboutconfig.patch"

    # Add our custom search engines
    "search-engines.patch"

    # Disable Telemetry
    "disable-telemetry.patch"

    # Disable Pocket/Contile
    "disable-pocket.patch"

    # Disable DoH canary requests
    "disable-doh-canary.patch"

    # Support spoofing locale to 'en-US'
    "tor-spoof-english.patch"

    # Set strict ETP by default
    "strict_etp.patch"

    # Enable HTTPS only mode by default
    "https_only.patch"

    # Hide the UI setting for Global Privacy Control
    "global-privacy-control.patch"

    # Disable search suggestions by default
    "disable-search-suggestions.patch"

    # Disable autocomplete by default
    "disable-autocomplete.patch"

    # Disable shipped domains - These haven't been updated in several years, posing security concerns - and are also just annoying...
    "disable-shipped-domains.patch"

    # Disable password manager/autofill by default
    "disable-autofill.patch"

    # Clear open tabs, browsing history, cache, & download list on exit by default
    "sanitize-on-exit.patch"

    # Disable Firefox Suggest
    "disable-firefox-suggest.patch"

    # Enable "Zoom on all websites" by default - allows always zooming into websites, even if they try to block it...
    "force-enable-zoom.patch"

    # Disable Contextual Feature Recommendations
    "disable-cfrs.patch"

    # Disable Mozilla Feedback Surveys (Microsurveys)
    "disable-microsurveys.patch"

    # Enable light mode by default
    "enable-light-mode-by-default.patch"

    # Block cookie banners by default
    "block-cookie-banners.patch"

    # Switch the built-in extension recommendations page to use our collection instead of Mozilla's...
    "extension-recommendations.patch"

    # Disable menu item to report issues with websites to Mozilla...
    "disable-reporting-site-issues.patch"

    # Configure DNS over HTTPS
    "configure-doh.patch"

    # Tweak Safe Browsing (See '009 SAFE BROWSING' in Phoenix for more details...)
    "configure-safe-browsing.patch"

    # Tweak PDF.js (We currently disable JavaScript & XFA + enable sidebar by default)
    "configure-pdfjs.patch"

    # Remove default top sites/shortcuts
    "remove-default-sites.patch"

    # Enable preference to toggle tab strip https://gitlab.com/ironfox-oss/IronFox/-/issues/27
    "enable-tab-strip.patch"

    # Enable Firefox's newer 'Felt privacy' design for Private Browsing by default
    "enable-felt-privacy.patch"

    # Set uBlock Origin to use our custom/enhanced config by default
    "ublock-assets.patch"

    # Install uBlock Origin on startup and allow it to be shown in AddonsFragment
    "install-ublock.patch"

    # Disable Firefox Sync by default
    "disable-sync-by-default.patch"

    # Disallow using the Domestic China server for Firefox Sync...
    "disallow-china-fxa-server.patch"

    # Block autoplay by default...
    "block-autoplay-by-default.patch"

    # Ensure users can toggle certain `secret` settings if desired
    "enable-secret-settings.patch"

    # Fix v125 compile error
    "gecko-fix-125-compile.patch"
)

check_patch() {
    patch="$patches/$1"
    if ! [[ -f "$patch" ]]; then
        echo "Patch '$patch' does not exist or is not a file"
        return 1
    fi

    if ! patch -p1 -f --quiet --dry-run <"$patch"; then
        echo "Incompatible patch: '$patch'"
        return 1
    fi
}

check_patches() {
    for patch in "${PATCH_FILES[@]}"; do
        if ! check_patch "$patch"; then
            return 1
        fi
    done
}

test_patches() {
    for patch in "${PATCH_FILES[@]}"; do
        if ! check_patch "$patch">/dev/null 2>&1; then
            printf "${RED}%-45s: FAILED${NC}\n" "$(basename "$patch")"
        else
            printf "${GREEN}%-45s: OK${NC}\n" "$(basename "$patch")"
        fi
    done
}

apply_patch() {
    name="$1"
    echo "Applying patch: $name"
    check_patch "$name" || return 1
    patch -p1 --no-backup-if-mismatch --quiet <"$patches/$name"
    return $?
}

apply_patches() {
    for patch in "${PATCH_FILES[@]}"; do
        if ! apply_patch "$patch"; then
            echo "Failed to apply patch: $patch"
        fi
    done
}
