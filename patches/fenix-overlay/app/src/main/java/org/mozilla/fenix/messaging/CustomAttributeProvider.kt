/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.messaging

import android.content.Context
import mozilla.components.service.nimbus.messaging.JexlAttributeProvider
import org.json.JSONObject
import org.mozilla.fenix.ext.settings
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

object CustomAttributeProvider : JexlAttributeProvider {
    private val formatter = SimpleDateFormat("yyyy-MM-dd", Locale.US)

    fun getCustomTargetingAttributes(context: Context): JSONObject {
        val settings = context.settings()
        val isFirstRun = settings.isFirstNimbusRun
        return JSONObject()
    }

    override fun getCustomAttributes(context: Context): JSONObject {
        val now = Calendar.getInstance()
        val settings = context.settings()
        return JSONObject()
    }
}
