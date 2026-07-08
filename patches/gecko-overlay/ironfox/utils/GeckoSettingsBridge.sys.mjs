// IronFox GeckoSettingsBridge (Receiver)

const lazy = {};

ChromeUtils.defineESModuleGetters(lazy, {
  IFPrefUtils: "moz-src:///ironfox/utils/IFPrefUtils.sys.mjs",
  RFPHelper:   "resource://gre/modules/RFPHelper.sys.mjs",
});

ChromeUtils.defineLazyGetter(lazy, "log", () => {
  let { ConsoleAPI } = ChromeUtils.importESModule(
    "resource://gre/modules/Console.sys.mjs"
  );
  return new ConsoleAPI({
    prefix: "GeckoSettingsBridge",
    maxLogLevel: "warn",
    maxLogLevelPref: "browser.ironfox.geckoSettingsBridge.loglevel",
  });
});

export const GeckoSettingsBridge = {
  /**
   * Set a boolean Gecko preference backed by a UI setting
   *
   * @param {string} pref - Preference name
   * @param {boolean} value - Preference value
   */
  setBoolPref(pref, value) {
    // Some prefs require special handling, so handle those first
    if (pref == "browser.ironfox.fenix.accessibilityEnabled") {
      setAccessibilityEnabled(value);
    } else if (pref == "browser.ironfox.fenix.ipv6Enabled") {
      lazy.IFPrefUtils.setAndLockBoolPref("network.dns.disableIPv6", !value);
    } else if (pref == "browser.ironfox.fenix.javascriptJitEnabled") {
      setJITEnabled(value);
    } else if (pref == "browser.ironfox.fenix.safeBrowsingEnabled") {
      setSafeBrowsingEnabled(value);
    } else if (pref == "browser.ironfox.fenix.spoofEnglish") {
      setSpoofEnglishEnabled(value);
    } else if (pref == "browser.ironfox.fenix.svgEnabled") {
      lazy.IFPrefUtils.setAndLockBoolPref("svg.disabled", !value);
    } else if (pref == "browser.ironfox.fenix.translationsEnabled") {
      setTranslationsEnabled(value);
    };

    // Check if the pref is backed by a UI setting
    if (boolPrefHasUISetting(pref)) {
      lazy.IFPrefUtils.setAndLockBoolPref(pref, value);
    } else if (!canOverrideBoolPref(pref) || lazy.IFPrefUtils.prefIsLocked(pref)) {
      // If we're blocked from overriding the pref, leave it alone
      lazy.log.warn(
        `setBoolPref: Blocked attempt to override forbidden pref (${pref}) to value: ${value}`
      );
    } else {
      lazy.IFPrefUtils.setDefaultBoolPref(pref, value);
    };
  },

  /**
   * Set an integer Gecko preference backed by a UI setting
   *
   * @param {string} pref - Preference name
   * @param {integer} value - Preference value
   */
  setIntPref(pref, value) {
    // Some prefs require special handling, so handle those first
    if (pref === "network.trr.mode") {
      setDohMode(value);
    };

    // Check if the pref is backed by a UI setting
    if (intPrefHasUISetting(pref)) {
      lazy.IFPrefUtils.setAndLockIntPref(pref, value);
    } else if (!canOverrideIntPref(pref) || lazy.IFPrefUtils.prefIsLocked(pref)) {
      // If we're blocked from overriding the pref, leave it alone
      lazy.log.warn(
        `setIntPref: Blocked attempt to override forbidden pref (${pref}) to value: ${value}`
      );
    } else {
      lazy.IFPrefUtils.setDefaultIntPref(pref, value);
    };
  },

  /**
   * Set a string Gecko preference backed by a UI setting
   *
   * @param {string} pref - Preference name
   * @param {string} value - Preference value
   */
  setStringPref(pref, value) {
    // Some prefs require special handling, so handle those first
    if (pref == "browser.ironfox.fenix.autoplayBlockingPolicy") {
      setAutoplayBlockingPolicy(value);
    } else if (pref == "browser.ironfox.fenix.prefersColorScheme") {
      setPreferredWebsiteAppearance(value);
    } else if (pref == "browser.ironfox.fenix.refererXOriginPolicy") {
      setRefererXOriginPolicy(value);
    } else if (pref == "network.trr.uri") {
      setDohAddress(value);
      return;
    };

    // Check if the pref is backed by a UI setting
    if (stringPrefHasUISetting(pref)) {
      lazy.IFPrefUtils.setAndLockStringPref(pref, value);
    } else if (!canOverrideStringPref(pref) || lazy.IFPrefUtils.prefIsLocked(pref)) {
      // If we're blocked from overriding the pref, leave it alone
      lazy.log.warn(
        `setStringPref: Blocked attempt to override forbidden pref (${pref}) to value: ${value}`
      );
    } else {
      // Set our preference
      lazy.IFPrefUtils.setDefaultStringPref(pref, value);
    };
  },

  /**
   * Initialize a Gecko preference that is backed by a UI setting
   *
   * @param {string} pref - Preference name
   */
  initPref(pref) {
    if (!canOverridePref(pref)) {
      // If we're blocked from overriding the pref, leave it alone
      lazy.log.warn(
        `initPref: Blocked attempt to lock forbidden pref: ${pref}`
      );
    } else if (!prefHasUISetting(pref)) {
      // If the pref is not backed by a UI setting, leave it alone
      lazy.log.warn(
        `initPref: Blocked attempt to lock pref without UI setting: ${pref}`
      );
    } else {
      // Lock our preference
      if (lazy.IFPrefUtils.prefHasDefaultValue(pref)) {
        lazy.IFPrefUtils.lockPref(pref);
      };
      lazy.log.debug(
        `initPref: Initialized pref: ${pref}`
      );
    };
  },

  /**
   * Check if the autoconfig mechanism is allowed to set a (default) boolean preference
   * 
   * This essentially controls whether a pref is allowed to be set by us/Phoenix (at `ironfox.cfg`)
   * This is needed because a few prefs controlled by GeckoRuntimeSettings appear to be set before `ironfox.cfg` is parsed, and
   * are thus overriden each launch - highly problematic for the ones we/Mozilla expose as UI settings
   *
   * @param {string} pref - Name of the preference to check
   * @return {boolean} - Returns `true` if the preference can be set; `false` otherwise
   */
  autoconfCanSetBoolPref(pref) {
    // If a pref doesn't have a UI setting, it should always be allowed
    if (!boolPrefHasUISetting(pref)) {
      return true;
    };

    // If GeckoRuntimeSettings isn't allowed to override a pref, it should always be allowed
    if (!canOverrideBoolPref(pref)) {
      return true;
    };

    // If the pref lacks a default value, it should always be allowed
    if (!lazy.IFPrefUtils.prefHasDefaultValue(pref)) {
      return true;
    };

    // Otherwise, block it...
    lazy.log.warn(
      `autoconfCanSetBoolPref: Blocked attempt to set pref: ${pref}`
    );
    return false;
  },

  /**
   * Check if the autoconfig mechanism is allowed to set a (default) integer preference
   * 
   * This essentially controls whether a pref is allowed to be set by us/Phoenix (at `ironfox.cfg`)
   * This is needed because a few prefs controlled by GeckoRuntimeSettings appear to be set before `ironfox.cfg` is parsed, and
   * are thus overriden each launch - highly problematic for the ones we/Mozilla expose as UI settings
   *
   * @param {string} pref - Name of the preference to check
   * @return {boolean} - Returns `true` if the preference can be set; `false` otherwise
   */
  autoconfCanSetIntPref(pref) {
    // If a pref doesn't have a UI setting, it should always be allowed
    if (!intPrefHasUISetting(pref)) {
      return true;
    };

    // If GeckoRuntimeSettings isn't allowed to override a pref, it should always be allowed
    if (!canOverrideIntPref(pref)) {
      return true;
    };

    // If the pref lacks a default value, it should always be allowed
    if (!lazy.IFPrefUtils.prefHasDefaultValue(pref)) {
      return true;
    };

    // Otherwise, block it...
    lazy.log.warn(
      `autoconfCanSetIntPref: Blocked attempt to set pref: ${pref}`
    );
    return false;
  },

  /**
   * Check if the autoconfig mechanism is allowed to set a (default) string preference
   * 
   * This essentially controls whether a pref is allowed to be set by us/Phoenix (at `ironfox.cfg`)
   * This is needed because a few prefs controlled by GeckoRuntimeSettings appear to be set before `ironfox.cfg` is parsed, and
   * are thus overriden each launch - highly problematic for the ones we/Mozilla expose as UI settings
   *
   * @param {string} pref - Name of the preference to check
   * @return {boolean} - Returns `true` if the preference can be set; `false` otherwise
   */
  autoconfCanSetStringPref(pref) {
    // If a pref doesn't have a UI setting, it should always be allowed
    if (!stringPrefHasUISetting(pref)) {
      return true;
    };

    // If GeckoRuntimeSettings isn't allowed to override a pref, it should always be allowed
    if (!canOverrideStringPref(pref)) {
      return true;
    };

    // If the pref lacks a default value, it should always be allowed
    if (!lazy.IFPrefUtils.prefHasDefaultValue(pref)) {
      return true;
    };

    // Otherwise, block it...
    lazy.log.warn(
      `autoconfCanSetStringPref: Blocked attempt to set pref: ${pref}`
    );
    return false;
  },
};

// Helpers

/**
 * Control Accessibility Services
 *
 * @param {boolean} value - Whether Accessibility Services should be enabled or disabled
 */
function setAccessibilityEnabled(value) {
  // If Accessibility Services are enabled, the pref should be unlocked,
  // so that users can set it to 0 or -1
  const setPref =
    value === true
      ? lazy.IFPrefUtils.setAndUnlockIntPref
      : lazy.IFPrefUtils.setAndLockIntPref

  // Convert our value
  const intVal =
    value === true
      ? 0
      : 1

  setPref("accessibility.force_disabled", intVal);
};

/**
 * Control JIT
 *
 * @param {boolean} value - Whether the JITs should be enabled or disabled
 */
function setJITEnabled(value) {
  // If JIT is enabled, the prefs should be unlocked,
  // because users may prefer to enable/disable specific JITs individually
  const setPref =
    value === true
      ? lazy.IFPrefUtils.setAndUnlockBoolPref
      : lazy.IFPrefUtils.setAndLockBoolPref

  setPref("javascript.options.baselinejit", value);
  setPref("javascript.options.ion", value);
  setPref("javascript.options.jithints", value);
  setPref("javascript.options.native_regexp", value);
  setPref("javascript.options.wasm_optimizingjit", value);
};

/**
 * Control Safe Browsing
 *
 * @param {boolean} value - Whether Safe Browsing should be enabled or disabled
 */
function setSafeBrowsingEnabled(value) {
  // If Safe Browsing is disabled, the prefs should be unlocked,
  // because users may prefer to enable/disable specific protections individually
  const setPref =
    value === false
      ? lazy.IFPrefUtils.setAndUnlockBoolPref
      : lazy.IFPrefUtils.setAndLockBoolPref

  setPref("browser.safebrowsing.malware.enabled", value);
  setPref("browser.safebrowsing.phishing.enabled", value);
};

/**
 * Control locale spoofing
 *
 * @param {boolean} value - Whether locale spoofing should be enabled or disabled
 */
function setSpoofEnglishEnabled(value) {
  // Convert our value
  const intVal =
    value === false
      ? 0
      : 2

  lazy.IFPrefUtils.setAndLockIntPref("privacy.spoof_english", intVal);
  lazy.RFPHelper._handleSpoofEnglishChanged();
};

/**
 * Control Firefox Translations
 *
 * @param {boolean} value - Whether Firefox Translations should be enabled or disabled
 */
function setTranslationsEnabled(value) {
  // Convert our value
  const stringVal =
    value === false
      ? "blocked"
      : "enabled"

  lazy.IFPrefUtils.setAndLockBoolPref("browser.translations.enable", value);
  lazy.IFPrefUtils.setAndLockBoolPref("browser.translations.simulateUnsupportedEngine", !value);
  lazy.IFPrefUtils.setAndLockStringPref("browser.ai.control.translations", stringVal);
};

/**
 * Set the media autoplay blocking policy
 * 
 * Supported values are:
 *  - "click-to-play" (2)
 *  - "sticky" (0)
 *  - "transient" (1) - Default
 *
 * @param {string} policy - Autoplay blocking policy
 */
function setAutoplayBlockingPolicy(policy) {
  let policyValue = 1;
  if (policy === "click-to-play") {
    policyValue = 2;
  } else if (policy === "sticky") {
    policyValue = 0;
  } else if (policy !== "transient") {
    throw new Error(`setAutoplayBlockingPolicy: Invalid policy: ${policy}`);
  };
  lazy.IFPrefUtils.setAndLockIntPref("media.autoplay.blocking_policy", policyValue);
};

/**
 * Set the preferred website color scheme
 * 
 * Supported values are:
 *  - "browser" (2)
 *  - "dark" (0)
 *  - "light" (1) - Default
 *
 * @param {string} scheme - Color scheme
 */
function setPreferredWebsiteAppearance(scheme) {
  let schemeValue = 1;
  if (scheme === "browser") {
    schemeValue = 2;
  } else if (scheme === "dark") {
    schemeValue = 0;
  } else if (scheme !== "light") {
    throw new Error(`setPreferredWebsiteAppearance: Invalid scheme: ${scheme}`);
  };
  lazy.IFPrefUtils.setAndLockIntPref("layout.css.prefers-color-scheme.content-override", schemeValue);
};

/**
 * Set the cross-origin referer policy
 * 
 * Supported values are:
 *  - "base-domains-match" (1)
 *  - "hosts-match" (2)
 *  - "always" (0) - Default
 *
 * @param {string} policy - Cross-origin referer policy
 */
function setRefererXOriginPolicy(policy) {
  let policyValue = 0;
  if (policy === "base-domains-match") {
    policyValue = 1;
  } else if (policy === "hosts-match") {
    policyValue = 2;
  } else if (policy !== "always") {
    throw new Error(`setRefererXOriginPolicy: Invalid policy: ${policy}`);
  };
  lazy.IFPrefUtils.setAndLockIntPref("network.http.referer.XOriginPolicy", policyValue);
};

/**
 * Set the DNS over HTTPS (DoH) address
 *
 * @param {string} address - DoH address
 */
function setDohAddress(address) {
  const currentMode = lazy.IFPrefUtils.getIntPref("network.trr.mode");
  if (currentMode === 0 || currentMode === 5) {
    // If TRR is set to the default mode (or disabled), we want to set the DoH provider to an empty string,
    // to ensure that we only use the system/network DNS for DoH
    lazy.IFPrefUtils.setAndLockStringPref("network.trr.uri", "");
    lazy.IFPrefUtils.setAndLockStringPref("network.trr.bootstrapAddr", "");
    return;
  };

  lazy.IFPrefUtils.setAndLockStringPref("network.trr.uri", address);

  if (lazy.IFPrefUtils.getBoolPref("browser.phoenix.trr.autoBootstrap") && address !== '') {
    // If we have an address, we also need to update the DoH bootstrap address
    setDohBootstrap(address);
  } else {
    // Otherwise, just ensure `network.trr.bootstrapAddr` is unlocked and empty
    lazy.IFPrefUtils.setAndUnlockStringPref("network.trr.bootstrapAddr", "");
  };
};

/**
 * Set the DNS over HTTPS (DoH) mode
 *
 * @param {integer} mode - DoH mode
 */
function setDohMode(mode) {
  // Get the current mode
  const currentMode = lazy.IFPrefUtils.getIntPref("network.trr.mode");

  // If TRR is set to the default mode, we want to set the DoH provider to an empty string,
  // to ensure that we only use the system/network DNS for DoH
  if (mode === 0 || mode === 5) {
    lazy.IFPrefUtils.setAndLockStringPref("network.trr.uri", "");
    lazy.IFPrefUtils.setAndLockStringPref("network.trr.bootstrapAddr", "");
  } else if (currentMode === 0 || currentMode === 5) {
    // To match upstream behavior, if users switch *from* modes 0 or 5, switch back to the default provider
    const defaultProvider = lazy.IFPrefUtils.getStringPref("network.trr.default_provider_uri");
    lazy.IFPrefUtils.setAndLockStringPref("network.trr.uri", defaultProvider);
    setDohBootstrap(defaultProvider);
  };
};

/**
 * Automatically set the DNS over HTTPS (DoH) bootstrap IP address
 * 
 * @param {string} address - DoH address
 */
function setDohBootstrap(address) {
  // Check if we should use the fall-back IP instead of the primary IP
  const useFallback = lazy.IFPrefUtils.getBoolPref("browser.phoenix.trr.autoBootstrap.useFallback");

  // Determine our bootstrap IP
  let bootstrapIP = '';
  if (address === "https://base.dns.mullvad.net/dns-query" ||
   address === "https://base.dns.mullvad.net:443/dns-query") {
    bootstrapIP = '194.242.2.4';
  } else if (address === "https://dns.mullvad.net/dns-query" ||
   address === "https://dns.mullvad.net:443/dns-query") {
    bootstrapIP = '194.242.2.2';
  } else if (address === "https://mozilla.cloudflare-dns.com/dns-query" ||
   address === "https://mozilla.cloudflare-dns.com:443/dns-query" ||
   address === "https://cloudflare-dns.com/dns-query" ||
   address === "https://cloudflare-dns.com:443/dns-query" ||
   address === "https://dns.cloudflare.com/dns-query" ||
   address === "https://dns.cloudflare.com:443/dns-query") {
    if (useFallback) {
      bootstrapIP = '1.0.0.1';
    } else {
      bootstrapIP = '1.1.1.1';
    };
  } else if (address === "https://security.cloudflare-dns.com/dns-query" ||
   address === "https://security.cloudflare-dns.com:443/dns-query") {
    if (useFallback) {
      bootstrapIP = '1.0.0.2';
    } else {
      bootstrapIP = '1.1.1.2';
    };
  } else if (address === "https://noads.joindns4.eu/dns-query" ||
   address === "https://noads.joindns4.eu:443/dns-query") {
    bootstrapIP = '86.54.11.13';
  } else if (address === "https://protective.joindns4.eu/dns-query" ||
   address === "https://protective.joindns4.eu:443/dns-query") {
    bootstrapIP = '86.54.11.1';
  } else if (address === "https://unfiltered.joindns4.eu/dns-query" ||
   address === "https://unfiltered.joindns4.eu:443/dns-query") {
    bootstrapIP = '86.54.11.100';
  };

  // Set our bootstrap IP
  lazy.IFPrefUtils.setAndLockStringPref("network.trr.bootstrapAddr", bootstrapIP);
};

/**
  * Check if a boolean Gecko preference is backed by a UI setting
  *
  * @param {string} pref - Preference name
  * @return {boolean} - Returns `true` if the preference is backed by a UI setting; `false` otherwise
  */
function boolPrefHasUISetting(pref) {
  const boolPrefs = [
    // Fenix
    "browser.cache.disk.enable",
    "browser.ironfox.fenix.accessibilityEnabled",
    "browser.ironfox.fenix.ipv6Enabled",
    "browser.ironfox.fenix.javascriptJitEnabled",
    "browser.ironfox.fenix.safeBrowsingEnabled",
    "browser.ironfox.fenix.spoofEnglish",
    "browser.ironfox.fenix.svgEnabled",
    "browser.ironfox.fenix.translationsEnabled",
    "browser.ironfox.fingerprintingProtection.mozillaOverrides.enabled",
    "browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled",
    "browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled",
    "browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled",
    "browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled",
    "browser.ironfox.onboardingCompleted",
    "browser.ironfox.webgl.disabled",
    "browser.privatebrowsing.autostart",
    "extensions.formautofill.addresses.enabled",
    "extensions.formautofill.creditCards.enabled",
    "javascript.enabled",
    "javascript.options.jit_trustedprincipals",
    "javascript.options.wasm",
    "media.peerconnection.enabled",
    "pdfjs.disabled",
    "print.enabled",
    "signon.rememberSignons",
    "xpinstall.enabled",

    // GeckoRuntimeSettings
    "browser.contentblocking.database.enabled",
    "browser.translations.automaticallyPopup",
    "browser.ui.zoom.force-user-scalable",
    "consoleservice.logcat",
    "devtools.console.stdout.chrome",
    "dom.security.https_only_mode",
    "dom.security.https_only_mode_pbm",
    "network.lna.block_trackers",
    "network.lna.blocking",
    "network.lna.enabled",
    "privacy.trackingprotection.allow_list.baseline.enabled",
    "privacy.trackingprotection.allow_list.convenience.enabled",
    "security.enterprise_roots.enabled",
    "signon.autofillForms",
  ];
  return boolPrefs.includes(pref);
};

/**
  * Check if an integer Gecko preference is backed by a UI setting
  *
  * @param {string} pref - Preference name
  * @return {boolean} - Returns `true` if the preference is backed by a UI setting; `false` otherwise
  */
function intPrefHasUISetting(pref) {
  const intPrefs = [
    // GeckoRuntimeSettings
    "cookiebanners.service.mode.privateBrowsing",
    "font.size.inflation.minTwips",
    "network.trr.mode",
  ];
  return intPrefs.includes(pref);
};

/**
  * Check if a string Gecko preference is backed by a UI setting
  *
  * @param {string} pref - Preference name
  * @return {boolean} - Returns `true` if the preference is backed by a UI setting; `false` otherwise
  */
function stringPrefHasUISetting(pref) {
  const stringPrefs = [
    // Fenix
    "browser.ironfox.fenix.autoplayBlockingPolicy",
    "browser.ironfox.fenix.prefersColorScheme",
    "browser.ironfox.fenix.refererXOriginPolicy",

    // GeckoView
    "geckoview.logging",
    "network.trr.excluded-domains",
    "network.trr.uri",
    "signon.firefoxRelay.feature",
  ];
  return stringPrefs.includes(pref);
};

/**
  * Check if a Gecko preference is backed by a UI setting
  *
  * @param {string} pref - Preference name
  * @return {boolean} - Returns `true` if the preference is backed by a UI setting; `false` otherwise
  */
function prefHasUISetting(pref) {
  return boolPrefHasUISetting(pref) || intPrefHasUISetting(pref) || stringPrefHasUISetting(pref);
};

/**
  * Check if a boolean Gecko preference that is not backed by a UI setting can have its default value overriden
  * 
  * This ensures that the default values for preferences set by us (or Phoenix) at `ironfox.cfg`
  * are not overriden (by ex. GeckoRuntimeSettings)
  *
  * @param {string} pref - Name of the preference to check
  * @return {boolean} - Returns `true` if the preference can be overriden; `false` otherwise
  */
function canOverrideBoolPref(pref) {
  // This list should include preferences set/defined by us and/or Phoenix (at `ironfox.cfg`)
  // If a pref is NOT listed here, it can still be overriden by users, it just means it's default value will be set by ex. GeckoRuntimeSettings instead of us
  const forbiddenBoolPrefs = [
    "browser.crashReports.requestedNeverShowAgain",
    "browser.safebrowsing.malware.enabled",
    "browser.safebrowsing.phishing.enabled",
    "browser.safebrowsing.provider.google4.dataSharing.enabled",
    "browser.safebrowsing.provider.google5.enabled",
    "browser.safebrowsing.realTime.enabled",
    "browser.safebrowsing.realTime.simulation.enabled",
    "cookiebanners.service.detectOnly",
    "cookiebanners.service.enableGlobalRules",
    "cookiebanners.service.enableGlobalRules.subFrames",
    "devtools.debugger.remote-enabled",
    "extensions.webapi.enabled",
    "fission.autostart",
    "geckoview.console.enabled",
    "general.aboutConfig.enable",
    "javascript.enabled",
    "javascript.options.mem.gc_parallel_marking",
    "javascript.options.use_fdlibm_for_sin_cos_tan",
    "network.android_doh.autoselect_enabled",
    "network.cookie.cookieBehavior.optInPartitioning",
    "network.cookie.cookieBehavior.optInPartitioning.pbmode",
    "network.fetchpriority.enabled",
    "network.http.http3.enable_kyber",
    "privacy.annotate_channels.strict_list.enabled",
    "privacy.baselineFingerprintingProtection",
    "privacy.fingerprintingProtection",
    "privacy.fingerprintingProtection.pbmode",
    "privacy.globalprivacycontrol.enabled",
    "privacy.globalprivacycontrol.functionality.enabled",
    "privacy.globalprivacycontrol.pbmode.enabled",
    "privacy.purge_trackers.enabled",
    "privacy.query_stripping.enabled",
    "privacy.query_stripping.enabled.pbmode",
    "privacy.socialtracking.block_cookies.enabled",
    "privacy.trackingprotection.annotate_channels",
    "privacy.trackingprotection.cryptomining.enabled",
    "privacy.trackingprotection.emailtracking.enabled",
    "privacy.trackingprotection.emailtracking.pbmode.enabled",
    "privacy.trackingprotection.fingerprinting.enabled",
    "privacy.trackingprotection.harmfuladdon.enabled",
    "privacy.trackingprotection.socialtracking.enabled",
    "security.tls.enable_kyber",
  ];

  return !forbiddenBoolPrefs.includes(pref);
};

/**
  * Check if an integer Gecko preference that is not backed by a UI setting can have its default value overriden
  * 
  * This ensures that the default values for preferences set by us (or Phoenix) at `ironfox.cfg`
  * are not overriden (by ex. GeckoRuntimeSettings)
  *
  * @param {string} pref - Name of the preference to check
  * @return {boolean} - Returns `true` if the preference can be overriden; `false` otherwise
  */
function canOverrideIntPref(pref) {
  // This list should include preferences set/defined by us and/or Phoenix (at `ironfox.cfg`)
  // If a pref is NOT listed here, it can still be overriden by users, it just means it's default value will be set by ex. GeckoRuntimeSettings instead of us
  const forbiddenIntPrefs = [
    "cookiebanners.service.mode",
    "dom.ipc.processCount",
    "extensions.webapi.enabled",
    "fission.webContentIsolationStrategy",
    "network.cookie.cookieBehavior",
    "network.cookie.cookieBehavior.pbmode",
    "privacy.bounceTrackingProtection.mode",
    "security.pki.certificate_transparency.mode",
    "toolkit.telemetry.user_characteristics_ping.current_version",
  ];

  return !forbiddenIntPrefs.includes(pref);
};

/**
  * Check if a string Gecko preference that is not backed by a UI setting can have its *default* value overriden
  * 
  * This ensures that the default values for preferences set by us (or Phoenix) at `ironfox.cfg`
  * are not overriden (by ex. GeckoRuntimeSettings)
  *
  * @param {string} pref - Name of the preference to check
  * @return {boolean} - Returns `true` if the preference can be overriden; `false` otherwise
  */
function canOverrideStringPref(pref) {
  // This list should include preferences set/defined by us and/or Phoenix (at `ironfox.cfg`)
  // If a pref is NOT listed here, it can still be overriden by users, it just means it's default value will be set by ex. GeckoRuntimeSettings instead of us
  const forbiddenStringPrefs = [
    "browser.contentblocking.category",
    "browser.safebrowsing.provider.google.advisoryName",
    "browser.safebrowsing.provider.google.gethashURL",
    "browser.safebrowsing.provider.google.lists",
    "browser.safebrowsing.provider.google.reportMalwareMistakeURL",
    "browser.safebrowsing.provider.google.reportPhishMistakeURL",
    "browser.safebrowsing.provider.google.reportURL",
    "browser.safebrowsing.provider.google.updateURL",
    "browser.safebrowsing.provider.google4.advisoryName",
    "browser.safebrowsing.provider.google4.dataSharingURL",
    "browser.safebrowsing.provider.google4.gethashURL",
    "browser.safebrowsing.provider.google4.reportMalwareMistakeURL",
    "browser.safebrowsing.provider.google4.reportPhishMistakeURL",
    "browser.safebrowsing.provider.google4.reportURL",
    "browser.safebrowsing.provider.google4.updateURL",
    "browser.safebrowsing.provider.google5.advisoryName",
    "browser.safebrowsing.provider.google5.gethashURL",
    "browser.safebrowsing.provider.google5.reportMalwareMistakeURL",
    "browser.safebrowsing.provider.google5.reportPhishMistakeURL",
    "browser.safebrowsing.provider.google5.reportURL",
    "browser.safebrowsing.provider.google5.updateURL",
    "network.security.ports.banned",
    "network.trr.default_provider_uri",
    "privacy.baselineFingerprintingProtection.overrides",
    "privacy.fingerprintingProtection.overrides",
    "privacy.query_stripping.allow_list",
    "privacy.query_stripping.strip_list",
    "security.pki.crlite_channel",
    "urlclassifier.malwareTable",
    "urlclassifier.phishTable",
  ];

  return !forbiddenStringPrefs.includes(pref);
};

/**
  * Check if a Gecko preference that is not backed by a UI setting can have its *default* value overriden
  * 
  * This ensures that the default values for preferences set by us (or Phoenix) at `ironfox.cfg`
  * are not overriden (by ex. GeckoRuntimeSettings)
  *
  * @param {string} pref - Name of the preference to check
  * @return {boolean} - Returns `true` if the preference can be overriden; `false` otherwise
  */
function canOverridePref(pref) {
  return canOverrideBoolPref(pref) || canOverrideIntPref(pref) || canOverrideStringPref(pref);
};
