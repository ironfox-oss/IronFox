package org.ironfoxoss.ironfox.updater

import android.annotation.SuppressLint
import android.content.Context
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.mozilla.fenix.R

/** Shows the download progress notification owned by the updater. */
class UpdateNotifier(private val context: Context) {
    private val manager = NotificationManagerCompat.from(context)
    private var shown = false
    private var lastPercent: Int? = null

    init {
        manager.createNotificationChannel(
            NotificationChannelCompat.Builder(CHANNEL_ID, NotificationManagerCompat.IMPORTANCE_LOW)
                .setName(context.getString(R.string.updater_notification_channel))
                .build(),
        )
    }

    /** Shows the download notification; a null [percent] shows an indeterminate bar. */
    @SuppressLint("MissingPermission")
    fun showProgress(percent: Int?) {
        if (shown && percent == lastPercent) return
        shown = true
        lastPercent = percent
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_ironfox_status_logo)
            .setContentTitle(context.getString(R.string.updater_notification_downloading))
            .setProgress(MAX_PERCENT, percent ?: 0, percent == null)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
        manager.notify(NOTIFICATION_ID, notification)
    }

    /** Removes the download notification. */
    fun cancel() {
        shown = false
        lastPercent = null
        manager.cancel(NOTIFICATION_ID)
    }

    private companion object {
        const val CHANNEL_ID = "ironfox_updater"
        const val NOTIFICATION_ID = 0x1F0
        const val MAX_PERCENT = 100
    }
}
