
// Melding the Phoenix into a fox, with a strong coat of Iron…

// This is home to IronFox-specific preferences. This will primarily be used for overriding undesired preferences from Phoenix; but it can also be used for ex. branding.

/// Branding
pref("app.releaseNotesURL", "https://gitlab.com/ironfox-oss/IronFox/-/releases", locked);
pref("app.releaseNotesURL.prompt", "https://gitlab.com/ironfox-oss/IronFox/-/releases", locked);
pref("app.update.url.details", "https://gitlab.com/ironfox-oss/IronFox/-/releases", locked);
pref("app.update.url.manual", "https://gitlab.com/ironfox-oss/IronFox/-/releases", locked);
pref("app.vendorURL", "https://ironfoxoss.org/", locked);

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
pref("browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled", true); // [DEFAULT] Overrides from us that *relax* protections for certain sites by default
pref("browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled", true); // [DEFAULT] Overrides from us that disable timezone spoofing by default for certain sites
pref("privacy.fingerprintingProtection.remoteOverrides.enabled", true); // [DEFAULT] Overrides from Mozilla

/// Enable our Beacon API (navigator.sendBeacon) Stub
// Unlike standard Firefox, this doesn't actually enable the Beacon API; this just enables our stub - see the `stub-beacon` patch for more details
pref("beacon.enabled", true); // [DEFAULT]

/// Lock prefs controlled by UI settings
// This prevents prefs from becoming out of sync with the corresponding UI toggle(s)/behavior in Fenix
// Modifying these prefs directly from `about:config` also causes them to reset on the next browser launch, which users probably do not want/expect
// (These prefs can still be modified, just from the UI settings instead of from the `about:config`)
pref("accessibility.force_disabled", 1, locked);
pref("accessibility.force_disabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("accessibility.force_disabled.1.NOTE", "'Enable accessibility services'", locked);
pref("browser.cache.disk.enable", false, locked);
pref("browser.cache.disk.enable.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.cache.disk.enable.1.NOTE", "'Enable disk cache'", locked);
pref("browser.safebrowsing.malware.enabled", true, locked);
pref("browser.safebrowsing.malware.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.safebrowsing.malware.enabled.1.NOTE", "'Enable Safe Browsing'", locked);
pref("browser.safebrowsing.phishing.enabled", true, locked);
pref("browser.safebrowsing.phishing.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.safebrowsing.phishing.enabled.1.NOTE", "'Enable Safe Browsing'", locked);
pref("browser.translations.automaticallyPopup", true, locked);
pref("browser.translations.automaticallyPopup.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.translations.automaticallyPopup.1.NOTE", "'Offer to translate when possible'", locked);
pref("browser.translations.enable", true, locked);
pref("browser.translations.enable.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.translations.enable.1.NOTE", "'Enable Firefox Translations'", locked);
pref("browser.translations.simulateUnsupportedEngine", false, locked);
pref("browser.translations.simulateUnsupportedEngine.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.translations.simulateUnsupportedEngine.1.NOTE", "'Enable Firefox Translations'", locked);
pref("browser.ui.zoom.force-user-scalable", true, locked);
pref("browser.ui.zoom.force-user-scalable.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("browser.ui.zoom.force-user-scalable.1.NOTE", "'Zoom on all websites'", locked);
pref("consoleservice.logcat", false, locked);
pref("consoleservice.logcat.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("consoleservice.logcat.1.NOTE", "'Enable Gecko logs'", locked);
pref("cookiebanners.service.mode.privateBrowsing", 1, locked);
pref("cookiebanners.service.mode.privateBrowsing.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("cookiebanners.service.mode.privateBrowsing.1.NOTE", "'Cookie Banner Blocker in private browsing'", locked);
pref("devtools.console.stdout.chrome", false, locked);
pref("devtools.console.stdout.chrome.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("devtools.console.stdout.chrome.1.NOTE", "'Enable Gecko logs'", locked);
pref("dom.security.https_only_mode", true, locked);
pref("dom.security.https_only_mode.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("dom.security.https_only_mode.1.NOTE", "'HTTPS-Only Mode'", locked);
pref("dom.security.https_only_mode_pbm", false, locked);
pref("dom.security.https_only_mode_pbm.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("dom.security.https_only_mode_pbm.1.NOTE", "'HTTPS-Only Mode'", locked);
pref("extensions.formautofill.addresses.enabled", false, locked);
pref("extensions.formautofill.addresses.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("extensions.formautofill.addresses.enabled.1.NOTE", "'Save and fill addresses'", locked);
pref("extensions.formautofill.creditCards.enabled", false, locked);
pref("extensions.formautofill.creditCards.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("extensions.formautofill.creditCards.enabled.1.NOTE", "'Save and fill payment methods'", locked);
pref("font.size.inflation.minTwips", 0, locked);
pref("font.size.inflation.minTwips.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("font.size.inflation.minTwips.1.NOTE", "'Automatic font sizing'", locked);
pref("geckoview.console.enabled", false, locked);
pref("geckoview.console.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("geckoview.console.enabled.1.NOTE", "'Enable Gecko logs'", locked);
pref("geckoview.logging", "Warn", locked);
pref("geckoview.logging.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("geckoview.logging.1.NOTE", "'Enable Gecko logs'", locked);
pref("javascript.enabled", true, locked);
pref("javascript.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.enabled.1.NOTE", "'Enable JavaScript'", locked);
pref("javascript.options.baselinejit", false, locked);
pref("javascript.options.baselinejit.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.baselinejit.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.jit_trustedprincipals", false, locked);
pref("javascript.options.jit_trustedprincipals.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.jit_trustedprincipals.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT) for extensions'", locked);
pref("javascript.options.jithints", false, locked);
pref("javascript.options.jithints.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.jithints.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.ion", false, locked);
pref("javascript.options.ion.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.ion.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.main_process_disable_jit", true, locked);
pref("javascript.options.main_process_disable_jit.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.main_process_disable_jit.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.native_regexp", false, locked);
pref("javascript.options.native_regexp.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.native_regexp.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("javascript.options.wasm", true, locked);
pref("javascript.options.wasm.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.wasm.1.NOTE", "'Enable WebAssembly (WASM)'", locked);
pref("javascript.options.wasm_optimizingjit", false, locked);
pref("javascript.options.wasm_optimizingjit.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("javascript.options.wasm_optimizingjit.1.NOTE", "'Enable JavaScript Just-in-time Compilation (JIT)'", locked);
pref("media.eme.enabled", false, locked);
pref("media.eme.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("media.eme.enabled.1.NOTE", "'Enable Encrypted Media Extensions (EME)'", locked);
pref("media.mediadrm-widevinecdm.visible", false, locked);
pref("media.mediadrm-widevinecdm.visible.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("media.mediadrm-widevinecdm.visible.1.NOTE", "'Enable Widevine CDM'", locked);
pref("media.peerconnection.enabled", true, locked);
pref("media.peerconnection.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("media.peerconnection.enabled.1.NOTE", "'Enable Widevine CDM'", locked);
pref("network.dns.disableIPv6", false, locked);
pref("network.dns.disableIPv6.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.dns.disableIPv6.1.NOTE", "'Enable IPv6 network connectivity'", locked);
pref("network.http.referer.XOriginPolicy", 0, locked);
pref("network.http.referer.XOriginPolicy.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.http.referer.XOriginPolicy.1.NOTE", "'Cross-origin referer policy'", locked);
pref("network.lna.blocking", true, locked);
pref("network.lna.blocking.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.lna.blocking.1.NOTE", "'Enable LNA blocking'", locked);
pref("network.trr.default_provider_uri", "https://dns.quad9.net/dns-query", locked);
pref("network.trr.default_provider_uri.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.trr.default_provider_uri.1.NOTE", "'DNS over HTTPS'", locked);
pref("network.trr.excluded-domains", "", locked);
pref("network.trr.excluded-domains.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.trr.excluded-domains.1.NOTE", "'DNS over HTTPS'", locked);
pref("network.trr.mode", 3, locked);
pref("network.trr.mode.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.trr.mode.1.NOTE", "'DNS over HTTPS'", locked);
pref("network.trr.uri", "", locked);
pref("network.trr.uri.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("network.trr.uri.1.NOTE", "'DNS over HTTPS'", locked);
pref("pdfjs.disabled", false, locked);
pref("pdfjs.disabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("pdfjs.disabled.1.NOTE", "'Open PDF files externally'", locked);
pref("print.enabled", true, locked);
pref("print.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("print.enabled.1.NOTE", "'Enable printing capabilities'", locked);
pref("privacy.spoof_english", 2, locked);
pref("privacy.spoof_english.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("privacy.spoof_english.1.NOTE", "'Request English versions of webpages'", locked);
pref("privacy.trackingprotection.allow_list.baseline.enabled", true, locked);
pref("privacy.trackingprotection.allow_list.baseline.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("privacy.trackingprotection.allow_list.baseline.enabled.1.NOTE", "'Enhanced Tracking Protection'", locked);
pref("privacy.trackingprotection.allow_list.convenience.enabled", false, locked);
pref("privacy.trackingprotection.allow_list.convenience.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("privacy.trackingprotection.allow_list.convenience.enabled.1.NOTE", "'Enhanced Tracking Protection'", locked);
pref("security.enterprise_roots.enabled", false, locked);
pref("security.enterprise_roots.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("security.enterprise_roots.enabled.1.NOTE", "'Use third party CA certificates'", locked);
pref("signon.autofillForms", false, locked);
pref("signon.autofillForms.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("signon.autofillForms.1.NOTE", "'Autofill in IronFox'", locked);
pref("signon.rememberSignons", false, locked);
pref("signon.rememberSignons.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("signon.rememberSignons.1.NOTE", "'Save passwords'", locked);
pref("svg.disabled", false, locked);
pref("svg.disabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("svg.disabled.1.NOTE", "'Enable Scalable Vector Graphics (SVG)'", locked);
pref("webgl.disabled", false, locked);
pref("webgl.disabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("webgl.disabled.1.NOTE", "'Enable WebGL'", locked);
pref("xpinstall.enabled", false, locked);
pref("xpinstall.enabled.0.NOTE", "Locked in favor of the UI setting:", locked);
pref("xpinstall.enabled.1.NOTE", "'Allow installation of add-ons'", locked);

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
pref("browser.ironfox.services.settings.allowedCollections", "blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,blocklists/plugins,main/addons-manager-settings,main/anti-tracking-url-decoration,main/bounce-tracking-protection-exceptions,main/cookie-banner-rules-list,main/fingerprinting-protection-overrides,main/hijack-blocklists,main/ml-inference-options,main/ml-model-allow-deny-list,main/ml-onnx-runtime,main/partitioning-exempt-urls,main/password-recipes,main/query-stripping,main/remote-permissions,main/tracking-protection-lists,main/third-party-cookie-blocking-exempt-urls,main/translations-identification-models,main/translations-models,main/translations-wasm,main/url-classifier-exceptions,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,security-state/cert-revocations,security-state/ct-logs,security-state/intermediates,security-state/onecrl");
pref("browser.ironfox.services.settings.allowedCollectionsFromDump", "main/ironfox-fingerprinting-protection-overrides-harden,main/ironfox-fingerprinting-protection-overrides-unbreak,main/ironfox-fingerprinting-protection-overrides-unbreak-timezone,blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,main/anti-tracking-url-decoration,main/cookie-banner-rules-list,main/moz-essential-domain-fallbacks,main/ml-inference-options,main/ml-model-allow-deny-list,main/ml-onnx-runtime,main/password-recipes,main/remote-permissions,main/translations-models,main/translations-wasm,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,security-state/intermediates,security-state/onecrl");

/// Set light/dark mode to match system
// We still enable light mode by default, just via a patch for Fenix's UI settings instead
pref("layout.css.prefers-color-scheme.content-override", 2, locked); // [DEFAULT]

/// Expose build options via the `about:config`
// This allows users to easily see what build options we're using, and this makes it easier for us to test and confirm that our options are set as expected

#if defined(ACCESSIBILITY)
    pref("browser.ironfox.build.ACCESSIBILITY", true, locked);
#else
    pref("browser.ironfox.build.ACCESSIBILITY", false, locked);
#endif

pref("browser.ironfox.build.ANDROID_PACKAGE_NAME", "@ANDROID_PACKAGE_NAME@", locked);
pref("browser.ironfox.build.BROWSER_CHROME_URL", "@BROWSER_CHROME_URL@", locked);

#if !defined(EARLY_BETA_OR_EARLIER)
    pref("browser.ironfox.build.EARLY_BETA_OR_EARLIER", false, locked);
#else
    pref("browser.ironfox.build.EARLY_BETA_OR_EARLIER", true, locked);
    pref("0.ERROR.ironfox.EARLY_BETA_OR_EARLIER", "EARLY_BETA_OR_EARLIER should be FALSE, something's wrong!", locked);
#endif

#if !defined(ENABLE_SYSTEM_EXTENSION_DIRS)
    pref("browser.ironfox.build.ENABLE_SYSTEM_EXTENSION_DIRS", false, locked);
#else
    pref("browser.ironfox.build.ENABLE_SYSTEM_EXTENSION_DIRS", true, locked);
    pref("0.ERROR.ironfox.ENABLE_SYSTEM_EXTENSION_DIRS", "ENABLE_SYSTEM_EXTENSION_DIRS should be FALSE, something's wrong!", locked);
#endif

#if !defined(ENABLE_TESTS)
    pref("browser.ironfox.build.ENABLE_TESTS", false, locked);
#else
    pref("browser.ironfox.build.ENABLE_TESTS", true, locked);
    pref("0.ERROR.ironfox.ENABLE_TESTS", "ENABLE_TESTS should be FALSE, something's wrong!", locked);
#endif

#if !defined(ENABLE_WEBDRIVER)
    pref("browser.ironfox.build.ENABLE_WEBDRIVER", false, locked);
#else
    pref("browser.ironfox.build.ENABLE_WEBDRIVER", true, locked);
    pref("0.ERROR.ironfox.ENABLE_WEBDRIVER", "ENABLE_WEBDRIVER should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_ALLOW_ADDON_SIDELOAD)
    pref("browser.ironfox.build.MOZ_ALLOW_ADDON_SIDELOAD", false, locked);
#else
    pref("browser.ironfox.build.MOZ_ALLOW_ADDON_SIDELOAD", true, locked);
    pref("0.ERROR.ironfox.MOZ_ALLOW_ADDON_SIDELOAD", "MOZ_ALLOW_ADDON_SIDELOAD should be FALSE, something's wrong!", locked);
#endif

#if defined(MOZ_ANDROID_CONTENT_SERVICE_ISOLATED_PROCESS)
    pref("browser.ironfox.build.MOZ_ANDROID_CONTENT_SERVICE_ISOLATED_PROCESS", true, locked);
#else
    pref("browser.ironfox.build.MOZ_ANDROID_CONTENT_SERVICE_ISOLATED_PROCESS", false, locked);
#endif

#if !defined(MOZ_ANDROID_GOOGLE_VR)
    pref("browser.ironfox.build.MOZ_ANDROID_GOOGLE_VR", false, locked);
#else
    pref("browser.ironfox.build.MOZ_ANDROID_GOOGLE_VR", true, locked);
    pref("0.ERROR.ironfox.MOZ_ANDROID_GOOGLE_VR", "MOZ_ANDROID_GOOGLE_VR should be FALSE, something's wrong!", locked);
#endif

#if defined(MOZ_ARTIFACT_BUILDS)
    pref("browser.ironfox.build.MOZ_ARTIFACT_BUILDS", true, locked);
#else
    pref("browser.ironfox.build.MOZ_ARTIFACT_BUILDS", false, locked);
#endif

#if !defined(MOZ_ASAN_REPORTER)
    pref("browser.ironfox.build.MOZ_ASAN_REPORTER", false, locked);
#else
    pref("browser.ironfox.build.MOZ_ASAN_REPORTER", true, locked);
    pref("0.ERROR.ironfox.MOZ_ASAN_REPORTER", "MOZ_ASAN_REPORTER should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_AUTH_EXTENSION)
    pref("browser.ironfox.build.MOZ_AUTH_EXTENSION", false, locked);
#else
    pref("browser.ironfox.build.MOZ_AUTH_EXTENSION", true, locked);
    pref("0.ERROR.ironfox.MOZ_AUTH_EXTENSION", "MOZ_AUTH_EXTENSION should be FALSE, something's wrong!", locked);
#endif

#if defined(MOZ_AV1)
    pref("browser.ironfox.build.MOZ_AV1", true, locked);
#else
    pref("browser.ironfox.build.MOZ_AV1", false, locked);
#endif

#if !defined(MOZ_BACKGROUNDTASKS)
    pref("browser.ironfox.build.MOZ_BACKGROUNDTASKS", false, locked);
#else
    pref("browser.ironfox.build.MOZ_BACKGROUNDTASKS", true, locked);
    pref("0.ERROR.ironfox.MOZ_BACKGROUNDTASKS", "MOZ_BACKGROUNDTASKS should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_CRASHREPORTER)
    pref("browser.ironfox.build.MOZ_CRASHREPORTER", false, locked);
#else
    pref("browser.ironfox.build.MOZ_CRASHREPORTER", true, locked);
    pref("0.ERROR.ironfox.MOZ_CRASHREPORTER", "MOZ_CRASHREPORTER should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_DATA_REPORTING)
    pref("browser.ironfox.build.MOZ_DATA_REPORTING", false, locked);
#else
    pref("browser.ironfox.build.MOZ_DATA_REPORTING", true, locked);
    pref("0.ERROR.ironfox.MOZ_DATA_REPORTING", "MOZ_DATA_REPORTING should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_DEBUG)
    pref("browser.ironfox.build.MOZ_DEBUG", false, locked);
#else
    pref("browser.ironfox.build.MOZ_DEBUG", true, locked);
    pref("0.ERROR.ironfox.MOZ_DEBUG", "MOZ_DEBUG should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_DEV_EDITION)
    pref("browser.ironfox.build.MOZ_DEV_EDITION", false, locked);
#else
    pref("browser.ironfox.build.MOZ_DEV_EDITION", true, locked);
    pref("0.ERROR.ironfox.MOZ_DEV_EDITION", "MOZ_DEV_EDITION should be FALSE, something's wrong!", locked);
#endif

#if defined(MOZ_DISABLE_PARENTAL_CONTROLS)
    pref("browser.ironfox.build.MOZ_DISABLE_PARENTAL_CONTROLS", true, locked);
#else
    pref("browser.ironfox.build.MOZ_DISABLE_PARENTAL_CONTROLS", false, locked);
    pref("0.ERROR.ironfox.MOZ_DISABLE_PARENTAL_CONTROLS", "MOZ_DISABLE_PARENTAL_CONTROLS should be TRUE, something's wrong!", locked);
#endif

#if !defined(MOZ_ESR)
    pref("browser.ironfox.build.MOZ_ESR", false, locked);
#else
    pref("browser.ironfox.build.MOZ_ESR", true, locked);
    pref("0.ERROR.ironfox.MOZ_ESR", "MOZ_ESR should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_FFMPEG)
    pref("browser.ironfox.build.MOZ_FFMPEG", false, locked);
#else
    pref("browser.ironfox.build.MOZ_FFMPEG", true, locked);
    pref("0.ERROR.ironfox.MOZ_FFMPEG", "MOZ_FFMPEG should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_GECKO_PROFILER)
    pref("browser.ironfox.build.MOZ_GECKO_PROFILER", false, locked);
#else
    pref("browser.ironfox.build.MOZ_GECKO_PROFILER", true, locked);
    pref("0.ERROR.ironfox.MOZ_GECKO_PROFILER", "MOZ_GECKO_PROFILER should be FALSE, something's wrong!", locked);
#endif

#if defined(MOZ_GECKOVIEW)
    pref("browser.ironfox.build.MOZ_GECKOVIEW", true, locked);
#else
    pref("browser.ironfox.build.MOZ_GECKOVIEW", false, locked);
#endif

#if defined(MOZ_GECKOVIEW_HISTORY)
    pref("browser.ironfox.build.MOZ_GECKOVIEW_HISTORY", true, locked);
#else
    pref("browser.ironfox.build.MOZ_GECKOVIEW_HISTORY", false, locked);
#endif

#if defined(MOZ_GFX_OPTIMIZE_MOBILE)
    pref("browser.ironfox.build.MOZ_GFX_OPTIMIZE_MOBILE", true, locked);
#else
    pref("browser.ironfox.build.MOZ_GFX_OPTIMIZE_MOBILE", false, locked);
    pref("0.ERROR.ironfox.MOZ_GFX_OPTIMIZE_MOBILE", "MOZ_GFX_OPTIMIZE_MOBILE should be TRUE, something's wrong!", locked);
#endif

#if defined(MOZ_GLEAN_ANDROID)
    pref("browser.ironfox.build.MOZ_GLEAN_ANDROID", true, locked);
#else
    pref("browser.ironfox.build.MOZ_GLEAN_ANDROID", false, locked);
#endif

#if defined(MOZ_JXL)
    pref("browser.ironfox.build.MOZ_JXL", true, locked);
#else
    pref("browser.ironfox.build.MOZ_JXL", false, locked);
#endif

#if defined(MOZ_MEMORY)
    pref("browser.ironfox.build.MOZ_MEMORY", true, locked);
#else
    pref("browser.ironfox.build.MOZ_MEMORY", false, locked);
#endif

#if defined(MOZ_NO_SMART_CARDS)
    pref("browser.ironfox.build.MOZ_NO_SMART_CARDS", true, locked);
#else
    pref("browser.ironfox.build.MOZ_NO_SMART_CARDS", false, locked);
#endif

#if !defined(MOZ_NORMANDY)
    pref("browser.ironfox.build.MOZ_NORMANDY", false, locked);
#else
    pref("browser.ironfox.build.MOZ_NORMANDY", true, locked);
    pref("0.ERROR.ironfox.MOZ_NORMANDY", "MOZ_NORMANDY should be FALSE, something's wrong!", locked);
#endif

#if defined(MOZ_PGO)
    pref("browser.ironfox.build.MOZ_PGO", true, locked);
#else
    pref("browser.ironfox.build.MOZ_PGO", false, locked);
#endif

#if defined(MOZ_PLACES)
    pref("browser.ironfox.build.MOZ_PLACES", true, locked);
#else
    pref("browser.ironfox.build.MOZ_PLACES", false, locked);
#endif

#if defined(MOZ_PROXY_BYPASS_PROTECTION)
    pref("browser.ironfox.build.MOZ_PROXY_BYPASS_PROTECTION", true, locked);
#else
    pref("browser.ironfox.build.MOZ_PROXY_BYPASS_PROTECTION", false, locked);
    pref("0.ERROR.ironfox.MOZ_PROXY_BYPASS_PROTECTION", "MOZ_PROXY_BYPASS_PROTECTION should be TRUE, something's wrong!", locked);
#endif

#if defined(MOZ_REPLACE_MALLOC)
    pref("browser.ironfox.build.MOZ_REPLACE_MALLOC", true, locked);
#else
    pref("browser.ironfox.build.MOZ_REPLACE_MALLOC", false, locked);
#endif

#if !defined(MOZ_REQUIRE_SIGNING)
    pref("browser.ironfox.build.MOZ_REQUIRE_SIGNING", false, locked);
#else
    pref("browser.ironfox.build.MOZ_REQUIRE_SIGNING", true, locked);
    pref("0.ERROR.ironfox.MOZ_REQUIRE_SIGNING", "MOZ_REQUIRE_SIGNING should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_SERVICES_HEALTHREPORT)
    pref("browser.ironfox.build.MOZ_SERVICES_HEALTHREPORT", false, locked);
#else
    pref("browser.ironfox.build.MOZ_SERVICES_HEALTHREPORT", true, locked);
    pref("0.ERROR.ironfox.MOZ_SERVICES_HEALTHREPORT", "MOZ_SERVICES_HEALTHREPORT should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_SYSTEM_POLICIES)
    pref("browser.ironfox.build.MOZ_SYSTEM_POLICIES", false, locked);
#else
    pref("browser.ironfox.build.MOZ_SYSTEM_POLICIES", true, locked);
    pref("0.ERROR.ironfox.MOZ_SYSTEM_POLICIES", "MOZ_SYSTEM_POLICIES should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_TELEMETRY_ON_BY_DEFAULT)
    pref("browser.ironfox.build.MOZ_TELEMETRY_ON_BY_DEFAULT", false, locked);
#else
    pref("browser.ironfox.build.MOZ_TELEMETRY_ON_BY_DEFAULT", true, locked);
    pref("0.ERROR.ironfox.MOZ_TELEMETRY_ON_BY_DEFAULT", "MOZ_TELEMETRY_ON_BY_DEFAULT should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_TELEMETRY_REPORTING)
    pref("browser.ironfox.build.MOZ_TELEMETRY_REPORTING", false, locked);
#else
    pref("browser.ironfox.build.MOZ_TELEMETRY_REPORTING", true, locked);
    pref("0.ERROR.ironfox.MOZ_TELEMETRY_REPORTING", "MOZ_TELEMETRY_REPORTING should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_UNSIGNED_APP_SCOPE)
    pref("browser.ironfox.build.MOZ_UNSIGNED_APP_SCOPE", false, locked);
#else
    pref("browser.ironfox.build.MOZ_UNSIGNED_APP_SCOPE", true, locked);
    pref("0.ERROR.ironfox.MOZ_UNSIGNED_APP_SCOPE", "MOZ_UNSIGNED_APP_SCOPE should be FALSE, something's wrong!", locked);
#endif

#if !defined(MOZ_UNSIGNED_SYSTEM_SCOPE)
    pref("browser.ironfox.build.MOZ_UNSIGNED_SYSTEM_SCOPE", false, locked);
#else
    pref("browser.ironfox.build.MOZ_UNSIGNED_SYSTEM_SCOPE", true, locked);
    pref("0.ERROR.ironfox.MOZ_UNSIGNED_SYSTEM_SCOPE", "MOZ_UNSIGNED_SYSTEM_SCOPE should be FALSE, something's wrong!", locked);
#endif

pref("browser.ironfox.build.MOZ_UPDATE_CHANNEL", "@MOZ_UPDATE_CHANNEL@", locked);

#if defined(MOZ_USING_WASM_SANDBOXING)
    pref("browser.ironfox.build.MOZ_USING_WASM_SANDBOXING", true, locked);
#else
    pref("browser.ironfox.build.MOZ_USING_WASM_SANDBOXING", false, locked);
    pref("0.ERROR.ironfox.MOZ_USING_WASM_SANDBOXING", "MOZ_USING_WASM_SANDBOXING should be TRUE, something's wrong!", locked);
#endif

#if defined(MOZ_WEBRTC)
    pref("browser.ironfox.build.MOZ_WEBRTC", true, locked);
#else
    pref("browser.ironfox.build.MOZ_WEBRTC", false, locked);
#endif

#if defined(MOZ_WEBSPEECH)
    pref("browser.ironfox.build.MOZ_WEBSPEECH", true, locked);
#else
    pref("browser.ironfox.build.MOZ_WEBSPEECH", false, locked);
#endif

#if !defined(MOZ_WEBSPEECH_TEST_BACKEND)
    pref("browser.ironfox.build.MOZ_WEBSPEECH_TEST_BACKEND", false, locked);
#else
    pref("browser.ironfox.build.MOZ_WEBSPEECH_TEST_BACKEND", true, locked);
    pref("0.ERROR.ironfox.MOZ_WEBSPEECH_TEST_BACKEND", "MOZ_WEBSPEECH_TEST_BACKEND should be FALSE, something's wrong!", locked);
#endif

#if defined(MOZILLA_OFFICIAL)
    pref("browser.ironfox.build.MOZILLA_OFFICIAL", true, locked);
#else
    pref("browser.ironfox.build.MOZILLA_OFFICIAL", false, locked);
    pref("0.ERROR.ironfox.MOZILLA_OFFICIAL", "MOZILLA_OFFICIAL should be TRUE, something's wrong!", locked);
#endif

#if !defined(NIGHTLY_BUILD)
    pref("browser.ironfox.build.NIGHTLY_BUILD", false, locked);
#else
    pref("browser.ironfox.build.NIGHTLY_BUILD", true, locked);
    pref("0.ERROR.ironfox.NIGHTLY_BUILD", "NIGHTLY_BUILD should be FALSE, something's wrong!", locked);
#endif

#if defined(NS_PRINTING)
    pref("browser.ironfox.build.NS_PRINTING", true, locked);
#else
    pref("browser.ironfox.build.NS_PRINTING", false, locked);
#endif

#if defined(RELEASE_OR_BETA)
    pref("browser.ironfox.build.RELEASE_OR_BETA", true, locked);
#else
    pref("browser.ironfox.build.RELEASE_OR_BETA", false, locked);
    pref("0.ERROR.ironfox.RELEASE_OR_BETA", "RELEASE_OR_BETA should be TRUE, something's wrong!", locked);
#endif

pref("browser.ironfox.applied", true, locked);
