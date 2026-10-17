package org.ironfoxoss.ironfox.updater

import mozilla.components.concept.engine.Engine
import org.ironfoxoss.ironfox.utils.getPref

/** Reads the updater's Gecko preferences from the engine. */
object GeckoUpdaterConfig {
    /** Gecko pref holding the feed URL. */
    const val PREF_URL = "browser.ironfox.updater.url"

    /** Gecko pref holding the minimum hours between automatic checks. */
    const val PREF_INTERVAL_HOURS = "browser.ironfox.updater.intervalHours"

    /** Gecko pref holding the comma separated hosts the updater may contact. */
    const val PREF_ALLOWED_HOSTS = "browser.ironfox.updater.allowedHosts"

    /** Gecko pref (off by default) that lets the updater use plain HTTP, for testing against a local server. */
    const val PREF_ALLOW_INSECURE_HTTP = "browser.ironfox.updater.allowInsecureHttpConnection"

    private const val DEFAULT_FEED_URL = "https://releases.ironfoxoss.org/ironfox/updates.json"
    private const val DEFAULT_INTERVAL_HOURS = 24L

    /**
     * Loads the configuration; an unreadable allowlist comes back empty so the updater refuses to run.
     * Must be called from the main thread.
     */
    suspend fun load(engine: Engine): UpdaterConfig = UpdaterConfig(
        feedUrl = getPref(engine, PREF_URL) as? String ?: DEFAULT_FEED_URL,
        intervalHours = (getPref(engine, PREF_INTERVAL_HOURS) as? Number)?.toLong() ?: DEFAULT_INTERVAL_HOURS,
        allowedHosts = getPref(engine, PREF_ALLOWED_HOSTS) as? String ?: "",
        allowInsecureHttp = getPref(engine, PREF_ALLOW_INSECURE_HTTP) == true,
    )
}
