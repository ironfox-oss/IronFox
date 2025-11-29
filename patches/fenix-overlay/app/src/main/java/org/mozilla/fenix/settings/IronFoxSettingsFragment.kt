package org.mozilla.fenix.settings

import android.content.DialogInterface
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.navigation.NavDirections
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.preference.Preference
import androidx.preference.PreferenceCategory
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.SwitchPreference
import kotlin.system.exitProcess
import mozilla.components.concept.engine.EngineSession
import mozilla.components.ui.widgets.withCenterAlignedButtons
import org.ironfoxoss.ironfox.utils.IronFoxPreferences
import org.mozilla.fenix.components.Push
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.ext.getPreferenceKey
import org.mozilla.fenix.ext.requireComponents
import org.mozilla.fenix.ext.settings
import org.mozilla.fenix.ext.showToolbar
import org.mozilla.fenix.R
import org.mozilla.fenix.utils.view.addToRadioGroup

@Suppress("TooManyFunctions")
class IronFoxSettingsFragment : PreferenceFragmentCompat() {
    private lateinit var radioAutoplayBlockingSticky: RadioButtonPreference
    private lateinit var radioAutoplayBlockingTransient: RadioButtonPreference
    private lateinit var radioAutoplayBlockingClickToPlay: RadioButtonPreference
    private lateinit var radioPrefersLightColorScheme: RadioButtonPreference
    private lateinit var radioPrefersDarkColorScheme: RadioButtonPreference
    private lateinit var radioPrefersBrowserColorScheme: RadioButtonPreference
    private lateinit var radioRefererXOriginAlways: RadioButtonPreference
    private lateinit var radioRefererXOriginBaseDomainsMatch: RadioButtonPreference
    private lateinit var radioRefererXOriginHostsMatch: RadioButtonPreference

    override fun onResume() {
        super.onResume()
        showToolbar(getString(R.string.if_preferences))

        /*** Privacy and Security ***/

        /**
         * Indicates whether or not we should disable WebGL
         * Default: true
         * Gecko preference(s) impacted: webgl.disabled
         */
        val webglDisabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_webgl_disabled,
        )

        webglDisabledPreference.setOnPreferenceChangeListener { preference, webglDisabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.webglDisabled = webglDisabled as Boolean
            components.core.engine.settings.webglDisabled = webglDisabled

            true
        }

        /**
         * Indicates whether or not we should enable Accessibility Services
         * Default: false
         * Gecko preference(s) impacted: accessibility.force_disabled
         */
        val accessibilityEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_accessibility_enabled,
        )

        accessibilityEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, accessibilityEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.accessibilityEnabled = accessibilityEnabled
            components.core.engine.settings.accessibilityEnabled = accessibilityEnabled

            true
        }

        /**
         * Indicates whether or not we should enable JavaScript
         * Default: true
         * Gecko preference(s) impacted: javascript.enabled
         */
        val javascriptEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_javascript_enabled,
        )

        javascriptEnabledPreference.setOnPreferenceChangeListener { preference, javascriptEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.javascriptEnabled = javascriptEnabled as Boolean
            components.core.engine.settings.javascriptEnabled = javascriptEnabled

            true
        }

        /**
         * Indicates whether or not we should enable our WebGL overrides
         * Default: true
         * Gecko preference(s) impacted: browser.ironfox.fingerprintingProtection.unbreakWebGLOverrides.enabled
         */
        val fppOverridesIronFoxWebGLEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_fpp_overrides_ironfox_webgl_enabled,
        )

        fppOverridesIronFoxWebGLEnabledPreference.setOnPreferenceChangeListener { preference, fppOverridesIronFoxWebGLEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.fppOverridesIronFoxWebGLEnabled = fppOverridesIronFoxWebGLEnabled as Boolean
            components.core.engine.settings.fppOverridesIronFoxWebGLEnabled = fppOverridesIronFoxWebGLEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /*** Privacy ***/

        /**
         * Indicates whether or not we should enable disk cache
         * Default: false
         * Gecko preference(s) impacted: browser.cache.disk.enable
         */
        val cacheEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_cache_enabled,
        )

        cacheEnabledPreference.setOnPreferenceChangeListener { preference, cacheEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.cacheEnabled = cacheEnabled as Boolean
            components.core.engine.settings.cacheEnabled = cacheEnabled

            true
        }

        /**
         * Indicates whether or not we should enable our fingerprinting protection overrides
         * Default: true
         * Gecko preference(s) impacted: browser.ironfox.fingerprintingProtection.unbreakOverrides.enabled
         */
        val fppOverridesIronFoxEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_fpp_overrides_ironfox_enabled,
        )

        fppOverridesIronFoxEnabledPreference.setOnPreferenceChangeListener { preference, fppOverridesIronFoxEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.fppOverridesIronFoxEnabled = fppOverridesIronFoxEnabled as Boolean
            components.core.engine.settings.fppOverridesIronFoxEnabled = fppOverridesIronFoxEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
         * Indicates whether or not we should enable Mozilla's fingerprinting protection overrides
         * Default: true
         * Gecko preference(s) impacted: privacy.fingerprintingProtection.remoteOverrides.enabled
         */
        val fppOverridesMozillaEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_fpp_overrides_mozilla_enabled,
        )

        fppOverridesMozillaEnabledPreference.setOnPreferenceChangeListener { preference, fppOverridesMozillaEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.fppOverridesMozillaEnabled = fppOverridesMozillaEnabled as Boolean
            components.core.engine.settings.fppOverridesMozillaEnabled = fppOverridesMozillaEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
         * Indicates whether or not we should enable our timezone spoofing overrides
         * Default: true
         * Gecko preference(s) impacted: browser.ironfox.fingerprintingProtection.unbreakTimezoneOverrides.enabled
         */
        val fppOverridesIronFoxTimezoneEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_fpp_overrides_ironfox_timezone_enabled,
        )

        fppOverridesIronFoxTimezoneEnabledPreference.setOnPreferenceChangeListener { preference, fppOverridesIronFoxTimezoneEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.fppOverridesIronFoxTimezoneEnabled = fppOverridesIronFoxTimezoneEnabled as Boolean
            components.core.engine.settings.fppOverridesIronFoxTimezoneEnabled = fppOverridesIronFoxTimezoneEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
         * Indicates whether or not we should spoof the user's locale to en-US
         * Default: true
         * Gecko preference(s) impacted: privacy.spoof_english
         */
        val spoofEnglishPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_spoof_english,
        )

        spoofEnglishPreference.isChecked = IronFoxPreferences.isLocaleSpoofingEnabled(requireContext())
        spoofEnglishPreference.setOnPreferenceChangeListener { preference, spoofEnglish ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.spoofEnglish = spoofEnglish as Boolean
            components.core.engine.settings.spoofEnglish = spoofEnglish

            true
        }

        /**
         * Indicates whether or not we should spoof the user's timezone to UTC-0
         * Default: false
         * Gecko preference(s) impacted: browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled
         */
        val spoofTimezonePreference = requirePreference<SwitchPreference>(
            R.string.pref_key_spoof_timezone,
        )

        spoofTimezonePreference.setOnPreferenceChangeListener { preference, spoofTimezone ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.spoofTimezone = spoofTimezone as Boolean
            components.core.engine.settings.spoofTimezone = spoofTimezone

            true
        }

        /*** Security ***/

        /**
         * Indicates whether or not we should allow the installation of add-ons
         * Default: false
         * Gecko preference(s) impacted: xpinstall.enabled
         * (This also sets the InstallAddonsPermission policy (https://mozilla.github.io/policy-templates/#installaddonspermission), which is why we need to restart)
         */
        val xpinstallEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_xpinstall_enabled,
        )

        xpinstallEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, xpinstallEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.xpinstallEnabled = xpinstallEnabled
            components.core.engine.settings.xpinstallEnabled = xpinstallEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
         * Indicates whether or not we should enable JavaScript Just-in-time Compilation (JIT)
         * Default: false
         * Gecko preference(s) impacted:
         *  javascript.options.baselinejit,
         *  javascript.options.ion,
         *  javascript.options.jithints,
         *  javascript.options.native_regexp,
         *  javascript.options.wasm_optimizingjit
         */
        val javascriptJitEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_jit_enabled,
        )

        javascriptJitEnabledPreference.isChecked = IronFoxPreferences.isJavascriptJitEnabled(requireContext())
        javascriptJitEnabledPreference.setOnPreferenceChangeListener { preference, javascriptJitEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.javascriptJitEnabled = javascriptJitEnabled as Boolean
            components.core.engine.settings.javascriptJitBaselineEnabled = javascriptJitEnabled
            components.core.engine.settings.javascriptJitHintsEnabled = javascriptJitEnabled
            components.core.engine.settings.javascriptJitIonEnabled = javascriptJitEnabled
            components.core.engine.settings.javascriptJitIonWasmEnabled = javascriptJitEnabled
            components.core.engine.settings.javascriptJitNativeRegexpEnabled = javascriptJitEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
         * If JavaScript Just-in-time Compilation (JIT) is disabled globally, indicates whether or not we should still enable JIT for extensions
         * Default: false
         * Gecko preference(s) impacted: javascript.options.jit_trustedprincipals
         */
        val javascriptJitTrustedPrincipalsEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_jit_trusted_principals_enabled,
        )

        javascriptJitTrustedPrincipalsEnabledPreference.setOnPreferenceChangeListener { preference, javascriptJitTrustedPrincipalsEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.javascriptJitTrustedPrincipalsEnabled = javascriptJitTrustedPrincipalsEnabled as Boolean
            components.core.engine.settings.javascriptJitTrustedPrincipalsEnabled = javascriptJitTrustedPrincipalsEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
         * Indicates whether or not we should enable printing capabilities
         * Default: true
         * Gecko preference(s) impacted: print.enabled
         */
        val printEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_print_enabled,
        )

        printEnabledPreference.setOnPreferenceChangeListener { preference, printEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.printEnabled = printEnabled as Boolean
            components.core.engine.settings.printEnabled = printEnabled

            true
        }

        /**
         * Indicates whether or not we should enable Safe Browsing
         * Default: true
         * Gecko preference(s) impacted: browser.safebrowsing.malware.enabled, browser.safebrowsing.phishing.enabled
         */
        val safeBrowsingEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_safe_browsing_enabled,
        )

        safeBrowsingEnabledPreference.isChecked = IronFoxPreferences.isSafeBrowsingEnabled(requireContext())
        safeBrowsingEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, safeBrowsingEnabled ->
            val engineSettings = requireContext().components.core.engine.settings
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.safeBrowsingEnabled = safeBrowsingEnabled

            if (settings.safeBrowsingEnabled) {
                engineSettings.safeBrowsingPolicy = arrayOf(EngineSession.SafeBrowsingPolicy.RECOMMENDED)
            } else {
                engineSettings.safeBrowsingPolicy = arrayOf(EngineSession.SafeBrowsingPolicy.NONE)
            }
            requireContext().components.useCases.sessionUseCases.reload()

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
         * Indicates whether or not we should enable Scalar Vector Graphics (SVG)
         * Default: true
         * Gecko preference(s) impacted: svg.disabled
         */
        val svgEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_svg_enabled,
        )

        svgEnabledPreference.setOnPreferenceChangeListener { preference, svgEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.svgEnabled = svgEnabled as Boolean
            components.core.engine.settings.svgEnabled = svgEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
         * Indicates whether or not we should enable WebAssembly (WASM)
         * Default: true
         * Gecko preference(s) impacted: javascript.options.wasm
         */
        val wasmEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_wasm_enabled,
        )

        wasmEnabledPreference.setOnPreferenceChangeListener { preference, wasmEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.wasmEnabled = wasmEnabled as Boolean
            components.core.engine.settings.wasmEnabled = wasmEnabled

            true
        }

        /**
         * Indicates whether or not we should enable WebRTC globally
         * Default: true
         * Gecko preference(s) impacted: media.peerconnection.enabled
         */
        val webrtcEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_webrtc_enabled,
        )

        webrtcEnabledPreference.setOnPreferenceChangeListener { preference, webrtcEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.webrtcEnabled = webrtcEnabled as Boolean
            components.core.engine.settings.webrtcEnabled = webrtcEnabled

            true
        }

        /*** Miscellaneous ***/

        /**
        * Indicates whether or not we should enable collections
        * Default: true
        * Gecko preference(s) impacted: N/A
        */
        val collectionsEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_collections_enabled,
        )

        collectionsEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, collectionsEnabled ->
            val settings = preference.context.settings()

            settings.collections = collectionsEnabled

            true
        }

        /**
        * Indicates whether or not we should enable Firefox Translations
        * Default: true
        * Gecko preference(s) impacted: browser.translations.enable, browser.translations.simulateUnsupportedEngine
        */
        val translationsEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_translations_enabled,
        )

        translationsEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, translationsEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.translationsEnabled = translationsEnabled
            
            components.core.engine.settings.translationsEnabled = translationsEnabled
            components.core.engine.settings.translationsSupported = translationsEnabled

            Toast.makeText(
                context,
                getString(R.string.quit_application),
                Toast.LENGTH_LONG,
            ).show()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    exitProcess(0)
                },
                DEFAULT_EXIT_DELAY,
            )
            true
        }

        /**
        * Indicates whether or not we should enable IPv6 network connectivity
        * Default: true
        * Gecko preference(s) impacted: network.dns.disableIPv6
        */
        val ipv6EnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_ipv6_enabled,
        )

        ipv6EnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, ipv6Enabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.ipv6Enabled = ipv6Enabled
            
            components.core.engine.settings.ipv6Enabled = ipv6Enabled

            true
        }
        
        /**
         * Indicates whether or not we should disable PDF.js
         * Default: false
         * Gecko preference(s) impacted: pdfjs.disabled
         */
        val pdfjsDisabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_pdfjs_disabled,
        )

        pdfjsDisabledPreference.setOnPreferenceChangeListener { preference, pdfjsDisabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.pdfjsDisabled = pdfjsDisabled as Boolean
            components.core.engine.settings.pdfjsDisabled = pdfjsDisabled

            true
        }

        /*** Secret settings ***/

        /**
         * Indicates whether or not we should enable support for UnifiedPush
         * Default: true
         * Gecko preference(s) impacted: N/A
         */
        val enableUnifiedPushPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_enable_unifiedpush,
        )

        enableUnifiedPushPreference.setOnPreferenceChangeListener { preference, enableUnifiedPush ->
            val settings = preference.context.settings()
            settings.enableUnifiedPush = enableUnifiedPush as Boolean
            true
        }

        /**
         * Indicates whether or not we should enable Encrypted Media Extensions (EME)
         * Default: false
         * Gecko preference(s) impacted: media.eme.enabled
         */
        val emeEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_eme_enabled,
        )

        emeEnabledPreference.setOnPreferenceChangeListener { preference, emeEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.emeEnabled = emeEnabled as Boolean
            components.core.engine.settings.emeEnabled = emeEnabled

            true
        }

        /**
         * Indicates whether or not we should enable the Google Widevine CDM
         * Default: false
         * Gecko preference(s) impacted: media.mediadrm-widevinecdm.visible
         */
        val widevineEnabledPreference = requirePreference<SwitchPreference>(
            R.string.pref_key_widevine_enabled,
        )

        widevineEnabledPreference.setOnPreferenceChangeListener { preference, widevineEnabled ->
            val settings = preference.context.settings()
            val components = preference.context.components

            settings.widevineEnabled = widevineEnabled as Boolean
            components.core.engine.settings.widevineEnabled = widevineEnabled

            true
        }
    }

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.ironfox_preferences, rootKey)
        with(requireContext().settings()) {
            findPreference<SwitchPreference>(
                getPreferenceKey(R.string.pref_key_eme_enabled),
            )?.isVisible = showSecretDebugMenuThisSession
            findPreference<SwitchPreference>(
                getPreferenceKey(R.string.pref_key_enable_unifiedpush),
            )?.isVisible = showSecretDebugMenuThisSession
            findPreference<PreferenceCategory>(
                getPreferenceKey(R.string.pref_key_if_secret),
            )?.isVisible = showSecretDebugMenuThisSession
            findPreference<SwitchPreference>(
                getPreferenceKey(R.string.pref_key_use_unifiedpush),
            )?.apply {
                isVisible = enableUnifiedPush
                isChecked = useUnifiedPush
            }
            findPreference<SwitchPreference>(
                getPreferenceKey(R.string.pref_key_widevine_enabled),
            )?.isVisible = showSecretDebugMenuThisSession
        }
        setupAutoplayBlockingPolicy()
        setupCrossOriginRefererPolicy()
        setupWebsiteAppearance()
    }

    /*** Autoplay blocking policy ***/

    private fun setupAutoplayBlockingPolicy() {
        bindAutoplayBlockingSticky()
        bindAutoplayBlockingTransient()
        bindAutoplayBlockingClickToPlay()
        addToRadioGroup(
            radioAutoplayBlockingSticky,
            radioAutoplayBlockingTransient,
            radioAutoplayBlockingClickToPlay
        )
    }

    /*** Cross-origin referer policy ***/

    private fun setupCrossOriginRefererPolicy() {
        bindRefererXOriginAlways()
        bindRefererXOriginBaseDomainsMatch()
        bindRefererXOriginHostsMatch()
        addToRadioGroup(
            radioRefererXOriginAlways,
            radioRefererXOriginBaseDomainsMatch,
            radioRefererXOriginHostsMatch
        )
    }

    /*** Preferred website appearance ***/

    private fun setupWebsiteAppearance() {
        bindPrefersBrowserColorScheme()
        bindPrefersDarkColorScheme()
        bindPrefersLightColorScheme()
        addToRadioGroup(
            radioPrefersLightColorScheme,
            radioPrefersDarkColorScheme,
            radioPrefersBrowserColorScheme
        )
    }

    /**
    * Indicates whether or not we should use the sticky media autoplay blocking policy
    * Default: false
    * Gecko preference(s) impacted: media.autoplay.blocking_policy (0)
    */
    private fun bindAutoplayBlockingSticky() {
        radioAutoplayBlockingSticky = requirePreference(R.string.pref_key_autoplay_policy_sticky)
        radioAutoplayBlockingSticky.onClickListener {
            updateEngineAutoplayBlockingPolicy()
        }
    }

    /**
    * Indicates whether or not we should use the transient media autoplay blocking policy
    * Default: true
    * Gecko preference(s) impacted: media.autoplay.blocking_policy (1)
    */
    private fun bindAutoplayBlockingTransient() {
        radioAutoplayBlockingTransient = requirePreference(R.string.pref_key_autoplay_policy_transient)
        radioAutoplayBlockingTransient.onClickListener {
            updateEngineAutoplayBlockingPolicy()
        }
    }

    /**
    * Indicates whether or not we should use the click-to-play media autoplay blocking policy
    * Default: false
    * Gecko preference(s) impacted: media.autoplay.blocking_policy (2)
    */
    private fun bindAutoplayBlockingClickToPlay() {
        radioAutoplayBlockingClickToPlay = requirePreference(R.string.pref_key_autoplay_policy_click_to_play)
        radioAutoplayBlockingClickToPlay.onClickListener {
            updateEngineAutoplayBlockingPolicy()
        }
    }

    /**
    * Indicates whether or not we should always send cross-origin referers
    * Default: true
    * Gecko preference(s) impacted: network.http.referer.XOriginPolicy (0)
    */
    private fun bindRefererXOriginAlways() {
        radioRefererXOriginAlways = requirePreference(R.string.pref_key_referer_policy_always)
        radioRefererXOriginAlways.onClickListener {
            updateEngineRefererXOriginPolicy()
        }
    }

    /**
    * Indicates whether or not we should only send cross-origin referers when base domains match
    * Default: false
    * Gecko preference(s) impacted: network.http.referer.XOriginPolicy (1)
    */
    private fun bindRefererXOriginBaseDomainsMatch() {
        radioRefererXOriginBaseDomainsMatch = requirePreference(R.string.pref_key_referer_policy_base_domains_match)
        radioRefererXOriginBaseDomainsMatch.onClickListener {
            updateEngineRefererXOriginPolicy()
        }
    }

    /**
    * Indicates whether or not we should disable cross-origin referers
    * Default: false
    * Gecko preference(s) impacted: network.http.referer.XOriginPolicy (2)
    */
    private fun bindRefererXOriginHostsMatch() {
        radioRefererXOriginHostsMatch = requirePreference(R.string.pref_key_referer_policy_hosts_match)
        radioRefererXOriginHostsMatch.onClickListener {
            updateEngineRefererXOriginPolicy()
        }
    }

    /**
    * Indicates whether or not we should set CSS prefers-color-scheme to follow the browser's theme
    * Default: false
    * Gecko preference(s) impacted: N/A
    */
    private fun bindPrefersBrowserColorScheme() {
        radioPrefersBrowserColorScheme = requirePreference(R.string.pref_key_prefers_browser_color_scheme)
        radioPrefersBrowserColorScheme.onClickListener {
            setNewColorScheme()
        }
    }

    /**
    * Indicates whether or not we should set CSS prefers-color-scheme to dark
    * Default: false
    * Gecko preference(s) impacted: N/A
    */
    private fun bindPrefersDarkColorScheme() {
        radioPrefersDarkColorScheme = requirePreference(R.string.pref_key_prefers_dark_color_scheme)
        radioPrefersDarkColorScheme.onClickListener {
            setNewColorScheme()
        }
    }

    /**
    * Indicates whether or not we should set CSS prefers-color-scheme to light
    * Default: true
    * Gecko preference(s) impacted: N/A
    */
    private fun bindPrefersLightColorScheme() {
        radioPrefersLightColorScheme = requirePreference(R.string.pref_key_prefers_light_color_scheme)
        radioPrefersLightColorScheme.onClickListener {
            setNewColorScheme()
        }
    }

    private fun setNewColorScheme() {
        with(requireComponents.core) {
            engine.settings.preferredColorScheme = getPreferredColorScheme()
        }
        requireComponents.useCases.sessionUseCases.reload.invoke()
    }

    private fun updateEngineAutoplayBlockingPolicy() {
        requireContext().components.core.engine.settings.autoplayBlockingPolicy =
            requireContext().settings().getAutoplayBlockingPolicy()
    }

    private fun updateEngineRefererXOriginPolicy() {
        requireContext().components.core.engine.settings.refererXOriginPolicy =
            requireContext().settings().getRefererXOriginPolicy()
    }

    @Suppress("ComplexMethod", "LongMethod")
    override fun onPreferenceTreeClick(preference: Preference): Boolean {
        val directions: NavDirections? = when (preference.key) {
            /**
            * Indicates whether or not we should use UnifiedPush to deliver push notifications
            * Default: false
            * Gecko preference(s) impacted: N/A
            */
            resources.getString(R.string.pref_key_use_unifiedpush) -> {
                val context = requireActivity()
                context.settings().apply { useUnifiedPush = !useUnifiedPush }
                val alert = AlertDialog.Builder(context).apply {
                    setTitle(context.getString(R.string.preferences_unifiedpush))
                    setMessage(context.getString(R.string.quit_application))
                    setNegativeButton(android.R.string.cancel) { dialog: DialogInterface, _ ->
                        dialog.cancel()
                    }

                    setPositiveButton(android.R.string.ok) { _, _ ->
                        Toast.makeText(
                            context,
                            getString(R.string.toast_change_unifiedpush_done),
                            Toast.LENGTH_LONG,
                        ).show()

                        Handler(Looper.getMainLooper()).postDelayed(
                            {
                                exitProcess(0)
                            },
                            DEFAULT_EXIT_DELAY,
                        )
                    }
                    create().withCenterAlignedButtons()
                }
                if (context.settings().useUnifiedPush) {
                    requireComponents.push.switchToUnifiedPush(context) { success ->
                        if (!success) {
                            context.settings().useUnifiedPush = false
                        } else {
                            alert.show()
                        }
                    }
                } else {
                    requireComponents.push.switchToAutoPush(context)
                    alert.show()
                }
                null
            }

            else -> null
        }
        directions?.let { navigateFromIronFoxSettings(directions) }
        return super.onPreferenceTreeClick(preference)
    }

    private fun navigateFromIronFoxSettings(directions: NavDirections) {
        view?.findNavController()?.let { navController ->
            if (navController.currentDestination?.id == R.id.ironFoxSettingsFragment) {
                navController.navigate(directions)
            }
        }
    }

    companion object {
        private const val DEFAULT_EXIT_DELAY = 2000L
    }
}
