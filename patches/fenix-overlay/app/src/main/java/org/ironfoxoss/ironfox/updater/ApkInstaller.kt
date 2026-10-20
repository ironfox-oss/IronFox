package org.ironfoxoss.ironfox.updater

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import java.io.File
import java.io.IOException

/**
 * Installs a verified APK through a [PackageInstaller] session.
 *
 * @param context Application context.
 */
class ApkInstaller(private val context: Context) {
    private val packageInstaller: PackageInstaller
        get() = context.packageManager.packageInstaller

    /** Returns whether the user has allowed IronFox to install packages. */
    fun canRequestInstalls(): Boolean = context.packageManager.canRequestPackageInstalls()

    /**
     * Commits [apk] as an update to this app; the result arrives at [InstallStatusReceiver].
     *
     * @throws IllegalStateException if installs are not allowed yet.
     * @throws IOException if the session cannot be written.
     */
    @SuppressLint("RequestInstallPackagesPolicy")
    fun install(apk: File) {
        check(canRequestInstalls()) { "IronFox is not allowed to install packages" }
        val sessionId = packageInstaller.createSession(sessionParams())
        try {
            packageInstaller.openSession(sessionId).use { session ->
                write(session, apk)
                session.commit(statusIntentSender(sessionId))
            }
        } catch (e: IOException) {
            packageInstaller.abandonSession(sessionId)
            throw e
        } catch (e: SecurityException) {
            packageInstaller.abandonSession(sessionId)
            throw e
        }
    }

    private fun sessionParams() = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
        .apply {
            setAppPackageName(context.packageName)
        }

    private fun write(session: PackageInstaller.Session, apk: File) {
        apk.inputStream().use { input ->
            session.openWrite(SESSION_ENTRY_NAME, 0, apk.length()).use { output ->
                input.copyTo(output)
                session.fsync(output)
            }
        }
    }

    private fun statusIntentSender(sessionId: Int) = PendingIntent.getBroadcast(
        context,
        sessionId,
        Intent(context, InstallStatusReceiver::class.java),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
    ).intentSender

    companion object {
        private const val SESSION_ENTRY_NAME = "ironfox.apk"

        /** Abandons every install session this app left open, e.g. one waiting for a confirmation. */
        fun abandonLeftoverSessions(context: Context) {
            val packageInstaller = context.packageManager.packageInstaller
            packageInstaller.mySessions.forEach { packageInstaller.abandonSession(it.sessionId) }
        }
    }
}
