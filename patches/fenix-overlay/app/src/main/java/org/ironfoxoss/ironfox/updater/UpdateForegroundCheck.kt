package org.ironfoxoss.ironfox.updater

import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.withStarted
import java.lang.ref.WeakReference
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch
import mozilla.components.support.base.log.logger.Logger

/** Runs the automatic update check whenever IronFox comes to the foreground; the interval decides if it is due. */
object UpdateForegroundCheck {
  private val logger = Logger("UpdateForegroundCheck")
  private val cleanedUp = AtomicBoolean(false)
  private var observedActivity: WeakReference<FragmentActivity>? = null

  /**
   * Shows install failures for [activity] and, if a check is due, checks for an update and offers it.
   * The first call in a process also cleans up after the previous run.
   */
  fun run(activity: FragmentActivity) {
    val controller = UpdateController.from(activity)
    observeInstallFailures(activity, controller)
    activity.lifecycleScope.launch {
      controller.rememberInstaller()
      if (cleanedUp.compareAndSet(false, true)) runCatching { controller.cleanUpAfterStartup() }
      if (!controller.beginCheck()) return@launch
      try {
        val offer = checkQuietly(controller) ?: return@launch
        controller.downloadAhead(offer)
        activity.lifecycle.withStarted { UpdateUi(activity, controller).showForegroundUpdateDialog(offer) }
      } finally {
        controller.endCheck()
      }
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
