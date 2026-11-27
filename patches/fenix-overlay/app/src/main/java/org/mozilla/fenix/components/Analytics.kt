/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components

import android.content.Context
import mozilla.components.lib.crash.CrashReporter

class Analytics(
  private val context: Context,
  private val settings: Any?,
  private val nimbusComponents: Any?,
  private val runWhenReadyQueue: Any?,
  val buildMetadata: Any?,
) {
  val crashReporter: CrashReporter by lazy {
    CrashReporter(
      context = context,
      services = listOf(),
      telemetryServices = listOf(),
      shouldPrompt = CrashReporter.Prompt.ALWAYS,
      promptConfiguration = CrashReporter.PromptConfiguration(
        appName = "",
        organizationName = "",
      ),
      enabled = false,
      nonFatalCrashIntent = null,
      useLegacyReporting = false,
      runtimeTagProviders = listOf(),
    )
  }

  val metrics = {}
}
