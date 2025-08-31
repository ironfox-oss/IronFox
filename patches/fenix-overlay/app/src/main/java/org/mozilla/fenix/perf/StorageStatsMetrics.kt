/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.perf

import android.content.Context
import androidx.annotation.VisibleForTesting
import androidx.annotation.VisibleForTesting.Companion.PRIVATE
import androidx.annotation.WorkerThread

object StorageStatsMetrics {
    fun report(context: Context) {}

    @VisibleForTesting(otherwise = PRIVATE)
    @WorkerThread
    fun reportSync(context: Context) {}
}
