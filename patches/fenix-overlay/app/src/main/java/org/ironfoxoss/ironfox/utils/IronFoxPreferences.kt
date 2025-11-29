package org.ironfoxoss.ironfox.utils

import android.content.Context
import mozilla.components.concept.engine.EngineSession
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.ext.settings

object IronFoxPreferences {

    /**
     * Set whether to enable JavaScript Just-in-time compilation preferences.
     *
     * @param context The application context.
     * @param isEnabled Whether to enable JavaScript Just-in-time compilation.
     */
    fun setJavascriptJitEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()
        val components = context.components

        settings.javascriptJitEnabled = isEnabled

        components.core.engine.settings.javascriptJitBaselineEnabled = isEnabled
        components.core.engine.settings.javascriptJitHintsEnabled = isEnabled
        components.core.engine.settings.javascriptJitIonEnabled = isEnabled
        components.core.engine.settings.javascriptJitIonWasmEnabled = isEnabled
        components.core.engine.settings.javascriptJitNativeRegexpEnabled = isEnabled
        components.core.engine.settings.javascriptJitTrustedPrincipalsEnabled = isEnabled
    }

    /**
     * Check if JavaScript Just-in-time compilation is enabled.
     */
    fun isJavascriptJitEnabled(
        context: Context
    ): Boolean = context.settings().javascriptJitEnabled

    /**
     * Set whether to enable Safe Browsing preferences.
     *
     * @param context The application context.
     * @param isEnabled Whether to enable Safe Browsing.
     */
    fun setSafeBrowsingEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val engineSettings = context.components.core.engine.settings
        val settings = context.settings()
        val components = context.components

        settings.safeBrowsingEnabled = isEnabled

        if (settings.safeBrowsingEnabled) {
            engineSettings.safeBrowsingPolicy = arrayOf(EngineSession.SafeBrowsingPolicy.RECOMMENDED)
        } else {
            engineSettings.safeBrowsingPolicy = arrayOf(EngineSession.SafeBrowsingPolicy.NONE)
        }
        context.components.useCases.sessionUseCases.reload()
    }

    /**
     * Check if Safe Browsing is enabled.
     */
    fun isSafeBrowsingEnabled(
        context: Context
    ): Boolean = context.settings().safeBrowsingEnabled

    /**
     * Set whether to enable the locale spoofing preference.
     *
     * @param context The application context.
     * @param isEnabled Whether to enable locale spoofing.
     */
    fun setLocaleSpoofingEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()
        val components = context.components
        settings.spoofEnglish = isEnabled
        components.core.engine.settings.spoofEnglish = isEnabled
    }

    /**
     * Check if locale spoofing is enabled.
     */
    fun isLocaleSpoofingEnabled(
        context: Context,
    ): Boolean = context.settings().spoofEnglish
}
