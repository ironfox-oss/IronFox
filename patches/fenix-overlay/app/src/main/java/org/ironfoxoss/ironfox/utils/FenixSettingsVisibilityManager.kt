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
   * @param context The application context
   * @param prefFragment The preference fragment from where the preference should be displayed
   */
  fun SettingsFragment(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    hidePreference(R.string.pref_key_data_choices, prefFragment)
    hidePreference(R.string.pref_key_link_sharing, prefFragment)
    hidePreference(R.string.pref_key_nimbus_experiments, prefFragment)
    hidePreference(R.string.pref_key_remote_improvements, prefFragment)
    hidePreference(R.string.pref_key_rate, prefFragment)
    hidePreference(R.string.pref_key_start_profiler, prefFragment)
    hidePreference(R.string.pref_key_remote_debugging, prefFragment)
    hideLocalAddonInstall(context, prefFragment)
  }

  /**
   * Control the visibility of settings at the secret settings fragment
   *
   * @param context The application context
   * @param prefFragment The preference fragment from where the preference should be displayed
   */
  fun SecretSettingsFragment(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    displayPreference(R.string.pref_key_allow_settings_search, prefFragment)
    displayPreference(R.string.pref_key_enable_address_sync, prefFragment)
    displayPreference(R.string.pref_key_enable_homepage_as_new_tab, prefFragment)
    displayPreference(R.string.pref_key_enable_import_bookmarks, prefFragment)
    displayPreference(R.string.pref_key_enable_ip_protection, prefFragment)
    displayPreference(R.string.pref_key_enable_isolated_process, prefFragment)
    displayPreference(R.string.pref_key_enable_lna_blocking_enabled, prefFragment)
    displayPreference(R.string.pref_key_enable_lna_feature_enabled, prefFragment)
    displayPreference(R.string.pref_key_enable_lna_tracker_blocking_enabled, prefFragment)
    displayPreference(R.string.pref_key_enable_longfox, prefFragment)
    displayPreference(R.string.pref_key_native_share_sheet, prefFragment)
    displayPreference(R.string.pref_key_should_show_custom_tab_extensions, prefFragment)
    displayPreference(R.string.pref_key_tab_groups, prefFragment)
    displayPreference(R.string.pref_key_tab_groups_drag_and_drop, prefFragment)
    displayPreference(R.string.pref_key_tracking_protection_dashboard_status, prefFragment)
    displayPreference(R.string.pref_key_use_minimal_bottom_toolbar_while_entering_text, prefFragment)
    displayPreference(R.string.pref_key_use_scroll_data_for_dynamic_toolbar, prefFragment)
    displayAppZygote(context, prefFragment)

    hidePreference(R.string.pref_key_crash_pull_never_show_again, prefFragment)
    hidePreference(R.string.pref_key_enable_homepage_sports_widget, prefFragment)
    hidePreference(R.string.pref_key_enable_mozilla_ads_client, prefFragment)
    hidePreference(R.string.pref_key_microsurvey_feature_enabled, prefFragment)
    hidePreference(R.string.pref_key_nimbus_use_preview, prefFragment)
    hidePreference(R.string.pref_key_private_mode_and_stories_entry_point, prefFragment)
    hidePreference(R.string.pref_key_use_new_crash_reporter, prefFragment)
    hidePreference(R.string.pref_key_use_remote_search_configuration, prefFragment)
  }

  /**
   * Control the visibility of settings at the site settings fragment
   *
   * @param context The application context
   * @param prefFragment The preference fragment from where the preference should be displayed
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
   * @param context The application context
   * @param prefFragment The preference fragment from where the preference should be displayed
   */
  fun TrackingProtectionFragment(
    context: Context,
    prefFragment: PreferenceFragmentCompat
  ) {
    hidePreference(R.string.pref_key_privacy_enable_global_privacy_control, prefFragment)
    hidePreference(R.string.pref_key_tracking_protection, prefFragment)
    hidePreference(R.string.pref_key_tracking_protection_custom_option, prefFragment)
    hidePreference(R.string.pref_key_tracking_protection_standard_option, prefFragment)
    hidePreference(R.string.pref_key_tracking_protection_strict_default, prefFragment)
  }

  /**
   * Display the setting to toggle app zygote preloading
   *
   * @param context The application context
   * @param prefFragment The preference fragment from where the preference should be displayed
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
   * @param context The application context
   * @param prefFragment The preference fragment from where the preference should be displayed
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
   * @param context The application context
   * @param prefFragment The preference fragment from where the preference should be displayed
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
   * @param prefKey The preference to display
   * @param prefFragment The preference fragment from where the preference should be displayed
   */
  internal fun displayPreference(
    prefKey: String,
    prefFragment: PreferenceFragmentCompat,
  ) {
    val preference = prefFragment.findPreference<Preference>(prefKey)
    preference?.isVisible = true
  }

  /**
   * Hide an unwanted UI setting
   *
   * @param prefKey The preference to remove
   * @param prefFragment The preference fragment from where the preference should be removed
   */
  internal fun hidePreference(
    prefKey: String,
    prefFragment: PreferenceFragmentCompat,
  ) {
    val preference = prefFragment.findPreference<Preference>(prefKey)
    preference?.isVisible = false
  }
}
