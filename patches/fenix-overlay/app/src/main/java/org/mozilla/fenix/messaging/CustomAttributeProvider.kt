/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.messaging

import android.content.Context
import mozilla.components.service.nimbus.messaging.JexlAttributeProvider
import org.json.JSONObject

object CustomAttributeProvider : JexlAttributeProvider {
    fun getCustomTargetingAttributes(context: Context): JSONObject {
        return JSONObject()
    }

    override fun getCustomAttributes(context: Context): JSONObject {
        return JSONObject()
    }
}
