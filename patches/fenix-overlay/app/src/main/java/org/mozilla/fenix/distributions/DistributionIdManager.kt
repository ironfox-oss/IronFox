/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.distributions

import android.content.Context
import androidx.annotation.VisibleForTesting

class DistributionIdManager(
    private val context: Context,
    private val browserStoreProvider: DistributionBrowserStoreProvider,
    private val distributionProviderChecker: DistributionProviderChecker,
    private val legacyDistributionProviderChecker: DistributionProviderChecker,
    private val distributionSettings: DistributionSettings,
    private val appPreinstalledOnVivoDevice: () -> Boolean = { false },
    private val isDtTelefonicaInstalled: () -> Boolean = { false },
    private val isDtUsaInstalled: () -> Boolean = { false },
) {
    fun getDistributionId(): String = "Mozilla"

    fun isPartnershipDistribution(): Boolean = false

    @VisibleForTesting
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
