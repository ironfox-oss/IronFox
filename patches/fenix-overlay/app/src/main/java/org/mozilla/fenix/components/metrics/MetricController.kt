/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import androidx.annotation.VisibleForTesting
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.fenix.utils.Settings

interface MetricController {
    fun start(type: MetricServiceType)
    fun stop(type: MetricServiceType)
    fun track(event: Event)

    companion object {
        fun create(
            services: List<MetricsService>,
            isDataTelemetryEnabled: () -> Boolean,
            isMarketingDataTelemetryEnabled: () -> Boolean,
            isUsageTelemetryEnabled: () -> Boolean,
            settings: Settings,
        ): MetricController {
            return DebugMetricController()
        }
    }
}

@VisibleForTesting
internal class DebugMetricController(
    private val logger: Logger = Logger(),
) : MetricController {
    override fun start(type: MetricServiceType) {}

    override fun stop(type: MetricServiceType) {}

    override fun track(event: Event) {}
}
