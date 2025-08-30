/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import android.content.Context
import mozilla.components.browser.state.search.SearchEngine
import org.mozilla.experiments.nimbus.NimbusEventStore

object MetricsUtils {
    enum class Source {
        ACTION, SHORTCUT, SUGGESTION, TOPSITE, WIDGET, NONE
    }

    fun recordSearchMetrics(
        engine: SearchEngine,
        isDefault: Boolean,
        searchAccessPoint: Source,
        nimbusEventStore: NimbusEventStore,
    ) {}

    fun recordBookmarkMetrics(
        action: BookmarkAction,
        source: String,
    ) {}

    enum class BookmarkAction {
        ADD, EDIT, DELETE, OPEN
    }

    suspend fun getHashedIdentifier(context: Context, customSalt: String? = null): String? = null
}
