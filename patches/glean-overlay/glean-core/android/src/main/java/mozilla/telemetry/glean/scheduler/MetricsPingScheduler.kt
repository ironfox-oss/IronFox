/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean.scheduler

import android.content.Context
import android.content.SharedPreferences
import java.util.Calendar
import java.util.Date
import java.util.Timer
import java.util.TimerTask

@Suppress("TooManyFunctions")
internal class MetricsPingScheduler(
    private val applicationContext: Context,
    private val buildInfo: Any?,
    migratedLastSentDate: String? = null,
) {
    internal val sharedPreferences: SharedPreferences by lazy {
        applicationContext.getSharedPreferences(this.javaClass.canonicalName, Context.MODE_PRIVATE)
    }

    internal var timer: Timer? = null

    companion object {
        const val LAST_METRICS_PING_SENT_DATETIME = "last_metrics_ping_iso_datetime"
        const val DUE_HOUR_OF_THE_DAY = 4
        const val LAST_VERSION_OF_APP_USED = "last_version_of_app_used"
    }

    init {}

    internal fun safeDateToString(date: Date): String = ""

    internal fun schedulePingCollection(
        now: Calendar,
        sendTheNextCalendarDay: Boolean,
        reason: Any?,
    ) {}

    internal fun isDifferentVersion(): Boolean = false

    internal fun getMillisecondsUntilDueTime(
        sendTheNextCalendarDay: Boolean,
        now: Calendar,
        dueHourOfTheDay: Int = DUE_HOUR_OF_THE_DAY,
    ): Long = 0L

    internal fun isAfterDueTime(
        now: Calendar,
        dueHourOfTheDay: Int = DUE_HOUR_OF_THE_DAY,
    ): Boolean = false

    internal fun getDueTimeForToday(now: Calendar, dueHourOfTheDay: Int): Calendar {
        val dueTime = now.clone() as Calendar
        dueTime.set(Calendar.HOUR_OF_DAY, 0)
        dueTime.set(Calendar.MINUTE, 0)
        dueTime.set(Calendar.SECOND, 0)
        dueTime.set(Calendar.MILLISECOND, 0)
        return dueTime
    }

    fun schedule(): Boolean = false

    internal fun collectPingAndReschedule(now: Calendar, startupPing: Boolean, reason: Any?) {}

    internal fun getLastCollectedDate(): Date? = null

    fun cancel() {}

    internal fun updateSentDate(date: String) {}

    internal fun getCalendarInstance(): Calendar = Calendar.getInstance()
}

internal class MetricsPingTimer(
    val scheduler: MetricsPingScheduler,
    val reason: Any?,
) : TimerTask() {
    override fun run() {}
}
