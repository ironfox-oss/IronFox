package org.ironfoxoss.ironfox.utils

import android.content.Context
import mozilla.components.lib.crash.store.CrashReportOption
import org.ironfoxoss.ironfox.utils.IFPrefUtils
import org.mozilla.fenix.R
import org.mozilla.fenix.settings.sitepermissions.AUTOPLAY_BLOCK_ALL
import org.mozilla.fenix.termsofuse.TOU_TIME_IN_MILLIS

/**
 * IronFox Fenix Preferences
 *
 */
object IFPrefs {
  /**
   * Set our Fenix preferences
   *
   * @param context Application context
   */
  fun setPrefs(
    context: Context
  ) {
    val prefs = IFPrefUtils(context)

    // Allow zoom on all websites, even if the website tries to block it
    prefs.setDefaultBoolPref(R.string.pref_key_accessibility_force_enable_zoom, true)

    // Block media autoplay by default
    prefs.setStrDefaultIntPref("AUTOPLAY_USER_SETTING", AUTOPLAY_BLOCK_ALL)
    prefs.setDefaultIntPref(R.string.pref_key_browser_feature_autoplay_audible_v2, 0) // 0: Block, 1: Ask to Allow, 2: Allow
    prefs.setDefaultIntPref(R.string.pref_key_browser_feature_autoplay_inaudible_v2, 0) // 0: Block, 1: Ask to Allow, 2: Allow

    // Block websites from prompting to access geolocation by default
    prefs.setDefaultIntPref(R.string.pref_key_phone_feature_location, 0) // 0: Block, 1: Ask to Allow, 2: Allow

    // Block websites from prompting to display notifications by default
    prefs.setDefaultIntPref(R.string.pref_key_phone_feature_notification, 0) // 0: Block, 1: Ask to Allow, 2: Allow

    // Check the boxes for manually clearing browsing data by default
    prefs.setDefaultBoolPref(R.string.pref_key_delete_browsing_history_now, true) // [DEFAULT] Browsing history
    prefs.setDefaultBoolPref(R.string.pref_key_delete_cookies_now, true) // [DEFAULT] Cookies
    prefs.setDefaultBoolPref(R.string.pref_key_delete_caches_now, true) // [DEFAULT] Cache
    prefs.setDefaultBoolPref(R.string.pref_key_delete_downloads_now, true) // [DEFAULT] Download history
    prefs.setDefaultBoolPref(R.string.pref_key_delete_open_tabs_now, true) // [DEFAULT] Open tabs
    prefs.setDefaultBoolPref(R.string.pref_key_delete_permissions_now, true) // [DEFAULT] Permissions

    // Clear browsing history, cache, download history, and open tabs on exit by default
    prefs.setDefaultBoolPref(R.string.pref_key_delete_browsing_data_on_quit, true)
    prefs.setDefaultBoolPref(R.string.pref_key_delete_browsing_history_on_quit, true) // Browsing history
    prefs.setDefaultBoolPref(R.string.pref_key_delete_caches_on_quit, true) // Cache
    prefs.setDefaultBoolPref(R.string.pref_key_delete_downloads_on_quit, true) // Download history
    prefs.setDefaultBoolPref(R.string.pref_key_delete_open_tabs_on_quit, true) // Open tabs

    /// Ensure we don't clear cookies and permissions by default
    prefs.setDefaultBoolPref(R.string.pref_key_delete_cookies_and_site_data_on_quit, false)
    prefs.setDefaultBoolPref(R.string.pref_key_delete_permissions_on_quit, false)

    // Configure the default homepage
    prefs.setDefaultBoolPref(R.string.pref_key_customization_bookmarks, false) // Recently Saved Bookmarks
    prefs.setDefaultBoolPref(R.string.pref_key_recent_tabs, false) // Recently Tabs
    prefs.setDefaultBoolPref(R.string.pref_key_history_metadata_feature, false) // Recently Visited
    prefs.setDefaultBoolPref(R.string.pref_key_privacy_report, false) // Privacy Report
    prefs.setDefaultBoolPref(R.string.pref_key_show_top_sites, true) // [DEFAULT] Shortcuts

    // Disable AI Controls
    prefs.setBoolPref(R.string.pref_key_enable_ai_controls, false)

    // Disable AI Shake to Summarize
    prefs.setBoolPref(R.string.pref_key_enable_shake_to_summarize, false)

    // Disable autofill by default
    prefs.setDefaultBoolPref(R.string.pref_key_autofill_logins, false)

    // Disable Contile
    prefs.setBoolPref(R.string.pref_key_enable_contile, false)
    prefs.setBoolPref(R.string.pref_key_suppress_sponsored_tiles, true)

    // Disable crash reporting
    prefs.setBoolPref(R.string.pref_key_crash_reporter, false)
    prefs.setStringPref(R.string.pref_key_crash_reporting_choice, CrashReportOption.Never.toString())
    prefs.setBoolPref(R.string.pref_key_crash_pull_never_show_again, true)

    // Disable exceptions required to avoid minor breakage by default
    prefs.setDefaultBoolPref(R.string.pref_key_tracking_protection_custom_allow_list_convenience, false) // [DEFAULT]
    prefs.setDefaultBoolPref(R.string.pref_key_tracking_protection_strict_allow_list_convenience, false) // [DEFAULT]

    // Disable Firefox Relay by default
    prefs.setDefaultBoolPref(R.string.pref_key_email_mask_suggestion, false)
    prefs.setDefaultBoolPref(R.string.pref_key_enable_email_masks, false)

    // Disable Firefox Suggest
    prefs.setDefaultBoolPref(R.string.pref_key_enable_fxsuggest, false)
    prefs.setDefaultBoolPref(R.string.pref_key_show_nonsponsored_suggestions, false)
    prefs.setBoolPref(R.string.pref_key_show_sponsored_suggestions, false)

    // Disable Firefox Sync by default
    prefs.setDefaultBoolPref(R.string.pref_key_addresses_sync_cards_across_devices, false)
    prefs.setDefaultBoolPref(R.string.pref_key_credit_cards_sync_cards_across_devices, false)
    prefs.setDefaultBoolPref(R.string.pref_key_enable_address_sync, false)

    // Disable Google Lens integration
    prefs.setBoolPref(R.string.pref_key_google_lens_integration, false)

    // Disable historical search suggestions by default
    prefs.setDefaultBoolPref(R.string.pref_key_search_browsing_history, false)

    // Disable import of Mozilla's default shortcuts
    prefs.setBoolPref(R.string.default_top_sites_added, true)

    // Disable MARS (Mozilla Ad Routing Service)
    prefs.setBoolPref(R.string.pref_key_enable_mozilla_ads_client, false)

    // Disable Mozilla feedback surveys
    prefs.setBoolPref(R.string.pref_key_microsurvey_feature_enabled, false)
    prefs.setBoolPref(R.string.pref_key_should_show_microsurvey_prompt, false)

    // Disable Mozilla in-app messages and pop-ups
    prefs.setBoolPref(R.string.pref_cfr_popups_enabled, false)
    prefs.setBoolPref(R.string.pref_in_app_messages_enabled, false)

    // Disable Mozilla nags, CFRs, and promotions
    prefs.setBoolPref(R.string.pref_key_first_time_engage_with_signup, false)
    prefs.setBoolPref(R.string.pref_key_has_inactive_tabs_auto_close_dialog_dismissed, true)
    prefs.setBoolPref(R.string.pref_key_menu_cfr, false)
    prefs.setBoolPref(R.string.pref_key_should_show_auto_close_tabs_banner, false)
    prefs.setBoolPref(R.string.pref_key_should_show_cookie_banners_action_popup, false)
    prefs.setBoolPref(R.string.pref_key_should_show_email_mask_cfr, false)
    prefs.setBoolPref(R.string.pref_key_should_show_inactive_tabs_popup, false)
    prefs.setBoolPref(R.string.pref_key_should_show_lock_pbm_banner, false)
    prefs.setBoolPref(R.string.pref_key_should_show_open_in_app_banner, false)
    prefs.setBoolPref(R.string.pref_key_show_first_time_translation, false)
    prefs.setBoolPref(R.string.pref_key_show_menu_banner, false)
    prefs.setBoolPref(R.string.pref_key_summarize_toolbar_cfr_shown, true)
    prefs.setBoolPref(R.string.pref_key_toolbar_has_shown_tab_swipe_cfr, true)
    prefs.setBoolPref(R.string.pref_key_user_knows_about_pwa, true)
    prefs.setBoolPref(R.string.pref_key_wallpapers_onboarding, false)

    // Disable Nimbus
    prefs.setBoolPref(R.string.pref_key_experimentation_v2, false)
    prefs.setBoolPref(R.string.pref_key_is_first_run, true) // [DEFAULT] Ensure Nimbus only applies experiments locally
    prefs.setBoolPref(R.string.pref_key_is_first_splash_screen_shown, true)
    prefs.setBoolPref(R.string.pref_key_nimbus_experiments_fetched, true)
    prefs.setBoolPref(R.string.pref_key_nimbus_use_preview, false)
    prefs.setBoolPref(R.string.pref_key_user_disabled_experimentation, true)

    // Disable Nimbus Rollouts
    prefs.setBoolPref(R.string.pref_key_rollouts, false)

    // Disable Password Manager by default
    prefs.setDefaultBoolPref(R.string.pref_key_addresses_save_and_autofill_addresses, false)
    prefs.setDefaultBoolPref(R.string.pref_key_credit_cards_save_and_autofill_cards, false)
    prefs.setDefaultBoolPref(R.string.pref_key_never_save_logins, true)
    prefs.setDefaultBoolPref(R.string.pref_key_save_logins, false)

    // Disable Pocket
    prefs.setBoolPref(R.string.pref_key_pocket_homescreen_recommendations, false)
    prefs.setBoolPref(R.string.pref_key_pocket_sponsored_stories, false)

    // Disable recent search suggestions by default
    prefs.setDefaultBoolPref(R.string.pref_key_show_recent_search_suggestions, false)

    // Disable remote debugging
    /// We effectively no-op this anyways (in favor of using the Gecko pref directly)
    prefs.setBoolPref(R.string.pref_key_remote_debugging, false) // [DEFAULT]

    // Disable remote search configuration
    prefs.setBoolPref(R.string.pref_key_use_remote_search_configuration, false)

    // Disable search suggestions by default
    prefs.setDefaultBoolPref(R.string.pref_key_show_search_suggestions, false)
    prefs.setBoolPref(R.string.pref_key_show_search_suggestions_in_private_onboarding, true)

    // Disable 'Search Optimization' cards
    prefs.setBoolPref(R.string.pref_key_search_optimization_cards, false)
    prefs.setBoolPref(R.string.pref_key_search_optimization_feature, false)
    prefs.setBoolPref(R.string.pref_key_search_optimization_flights, false)
    prefs.setBoolPref(R.string.pref_key_search_optimization_sports, false)
    prefs.setBoolPref(R.string.pref_key_search_optimization_stocks, false)

    // Disable the 'Sent from Firefox' footer/link sharing feature
    prefs.setBoolPref(R.string.pref_key_link_sharing, false)
    prefs.setBoolPref(R.string.pref_key_link_sharing_settings_snackbar, true)

    // Disable the set-up checklist
    prefs.setBoolPref(R.string.pref_key_setup_checklist_complete, false)
    prefs.setBoolPref(R.string.pref_key_setup_step_extensions, true)
    prefs.setBoolPref(R.string.pref_key_setup_step_install_search_widget, true)
    prefs.setBoolPref(R.string.pref_key_setup_step_theme, true)
    prefs.setBoolPref(R.string.pref_key_setup_step_toolbar, true)

    // Disable stories
    prefs.setBoolPref(R.string.pref_key_private_mode_and_stories_entry_point, false)

    // Disable telemetry
    prefs.setStringPref(R.string.pref_key_custom_glean_server_url, "data;")
    prefs.setBoolPref(R.string.pref_key_daily_usage_ping, false)
    prefs.setStringPref(R.string.pref_key_glean_usage_profile_id, "beefbeef-beef-beef-beef-beeefbeefbee")
    prefs.setBoolPref(R.string.pref_key_marketing_telemetry, false) // [DEFAULT]
    prefs.setBoolPref(R.string.pref_key_should_show_marketing_onboarding, false)
    prefs.setBoolPref(R.string.pref_key_telemetry, false)

    /// For redundancy/defense in depth, ensure we never try to submit various pings
    prefs.setBoolPref(R.string.pref_key_first_week_post_install_everyday_activity_and_set_to_default_sent, true)
    prefs.setBoolPref(R.string.pref_key_first_week_post_install_is_browser_set_to_default_during_first_four_days, true)
    prefs.setBoolPref(R.string.pref_key_first_week_post_install_last_three_days_activity_sent, true)
    prefs.setBoolPref(R.string.pref_key_first_week_post_install_recurrent_activity_sent, true)
    prefs.setBoolPref(R.string.pref_key_growth_ad_click_sent, true)
    prefs.setBoolPref(R.string.pref_key_growth_first_week_series_sent, true)
    prefs.setBoolPref(R.string.pref_key_growth_set_as_default, true)
    prefs.setBoolPref(R.string.pref_key_growth_usage_time_sent, true)

    /// Ensure we don't enable third-party data sharing
    // We remove the Adjust Metrics Service entirely, so this is mainly for defense in depth/redundancy
    // https://searchfox.org/firefox-main/rev/d5171e9e/mobile/android/fenix/app/src/main/java/org/mozilla/fenix/components/metrics/AdjustMetricsService.kt#233
    prefs.setBoolPref(R.string.pref_key_is_user_meta_attributed, false)
    prefs.setBoolPref(R.string.pref_key_is_user_reddit_attributed, false)
    prefs.setBoolPref(R.string.pref_key_is_user_tiktok_attributed, false)
    prefs.setBoolPref(R.string.pref_key_is_user_x_twitter_attributed, false)

    // Disable third-party/OS-level root certificates by default
    prefs.setDefaultBoolPref(R.string.pref_key_allow_third_party_root_certs, false) // [DEFAULT]

    // Disable trending search suggestions by default
    prefs.setDefaultBoolPref(R.string.pref_key_show_trending_search_suggestions, false)

    // Disable the new 'Unified Trust Panel' by default
    // This prevents setting per-site exceptions for the built-in cookie banner blocker
    prefs.setDefaultBoolPref(R.string.pref_key_enable_unified_trust_panel, false)

    // Disable URL autocomplete by default
    prefs.setDefaultBoolPref(R.string.pref_key_enable_autocomplete_urls, false)

    // Disable the World Cup widget/promotion
    prefs.setBoolPref(R.string.pref_key_enable_homepage_sports_widget, false)
    prefs.setBoolPref(R.string.pref_key_show_homepage_sports_widget, false)

    // Disable Zygote preloading by default
    // https://grapheneos.org/usage#exec-spawning
    prefs.setDefaultBoolPref(R.string.pref_key_enable_app_zygote_process, false)

    // Display extensions in the custom tabs menu by default
    prefs.setDefaultBoolPref(R.string.pref_key_should_show_custom_tab_extensions, true)

    // Display the toolbar on the top by default
    prefs.setDefaultBoolPref(R.string.pref_key_toolbar_bottom, false)

    // Enable app icon selection
    prefs.setDefaultBoolPref(R.string.pref_key_app_icon_selection_enabled, true)

    // Enable Cookie Banner Reduction (in Private Browsing) by default
    prefs.setDefaultBoolPref(R.string.pref_key_cookie_banner_private_mode, true)

    // Enable DoH UI settings
    prefs.setDefaultBoolPref(R.string.pref_key_doh_settings_enabled, true)

    // Enable DoH without fallback by default
    prefs.setDefaultIntPref(R.string.pref_key_doh_settings_mode, 3)

    /// Set the default DoH provider to Mullvad (Base)
    prefs.setStringPref(R.string.pref_key_doh_default_provider_uri, "https://base.dns.mullvad.net/dns-query")

    // Enable exceptions required to avoid major breakage by default
    prefs.setDefaultBoolPref(R.string.pref_key_tracking_protection_custom_allow_list_baseline, true) // [DEFAULT]
    prefs.setDefaultBoolPref(R.string.pref_key_tracking_protection_strict_allow_list_baseline, true) // [DEFAULT]

    // Enable Firefox Labs
    prefs.setDefaultBoolPref(R.string.pref_key_enable_firefox_labs, true)

    // Enable Global Privacy Control by default
    /// We effectively no-op this anyways (in favor of using the Gecko pref directly)
    prefs.setDefaultBoolPref(R.string.pref_key_privacy_enable_global_privacy_control, true)

    // Enable ETP Strict
    prefs.setBoolPref(R.string.pref_key_tracking_protection, true) // [DEFAULT]
    prefs.setBoolPref(R.string.pref_key_tracking_protection_custom_option, false)
    prefs.setBoolPref(R.string.pref_key_tracking_protection_standard_option, false)
    prefs.setBoolPref(R.string.pref_key_tracking_protection_strict_default, true)

    // Enable HTTPS-Only Mode by default
    prefs.setDefaultBoolPref(R.string.pref_key_https_only, true)
    prefs.setDefaultBoolPref(R.string.pref_key_https_only_in_all_tabs, true) // [DEFAULT]
    prefs.setDefaultBoolPref(R.string.pref_key_https_only_in_private_tabs, false) // [DEFAULT]

    // Enable Local Network Access Restrictions
    prefs.setDefaultIntPref(R.string.pref_key_browser_feature_local_device_access, 0) // 0: Block, 1: Ask to Allow, 2: Allow
    prefs.setDefaultIntPref(R.string.pref_key_browser_feature_local_network_access, 0) // 0: Block, 1: Ask to Allow, 2: Allow
    prefs.setDefaultBoolPref(R.string.pref_key_enable_lna_blocking_enabled, true)
    prefs.setDefaultBoolPref(R.string.pref_key_enable_lna_feature_enabled, true)
    prefs.setDefaultBoolPref(R.string.pref_key_enable_lna_tracker_blocking_enabled, true)

    // Enable Private Browsing Lock
    // Allows users to require authentication to access tabs in Private Browsing
    prefs.setDefaultBoolPref(R.string.pref_key_private_browsing_locked_enabled, true)

    // Enable Pull-to-refresh by default
    prefs.setDefaultBoolPref(R.string.pref_key_website_pull_to_refresh, true) // [DEFAULT]

    // Enable Settings Search by default
    prefs.setDefaultBoolPref(R.string.pref_key_allow_settings_search, true)

    // Skip Mozilla's Privacy Notice and Terms of Use
    val tosTime = TOU_TIME_IN_MILLIS + 1_000
    prefs.setLongPref(R.string.pref_key_privacy_notice_banner_last_displayed_time, tosTime)
    prefs.setBoolPref(R.string.pref_key_terms_accepted, true)
    prefs.setLongPref(R.string.pref_key_terms_accepted_date, tosTime)
    prefs.setBoolPref(R.string.pref_key_terms_prompt_drag_handle_enabled, true)
    prefs.setBoolPref(R.string.pref_key_terms_prompt_enabled, false)
  }
}
