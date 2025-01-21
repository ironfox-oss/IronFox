
// Melding the Phoenix into a fox; one built with a strong coat of Iron…

// This is home to IronFox-specific preferences. This will primarily be used for overriding undesired preferences from Phoenix; but it can also be used for ex. branding.

/// Disable DNS Over HTTPS by default

pref("network.trr.mode", 5);

/// Enable Safe Browsing by default
pref("browser.safebrowsing.features.malware.update", false);
pref("browser.safebrowsing.features.phishing.update", false);

/// Set Safe Browsing API proxy
pref("browser.safebrowsing.provider.google4.updateURL", "https://safebrowsing.itsaky.workers.dev/v4/threatListUpdates:fetch?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST");
pref("browser.safebrowsing.provider.google4.gethashURL", "https://safebrowsing.itsaky.workers.dev/v4/fullHashes:find?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST");
pref("browser.safebrowsing.provider.google4.dataSharingURL", "https://safebrowsing.itsaky.workers.dev/v4/threatHits?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST");

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

pref("browser.ironfox.applied", true);
