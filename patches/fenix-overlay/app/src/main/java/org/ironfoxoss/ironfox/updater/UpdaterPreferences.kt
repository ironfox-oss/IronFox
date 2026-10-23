package org.ironfoxoss.ironfox.updater

import android.text.format.DateUtils
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.lifecycleScope
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.SeekBarPreference
import androidx.preference.SwitchPreference
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch
import mozilla.components.ui.widgets.withCenterAlignedButtons
import org.ironfoxoss.core.IFConstants
import org.mozilla.fenix.R
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.settings.requirePreference

/**
 * Binds the "Updates" preferences of the IronFox settings screen to the updater.
 *
 * @param fragment The settings fragment that hosts the preferences.
 */
class UpdaterPreferences(private val fragment: PreferenceFragmentCompat) {
  private val controller = UpdateController.from(fragment.requireContext())
  private val ui = UpdateUi(fragment.requireActivity(), controller)
  private var transientStatus: String? = null

  /** Attaches the listeners and shows the current state; safe to call on every resume. */
  fun bind() {
    val settings = controller.settings
    fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_enabled)
      .setOnPreferenceChangeListener { _, value ->
        settings.updaterEnabled = value as Boolean
        true
      }
    fragment.requirePreference<SeekBarPreference>(R.string.pref_key_updater_interval_hours)
      .setOnPreferenceChangeListener { preference, value ->
        val hours = (value as Int).coerceIn(UpdateInterval.MIN_HOURS, UpdateInterval.MAX_HOURS)
        settings.updaterIntervalHours = hours
        (preference as SeekBarPreference).value = hours
        false
      }
    fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_auto_download)
      .setOnPreferenceChangeListener { _, value ->
        val enabling = value as Boolean
        if (enabling) confirmAutoDownload() else settings.updaterAutoDownload = false
        !enabling
      }
    fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_direct_downloads)
      .setOnPreferenceChangeListener { _, value ->
        settings.updaterDirectDownloads = value as Boolean
        refresh()
        true
      }
    fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_allow_insecure_http)
      .setOnPreferenceChangeListener { _, value ->
        settings.updaterAllowInsecureHttp = value as Boolean
        true
      }
    fragment.requirePreference<Preference>(R.string.pref_key_updater_status).setOnPreferenceClickListener {
      controller.availableOffer?.let(ui::showUpdateDialog)
      true
    }
    fragment.requirePreference<Preference>(R.string.pref_key_updater_check_now).setOnPreferenceClickListener {
      checkNow()
      true
    }
    refresh()
  }

  private fun refresh() {
    val settings = controller.settings
    val store = controller.rememberedStore
    val browserSettings = fragment.requireContext().components.settings
    val httpsOnlyInAllTabs = browserSettings.shouldUseHttpsOnly && browserSettings.shouldUseHttpsOnlyInAllTabs
    val showSecretDebugMenuThisSession = browserSettings.showSecretDebugMenuThisSession
    fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_enabled).isChecked =
      settings.updaterEnabled
    fragment.requirePreference<SeekBarPreference>(R.string.pref_key_updater_interval_hours).value =
      settings.updaterIntervalHours.coerceIn(UpdateInterval.MIN_HOURS, UpdateInterval.MAX_HOURS)
    fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_direct_downloads).apply {
      isVisible = store != null
      isChecked = settings.updaterDirectDownloads
      if (store != null) summary = this@UpdaterPreferences.fragment.getString(R.string.updater_direct_downloads_summary, store.displayName)
    }
    fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_auto_download).apply {
      val downloadsDirectly = controller.activeStore == null
      isEnabled = downloadsDirectly
      isChecked = settings.updaterAutoDownload && downloadsDirectly
      summary = this@UpdaterPreferences.fragment.getString(
        if (downloadsDirectly) R.string.updater_auto_download_summary else R.string.updater_auto_download_needs_direct_summary,
      )
    }
    fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_allow_insecure_http).apply {
      isVisible = IFConstants.IRONFOX_NIGHTLY && showSecretDebugMenuThisSession
      isEnabled = !httpsOnlyInAllTabs
      isChecked = settings.updaterAllowInsecureHttp && !httpsOnlyInAllTabs
      summary = this@UpdaterPreferences.fragment.getString(
        if (httpsOnlyInAllTabs) R.string.updater_insecure_http_blocked_summary else R.string.updater_insecure_http_summary,
      )
    }
    fragment.requirePreference<Preference>(R.string.pref_key_updater_source).summary =
      controller.activeStore?.displayName ?: fragment.getString(R.string.updater_source_direct)
    fragment.requirePreference<Preference>(R.string.pref_key_updater_status).summary = statusText()
  }

  private fun confirmAutoDownload() {
    AlertDialog.Builder(fragment.requireContext())
      .setTitle(R.string.updater_auto_download_confirm_title)
      .setMessage(R.string.updater_auto_download_confirm_message)
      .setPositiveButton(R.string.updater_auto_download_confirm_enable) { _, _ ->
        controller.settings.updaterAutoDownload = true
        refresh()
      }
      .setNegativeButton(android.R.string.cancel, null)
      .create()
      .withCenterAlignedButtons()
      .show()
  }

  private fun statusText(): String {
    transientStatus?.let { return it }
    controller.availableOffer?.let { return fragment.getString(R.string.updater_status_available, it.version) }
    val lastCheck = controller.settings.updaterLastCheckMillis
    if (lastCheck == 0L) return fragment.getString(R.string.updater_status_never)
    val ago = DateUtils.getRelativeTimeSpanString(lastCheck, System.currentTimeMillis(), DateUtils.MINUTE_IN_MILLIS)
    return fragment.getString(R.string.updater_status_last_checked, ago)
  }

  private suspend fun downloadAheadWithStatus(offer: UpdateOffer) {
    if (!controller.autoDownloadActive) return
    transientStatus = fragment.getString(R.string.updater_status_downloading)
    refresh()
    controller.downloadAhead(offer)
  }

  private fun checkNow() {
    fragment.viewLifecycleOwner.lifecycleScope.launch {
      transientStatus = fragment.getString(R.string.updater_status_checking)
      refresh()
      transientStatus = try {
        (controller.check(manual = true) as? CheckResult.Available)?.let { result ->
          downloadAheadWithStatus(result.offer)
          ui.showUpdateDialog(result.offer)
        }
        null
      } catch (e: CancellationException) {
        throw e
      } catch (e: Exception) {
        fragment.getString(R.string.updater_status_error, e.message ?: e.javaClass.simpleName)
      }
      refresh()
    }
  }
}
