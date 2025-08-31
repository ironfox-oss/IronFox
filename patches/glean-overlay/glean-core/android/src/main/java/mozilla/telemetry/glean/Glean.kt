/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean

import android.content.Context
import androidx.annotation.VisibleForTesting
import mozilla.telemetry.glean.config.Configuration
import mozilla.telemetry.glean.net.BaseUploader
import mozilla.telemetry.glean.scheduler.GleanLifecycleObserver
import mozilla.telemetry.glean.scheduler.MetricsPingScheduler
import java.io.File
import java.util.Calendar

typealias GleanTimerId = mozilla.telemetry.glean.internal.TimerId

data class BuildInfo(val versionCode: String, val versionName: String, val buildDate: Calendar)

@Suppress("TooManyFunctions")
open class GleanInternalAPI internal constructor() {
    internal var initialized: Boolean = false

    internal lateinit var configuration: Configuration

    internal lateinit var httpClient: BaseUploader

    internal lateinit var applicationContext: Context

    internal val gleanLifecycleObserver by lazy { GleanLifecycleObserver() }

    private lateinit var gleanDataDir: File

    internal var testingMode: Boolean = false
        private set

    internal var metricsPingScheduler: MetricsPingScheduler? = null

    internal val afterInitQueue: MutableList<() -> Unit> = mutableListOf()

    @VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
    internal var isMainProcess: Boolean? = null

    internal var isSendingToTestEndpoint: Boolean = false

    internal lateinit var buildInfo: BuildInfo

    internal var isCustomDataPath: Boolean = false

    @JvmOverloads
    @Synchronized
    fun initialize(
        applicationContext: Context,
        uploadEnabled: Boolean,
        configuration: Configuration = Configuration(),
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

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    fun testIsExperimentActive(experimentId: String): Boolean = false

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    fun testGetExperimentData(experimentId: String) {}

    fun setExperimentationId(experimentationId: String) {}

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    fun testGetExperimentationId(): String = ""

    fun registerEventListener(tag: String) {}

    fun unregisterEventListener(tag: String) {}

    internal fun getClientInfo(configuration: Configuration, buildInfo: BuildInfo) {}

    internal fun getDataDir(): File = File("")

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

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    fun enableTestingMode() {}

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    fun setTestingMode(enabled: Boolean) {}

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    internal fun setDirtyFlag(flag: Boolean) {}

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    fun resetGlean(
        context: Context,
        config: Configuration,
        clearStores: Boolean,
        uploadEnabled: Boolean = false,
    ) {}

    internal fun afterInitialize(block: () -> Unit) {}

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    fun testSetLocalEndpoint(port: Int) {}

    @VisibleForTesting(otherwise = VisibleForTesting.NONE)
    fun testDestroyGleanHandle(clearStores: Boolean = false, dataPath: String? = null) {}

    @VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
    internal fun isMainProcess(context: Context): Boolean = false

    fun updateAttribution() {}

    @VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
    fun testGetAttribution() {}

    fun updateDistribution() {}

    @VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
    fun testGetDistribution() {}
}

object Glean : GleanInternalAPI()
