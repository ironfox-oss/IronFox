/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics.fonts

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

class FontEnumerationWorker(
    context: Context,
    workerParameters: WorkerParameters,
) : CoroutineWorker(context, workerParameters) {
    override suspend fun doWork(): Result = Result.success()

    private val brokenFonts: ArrayList<Pair<String, String>> = ArrayList()
    private val fonts: MutableSet<FontMetric> = HashSet()

    private fun readAllFonts() {}

    companion object {
        private val HOUR_MILLIS: Long = 0
        private const val SIX: Long = 0

        fun sendActivatedSignalIfNeeded(context: Context) {}

        private fun getSystemFonts(): ArrayList<String> {
            return ArrayList()
        }

        private fun getAPIFonts(): List<String> {
            return emptyList()
        }
    }
}
