package org.ironfoxoss.ironfox.utils

import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.content.SharedPreferences
import mozilla.components.support.ktx.android.content.PreferencesHolder
import mozilla.components.support.ktx.android.content.booleanPreference
import org.mozilla.fenix.R
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
        context.getPreferenceKey(R.string.pref_key_accessibility_enabled),
        default = false,
    )

    var alwaysUsePrivateBrowsing by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_always_use_private_browsing),
        default = false,
    )

    var autoplayBlockingClickToPlay by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_autoplay_policy_click_to_play),
        default = false,
    )

    var autoplayBlockingSticky by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_autoplay_policy_sticky),
        default = false,
    )

    var autoplayBlockingTransient by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_autoplay_policy_transient),
        default = true,
    )

    var cacheEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_cache_enabled),
        default = false,
    )

    var emeEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_eme_enabled),
        default = false,
    )

    var enableUnifiedPush by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_enable_unifiedpush),
        default = true,
    )

    var fppOverridesIronFoxEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_fpp_overrides_ironfox_enabled),
        default = true,
    )

    var fppOverridesIronFoxTimezoneEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_fpp_overrides_ironfox_timezone_enabled),
        default = true,
    )

    var fppOverridesIronFoxWebGLEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_fpp_overrides_ironfox_webgl_enabled),
        default = true,
    )

    var fppOverridesMozillaEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_fpp_overrides_mozilla_enabled),
        default = true,
    )

    var ironFoxOnboardingCompleted by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_if_onboarding_completed),
        default = false,
    )

    var ipv6Enabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_ipv6_enabled),
        default = true,
    )

    var javascriptEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_javascript_enabled),
        default = true,
    )

    var javascriptJitEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_jit_enabled),
        default = false,
    )

    var javascriptJitTrustedPrincipalsEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_jit_trusted_principals_enabled),
        default = false,
    )

    var pdfjsDisabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_pdfjs_disabled),
        default = false,
    )

	var shouldUseOledTheme by booleanPreference(
		context.getPreferenceKey(R.string.pref_key_oled_theme),
		default = false,
	)

    var prefersBrowserColorScheme by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_prefers_browser_color_scheme),
        default = false,
    )

    var prefersDarkColorScheme by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_prefers_dark_color_scheme),
        default = false,
    )

    var prefersLightColorScheme by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_prefers_light_color_scheme),
        default = true,
    )

    var printEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_print_enabled),
        default = true,
    )

    var openLinksInAPrivateTabCachedValue by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_open_links_in_a_private_tab_cached_value),
        default = false,
    )

    var refererXOriginAlways by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_referer_policy_always),
        default = true,
    )

    var refererXOriginBaseDomainsMatch by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_referer_policy_base_domains_match),
        default = false,
    )

    var refererXOriginHostsMatch by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_referer_policy_hosts_match),
        default = false,
    )

    var safeBrowsingEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_safe_browsing_enabled),
        default = true,
    )

    var spoofEnglish by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_spoof_english),
        default = true,
    )

    var spoofTimezone by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_spoof_timezone),
        default = false,
    )

    var svgEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_svg_enabled),
        default = true,
    )

    var translationsEnabled by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_translations_enabled),
        default = true,
    )

    var useUnifiedPush by booleanPreference(
        key = context.getPreferenceKey(R.string.pref_key_use_unifiedpush),
        default = false,
    )

    var wasmEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_wasm_enabled),
        default = true,
    )

    var webglDisabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_webgl_disabled),
        default = true,
    )

    var webrtcEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_webrtc_enabled),
        default = true,
    )

    var xpinstallEnabled by booleanPreference(
        context.getPreferenceKey(R.string.pref_key_xpinstall_enabled),
        default = false,
    )
}
