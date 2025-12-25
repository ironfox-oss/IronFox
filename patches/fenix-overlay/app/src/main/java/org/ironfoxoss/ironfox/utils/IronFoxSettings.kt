package org.ironfoxoss.ironfox.utils

import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.content.SharedPreferences
import mozilla.components.support.ktx.android.content.PreferencesHolder
import mozilla.components.support.ktx.android.content.booleanPreference
import org.ironfoxoss.ironfox.utils.FenixSettingsDictionary
import org.mozilla.fenix.ext.getPreferenceKey

/**
 *
 * @param context The application context
 */
class IronFoxSettings(private val context: Context) : PreferencesHolder {

    companion object {
        const val FENIX_PREFERENCES = "fenix_preferences"
    }

    override val preferences: SharedPreferences =
        context.getSharedPreferences(FENIX_PREFERENCES, MODE_PRIVATE)

    var accessibilityEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.accessibilityEnabled),
        default = false,
    )

    var alwaysUsePrivateBrowsing by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.alwaysUsePrivateBrowsing),
        default = false,
    )

    var autoplayBlockingClickToPlay by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.autoplayBlockingClickToPlay),
        default = false,
    )

    var autoplayBlockingSticky by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.autoplayBlockingSticky),
        default = false,
    )

    var autoplayBlockingTransient by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.autoplayBlockingTransient),
        default = true,
    )

    var cacheEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.cacheEnabled),
        default = false,
    )

    var emeEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.emeEnabled),
        default = false,
    )

    var enableUnifiedPush by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.enableUnifiedPush),
        default = true,
    )

    var fppOverridesIronFoxEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.fppOverridesIronFoxEnabled),
        default = true,
    )

    var fppOverridesIronFoxTimezoneEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.fppOverridesIronFoxTimezoneEnabled),
        default = true,
    )

    var fppOverridesIronFoxWebGLEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.fppOverridesIronFoxWebGLEnabled),
        default = true,
    )

    var fppOverridesMozillaEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.fppOverridesMozillaEnabled),
        default = true,
    )

    var ipv6Enabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.ipv6Enabled),
        default = true,
    )

    var ironFoxOnboardingCompleted by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.ironFoxOnboardingCompleted),
        default = false,
    )

    var javascriptEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.javascriptEnabled),
        default = true,
    )

    var javascriptJitEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.javascriptJitEnabled),
        default = false,
    )

    var javascriptJitTrustedPrincipalsEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.javascriptJitTrustedPrincipalsEnabled),
        default = false,
    )

    var openLinksInAPrivateTabCachedValue by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.openLinksInAPrivateTabCachedValue),
        default = false,
    )

    var pdfjsDisabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.pdfjsDisabled),
        default = false,
    )

    var prefersBrowserColorScheme by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.prefersBrowserColorScheme),
        default = false,
    )

    var prefersDarkColorScheme by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.prefersDarkColorScheme),
        default = false,
    )

    var prefersLightColorScheme by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.prefersLightColorScheme),
        default = true,
    )

    var printEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.printEnabled),
        default = true,
    )

    var refererXOriginAlways by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.refererXOriginAlways),
        default = true,
    )

    var refererXOriginBaseDomainsMatch by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.refererXOriginBaseDomainsMatch),
        default = false,
    )

    var refererXOriginHostsMatch by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.refererXOriginHostsMatch),
        default = false,
    )

    var safeBrowsingEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.safeBrowsingEnabled),
        default = true,
    )

    var shouldUseOledTheme by booleanPreference(
		key = context.getPreferenceKey(FenixSettingsDictionary.shouldUseOledTheme),
		default = false,
	)

    var spoofEnglish by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.spoofEnglish),
        default = true,
    )

    var spoofTimezone by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.spoofTimezone),
        default = false,
    )

    var svgEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.svgEnabled),
        default = true,
    )

    var translationsEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.translationsEnabled),
        default = true,
    )

    var useUnifiedPush by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.useUnifiedPush),
        default = false,
    )

    var wasmEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.wasmEnabled),
        default = true,
    )

    var webglDisabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.webglDisabled),
        default = true,
    )

    var webrtcEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.webrtcEnabled),
        default = true,
    )

    var xpinstallEnabled by booleanPreference(
        key = context.getPreferenceKey(FenixSettingsDictionary.xpinstallEnabled),
        default = false,
    )
}
