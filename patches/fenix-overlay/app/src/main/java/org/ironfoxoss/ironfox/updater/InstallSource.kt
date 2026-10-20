package org.ironfoxoss.ironfox.updater

import android.content.Context
import android.content.Intent
import android.os.Build
import org.ironfoxoss.ironfox.utils.IronFoxSettings

/**
 * Tells which known store installed IronFox.
 *
 * Android forgets the installer when the store is uninstalled, and an in-app update makes IronFox its own installer,
 * so the store is remembered the first time it is seen.
 *
 * @param context Application context.
 * @param settings Where the remembered store is kept.
 */
class InstallSource(
    private val context: Context,
    private val settings: IronFoxSettings,
) {
    /** The known store IronFox was installed from, even if it is no longer the installer or no longer installed. */
    val rememberedStore: KnownStore?
        get() = KnownStore.forPackage(settings.updaterOriginalStore)

    /** Remembers the installer if it is a known store; any other installer leaves the remembered store alone. */
    fun rememberInstaller() {
        val store = KnownStore.forPackage(installingPackage()) ?: return
        if (settings.updaterOriginalStore != store.packageName) {
            settings.updaterOriginalStore = store.packageName
        }
    }

    /** Returns an intent that opens [store], or null if it is not installed. */
    fun launchIntentFor(store: KnownStore): Intent? =
        context.packageManager.getLaunchIntentForPackage(store.packageName)

    private fun installingPackage(): String? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        context.packageManager.getInstallSourceInfo(context.packageName).installingPackageName
    } else {
        @Suppress("DEPRECATION")
        context.packageManager.getInstallerPackageName(context.packageName)
    }
}
