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

    val UBLOCK_ORIGIN = Addon(
        id = "uBlock0@raymondhill.net",
        downloadUrl = "https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi"
    )

    fun isUBlockOrigin(addon: Addon) = addon.id == UBLOCK_ORIGIN.id

    suspend fun installAddon(
        components: Components,
        addon: Addon,
    ): Result<Addon> = withContext(Dispatchers.IO) {
        runCatching {
            val addonManager = components.addonManager
            val addons = addonManager.getAddons(waitForPendingActions = false)
            if (addons.none { it.id == addon.id && it.isInstalled() }) {
                logger.warn("Installing addon: '${addon.id}'")
                val deferred = withContext(Dispatchers.Main) {
                    val deferred = CompletableDeferred<Addon>()
                    addonManager.installAddon(
                        url = addon.downloadUrl,
                        installationMethod = InstallationMethod.MANAGER,
                        onSuccess = { result ->
                            logger.info("Addon '${addon.id}' installed.")
                            deferred.complete(result)
                        },
                        onError = { err ->
                            logger.error("Failed to install addon with id '${addon.id}'", err)
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
