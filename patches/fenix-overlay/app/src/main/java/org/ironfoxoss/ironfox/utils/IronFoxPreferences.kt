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

        settings.webglDisabled = isDisabled
    }

    /**
     * Check if WebGL is disabled
     *
     * @param context The application context
     */
    fun isWebGLDisabled(
        context: Context
    ): Boolean = context.settings().webglDisabled

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

        settings.accessibilityEnabled = isEnabled
    }

    /**
     * Check if support for Accessibility Services is enabled
     *
     * @param context The application context
     */
    fun isAccessibilityEnabled(
        context: Context
    ): Boolean = context.settings().accessibilityEnabled

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

        settings.javascriptEnabled = isEnabled
    }

    /**
     * Check if JavaScript is enabled
     *
     * @param context The application context
     */
    fun isJavaScriptEnabled(
        context: Context
    ): Boolean = context.settings().javascriptEnabled

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

        settings.fppOverridesIronFoxWebGLEnabled = isEnabled
    }

    /**
     * Check if our WebGL overrides are enabled
     *
     * @param context The application context
     */
    fun isFPPOverridesIronFoxWebGLEnabled(
        context: Context
    ): Boolean = context.settings().fppOverridesIronFoxWebGLEnabled

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

        settings.alwaysUsePrivateBrowsing = isEnabled
        settings.showHomepageHeader = !isEnabled

        if (isEnabled) {
            // Set this to ensure that the user's choice sticks if they enable always private browsing mode and disable it later
            settings.openLinksInAPrivateTabCachedValue = settings.openLinksInAPrivateTab
            settings.openLinksInAPrivateTab = isEnabled
        } else {
            settings.openLinksInAPrivateTab = settings.openLinksInAPrivateTabCachedValue
        }
    }

    /**
     * Check if we should always use private browsing mode
     *
     * @param context The application context
     */
    fun isAlwaysUsePrivateBrowsing(
        context: Context
    ): Boolean = context.settings().alwaysUsePrivateBrowsing

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

        settings.cacheEnabled = isEnabled
    }

    /**
     * Check if disk cache is enabled
     *
     * @param context The application context
     */
    fun isCacheEnabled(
        context: Context
    ): Boolean = context.settings().cacheEnabled

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

        settings.fppOverridesIronFoxEnabled = isEnabled
    }

    /**
     * Check if our fingerprinting protection overrides are enabled
     *
     * @param context The application context
     */
    fun isFPPOverridesIronFoxEnabled(
        context: Context
    ): Boolean = context.settings().fppOverridesIronFoxEnabled

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

        settings.fppOverridesMozillaEnabled = isEnabled
    }

    /**
     * Check if Mozilla's fingerprinting protection overrides are enabled
     *
     * @param context The application context
     */
    fun isFPPOverridesMozillaEnabled(
        context: Context
    ): Boolean = context.settings().fppOverridesMozillaEnabled

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

        settings.fppOverridesIronFoxTimezoneEnabled = isEnabled
    }

    /**
     * Check if our timezone spoofing overrides are enabled
     *
     * @param context The application context
     */
    fun isFPPOverridesIronFoxTimezoneEnabled(
        context: Context
    ): Boolean = context.settings().fppOverridesIronFoxTimezoneEnabled

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

        settings.spoofEnglish = isEnabled
    }

    /**
     * Check if locale spoofing is enabled
     *
     * @param context The application context
     */
    fun isSpoofEnglishEnabled(
        context: Context,
    ): Boolean = context.settings().spoofEnglish

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

        settings.spoofTimezone = isEnabled
    }

    /**
     * Check if timezone spoofing is enabled
     *
     * @param context The application context
     */
    fun isSpoofTimezoneEnabled(
        context: Context,
    ): Boolean = context.settings().spoofTimezone

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

        settings.xpinstallEnabled = isEnabled
    }

    /**
     * Check if add-on installation is enabled
     *
     * @param context The application context
     */
    fun isXPInstallEnabled(
        context: Context,
    ): Boolean = context.settings().xpinstallEnabled

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

        settings.javascriptJitEnabled = isEnabled
    }

    /**
     * Check if JavaScript Just-in-time compilation (JIT) is enabled
     *
     * @param context The application context
     */
    fun isJITEnabled(
        context: Context
    ): Boolean = context.settings().javascriptJitEnabled

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

        settings.javascriptJitTrustedPrincipalsEnabled = isEnabled
    }

    /**
     * Check if JavaScript Just-in-time compilation (JIT) for extensions is enabled
     * (if JIT is otherwise disabled globally)
     *
     * @param context The application context
     */
    fun isJITTrustedPrincipalsEnabled(
        context: Context
    ): Boolean = context.settings().javascriptJitTrustedPrincipalsEnabled

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

        settings.printEnabled = isEnabled
    }

    /**
     * Check if printing capabilities are enabled
     *
     * @param context The application context
     */
    fun isPrintEnabled(
        context: Context,
    ): Boolean = context.settings().printEnabled

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

        settings.safeBrowsingEnabled = isEnabled
    }

    /**
     * Check if Safe Browsing is enabled
     *
     * @param context The application context
     */
    fun isSafeBrowsingEnabled(
        context: Context
    ): Boolean = context.settings().safeBrowsingEnabled

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

        settings.svgEnabled = isEnabled
    }

    /**
     * Check if Scalar Vector Graphics (SVG) is enabled
     *
     * @param context The application context
     */
    fun isSVGEnabled(
        context: Context
    ): Boolean = context.settings().svgEnabled

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

        settings.wasmEnabled = isEnabled
    }

    /**
     * Check if WebAssembly (WASM) is enabled
     *
     * @param context The application context
     */
    fun isWASMEnabled(
        context: Context
    ): Boolean = context.settings().wasmEnabled

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

        settings.webrtcEnabled = isEnabled
    }

    /**
     * Check if WebRTC is enabled globally
     *
     * @param context The application context
     */
    fun isWebRTCEnabled(
        context: Context
    ): Boolean = context.settings().webrtcEnabled

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

        settings.translationsEnabled = isEnabled
    }

    /**
     * Check if Firefox Translations is enabled
     *
     * @param context The application context
     */
    fun isTranslationsEnabled(
        context: Context
    ): Boolean = context.settings().translationsEnabled

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

        settings.ipv6Enabled = isEnabled
    }

    /**
     * Check if IPv6 network connectivity is enabled
     *
     * @param context The application context
     */
    fun isIPv6Enabled(
        context: Context
    ): Boolean = context.settings().ipv6Enabled

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

        settings.pdfjsDisabled = isDisabled
    }

    /**
     * Check if PDF.js is disabled
     *
     * @param context The application context
     */
    fun isPDFjsDisabled(
        context: Context
    ): Boolean = context.settings().pdfjsDisabled

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

        settings.enableUnifiedPush = isEnabled
    }

    /**
     * Check if support for UnifiedPush is enabled
     *
     * @param context The application context
     */
    fun isUnifiedPushEnabled(
        context: Context
    ): Boolean = context.settings().enableUnifiedPush

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

        settings.useUnifiedPush = isEnabled
    }

    /**
     * Check if we should use UnifiedPush to deliver push notifications
     *
     * @param context The application context
     */
    fun shouldUseUnifiedPush(
        context: Context
    ): Boolean = context.settings().useUnifiedPush

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

        settings.emeEnabled = isEnabled
    }

    /**
     * Check if Encrypted Media Extensions (EME) is enabled
     *
     * @param context The application context
     */
    fun isEMEEnabled(
        context: Context
    ): Boolean = context.settings().emeEnabled

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

        settings.ironFoxOnboardingCompleted = isCompleted
    }

    /**
     * Check if the onboarding has been completed
     *
     * @param context The application context
     */
    fun isIronFoxOnboardingCompleted(
        context: Context
    ): Boolean = context.settings().ironFoxOnboardingCompleted
}
