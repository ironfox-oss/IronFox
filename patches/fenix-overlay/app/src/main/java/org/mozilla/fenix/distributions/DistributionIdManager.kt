/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.distributions

class DistributionIdManager(
    private val packageManager: Any?,
    private val browserStoreProvider: Any?,
    private val distributionProviderChecker: Any?,
    private val distributionSettings: Any?,
    private val metricController: Any?,
    private val appPreinstalledOnVivoDevice: () -> Boolean = { false },
    private val isDtTelefonicaInstalled: () -> Boolean = { false },
    private val isDtUsaInstalled: () -> Boolean = { false },
) {
    fun getDistributionId(): String = "Mozilla"
    fun updateDistributionIdFromUtmParams(utmParams: Any?) {}
    fun shouldSkipMarketingConsentScreen(): Boolean = true
    fun isPartnershipDistribution(): Boolean = false
    fun startAdjustIfSkippingConsentScreen() {}

    internal enum class Distribution(val id: String) {
        DEFAULT(id = "Mozilla"),
        ;

        companion object {
            fun fromId(id: String): Distribution {
                return DEFAULT
            }
        }
    }
}
