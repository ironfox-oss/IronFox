/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.distributions

import android.database.Cursor

interface DistributionProviderChecker {
    fun queryProvider(): String?
}

class DefaultDistributionProviderChecker(private val context: Any?) : DistributionProviderChecker {
    override fun queryProvider(): String? {
        return null
    }

    private fun Cursor.getProvider(): String? {
        return null
    }
}
