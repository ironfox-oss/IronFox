package org.ironfoxoss.ironfox.utils

import android.content.Context
import org.mozilla.fenix.ext.settings

object IronFoxPreferences {

    /**
     * Set whether to disable WebGL
     *
     * @param context The application context
     * @param isDisabled Whether to disable WebGL
     */
    fun setWebGLDisabled(
        context: Context,
        isDisabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.webglDisabled = isDisabled
    }

    /**
     * Check if WebGL is disabled
     *
     * @param context The application context
     */
    fun isWebGLDisabled(
        context: Context
    ): Boolean = context.settings().ironfox.webglDisabled

    /**
     * Set whether to enable support for Accessibility Services
     *
     * @param context The application context
     * @param isEnabled Whether to enable support for Accessibility Services
     */
    fun setAccessibilityEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.accessibilityEnabled = isEnabled
    }

    /**
     * Check if support for Accessibility Services is enabled
     *
     * @param context The application context
     */
    fun isAccessibilityEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.accessibilityEnabled

    /**
     * Set whether to enable JavaScript
     *
     * @param context The application context
     * @param isEnabled Whether to enable JavaScript
     */
    fun setJavaScriptEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.javascriptEnabled = isEnabled
    }

    /**
     * Check if JavaScript is enabled
     *
     * @param context The application context
     */
    fun isJavaScriptEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.javascriptEnabled

    /**
     * Set whether to enable our WebGL overrides
     *
     * @param context The application context
     * @param isEnabled Whether to enable our WebGL overrides
     */
    fun setFPPOverridesIronFoxWebGLEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.fppOverridesIronFoxWebGLEnabled = isEnabled
    }

    /**
     * Check if our WebGL overrides are enabled
     *
     * @param context The application context
     */
    fun isFPPOverridesIronFoxWebGLEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.fppOverridesIronFoxWebGLEnabled

    /**
     * Set whether to always use private browsing mode
     *
     * @param context The application context
     * @param isEnabled Whether to always use private browsing mode
     */
    fun setAlwaysUsePrivateBrowsing(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.alwaysUsePrivateBrowsing = isEnabled
        settings.showHomepageHeader = !isEnabled

        if (isEnabled) {
            // Set this to ensure that the user's choice sticks if they enable always private browsing mode and disable it later
            settings.ironfox.openLinksInAPrivateTabCachedValue = settings.openLinksInAPrivateTab
            settings.openLinksInAPrivateTab = isEnabled
        } else {
            settings.openLinksInAPrivateTab = settings.ironfox.openLinksInAPrivateTabCachedValue
        }
    }

    /**
     * Check if we should always use private browsing mode
     *
     * @param context The application context
     */
    fun isAlwaysUsePrivateBrowsing(
        context: Context
    ): Boolean = context.settings().ironfox.alwaysUsePrivateBrowsing

    /**
     * Set whether to enable disk cache
     *
     * @param context The application context
     * @param isEnabled Whether to enable disk cache
     */
    fun setCacheEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.cacheEnabled = isEnabled
    }

    /**
     * Check if disk cache is enabled
     *
     * @param context The application context
     */
    fun isCacheEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.cacheEnabled

    /**
     * Set whether to enable our fingerprinting protection overrides
     *
     * @param context The application context
     * @param isEnabled Whether to enable our fingerprinting protection overrides
     */
    fun setFPPOverridesIronFoxEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.fppOverridesIronFoxEnabled = isEnabled
    }

    /**
     * Check if our fingerprinting protection overrides are enabled
     *
     * @param context The application context
     */
    fun isFPPOverridesIronFoxEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.fppOverridesIronFoxEnabled

    /**
     * Set whether to enable Mozilla's fingerprinting protection overrides
     *
     * @param context The application context
     * @param isEnabled Whether to enable Mozilla's fingerprinting protection overrides
     */
    fun setFPPOverridesMozillaEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.fppOverridesMozillaEnabled = isEnabled
    }

    /**
     * Check if Mozilla's fingerprinting protection overrides are enabled
     *
     * @param context The application context
     */
    fun isFPPOverridesMozillaEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.fppOverridesMozillaEnabled

    /**
     * Set whether to enable our timezone spoofing overrides
     *
     * @param context The application context
     * @param isEnabled Whether to enable our timezone spoofing overrides
     */
    fun setFPPOverridesIronFoxTimezoneEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.fppOverridesIronFoxTimezoneEnabled = isEnabled
    }

    /**
     * Check if our timezone spoofing overrides are enabled
     *
     * @param context The application context
     */
    fun isFPPOverridesIronFoxTimezoneEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.fppOverridesIronFoxTimezoneEnabled

    /**
     * Set whether to enable locale spoofing
     *
     * @param context The application context
     * @param isEnabled Whether to enable locale spoofing
     */
    fun setSpoofEnglishEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.spoofEnglish = isEnabled
    }

    /**
     * Check if locale spoofing is enabled
     *
     * @param context The application context
     */
    fun isSpoofEnglishEnabled(
        context: Context,
    ): Boolean = context.settings().ironfox.spoofEnglish

    /**
     * Set whether to enable timezone spoofing
     *
     * @param context The application context
     * @param isEnabled Whether to enable timezone spoofing
     */
    fun setSpoofTimezoneEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.spoofTimezone = isEnabled
    }

    /**
     * Check if timezone spoofing is enabled
     *
     * @param context The application context
     */
    fun isSpoofTimezoneEnabled(
        context: Context,
    ): Boolean = context.settings().ironfox.spoofTimezone

    /**
     * Set whether to enable add-on installation
     *
     * @param context The application context
     * @param isEnabled Whether to enable add-on installation
     */
    fun setXPInstallEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.xpinstallEnabled = isEnabled
    }

    /**
     * Check if add-on installation is enabled
     *
     * @param context The application context
     */
    fun isXPInstallEnabled(
        context: Context,
    ): Boolean = context.settings().ironfox.xpinstallEnabled

    /**
     * Set whether to enable JavaScript Just-in-time compilation (JIT)
     *
     * @param context The application context
     * @param isEnabled Whether to enable JIT
     */
    fun setJITEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.javascriptJitEnabled = isEnabled
    }

    /**
     * Check if JavaScript Just-in-time compilation (JIT) is enabled
     *
     * @param context The application context
     */
    fun isJITEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.javascriptJitEnabled

    /**
     * Set whether to enable JavaScript Just-in-time compilation (JIT) for extensions
     * (if JIT is otherwise disabled globally)
     *
     * @param context The application context
     * @param isEnabled Whether to enable JIT
     */
    fun setJITTrustedPrincipalsEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.javascriptJitTrustedPrincipalsEnabled = isEnabled
    }

    /**
     * Check if JavaScript Just-in-time compilation (JIT) for extensions is enabled
     * (if JIT is otherwise disabled globally)
     *
     * @param context The application context
     */
    fun isJITTrustedPrincipalsEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.javascriptJitTrustedPrincipalsEnabled

    /**
     * Set whether to enable printing capabilities
     *
     * @param context The application context
     * @param isEnabled Whether to enable printing capabilities
     */
    fun setPrintEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.printEnabled = isEnabled
    }

    /**
     * Check if printing capabilities are enabled
     *
     * @param context The application context
     */
    fun isPrintEnabled(
        context: Context,
    ): Boolean = context.settings().ironfox.printEnabled

    /**
     * Set whether to enable Safe Browsing
     *
     * @param context The application context
     * @param isEnabled Whether to enable Safe Browsing
     */
    fun setSafeBrowsingEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.safeBrowsingEnabled = isEnabled
    }

    /**
     * Check if Safe Browsing is enabled
     *
     * @param context The application context
     */
    fun isSafeBrowsingEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.safeBrowsingEnabled

    /**
     * Set whether to enable Scalar Vector Graphics (SVG)
     *
     * @param context The application context
     * @param isEnabled Whether to enable SVG
     */
    fun setSVGEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.svgEnabled = isEnabled
    }

    /**
     * Check if Scalar Vector Graphics (SVG) is enabled
     *
     * @param context The application context
     */
    fun isSVGEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.svgEnabled

    /**
     * Set whether to enable WebAssembly (WASM)
     *
     * @param context The application context
     * @param isEnabled Whether to enable WASM
     */
    fun setWASMEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.wasmEnabled = isEnabled
    }

    /**
     * Check if WebAssembly (WASM) is enabled
     *
     * @param context The application context
     */
    fun isWASMEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.wasmEnabled

    /**
     * Set whether to enable WebRTC globally
     *
     * @param context The application context
     * @param isEnabled Whether to enable WebRTC globally
     */
    fun setWebRTCEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.webrtcEnabled = isEnabled
    }

    /**
     * Check if WebRTC is enabled globally
     *
     * @param context The application context
     */
    fun isWebRTCEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.webrtcEnabled

    /**
     * Set whether to enable collections
     *
     * @param context The application context
     * @param isEnabled Whether to enable collections
     */
    fun setCollectionsEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.collections = isEnabled
    }

    /**
     * Check if collections are enabled
     *
     * @param context The application context
     */
    fun isCollectionsEnabled(
        context: Context
    ): Boolean = context.settings().collections

    /**
     * Set whether to enable Firefox Translations
     *
     * @param context The application context
     * @param isEnabled Whether to enable Firefox Translations
     */
    fun setTranslationsEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.translationsEnabled = isEnabled
    }

    /**
     * Check if Firefox Translations is enabled
     *
     * @param context The application context
     */
    fun isTranslationsEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.translationsEnabled

    /**
     * Set whether to enable IPv6 network connectivity
     *
     * @param context The application context
     * @param isEnabled Whether to enable IPv6 network connectivity
     */
    fun setIPv6Enabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.ipv6Enabled = isEnabled
    }

    /**
     * Check if IPv6 network connectivity is enabled
     *
     * @param context The application context
     */
    fun isIPv6Enabled(
        context: Context
    ): Boolean = context.settings().ironfox.ipv6Enabled

    /**
     * Set whether to disable PDF.js
     *
     * @param context The application context
     * @param isDisabled Whether to disable PDF.js
     */
    fun setPDFjsDisabled(
        context: Context,
        isDisabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.pdfjsDisabled = isDisabled
    }

    /**
     * Check if PDF.js is disabled
     *
     * @param context The application context
     */
    fun isPDFjsDisabled(
        context: Context
    ): Boolean = context.settings().ironfox.pdfjsDisabled

    /**
     * Set whether to enable support for UnifiedPush
     *
     * @param context The application context
     * @param isEnabled Whether to enable support for UnifiedPush
     */
    fun setUnifiedPushEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.enableUnifiedPush = isEnabled
    }

    /**
     * Check if support for UnifiedPush is enabled
     *
     * @param context The application context
     */
    fun isUnifiedPushEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.enableUnifiedPush

    /**
     * Set whether we should use UnifiedPush to deliver push notifications
     *
     * @param context The application context
     * @param isEnabled Whether we should use UnifiedPush to deliver push notifications
     */
    fun setUseUnifiedPush(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.useUnifiedPush = isEnabled
    }

    /**
     * Check if we should use UnifiedPush to deliver push notifications
     *
     * @param context The application context
     */
    fun shouldUseUnifiedPush(
        context: Context
    ): Boolean = context.settings().ironfox.useUnifiedPush

    /**
     * Set whether to enable Encrypted Media Extensions (EME)
     *
     * @param context The application context
     * @param isEnabled Whether to enable EME
     */
    fun setEMEEnabled(
        context: Context,
        isEnabled: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.emeEnabled = isEnabled
    }

    /**
     * Check if Encrypted Media Extensions (EME) is enabled
     *
     * @param context The application context
     */
    fun isEMEEnabled(
        context: Context
    ): Boolean = context.settings().ironfox.emeEnabled

    /**
     * Set whether the onboarding has been completed
     *
     * @param context The application context
     * @param isCompleted Whether the onboarding has been completed
     */
    fun setIronFoxOnboardingCompleted(
        context: Context,
        isCompleted: Boolean,
    ) {
        val settings = context.settings()

        settings.ironfox.ironFoxOnboardingCompleted = isCompleted
    }

    /**
     * Check if the onboarding has been completed
     *
     * @param context The application context
     */
    fun isIronFoxOnboardingCompleted(
        context: Context
    ): Boolean = context.settings().ironfox.ironFoxOnboardingCompleted
}
