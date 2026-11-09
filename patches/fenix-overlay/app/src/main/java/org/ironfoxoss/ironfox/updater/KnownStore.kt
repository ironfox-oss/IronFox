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
  DISCOVERIUM("org.cygnusx1.discoverium", "Discoverium"),
  DROIDIFY("com.looker.droidify", "Droid-ify"),
  FDROID("org.fdroid.fdroid", "F-Droid"),
  FDROID_BASIC("org.fdroid.basic", "F-Droid Basic"),
  FFUPDATER("de.marmaro.krt.ffupdater", "FFUpdater"),
  FLICKY("app.flicky", "Flicky"),
  FLORID("com.nahnah.florid", "Florid"),
  FOXY_DROID("nya.kitsunyan.foxydroid", "Foxy Droid"),
  NEO_STORE("com.machiav3lli.fdroid", "Neo Store"),
  OBTAINIUM("dev.imranr.obtainium", "Obtainium"),
  OBTAINIUM_FDROID("dev.imranr.obtainium.fdroid", "Obtainium (F-Droid)"),
  OBTAINIUM_PLUS("dev.thejaustin.obtainiumplus", "Obtainium+"),
  OBTAINX("dev.bikram.obtainx", "ObtainX"),
  ORION_STORE("com.orion.store", "Orion Store"),
  UPDATIUM("io.github.omeritzics.updatium", "Updatium"),
  ZAPSTORE("dev.zapstore.app", "Zapstore"),
  ;

  companion object {
    /** Returns the store with [packageName], or null if it is not a known store. */
    fun forPackage(packageName: String?): KnownStore? = entries.firstOrNull { it.packageName == packageName }
  }
}
