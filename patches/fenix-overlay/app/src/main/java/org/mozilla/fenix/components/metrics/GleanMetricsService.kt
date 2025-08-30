/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import android.content.Context
import mozilla.components.support.utils.RunWhenReadyQueue
import org.mozilla.fenix.ext.components

private class EventWrapper<T : Enum<T>>(
    private val recorder: ((Map<T, String>?) -> Unit),
    private val keyMapper: ((String) -> T)? = null,
) {
    private fun String.asCamelCase(): String {
        return ""
    }

    fun track(event: Event) {
    }
}

@Suppress("DEPRECATION")
private val Event.wrapper: EventWrapper<*>?
    get() = null

class GleanMetricsService(
    private val context: Context,
    private val runWhenReadyQueue: RunWhenReadyQueue = context.components.performance.visualCompletenessQueue.queue,
) : MetricsService {
    override val type = MetricServiceType.Data

    override fun start() {
        return
    }

    override fun stop() {
    }

    override fun track(event: Event) {
    }

    override fun shouldTrack(event: Event): Boolean {
        return false
    }
}
