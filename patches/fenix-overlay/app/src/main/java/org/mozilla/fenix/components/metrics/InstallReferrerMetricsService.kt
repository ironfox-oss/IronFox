/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components.metrics

import android.content.Context
import org.mozilla.fenix.ext.settings
import org.mozilla.fenix.utils.Settings

class InstallReferrerMetricsService(private val context: Context) : MetricsService {
    override val type = MetricServiceType.Data

    override fun start() {
    }

    override fun stop() {
    }

    override fun track(event: Event) = Unit

    override fun shouldTrack(event: Event): Boolean = false
}

data class UTMParams(
    val source: String,
    val medium: String,
    val campaign: String,
    val content: String,
    val term: String,
) {

    companion object {
        const val UTM_SOURCE = "utm_source"
        const val UTM_MEDIUM = "utm_medium"
        const val UTM_CAMPAIGN = "utm_campaign"
        const val UTM_CONTENT = "utm_content"
        const val UTM_TERM = "utm_term"

        fun parseUTMParameters(installReferrerResponse: String): UTMParams {
            return UTMParams(
                source = "",
                medium = "",
                campaign = "",
                content = "",
                term = "",
            )
        }

        fun fromSettings(settings: Settings): UTMParams =
            UTMParams(
                source = "",
                medium = "",
                campaign = "",
                content = "",
                term = "",
            )
    }

    fun intoSettings(settings: Settings) {
    }

    fun isEmpty(): Boolean {
        return true
    }

    fun recordInstallReferrer(settings: Settings) {
        return
    }
}

data class MetaParams(
    val app: String,
    val t: String,
    val data: String,
    val nonce: String,
) {
    companion object {
        private const val APP = "app"
        private const val T = "t"
        private const val SOURCE = "source"
        private const val DATA = "data"
        private const val NONCE = "nonce"
    }

    fun recordMetaAttribution() {
        return
    }
}
