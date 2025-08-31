/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean.debug

import android.app.Activity
import android.content.ComponentName
import android.os.Bundle

class GleanDebugActivity : Activity() {
    companion object {
        const val SEND_PING_EXTRA_KEY = "sendPing"

        const val LOG_PINGS_EXTRA_KEY = "logPings"

        const val TAG_DEBUG_VIEW_EXTRA_KEY = "debugViewTag"

        const val SOURCE_TAGS_KEY = "sourceTags"

        const val NEXT_ACTIVITY_TO_RUN = "startNext"
    }

    private fun isActivityExported(targetActivity: ComponentName): Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {}
}
