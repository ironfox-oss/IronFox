/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean.scheduler

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner

internal class GleanLifecycleObserver : LifecycleEventObserver {
    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {}
}
