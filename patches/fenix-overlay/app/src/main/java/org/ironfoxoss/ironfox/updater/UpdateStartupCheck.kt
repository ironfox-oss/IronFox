/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package org.ironfoxoss.ironfox.updater

import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.withStarted
import java.lang.ref.WeakReference
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch
import mozilla.components.support.base.log.logger.Logger

/** Runs the automatic update check once per process, when the first screen appears. */
object UpdateStartupCheck {
    private val logger = Logger("UpdateStartupCheck")
    private val started = AtomicBoolean(false)
    private var observedActivity: WeakReference<FragmentActivity>? = null

    /**
     * Shows install failures for [activity] and, once per process, cleans up after the previous run and,
     * if due, checks for an update and offers it.
     */
    fun run(activity: FragmentActivity) {
        val controller = UpdateController.from(activity)
        observeInstallFailures(activity, controller)
        if (!started.compareAndSet(false, true)) return
        activity.lifecycleScope.launch {
            runCatching { controller.cleanUpAfterStartup() }
            val offer = checkQuietly(controller) ?: return@launch
            activity.lifecycle.withStarted { UpdateUi(activity, controller).showUpdateDialog(offer) }
        }
    }

    private fun observeInstallFailures(activity: FragmentActivity, controller: UpdateController) {
        if (observedActivity?.get() === activity) return
        observedActivity = WeakReference(activity)
        UpdateUi(activity, controller).observeInstallFailures(activity)
    }

    private suspend fun checkQuietly(controller: UpdateController): UpdateOffer? =
        try {
            (controller.check(manual = false) as? CheckResult.Available)?.offer
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            logger.warn("Automatic update check failed", e)
            null
        }
}
