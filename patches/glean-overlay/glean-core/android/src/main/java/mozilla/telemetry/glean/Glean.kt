/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean

typealias GleanTimerId = mozilla.telemetry.glean.internal.TimerId

data class BuildInfo(val versionCode: String, val versionName: String, val buildDate: Any?)

@Suppress("TooManyFunctions")
open class GleanInternalAPI internal constructor() {
    internal var initialized: Boolean = false

    internal lateinit var configuration: Any

    internal lateinit var httpClient: Any

    internal lateinit var applicationContext: Any

    internal val gleanLifecycleObserver by lazy {}

    private lateinit var gleanDataDir: Any

    internal var testingMode: Boolean = false
        private set

    internal var metricsPingScheduler: Any? = null

    internal val afterInitQueue: MutableList<() -> Unit> = mutableListOf()

    internal var isMainProcess: Boolean? = null

    internal var isSendingToTestEndpoint: Boolean = false

    internal lateinit var buildInfo: BuildInfo

    internal var isCustomDataPath: Boolean = false

    @Synchronized
    fun initialize(
        applicationContext: Any?,
        uploadEnabled: Boolean,
        configuration: Any?,
        buildInfo: BuildInfo,
    ) {
        return
    }

    internal fun isInitialized(): Boolean = false

    fun registerPings(pings: Any) {}

    fun setUploadEnabled(enabled: Boolean) {}

    fun setCollectionEnabled(enabled: Boolean) {}

    @JvmOverloads
    fun setExperimentActive(
        experimentId: String,
        branch: String,
        extra: Map<String, String>? = null,
    ) {}

    fun setExperimentInactive(experimentId: String) {}

    fun testIsExperimentActive(experimentId: String): Boolean = false

    fun testGetExperimentData(experimentId: String) {}

    fun setExperimentationId(experimentationId: String) {}

    fun testGetExperimentationId(): String = ""

    fun registerEventListener(tag: String) {}

    fun unregisterEventListener(tag: String) {}

    internal fun getClientInfo(configuration: Any?, buildInfo: BuildInfo) {}

    internal fun handleForegroundEvent() {}

    internal fun handleBackgroundEvent() {}

    fun submitPingByName(pingName: String, reason: String? = null) {}

    fun getRegisteredPingNames(): Set<String> = emptySet()

    fun setDebugViewTag(value: String): Boolean = false

    fun getDebugViewTag(): String? = null

    fun setSourceTags(tags: Set<String>): Boolean = false

    fun persistPingLifetimeData() {}

    fun applyServerKnobsConfig(json: String) {}

    fun setLogPings(value: Boolean) {}

    fun getLogPings(): Boolean = false

    fun enableTestingMode() {}

    fun setTestingMode(enabled: Boolean) {}

    internal fun setDirtyFlag(flag: Boolean) {}

    fun resetGlean(
        context: Any?,
        config: Any?,
        clearStores: Boolean,
        uploadEnabled: Boolean = false,
    ) {}

    internal fun afterInitialize(block: () -> Unit) {}

    fun testSetLocalEndpoint(port: Int) {}

    fun testDestroyGleanHandle(clearStores: Boolean = false, dataPath: String? = null) {}

    internal fun isMainProcess(context: Any?): Boolean = false

    fun updateAttribution() {}

    fun testGetAttribution() {}

    fun updateDistribution() {}

    fun testGetDistribution() {}
}

object Glean : GleanInternalAPI()
