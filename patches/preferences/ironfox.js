
// Melding the Phoenix into a fox, with a strong coat of Iron…

// This is home to IronFox-specific preferences. This will primarily be used for overriding undesired preferences from Phoenix; but it can also be used for ex. branding.

/// Branding
pref("app.releaseNotesURL", "https://gitlab.com/ironfox-oss/IronFox/-/releases", locked);
pref("app.releaseNotesURL.prompt", "https://gitlab.com/ironfox-oss/IronFox/-/releases", locked);
pref("app.update.url.details", "https://gitlab.com/ironfox-oss/IronFox/-/releases", locked);
pref("app.update.url.manual", "https://gitlab.com/ironfox-oss/IronFox/-/releases", locked);
pref("app.vendorURL", "https://ironfoxoss.org/", locked);

/// Configure uBlock Origin
pref("browser.ironfox.uBO.autoCommentFilterTemplate", "{{url}}");
pref("browser.ironfox.uBO.autoUpdateDelayAfterLaunch", "10");
pref("browser.ironfox.uBO.disableWebAssembly", "true");
pref("browser.ironfox.uBO.filterAuthorMode", "true");
pref("browser.ironfox.uBO.uiPopupConfig", "+logger");
pref("browser.ironfox.uBO.updateAssetBypassBrowserCache", "true");

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

/// Enable FPP overrides by default
pref("browser.ironfox.fingerprintingProtection.hardenOverrides.enabled", true); // [DEFAULT] Overrides from us that *harden* protections for certain sites

/// Enable our Beacon API (navigator.sendBeacon) Stub
// Unlike standard Firefox, this doesn't actually enable the Beacon API; this just enables our stub - see the `stub-beacon` patch for more details
pref("beacon.enabled", true); // [DEFAULT]

/// Enable the Phoenix add-on blocklist by default
// https://codeberg.org/celenity/Phoenix/src/branch/pages/build/policies/blocklist.json
pref("browser.ironfox.extensions.blocklist.enabled", true); // [DEFAULT]

/// Ensure media autoplay is always/only controlled by the UI/permission prompt
pref("media.geckoview.autoplay.request", true, locked); // [DEFAULT]

/// Ensure EME is always/only controlled by the UI/permission prompt
pref("media.eme.require-app-approval", true, locked); // [DEFAULT]

/// Re-enable geolocation permission prompts in GeckoView
// We still block this by default, just via a patch for Fenix's UI settings instead
pref("geo.prompt.testing", false); // [HIDDEN] [DEFAULT]

/// Re-enable media autoplay in GeckoView
// We still block this by default, just via a patch for Fenix's UI settings instead
pref("media.geckoview.autoplay.request.testing", 0, locked); // [DEFAULT]

/// Re-enable notification permission prompts in GeckoView
// We still block this by default, just via a patch for Fenix's UI settings instead
pref("notification.prompt.testing", false); // [HIDDEN] [DEFAULT]

/// Restrict Remote Settings
pref("browser.ironfox.services.settings.allowedCollections", "blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,blocklists/plugins,main/addons-data-leak-blocker-domains,main/anti-tracking-url-decoration,main/bounce-tracking-protection-exceptions,main/cookie-banner-rules-list,main/fingerprinting-protection-overrides,main/hijack-blocklists,main/ml-inference-options,main/ml-inference-request-options,main/ml-model-allow-deny-list,main/ml-onnx-runtime,main/partitioning-exempt-urls,main/password-recipes,main/public-suffix-list,main/query-stripping,main/remote-permissions,main/third-party-cookie-blocking-exempt-urls,main/tracking-protection-lists,main/translations-identification-models,main/translations-models,main/translations-models-v2,main/translations-wasm,main/translations-wasm-v2,main/url-classifier-exceptions,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,main/webcompat-interventions,security-state/cert-revocations,security-state/ct-logs,security-state/intermediates,security-state/onecrl");
pref("browser.ironfox.services.settings.allowedCollectionsFromDump", "main/ironfox-fingerprinting-protection-overrides-harden,main/ironfox-fingerprinting-protection-overrides-unbreak,main/ironfox-fingerprinting-protection-overrides-unbreak-timezone,main/ironfox-fingerprinting-protection-overrides-unbreak-webgl,blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,blocklists/plugins,main/addons-data-leak-blocker-domains,main/anti-tracking-url-decoration,main/bounce-tracking-protection-exceptions,main/cookie-banner-rules-list,main/fingerprinting-protection-overrides,main/hijack-blocklists,main/moz-essential-domain-fallbacks,main/ml-inference-options,main/ml-inference-request-options,main/ml-model-allow-deny-list,main/ml-onnx-runtime,main/partitioning-exempt-urls,main/password-recipes,main/public-suffix-list,main/query-stripping,main/remote-permissions,main/third-party-cookie-blocking-exempt-urls,main/tracking-protection-lists,main/translations-identification-models,main/translations-models,main/translations-models-v2,main/translations-wasm,main/translations-wasm-v2,main/url-classifier-exceptions,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,main/webcompat-interventions,security-state/cert-revocations,security-state/ct-logs,security-state/intermediates,security-state/onecrl");

/// Set light/dark mode to match system
// We still enable light mode by default, just via a patch for Fenix's UI settings instead
pref("layout.css.prefers-color-scheme.content-override", 2, locked); // [DEFAULT]

/// Annotate locked prefs controlled by UI settings
pref("accessibility.force_disabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("accessibility.force_disabled.1.NOTE", "'Enable accessibility services'", locked);
pref("browser.cache.disk.enable.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.cache.disk.enable.1.NOTE", "'Enable disk cache'", locked);
pref("browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled.1.NOTE", "'Spoof timezone to UTC-0'", locked);
pref("browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled.1.NOTE", "'Enable fingerprinting protection overrides from IronFox'", locked);
pref("browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled.1.NOTE", "'Enable timezone spoofing overrides from IronFox'", locked);
pref("browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled.1.NOTE", "'Enable WebGL overrides from IronFox'", locked);
pref("browser.safebrowsing.malware.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.safebrowsing.malware.enabled.1.NOTE", "'Enable Safe Browsing'", locked);
pref("browser.safebrowsing.phishing.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.safebrowsing.phishing.enabled.1.NOTE", "'Enable Safe Browsing'", locked);
pref("browser.translations.automaticallyPopup.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.translations.automaticallyPopup.1.NOTE", "'Offer to translate when possible'", locked);
pref("browser.translations.enable.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.translations.enable.1.NOTE", "'Enable Firefox Translations'", locked);
pref("browser.translations.simulateUnsupportedEngine.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.translations.simulateUnsupportedEngine.1.NOTE", "'Enable Firefox Translations'", locked);
pref("browser.ui.zoom.force-user-scalable.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.ui.zoom.force-user-scalable.1.NOTE", "'Zoom on all websites'", locked);
pref("consoleservice.logcat.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("consoleservice.logcat.1.NOTE", "'Enable Gecko logs'", locked);
pref("cookiebanners.service.mode.privateBrowsing.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("cookiebanners.service.mode.privateBrowsing.1.NOTE", "'Cookie Banner Blocker in private browsing'", locked);
pref("devtools.console.stdout.chrome.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("devtools.console.stdout.chrome.1.NOTE", "'Enable Gecko logs'", locked);
pref("dom.security.https_only_mode.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("dom.security.https_only_mode.1.NOTE", "'HTTPS-Only Mode'", locked);
pref("dom.security.https_only_mode_pbm.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("dom.security.https_only_mode_pbm.1.NOTE", "'HTTPS-Only Mode'", locked);
pref("extensions.formautofill.addresses.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("extensions.formautofill.addresses.enabled.1.NOTE", "'Save and fill addresses'", locked);
pref("extensions.formautofill.creditCards.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("extensions.formautofill.creditCards.enabled.1.NOTE", "'Save and fill payment methods'", locked);
pref("font.size.inflation.minTwips.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("font.size.inflation.minTwips.1.NOTE", "'Automatic font sizing'", locked);
pref("geckoview.console.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("geckoview.console.enabled.1.NOTE", "'Enable Gecko logs'", locked);
pref("geckoview.logging.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("geckoview.logging.1.NOTE", "'Enable Gecko logs'", locked);
pref("javascript.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.enabled.1.NOTE", "'Enable JavaScript'", locked);
pref("javascript.options.baselinejit.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.baselinejit.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.jit_trustedprincipals.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.jit_trustedprincipals.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT) for extensions'", locked);
pref("javascript.options.jithints.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.jithints.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.ion.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.ion.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.native_regexp.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.native_regexp.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.wasm.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.wasm.1.NOTE", "'Enable WebAssembly (WASM)'", locked);
pref("javascript.options.wasm_optimizingjit.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.wasm_optimizingjit.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("media.autoplay.blocking_policy.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("media.autoplay.blocking_policy.1.NOTE", "'Media autoplay'", locked);
pref("media.eme.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("media.eme.enabled.1.NOTE", "'Enable Encrypted Media Extensions (EME)'", locked);
pref("media.mediadrm-widevinecdm.visible.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("media.mediadrm-widevinecdm.visible.1.NOTE", "'Enable Widevine CDM'", locked);
pref("media.peerconnection.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("media.peerconnection.enabled.1.NOTE", "'Enable Widevine CDM'", locked);
pref("network.dns.disableIPv6.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.dns.disableIPv6.1.NOTE", "'Enable IPv6 network connectivity'", locked);
pref("network.http.referer.XOriginPolicy.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.http.referer.XOriginPolicy.1.NOTE", "'Cross-origin referer policy'", locked);
pref("network.lna.blocking.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.lna.blocking.1.NOTE", "'Enable LNA blocking'", locked);
pref("network.trr.default_provider_uri.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.trr.default_provider_uri.1.NOTE", "'DNS over HTTPS'", locked);
pref("network.trr.excluded-domains.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.trr.excluded-domains.1.NOTE", "'DNS over HTTPS'", locked);
pref("network.trr.mode.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.trr.mode.1.NOTE", "'DNS over HTTPS'", locked);
pref("network.trr.uri.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.trr.uri.1.NOTE", "'DNS over HTTPS'", locked);
pref("pdfjs.disabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("pdfjs.disabled.1.NOTE", "'Open PDF files externally'", locked);
pref("print.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("print.enabled.1.NOTE", "'Enable printing capabilities'", locked);
pref("privacy.fingerprintingProtection.remoteOverrides.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("privacy.fingerprintingProtection.remoteOverrides.enabled.1.NOTE", "'Enable fingerprinting protection overrides from Mozilla'", locked);
pref("privacy.spoof_english.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("privacy.spoof_english.1.NOTE", "'Request English versions of webpages'", locked);
pref("privacy.trackingprotection.allow_list.baseline.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("privacy.trackingprotection.allow_list.baseline.enabled.1.NOTE", "'Enhanced Tracking Protection'", locked);
pref("privacy.trackingprotection.allow_list.convenience.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("privacy.trackingprotection.allow_list.convenience.enabled.1.NOTE", "'Enhanced Tracking Protection'", locked);
pref("security.enterprise_roots.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("security.enterprise_roots.enabled.1.NOTE", "'Use third party CA certificates'", locked);
pref("signon.autofillForms.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("signon.autofillForms.1.NOTE", "'Autofill in IronFox'", locked);
pref("signon.rememberSignons.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("signon.rememberSignons.1.NOTE", "'Save passwords'", locked);
pref("svg.disabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("svg.disabled.1.NOTE", "'Enable Scalable Vector Graphics (SVG)'", locked);
pref("webgl.disabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("webgl.disabled.1.NOTE", "'Disable WebGL'", locked);
pref("xpinstall.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("xpinstall.enabled.1.NOTE", "'Allow installation of add-ons'", locked);

pref("browser.ironfox.applied", true, locked);
