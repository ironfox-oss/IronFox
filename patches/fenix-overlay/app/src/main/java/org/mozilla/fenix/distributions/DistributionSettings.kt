/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.distributions

interface DistributionSettings {
    fun getDistributionId(): String
    fun saveDistributionId(id: String)
    fun setMarketingTelemetryPreferences()
}

class DefaultDistributionSettings(
    private val settings: Any?,
) : DistributionSettings {
    override fun getDistributionId() = "Mozilla"
    override fun saveDistributionId(id: String) {}
    override fun setMarketingTelemetryPreferences() {}
}
