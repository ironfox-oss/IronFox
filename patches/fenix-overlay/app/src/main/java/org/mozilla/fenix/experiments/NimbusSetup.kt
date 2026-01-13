/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.experiments

import android.content.Context
import mozilla.components.service.nimbus.NimbusApi
import mozilla.components.service.nimbus.NimbusAppInfo
import mozilla.components.service.nimbus.NimbusBuilder
import org.json.JSONObject

fun createNimbus(context: Context, urlString: String?, remoteSettingsService: Any?): NimbusApi {
    val serverSettings = null

    val appInfo = NimbusAppInfo(
        appName = "",
        channel = "",
        customTargetingAttributes = JSONObject(),
    )

    return NimbusBuilder(context).apply {
        url = null
        errorReporter = context::reportError
        initialExperiments = null
        timeoutLoadingExperiment = 200L
        sharedPreferences = null
        isFirstRun = true
        featureManifest = null
        onFetchCallback = {}
        recordedContext = null
    }.build(appInfo, serverSettings)
}

private fun Context.reportError(message: String, e: Throwable) {}
