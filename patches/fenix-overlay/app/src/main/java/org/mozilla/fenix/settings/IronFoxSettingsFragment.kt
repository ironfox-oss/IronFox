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
import mozilla.components.ui.widgets.withCenterAlignedButtons
import org.ironfoxoss.ironfox.utils.GeckoSettingsBridge
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

        webglDisabledPreference.isChecked = IronFoxPreferences.isWebGLDisabled(requireContext())
        webglDisabledPreference.setOnPreferenceChangeListener<Boolean> { preference, webglDisabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setWebGLDisabled(context, webglDisabled)
            GeckoSettingsBridge.setWebGLDisabled(context, engine)

            requireComponents.useCases.sessionUseCases.reload.invoke()

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

        accessibilityEnabledPreference.isChecked = IronFoxPreferences.isAccessibilityEnabled(requireContext())
        accessibilityEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, accessibilityEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setAccessibilityEnabled(context, accessibilityEnabled)
            GeckoSettingsBridge.setAccessibilityEnabled(context, engine)

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

        javascriptEnabledPreference.isChecked = IronFoxPreferences.isJavaScriptEnabled(requireContext())
        javascriptEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, javascriptEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setJavaScriptEnabled(context, javascriptEnabled)
            GeckoSettingsBridge.setJavaScriptEnabled(context, engine)

            requireComponents.useCases.sessionUseCases.reload.invoke()

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

        fppOverridesIronFoxWebGLEnabledPreference.isChecked = IronFoxPreferences.isFPPOverridesIronFoxWebGLEnabled(requireContext())
        fppOverridesIronFoxWebGLEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, fppOverridesIronFoxWebGLEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setFPPOverridesIronFoxWebGLEnabled(context, fppOverridesIronFoxWebGLEnabled)
            GeckoSettingsBridge.setFPPOverridesIronFoxWebGLEnabled(context, engine)

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

        cacheEnabledPreference.isChecked = IronFoxPreferences.isCacheEnabled(requireContext())
        cacheEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, cacheEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setCacheEnabled(context, cacheEnabled)
            GeckoSettingsBridge.setCacheEnabled(context, engine)

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

        fppOverridesIronFoxEnabledPreference.isChecked = IronFoxPreferences.isFPPOverridesIronFoxEnabled(requireContext())
        fppOverridesIronFoxEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, fppOverridesIronFoxEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setFPPOverridesIronFoxEnabled(context, fppOverridesIronFoxEnabled)
            GeckoSettingsBridge.setFPPOverridesIronFoxEnabled(context, engine)

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

        fppOverridesMozillaEnabledPreference.isChecked = IronFoxPreferences.isFPPOverridesMozillaEnabled(requireContext())
        fppOverridesMozillaEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, fppOverridesMozillaEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setFPPOverridesMozillaEnabled(context, fppOverridesMozillaEnabled)
            GeckoSettingsBridge.setFPPOverridesMozillaEnabled(context, engine)

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

        fppOverridesIronFoxTimezoneEnabledPreference.isChecked = IronFoxPreferences.isFPPOverridesIronFoxTimezoneEnabled(requireContext())
        fppOverridesIronFoxTimezoneEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, fppOverridesIronFoxTimezoneEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setFPPOverridesIronFoxTimezoneEnabled(context, fppOverridesIronFoxTimezoneEnabled)
            GeckoSettingsBridge.setFPPOverridesIronFoxTimezoneEnabled(context, engine)

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

        spoofEnglishPreference.isChecked = IronFoxPreferences.isSpoofEnglishEnabled(requireContext())
        spoofEnglishPreference.setOnPreferenceChangeListener<Boolean> { preference, spoofEnglish ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setSpoofEnglishEnabled(context, spoofEnglish)
            GeckoSettingsBridge.setSpoofEnglishEnabled(context, engine)

            requireComponents.useCases.sessionUseCases.reload.invoke()

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

        spoofTimezonePreference.isChecked = IronFoxPreferences.isSpoofTimezoneEnabled(requireContext())
        spoofTimezonePreference.setOnPreferenceChangeListener<Boolean> { preference, spoofTimezone ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setSpoofTimezoneEnabled(context, spoofTimezone)
            GeckoSettingsBridge.setSpoofTimezoneEnabled(context, engine)

            requireComponents.useCases.sessionUseCases.reload.invoke()

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

        xpinstallEnabledPreference.isChecked = IronFoxPreferences.isXPInstallEnabled(requireContext())
        xpinstallEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, xpinstallEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setXPInstallEnabled(context, xpinstallEnabled)
            GeckoSettingsBridge.setXPInstallEnabled(context, engine)

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

        javascriptJitEnabledPreference.isChecked = IronFoxPreferences.isJITEnabled(requireContext())
        javascriptJitEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, javascriptJitEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setJITEnabled(context, javascriptJitEnabled)
            GeckoSettingsBridge.setJITEnabled(context, engine)

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

        javascriptJitTrustedPrincipalsEnabledPreference.isChecked = IronFoxPreferences.isJITTrustedPrincipalsEnabled(requireContext())
        javascriptJitTrustedPrincipalsEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, javascriptJitTrustedPrincipalsEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setJITTrustedPrincipalsEnabled(context, javascriptJitTrustedPrincipalsEnabled)
            GeckoSettingsBridge.setJITTrustedPrincipalsEnabled(context, engine)

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

        printEnabledPreference.isChecked = IronFoxPreferences.isPrintEnabled(requireContext())
        printEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, printEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setPrintEnabled(context, printEnabled)
            GeckoSettingsBridge.setPrintEnabled(context, engine)

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
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setSafeBrowsingEnabled(context, safeBrowsingEnabled)
            GeckoSettingsBridge.setSafeBrowsingEnabled(context, engine)

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

        svgEnabledPreference.isChecked = IronFoxPreferences.isSVGEnabled(requireContext())
        svgEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, svgEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setSVGEnabled(context, svgEnabled)
            GeckoSettingsBridge.setSVGEnabled(context, engine)

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

        wasmEnabledPreference.isChecked = IronFoxPreferences.isWASMEnabled(requireContext())
        wasmEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, wasmEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setWASMEnabled(context, wasmEnabled)
            GeckoSettingsBridge.setWASMEnabled(context, engine)

            requireComponents.useCases.sessionUseCases.reload.invoke()

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

        webrtcEnabledPreference.isChecked = IronFoxPreferences.isWebRTCEnabled(requireContext())
        webrtcEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, webrtcEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setWebRTCEnabled(context, webrtcEnabled)
            GeckoSettingsBridge.setWebRTCEnabled(context, engine)

            requireComponents.useCases.sessionUseCases.reload.invoke()

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

        collectionsEnabledPreference.isChecked = IronFoxPreferences.isCollectionsEnabled(requireContext())
        collectionsEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, collectionsEnabled ->
            val context = requireContext()

            IronFoxPreferences.setCollectionsEnabled(context, collectionsEnabled)

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

        translationsEnabledPreference.isChecked = IronFoxPreferences.isTranslationsEnabled(requireContext())
        translationsEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, translationsEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setTranslationsEnabled(context, translationsEnabled)
            GeckoSettingsBridge.setTranslationsEnabled(context, engine)

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

        ipv6EnabledPreference.isChecked = IronFoxPreferences.isIPv6Enabled(requireContext())
        ipv6EnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, ipv6Enabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setIPv6Enabled(context, ipv6Enabled)
            GeckoSettingsBridge.setIPv6Enabled(context, engine)

            requireComponents.useCases.sessionUseCases.reload.invoke()

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

        pdfjsDisabledPreference.isChecked = IronFoxPreferences.isPDFjsDisabled(requireContext())
        pdfjsDisabledPreference.setOnPreferenceChangeListener<Boolean> { preference, pdfjsDisabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setPDFjsDisabled(context, pdfjsDisabled)
            GeckoSettingsBridge.setPDFjsDisabled(context, engine)

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

        enableUnifiedPushPreference.isChecked = IronFoxPreferences.isUnifiedPushEnabled(requireContext())
        enableUnifiedPushPreference.setOnPreferenceChangeListener<Boolean> { preference, enableUnifiedPush ->
            val context = requireContext()

            IronFoxPreferences.setUnifiedPushEnabled(context, enableUnifiedPush)

            true
        }
    }

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.ironfox_preferences, rootKey)
        with(requireContext().settings()) {
            findPreference<SwitchPreference>(
                getPreferenceKey(R.string.pref_key_enable_unifiedpush),
            )?.isVisible = showSecretDebugMenuThisSession
            findPreference<PreferenceCategory>(
                getPreferenceKey(R.string.pref_key_if_secret),
            )?.isVisible = showSecretDebugMenuThisSession
            findPreference<SwitchPreference>(
                getPreferenceKey(R.string.pref_key_use_unifiedpush),
            )?.apply {
                isVisible = IronFoxPreferences.isUnifiedPushEnabled(requireContext())
                isChecked = IronFoxPreferences.shouldUseUnifiedPush(requireContext())
            }
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
            updateGeckoAutoplayBlockingPolicy()
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
            updateGeckoAutoplayBlockingPolicy()
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
            updateGeckoAutoplayBlockingPolicy()
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
            updateGeckoRefererXOriginPolicy()
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
            updateGeckoRefererXOriginPolicy()
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
            updateGeckoRefererXOriginPolicy()
        }
    }

    /**
    * Indicates whether or not we should set CSS prefers-color-scheme to follow the browser's theme
    * Default: false
    * Gecko preference(s) impacted: layout.css.prefers-color-scheme.content-override (2)
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
    * Gecko preference(s) impacted: layout.css.prefers-color-scheme.content-override (0)
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
    * Gecko preference(s) impacted: layout.css.prefers-color-scheme.content-override (1)
    */
    private fun bindPrefersLightColorScheme() {
        radioPrefersLightColorScheme = requirePreference(R.string.pref_key_prefers_light_color_scheme)
        radioPrefersLightColorScheme.onClickListener {
            setNewColorScheme()
        }
    }

    private fun setNewColorScheme() {
        val context = requireContext()
        val engine = requireComponents.core.engine

        GeckoSettingsBridge.setPreferredWebsiteAppearance(context, engine)

        requireComponents.useCases.sessionUseCases.reload.invoke()
    }

    private fun updateGeckoAutoplayBlockingPolicy() {
        val context = requireContext()
        val engine = requireComponents.core.engine

        GeckoSettingsBridge.setAutoplayBlockingPolicy(context, engine)

        requireComponents.useCases.sessionUseCases.reload.invoke()
    }

    private fun updateGeckoRefererXOriginPolicy() {
        val context = requireContext()
        val engine = requireComponents.core.engine

        GeckoSettingsBridge.setRefererXOriginPolicy(context, engine)
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
                if (IronFoxPreferences.shouldUseUnifiedPush(requireContext())) {
                    requireComponents.push.switchToUnifiedPush(context) { success ->
                        if (!success) {
                            IronFoxPreferences.setUseUnifiedPush(requireContext(), false)
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
