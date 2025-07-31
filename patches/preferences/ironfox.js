
// Melding the Phoenix into a fox, with a strong coat of Iron…

// This is home to IronFox-specific preferences. This will primarily be used for overriding undesired preferences from Phoenix; but it can also be used for ex. branding.

/// Clear FPP global overrides
// We're hardening FPP internally with our own `RFPTargetsDefault.inc` file instead of setting them here, which makes it far easier for users to add their own overrides if desired (by using this preference).
pref("privacy.fingerprintingProtection.overrides", ""); // [DEFAULT]

/// Clear FPP granular overrides
// We're including these internally with a custom Remote Settings dump instead of setting them here, which makes it far easier for users to add their own overrides if desired (by using this preference).
pref("privacy.fingerprintingProtection.granularOverrides", ''); // [DEFAULT]

/// Disable mozAddonManager
// mozAddonManager prevents extensions from working on `addons.mozilla.org`, and this API also exposes a list of the user's installed add-ons to `addons.mozilla.org`
// Disabling the following preferences typically breaks installation of extensions from `addons.mozilla.org` on Android, but we fix this with our `install-addons-from-amo-without-mozaddonmanager` patch.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1952390#c4
// https://bugzilla.mozilla.org/show_bug.cgi?id=1384330
pref("extensions.webapi.enabled", false);
pref("privacy.resistFingerprinting.block_mozAddonManager", true);

/// Enable our Beacon API (navigator.sendBeacon) Stub
// Unlike standard Firefox, this doesn't actually enable the Beacon API; this just enables our stub - see the `stub-beacon` patch for more details
pref("beacon.enabled", true); // [DEFAULT]

/// Re-enable geolocation permission prompts in GeckoView
// We still block this by default, just via a patch for Fenix's UI settings instead
pref("geo.prompt.testing", false); // [HIDDEN] [DEFAULT]

/// Re-enable media autoplay in GeckoView
// We still block this by default, just via a patch for Fenix's UI settings instead
pref("media.geckoview.autoplay.request.testing", 0); // [DEFAULT]

/// Re-enable notification permission prompts in GeckoView
// We still block this by default, just via a patch for Fenix's UI settings instead
pref("notification.prompt.testing", false); // [HIDDEN] [DEFAULT]

/// Re-enable Password Manager and Autofill in GeckoView
// We still disable these by default, just via a patch for Fenix's UI settings instead
// https://gitlab.com/ironfox-oss/IronFox/-/issues/11
pref("extensions.formautofill.addresses.enabled", true); // [DEFAULT]
pref("extensions.formautofill.creditCards.enabled", true); // [DEFAULT]
pref("signon.rememberSignons", true); // [DEFAULT]

/// Re-enable WebGL
// We're now blocking this by default with uBlock Origin
pref("webgl.disabled", false); // [DEFAULT]

/// Restrict Remote Settings
pref("browser.ironfox.services.settings.allowedCollections", "blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,blocklists/plugins,main/addons-manager-settings,main/anti-tracking-url-decoration,main/bounce-tracking-protection-exceptions,main/fingerprinting-protection-overrides,main/hijack-blocklists,main/ml-onnx-runtime,main/partitioning-exempt-urls,main/password-recipes,main/query-stripping,main/remote-permissions,main/tracking-protection-lists,main/third-party-cookie-blocking-exempt-urls,main/translations-identification-models,main/translations-models,main/translations-wasm,main/url-classifier-exceptions,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,security-state/cert-revocations,security-state/ct-logs,security-state/intermediates,security-state/onecrl");
pref("browser.ironfox.services.settings.allowedCollectionsFromDump", "main/ironfox-fingerprinting-protection-overrides,blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,main/anti-tracking-url-decoration,main/cookie-banner-rules-list,main/moz-essential-domain-fallbacks,main/password-recipes,main/remote-permissions,main/translations-models,main/translations-wasm,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,security-state/intermediates,security-state/onecrl");

/// Set default process count
// This is the same as the default value - but we need to set here since Mozilla only defines it in GeckoRuntimeSettings, which we override to allow users to change the value if desired
pref("dom.ipc.processCount", 2); // [DEFAULT]

/// Set light/dark mode to match system
// We still enable light mode by default, just via a patch for Fenix's UI settings instead
pref("layout.css.prefers-color-scheme.content-override", 2); // [DEFAULT]

pref("browser.ironfox.applied", true, locked);
