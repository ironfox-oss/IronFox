package org.ironfoxoss.ironfox.utils

import android.content.Context
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.suspendCancellableCoroutine
import mozilla.components.concept.engine.preferences.Branch
import mozilla.components.concept.engine.preferences.BrowserPreference
import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.Engine
import org.ironfoxoss.ironfox.utils.GeckoSettingsDictionary
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
        val emeGeckoPref = GeckoSettingsDictionary.emeEnabled
        @OptIn(ExperimentalAndroidComponentsApi::class)
        engine.getBrowserPref(
            emeGeckoPref,
            onSuccess = { emePref ->
                IronFoxPreferences.setEMEEnabled(context, emePref.value as Boolean)
            },
            onError = { throwable ->
                IronFoxPreferences.setEMEEnabled(context, false)
            }
        )
    }

    fun setIronFoxOnboardingCompleted(context: Context, engine: Engine) {
        val ironFoxOnboardingCompleted = IronFoxPreferences.isIronFoxOnboardingCompleted(context)
        val ironFoxOnboardingCompletedFenixPref = GeckoSettingsDictionary.fenixIronFoxOnboardingCompleted
        val ironFoxOnboardingCompletedFenixModifiedPref = GeckoSettingsDictionary.fenixIronFoxOnboardingCompletedModified
        val ironFoxOnboardingCompletedGeckoPref = GeckoSettingsDictionary.onboardingCompleted
        setUserPref(engine, ironFoxOnboardingCompletedFenixPref, ironFoxOnboardingCompleted)
        setDefaultPref(engine, ironFoxOnboardingCompletedFenixPref, ironFoxOnboardingCompleted)
        setUserPref(engine, ironFoxOnboardingCompletedGeckoPref, ironFoxOnboardingCompleted)
        setDefaultPref(engine, ironFoxOnboardingCompletedGeckoPref, ironFoxOnboardingCompleted)

        if (ironFoxOnboardingCompleted) {
            setUserPref(engine, ironFoxOnboardingCompletedFenixModifiedPref, true)
            setDefaultPref(engine, ironFoxOnboardingCompletedGeckoPref, true)
        }
    }

    fun setWebGLDisabled(context: Context, engine: Engine) {
        val webglDisabled = IronFoxPreferences.isWebGLDisabled(context)
        val webglFenixPref = GeckoSettingsDictionary.fenixWebglDisabled
        val webglFenixModifiedPref = GeckoSettingsDictionary.fenixWebglDisabledModified
        val webglGeckoPref = GeckoSettingsDictionary.webglDisabled
        setUserPref(engine, webglFenixPref, webglDisabled)
        setDefaultPref(engine, webglFenixPref, webglDisabled)
        setUserPref(engine, webglGeckoPref, webglDisabled)
        setDefaultPref(engine, webglGeckoPref, webglDisabled)

        if (!webglDisabled) {
            setUserPref(engine, webglFenixModifiedPref, true)
            setDefaultPref(engine, webglFenixModifiedPref, true)
        }
    }

    fun setAccessibilityEnabled(context: Context, engine: Engine) {
        val accessibilityEnabled = IronFoxPreferences.isAccessibilityEnabled(context)
        val accessibilityFenixPref = GeckoSettingsDictionary.fenixAccessibilityEnabled
        val accessibilityFenixModifiedPref = GeckoSettingsDictionary.fenixAccessibilityEnabledModified
        val accessibilityGeckoPref = GeckoSettingsDictionary.accessibilityDisabled
        setUserPref(engine, accessibilityFenixPref, accessibilityEnabled)
        setDefaultPref(engine, accessibilityFenixPref, accessibilityEnabled)
    
        if (accessibilityEnabled) {
            setUserPref(engine, accessibilityGeckoPref, 0)
            setDefaultPref(engine, accessibilityGeckoPref, 0)
            setUserPref(engine, accessibilityFenixModifiedPref, true)
            setDefaultPref(engine, accessibilityFenixModifiedPref, true)
        } else {
            setUserPref(engine, accessibilityGeckoPref, 1)
            setDefaultPref(engine, accessibilityGeckoPref, 1)
        }
    }

    fun setJavaScriptEnabled(context: Context, engine: Engine) {
        val javascriptEnabled = IronFoxPreferences.isJavaScriptEnabled(context)
        val javascriptFenixPref = GeckoSettingsDictionary.fenixJavascriptEnabled
        val javascriptFenixModifiedPref = GeckoSettingsDictionary.fenixJavascriptEnabledModified
        val javascriptGeckoPref = GeckoSettingsDictionary.javascriptEnabled
        setUserPref(engine, javascriptFenixPref, javascriptEnabled)
        setDefaultPref(engine, javascriptFenixPref, javascriptEnabled)
        setUserPref(engine, javascriptGeckoPref, javascriptEnabled)
        setDefaultPref(engine, javascriptGeckoPref, javascriptEnabled)

        if (!javascriptEnabled) {
            setUserPref(engine, javascriptFenixModifiedPref, true)
            setDefaultPref(engine, javascriptFenixModifiedPref, true)
        }
    }

    fun setFPPOverridesIronFoxWebGLEnabled(context: Context, engine: Engine) {
        val fppOverridesIronFoxWebGLEnabled = IronFoxPreferences.isFPPOverridesIronFoxWebGLEnabled(context)
        val fppOverridesIronFoxWebGLFenixPref = GeckoSettingsDictionary.fenixFppOverridesIronFoxWebGLEnabled
        val fppOverridesIronFoxWebGLFenixModifiedPref = GeckoSettingsDictionary.fenixFppOverridesIronFoxWebGLEnabledModified
        val fppOverridesIronFoxWebGLGeckoPref = GeckoSettingsDictionary.fppOverridesIFWebGL
        setUserPref(engine, fppOverridesIronFoxWebGLFenixPref, fppOverridesIronFoxWebGLEnabled)
        setDefaultPref(engine, fppOverridesIronFoxWebGLFenixPref, fppOverridesIronFoxWebGLEnabled)
        setUserPref(engine, fppOverridesIronFoxWebGLGeckoPref, fppOverridesIronFoxWebGLEnabled)
        setDefaultPref(engine, fppOverridesIronFoxWebGLGeckoPref, fppOverridesIronFoxWebGLEnabled)

        if (!fppOverridesIronFoxWebGLEnabled) {
            setUserPref(engine, fppOverridesIronFoxWebGLFenixModifiedPref, true)
            setDefaultPref(engine, fppOverridesIronFoxWebGLFenixModifiedPref, true)
        }
    }

    fun setAlwaysUsePrivateBrowsing(context: Context, engine: Engine) {
        val alwaysUsePrivateBrowsing = IronFoxPreferences.isAlwaysUsePrivateBrowsing(context)
        val alwaysUsePrivateBrowsingFenixPref = GeckoSettingsDictionary.fenixAlwaysUsePrivateBrowsing
        val alwaysUsePrivateBrowsingFenixModifiedPref = GeckoSettingsDictionary.fenixAlwaysUsePrivateBrowsingModified
        val alwaysUsePrivateBrowsingGeckoPref = GeckoSettingsDictionary.alwaysUsePrivateBrowsing
        setUserPref(engine, alwaysUsePrivateBrowsingFenixPref, alwaysUsePrivateBrowsing)
        setDefaultPref(engine, alwaysUsePrivateBrowsingFenixPref, alwaysUsePrivateBrowsing)
        setUserPref(engine, alwaysUsePrivateBrowsingGeckoPref, alwaysUsePrivateBrowsing)
        setDefaultPref(engine, alwaysUsePrivateBrowsingGeckoPref, alwaysUsePrivateBrowsing)

        if (alwaysUsePrivateBrowsing) {
            setUserPref(engine, alwaysUsePrivateBrowsingFenixModifiedPref, true)
            setDefaultPref(engine, alwaysUsePrivateBrowsingFenixModifiedPref, true)
        }
    }

    fun setCacheEnabled(context: Context, engine: Engine) {
        val cacheEnabled = IronFoxPreferences.isCacheEnabled(context)
        val cacheEnabledFenixPref = GeckoSettingsDictionary.fenixCacheEnabled
        val cacheEnabledFenixModifiedPref = GeckoSettingsDictionary.fenixCacheEnabledModified
        val cacheEnabledGeckoPref = GeckoSettingsDictionary.cacheEnabled
        setUserPref(engine, cacheEnabledFenixPref, cacheEnabled)
        setDefaultPref(engine, cacheEnabledFenixPref, cacheEnabled)
        setUserPref(engine, cacheEnabledGeckoPref, cacheEnabled)
        setDefaultPref(engine, cacheEnabledGeckoPref, cacheEnabled)

        if (cacheEnabled) {
            setUserPref(engine, cacheEnabledFenixModifiedPref, true)
            setDefaultPref(engine, cacheEnabledFenixModifiedPref, true)
        }
    }

    fun setFPPOverridesIronFoxEnabled(context: Context, engine: Engine) {
        val fppOverridesIronFoxEnabled = IronFoxPreferences.isFPPOverridesIronFoxEnabled(context)
        val fppOverridesIronFoxFenixPref = GeckoSettingsDictionary.fenixFppOverridesIronFoxEnabled
        val fppOverridesIronFoxFenixModifiedPref = GeckoSettingsDictionary.fenixFppOverridesIronFoxEnabledModified
        val fppOverridesIronFoxGeckoPref = GeckoSettingsDictionary.fppOverridesIFUnbreak
        setUserPref(engine, fppOverridesIronFoxFenixPref, fppOverridesIronFoxEnabled)
        setDefaultPref(engine, fppOverridesIronFoxFenixPref, fppOverridesIronFoxEnabled)
        setUserPref(engine, fppOverridesIronFoxGeckoPref, fppOverridesIronFoxEnabled)
        setDefaultPref(engine, fppOverridesIronFoxGeckoPref, fppOverridesIronFoxEnabled)

        if (!fppOverridesIronFoxEnabled) {
            setUserPref(engine, fppOverridesIronFoxFenixModifiedPref, true)
            setDefaultPref(engine, fppOverridesIronFoxFenixModifiedPref, true)
        }
    }

    fun setFPPOverridesMozillaEnabled(context: Context, engine: Engine) {
        val fppOverridesMozillaEnabled = IronFoxPreferences.isFPPOverridesMozillaEnabled(context)
        val fppOverridesMozillaFenixPref = GeckoSettingsDictionary.fenixFppOverridesMozillaEnabled
        val fppOverridesMozillaFenixModifiedPref = GeckoSettingsDictionary.fenixFppOverridesMozillaEnabledModified
        val fppOverridesMozillaGeckoPref = GeckoSettingsDictionary.fppOverridesMozUnbreak
        setUserPref(engine, fppOverridesMozillaFenixPref, fppOverridesMozillaEnabled)
        setDefaultPref(engine, fppOverridesMozillaFenixPref, fppOverridesMozillaEnabled)
        setUserPref(engine, fppOverridesMozillaGeckoPref, fppOverridesMozillaEnabled)
        setDefaultPref(engine, fppOverridesMozillaGeckoPref, fppOverridesMozillaEnabled)

        if (!fppOverridesMozillaEnabled) {
            setUserPref(engine, fppOverridesMozillaFenixModifiedPref, true)
            setDefaultPref(engine, fppOverridesMozillaFenixModifiedPref, true)
        }
    }

    fun setFPPOverridesIronFoxTimezoneEnabled(context: Context, engine: Engine) {
        val fppOverridesIronFoxTimezoneEnabled = IronFoxPreferences.isFPPOverridesIronFoxTimezoneEnabled(context)
        val fppOverridesIronFoxTimezoneFenixPref = GeckoSettingsDictionary.fenixFppOverridesIronFoxTimezoneEnabled
        val fppOverridesIronFoxTimezoneFenixModifiedPref = GeckoSettingsDictionary.fenixFppOverridesIronFoxTimezoneEnabledModified
        val fppOverridesIronFoxTimezoneGeckoPref = GeckoSettingsDictionary.fppOverridesIFTimezone
        setUserPref(engine, fppOverridesIronFoxTimezoneFenixPref, fppOverridesIronFoxTimezoneEnabled)
        setDefaultPref(engine, fppOverridesIronFoxTimezoneFenixPref, fppOverridesIronFoxTimezoneEnabled)
        setUserPref(engine, fppOverridesIronFoxTimezoneGeckoPref, fppOverridesIronFoxTimezoneEnabled)
        setDefaultPref(engine, fppOverridesIronFoxTimezoneGeckoPref, fppOverridesIronFoxTimezoneEnabled)

        if (!fppOverridesIronFoxTimezoneEnabled) {
            setUserPref(engine, fppOverridesIronFoxTimezoneFenixModifiedPref, true)
            setDefaultPref(engine, fppOverridesIronFoxTimezoneFenixModifiedPref, true)
        }
    }

    fun setSpoofEnglishEnabled(context: Context, engine: Engine) {
        val spoofEnglish = IronFoxPreferences.isSpoofEnglishEnabled(context)
        val spoofEnglishFenixPref = GeckoSettingsDictionary.fenixSpoofEnglish
        val spoofEnglishFenixModifiedPref = GeckoSettingsDictionary.fenixSpoofEnglishModified
        val spoofEnglishGeckoPref = GeckoSettingsDictionary.spoofEnglish
        setUserPref(engine, spoofEnglishFenixPref, spoofEnglish)
        setDefaultPref(engine, spoofEnglishFenixPref, spoofEnglish)

        if (spoofEnglish) {
            setUserPref(engine, spoofEnglishGeckoPref, 2)
            setDefaultPref(engine, spoofEnglishGeckoPref, 2)
        } else {
            setUserPref(engine, spoofEnglishGeckoPref, 1)
            setDefaultPref(engine, spoofEnglishGeckoPref, 1)
            setUserPref(engine, spoofEnglishFenixModifiedPref, true)
            setDefaultPref(engine, spoofEnglishFenixModifiedPref, true)
        }
    }

    fun setSpoofTimezoneEnabled(context: Context, engine: Engine) {
        val spoofTimezone = IronFoxPreferences.isSpoofTimezoneEnabled(context)
        val spoofTimezoneFenixPref = GeckoSettingsDictionary.fenixSpoofTimezone
        val spoofTimezoneFenixModifiedPref = GeckoSettingsDictionary.fenixSpoofTimezoneModified
        val spoofTimezoneGeckoPref = GeckoSettingsDictionary.spoofTimezone
        setUserPref(engine, spoofTimezoneFenixPref, spoofTimezone)
        setDefaultPref(engine, spoofTimezoneFenixPref, spoofTimezone)
        setUserPref(engine, spoofTimezoneGeckoPref, spoofTimezone)
        setDefaultPref(engine, spoofTimezoneGeckoPref, spoofTimezone)

        if (spoofTimezone) {
            setUserPref(engine, spoofTimezoneFenixModifiedPref, true)
            setDefaultPref(engine, spoofTimezoneFenixModifiedPref, true)
        }
    }

    fun setXPInstallEnabled(context: Context, engine: Engine) {
        val xpinstallEnabled = IronFoxPreferences.isXPInstallEnabled(context)
        val xpinstallFenixPref = GeckoSettingsDictionary.fenixXpinstallEnabled
        val xpinstallFenixModifiedPref = GeckoSettingsDictionary.fenixXpinstallEnabledModified
        val xpinstallGeckoPref = GeckoSettingsDictionary.xpinstallEnabled
        setUserPref(engine, xpinstallFenixPref, xpinstallEnabled)
        setDefaultPref(engine, xpinstallFenixPref, xpinstallEnabled)
        setUserPref(engine, xpinstallGeckoPref, xpinstallEnabled)
        setDefaultPref(engine, xpinstallGeckoPref, xpinstallEnabled)

        if (xpinstallEnabled) {
            setUserPref(engine, xpinstallFenixModifiedPref, true)
            setDefaultPref(engine, xpinstallFenixModifiedPref, true)
        }
    }

    fun setJITEnabled(context: Context, engine: Engine) {
        val javascriptJitEnabled = IronFoxPreferences.isJITEnabled(context)
        val javascriptJitFenixPref = GeckoSettingsDictionary.fenixJavascriptJitEnabled
        val javascriptJitFenixModifiedPref = GeckoSettingsDictionary.fenixJavascriptJitEnabledModified
        val jitBaselineGeckoPref = GeckoSettingsDictionary.jitBaseline
        val jitIonGeckoPref = GeckoSettingsDictionary.jitIon
        val jitHintsGeckoPref = GeckoSettingsDictionary.jitHints
        val jitNativeRegexpGeckoPref = GeckoSettingsDictionary.jitNativeRegexp
        val jitWasmIonGeckoPref = GeckoSettingsDictionary.jitWasmIon
        setUserPref(engine, javascriptJitFenixPref, javascriptJitEnabled)
        setDefaultPref(engine, javascriptJitFenixPref, javascriptJitEnabled)

        setUserPref(engine, jitBaselineGeckoPref, javascriptJitEnabled)
        setDefaultPref(engine, jitBaselineGeckoPref, javascriptJitEnabled)

        setUserPref(engine, jitIonGeckoPref, javascriptJitEnabled)
        setDefaultPref(engine, jitIonGeckoPref, javascriptJitEnabled)

        setUserPref(engine, jitHintsGeckoPref, javascriptJitEnabled)
        setDefaultPref(engine, jitHintsGeckoPref, javascriptJitEnabled)

        setUserPref(engine, jitNativeRegexpGeckoPref, javascriptJitEnabled)
        setDefaultPref(engine, jitNativeRegexpGeckoPref, javascriptJitEnabled)

        setUserPref(engine, jitWasmIonGeckoPref, javascriptJitEnabled)
        setDefaultPref(engine, jitWasmIonGeckoPref, javascriptJitEnabled)

        if (javascriptJitEnabled) {
            setUserPref(engine, javascriptJitFenixModifiedPref, true)
            setDefaultPref(engine, javascriptJitFenixModifiedPref, true)
        }
    }

    fun setJITTrustedPrincipalsEnabled(context: Context, engine: Engine) {
        val javascriptJitTrustedPrincipalsEnabled = IronFoxPreferences.isJITTrustedPrincipalsEnabled(context)
        val jitTrustedPrincipalsFenixPref = GeckoSettingsDictionary.fenixJavascriptJitTrustedPrincipalsEnabled
        val jitTrustedPrincipalsFenixModifiedPref = GeckoSettingsDictionary.fenixJavascriptJitTrustedPrincipalsEnabled
        val jitTrustedPrincipalsGeckoPref = GeckoSettingsDictionary.jitTrustedPrincipals
        setUserPref(engine, jitTrustedPrincipalsFenixPref, javascriptJitTrustedPrincipalsEnabled)
        setDefaultPref(engine, jitTrustedPrincipalsFenixPref, javascriptJitTrustedPrincipalsEnabled)
        setUserPref(engine, jitTrustedPrincipalsGeckoPref, javascriptJitTrustedPrincipalsEnabled)
        setDefaultPref(engine, jitTrustedPrincipalsGeckoPref, javascriptJitTrustedPrincipalsEnabled)

        if (javascriptJitTrustedPrincipalsEnabled) {
            setUserPref(engine, jitTrustedPrincipalsFenixModifiedPref, true)
            setDefaultPref(engine, jitTrustedPrincipalsFenixModifiedPref, true)
        }
    }

    fun setPrintEnabled(context: Context, engine: Engine) {
        val printEnabled = IronFoxPreferences.isPrintEnabled(context)
        val printFenixPref = GeckoSettingsDictionary.fenixPrintEnabled
        val printFenixModifiedPref = GeckoSettingsDictionary.fenixPrintEnabledModified
        val printGeckoPref = GeckoSettingsDictionary.printEnabled
        setUserPref(engine, printFenixPref, printEnabled)
        setDefaultPref(engine, printFenixPref, printEnabled)
        setUserPref(engine, printGeckoPref, printEnabled)
        setDefaultPref(engine, printGeckoPref, printEnabled)

        if (!printEnabled) {
            setUserPref(engine, printFenixModifiedPref, true)
            setDefaultPref(engine, printFenixModifiedPref, true)
        }
    }

    fun setSafeBrowsingEnabled(context: Context, engine: Engine) {
        val safeBrowsingEnabled = IronFoxPreferences.isSafeBrowsingEnabled(context)
        val safeBrowsingEnabledFenixPref = GeckoSettingsDictionary.fenixSafeBrowsingEnabled
        val safeBrowsingEnabledFenixModifiedPref = GeckoSettingsDictionary.fenixSafeBrowsingEnabledModified
        val safeBrowsingMalwareGeckoPref = GeckoSettingsDictionary.sbMalware
        val safeBrowsingPhishingGeckoPref = GeckoSettingsDictionary.sbPhishing
        setUserPref(engine, safeBrowsingEnabledFenixPref, safeBrowsingEnabled)
        setDefaultPref(engine, safeBrowsingEnabledFenixPref, safeBrowsingEnabled)

        setUserPref(engine, safeBrowsingMalwareGeckoPref, safeBrowsingEnabled)
        setDefaultPref(engine, safeBrowsingMalwareGeckoPref, safeBrowsingEnabled)

        setUserPref(engine, safeBrowsingPhishingGeckoPref, safeBrowsingEnabled)
        setDefaultPref(engine, safeBrowsingPhishingGeckoPref, safeBrowsingEnabled)

       if (!safeBrowsingEnabled) {
            setUserPref(engine, safeBrowsingEnabledFenixModifiedPref, true)
            setDefaultPref(engine, safeBrowsingEnabledFenixModifiedPref, true)
        }
    }

    fun setSVGEnabled(context: Context, engine: Engine) {
        val svgEnabled = IronFoxPreferences.isSVGEnabled(context)
        val svgFenixPref = GeckoSettingsDictionary.fenixSvgEnabled
        val svgFenixModifiedPref = GeckoSettingsDictionary.fenixSvgEnabledModified
        val svgGeckoPref = GeckoSettingsDictionary.svgDisabled
        setUserPref(engine, svgFenixPref, svgEnabled)
        setDefaultPref(engine, svgFenixPref, svgEnabled)
        setUserPref(engine, svgGeckoPref, !svgEnabled)
        setDefaultPref(engine, svgGeckoPref, !svgEnabled)

        if (!svgEnabled) {
            setUserPref(engine, svgFenixModifiedPref, true)
            setDefaultPref(engine, svgFenixModifiedPref, true)
        }
    }

    fun setWASMEnabled(context: Context, engine: Engine) {
        val wasmEnabled = IronFoxPreferences.isWASMEnabled(context)
        val wasmFenixPref = GeckoSettingsDictionary.fenixWasmEnabled
        val wasmFenixModifiedPref = GeckoSettingsDictionary.fenixWasmEnabledModified
        val wasmGeckoPref = GeckoSettingsDictionary.wasm
        setUserPref(engine, wasmFenixPref, wasmEnabled)
        setDefaultPref(engine, wasmFenixPref, wasmEnabled)
        setUserPref(engine, wasmGeckoPref, wasmEnabled)
        setDefaultPref(engine, wasmGeckoPref, wasmEnabled)

        if (!wasmEnabled) {
            setUserPref(engine, wasmFenixModifiedPref, true)
            setDefaultPref(engine, wasmFenixModifiedPref, true)
        }
    }

    fun setWebRTCEnabled(context: Context, engine: Engine) {
        val webrtcEnabled = IronFoxPreferences.isWebRTCEnabled(context)
        val webrtcFenixPref = GeckoSettingsDictionary.fenixWebrtcEnabled
        val webrtcFenixModifiedPref = GeckoSettingsDictionary.fenixWebrtcEnabledModified
        val webrtcGeckoPref = GeckoSettingsDictionary.webrtcEnabled
        setUserPref(engine, webrtcFenixPref, webrtcEnabled)
        setDefaultPref(engine, webrtcFenixPref, webrtcEnabled)
        setUserPref(engine, webrtcGeckoPref, webrtcEnabled)
        setDefaultPref(engine, webrtcGeckoPref, webrtcEnabled)

        if (!webrtcEnabled) {
            setUserPref(engine, webrtcFenixModifiedPref, true)
            setDefaultPref(engine, webrtcFenixModifiedPref, true)
        }
    }

    fun setTranslationsEnabled(context: Context, engine: Engine) {
        val translationsEnabled = IronFoxPreferences.isTranslationsEnabled(context)
        val translationsEnabledFenixPref = GeckoSettingsDictionary.fenixTranslationsEnabled
        val translationsEnabledFenixModifiedPref = GeckoSettingsDictionary.fenixTranslationsEnabledModified
        val translationsAiControlGeckoPref = GeckoSettingsDictionary.translationsAiControl
        val translationsEnabledGeckoPref = GeckoSettingsDictionary.translationsEnabled
        val translationsSupportedGeckoPref = GeckoSettingsDictionary.translationsUnsupported
        setUserPref(engine, translationsEnabledFenixPref, translationsEnabled)
        setDefaultPref(engine, translationsEnabledFenixPref, translationsEnabled)
        setUserPref(engine, translationsEnabledGeckoPref, translationsEnabled)
        setDefaultPref(engine, translationsEnabledGeckoPref, translationsEnabled)
        setUserPref(engine, translationsSupportedGeckoPref, !translationsEnabled)
        setDefaultPref(engine, translationsSupportedGeckoPref, !translationsEnabled)

        if (translationsEnabled) {
            setUserPref(engine, translationsAiControlGeckoPref, "enabled")
            setDefaultPref(engine, translationsAiControlGeckoPref, "enabled")
        } else {
            setUserPref(engine, translationsAiControlGeckoPref, "blocked")
            setDefaultPref(engine, translationsAiControlGeckoPref, "blocked")
            setUserPref(engine, translationsEnabledFenixModifiedPref, true)
            setDefaultPref(engine, translationsEnabledFenixModifiedPref, true)
        }
    }

    fun setIPv6Enabled(context: Context, engine: Engine) {
        val ipv6Enabled = IronFoxPreferences.isIPv6Enabled(context)
        val ipv6FenixPref = GeckoSettingsDictionary.fenixIpv6Enabled
        val ipv6FenixModifiedPref = GeckoSettingsDictionary.fenixIpv6EnabledModified
        val ipv6GeckoPref = GeckoSettingsDictionary.ipv6Disabled
        setUserPref(engine, ipv6FenixPref, ipv6Enabled)
        setDefaultPref(engine, ipv6FenixPref, ipv6Enabled)
        setUserPref(engine, ipv6GeckoPref, !ipv6Enabled)
        setDefaultPref(engine, ipv6GeckoPref, !ipv6Enabled)

        if (!ipv6Enabled) {
            setUserPref(engine, ipv6FenixModifiedPref, true)
            setDefaultPref(engine, ipv6FenixModifiedPref, true)
        }
    }

    fun setPDFjsDisabled(context: Context, engine: Engine) {
        val pdfjsDisabled = IronFoxPreferences.isPDFjsDisabled(context)
        val pdfjsFenixPref = GeckoSettingsDictionary.fenixPdfjsDisabled
        val pdfjsFenixModifiedPref = GeckoSettingsDictionary.fenixPdfjsDisabledModified
        val pdfjsGeckoPref = GeckoSettingsDictionary.pdfjsDisabled
        setUserPref(engine, pdfjsFenixPref, pdfjsDisabled)
        setDefaultPref(engine, pdfjsFenixPref, pdfjsDisabled)
        setUserPref(engine, pdfjsGeckoPref, pdfjsDisabled)
        setDefaultPref(engine, pdfjsGeckoPref, pdfjsDisabled)

        if (pdfjsDisabled) {
            setUserPref(engine, pdfjsFenixModifiedPref, true)
            setDefaultPref(engine, pdfjsFenixModifiedPref, true)
        }
    }

    fun setAutoplayBlockingPolicy(context: Context, engine: Engine) {
        val autoplayBlockingClickToPlay = IronFoxPreferences.isAutoplayBlockingClickToPlay(context)
        val autoplayBlockingSticky = IronFoxPreferences.isAutoplayBlockingSticky(context)
        val autoplayBlockingTransient = IronFoxPreferences.isAutoplayBlockingTransient(context)
        val autoplayBlockingClickToPlayFenixPref = GeckoSettingsDictionary.fenixAutoplayBlockingClickToPlay
        val autoplayBlockingClickToPlayFenixModifiedPref = GeckoSettingsDictionary.fenixAutoplayBlockingClickToPlayModified
        val autoplayBlockingStickyFenixPref = GeckoSettingsDictionary.fenixAutoplayBlockingSticky
        val autoplayBlockingStickyFenixModifiedPref = GeckoSettingsDictionary.fenixAutoplayBlockingStickyModified
        val autoplayBlockingTransientFenixPref = GeckoSettingsDictionary.fenixAutoplayBlockingTransient
        val autoplayBlockingTransientFenixModifiedPref = GeckoSettingsDictionary.fenixAutoplayBlockingTransientModified
        val autoplayBlockingPolicyGeckoPref = GeckoSettingsDictionary.autoplayPolicy
        setUserPref(engine, autoplayBlockingClickToPlayFenixPref, autoplayBlockingClickToPlay)
        setDefaultPref(engine, autoplayBlockingClickToPlayFenixPref, autoplayBlockingClickToPlay)
        setUserPref(engine, autoplayBlockingStickyFenixPref, autoplayBlockingSticky)
        setDefaultPref(engine, autoplayBlockingStickyFenixPref, autoplayBlockingSticky)
        setUserPref(engine, autoplayBlockingTransientFenixPref, autoplayBlockingTransient)
        setDefaultPref(engine, autoplayBlockingTransientFenixPref, autoplayBlockingTransient)

        if (autoplayBlockingClickToPlay) {
            setUserPref(engine, autoplayBlockingPolicyGeckoPref, 2)
            setDefaultPref(engine, autoplayBlockingPolicyGeckoPref, 2)
        } else if (autoplayBlockingSticky) {
            setUserPref(engine, autoplayBlockingPolicyGeckoPref, 0)
            setDefaultPref(engine, autoplayBlockingPolicyGeckoPref, 0)
        } else {
            setUserPref(engine, autoplayBlockingPolicyGeckoPref, 1)
            setDefaultPref(engine, autoplayBlockingPolicyGeckoPref, 1)
        }
 
        if (autoplayBlockingClickToPlay || autoplayBlockingSticky) {
            setUserPref(engine, autoplayBlockingClickToPlayFenixModifiedPref, true)
            setDefaultPref(engine, autoplayBlockingClickToPlayFenixModifiedPref, true)
            setUserPref(engine, autoplayBlockingStickyFenixModifiedPref, true)
            setDefaultPref(engine, autoplayBlockingStickyFenixModifiedPref, true)
            setUserPref(engine, autoplayBlockingTransientFenixModifiedPref, true)
            setDefaultPref(engine, autoplayBlockingTransientFenixModifiedPref, true)
        }
    }

    fun setPreferredWebsiteAppearance(context: Context, engine: Engine) {
        val prefersBrowserColorScheme = IronFoxPreferences.isPrefersBrowserColorScheme(context)
        val prefersDarkColorScheme = IronFoxPreferences.isPrefersDarkColorScheme(context)
        val prefersLightColorScheme = IronFoxPreferences.isPrefersLightColorScheme(context)
        val prefersBrowserColorSchemeFenixPref = GeckoSettingsDictionary.fenixPrefersBrowserColorScheme
        val prefersBrowserColorSchemeFenixModifiedPref = GeckoSettingsDictionary.fenixPrefersBrowserColorSchemeModified
        val prefersDarkColorSchemeFenixPref = GeckoSettingsDictionary.fenixPrefersDarkColorScheme
        val prefersDarkColorSchemeFenixModifiedPref = GeckoSettingsDictionary.fenixPrefersDarkColorSchemeModified
        val prefersLightColorSchemeFenixPref = GeckoSettingsDictionary.fenixPrefersLightColorScheme
        val prefersLightColorSchemeFenixModifiedPref = GeckoSettingsDictionary.fenixPrefersLightColorSchemeModified
        val preferredWebsiteAppearanceGeckoPref = GeckoSettingsDictionary.websiteAppearance
        setUserPref(engine, prefersBrowserColorSchemeFenixPref, prefersBrowserColorScheme)
        setDefaultPref(engine, prefersBrowserColorSchemeFenixPref, prefersBrowserColorScheme)
        setUserPref(engine, prefersDarkColorSchemeFenixPref, prefersDarkColorScheme)
        setDefaultPref(engine, prefersDarkColorSchemeFenixPref, prefersDarkColorScheme)
        setUserPref(engine, prefersLightColorSchemeFenixPref, prefersLightColorScheme)
        setDefaultPref(engine, prefersLightColorSchemeFenixPref, prefersLightColorScheme)

        if (prefersBrowserColorScheme) {
            setUserPref(engine, preferredWebsiteAppearanceGeckoPref, 2)
            setDefaultPref(engine, preferredWebsiteAppearanceGeckoPref, 2)
        } else if (prefersDarkColorScheme) {
            setUserPref(engine, preferredWebsiteAppearanceGeckoPref, 0)
            setDefaultPref(engine, preferredWebsiteAppearanceGeckoPref, 0)
        } else {
            setUserPref(engine, preferredWebsiteAppearanceGeckoPref, 1)
            setDefaultPref(engine, preferredWebsiteAppearanceGeckoPref, 1)
        }

        if (prefersBrowserColorScheme || prefersDarkColorScheme) {
            setUserPref(engine, prefersBrowserColorSchemeFenixModifiedPref, true)
            setDefaultPref(engine, prefersBrowserColorSchemeFenixModifiedPref, true)
            setUserPref(engine, prefersDarkColorSchemeFenixModifiedPref, true)
            setDefaultPref(engine, prefersDarkColorSchemeFenixModifiedPref, true)
            setUserPref(engine, prefersLightColorSchemeFenixModifiedPref, true)
            setDefaultPref(engine, prefersLightColorSchemeFenixModifiedPref, true)
        }
    }

    fun setRefererXOriginPolicy(context: Context, engine: Engine) {
        val refererXOriginAlways = IronFoxPreferences.isRefererXOriginAlways(context)
        val refererXOriginBaseDomainsMatch = IronFoxPreferences.isRefererXOriginBaseDomainsMatch(context)
        val refererXOriginHostsMatch = IronFoxPreferences.isRefererXOriginHostsMatch(context)
        val refererXOriginAlwaysFenixPref = GeckoSettingsDictionary.fenixRefererXOriginAlways
        val refererXOriginAlwaysFenixModifiedPref = GeckoSettingsDictionary.fenixRefererXOriginAlwaysModified
        val refererXOriginBaseDomainsMatchFenixPref = GeckoSettingsDictionary.fenixRefererXOriginBaseDomainsMatch
        val refererXOriginBaseDomainsMatchFenixModifiedPref = GeckoSettingsDictionary.fenixRefererXOriginBaseDomainsMatchModified
        val refererXOriginHostsMatchFenixPref = GeckoSettingsDictionary.fenixRefererXOriginHostsMatch
        val refererXOriginHostsMatchFenixModifiedPref = GeckoSettingsDictionary.fenixRefererXOriginHostsMatchModified
        val refererXOriginPolicyGeckoPref = GeckoSettingsDictionary.refererXOriginPolicy
        setUserPref(engine, refererXOriginAlwaysFenixPref, refererXOriginAlways)
        setDefaultPref(engine, refererXOriginAlwaysFenixPref, refererXOriginAlways)
        setUserPref(engine, refererXOriginBaseDomainsMatchFenixPref, refererXOriginBaseDomainsMatch)
        setDefaultPref(engine, refererXOriginBaseDomainsMatchFenixPref, refererXOriginBaseDomainsMatch)
        setUserPref(engine, refererXOriginHostsMatchFenixPref, refererXOriginHostsMatch)
        setDefaultPref(engine, refererXOriginHostsMatchFenixPref, refererXOriginHostsMatch)

        if (refererXOriginHostsMatch) {
            setUserPref(engine, refererXOriginPolicyGeckoPref, 2)
            setDefaultPref(engine, refererXOriginPolicyGeckoPref, 2)
        } else if (refererXOriginBaseDomainsMatch) {
            setUserPref(engine, refererXOriginPolicyGeckoPref, 1)
            setDefaultPref(engine, refererXOriginPolicyGeckoPref, 1)
        } else {
            setUserPref(engine, refererXOriginPolicyGeckoPref, 0)
            setDefaultPref(engine, refererXOriginPolicyGeckoPref, 0)
        }

        if (refererXOriginHostsMatch || refererXOriginBaseDomainsMatch) {
            setUserPref(engine, refererXOriginHostsMatchFenixModifiedPref, true)
            setDefaultPref(engine, refererXOriginHostsMatchFenixModifiedPref, true)
            setUserPref(engine, refererXOriginBaseDomainsMatchFenixModifiedPref, true)
            setDefaultPref(engine, refererXOriginBaseDomainsMatchFenixModifiedPref, true)
            setUserPref(engine, refererXOriginAlwaysFenixModifiedPref, true)
            setDefaultPref(engine, refererXOriginAlwaysFenixModifiedPref, true)
        }
    }

    fun setAddressAutofillEnabled(context: Context, engine: Engine) {
        val addressAutofillEnabled = context.settings().shouldAutofillAddressDetails
        val addressAutofillFenixPref = GeckoSettingsDictionary.fenixShouldAutofillAddressDetails
        val addressAutofillFenixModifiedPref = GeckoSettingsDictionary.fenixShouldAutofillAddressDetailsModified
        val addressAutofillGeckoPref = GeckoSettingsDictionary.addressAutofill
        setUserPref(engine, addressAutofillFenixPref, addressAutofillEnabled)
        setDefaultPref(engine, addressAutofillFenixPref, addressAutofillEnabled)
        setUserPref(engine, addressAutofillGeckoPref, addressAutofillEnabled)
        setDefaultPref(engine, addressAutofillGeckoPref, addressAutofillEnabled)

        if (addressAutofillEnabled) {
            setUserPref(engine, addressAutofillFenixModifiedPref, true)
            setDefaultPref(engine, addressAutofillFenixModifiedPref, true)
        }
    }

    fun setCardAutofillEnabled(context: Context, engine: Engine) {
        val cardAutofillEnabled = context.settings().shouldAutofillCreditCardDetails
        val cardAutofillFenixPref = GeckoSettingsDictionary.fenixShouldAutofillCreditCardDetails
        val cardAutofillFenixModifiedPref = GeckoSettingsDictionary.fenixShouldAutofillCreditCardDetailsModified
        val cardAutofillGeckoPref = GeckoSettingsDictionary.cardAutofill
        setUserPref(engine, cardAutofillFenixPref, cardAutofillEnabled)
        setDefaultPref(engine, cardAutofillFenixPref, cardAutofillEnabled)
        setUserPref(engine, cardAutofillGeckoPref, cardAutofillEnabled)
        setDefaultPref(engine, cardAutofillGeckoPref, cardAutofillEnabled)

        if (cardAutofillEnabled) {
            setUserPref(engine, cardAutofillFenixModifiedPref, true)
            setDefaultPref(engine, cardAutofillFenixModifiedPref, true)
        }
    }

    fun setPasswordManagerEnabled(context: Context, engine: Engine) {
        val passwordManagerEnabled = context.settings().shouldPromptToSaveLogins
        val passwordManagerFenixPref = GeckoSettingsDictionary.fenixShouldPromptToSaveLogins
        val passwordManagerFenixModifiedPref = GeckoSettingsDictionary.fenixShouldPromptToSaveLoginsModified
        val passwordManagerGeckoPref = GeckoSettingsDictionary.passwordManager
        setUserPref(engine, passwordManagerFenixPref, passwordManagerEnabled)
        setDefaultPref(engine, passwordManagerFenixPref, passwordManagerEnabled)
        setUserPref(engine, passwordManagerGeckoPref, passwordManagerEnabled)
        setDefaultPref(engine, passwordManagerGeckoPref, passwordManagerEnabled)

        if (passwordManagerEnabled) {
            setUserPref(engine, passwordManagerFenixModifiedPref, true)
            setDefaultPref(engine, passwordManagerFenixModifiedPref, true)
        }
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
