
// Melding the Phoenix into a fox; one built with a strong coat of Iron…

// This is home to IronFox-specific preferences. This will primarily be used for overriding undesired preferences from Phoenix; but it can also be used for ex. branding.

/// Disable DNS Over HTTPS by default

pref("network.trr.mode", 5);

/// Re-enable Password Manager & Autofill in GeckoView
// We still disable these by default, just via Fenix's UI settings instead...
// https://gitlab.com/ironfox-oss/IronFox/-/issues/11

pref("extensions.formautofill.addresses.enabled", true); // [DEFAULT]
pref("extensions.formautofill.creditCards.enabled", true); // [DEFAULT]
pref("signon.rememberSignons", true); // [DEFAULT]

/// Disable automatic translation
// We need to handle this by the UI instead...

pref("browser.translations.alwaysTranslateLanguages", ""); // [DEFAULT]

/// Set light/dark mode to match system
// We're going to patch to set this to light mode by default via UI instead...

pref("layout.css.prefers-color-scheme.content-override", 2); // [DEFAULT]

pref("browser.ironfox.applied", true, locked);
