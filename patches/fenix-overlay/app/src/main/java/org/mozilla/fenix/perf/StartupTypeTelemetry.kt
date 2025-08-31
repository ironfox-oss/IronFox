/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.perf

import androidx.annotation.VisibleForTesting
import androidx.annotation.VisibleForTesting.Companion.NONE
import androidx.annotation.VisibleForTesting.Companion.PRIVATE
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import org.mozilla.fenix.perf.StartupPathProvider.StartupPath
import org.mozilla.fenix.perf.StartupStateProvider.StartupState

class StartupTypeTelemetry(
    private val startupStateProvider: StartupStateProvider,
    private val startupPathProvider: StartupPathProvider,
) {

    fun attachOnHomeActivityOnCreate(lifecycle: Lifecycle) {}

    private fun getTelemetryLabel(startupState: StartupState, startupPath: StartupPath): String = ""

    @VisibleForTesting(otherwise = NONE)
    fun getTestCallbacks() = StartupTypeLifecycleObserver()

    @VisibleForTesting(otherwise = PRIVATE)
    fun record(dispatcher: CoroutineDispatcher = Dispatchers.IO) {}

    @VisibleForTesting(otherwise = PRIVATE)
    inner class StartupTypeLifecycleObserver : DefaultLifecycleObserver {
        private var shouldRecordStart = false

        override fun onStart(owner: LifecycleOwner) {}

        override fun onResume(owner: LifecycleOwner) {}
    }
}
