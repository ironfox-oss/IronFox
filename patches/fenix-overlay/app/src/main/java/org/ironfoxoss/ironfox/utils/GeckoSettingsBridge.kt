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
  }

  fun setIronFoxOnboardingCompleted(context: Context, engine: Engine) {
    val ironFoxOnboardingCompleted = IronFoxPreferences.isIronFoxOnboardingCompleted(context)
    setDefaultPref(engine, "browser.ironfox.onboardingCompleted", ironFoxOnboardingCompleted)
  }

  fun setWebGLDisabled(context: Context, engine: Engine) {
    val webglDisabled = IronFoxPreferences.isWebGLDisabled(context)
    setDefaultPref(engine, "browser.ironfox.webgl.disabled", webglDisabled)
  }

  fun setAccessibilityEnabled(context: Context, engine: Engine) {
    val accessibilityEnabled = IronFoxPreferences.isAccessibilityEnabled(context)
    setDefaultPref(engine, "browser.ironfox.fenix.accessibilityEnabled", accessibilityEnabled)
  }

  fun setJavaScriptEnabled(context: Context, engine: Engine) {
    val javascriptEnabled = IronFoxPreferences.isJavaScriptEnabled(context)
    setDefaultPref(engine, "javascript.enabled", javascriptEnabled)
  }

  fun setFPPOverridesIronFoxWebGLEnabled(context: Context, engine: Engine) {
    val fppOverridesIronFoxWebGLEnabled = IronFoxPreferences.isFPPOverridesIronFoxWebGLEnabled(context)
    setDefaultPref(engine, "browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled", fppOverridesIronFoxWebGLEnabled)
  }

  fun setAlwaysUsePrivateBrowsing(context: Context, engine: Engine) {
    val alwaysUsePrivateBrowsing = IronFoxPreferences.isAlwaysUsePrivateBrowsing(context)
    setDefaultPref(engine, "browser.privatebrowsing.autostart", alwaysUsePrivateBrowsing)
  }

  fun setCacheEnabled(context: Context, engine: Engine) {
    val cacheEnabled = IronFoxPreferences.isCacheEnabled(context)
    setDefaultPref(engine, "browser.cache.disk.enable", cacheEnabled)
  }

  fun setFPPOverridesIronFoxEnabled(context: Context, engine: Engine) {
    val fppOverridesIronFoxEnabled = IronFoxPreferences.isFPPOverridesIronFoxEnabled(context)
    setDefaultPref(engine, "browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled", fppOverridesIronFoxEnabled)
  }

  fun setFPPOverridesMozillaEnabled(context: Context, engine: Engine) {
    val fppOverridesMozillaEnabled = IronFoxPreferences.isFPPOverridesMozillaEnabled(context)
    setDefaultPref(engine, "browser.ironfox.fingerprintingProtection.mozillaOverrides.enabled", fppOverridesMozillaEnabled)
  }

  fun setFPPOverridesIronFoxTimezoneEnabled(context: Context, engine: Engine) {
    val fppOverridesIronFoxTimezoneEnabled = IronFoxPreferences.isFPPOverridesIronFoxTimezoneEnabled(context)
    setDefaultPref(engine, "browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled", fppOverridesIronFoxTimezoneEnabled)
  }

  fun setSpoofEnglishEnabled(context: Context, engine: Engine) {
    val spoofEnglish = IronFoxPreferences.isSpoofEnglishEnabled(context)
    setDefaultPref(engine, "browser.ironfox.fenix.spoofEnglish", spoofEnglish)
  }

  fun setSpoofTimezoneEnabled(context: Context, engine: Engine) {
    val spoofTimezone = IronFoxPreferences.isSpoofTimezoneEnabled(context)
    setDefaultPref(engine, "browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled", spoofTimezone)
  }

  fun setXPInstallEnabled(context: Context, engine: Engine) {
    val xpinstallEnabled = IronFoxPreferences.isXPInstallEnabled(context)
    setDefaultPref(engine, "browser.ironfox.xpinstall.enabled", xpinstallEnabled)
  }

  fun setJITEnabled(context: Context, engine: Engine) {
    val javascriptJitEnabled = IronFoxPreferences.isJITEnabled(context)
    setDefaultPref(engine, "browser.ironfox.fenix.javascriptJitEnabled", javascriptJitEnabled)
  }

  fun setJITTrustedPrincipalsEnabled(context: Context, engine: Engine) {
    val javascriptJitTrustedPrincipalsEnabled = IronFoxPreferences.isJITTrustedPrincipalsEnabled(context)
    setDefaultPref(engine, "javascript.options.jit_trustedprincipals", javascriptJitTrustedPrincipalsEnabled)
  }

  fun setPrintEnabled(context: Context, engine: Engine) {
    val printEnabled = IronFoxPreferences.isPrintEnabled(context)
    setDefaultPref(engine, "print.enabled", printEnabled)
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
    setDefaultPref(engine, "javascript.options.wasm", wasmEnabled)
  }

  fun setWebRTCEnabled(context: Context, engine: Engine) {
    val webrtcEnabled = IronFoxPreferences.isWebRTCEnabled(context)
    setDefaultPref(engine, "media.peerconnection.enabled", webrtcEnabled)
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
    setDefaultPref(engine, "pdfjs.disabled", pdfjsDisabled)
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
    setDefaultPref(engine, "extensions.formautofill.addresses.enabled", addressAutofillEnabled)
  }

  fun setCardAutofillEnabled(context: Context, engine: Engine) {
    val cardAutofillEnabled = context.settings().shouldAutofillCreditCardDetails
    setDefaultPref(engine, "extensions.formautofill.creditCards.enabled", cardAutofillEnabled)
  }

  fun setPasswordManagerEnabled(context: Context, engine: Engine) {
    val passwordManagerEnabled = context.settings().shouldPromptToSaveLogins
    setDefaultPref(engine, "signon.rememberSignons", passwordManagerEnabled)
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
