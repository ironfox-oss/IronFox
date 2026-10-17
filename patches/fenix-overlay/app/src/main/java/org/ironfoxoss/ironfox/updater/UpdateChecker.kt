package org.ironfoxoss.ironfox.updater

import java.io.IOException

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
 * @param config The Gecko-backed updater configuration.
 * @param store The persisted updater state.
 * @param packageName The package key to look up in the feed.
 * @param installedVersionCode The version code of the running app.
 * @param clock Supplies the current time in milliseconds.
 */
class UpdateChecker(
    private val fetcher: AllowlistedFetcher,
    private val config: UpdaterConfig,
    private val store: UpdaterStore,
    private val packageName: String,
    private val installedVersionCode: Long,
    private val clock: () -> Long,
) {
    /** The variant of the running app; updates always stay on it. */
    val installedVariant: Variant = VersionCode.variantOf(installedVersionCode)

    /**
     * Checks the feed; a manual check ignores the enabled switch, the interval and the dismissed version.
     *
     * @throws IOException on network failure.
     * @throws ManifestException if the feed is malformed.
     * @throws SecurityException if the feed leaves the host allowlist.
     */
    fun check(manual: Boolean): CheckResult {
        if (!manual && !isDue()) return CheckResult.NotDue
        val offer = fetchOffer()
        store.lastCheckMillis = clock()
        return when {
            !VersionCode.isNewerBuild(offer.versionCode, installedVersionCode) -> CheckResult.UpToDate
            !manual && offer.version == store.dismissedVersion -> CheckResult.Dismissed(offer)
            else -> CheckResult.Available(offer)
        }
    }

    private fun isDue(): Boolean =
        store.enabled && clock() - store.lastCheckMillis >= config.intervalHours * MILLIS_PER_HOUR

    private fun fetchOffer(): UpdateOffer {
        val body = fetcher.fetch(config.feedUrl, FEED_TIMEOUT_SECONDS).body.string()
        val offer = UpdateManifest.parse(body, packageName, installedVariant)
        if (VersionCode.variantOf(offer.versionCode) != installedVariant) {
            throw ManifestException("Update feed entry for $installedVariant has another variant's version code")
        }
        return offer
    }

    private companion object {
        const val FEED_TIMEOUT_SECONDS = 10L
        const val MILLIS_PER_HOUR = 3_600_000L
    }
}
