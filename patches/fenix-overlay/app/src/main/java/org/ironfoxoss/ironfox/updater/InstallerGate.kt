package org.ironfoxoss.ironfox.updater

/** Reports which package installed the app and which one owns its updates. */
interface InstallSourceReader {
    /** The package that installed the app, or null for adb and unknown sources. */
    val installingPackage: String?

    /** The package that owns updates for the app (Android 14+), or null if none does. */
    val updateOwnerPackage: String?
}

/** Whether automatic updates start enabled for the way IronFox was installed. */
enum class InstallerGateState { ENABLED_BY_DEFAULT, DISABLED_BY_DEFAULT }

/**
 * Decides whether the updater may run, based on who installed the app.
 *
 * Stores and updater tools own updates for the apps they install, so the updater stays off for them
 * unless the user lifts the gate.
 *
 * @param source The install source of the running app.
 * @param selfPackage The package name of the running app.
 */
class InstallerGate(
    private val source: InstallSourceReader,
    private val selfPackage: String,
) {
    /** The name to show for the installer: a known name, the raw package name, or a placeholder. */
    val installerDisplayName: String
        get() = source.installingPackage?.let { KNOWN_INSTALLERS[it] ?: it } ?: UNKNOWN_INSTALLER

    /** Returns whether the updater starts enabled for this install source. */
    fun defaultState(): InstallerGateState {
        val owner = source.updateOwnerPackage
        if (owner != null && owner != selfPackage) return InstallerGateState.DISABLED_BY_DEFAULT
        val installer = source.installingPackage
        return if (installer == null || installer == selfPackage || installer in SELF_SERVICE_INSTALLERS) {
            InstallerGateState.ENABLED_BY_DEFAULT
        } else {
            InstallerGateState.DISABLED_BY_DEFAULT
        }
    }

    /** Returns whether the updater may run given the user's "other sources" override. */
    fun isAllowed(allowOtherSources: Boolean): Boolean =
        allowOtherSources || defaultState() == InstallerGateState.ENABLED_BY_DEFAULT

    private companion object {
        const val UNKNOWN_INSTALLER = "adb / unknown"

        val SELF_SERVICE_INSTALLERS = setOf(
            "com.google.android.packageinstaller",
            "com.android.packageinstaller",
            "com.google.android.documentsui",
            "com.android.documentsui",
            "com.miui.packageinstaller",
            "com.samsung.android.packageinstaller",
        )

        val KNOWN_INSTALLERS = mapOf(
            "org.fdroid.fdroid" to "F-Droid",
            "app.accrescent.client" to "Accrescent",
            "com.android.vending" to "Google Play",
            "dev.imranr.obtainium" to "Obtainium",
            "com.google.android.packageinstaller" to "Package installer",
            "com.android.packageinstaller" to "Package installer",
            "com.google.android.documentsui" to "Files",
            "com.android.documentsui" to "Files",
            "com.miui.packageinstaller" to "Package installer",
            "com.samsung.android.packageinstaller" to "Package installer",
        )
    }
}
