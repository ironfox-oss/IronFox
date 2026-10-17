package org.ironfoxoss.ironfox.updater

import android.content.Context
import androidx.core.content.edit

/** The user-controlled state of the updater. */
interface UpdaterStore {
    /** Whether the user opted in to automatic checks. */
    var enabled: Boolean

    /** Whether the user lifted the installer gate. */
    var allowOtherSources: Boolean

    /** When the feed was last fetched successfully, in milliseconds; 0 if never. */
    var lastCheckMillis: Long

    /** The version the user chose "Later" for, if any. */
    var dismissedVersion: String?
}

/**
 * The updater settings that come from Gecko preferences.
 *
 * @property feedUrl Where the update feed lives.
 * @property intervalHours The minimum time between automatic checks.
 * @property allowedHosts Comma separated hosts the updater may talk to.
 * @property allowInsecureHttp Whether plain HTTP is accepted as well as HTTPS (off unless the user turns it on).
 */
data class UpdaterConfig(
    val feedUrl: String,
    val intervalHours: Long,
    val allowedHosts: String,
    val allowInsecureHttp: Boolean = false,
)

/**
 * [UpdaterStore] backed by SharedPreferences, readable at startup.
 *
 * @param context Application context.
 */
class UpdaterSettings(context: Context) : UpdaterStore {
    private val preferences = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)

    override var enabled: Boolean
        get() = preferences.getBoolean(KEY_ENABLED, false)
        set(value) = preferences.edit { putBoolean(KEY_ENABLED, value) }

    override var allowOtherSources: Boolean
        get() = preferences.getBoolean(KEY_ALLOW_OTHER_SOURCES, false)
        set(value) = preferences.edit { putBoolean(KEY_ALLOW_OTHER_SOURCES, value) }

    override var lastCheckMillis: Long
        get() = preferences.getLong(KEY_LAST_CHECK, 0L)
        set(value) = preferences.edit { putLong(KEY_LAST_CHECK, value) }

    override var dismissedVersion: String?
        get() = preferences.getString(KEY_DISMISSED_VERSION, null)
        set(value) = preferences.edit { putString(KEY_DISMISSED_VERSION, value) }

    private companion object {
        const val PREFERENCES_NAME = "ironfox_updater"
        const val KEY_ENABLED = "enabled"
        const val KEY_ALLOW_OTHER_SOURCES = "allowOtherSources"
        const val KEY_LAST_CHECK = "lastCheck"
        const val KEY_DISMISSED_VERSION = "dismissedVersion"
    }
}
