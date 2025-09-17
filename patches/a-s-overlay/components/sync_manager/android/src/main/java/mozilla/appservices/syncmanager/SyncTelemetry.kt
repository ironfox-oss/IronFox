/* Hi, I'm a stub. ;) */

package mozilla.appservices.syncmanager

import mozilla.appservices.sync15.EngineInfo
import mozilla.appservices.sync15.SyncTelemetryPing
import org.json.JSONException

const val MAX_FAILURE_REASON_LENGTH = 100

sealed class InvalidTelemetryException : Exception {
    constructor(cause: Throwable) : super(cause)
    constructor(message: String) : super(message)

    class InvalidData(cause: JSONException) : InvalidTelemetryException(cause)

    class InvalidEvents(cause: JSONException) : InvalidTelemetryException(cause)

    class UnknownEvent(command: String) : InvalidTelemetryException("No event for command $command")
}

@Suppress("LargeClass")
object SyncTelemetry {
    @Suppress("LongParameterList")
    fun processSyncTelemetry(
        syncTelemetry: SyncTelemetryPing,
        submitGlobalPing: () -> Unit = { },
        submitHistoryPing: () -> Unit = { },
        submitBookmarksPing: () -> Unit = { },
        submitLoginsPing: () -> Unit = { },
        submitCreditCardsPing: () -> Unit = { },
        submitAddressesPing: () -> Unit = { },
        submitTabsPing: () -> Unit = { },
    ) {}

    @Suppress("ComplexMethod", "NestedBlockDepth", "ReturnCount")
    fun processHistoryPing(
        ping: SyncTelemetryPing,
        sendPing: () -> Unit = { },
    ): Boolean = true

    @Suppress("ComplexMethod", "NestedBlockDepth", "ReturnCount")
    fun processLoginsPing(
        ping: SyncTelemetryPing,
        sendPing: () -> Unit = { },
    ): Boolean = true

    @Suppress("ComplexMethod", "NestedBlockDepth", "ReturnCount")
    fun processBookmarksPing(
        ping: SyncTelemetryPing,
        sendPing: () -> Unit = { },
    ): Boolean = true

    private fun individualLoginsSync(hashedFxaUid: String, engineInfo: EngineInfo) {}

    private fun individualBookmarksSync(hashedFxaUid: String, engineInfo: EngineInfo) {}

    private fun individualHistorySync(hashedFxaUid: String, engineInfo: EngineInfo) {}

    private fun individualCreditCardsSync(hashedFxaUid: String, engineInfo: EngineInfo) {}

    private fun individualAddressesSync(hashedFxaUid: String, engineInfo: EngineInfo) {}

    private fun individualTabsSync(hashedFxaUid: String, engineInfo: EngineInfo) {}

    @Throws(Throwable::class)
    fun processFxaTelemetry(jsonStr: String): List<Throwable> = listOf()

    fun processOpenSyncSettingsMenuTelemetry() {}

    fun processSaveSyncSettingsTelemetry(enabledEngines: List<String>, disabledEngines: List<String>) {}
}
