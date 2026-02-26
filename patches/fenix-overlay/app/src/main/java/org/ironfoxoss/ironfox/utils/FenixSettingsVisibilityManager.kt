package org.ironfoxoss.ironfox.utils

import android.content.Context
import android.os.Build
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import org.ironfoxoss.ironfox.utils.FenixSettingsDictionary
import org.ironfoxoss.ironfox.utils.IronFoxPreferences
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
        hideDataChoices(context, prefFragment)
        hideLinkSharing(context, prefFragment)
        hideLocalAddonInstall(context, prefFragment)
        hideNimbusExperiments(context, prefFragment)
        hideRemoteImprovements(context, prefFragment)
        hideProfiler(context, prefFragment)
        hideRate(context, prefFragment)
        hideRemoteDebugging(context, prefFragment)
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
        displayAddressSync(context, prefFragment)
        displayAppZygote(context, prefFragment)
        displayCustomTabExtensions(context, prefFragment)
        displayEnableHomepageAsNewTab(context, prefFragment)
        displayEnableMenuRedesign(context, prefFragment)
        displayIsolatedProcess(context, prefFragment)
        displayLnaBlocking(context, prefFragment)
        displayLnaFeature(context, prefFragment)
        displayLnaTrackerBlocking(context, prefFragment)
        displayMinimalBottomToolbarWhenEnteringText(context, prefFragment)
        displayNewDynamicToolbarBehaviour(context, prefFragment)
        displayRelayFeature(context, prefFragment)
        displaySettingsSearch(context, prefFragment)
        displayToolbarCustomization(context, prefFragment)
        hideCrashPullNeverShow(context, prefFragment)
        hideDiscoverMoreStories(context, prefFragment)
        hideMicrosurveyFeature(context, prefFragment)
        hideMozillaAdsClient(context, prefFragment)
        hideNewCrashReporterDialog(context, prefFragment)
        hideNimbusPreview(context, prefFragment)
        hideRemoteSearchConfiguration(context, prefFragment)
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
        hideEtpCustom(context, prefFragment)
        hideEtpStandard(context, prefFragment)
        hideEtpStrict(context, prefFragment)
        hideGpc(context, prefFragment)
        hideUseTrackingProtection(context, prefFragment)
    }

    /**
     * Hide the "data choices" option
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideDataChoices(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val dataChoicesKey = context.getPreferenceKey(FenixSettingsDictionary.dataChoices)
        hidePreference(dataChoicesKey, prefFragment)
    }

    /**
     * Hide the link sharing setting
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideLinkSharing(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val whatsappLinkSharingKey = context.getPreferenceKey(FenixSettingsDictionary.whatsappLinkSharingEnabled)
        hidePreference(whatsappLinkSharingKey, prefFragment)
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
        val localAddonInstallKey = context.getPreferenceKey(FenixSettingsDictionary.localAddonInstall)
        val localAddonInstallPreference = prefFragment.findPreference<Preference>(localAddonInstallKey)
        localAddonInstallPreference?.isVisible = IronFoxPreferences.isXPInstallEnabled(context) && IronFoxPreferences.shouldShowSecretDebugMenuThisSession(context)
    }

    /**
     * Hide the Nimbus Experiments option
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideNimbusExperiments(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val nimbusExperimentsKey = context.getPreferenceKey(FenixSettingsDictionary.nimbusExperiments)
        hidePreference(nimbusExperimentsKey, prefFragment)
    }

    /**
     * Hide the Remote Improvements (Nimbus Rollouts) option
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideRemoteImprovements(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val remoteImprovementsKey = context.getPreferenceKey(FenixSettingsDictionary.remoteImprovements)
        hidePreference(remoteImprovementsKey, prefFragment)
    }

    /**
     * Hide the option to start the Profiler
     * (This doesn't work and causes a crash when selected, due to us
     * disabling the Gecko Profiler at build-time)
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideProfiler(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val profilerKey = context.getPreferenceKey(FenixSettingsDictionary.profiler)
        hidePreference(profilerKey, prefFragment)
    }

    /**
     * Hide the app rating option
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideRate(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val rateKey = context.getPreferenceKey(FenixSettingsDictionary.rate)
        hidePreference(rateKey, prefFragment)
    }

    /**
     * Hide the remote debugging setting
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideRemoteDebugging(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val remoteDebuggingKey = context.getPreferenceKey(FenixSettingsDictionary.isRemoteDebuggingEnabled)
        hidePreference(remoteDebuggingKey, prefFragment)
    }

    /**
     * Display the setting to toggle support for syncing addresses via Firefox Sync
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayAddressSync(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val addressSyncKey = context.getPreferenceKey(FenixSettingsDictionary.isAddressSyncEnabled)
        displayPreference(addressSyncKey, prefFragment)
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
        val appZygoteKey = context.getPreferenceKey(FenixSettingsDictionary.isAppZygoteEnabled)
        val appZygotePreference = prefFragment.findPreference<Preference>(appZygoteKey)
        appZygotePreference?.isVisible = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    }

    /**
     * Display the setting to show the status of extensions in the menu for custom tabs
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayCustomTabExtensions(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val customTabExtensionsKey = context.getPreferenceKey(FenixSettingsDictionary.shouldShowCustomTabExtensions)
        displayPreference(customTabExtensionsKey, prefFragment)
    }

    /**
     * Display the setting to toggle the homepage as a new tab
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayEnableHomepageAsNewTab(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val homepageNewTabKey = context.getPreferenceKey(FenixSettingsDictionary.enableHomepageAsNewTab)
        displayPreference(homepageNewTabKey, prefFragment)
    }

    /**
     * Display the setting to toggle the menu redesign
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayEnableMenuRedesign(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val menuRedesignKey = context.getPreferenceKey(FenixSettingsDictionary.enableMenuRedesign)
        displayPreference(menuRedesignKey, prefFragment)
    }

    /**
     * Display the setting to enable isolated content processes
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayIsolatedProcess(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val isolatedProcessKey = context.getPreferenceKey(FenixSettingsDictionary.isIsolatedProcessEnabled)
        displayPreference(isolatedProcessKey, prefFragment)
    }

    /**
     * Display the setting to enforce local network access restrictions
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayLnaBlocking(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val lnaBlockingKey = context.getPreferenceKey(FenixSettingsDictionary.isLnaBlockingEnabled)
        displayPreference(lnaBlockingKey, prefFragment)
    }

    /**
     * Display the setting to enable local network access restrictions
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayLnaFeature(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val lnaFeatureKey = context.getPreferenceKey(FenixSettingsDictionary.isLnaFeatureEnabled)
        displayPreference(lnaFeatureKey, prefFragment)
    }

    /**
     * Display the setting to enforce local network access restrictions for known tracking resources
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayLnaTrackerBlocking(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val lnaTrackerBlockingKey = context.getPreferenceKey(FenixSettingsDictionary.isLnaTrackerBlockingEnabled)
        displayPreference(lnaTrackerBlockingKey, prefFragment)
    }

    /**
     * Display the setting to toggle the minimal bottom toolbar when entering text
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayMinimalBottomToolbarWhenEnteringText(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val minimalBottomToolbarWhenEnteringTextKey = context.getPreferenceKey(FenixSettingsDictionary.useMinimalBottomToolbarWhenEnteringText)
        displayPreference(minimalBottomToolbarWhenEnteringTextKey, prefFragment)
    }

     /**
     * Display the setting to toggle the new dynamic toolbar behaviour
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayNewDynamicToolbarBehaviour(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val newDynamicToolbarBehaviourKey = context.getPreferenceKey(FenixSettingsDictionary.useNewDynamicToolbarBehaviour)
        displayPreference(newDynamicToolbarBehaviourKey, prefFragment)
    }

    /**
     * Display the setting to toggle the Relay feature
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayRelayFeature(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val relayFeatureKey = context.getPreferenceKey(FenixSettingsDictionary.isRelayFeatureEnabled)
        displayPreference(relayFeatureKey, prefFragment)
    }

    /**
     * Display the setting to toggle settings search
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displaySettingsSearch(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val settingsSearchKey = context.getPreferenceKey(FenixSettingsDictionary.isSettingsSearchEnabled)
        displayPreference(settingsSearchKey, prefFragment)
    }

    /**
     * Display the setting to toggle toolbar customization
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun displayToolbarCustomization(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val toolbarCustomizationKey = context.getPreferenceKey(FenixSettingsDictionary.shouldShowToolbarCustomization)
        displayPreference(toolbarCustomizationKey, prefFragment)
    }

    /**
     * Hide the setting to toggle crash pull
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideCrashPullNeverShow(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val crashPullNeverShowKey = context.getPreferenceKey(FenixSettingsDictionary.crashPullNeverShowAgain)
        hidePreference(crashPullNeverShowKey, prefFragment)
    }

    /**
     * Hide the setting to toggle Pocket "Discover more stories"
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideDiscoverMoreStories(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val discoverMoreStoriesKey = context.getPreferenceKey(FenixSettingsDictionary.enableDiscoverMoreStories)
        hidePreference(discoverMoreStoriesKey, prefFragment)
    }

    /**
     * Hide the setting to toggle microsurveys
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideMicrosurveyFeature(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val microsurveyFeatureKey = context.getPreferenceKey(FenixSettingsDictionary.microsurveyFeatureEnabled)
        hidePreference(microsurveyFeatureKey, prefFragment)
    }

    /**
     * Hide the setting to enable the Mozilla Ads Client
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideMozillaAdsClient(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val mozillaAdsClientKey = context.getPreferenceKey(FenixSettingsDictionary.enableMozillaAdsClient)
        hidePreference(mozillaAdsClientKey, prefFragment)
    }

    /**
     * Hide the setting to toggle the new crash reporter dialog
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideNewCrashReporterDialog(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val newCrashReporterKey = context.getPreferenceKey(FenixSettingsDictionary.useNewCrashReporterDialog)
        hidePreference(newCrashReporterKey, prefFragment)
    }

    /**
     * Hide the setting to toggle Nimbus "Preview" experiments
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideNimbusPreview(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val nimbusPreviewKey = context.getPreferenceKey(FenixSettingsDictionary.nimbusUsePreview)
        hidePreference(nimbusPreviewKey, prefFragment)
    }

    /**
     * Hide the setting to toggle remote search configuration
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideRemoteSearchConfiguration(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val remoteSearchConfigurationKey = context.getPreferenceKey(FenixSettingsDictionary.useRemoteSearchConfiguration)
        hidePreference(remoteSearchConfigurationKey, prefFragment)
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
        val emeSiteSettingKey = context.getPreferenceKey(FenixSettingsDictionary.emeSiteSetting)
        val emeSiteSettingPreference = prefFragment.findPreference<Preference>(emeSiteSettingKey)
        emeSiteSettingPreference?.isVisible = IronFoxPreferences.isEMEEnabled(context)
    }

    /**
     * Hide the setting to toggle ETP Custom
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideEtpCustom(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val etpCustomKey = context.getPreferenceKey(FenixSettingsDictionary.useCustomTrackingProtection)
        hidePreference(etpCustomKey, prefFragment)
    }

    /**
     * Hide the setting to toggle ETP Standard
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideEtpStandard(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val etpStandardKey = context.getPreferenceKey(FenixSettingsDictionary.useStandardTrackingProtection)
        hidePreference(etpStandardKey, prefFragment)
    }

    /**
     * Hide the setting to toggle ETP Strict
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideEtpStrict(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val etpStrictKey = context.getPreferenceKey(FenixSettingsDictionary.useStrictTrackingProtection)
        hidePreference(etpStrictKey, prefFragment)
    }

    /**
     * Hide the setting to toggle GPC
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideGpc(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val gpcKey = context.getPreferenceKey(FenixSettingsDictionary.shouldEnableGlobalPrivacyControl)
        hidePreference(gpcKey, prefFragment)
    }

    /**
     * Hide the setting to toggle ETP
     *
     * @param context The application context
     * @param prefFragment The preference fragment from where the preference should be displayed
     */
    internal fun hideUseTrackingProtection(
        context: Context,
        prefFragment: PreferenceFragmentCompat
    ) {
        val etpKey = context.getPreferenceKey(FenixSettingsDictionary.shouldUseTrackingProtection)
        hidePreference(etpKey, prefFragment)
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
