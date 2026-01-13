package org.ironfoxoss.ironfox.utils

import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.webextension.InstallationMethod
import mozilla.components.feature.addons.Addon
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.fenix.components.Components

object IronFoxAddons {
    private val logger = Logger("IronFoxAddons")

    val FXA_WEBCHANNEL = Addon(
        id = "fxa@mozac.org"
    )
    
    val ICONS = Addon(
        id = "icons@mozac.org"
    )

    val READERVIEW = Addon(
        id = "readerview@mozac.org"
    )

    val WEBCOMPAT = Addon(
        id = "webcompat@mozilla.org"
    )

    val UBLOCK_ORIGIN = Addon(
        id = "uBlock0@raymondhill.net",
        downloadUrl = "https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi"
    )

    /**
     * Determine whether an add-on is built-in
     * 
     * @param addon The add-on we should check
     */
    fun isBuiltIn(addon: Addon): Boolean {
        if (addon.id == FXA_WEBCHANNEL.id || addon.id == ICONS.id || addon.id == READERVIEW.id ||
        addon.id == WEBCOMPAT.id) {
            return true
        } else {
            return false
        }
    }

    /**
     * Determine whether an add-on is uBlock Origin
     * 
     * @param addon The add-on we should check
     */
    fun isUBlockOrigin(addon: Addon): Boolean {
        if (addon.id == UBLOCK_ORIGIN.id && addon.downloadUrl == UBLOCK_ORIGIN.downloadUrl) {
            return true
        } else {
            return false
        }
    }

    /**
     * Install an add-on
     * 
     * @param components Application components
     * @param addon The add-on we should install
     * @param checkUBlock Whether we should check if the add-on is uBlock Origin
     */
    suspend fun installAddon(
        components: Components,
        addon: Addon,
        checkUBlock: Boolean,
    ): Result<Addon> = withContext(Dispatchers.IO) {
        runCatching {
            val addonManager = components.addonManager
            val addons = addonManager.getAddons(waitForPendingActions = false)

            fun verifyUBlock(): Boolean {
                if (checkUBlock) {
                    return isUBlockOrigin(addon)
                } else {
                    return true
                }
            }

            if (addons.none { it.id == addon.id && it.isInstalled() } && verifyUBlock()) {
                logger.warn("Installing add-on: '${addon.id}'")
                val deferred = withContext(Dispatchers.Main) {
                    val deferred = CompletableDeferred<Addon>()
                    addonManager.installAddon(
                        url = addon.downloadUrl,
                        installationMethod = InstallationMethod.MANAGER,
                        onSuccess = { result ->
                            logger.info("Add-on: '${addon.id}' installed.")
                            deferred.complete(result)
                        },
                        onError = { err ->
                            logger.error("Failed to install add-on: '${addon.id}'", err)
                            deferred.completeExceptionally(err)
                        }
                    )

                    deferred
                }

                deferred.await()
            }

            addon
        }
    }
}
