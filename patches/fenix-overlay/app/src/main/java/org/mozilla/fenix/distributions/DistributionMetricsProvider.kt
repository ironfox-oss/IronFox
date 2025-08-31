/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.distributions

interface DistributionMetricsProvider {
    fun recordDt001Detected()

    fun recordDt001LegacyDetected()

    fun recordDt002Detected()

    fun recordDt002LegacyDetected()

    fun recordDt003Detected()

    fun recordDt003LegacyDetected()
}

class DefaultDistributionMetricsProvider : DistributionMetricsProvider {
    override fun recordDt001Detected() {}

    override fun recordDt001LegacyDetected() {}

    override fun recordDt002Detected() {}

    override fun recordDt002LegacyDetected() {}

    override fun recordDt003Detected() {}

    override fun recordDt003LegacyDetected() {}
}
