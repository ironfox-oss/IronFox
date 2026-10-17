/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package org.ironfoxoss.ironfox.updater

import android.text.format.DateUtils
import androidx.lifecycle.lifecycleScope
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.SwitchPreference
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch
import org.mozilla.fenix.R
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
        fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_enabled)
            .setOnPreferenceChangeListener { _, value ->
                controller.settings.enabled = value as Boolean
                true
            }
        fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_allow_other_sources)
            .setOnPreferenceChangeListener { _, value ->
                controller.settings.allowOtherSources = value as Boolean
                refresh()
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
        val allowed = controller.isUpdaterAllowed()
        fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_enabled).apply {
            isEnabled = allowed
            isChecked = settings.enabled && allowed
            summary = if (allowed) {
                this@UpdaterPreferences.fragment.getString(R.string.updater_enabled_summary)
            } else {
                this@UpdaterPreferences.fragment.getString(R.string.updater_enabled_summary_gated, controller.gate.installerDisplayName)
            }
        }
        fragment.requirePreference<SwitchPreference>(R.string.pref_key_updater_allow_other_sources).isChecked =
            settings.allowOtherSources
        fragment.requirePreference<Preference>(R.string.pref_key_updater_installed_via).summary =
            controller.gate.installerDisplayName
        fragment.requirePreference<Preference>(R.string.pref_key_updater_check_now).isEnabled = allowed
        fragment.requirePreference<Preference>(R.string.pref_key_updater_status).summary = statusText()
    }

    private fun statusText(): String {
        transientStatus?.let { return it }
        controller.availableOffer?.let { return fragment.getString(R.string.updater_status_available, it.version) }
        val lastCheck = controller.settings.lastCheckMillis
        if (lastCheck == 0L) return fragment.getString(R.string.updater_status_never)
        val ago = DateUtils.getRelativeTimeSpanString(lastCheck, System.currentTimeMillis(), DateUtils.MINUTE_IN_MILLIS)
        return fragment.getString(R.string.updater_status_last_checked, ago)
    }

    private fun checkNow() {
        fragment.viewLifecycleOwner.lifecycleScope.launch {
            transientStatus = fragment.getString(R.string.updater_status_checking)
            refresh()
            transientStatus = try {
                (controller.check(manual = true) as? CheckResult.Available)?.let { ui.showUpdateDialog(it.offer) }
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
