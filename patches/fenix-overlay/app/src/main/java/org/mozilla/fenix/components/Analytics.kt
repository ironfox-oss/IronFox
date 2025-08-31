/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components

import android.content.Context
import mozilla.components.lib.crash.CrashReporter
import mozilla.components.support.utils.RunWhenReadyQueue
import org.ironfoxoss.ironfox.NoopCrashService
import org.mozilla.fenix.components.metrics.DefaultMetricsStorage
import org.mozilla.fenix.components.metrics.MetricController
import org.mozilla.fenix.components.metrics.MetricsStorage
import org.mozilla.fenix.crashes.CrashFactCollector
import org.mozilla.fenix.ext.settings
import org.mozilla.fenix.perf.lazyMonitored

class Analytics(
    private val context: Context,
    private val runWhenReadyQueue: RunWhenReadyQueue,
) {
    val crashReporter: CrashReporter by lazyMonitored {
        CrashReporter(
            context = context,
            services = listOf(NoopCrashService()),
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

    val crashFactCollector: CrashFactCollector by lazyMonitored {
        CrashFactCollector(crashReporter)
    }

    val metricsStorage: MetricsStorage by lazyMonitored {
        DefaultMetricsStorage(
            context = context,
            settings = context.settings(),
            checkDefaultBrowser = { false },
        )
    }

    val metrics: MetricController by lazyMonitored {
        MetricController.create(
            listOf(),
            isDataTelemetryEnabled = { false },
            isMarketingDataTelemetryEnabled = { false },
            isUsageTelemetryEnabled = { false },
            context.settings(),
        )
    }
}

private fun isSentryEnabled() = false

private fun getSentryProjectUrl(): String? = null
