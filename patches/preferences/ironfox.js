
// Melding the Phoenix into a fox; one built with a strong coat of Iron…

// This is home to IronFox-specific preferences. This will primarily be used for overriding undesired preferences from Phoenix; but it can also be used for ex. branding.

/// Disable DNS Over HTTPS by default

pref("network.trr.mode", 5);

/// Disable Safe Browsing by default
// We're going to look into proxying this in the future; but for the time being, we decided it's best to leave off by default. It's unfortunate this isn't exposed in the UI or by some kind of onboarding from Mozilla :/

pref("browser.safebrowsing.features.malware.update", false);
pref("browser.safebrowsing.features.phishing.update", false);

/// Re-enable Password Manager & Autofill in GeckoView
// We still disable these by default, just via Fenix's UI settings instead...
// https://gitlab.com/ironfox-oss/IronFox/-/issues/11

pref("extensions.formautofill.addresses.enabled", true); // [DEFAULT]
pref("extensions.formautofill.creditCards.enabled", true); // [DEFAULT]
pref("signon.rememberSignons", true); // [DEFAULT]

pref("browser.ironfox.applied", true);
