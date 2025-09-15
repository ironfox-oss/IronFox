/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.experiments

import android.content.Context
import mozilla.components.service.nimbus.NimbusApi
import mozilla.components.service.nimbus.NimbusAppInfo
import mozilla.components.service.nimbus.NimbusBuilder
import org.json.JSONObject

fun createNimbus(context: Context, urlString: String?): NimbusApi {
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
        usePreviewCollection = false
        sharedPreferences = null
        isFirstRun = true
        featureManifest = null
        onFetchCallback = {}
        recordedContext = null
    }.build(appInfo)
}

private fun Context.reportError(message: String, e: Throwable) {}
