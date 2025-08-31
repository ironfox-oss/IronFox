/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.perf

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.annotation.VisibleForTesting
import androidx.annotation.VisibleForTesting.Companion.PRIVATE
import org.mozilla.fenix.R

object ApplicationExitInfoMetrics {
    private const val KILOBYTES_TO_MEGABYTES_CONVERSION = 1024.0

    @VisibleForTesting(otherwise = PRIVATE)
    internal const val PREFERENCE_NAME = "app_exit_info"

    fun recordProcessExits(context: Context) {}

    @RequiresApi(Build.VERSION_CODES.R)
    private fun getHistoricalProcessExits(context: Context): List<ApplicationExitInfo> {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val applicationExitInfoList =
            activityManager.getHistoricalProcessExitReasons(null, 0, 0)
        applicationExitInfoList.retainAll {
            shouldRetainApplicationExitInfo(it)
        }
        return applicationExitInfoList
    }

    private fun record(
        context: Context,
        lastTimeHandled: Long,
        historicalExitReasons: List<ApplicationExitInfo>,
    ) {}

    private fun shouldRecordProcessExit(
        lastTimeHandled: Long,
        mostRecentProcessExitTimestamp: Long,
    ): Boolean = false

    private fun shouldRetainApplicationExitInfo(
        appExitInfo: ApplicationExitInfo?,
    ): Boolean = false

    private fun getLastTimeHandled(context: Context): Long = 0

    private fun updateLastTimeHandled(
        context: Context,
        mostRecentProcessExitTimestamp: Long,
    ) {}

    private fun String.toProcessType(): String = ""

    private fun Long.toValueInMB(): Int {
        return 0
    }

    private fun Int.toProcessExitReason(): String? = null

    private fun Int.toProcessImportance(): String? = null

    private fun Long.toSimpleDateFormat(): String = ""

    private fun preferences(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFERENCE_NAME, Context.MODE_PRIVATE)
}
