/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

class GrowthDataWorker(
    context: Context,
    workerParameters: WorkerParameters,
) : Worker(context, workerParameters) {
    override fun doWork(): Result = Result.success()

    companion object {
        private const val DAY_MILLIS: Long = 0
        private const val FULL_WEEK_MILLIS: Long = 0

        fun sendActivatedSignalIfNeeded(context: Context) {}

        private fun Long.isAfterFirstWeekFromInstall(context: Context): Boolean = false

        private fun getInstalledTime(context: Context): Long = 0
    }
}
