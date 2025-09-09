/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.perf

import android.view.View
import mozilla.components.support.utils.RunWhenReadyQueue
import mozilla.components.support.utils.SafeIntent

class ColdStartupDurationTelemetry {

    fun onHomeActivityOnCreate(
        visualCompletenessQueue: RunWhenReadyQueue,
        startupStateProvider: StartupStateProvider,
        safeIntent: SafeIntent,
        rootContainer: View,
    ) {
        return
    }

    private fun recordColdStartupTelemetry(safeIntent: SafeIntent, firstFrameNanos: Long) {}
}
