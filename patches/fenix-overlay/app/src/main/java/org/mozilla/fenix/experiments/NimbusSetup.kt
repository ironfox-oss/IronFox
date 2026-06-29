/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.experiments

import android.content.Context
import mozilla.appservices.remotesettings.RemoteSettingsService
import mozilla.components.service.nimbus.NimbusApi
import mozilla.components.service.nimbus.NimbusAppInfo
import mozilla.components.service.nimbus.NimbusBuilder
import org.json.JSONObject
import org.mozilla.experiments.nimbus.internal.NimbusServerSettings
import org.mozilla.fenix.R
import org.mozilla.fenix.ext.settings

fun createNimbus(context: Context, urlString: String?, remoteSettingsService: RemoteSettingsService?, geckoPrefHandler: Any?): NimbusApi {
  val serverSettings: NimbusServerSettings? = remoteSettingsService?.let { service ->
    NimbusServerSettings(
      rsService = service,
      collectionName = "noop",
    )
  }

  val appInfo = NimbusAppInfo(
    appName = "fenix",
    channel = "release",
    customTargetingAttributes = JSONObject(),
  )

  return NimbusBuilder(context).apply {
    url = null
    errorReporter = context::reportError
    initialExperiments = R.raw.initial_experiments
    timeoutLoadingExperiment = 200L
    sharedPreferences = context.settings().preferences
    isFirstRun = true
    featureManifest = null
    onFetchCallback = {}
    recordedContext = null
    this.geckoPrefHandler = null
  }.build(appInfo, serverSettings)
}

private fun Context.reportError(message: String, e: Throwable) {}
