/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import mozilla.components.browser.state.search.SearchAccessPoint
import mozilla.components.browser.state.search.SearchEngine
import org.mozilla.experiments.nimbus.NimbusEventStore

object MetricsUtils {
  private const val PBKDF2_ITERATIONS = 1000
  private const val PBKDF2_KEY_LEN_BITS = 256

  enum class Source {
    ACTION, SHORTCUT, SUGGESTION, TOPSITE, WIDGET, CONTEXT, DIGITAL_ASSISTANT, NONE
  }

  fun recordSearchMetrics(
    engine: SearchEngine,
    isDefault: Boolean,
    searchAccessPoint: Source,
    nimbusEventStore: NimbusEventStore,
  ) {}

  fun recordBookmarkAddMetric(
    source: BookmarkAction.Source,
    nimbusEventStore: NimbusEventStore,
    count: Int = 1,
  ) {}

  fun recordBookmarkMetrics(
    action: BookmarkAction,
    source: BookmarkAction.Source,
  ) {}

  enum class BookmarkAction {
    EDIT, DELETE, OPEN;

    enum class Source {
      ADD_BOOKMARK_TOAST,
      BOOKMARK_EDIT_PAGE,
      BOOKMARK_PANEL,
      BROWSER_NAVBAR,
      BROWSER_TOOLBAR,
      MENU_DIALOG,
      PAGE_ACTION_MENU,
      TABS_TRAY,
      TEST,
    }
  }

  private fun BookmarkAction.Source.label() = name.lowercase()

  @Suppress("FunctionOnlyReturningConstant")
  internal fun getHashingSalt(): String = "org.mozilla.fenix-salt"

  @Suppress("TooGenericExceptionCaught")
  internal fun getAdvertisingID(retrieveAdvertisingIdInfo: () -> String?): String? = null

  suspend fun getHashedIdentifier(
    retrieveAdvertisingIdInfo: () -> String?,
    encodeToString: (data: ByteArray, flag: Int) -> String,
    customSalt: String? = null,
  ): String? = null

  enum class TabGroupAccessPoint {
    TABS_TRAY,
    BROWSER_MENU,
  }
}

fun MetricsUtils.Source.toSearchAccessPoint(): String =
  when (this) {
    MetricsUtils.Source.CONTEXT -> SearchAccessPoint.CONTEXT
    MetricsUtils.Source.TOPSITE -> SearchAccessPoint.TOPSITE
    MetricsUtils.Source.WIDGET -> SearchAccessPoint.WIDGET
    MetricsUtils.Source.ACTION,
    MetricsUtils.Source.SHORTCUT,
    MetricsUtils.Source.SUGGESTION,
    MetricsUtils.Source.DIGITAL_ASSISTANT,
    MetricsUtils.Source.NONE -> SearchAccessPoint.DEFAULT
  }
