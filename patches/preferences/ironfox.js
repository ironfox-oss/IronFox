
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
pref("browser.ironfox.services.settings.allowedCollections", "blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,blocklists/plugins,main/addons-manager-settings,main/anti-tracking-url-decoration,main/bounce-tracking-protection-exceptions,main/cookie-banner-rules-list,main/fingerprinting-protection-overrides,main/hijack-blocklists,main/ml-inference-options,main/ml-model-allow-deny-list,main/ml-onnx-runtime,main/partitioning-exempt-urls,main/password-recipes,main/query-stripping,main/remote-permissions,main/tracking-protection-lists,main/third-party-cookie-blocking-exempt-urls,main/translations-identification-models,main/translations-models,main/translations-wasm,main/url-classifier-exceptions,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,security-state/cert-revocations,security-state/ct-logs,security-state/intermediates,security-state/onecrl");
pref("browser.ironfox.services.settings.allowedCollectionsFromDump", "main/ironfox-fingerprinting-protection-overrides,blocklists/addons,blocklists/addons-bloomfilters,blocklists/gfx,main/anti-tracking-url-decoration,main/cookie-banner-rules-list,main/moz-essential-domain-fallbacks,main/ml-inference-options,main/ml-model-allow-deny-list,main/ml-onnx-runtime,main/password-recipes,main/remote-permissions,main/translations-models,main/translations-wasm,main/url-classifier-skip-urls,main/url-parser-default-unknown-schemes-interventions,security-state/intermediates,security-state/onecrl");

/// Set light/dark mode to match system
// We still enable light mode by default, just via a patch for Fenix's UI settings instead
pref("layout.css.prefers-color-scheme.content-override", 2); // [DEFAULT]

/// Skip ETP allow list migration so that privacy.trackingprotection.allow_list.baseline.enabled isn't overriden to false on first launch
// https://searchfox.org/mozilla-central/rev/59cf9b74/netwerk/url-classifier/UrlClassifierExceptionListService.sys.mjs#236
// (We'll only need this temporarily, added to Phoenix for next release)
pref("privacy.trackingprotection.allow_list.hasMigratedCategoryPrefs", true, locked);

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
