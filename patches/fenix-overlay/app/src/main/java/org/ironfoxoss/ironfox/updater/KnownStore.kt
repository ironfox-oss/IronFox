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
  ACCRESCENT("app.accrescent.client", "Accrescent"),
  AURORA_DROID("com.aurora.adroid", "Aurora Droid"),
  DROIDIFY("com.looker.droidify", "Droid-ify"),
  FDROID("org.fdroid.fdroid", "F-Droid"),
  FDROID_BASIC("org.fdroid.basic", "F-Droid Basic"),
  FFUPDATER("de.marmaro.krt.ffupdater", "FFUpdater"),
  FOXY_DROID("nya.kitsunyan.foxydroid", "Foxy Droid"),
  NEO_STORE("com.machiav3lli.fdroid", "Neo Store"),
  OBTAINIUM("dev.imranr.obtainium", "Obtainium"),
  OBTAINX("dev.bikram.obtainx", "ObtainX"),
  ZAPSTORE("dev.zapstore.app", "Zapstore"),
  ;

  companion object {
    /** Returns the store with [packageName], or null if it is not a known store. */
    fun forPackage(packageName: String?): KnownStore? = entries.firstOrNull { it.packageName == packageName }
  }
}
