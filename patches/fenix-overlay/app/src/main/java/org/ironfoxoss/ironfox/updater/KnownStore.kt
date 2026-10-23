package org.ironfoxoss.ironfox.updater

/**
 * An app store or updater tool that IronFox may have been installed from.
 *
 * Only these are treated as stores: for every other installer (adb, a package installer, anything unknown) IronFox
 * updates itself.
 *
 * @property packageName The installer package name Android reports.
 * @property displayName The name to show to the user.
 */
enum class KnownStore(val packageName: String, val displayName: String) {
    FDROID("org.fdroid.fdroid", "F-Droid"),
    FDROID_BASIC("org.fdroid.basic", "F-Droid Basic"),
    DROIDIFY("com.looker.droidify", "Droid-ify"),
    NEO_STORE("com.machiav3lli.fdroid", "Neo Store"),
    FOXY_DROID("nya.kitsunyan.foxydroid", "Foxy Droid"),
    AURORA_DROID("com.aurora.adroid", "Aurora Droid"),
    ACCRESCENT("app.accrescent.client", "Accrescent"),
    ZAPSTORE("dev.zapstore.app", "Zapstore"),
    OBTAINIUM("dev.imranr.obtainium", "Obtainium"),
    OBTAINX("dev.bikram.obtainx", "ObtainX"),
    FFUPDATER("de.marmaro.krt.ffupdater", "FFUpdater"),
    ;

    companion object {
        /** Returns the store with [packageName], or null if it is not a known store. */
        fun forPackage(packageName: String?): KnownStore? = entries.firstOrNull { it.packageName == packageName }
    }
}
