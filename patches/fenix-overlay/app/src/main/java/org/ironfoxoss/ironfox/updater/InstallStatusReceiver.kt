package org.ironfoxoss.ironfox.updater

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import androidx.core.content.IntentCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.ProcessLifecycleOwner
import org.mozilla.fenix.ext.components

/**
 * Receives the result of an update install session.
 *
 * The system confirmation is shown only while IronFox is in the foreground; otherwise the session is
 * abandoned and the verified APK stays in the cache for the next attempt.
 */
class InstallStatusReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)) {
            PackageInstaller.STATUS_PENDING_USER_ACTION -> confirmOrAbandon(context, intent)
            PackageInstaller.STATUS_SUCCESS, PackageInstaller.STATUS_FAILURE_ABORTED -> Unit
            else -> InstallEvents.publish(InstallFailureMapper.fromStatus(status))
        }
    }

    private fun confirmOrAbandon(context: Context, intent: Intent) {
        val confirmation = confirmationIntent(intent)
        if (confirmation != null && isInForeground()) {
            context.startActivity(confirmation.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        } else {
            abandonSession(context, intent)
            context.components.settings.ironfox.updaterLastCheckMillis = 0L
        }
    }

    private fun abandonSession(context: Context, intent: Intent) {
        val sessionId = intent.getIntExtra(PackageInstaller.EXTRA_SESSION_ID, NO_SESSION)
        if (sessionId == NO_SESSION) return
        runCatching { context.packageManager.packageInstaller.abandonSession(sessionId) }
    }

    private fun isInForeground() =
        ProcessLifecycleOwner.get().lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)

    private fun confirmationIntent(intent: Intent): Intent? =
        IntentCompat.getParcelableExtra(intent, Intent.EXTRA_INTENT, Intent::class.java)

    private companion object {
        const val NO_SESSION = -1
    }
}
