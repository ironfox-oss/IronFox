/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package org.ironfoxoss.ironfox.updater

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.launch
import mozilla.components.ui.widgets.withCenterAlignedButtons
import org.mozilla.fenix.BrowserDirection
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.HomeActivity
import org.mozilla.fenix.R

/**
 * The dialogs and flow that take an [UpdateOffer] from "available" to "install requested".
 *
 * @param activity The activity that hosts the dialogs.
 * @param controller Does the actual checking, downloading and installing.
 */
class UpdateUi(
    private val activity: FragmentActivity,
    private val controller: UpdateController,
) {
    private val notifier = UpdateNotifier(activity)

    /**
     * Asks the user whether to install [offer]; does nothing if a dialog is already up or an update is running.
     *
     * Update (or Install, once the APK is already downloaded) installs the APK, unless IronFox came from a known
     * store and the user did not choose direct downloads: then the button opens that store. Later remembers the
     * version so it is not offered again; Release notes opens them in a new IronFox tab.
     */
    fun showUpdateDialog(offer: UpdateOffer) = showDialog(offer) {}

    /** Like [showUpdateDialog], but only a button closes it, so an automatic check cannot be dismissed by accident. */
    fun showForegroundUpdateDialog(offer: UpdateOffer) = showDialog(offer) { setCancelable(false) }

    private fun showDialog(offer: UpdateOffer, configure: AlertDialog.Builder.() -> Unit) {
        if (controller.isUpdating || !dialogShowing.compareAndSet(false, true)) return
        val store = controller.activeStore
        val builder = AlertDialog.Builder(activity)
            .setTitle(R.string.updater_dialog_title)
            .setNegativeButton(R.string.updater_dialog_later) { _, _ ->
                controller.settings.updaterDismissedVersion = offer.version
            }
            .setNeutralButton(R.string.updater_dialog_release_notes) { _, _ -> openReleaseNotes(offer) }
            .setOnDismissListener { dialogShowing.set(false) }
        if (store == null) {
            val downloaded = controller.isDownloaded(offer)
            builder.setMessage(
                activity.getString(
                    if (downloaded) R.string.updater_dialog_ready_message else R.string.updater_dialog_message,
                    offer.version,
                ),
            ).setPositiveButton(if (downloaded) R.string.updater_dialog_install else R.string.updater_dialog_update) { _, _ ->
                startUpdate(offer)
            }
        } else {
            builder.setMessage(activity.getString(R.string.updater_dialog_store_message, offer.version, store.displayName))
                .setPositiveButton(activity.getString(R.string.updater_dialog_open_store, store.displayName)) { _, _ ->
                    openStore(offer, store)
                }
        }
        builder.apply(configure).create().withCenterAlignedButtons().show()
    }

    private fun openStore(offer: UpdateOffer, store: KnownStore) {
        val intent = controller.launchIntentFor(store)
        val opened = intent != null && runCatching { activity.startActivity(intent) }.isSuccess
        if (!opened) showStoreGone(offer, store)
    }

    private fun showStoreGone(offer: UpdateOffer, store: KnownStore) {
        AlertDialog.Builder(activity)
            .setTitle(activity.getString(R.string.updater_store_gone_title, store.displayName))
            .setMessage(activity.getString(R.string.updater_store_gone_message, store.displayName))
            .setPositiveButton(R.string.updater_store_gone_download) { _, _ -> startUpdate(offer) }
            .setNegativeButton(android.R.string.cancel, null)
            .create()
            .withCenterAlignedButtons()
            .show()
    }

    private fun openReleaseNotes(offer: UpdateOffer) {
        if (!offer.releaseNotesUrl.startsWith("https://")) return
        (activity as? HomeActivity)?.apply {
          openToBrowser(from = BrowserDirection.FromGlobal)
          components.useCases.fenixBrowserUseCases.loadUrlOrSearch(
            searchTermOrURL = offer.releaseNotesUrl,
            newTab = true,
          )
        }
    }

    /** Downloads, verifies and installs [offer], first asking for the install permission if needed. */
    fun startUpdate(offer: UpdateOffer) {
        controller.lastRequestedOffer = offer
        if (!controller.installer.canRequestInstalls()) {
            askForInstallPermission(offer)
            return
        }
        if (!controller.beginUpdate()) return
        InstallEvents.consume()
        activity.lifecycleScope.launch {
            notifier.showProgress(null)
            try {
                val apk = controller.download(offer) { notifier.showProgress(it) }
                controller.install(apk)
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                showFailure(failureFor(e))
            } finally {
                notifier.cancel()
                controller.endUpdate()
            }
        }
    }

    /** Shows install failures reported by the system while [owner] is started. */
    fun observeInstallFailures(owner: LifecycleOwner) {
        owner.lifecycleScope.launch {
            owner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                InstallEvents.failures.filterNotNull().collect {
                    InstallEvents.consume()
                    showFailure(it)
                }
            }
        }
    }

    private fun failureFor(error: Exception): InstallFailure = when (error) {
        is ApkVerificationException -> InstallFailure.INVALID
        is IllegalStateException -> InstallFailure.BLOCKED
        else -> InstallFailure.ABORTED
    }

    private fun showFailure(failure: InstallFailure) {
        if (activity.isFinishing) return
        AlertDialog.Builder(activity)
            .setTitle(R.string.updater_failure_title)
            .setMessage(failureMessage(failure))
            .setPositiveButton(R.string.updater_try_again) { _, _ ->
                controller.lastRequestedOffer?.let(::startUpdate)
            }
            .setNegativeButton(R.string.updater_close, null)
            .create()
            .withCenterAlignedButtons()
            .show()
    }

    private fun failureMessage(failure: InstallFailure): String {
        val message = activity.getString(
            when (failure) {
                InstallFailure.BLOCKED -> R.string.updater_failure_blocked
                InstallFailure.INCOMPATIBLE -> R.string.updater_failure_incompatible
                InstallFailure.CONFLICT -> R.string.updater_failure_conflict
                InstallFailure.INVALID -> R.string.updater_failure_invalid
                InstallFailure.STORAGE -> R.string.updater_failure_storage
                InstallFailure.ABORTED -> R.string.updater_failure_aborted
            },
        )
        val needsHint = failure == InstallFailure.BLOCKED || failure == InstallFailure.INVALID
        return if (needsHint) "$message\n\n${activity.getString(R.string.updater_failure_verification_hint)}" else message
    }

    private fun askForInstallPermission(offer: UpdateOffer) {
        AlertDialog.Builder(activity)
            .setTitle(R.string.updater_unknown_sources_title)
            .setMessage(R.string.updater_unknown_sources_message)
            .setPositiveButton(R.string.updater_unknown_sources_continue) { _, _ ->
                resumeWhenBackInForeground(offer)
                activity.startActivity(
                    Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.fromParts("package", activity.packageName, null),
                    ),
                )
            }
            .setNegativeButton(android.R.string.cancel, null)
            .create()
            .withCenterAlignedButtons()
            .show()
    }

    private fun resumeWhenBackInForeground(offer: UpdateOffer) {
        activity.lifecycle.addObserver(object : DefaultLifecycleObserver {
            private var leftApp = false

            override fun onPause(owner: LifecycleOwner) {
                leftApp = true
            }

            override fun onResume(owner: LifecycleOwner) {
                if (!leftApp) return
                owner.lifecycle.removeObserver(this)
                if (controller.installer.canRequestInstalls()) startUpdate(offer)
            }
        })
    }

    private companion object {
        val dialogShowing = AtomicBoolean(false)
    }
}
