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
import org.ironfoxoss.ironfox.utils.FenixSettingsDictionary
import org.ironfoxoss.ironfox.utils.FenixStringsDictionary
import org.ironfoxoss.ironfox.utils.GeckoSettingsBridge
import org.ironfoxoss.ironfox.utils.IronFoxPreferences
import org.mozilla.fenix.components.Push
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.ext.getPreferenceKey
import org.mozilla.fenix.ext.requireComponents
import org.mozilla.fenix.ext.settings
import org.mozilla.fenix.ext.showToolbar
import org.mozilla.fenix.settings.requirePreference
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
        showToolbar(getString(FenixStringsDictionary.ironFoxSettingsTitle))

        /*** Privacy and Security ***/

        /**
         * Indicates whether or not we should disable WebGL
         * Default: true
         * Gecko preference(s) impacted: webgl.disabled
         */
        val webglDisabledPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.webglDisabled)

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
            FenixSettingsDictionary.accessibilityEnabled
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
            FenixSettingsDictionary.javascriptEnabled
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
            FenixSettingsDictionary.fppOverridesIronFoxWebGLEnabled
        )

        fppOverridesIronFoxWebGLEnabledPreference.isChecked = IronFoxPreferences.isFPPOverridesIronFoxWebGLEnabled(requireContext())
        fppOverridesIronFoxWebGLEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, fppOverridesIronFoxWebGLEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setFPPOverridesIronFoxWebGLEnabled(context, fppOverridesIronFoxWebGLEnabled)
            GeckoSettingsBridge.setFPPOverridesIronFoxWebGLEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
         * Indicates whether or not we should always use private browsing
         * Default: false
         * Gecko preference(s) impacted: browser.privatebrowsing.autostart
         */
        val alwaysUsePrivateBrowsingPreference = requirePreference<SwitchPreference>(
            FenixSettingsDictionary.alwaysUsePrivateBrowsing
        )

        alwaysUsePrivateBrowsingPreference.isChecked = IronFoxPreferences.isAlwaysUsePrivateBrowsing(requireContext())
        alwaysUsePrivateBrowsingPreference.setOnPreferenceChangeListener<Boolean> { preference, alwaysUsePrivateBrowsing ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setAlwaysUsePrivateBrowsing(context, alwaysUsePrivateBrowsing)
            GeckoSettingsBridge.setAlwaysUsePrivateBrowsing(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
         * Indicates whether or not we should enable disk cache
         * Default: false
         * Gecko preference(s) impacted: browser.cache.disk.enable
         */
        val cacheEnabledPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.cacheEnabled)

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
            FenixSettingsDictionary.fppOverridesIronFoxEnabled
        )

        fppOverridesIronFoxEnabledPreference.isChecked = IronFoxPreferences.isFPPOverridesIronFoxEnabled(requireContext())
        fppOverridesIronFoxEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, fppOverridesIronFoxEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setFPPOverridesIronFoxEnabled(context, fppOverridesIronFoxEnabled)
            GeckoSettingsBridge.setFPPOverridesIronFoxEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
            FenixSettingsDictionary.fppOverridesMozillaEnabled
        )

        fppOverridesMozillaEnabledPreference.isChecked = IronFoxPreferences.isFPPOverridesMozillaEnabled(requireContext())
        fppOverridesMozillaEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, fppOverridesMozillaEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setFPPOverridesMozillaEnabled(context, fppOverridesMozillaEnabled)
            GeckoSettingsBridge.setFPPOverridesMozillaEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
            FenixSettingsDictionary.fppOverridesIronFoxTimezoneEnabled
        )

        fppOverridesIronFoxTimezoneEnabledPreference.isChecked = IronFoxPreferences.isFPPOverridesIronFoxTimezoneEnabled(requireContext())
        fppOverridesIronFoxTimezoneEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, fppOverridesIronFoxTimezoneEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setFPPOverridesIronFoxTimezoneEnabled(context, fppOverridesIronFoxTimezoneEnabled)
            GeckoSettingsBridge.setFPPOverridesIronFoxTimezoneEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
        val spoofEnglishPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.spoofEnglish)

        spoofEnglishPreference.isChecked = IronFoxPreferences.isSpoofEnglishEnabled(requireContext())
        spoofEnglishPreference.setOnPreferenceChangeListener<Boolean> { preference, spoofEnglish ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setSpoofEnglishEnabled(context, spoofEnglish)
            GeckoSettingsBridge.setSpoofEnglishEnabled(context, engine)

            requireComponents.useCases.sessionUseCases.reload.invoke()

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
         * Indicates whether or not we should spoof the user's timezone to UTC-0
         * Default: false
         * Gecko preference(s) impacted: browser.ironfox.fingerprintingProtection.timezoneSpoofing.enabled
         */
        val spoofTimezonePreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.spoofTimezone)

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
            FenixSettingsDictionary.xpinstallEnabled
        )

        xpinstallEnabledPreference.isChecked = IronFoxPreferences.isXPInstallEnabled(requireContext())
        xpinstallEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, xpinstallEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setXPInstallEnabled(context, xpinstallEnabled)
            GeckoSettingsBridge.setXPInstallEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
            FenixSettingsDictionary.javascriptJitEnabled
        )

        javascriptJitEnabledPreference.isChecked = IronFoxPreferences.isJITEnabled(requireContext())
        javascriptJitEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, javascriptJitEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setJITEnabled(context, javascriptJitEnabled)
            GeckoSettingsBridge.setJITEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
            FenixSettingsDictionary.javascriptJitTrustedPrincipalsEnabled
        )

        javascriptJitTrustedPrincipalsEnabledPreference.isChecked = IronFoxPreferences.isJITTrustedPrincipalsEnabled(requireContext())
        javascriptJitTrustedPrincipalsEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, javascriptJitTrustedPrincipalsEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setJITTrustedPrincipalsEnabled(context, javascriptJitTrustedPrincipalsEnabled)
            GeckoSettingsBridge.setJITTrustedPrincipalsEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
        val printEnabledPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.printEnabled)

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
            FenixSettingsDictionary.safeBrowsingEnabled
        )

        safeBrowsingEnabledPreference.isChecked = IronFoxPreferences.isSafeBrowsingEnabled(requireContext())
        safeBrowsingEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, safeBrowsingEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setSafeBrowsingEnabled(context, safeBrowsingEnabled)
            GeckoSettingsBridge.setSafeBrowsingEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
        val svgEnabledPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.svgEnabled)

        svgEnabledPreference.isChecked = IronFoxPreferences.isSVGEnabled(requireContext())
        svgEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, svgEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setSVGEnabled(context, svgEnabled)
            GeckoSettingsBridge.setSVGEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
        val wasmEnabledPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.wasmEnabled)

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
        val webrtcEnabledPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.webrtcEnabled)

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
        val collectionsPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.collections)

        collectionsPreference.isChecked = IronFoxPreferences.isCollectionsEnabled(requireContext())
        collectionsPreference.setOnPreferenceChangeListener<Boolean> { preference, collectionsEnabled ->
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
            FenixSettingsDictionary.translationsEnabled
        )

        translationsEnabledPreference.isChecked = IronFoxPreferences.isTranslationsEnabled(requireContext())
        translationsEnabledPreference.setOnPreferenceChangeListener<Boolean> { preference, translationsEnabled ->
            val context = requireContext()
            val engine = requireComponents.core.engine

            IronFoxPreferences.setTranslationsEnabled(context, translationsEnabled)
            GeckoSettingsBridge.setTranslationsEnabled(context, engine)

            Toast.makeText(
                context,
                getString(FenixStringsDictionary.quitApplication),
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
        val ipv6EnabledPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.ipv6Enabled)

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
        val pdfjsDisabledPreference = requirePreference<SwitchPreference>(FenixSettingsDictionary.pdfjsDisabled)

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
            FenixSettingsDictionary.enableUnifiedPush
        )

        enableUnifiedPushPreference.isChecked = IronFoxPreferences.isUnifiedPushEnabled(requireContext())
        enableUnifiedPushPreference.setOnPreferenceChangeListener<Boolean> { preference, enableUnifiedPush ->
            val context = requireContext()

            IronFoxPreferences.setUnifiedPushEnabled(context, enableUnifiedPush)

            true
        }
    }

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(FenixStringsDictionary.ironFoxSettingsResource, rootKey)
        with(requireContext().settings()) {
            findPreference<SwitchPreference>(
                getPreferenceKey(FenixSettingsDictionary.enableUnifiedPush),
            )?.isVisible = showSecretDebugMenuThisSession
            findPreference<PreferenceCategory>(
                getPreferenceKey(FenixSettingsDictionary.ironfoxSecretSettings),
            )?.isVisible = showSecretDebugMenuThisSession
            findPreference<SwitchPreference>(
                getPreferenceKey(FenixSettingsDictionary.useUnifiedPush),
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
        radioAutoplayBlockingSticky = requirePreference(FenixSettingsDictionary.autoplayBlockingSticky)
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
        radioAutoplayBlockingTransient = requirePreference(FenixSettingsDictionary.autoplayBlockingTransient)
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
        radioAutoplayBlockingClickToPlay = requirePreference(FenixSettingsDictionary.autoplayBlockingClickToPlay)
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
        radioRefererXOriginAlways = requirePreference(FenixSettingsDictionary.refererXOriginAlways)
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
        radioRefererXOriginBaseDomainsMatch = requirePreference(FenixSettingsDictionary.refererXOriginBaseDomainsMatch)
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
        radioRefererXOriginHostsMatch = requirePreference(FenixSettingsDictionary.refererXOriginHostsMatch)
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
        radioPrefersBrowserColorScheme = requirePreference(FenixSettingsDictionary.prefersBrowserColorScheme)
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
        radioPrefersDarkColorScheme = requirePreference(FenixSettingsDictionary.prefersDarkColorScheme)
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
        radioPrefersLightColorScheme = requirePreference(FenixSettingsDictionary.prefersLightColorScheme)
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
            resources.getString(FenixSettingsDictionary.useUnifiedPush) -> {
                val context = requireActivity()
                context.settings().apply { ironfox.useUnifiedPush = !ironfox.useUnifiedPush }
                val alert = AlertDialog.Builder(context).apply {
                    setTitle(context.getString(FenixStringsDictionary.unifiedPushPreference))
                    setMessage(context.getString(FenixStringsDictionary.quitApplication))
                    setNegativeButton(android.R.string.cancel) { dialog: DialogInterface, _ ->
                        dialog.cancel()
                    }

                    setPositiveButton(android.R.string.ok) { _, _ ->
                        Toast.makeText(
                            context,
                            getString(FenixStringsDictionary.unifiedPushModified),
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
            if (navController.currentDestination?.id == FenixStringsDictionary.ironFoxSettingsFragment) {
                navController.navigate(directions)
            }
        }
    }

    companion object {
        private const val DEFAULT_EXIT_DELAY = 2000L
    }
}
