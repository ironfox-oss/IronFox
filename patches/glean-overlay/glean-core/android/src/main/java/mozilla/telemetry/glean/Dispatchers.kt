/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.newSingleThreadContext
import java.util.concurrent.ConcurrentLinkedQueue

internal object Dispatchers {
    class WaitableCoroutineScope(private val coroutineScope: CoroutineScope) {
        fun setTestingMode(enabled: Boolean) {}

        internal fun executeTask(block: suspend CoroutineScope.() -> Unit): Job? = null
    }

    class DelayedTaskQueue {
        private var queueInitialTasks = false

        internal val taskQueue: ConcurrentLinkedQueue<() -> Unit> = ConcurrentLinkedQueue()

        fun launch(
            block: () -> Unit,
        ) {}

        internal fun flushQueuedInitialTasks() {}

        @Synchronized
        private fun addTaskToQueue(block: () -> Unit) {}
    }

    private val supervisorJob = SupervisorJob()

    @OptIn(kotlinx.coroutines.DelicateCoroutinesApi::class, kotlinx.coroutines.ExperimentalCoroutinesApi::class)
    var API = WaitableCoroutineScope(
        CoroutineScope(
            newSingleThreadContext("GleanAPIPool") + supervisorJob,
        ),
    )

    @OptIn(kotlinx.coroutines.DelicateCoroutinesApi::class, kotlinx.coroutines.ExperimentalCoroutinesApi::class)
    var Delayed = DelayedTaskQueue()
}
