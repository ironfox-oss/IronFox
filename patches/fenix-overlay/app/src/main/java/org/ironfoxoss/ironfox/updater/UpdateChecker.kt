package org.ironfoxoss.ironfox.updater

import java.io.IOException
import org.ironfoxoss.ironfox.utils.IronFoxSettings

/** The bounds of the user-chosen interval between automatic checks. */
object UpdateInterval {
  /** The shortest interval, in hours. */
  const val MIN_HOURS = 1

  /** The longest interval, in hours. */
  const val MAX_HOURS = 24

  /** The interval used until the user changes it, in hours. */
  const val DEFAULT_HOURS = 1
}

/** The outcome of an update check. */
sealed interface CheckResult {
  /** No request was made: the updater is off or the interval has not elapsed. */
  data object NotDue : CheckResult

  /** The installed build is current. */
  data object UpToDate : CheckResult

  /** A newer build exists. */
  data class Available(val offer: UpdateOffer) : CheckResult

  /** A newer build exists but the user already dismissed that version. */
  data class Dismissed(val offer: UpdateOffer) : CheckResult
}

/**
 * Asks the update feed whether a newer build of the installed variant exists.
 *
 * @param fetcher Fetches the feed within the host allowlist.
 * @param feedUrl Where the feed lives.
 * @param settings The persisted updater settings and state.
 * @param packageName The package key to look up in the feed.
 * @param installedVersionCode The version code of the running app.
 * @param clock Supplies the current time in milliseconds.
 */
class UpdateChecker(
  private val fetcher: AllowlistedFetcher,
  private val feedUrl: String,
  private val settings: IronFoxSettings,
  private val packageName: String,
  private val installedVersionCode: Long,
  private val clock: () -> Long,
) {
  /** The variant of the running app; updates always stay on it. */
  val installedVariant: Variant = VersionCode.variantOf(installedVersionCode)

  /**
   * Checks the feed; a manual check ignores the enabled switch, the interval, the failure cooldown and the
   * dismissed version.
   *
   * @throws IOException on network failure.
   * @throws ManifestException if the feed is malformed.
   * @throws SecurityException if the feed leaves the host allowlist.
   */
  fun check(manual: Boolean): CheckResult {
    if (!manual && !isDue()) return CheckResult.NotDue
    val offer = fetchOffer()
    settings.updaterLastCheckMillis = clock()
    return when {
      !VersionCode.isNewerBuild(offer.versionCode, installedVersionCode) -> CheckResult.UpToDate
      !manual && offer.version == settings.updaterDismissedVersion -> CheckResult.Dismissed(offer)
      else -> CheckResult.Available(offer)
    }
  }

  private fun isDue(): Boolean {
    val now = clock()
    val hours = settings.updaterIntervalHours.coerceIn(UpdateInterval.MIN_HOURS, UpdateInterval.MAX_HOURS)
    return settings.updaterEnabled &&
      now - settings.updaterLastCheckMillis >= hours * MILLIS_PER_HOUR &&
      now - settings.updaterLastFailureMillis >= FAILURE_COOLDOWN_MILLIS
  }

  private fun fetchOffer(): UpdateOffer {
    val body = fetcher.fetch(feedUrl, FEED_TIMEOUT_SECONDS).body.string()
    val offer = UpdateManifest.parse(body, packageName, installedVariant)
    if (VersionCode.variantOf(offer.versionCode) != installedVariant) {
      throw ManifestException("Update feed entry for $installedVariant has another variant's version code")
    }
    return offer
  }

  private companion object {
    const val FAILURE_COOLDOWN_MILLIS = 15 * 60_000L
    const val FEED_TIMEOUT_SECONDS = 10L
    const val MILLIS_PER_HOUR = 3_600_000L
  }
}
