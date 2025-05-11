
// Melding the Phoenix into a fox, with a strong coat of Iron…

// This is home to IronFox-specific preferences. This will primarily be used for overriding undesired preferences from Phoenix; but it can also be used for ex. branding.

/// Clear FPP global overrides
// We're hardening FPP internally with our own `RFPTargetsDefault.inc` file instead of setting them here, which makes it far easier for users to add their own overrides if desired (by using this preference).
pref("privacy.fingerprintingProtection.overrides", ""); // [DEFAULT]

/// Clear FPP granular overrides
// We're including these internally with a custom Remote Settings dump instead of setting them here, which makes it far easier for users to add their own overrides if desired (by using this preference).
pref("privacy.fingerprintingProtection.granularOverrides", ''); // [DEFAULT]

/// Re-enable our/Mozilla's fingerprinting protection overrides
// We disable this functionality in Phoenix to re-enable Canvas randomization for Google domains by default - that isn't a problem for us here though, since we just use our custom Remote Settings dump to re-enable Canvas randomization for Google domains instead
// This pref is also required for our custom Remote Settings dump/overrides to work anyways...
pref("privacy.fingerprintingProtection.remoteOverrides.enabled", true); // [DEFAULT]

/// Re-enable Password Manager & Autofill in GeckoView
// We still disable these by default, just via a patch for Fenix's UI settings instead
// https://gitlab.com/ironfox-oss/IronFox/-/issues/11
pref("extensions.formautofill.addresses.enabled", true); // [DEFAULT]
pref("extensions.formautofill.creditCards.enabled", true); // [DEFAULT]
pref("signon.rememberSignons", true); // [DEFAULT]

/// Re-enable WebGL
// We're now blocking this by default with uBlock Origin
pref("webgl.disabled", false); // [DEFAULT]

/// Restrict Remote Settings
pref("browser.ironfox.services.settings.allowedCollections", "blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,main/addons-manager-settings,main/anti-tracking-url-decoration,main/bounce-tracking-protection-exceptions,main/cookie-banner-rules-list,main/fingerprinting-protection-overrides,main/moz-essential-domain-fallbacks,main/partitioning-exempt-urls,main/password-recipes,main/query-stripping,main/remote-permissions,main/tracking-protection-lists,main/third-party-cookie-blocking-exempt-urls,main/translations-models,main/translations-wasm,main/url-classifier-exceptions,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,security-state/cert-revocations,security-state/ct-logs,security-state/intermediates,security-state/onecrl");
pref("browser.ironfox.services.settings.allowedCollectionsFromDump", "main/ironfox-fingerprinting-protection-overrides,blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,main/anti-tracking-url-decoration,main/cookie-banner-rules-list,main/moz-essential-domain-fallbacks,main/password-recipes,main/remote-permissions,main/translations-models,main/translations-wasm,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,security-state/intermediates,security-state/onecrl");

/// Set light/dark mode to match system
// We still enable light mode by default, just via a patch for Fenix's UI settings instead
pref("layout.css.prefers-color-scheme.content-override", 2); // [DEFAULT]

pref("browser.ironfox.applied", true, locked);
