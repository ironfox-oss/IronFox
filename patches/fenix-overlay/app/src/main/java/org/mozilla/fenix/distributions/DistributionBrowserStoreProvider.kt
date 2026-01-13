/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.distributions

interface DistributionBrowserStoreProvider {
    fun getDistributionId(): String?
    fun updateDistributionId(id: String)
}

class DefaultDistributionBrowserStoreProvider(
    private val browserStore: Any?,
) : DistributionBrowserStoreProvider {
    override fun getDistributionId(): String? = "Mozilla"

    override fun updateDistributionId(id: String) {}
}
