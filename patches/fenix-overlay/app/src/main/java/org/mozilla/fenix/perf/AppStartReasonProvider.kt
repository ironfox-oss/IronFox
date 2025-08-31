/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.perf

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import org.mozilla.fenix.android.DefaultActivityLifecycleCallbacks
import org.mozilla.fenix.perf.AppStartReasonProvider.StartReason

class AppStartReasonProvider {

    enum class StartReason {
        TO_BE_DETERMINED,

        ACTIVITY,

        NON_ACTIVITY,
    }

    var reason = StartReason.TO_BE_DETERMINED
        private set

    fun registerInAppOnCreate(application: Application) {}

    private inner class ProcessLifecycleObserver : DefaultLifecycleObserver {
        override fun onCreate(owner: LifecycleOwner) {}
    }

    private inner class ActivityLifecycleCallbacks : DefaultActivityLifecycleCallbacks {
        override fun onActivityCreated(activity: Activity, bundle: Bundle?) {}
    }
}
