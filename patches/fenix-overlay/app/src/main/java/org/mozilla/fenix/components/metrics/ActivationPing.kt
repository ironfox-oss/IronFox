/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import android.content.Context
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers

class ActivationPing(
    private val context: Context,
    private val backgroundDispatcher: CoroutineDispatcher = Dispatchers.IO,
) {
    fun checkAndSend() {
        return
    }
}
