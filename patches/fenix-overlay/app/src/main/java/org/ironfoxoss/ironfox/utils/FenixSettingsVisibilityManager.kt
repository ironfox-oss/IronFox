package org.ironfoxoss.ironfox.utils

import android.content.Context
import android.os.Build
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import org.ironfoxoss.ironfox.utils.IronFoxPreferences
import org.mozilla.fenix.R
import org.mozilla.fenix.ext.getPreferenceKey

// Helpers for controlling the visibility of Fenix UI settings

object FenixSettingsVisibilityManager {

  /**
   * Control the visibility of settings at the general settings fragment
   *
   * @param context Application context
   * @param prefFragment Preference fragment
   */
  fun SettingsFragment(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    hidePreference(context, R.string.pref_key_data_choices, prefFragment)
    hidePreference(context, R.string.pref_key_link_sharing, prefFragment)
    hidePreference(context, R.string.pref_key_nimbus_experiments, prefFragment)
    hidePreference(context, R.string.pref_key_remote_improvements, prefFragment)
    hidePreference(context, R.string.pref_key_rate, prefFragment)
    hidePreference(context, R.string.pref_key_start_profiler, prefFragment)
    hidePreference(context, R.string.pref_key_remote_debugging, prefFragment)
    hideLocalAddonInstall(context, prefFragment)
  }

  /**
   * Control the visibility of settings at the secret settings fragment
   *
   * @param context Application context
   * @param prefFragment Preference fragment
   */
  fun SecretSettingsFragment(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    displayPreference(context, R.string.pref_key_enable_address_sync, prefFragment)
    displayPreference(context, R.string.pref_key_enable_homepage_as_new_tab, prefFragment)
    displayPreference(context, R.string.pref_key_enable_import_bookmarks, prefFragment)
    displayPreference(context, R.string.pref_key_enable_import_passwords, prefFragment)
    displayPreference(context, R.string.pref_key_enable_ip_protection, prefFragment)
    displayPreference(context, R.string.pref_key_enable_isolated_process, prefFragment)
    displayPreference(context, R.string.pref_key_enable_lna_blocking_enabled, prefFragment)
    displayPreference(context, R.string.pref_key_enable_lna_feature_enabled, prefFragment)
    displayPreference(context, R.string.pref_key_enable_lna_tracker_blocking_enabled, prefFragment)
    displayPreference(context, R.string.pref_key_native_share_sheet, prefFragment)
    displayPreference(context, R.string.pref_key_should_show_custom_tab_extensions, prefFragment)
    displayPreference(context, R.string.pref_key_show_voice_search_in_display_toolbar, prefFragment)
    displayPreference(context, R.string.pref_key_tab_groups, prefFragment)
    displayPreference(context, R.string.pref_key_tab_groups_drag_and_drop, prefFragment)
    displayPreference(context, R.string.pref_key_tab_groups_live_reorder, prefFragment)
    displayPreference(context, R.string.pref_key_use_minimal_bottom_toolbar_while_entering_text, prefFragment)
    displayPreference(context, R.string.pref_key_use_scroll_data_for_dynamic_toolbar, prefFragment)
    displayAppZygote(context, prefFragment)

    hidePreference(context, R.string.pref_key_crash_pull_never_show_again, prefFragment)
    hidePreference(context, R.string.pref_key_enable_ads_client_for_stories, prefFragment)
    hidePreference(context, R.string.pref_key_enable_homepage_sports_widget, prefFragment)
    hidePreference(context, R.string.pref_key_enable_uninstall_survey, prefFragment)
    hidePreference(context, R.string.pref_key_microsurvey_feature_enabled, prefFragment)
    hidePreference(context, R.string.pref_key_nimbus_use_preview, prefFragment)
    hidePreference(context, R.string.pref_key_private_mode_and_stories_entry_point, prefFragment)
    hidePreference(context, R.string.pref_key_use_remote_search_configuration, prefFragment)
  }

  /**
   * Control the visibility of settings at the site settings fragment
   *
   * @param context Application context
   * @param prefFragment Preference fragment
   */
  fun SiteSettingsFragment(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    hideEme(context, prefFragment)
  }

  /**
   * Control the visibility of settings at the tracking protection fragment
   *
   * @param context Application context
   * @param prefFragment Preference fragment
   */
  fun TrackingProtectionFragment(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    hidePreference(context, R.string.pref_key_privacy_enable_global_privacy_control, prefFragment)
    hidePreference(context, R.string.pref_key_tracking_protection, prefFragment)
    hidePreference(context, R.string.pref_key_tracking_protection_custom_option, prefFragment)
    hidePreference(context, R.string.pref_key_tracking_protection_standard_option, prefFragment)
    hidePreference(context, R.string.pref_key_tracking_protection_strict_default, prefFragment)
  }

  /**
   * Display the setting to toggle app zygote preloading
   *
   * @param context Application context
   * @param prefFragment Preference fragment
   */
  internal fun displayAppZygote(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    val appZygoteKey = context.getPreferenceKey(R.string.pref_key_enable_app_zygote_process)
    val appZygotePreference = prefFragment.findPreference<Preference>(appZygoteKey)
    appZygotePreference?.isVisible = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
  }

  /**
   * Hide the EME site setting
   *
   * @param context Application context
   * @param prefFragment Preference fragment
   */
  internal fun hideEme(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    val emeSiteSettingKey = context.getPreferenceKey(R.string.pref_key_browser_feature_media_key_system_access)
    val emeSiteSettingPreference = prefFragment.findPreference<Preference>(emeSiteSettingKey)
    emeSiteSettingPreference?.isVisible = IronFoxPreferences.isEMEEnabled(context)
  }

  /**
   * Hide the local add-on installation option
   *
   * @param context Application context
   * @param prefFragment Preference fragment
   */
  internal fun hideLocalAddonInstall(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    val localAddonInstallKey = context.getPreferenceKey(R.string.pref_key_install_local_addon)
    val localAddonInstallPreference = prefFragment.findPreference<Preference>(localAddonInstallKey)
    localAddonInstallPreference?.isVisible = IronFoxPreferences.isXPInstallEnabled(context) && IronFoxPreferences.shouldShowSecretDebugMenuThisSession(context)
  }

  /**
   * Display a hidden UI setting
   *
   * @param context Application context
   * @param pref Preference to display
   * @param prefFragment Preference fragment
   */
  internal fun displayPreference(
    context: Context,
    pref: Int,
    prefFragment: PreferenceFragmentCompat,
  ) {
    val prefKey = context.getPreferenceKey(pref)
    val preference = prefFragment.findPreference<Preference>(prefKey)
    preference?.isVisible = true
  }

  /**
   * Hide an unwanted UI setting
   *
   * @param context Application context
   * @param pref Preference to remove
   * @param prefFragment Preference fragment
   */
  internal fun hidePreference(
    context: Context,
    pref: Int,
    prefFragment: PreferenceFragmentCompat,
  ) {
    val prefKey = context.getPreferenceKey(pref)
    val preference = prefFragment.findPreference<Preference>(prefKey)
    preference?.isVisible = false
  }
}
