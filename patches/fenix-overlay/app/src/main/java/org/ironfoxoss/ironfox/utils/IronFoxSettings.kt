package org.ironfoxoss.ironfox.utils

import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.content.SharedPreferences
import mozilla.components.support.ktx.android.content.PreferencesHolder
import mozilla.components.support.ktx.android.content.booleanPreference
import mozilla.components.support.ktx.android.content.intPreference
import mozilla.components.support.ktx.android.content.longPreference
import mozilla.components.support.ktx.android.content.stringPreference
import org.ironfoxoss.ironfox.updater.UpdateInterval
import org.mozilla.fenix.R
import org.mozilla.fenix.ext.getPreferenceKey

/**
 *
 * @param context Application context
 */
class IronFoxSettings(private val context: Context) : PreferencesHolder {

  companion object {
    const val FENIX_PREFERENCES = "fenix_preferences"
  }

  override val preferences: SharedPreferences = context.getSharedPreferences(FENIX_PREFERENCES, MODE_PRIVATE)

  var accessibilityEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_accessibility_enabled),
      default = false,
    )

  var alwaysUsePrivateBrowsing by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_always_use_private_browsing),
      default = false,
    )

  var autoplayBlockingClickToPlay by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_autoplay_policy_click_to_play),
      default = false,
    )

  var autoplayBlockingSticky by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_autoplay_policy_sticky),
      default = false,
    )

  var autoplayBlockingTransient by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_autoplay_policy_transient),
      default = true,
    )

  var cacheEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_cache_enabled),
      default = false,
    )

  // This is for our legacy collection setting - to be removed!
  var collections by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_collections_enabled),
      default = true,
    )

  var collectionsMigrated by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_collections_migrated),
      default = false,
    )

  var emeEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_eme_enabled),
      default = false,
    )

  var enableUnifiedPush by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_enable_unifiedpush),
      default = true,
    )

  var fppOverridesIronFoxEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_fpp_overrides_ironfox_enabled),
      default = true,
    )

  var fppOverridesIronFoxTimezoneEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_fpp_overrides_ironfox_timezone_enabled),
      default = true,
    )

  var fppOverridesIronFoxWebGLEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_fpp_overrides_ironfox_webgl_enabled),
      default = true,
    )

  var fppOverridesMozillaEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_fpp_overrides_mozilla_enabled),
      default = true,
    )

  var fxaEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_fxa_enabled),
      default = true,
    )

  var geoProviderAndroidEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_geo_provider_android_enabled),
      default = true,
    )

  var geoProviderNetworkEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_geo_provider_network_enabled),
      default = true,
    )

  var historyEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_history_enabled),
      default = false,
    )

  var historyEnabledCachedValue by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_history_enabled_cached_value),
      default = false,
    )

  var historyMetadataUIFeatureCachedValue by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_history_metadata_feature_cached_value),
      default = false,
    )

  var ipProtectionEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_ip_protection_enabled),
      default = true,
    )

  var ipProtectionEnabledCachedValue by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_ip_protection_enabled_cached_value),
      default = true,
    )

  var ipv6Enabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ipv6_enabled),
      default = true,
    )

  var isAddressSyncEnabledCachedValue by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_enable_address_sync_cached_value),
      default = true,
    )

  var isEmailMaskSuggestionEnabledCachedValue by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_email_mask_suggestion_cached_value),
      default = false,
    )

  var ironFoxOnboardingCompleted by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_if_onboarding_completed),
      default = false,
    )

  var javascriptEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_javascript_enabled),
      default = true,
    )

  var javascriptJitEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_jit_enabled),
      default = false,
    )

  var javascriptJitTrustedPrincipalsEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_jit_trusted_principals_enabled),
      default = false,
    )

  var openLinksInAPrivateTabCachedValue by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_open_links_in_a_private_tab_cached_value),
      default = false,
    )

  var pdfjsDisabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_pdfjs_disabled),
      default = false,
    )

  var prefersBrowserColorScheme by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_prefers_browser_color_scheme),
      default = false,
    )

  var prefersDarkColorScheme by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_prefers_dark_color_scheme),
      default = false,
    )

  var prefersLightColorScheme by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_prefers_light_color_scheme),
      default = true,
    )

  var printEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_print_enabled),
      default = true,
    )

  var refererXOriginAlways by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_referer_policy_always),
      default = true,
    )

  var refererXOriginBaseDomainsMatch by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_referer_policy_base_domains_match),
      default = false,
    )

  var refererXOriginHostsMatch by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_referer_policy_hosts_match),
      default = false,
    )

  var safeBrowsingEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_safe_browsing_enabled),
      default = true,
    )

  var shownDohMigrationMessage by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_ironfox_shown_doh_migration_message),
      default = false,
    )

  var spoofEnglish by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_spoof_english),
      default = true,
    )

  var spoofTimezone by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_spoof_timezone),
      default = false,
    )

  var svgEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_svg_enabled),
      default = true,
    )

  var translationsEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_translations_enabled),
      default = true,
    )

  var useUnifiedPush by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_use_unifiedpush),
      default = false,
    )

  /** The updater's settings and state. */
  var updaterAllowInsecureHttp by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_allow_insecure_http),
      default = false,
    )

  var updaterAutoDownload by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_auto_download),
      default = { updaterOriginalStore.isEmpty() },
    )

  var updaterDirectDownloads by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_direct_downloads),
      default = false,
    )

  var updaterDismissedVersion by
    stringPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_dismissed_version),
      default = "",
    )

  var updaterEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_enabled),
      default = true,
    )

  var updaterIntervalHours by
    intPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_interval_hours),
      default = UpdateInterval.DEFAULT_HOURS,
    )

  var updaterLastCheckMillis by
    longPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_last_check),
      default = 0L,
    )

  var updaterLastFailureMillis by
    longPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_last_failure),
      default = 0L,
    )

  var updaterOriginalStore by
    stringPreference(
      key = context.getPreferenceKey(R.string.pref_key_updater_original_store),
      default = "",
    )

  var wasmEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_wasm_enabled),
      default = true,
    )

  var webglDisabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_webgl_disabled),
      default = true,
    )

  var webrtcEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_webrtc_enabled),
      default = true,
    )

  var xpinstallEnabled by
    booleanPreference(
      key = context.getPreferenceKey(R.string.pref_key_xpinstall_enabled),
      default = false,
    )
}
