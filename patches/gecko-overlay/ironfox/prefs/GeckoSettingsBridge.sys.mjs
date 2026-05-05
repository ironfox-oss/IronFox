// IronFox GeckoSettingsBridge (Receiver)

const lazy = {};

ChromeUtils.defineESModuleGetters(lazy, {
  RFPHelper: "resource://gre/modules/RFPHelper.sys.mjs",
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

export var GeckoSettingsBridge = {
    setPref(pref, value, type) {
        if (type === "int") {
            if (!Number.isInteger(value)) {
                throw new Error(`Non-integer value for ${pref}`);
            }
        } else if (type !== "boolean" && type !== "string") {
            throw new Error(`Invalid type for ${pref}`);
        };
        lazy.log.debug(
            `Unlocking ${pref}`
        );
        if (Services.prefs.prefIsLocked(pref) === true) {
            Services.prefs.unlockPref(pref);
        };
        lazy.log.debug(
            `Setting ${pref} to ${value}`
        );
        if (pref === "browser.ironfox.fenix.accessibilityEnabled") {
            this.setAccessibilityEnabled(value);
        } else if (pref === "browser.ironfox.fenix.alwaysUsePrivateBrowsing") {
            this.setAlwaysUsePrivateBrowsing(value);
        } else if (pref === "browser.ironfox.fenix.autoplayBlockingPolicy") {
            this.setAutoplayBlockingPolicy(value);
        } else if (pref === "browser.ironfox.fenix.cacheEnabled") {
            this.setCacheEnabled(value);
        } else if (pref === "browser.ironfox.fenix.fppOverridesIronFoxEnabled") {
            this.setFPPOverridesIronFoxEnabled(value);
        } else if (pref === "browser.ironfox.fenix.fppOverridesIronFoxTimezoneEnabled") {
            this.setFPPOverridesIronFoxTimezoneEnabled(value);
        } else if (pref === "browser.ironfox.fenix.fppOverridesIronFoxWebGLEnabled") {
            this.setFPPOverridesIronFoxWebGLEnabled(value);
        } else if (pref === "browser.ironfox.fenix.fppOverridesMozillaEnabled") {
            this.setFPPOverridesMozillaEnabled(value);
        } else if (pref === "browser.ironfox.fenix.ipv6Enabled") {
            this.setIPv6Enabled(value);
        } else if (pref === "browser.ironfox.fenix.ironFoxOnboardingCompleted") {
            this.setIronFoxOnboardingCompleted(value);
        } else if (pref === "browser.ironfox.fenix.javascriptEnabled") {
            this.setJavaScriptEnabled(value);
        } else if (pref === "browser.ironfox.fenix.javascriptJitEnabled") {
            this.setJITEnabled(value);
        } else if (pref === "browser.ironfox.fenix.javascriptJitTrustedPrincipalsEnabled") {
            this.setJITTrustedPrincipalsEnabled(value);
        } else if (pref === "browser.ironfox.fenix.pdfjsDisabled") {
            this.setPDFjsDisabled(value);
        } else if (pref === "browser.ironfox.fenix.prefersColorScheme") {
            this.setPreferredWebsiteAppearance(value);
        } else if (pref === "browser.ironfox.fenix.printEnabled") {
            this.setPrintEnabled(value);
        } else if (pref === "browser.ironfox.fenix.refererXOriginPolicy") {
            this.setRefererXOriginPolicy(value);
        } else if (pref === "browser.ironfox.fenix.safeBrowsingEnabled") {
            this.setSafeBrowsingEnabled(value);
        } else if (pref === "browser.ironfox.fenix.shouldAutofillAddressDetails") {
            this.setAddressAutofillEnabled(value);
        } else if (pref === "browser.ironfox.fenix.shouldAutofillCreditCardDetails") {
            this.setCardAutofillEnabled(value);
        } else if (pref === "browser.ironfox.fenix.shouldPromptToSaveLogins") {
            this.setPasswordManagerEnabled(value);
        } else if (pref === "browser.ironfox.fenix.spoofEnglish") {
            this.setSpoofEnglishEnabled(value);
        } else if (pref === "browser.ironfox.fenix.spoofTimezone") {
            this.setSpoofTimezoneEnabled(value);
        } else if (pref === "browser.ironfox.fenix.svgEnabled") {
            this.setSVGEnabled(value);
        } else if (pref === "browser.ironfox.fenix.translationsEnabled") {
            this.setTranslationsEnabled(value);
        } else if (pref === "browser.ironfox.fenix.wasmEnabled") {
            this.setWASMEnabled(value);
        } else if (pref === "browser.ironfox.fenix.webglDisabled") {
            this.setWebGLDisabled(value);
        } else if (pref === "browser.ironfox.fenix.webrtcEnabled") {
            this.setWebRTCEnabled(value);
        } else if (pref === "browser.ironfox.fenix.xpinstallEnabled") {
            this.setXPInstallEnabled(value);
        };
        if (type === "boolean") {
            Services.prefs.getDefaultBranch(null).setBoolPref(pref, value);
        } else if (type === "int") {
            Services.prefs.getDefaultBranch(null).setIntPref(pref, value);
        } else if (type === "string") {
            Services.prefs.getDefaultBranch(null).setStringPref(pref, value);
        };
        lazy.log.debug(
            `Locking ${pref}`
        );
        Services.prefs.lockPref(pref);
        lazy.log.debug(
            `SUCCESS: Set ${pref} to ${value}`
        );
    },

    // Set whether to enable support for Accessibility Services
    /// (Corresponds to the `accessibilityEnabled` Fenix UI setting)
    setAccessibilityEnabled(value) {
        if (Services.prefs.prefIsLocked("accessibility.force_disabled") === true) {
            Services.prefs.unlockPref("accessibility.force_disabled");
        };
        if (value === true) {
            // If accessibility services are enabled, we don't want to lock accessibility.force_disabled, because users could technically set it
            // to 0 or -1
            Services.prefs.getDefaultBranch(null).setIntPref("accessibility.force_disabled", 0);
        } else {
            Services.prefs.getDefaultBranch(null).setIntPref("accessibility.force_disabled", 1);
            Services.prefs.lockPref("accessibility.force_disabled");
        };
    },

    // Set whether to always use private browsing mode
    /// (Corresponds to the `alwaysUsePrivateBrowsing` Fenix UI setting)
    setAlwaysUsePrivateBrowsing(value) {
        if (Services.prefs.prefIsLocked("browser.privatebrowsing.autostart") === true) {
            Services.prefs.unlockPref("browser.privatebrowsing.autostart");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.privatebrowsing.autostart", value);
        Services.prefs.lockPref("browser.privatebrowsing.autostart");
    },

    // Set the media autoplay blocking policy
    setAutoplayBlockingPolicy(value) {
        if (Services.prefs.prefIsLocked("media.autoplay.blocking_policy") === true) {
            Services.prefs.unlockPref("media.autoplay.blocking_policy");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.autoplayBlockingClickToPlay") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.autoplayBlockingClickToPlay");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.autoplayBlockingSticky") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.autoplayBlockingSticky");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.autoplayBlockingTransient") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.autoplayBlockingTransient");
        };
        if (value === "click-to-play") {
            Services.prefs.getDefaultBranch(null).setIntPref("media.autoplay.blocking_policy", 2);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingClickToPlay", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingSticky", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingTransient", false);
        } else if (value === "sticky") {
            Services.prefs.getDefaultBranch(null).setIntPref("media.autoplay.blocking_policy", 0);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingSticky", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingClickToPlay", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingTransient", false);
        } else {
            Services.prefs.getDefaultBranch(null).setIntPref("media.autoplay.blocking_policy", 1);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingTransient", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingClickToPlay", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.autoplayBlockingSticky", false);
        };
        Services.prefs.lockPref("media.autoplay.blocking_policy");
        Services.prefs.lockPref("browser.ironfox.fenix.autoplayBlockingClickToPlay");
        Services.prefs.lockPref("browser.ironfox.fenix.autoplayBlockingSticky");
        Services.prefs.lockPref("browser.ironfox.fenix.autoplayBlockingTransient");
    },

    // Set whether to enable disk cache
    /// (Corresponds to the `cacheEnabled` Fenix UI setting)
    setCacheEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.cache.disk.enable") === true) {
            Services.prefs.unlockPref("browser.cache.disk.enable");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.cache.disk.enable", value);
        Services.prefs.lockPref("browser.cache.disk.enable");
    },

    // Set whether to enable our fingerprinting protection overrides
    /// (Corresponds to the `fppOverridesIronFoxEnabled` Fenix UI setting)
    setFPPOverridesIronFoxEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled") === true) {
            Services.prefs.unlockPref("browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled", value);
        Services.prefs.lockPref("browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled");
    },

    // Set whether to enable our timezone spoofing overrides
    /// (Corresponds to the `fppOverridesIronFoxTimezoneEnabled` Fenix UI setting)
    setFPPOverridesIronFoxTimezoneEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled") === true) {
            Services.prefs.unlockPref("browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled", value);
        Services.prefs.lockPref("browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled");
    },

    // Set whether to enable our WebGL overrides
    /// (Corresponds to the `fppOverridesIronFoxWebGLEnabled` Fenix UI setting)
    setFPPOverridesIronFoxWebGLEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled") === true) {
            Services.prefs.unlockPref("browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled", value);
        Services.prefs.lockPref("browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled");
    },

    // Set whether to enable Mozilla's fingerprinting protection overrides
    /// (Corresponds to the `fppOverridesMozillaEnabled` Fenix UI setting)
    setFPPOverridesMozillaEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.ironfox.fingerprintingProtection.mozillaOverrides.enabled") === true) {
            Services.prefs.unlockPref("browser.ironfox.fingerprintingProtection.mozillaOverrides.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fingerprintingProtection.mozillaOverrides.enabled", value);
        Services.prefs.lockPref("browser.ironfox.fingerprintingProtection.mozillaOverrides.enabled");
    },

    // Set whether to enable IPv6 network connectivity
    /// (Corresponds to the `ipv6Enabled` Fenix UI setting)
    setIPv6Enabled(value) {
        if (Services.prefs.prefIsLocked("network.dns.disableIPv6") === true) {
            Services.prefs.unlockPref("network.dns.disableIPv6");
        };
        if (value === false) {
            Services.prefs.getDefaultBranch(null).setBoolPref("network.dns.disableIPv6", true);
        } else {
            Services.prefs.getDefaultBranch(null).setBoolPref("network.dns.disableIPv6", false);
        };
        Services.prefs.lockPref("network.dns.disableIPv6");
    },

    // Set whether the onboarding has been completed
    /// (Corresponds to the `ironFoxOnboardingCompleted` Fenix UI setting)
    setIronFoxOnboardingCompleted(value) {
        if (Services.prefs.prefIsLocked("browser.ironfox.onboardingCompleted") === true) {
            Services.prefs.unlockPref("browser.ironfox.onboardingCompleted");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.onboardingCompleted", value);
        Services.prefs.lockPref("browser.ironfox.onboardingCompleted");
    },

    // Set whether to enable JavaScript
    /// (Corresponds to the `javascriptEnabled` Fenix UI setting)
    setJavaScriptEnabled(value) {
        if (Services.prefs.prefIsLocked("javascript.enabled") === true) {
            Services.prefs.unlockPref("javascript.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("javascript.enabled", value);
        Services.prefs.lockPref("javascript.enabled");
    },

    // Set whether to enable JavaScript Just-in-time compilation (JIT)
    /// (Corresponds to the `javascriptJitEnabled` Fenix UI setting)
    setJITEnabled(value) {
        if (Services.prefs.prefIsLocked("javascript.options.baselinejit") === true) {
            Services.prefs.unlockPref("javascript.options.baselinejit");
        };
        if (Services.prefs.prefIsLocked("javascript.options.ion") === true) {
            Services.prefs.unlockPref("javascript.options.ion");
        };
        if (Services.prefs.prefIsLocked("javascript.options.jithints") === true) {
            Services.prefs.unlockPref("javascript.options.jithints");
        };
        if (Services.prefs.prefIsLocked("javascript.options.native_regexp") === true) {
            Services.prefs.unlockPref("javascript.options.native_regexp");
        };
        if (Services.prefs.prefIsLocked("javascript.options.wasm_optimizingjit") === true) {
            Services.prefs.unlockPref("javascript.options.wasm_optimizingjit");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("javascript.options.baselinejit", value);
        Services.prefs.getDefaultBranch(null).setBoolPref("javascript.options.ion", value);
        Services.prefs.getDefaultBranch(null).setBoolPref("javascript.options.jithints", value);
        Services.prefs.getDefaultBranch(null).setBoolPref("javascript.options.native_regexp", value);
        Services.prefs.getDefaultBranch(null).setBoolPref("javascript.options.wasm_optimizingjit", value);
        // We only want to lock the JIT preferences if JIT is disabled, because if its enabled, users may prefer to enable/disable
        // specific JITs individually
        if (value === false) {
            Services.prefs.lockPref("javascript.options.baselinejit");
            Services.prefs.lockPref("javascript.options.ion");
            Services.prefs.lockPref("javascript.options.jithints");
            Services.prefs.lockPref("javascript.options.native_regexp");
            Services.prefs.lockPref("javascript.options.wasm_optimizingjit");
        };
    },

    // Set whether to enable JavaScript Just-in-time compilation (JIT) for extensions
    /// (if JIT is otherwise disabled globally)
    /// (Corresponds to the `javascriptJitTrustedPrincipalsEnabled` Fenix UI setting)
    setJITTrustedPrincipalsEnabled(value) {
        if (Services.prefs.prefIsLocked("javascript.options.jit_trustedprincipals") === true) {
            Services.prefs.unlockPref("javascript.options.jit_trustedprincipals");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("javascript.options.jit_trustedprincipals", value);
        Services.prefs.lockPref("javascript.options.jit_trustedprincipals");
    },

    // Set whether to disable PDF.js
    /// (Corresponds to the `pdfjsDisabled` Fenix UI setting)
    setPDFjsDisabled(value) {
        if (Services.prefs.prefIsLocked("pdfjs.disabled") === true) {
            Services.prefs.unlockPref("pdfjs.disabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("pdfjs.disabled", value);
        Services.prefs.lockPref("pdfjs.disabled");
    },

    // Set the preferred color scheme for websites
    setPreferredWebsiteAppearance(value) {
        if (Services.prefs.prefIsLocked("layout.css.prefers-color-scheme.content-override") === true) {
            Services.prefs.unlockPref("layout.css.prefers-color-scheme.content-override");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.prefersBrowserColorScheme") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.prefersBrowserColorScheme");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.prefersDarkColorScheme") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.prefersDarkColorScheme");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.prefersLightColorScheme") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.prefersLightColorScheme");
        };
        if (value === "browser") {
            Services.prefs.getDefaultBranch(null).setIntPref("layout.css.prefers-color-scheme.content-override", 2);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersBrowserColorScheme", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersDarkColorScheme", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersLightColorScheme", false);
        } else if (value === "dark") {
            Services.prefs.getDefaultBranch(null).setIntPref("layout.css.prefers-color-scheme.content-override", 0);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersDarkColorScheme", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersBrowserColorScheme", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersLightColorScheme", false);
        } else {
            Services.prefs.getDefaultBranch(null).setIntPref("layout.css.prefers-color-scheme.content-override", 1);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersLightColorScheme", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersBrowserColorScheme", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.prefersDarkColorScheme", false);
        };
        Services.prefs.lockPref("layout.css.prefers-color-scheme.content-override");
        Services.prefs.lockPref("browser.ironfox.fenix.prefersBrowserColorScheme");
        Services.prefs.lockPref("browser.ironfox.fenix.prefersDarkColorScheme");
        Services.prefs.lockPref("browser.ironfox.fenix.prefersLightColorScheme");
    },

    // Set whether to enable printing capabilities
    /// (Corresponds to the `printEnabled` Fenix UI setting)
    setPrintEnabled(value) {
        if (Services.prefs.prefIsLocked("print.enabled") === true) {
            Services.prefs.unlockPref("print.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("print.enabled", value);
        Services.prefs.lockPref("print.enabled");
    },

    // Set the cross-origin referer policy
    setRefererXOriginPolicy(value) {
        if (Services.prefs.prefIsLocked("network.http.referer.XOriginPolicy") === true) {
            Services.prefs.unlockPref("network.http.referer.XOriginPolicy");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.refererXOriginAlways") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.refererXOriginAlways");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.refererXOriginBaseDomainsMatch") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.refererXOriginBaseDomainsMatch");
        };
        if (Services.prefs.prefIsLocked("browser.ironfox.fenix.refererXOriginHostsMatch") === true) {
            Services.prefs.unlockPref("browser.ironfox.fenix.refererXOriginHostsMatch");
        };
        if (value === "base-domains-match") {
            Services.prefs.getDefaultBranch(null).setIntPref("network.http.referer.XOriginPolicy", 1);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginBaseDomainsMatch", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginAlways", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginHostsMatch", false);
        } else if (value === "hosts-match") {
            Services.prefs.getDefaultBranch(null).setIntPref("network.http.referer.XOriginPolicy", 2);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginHostsMatch", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginAlways", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginBaseDomainsMatch", false);
        } else {
            Services.prefs.getDefaultBranch(null).setIntPref("network.http.referer.XOriginPolicy", 0);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginAlways", true);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginHostsMatch", false);
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fenix.refererXOriginBaseDomainsMatch", false);
        };
        Services.prefs.lockPref("network.http.referer.XOriginPolicy");
        Services.prefs.lockPref("browser.ironfox.fenix.refererXOriginAlways");
        Services.prefs.lockPref("browser.ironfox.fenix.refererXOriginBaseDomainsMatch");
        Services.prefs.lockPref("browser.ironfox.fenix.refererXOriginHostsMatch");
    },

    // Set whether to enable Safe Browsing
    /// (Corresponds to the `safeBrowsingEnabled` Fenix UI setting)
    setSafeBrowsingEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.safebrowsing.malware.enabled") === true) {
            Services.prefs.unlockPref("browser.safebrowsing.malware.enabled");
        };
        if (Services.prefs.prefIsLocked("browser.safebrowsing.phishing.enabled") === true) {
            Services.prefs.unlockPref("browser.safebrowsing.phishing.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.safebrowsing.malware.enabled", value);
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.safebrowsing.phishing.enabled", value);
        // We only want to lock the Safe Browsing preferences if Safe Browsing is enabled, because if its disabled, users may prefer
        // to enable/disable the protections individually
        if (value === true) {
            Services.prefs.lockPref("browser.safebrowsing.malware.enabled");
            Services.prefs.lockPref("browser.safebrowsing.phishing.enabled");
        };
    },

    // Set whether to enable address autofill
    /// (Corresponds to the `shouldAutofillAddressDetails` Fenix UI setting)
    setAddressAutofillEnabled(value) {
        if (Services.prefs.prefIsLocked("extensions.formautofill.addresses.enabled") === true) {
            Services.prefs.unlockPref("extensions.formautofill.addresses.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("extensions.formautofill.addresses.enabled", value);
        Services.prefs.lockPref("extensions.formautofill.addresses.enabled");
    },

    // Set whether to enable card autofill
    /// (Corresponds to the `shouldAutofillCreditCardDetails` Fenix UI setting)
    setCardAutofillEnabled(value) {
        if (Services.prefs.prefIsLocked("extensions.formautofill.creditCards.enabled") === true) {
            Services.prefs.unlockPref("extensions.formautofill.creditCards.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("extensions.formautofill.creditCards.enabled", value);
        Services.prefs.lockPref("extensions.formautofill.creditCards.enabled");
    },

    // Set whether to enable the password manager
    /// (Corresponds to the `shouldPromptToSaveLogins` Fenix UI setting)
    setPasswordManagerEnabled(value) {
        if (Services.prefs.prefIsLocked("signon.rememberSignons") === true) {
            Services.prefs.unlockPref("signon.rememberSignons");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("signon.rememberSignons", value);
        Services.prefs.lockPref("signon.rememberSignons");
    },

    // Set whether to enable locale spoofing
    /// (Corresponds to the `spoofEnglish` Fenix UI setting)
    setSpoofEnglishEnabled(value) {
        if (Services.prefs.prefIsLocked("privacy.spoof_english") === true) {
            Services.prefs.unlockPref("privacy.spoof_english");
        };
        if (value === true) {
            Services.prefs.getDefaultBranch(null).setIntPref("privacy.spoof_english", 2);
        } else {
            Services.prefs.getDefaultBranch(null).setIntPref("privacy.spoof_english", 0);
        };
        lazy.RFPHelper._handleSpoofEnglishChanged();
        Services.prefs.lockPref("privacy.spoof_english");
    },

    // Set whether to enable timezone spoofing
    /// (Corresponds to the `spoofTimezone` Fenix UI setting)
    setSpoofTimezoneEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled") === true) {
            Services.prefs.unlockPref("browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled", value);
        Services.prefs.lockPref("browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled");
    },

    // Set whether to enable Scalar Vector Graphics (SVG)
    /// (Corresponds to the `svgEnabled` Fenix UI setting)
    setSVGEnabled(value) {
        if (Services.prefs.prefIsLocked("svg.disabled") === true) {
            Services.prefs.unlockPref("svg.disabled");
        };
        if (value === false) {
            Services.prefs.getDefaultBranch(null).setBoolPref("svg.disabled", true);
        } else {
            Services.prefs.getDefaultBranch(null).setBoolPref("svg.disabled", false);
        };
        Services.prefs.lockPref("svg.disabled");
    },

    // Set whether to enable Firefox Translations
    /// (Corresponds to the `translationsEnabled` Fenix UI setting)
    setTranslationsEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.ai.control.translations") === true) {
            Services.prefs.unlockPref("browser.ai.control.translations");
        };
        if (Services.prefs.prefIsLocked("browser.translations.enable") === true) {
            Services.prefs.unlockPref("browser.translations.enable");
        };
        if (Services.prefs.prefIsLocked("browser.translations.simulateUnsupportedEngine") === true) {
            Services.prefs.unlockPref("browser.translations.simulateUnsupportedEngine");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.translations.enable", value);
        if (value === false) {
            Services.prefs.getDefaultBranch(null).setStringPref("browser.ai.control.translations", "blocked");
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.translations.simulateUnsupportedEngine", true);
        } else {
            Services.prefs.getDefaultBranch(null).setStringPref("browser.ai.control.translations", "enabled");
            Services.prefs.getDefaultBranch(null).setBoolPref("browser.translations.simulateUnsupportedEngine", false);
        };
        Services.prefs.lockPref("browser.ai.control.translations");
        Services.prefs.lockPref("browser.translations.enable");
        Services.prefs.lockPref("browser.translations.simulateUnsupportedEngine");
    },

    // Set whether to enable WebAssembly (WASM)
    /// (Corresponds to the `wasmEnabled` Fenix UI setting)
    setWASMEnabled(value) {
        if (Services.prefs.prefIsLocked("javascript.options.wasm") === true) {
            Services.prefs.unlockPref("javascript.options.wasm");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("javascript.options.wasm", value);
        Services.prefs.lockPref("javascript.options.wasm");
    },

    // Set whether to enable WebRTC
    /// (Corresponds to the `webrtcEnabled` Fenix UI setting)
    setWebRTCEnabled(value) {
        if (Services.prefs.prefIsLocked("media.peerconnection.enabled") === true) {
            Services.prefs.unlockPref("media.peerconnection.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("media.peerconnection.enabled", value);
        Services.prefs.lockPref("media.peerconnection.enabled");
    },

    // Set whether to enable add-on installation
    /// (Corresponds to the `xpinstallEnabled` Fenix UI setting)
    setXPInstallEnabled(value) {
        if (Services.prefs.prefIsLocked("browser.ironfox.xpinstall.enabled") === true) {
            Services.prefs.unlockPref("browser.ironfox.xpinstall.enabled");
        };
        Services.prefs.getDefaultBranch(null).setBoolPref("browser.ironfox.xpinstall.enabled", value);
        Services.prefs.lockPref("browser.ironfox.xpinstall.enabled");
    }
};
