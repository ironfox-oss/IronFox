// IronFox GeckoSettingsBridge (Sender)

package org.ironfoxoss.ironfox.utils

import android.content.Context
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.suspendCancellableCoroutine
import mozilla.components.concept.engine.preferences.Branch
import mozilla.components.concept.engine.preferences.BrowserPreference
import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.Engine
import org.ironfoxoss.ironfox.utils.IronFoxPreferences
import org.mozilla.fenix.ext.settings

// Helpers for managing Gecko preferences from Fenix
/// (Thus, the name is Gecko Settings "Bridge" - this is meant to serve as a bridge between Fenix settings
/// and Gecko prefs)
/// For reference, I took some inspiration from AutoConfig functions:
// https://support.mozilla.org/kb/customizing-firefox-using-autoconfig#w_functions-of-autoconfig

object GeckoSettingsBridge {

    fun setIronFoxPrefs(context: Context, engine: Engine) {

        setWebGLDisabled(context, engine)
        setAccessibilityEnabled(context, engine)
        setJavaScriptEnabled(context, engine)
        setFPPOverridesIronFoxWebGLEnabled(context, engine)
        setAlwaysUsePrivateBrowsing(context, engine)
        setCacheEnabled(context, engine)
        setFPPOverridesIronFoxEnabled(context, engine)
        setFPPOverridesMozillaEnabled(context, engine)
        setFPPOverridesIronFoxTimezoneEnabled(context, engine)
        setSpoofEnglishEnabled(context, engine)
        setSpoofTimezoneEnabled(context, engine)
        setXPInstallEnabled(context, engine)
        setJITEnabled(context, engine)
        setJITTrustedPrincipalsEnabled(context, engine)
        setPrintEnabled(context, engine)
        setSafeBrowsingEnabled(context, engine)
        setSVGEnabled(context, engine)
        setWASMEnabled(context, engine)
        setWebRTCEnabled(context, engine)
        setTranslationsEnabled(context, engine)
        setIPv6Enabled(context, engine)
        setPDFjsDisabled(context, engine)
        setAutoplayBlockingPolicy(context, engine)
        setPreferredWebsiteAppearance(context, engine)
        setRefererXOriginPolicy(context, engine)
        setAddressAutofillEnabled(context, engine)
        setCardAutofillEnabled(context, engine)
        setPasswordManagerEnabled(context, engine)
        setIronFoxOnboardingCompleted(context, engine)
        setGeckoRuntimeSettings(context, engine)

        // We don't support EME, but, if a user enables it from the about:config,
        // we need to expose the permision UI for it.
        // If we don't, and a user enables it, Gecko will just allow every site unconditionally to use EME...
        @OptIn(ExperimentalAndroidComponentsApi::class)
        engine.getBrowserPref(
            "media.eme.enabled",
            onSuccess = { emePref ->
                IronFoxPreferences.setEMEEnabled(context, emePref.value as Boolean)
            },
            onError = { throwable ->
                IronFoxPreferences.setEMEEnabled(context, false)
            }
        )

        setGeckoPrefsInitialized(context, engine)
    }

    fun setIronFoxOnboardingCompleted(context: Context, engine: Engine) {
        val ironFoxOnboardingCompleted = IronFoxPreferences.isIronFoxOnboardingCompleted(context)
        setDefaultPref(engine, "browser.ironfox.fenix.ironFoxOnboardingCompleted", ironFoxOnboardingCompleted)
    }

    fun setWebGLDisabled(context: Context, engine: Engine) {
        val webglDisabled = IronFoxPreferences.isWebGLDisabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.webglDisabled", webglDisabled)
    }

    fun setAccessibilityEnabled(context: Context, engine: Engine) {
        val accessibilityEnabled = IronFoxPreferences.isAccessibilityEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.accessibilityEnabled", accessibilityEnabled)
    }

    fun setJavaScriptEnabled(context: Context, engine: Engine) {
        val javascriptEnabled = IronFoxPreferences.isJavaScriptEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.javascriptEnabled", javascriptEnabled)
    }

    fun setFPPOverridesIronFoxWebGLEnabled(context: Context, engine: Engine) {
        val fppOverridesIronFoxWebGLEnabled = IronFoxPreferences.isFPPOverridesIronFoxWebGLEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.fppOverridesIronFoxWebGLEnabled", fppOverridesIronFoxWebGLEnabled)
    }

    fun setAlwaysUsePrivateBrowsing(context: Context, engine: Engine) {
        val alwaysUsePrivateBrowsing = IronFoxPreferences.isAlwaysUsePrivateBrowsing(context)
        setDefaultPref(engine, "browser.ironfox.fenix.alwaysUsePrivateBrowsing", alwaysUsePrivateBrowsing)
    }

    fun setCacheEnabled(context: Context, engine: Engine) {
        val cacheEnabled = IronFoxPreferences.isCacheEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.cacheEnabled", cacheEnabled)
    }

    fun setFPPOverridesIronFoxEnabled(context: Context, engine: Engine) {
        val fppOverridesIronFoxEnabled = IronFoxPreferences.isFPPOverridesIronFoxEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.fppOverridesIronFoxEnabled", fppOverridesIronFoxEnabled)
    }

    fun setFPPOverridesMozillaEnabled(context: Context, engine: Engine) {
        val fppOverridesMozillaEnabled = IronFoxPreferences.isFPPOverridesMozillaEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.fppOverridesMozillaEnabled", fppOverridesMozillaEnabled)
    }

    fun setFPPOverridesIronFoxTimezoneEnabled(context: Context, engine: Engine) {
        val fppOverridesIronFoxTimezoneEnabled = IronFoxPreferences.isFPPOverridesIronFoxTimezoneEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.fppOverridesIronFoxTimezoneEnabled", fppOverridesIronFoxTimezoneEnabled)
    }

    fun setSpoofEnglishEnabled(context: Context, engine: Engine) {
        val spoofEnglish = IronFoxPreferences.isSpoofEnglishEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.spoofEnglish", spoofEnglish)
    }

    fun setSpoofTimezoneEnabled(context: Context, engine: Engine) {
        val spoofTimezone = IronFoxPreferences.isSpoofTimezoneEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.spoofTimezone", spoofTimezone)
    }

    fun setXPInstallEnabled(context: Context, engine: Engine) {
        val xpinstallEnabled = IronFoxPreferences.isXPInstallEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.xpinstallEnabled", xpinstallEnabled)
    }

    fun setJITEnabled(context: Context, engine: Engine) {
        val javascriptJitEnabled = IronFoxPreferences.isJITEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.javascriptJitEnabled", javascriptJitEnabled)
    }

    fun setJITTrustedPrincipalsEnabled(context: Context, engine: Engine) {
        val javascriptJitTrustedPrincipalsEnabled = IronFoxPreferences.isJITTrustedPrincipalsEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.javascriptJitTrustedPrincipalsEnabled", javascriptJitTrustedPrincipalsEnabled)
    }

    fun setPrintEnabled(context: Context, engine: Engine) {
        val printEnabled = IronFoxPreferences.isPrintEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.printEnabled", printEnabled)
    }

    fun setSafeBrowsingEnabled(context: Context, engine: Engine) {
        val safeBrowsingEnabled = IronFoxPreferences.isSafeBrowsingEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.safeBrowsingEnabled", safeBrowsingEnabled)
    }

    fun setSVGEnabled(context: Context, engine: Engine) {
        val svgEnabled = IronFoxPreferences.isSVGEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.svgEnabled", svgEnabled)
    }

    fun setWASMEnabled(context: Context, engine: Engine) {
        val wasmEnabled = IronFoxPreferences.isWASMEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.wasmEnabled", wasmEnabled)
    }

    fun setWebRTCEnabled(context: Context, engine: Engine) {
        val webrtcEnabled = IronFoxPreferences.isWebRTCEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.webrtcEnabled", webrtcEnabled)
    }

    fun setTranslationsEnabled(context: Context, engine: Engine) {
        val translationsEnabled = IronFoxPreferences.isTranslationsEnabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.translationsEnabled", translationsEnabled)
    }

    fun setIPv6Enabled(context: Context, engine: Engine) {
        val ipv6Enabled = IronFoxPreferences.isIPv6Enabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.ipv6Enabled", ipv6Enabled)
    }

    fun setPDFjsDisabled(context: Context, engine: Engine) {
        val pdfjsDisabled = IronFoxPreferences.isPDFjsDisabled(context)
        setDefaultPref(engine, "browser.ironfox.fenix.pdfjsDisabled", pdfjsDisabled)
    }

    fun setAutoplayBlockingPolicy(context: Context, engine: Engine) {
        val autoplayBlockingClickToPlay = IronFoxPreferences.isAutoplayBlockingClickToPlay(context)
        val autoplayBlockingSticky = IronFoxPreferences.isAutoplayBlockingSticky(context)

        if (autoplayBlockingClickToPlay) {
            setDefaultPref(engine, "browser.ironfox.fenix.autoplayBlockingPolicy", "click-to-play")
        } else if (autoplayBlockingSticky) {
            setDefaultPref(engine, "browser.ironfox.fenix.autoplayBlockingPolicy", "sticky")
        } else {
            setDefaultPref(engine, "browser.ironfox.fenix.autoplayBlockingPolicy", "transient")
        }
    }

    fun setPreferredWebsiteAppearance(context: Context, engine: Engine) {
        val prefersBrowserColorScheme = IronFoxPreferences.isPrefersBrowserColorScheme(context)
        val prefersDarkColorScheme = IronFoxPreferences.isPrefersDarkColorScheme(context)

        if (prefersBrowserColorScheme) {
            setDefaultPref(engine, "browser.ironfox.fenix.prefersColorScheme", "browser")
        } else if (prefersDarkColorScheme) {
            setDefaultPref(engine, "browser.ironfox.fenix.prefersColorScheme", "dark")
        } else {
            setDefaultPref(engine, "browser.ironfox.fenix.prefersColorScheme", "light")
        }
    }

    fun setRefererXOriginPolicy(context: Context, engine: Engine) {
        val refererXOriginBaseDomainsMatch = IronFoxPreferences.isRefererXOriginBaseDomainsMatch(context)
        val refererXOriginHostsMatch = IronFoxPreferences.isRefererXOriginHostsMatch(context)

        if (refererXOriginHostsMatch) {
            setDefaultPref(engine, "browser.ironfox.fenix.refererXOriginPolicy", "hosts-match")
        } else if (refererXOriginBaseDomainsMatch) {
            setDefaultPref(engine, "browser.ironfox.fenix.refererXOriginPolicy", "base-domains-match")
        } else {
            setDefaultPref(engine, "browser.ironfox.fenix.refererXOriginPolicy", "always")
        }
    }

    fun setAddressAutofillEnabled(context: Context, engine: Engine) {
        val addressAutofillEnabled = context.settings().shouldAutofillAddressDetails
        setDefaultPref(engine, "browser.ironfox.fenix.shouldAutofillAddressDetails", addressAutofillEnabled)
    }

    fun setCardAutofillEnabled(context: Context, engine: Engine) {
        val cardAutofillEnabled = context.settings().shouldAutofillCreditCardDetails
        setDefaultPref(engine, "browser.ironfox.fenix.shouldAutofillCreditCardDetails", cardAutofillEnabled)
    }

    fun setPasswordManagerEnabled(context: Context, engine: Engine) {
        val passwordManagerEnabled = context.settings().shouldPromptToSaveLogins
        setDefaultPref(engine, "browser.ironfox.fenix.shouldPromptToSaveLogins", passwordManagerEnabled)
    }

    fun setGeckoPrefsInitialized(context: Context, engine: Engine) {
        setDefaultPref(engine, "browser.ironfox.geckoSettingsBridge.initialized", true)
    }

    // This is an (ideally temporary) solution to ensure that GeckoRuntimeSettings prefs are being properly configured based on Fenix's UI settings
    fun setGeckoRuntimeSettings(context: Context, engine: Engine) {
        setAllowThirdPartyRootCerts(context, engine)
        setDohProviderUrl(context, engine)
        setEnableGeckoLogs(context, engine)
        setForceEnableZoom(context, engine)
        setHttpsOnlyMode(context, engine)
        setIsLnaBlockingEnabled(context, engine)
        setIsLnaFeatureEnabled(context, engine)
        setIsLnaTrackerBlockingEnabled(context, engine)
        setOfferTranslation(context, engine)
        setTrrMode(context, engine)
        setShouldAutofillLogins(context, engine)
        setShouldUseCookieBannerPrivateMode(context, engine)
        setStrictAllowListBaselineTrackingProtection(context, engine)
        setStrictAllowListConvenienceTrackingProtection(context, engine)
    }

    fun setAllowThirdPartyRootCerts(context: Context, engine: Engine) {
        val allowThirdPartyRootCerts = context.settings().allowThirdPartyRootCerts
        val allowThirdPartyRootCertsGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.security.enterprise_roots.enabled.value"
        val allowThirdPartyRootCertsGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.security.enterprise_roots.enabled.value.modified"
        val allowThirdPartyRootCertsGeckoPref = "security.enterprise_roots.enabled"
        setUserPref(engine, allowThirdPartyRootCertsGeckoViewPref, allowThirdPartyRootCerts)
        setDefaultPref(engine, allowThirdPartyRootCertsGeckoViewPref, allowThirdPartyRootCerts)
        setUserPref(engine, allowThirdPartyRootCertsGeckoPref, allowThirdPartyRootCerts)
        setDefaultPref(engine, allowThirdPartyRootCertsGeckoPref, allowThirdPartyRootCerts)

        if (allowThirdPartyRootCerts) {
            setUserPref(engine, allowThirdPartyRootCertsGeckoViewModifiedPref, true)
            setDefaultPref(engine, allowThirdPartyRootCertsGeckoViewModifiedPref, true)
        }
    }

    fun setDohProviderUrl(context: Context, engine: Engine) {
        val dohProviderUrl = context.settings().dohProviderUrl
        val dohProviderUrlGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.network.trr.uri.value"
        val dohProviderUrlGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.network.trr.uri.value.modified"
        val dohProviderUrlGeckoPref = "network.trr.uri"
        setUserPref(engine, dohProviderUrlGeckoViewPref, dohProviderUrl)
        setDefaultPref(engine, dohProviderUrlGeckoViewPref, dohProviderUrl)
        setUserPref(engine, dohProviderUrlGeckoPref, dohProviderUrl)
        setDefaultPref(engine, dohProviderUrlGeckoPref, dohProviderUrl)

        if (dohProviderUrl != "https://dns.quad9.net/dns-query") {
            setUserPref(engine, dohProviderUrlGeckoViewModifiedPref, true)
            setDefaultPref(engine, dohProviderUrlGeckoViewModifiedPref, true)
        }
    }

    fun setEnableGeckoLogs(context: Context, engine: Engine) {
        val enableGeckoLogs = context.settings().enableGeckoLogs
        val consoleEnabledGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.geckoview.console.enabled.value"
        val consoleEnabledGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.geckoview.console.enabled.value.modified"
        val consoleEnabledGeckoPref = "geckoview.console.enabled"
        val geckoviewLoggingGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.geckoview.logging.value"
        val geckoviewLoggingGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.geckoview.logging.value.modified"
        val geckoviewLoggingGeckoPref = "geckoview.logging"
        val consoleLogcatGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.consoleservice.logcat.value"
        val consoleLogcatGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.consoleservice.logcat.value.modified"
        val consoleLogcatGeckoPref = "consoleservice.logcat"
        setUserPref(engine, consoleEnabledGeckoViewPref, enableGeckoLogs)
        setDefaultPref(engine, consoleEnabledGeckoViewPref, enableGeckoLogs)
        setUserPref(engine, consoleEnabledGeckoPref, enableGeckoLogs)
        setDefaultPref(engine, consoleEnabledGeckoPref, enableGeckoLogs)
        setUserPref(engine, consoleLogcatGeckoViewPref, enableGeckoLogs)
        setDefaultPref(engine, consoleLogcatGeckoViewPref, enableGeckoLogs)
        setUserPref(engine, consoleLogcatGeckoPref, enableGeckoLogs)
        setDefaultPref(engine, consoleLogcatGeckoPref, enableGeckoLogs)

        if (enableGeckoLogs) {
            setUserPref(engine, geckoviewLoggingGeckoViewPref, "Debug")
            setDefaultPref(engine, geckoviewLoggingGeckoViewPref, "Debug")
            setUserPref(engine, geckoviewLoggingGeckoPref, "Debug")
            setDefaultPref(engine, geckoviewLoggingGeckoPref, "Debug")

            setUserPref(engine, consoleEnabledGeckoViewModifiedPref, true)
            setDefaultPref(engine, consoleEnabledGeckoViewModifiedPref, true)
            setUserPref(engine, geckoviewLoggingGeckoViewModifiedPref, true)
            setDefaultPref(engine, geckoviewLoggingGeckoViewModifiedPref, true)
            setUserPref(engine, consoleLogcatGeckoViewModifiedPref, true)
            setDefaultPref(engine, consoleLogcatGeckoViewModifiedPref, true)
        } else {
            setUserPref(engine, geckoviewLoggingGeckoViewPref, "Warn")
            setDefaultPref(engine, geckoviewLoggingGeckoViewPref, "Warn")
            setUserPref(engine, geckoviewLoggingGeckoPref, "Warn")
            setDefaultPref(engine, geckoviewLoggingGeckoPref, "Warn")
        }
    }

    fun setForceEnableZoom(context: Context, engine: Engine) {
        val forceEnableZoom = context.settings().forceEnableZoom
        val forceEnableZoomGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.browser.ui.zoom.force-user-scalable.value"
        val forceEnableZoomGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.browser.ui.zoom.force-user-scalable.value.modified"
        val forceEnableZoomGeckoPref = "browser.ui.zoom.force-user-scalable"
        setUserPref(engine, forceEnableZoomGeckoViewPref, forceEnableZoom)
        setDefaultPref(engine, forceEnableZoomGeckoViewPref, forceEnableZoom)
        setUserPref(engine, forceEnableZoomGeckoPref, forceEnableZoom)
        setDefaultPref(engine, forceEnableZoomGeckoPref, forceEnableZoom)

        if (!forceEnableZoom) {
            setUserPref(engine, forceEnableZoomGeckoViewModifiedPref, true)
            setDefaultPref(engine, forceEnableZoomGeckoViewModifiedPref, true)
        }
    }
    
    fun setHttpsOnlyMode(context: Context, engine: Engine) {
        val shouldUseHttpsOnly = context.settings().shouldUseHttpsOnly
        val shouldUseHttpsOnlyInAllTabs = context.settings().shouldUseHttpsOnlyInAllTabs
        val shouldUseHttpsOnlyInPrivateTabsOnly = context.settings().shouldUseHttpsOnlyInPrivateTabsOnly
        val httpsOnlyGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.dom.security.https_only_mode.value"
        val httpsOnlyGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.dom.security.https_only_mode.value.modified"
        val httpsOnlyGeckoPref = "dom.security.https_only_mode"
        val httpsOnlyPbmGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.dom.security.https_only_mode_pbm.value"
        val httpsOnlyPbmGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.dom.security.https_only_mode_pbm.value.modified"
        val httpsOnlyPbmGeckoPref = "dom.security.https_only_mode_pbm"

        if (!shouldUseHttpsOnly) {
            setUserPref(engine, httpsOnlyGeckoViewPref, shouldUseHttpsOnly)
            setDefaultPref(engine, httpsOnlyGeckoViewPref, shouldUseHttpsOnly)
            setUserPref(engine, httpsOnlyGeckoPref, shouldUseHttpsOnly)
            setDefaultPref(engine, httpsOnlyGeckoPref, shouldUseHttpsOnly)

            setUserPref(engine, httpsOnlyPbmGeckoViewPref, shouldUseHttpsOnly)
            setDefaultPref(engine, httpsOnlyPbmGeckoViewPref, shouldUseHttpsOnly)
            setUserPref(engine, httpsOnlyPbmGeckoPref, shouldUseHttpsOnly)
            setDefaultPref(engine, httpsOnlyPbmGeckoPref, shouldUseHttpsOnly)

            setUserPref(engine, httpsOnlyGeckoViewModifiedPref, true)
            setDefaultPref(engine, httpsOnlyGeckoViewModifiedPref, true)
            setUserPref(engine, httpsOnlyPbmGeckoViewModifiedPref, true)
            setDefaultPref(engine, httpsOnlyPbmGeckoViewModifiedPref, true)
        } else {
            setUserPref(engine, httpsOnlyPbmGeckoViewPref, true)
            setDefaultPref(engine, httpsOnlyPbmGeckoViewPref, true)
            setUserPref(engine, httpsOnlyPbmGeckoPref, true)
            setDefaultPref(engine, httpsOnlyPbmGeckoPref, true)

            if (shouldUseHttpsOnlyInAllTabs) {
                setUserPref(engine, httpsOnlyGeckoViewPref, shouldUseHttpsOnlyInAllTabs)
                setDefaultPref(engine, httpsOnlyGeckoViewPref, shouldUseHttpsOnlyInAllTabs)
                setUserPref(engine, httpsOnlyGeckoPref, shouldUseHttpsOnlyInAllTabs)
                setDefaultPref(engine, httpsOnlyGeckoPref, shouldUseHttpsOnlyInAllTabs)
            } else {
                setUserPref(engine, httpsOnlyGeckoViewModifiedPref, true)
                setDefaultPref(engine, httpsOnlyGeckoViewModifiedPref, true)
            }
        }
    }

    fun setIsLnaBlockingEnabled(context: Context, engine: Engine) {
        val isLnaBlockingEnabled = context.settings().isLnaBlockingEnabled
        val isLnaBlockingEnabledGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.network.lna.blocking.value"
        val isLnaBlockingEnabledGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.network.lna.blocking.value.modified"
        val isLnaBlockingEnabledGeckoPref = "network.lna.blocking"
        setUserPref(engine, isLnaBlockingEnabledGeckoViewPref, isLnaBlockingEnabled)
        setDefaultPref(engine, isLnaBlockingEnabledGeckoViewPref, isLnaBlockingEnabled)
        setUserPref(engine, isLnaBlockingEnabledGeckoPref, isLnaBlockingEnabled)
        setDefaultPref(engine, isLnaBlockingEnabledGeckoPref, isLnaBlockingEnabled)

        if (!isLnaBlockingEnabled) {
            setUserPref(engine, isLnaBlockingEnabledGeckoViewModifiedPref, true)
            setDefaultPref(engine, isLnaBlockingEnabledGeckoViewModifiedPref, true)
        }
    }

    fun setIsLnaFeatureEnabled(context: Context, engine: Engine) {
        val isLnaFeatureEnabled = context.settings().isLnaFeatureEnabled
        val isLnaFeatureEnabledGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.network.lna.enabled.value"
        val isLnaFeatureEnabledGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.network.lna.enabled.value.modified"
        val isLnaFeatureEnabledGeckoPref = "network.lna.enabled"
        setUserPref(engine, isLnaFeatureEnabledGeckoViewPref, isLnaFeatureEnabled)
        setDefaultPref(engine, isLnaFeatureEnabledGeckoViewPref, isLnaFeatureEnabled)
        setUserPref(engine, isLnaFeatureEnabledGeckoPref, isLnaFeatureEnabled)
        setDefaultPref(engine, isLnaFeatureEnabledGeckoPref, isLnaFeatureEnabled)

        if (!isLnaFeatureEnabled) {
            setUserPref(engine, isLnaFeatureEnabledGeckoViewModifiedPref, true)
            setDefaultPref(engine, isLnaFeatureEnabledGeckoViewModifiedPref, true)
        }
    }

    fun setIsLnaTrackerBlockingEnabled(context: Context, engine: Engine) {
        val isLnaTrackerBlockingEnabled = context.settings().isLnaTrackerBlockingEnabled
        val isLnaTrackerBlockingEnabledGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.network.lna.block_trackers.value"
        val isLnaTrackerBlockingEnabledGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.network.lna.block_trackers.value.modified"
        val isLnaTrackerBlockingEnabledGeckoPref = "network.lna.block_trackers"
        setUserPref(engine, isLnaTrackerBlockingEnabledGeckoViewPref, isLnaTrackerBlockingEnabled)
        setDefaultPref(engine, isLnaTrackerBlockingEnabledGeckoViewPref, isLnaTrackerBlockingEnabled)
        setUserPref(engine, isLnaTrackerBlockingEnabledGeckoPref, isLnaTrackerBlockingEnabled)
        setDefaultPref(engine, isLnaTrackerBlockingEnabledGeckoPref, isLnaTrackerBlockingEnabled)

        if (!isLnaTrackerBlockingEnabled) {
            setUserPref(engine, isLnaTrackerBlockingEnabledGeckoViewModifiedPref, true)
            setDefaultPref(engine, isLnaTrackerBlockingEnabledGeckoViewModifiedPref, true)
        }
    }

    fun setOfferTranslation(context: Context, engine: Engine) {
        val offerTranslation = context.settings().offerTranslation
        val offerTranslationGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.browser.translations.automaticallyPopup.value"
        val offerTranslationGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.browser.translations.automaticallyPopup.value.modified"
        val offerTranslationGeckoPref = "browser.translations.automaticallyPopup"
        setUserPref(engine, offerTranslationGeckoViewPref, offerTranslation)
        setDefaultPref(engine, offerTranslationGeckoViewPref, offerTranslation)
        setUserPref(engine, offerTranslationGeckoPref, offerTranslation)
        setDefaultPref(engine, offerTranslationGeckoPref, offerTranslation)

        if (!offerTranslation) {
            setUserPref(engine, offerTranslationGeckoViewModifiedPref, true)
            setDefaultPref(engine, offerTranslationGeckoViewModifiedPref, true)
        }
    }

    fun setTrrMode(context: Context, engine: Engine) {
        val trrMode = context.settings().trrMode
        val trrModeGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.network.trr.mode.value"
        val trrModeGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.network.trr.mode.value.modified"
        val trrModeGeckoPref = "network.trr.mode"
        setUserPref(engine, trrModeGeckoViewPref, trrMode)
        setDefaultPref(engine, trrModeGeckoViewPref, trrMode)
        setUserPref(engine, trrModeGeckoPref, trrMode)
        setDefaultPref(engine, trrModeGeckoPref, trrMode)

        if (trrMode != 3) {
            setUserPref(engine, trrModeGeckoViewModifiedPref, true)
            setDefaultPref(engine, trrModeGeckoViewModifiedPref, true)
        }
    }

    fun setShouldAutofillLogins(context: Context, engine: Engine) {
        val shouldAutofillLogins = context.settings().shouldAutofillLogins
        val shouldAutofillLoginsGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.signon.autofillForms.value"
        val shouldAutofillLoginsGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.signon.autofillForms.value.modified"
        val shouldAutofillLoginsGeckoPref = "signon.autofillForms"
        setUserPref(engine, shouldAutofillLoginsGeckoViewPref, shouldAutofillLogins)
        setDefaultPref(engine, shouldAutofillLoginsGeckoViewPref, shouldAutofillLogins)
        setUserPref(engine, shouldAutofillLoginsGeckoPref, shouldAutofillLogins)
        setDefaultPref(engine, shouldAutofillLoginsGeckoPref, shouldAutofillLogins)

        if (shouldAutofillLogins) {
            setUserPref(engine, shouldAutofillLoginsGeckoViewModifiedPref, true)
            setDefaultPref(engine, shouldAutofillLoginsGeckoViewModifiedPref, true)
        }
    }

    fun setShouldUseCookieBannerPrivateMode(context: Context, engine: Engine) {
        val shouldUseCookieBannerPrivateMode = context.settings().shouldUseCookieBannerPrivateMode
        val shouldUseCookieBannerPrivateModeGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.cookiebanners.service.mode.privateBrowsing.value"
        val shouldUseCookieBannerPrivateModeGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.cookiebanners.service.mode.privateBrowsing.value.modified"
        val shouldUseCookieBannerPrivateModeGeckoPref = "cookiebanners.service.mode.privateBrowsing"
        setUserPref(engine, shouldUseCookieBannerPrivateModeGeckoViewPref, shouldUseCookieBannerPrivateMode)
        setDefaultPref(engine, shouldUseCookieBannerPrivateModeGeckoViewPref, shouldUseCookieBannerPrivateMode)

        if (shouldUseCookieBannerPrivateMode) {
            setUserPref(engine, shouldUseCookieBannerPrivateModeGeckoPref, 1)
            setDefaultPref(engine, shouldUseCookieBannerPrivateModeGeckoPref, 1)
        } else {
            setUserPref(engine, shouldUseCookieBannerPrivateModeGeckoPref, 0)
            setDefaultPref(engine, shouldUseCookieBannerPrivateModeGeckoPref, 0)

            setUserPref(engine, shouldUseCookieBannerPrivateModeGeckoViewModifiedPref, true)
            setDefaultPref(engine, shouldUseCookieBannerPrivateModeGeckoViewModifiedPref, true)
        }
    }

    fun setStrictAllowListBaselineTrackingProtection(context: Context, engine: Engine) {
        val strictAllowListBaselineTrackingProtection = context.settings().strictAllowListBaselineTrackingProtection
        val strictAllowListBaselineTrackingProtectionGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.privacy.trackingprotection.allow_list.baseline.enabled.value"
        val strictAllowListBaselineTrackingProtectionGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.privacy.trackingprotection.allow_list.baseline.enabled.value.modified"
        val strictAllowListBaselineTrackingProtectionGeckoPref = "privacy.trackingprotection.allow_list.baseline.enabled"
        setUserPref(engine, strictAllowListBaselineTrackingProtectionGeckoViewPref, strictAllowListBaselineTrackingProtection)
        setDefaultPref(engine, strictAllowListBaselineTrackingProtectionGeckoViewPref, strictAllowListBaselineTrackingProtection)
        setUserPref(engine, strictAllowListBaselineTrackingProtectionGeckoPref, strictAllowListBaselineTrackingProtection)
        setDefaultPref(engine, strictAllowListBaselineTrackingProtectionGeckoPref, strictAllowListBaselineTrackingProtection)

        if (!strictAllowListBaselineTrackingProtection) {
            setUserPref(engine, strictAllowListBaselineTrackingProtectionGeckoViewModifiedPref, true)
            setDefaultPref(engine, strictAllowListBaselineTrackingProtectionGeckoViewModifiedPref, true)
        }
    }

    fun setStrictAllowListConvenienceTrackingProtection(context: Context, engine: Engine) {
        val strictAllowListConvenienceTrackingProtection = context.settings().strictAllowListConvenienceTrackingProtection
        val strictAllowListConvenienceTrackingProtectionGeckoViewPref = "browser.ironfox.geckoRuntimeSettings.privacy.trackingprotection.allow_list.convenience.enabled.value"
        val strictAllowListConvenienceTrackingProtectionGeckoViewModifiedPref = "browser.ironfox.geckoRuntimeSettings.privacy.trackingprotection.allow_list.convenience.enabled.value.modified"
        val strictAllowListConvenienceTrackingProtectionGeckoPref = "privacy.trackingprotection.allow_list.convenience.enabled"
        setUserPref(engine, strictAllowListConvenienceTrackingProtectionGeckoViewPref, strictAllowListConvenienceTrackingProtection)
        setDefaultPref(engine, strictAllowListConvenienceTrackingProtectionGeckoViewPref, strictAllowListConvenienceTrackingProtection)
        setUserPref(engine, strictAllowListConvenienceTrackingProtectionGeckoPref, strictAllowListConvenienceTrackingProtection)
        setDefaultPref(engine, strictAllowListConvenienceTrackingProtectionGeckoPref, strictAllowListConvenienceTrackingProtection)

        if (strictAllowListConvenienceTrackingProtection) {
            setUserPref(engine, strictAllowListConvenienceTrackingProtectionGeckoViewModifiedPref, true)
            setDefaultPref(engine, strictAllowListConvenienceTrackingProtectionGeckoViewModifiedPref, true)
        }
    }
}

/**
 * Set a Gecko preference (geckoPreference) to a desired value (geckoPreferenceValue)
 *
 * @param engine Gecko engine
 * @param geckoPreference The desired Gecko preference
 * @param geckoPreferenceValue The desired Gecko preference value
 * @param geckoPreferenceBranch The desired Gecko preference branch (Currently, user or default)
 */
internal fun setPref(
    engine: Engine,
    geckoPreference: String,
    geckoPreferenceValue: Any,
    geckoPreferenceBranch: Branch,
) {
    @OptIn(ExperimentalAndroidComponentsApi::class)
    when (geckoPreferenceValue) {
        is String -> engine.setBrowserPref(
            geckoPreference,
            geckoPreferenceValue,
            geckoPreferenceBranch,
            onSuccess = {},
            onError = {}
        )
        is Boolean -> engine.setBrowserPref(
            geckoPreference,
            geckoPreferenceValue,
            geckoPreferenceBranch,
            onSuccess = {},
            onError = {}
        )
        is Int -> engine.setBrowserPref(
            geckoPreference,
            geckoPreferenceValue,
            geckoPreferenceBranch,
            onSuccess = {},
            onError = {}
        )
        else -> throw IllegalArgumentException("Unsupported preference value type: ${geckoPreferenceValue::class.java}")
    }
}

/**
 * Set a Gecko preference (geckoPreference) to a desired user value (geckoPreferenceValue)
 * This should be set in combination with setDefaultPref in most cases, as it ensures that Gecko can read/access the pref value
 * earlier in start-up, though note that this MUST be run BEFORE setDefaultPref for it to work properly in those cases
 * @param engine Gecko engine
 * @param geckoPreference The desired Gecko preference
 * @param geckoPreferenceValue The desired Gecko preference value
 */
internal fun setUserPref(
    engine: Engine,
    geckoPreference: String,
    geckoPreferenceValue: Any,
) {
    setPref(engine, geckoPreference, geckoPreferenceValue, Branch.USER)
}

/**
 * Set a Gecko preference (geckoPreference) to a desired default value (geckoPreferenceValue)
 * This also locks the preference to ensure its value is only controlled by the proper UI setting
 * 
 * @param engine Gecko engine
 * @param geckoPreference The desired Gecko preference
 * @param geckoPreferenceValue The desired Gecko preference value
 */
internal fun setDefaultPref(
    engine: Engine,
    geckoPreference: String,
    geckoPreferenceValue: Any,
) {
    setPref(engine, geckoPreference, geckoPreferenceValue, Branch.DEFAULT)
}

/**
 * Get the value of a Gecko preference (geckoPreference)
 *
 * @param engine Gecko engine
 * @param geckoPreference The desired Gecko preference
 */
internal suspend fun getPref(
    engine: Engine,
    geckoPreference: String,
): Any? = suspendCancellableCoroutine { continuation ->
    @OptIn(ExperimentalAndroidComponentsApi::class)
    engine.getBrowserPref(
        geckoPreference,
        onSuccess = { geckoPref ->
            continuation.resume(geckoPref.value)
        },
        onError = {
            continuation.resume(null)
        }
    )
}

/**
 * Reset the value of a Gecko preference (geckoPreference)
 * This applies to user prefs
 * This should generally NOT be used, in favor of using clearPref() at ironfox.cfg
 *
 * @param engine Gecko engine
 * @param geckoPreference The desired Gecko preference
 */
internal fun clearPref(
    engine: Engine,
    geckoPreference: String,
) {
    @OptIn(ExperimentalAndroidComponentsApi::class)
    engine.clearBrowserUserPref(
        geckoPreference,
        onSuccess = {},
        onError = {}
    )
}
