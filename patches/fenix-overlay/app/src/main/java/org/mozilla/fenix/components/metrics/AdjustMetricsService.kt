/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import android.app.Application
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import mozilla.components.lib.crash.CrashReporter

class AdjustMetricsService(
    private val application: Application,
    private val storage: MetricsStorage,
    private val crashReporter: CrashReporter,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MetricsService {
    override val type = MetricServiceType.Marketing

    override fun start() {
    }

    override fun stop() {
    }

    override fun track(event: Event) {
    }

    override fun shouldTrack(event: Event): Boolean = false

    companion object {
        private fun triggerPing() {
        }
    }
}
