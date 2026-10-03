package org.ironfoxoss.ironfox.utils

import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.webextension.EnableSource
import mozilla.components.concept.engine.webextension.InstallationMethod
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.AddonManagerException
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.fenix.components.Components

/**
 * IronFox Fenix Add-on Utilities
 *
 */
object IFAddonUtils {
  private val logger = Logger("IFAddonUtils")

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
  fun isAddonBuiltIn(addon: Addon): Boolean {
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
   * Check if we are allowed to install an add-on
   * 
   * @param components Application components
   * @param addon The add-on we should check
   */
  fun canInstallAddon(components: Components, addon: Addon): Boolean {
    val settings = components.settings
    
    // If the onboarding has not been completed and the add-on we're trying to install is uBlock Origin, always allow it
    if (!settings.ironfox.ironFoxOnboardingCompleted && isUBlockOrigin(addon)) {
      return true
    }

    // If the add-on is built-in, allow it
    if (isAddonBuiltIn(addon)) {
      return true
    }

    return settings.ironfox.xpinstallEnabled
  }

  /**
   * Check if we are allowed to uninstall an add-on
   * 
   * @param addon The add-on we should check
   */
  fun canUninstallAddon(addon: Addon): Boolean {
    // We should never try to uninstall a built-in add-on...
    return !isAddonBuiltIn(addon)
  }

  /**
   * Check if an add-on is installed
   * 
   * @param components Application components
   * @param addon The add-on we should check
   */
  suspend fun isAddonInstalled(components: Components, addon: Addon): Boolean {
    try {
      val addonManager = components.addonManager
      val addons = addonManager.getAddons(waitForPendingActions = false)
      if (addons.none { it.id == addon.id && it.isInstalled() }) {
        return false
      } else {
        return true
      }
    } catch (e: AddonManagerException) {
      return false
    }
  }

  /**
   * Check if an add-on is enabled
   * 
   * @param components Application components
   * @param addon The add-on we should check
   */
  suspend fun isAddonEnabled(components: Components, addon: Addon): Boolean {
    try {
      val addonManager = components.addonManager
      val addons = addonManager.getAddons(waitForPendingActions = false)
      if (addons.none { it.id == addon.id && it.isInstalled() }) {
        // If an add-on isn't installed, it's obviously not enabled...
        return false
      } else {
        return addon.isEnabled()
      }
    } catch (e: AddonManagerException) {
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
  ): Result<Addon> = withContext(Dispatchers.IO) {
    runCatching {
      val addonManager = components.addonManager
      val addonInstalled = isAddonInstalled(components, addon)

      if (canInstallAddon(components, addon)) {
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

  /**
   * Uninstall an add-on
   * 
   * @param components Application components
   * @param addon The add-on we should uninstall
   */
  fun uninstallAddon(
    components: Components,
    addon: Addon,
  ) {
    val addonManager = components.addonManager

    if (canUninstallAddon(addon)) {
      addonManager.uninstallAddon(
        addon = addon,
        onSuccess = {
          logger.info("Add-on: '${addon.id}' uninstalled.")
        },
        onError = { id, throwable ->
          logger.error("Failed to uninstall add-on: '${addon.id}'")
        }
      )
    }
  }

  /**
   * Enable an add-on
   * 
   * @param components Application components
   * @param addon The add-on we should enable
   */
  fun enableAddon(
    components: Components,
    addon: Addon,
  ) {
    val addonManager = components.addonManager

    addonManager.enableAddon(
      addon = addon,
      source = EnableSource.USER,
      onSuccess = {
        logger.info("Add-on: '${addon.id}' enabled.")
      },
      onError = { err ->
        logger.error("Failed to enable add-on: '${addon.id}'", err)
      }
    )
  }

  /**
   * Disable an add-on
   * 
   * @param components Application components
   * @param addon The add-on we should disable
   */
  fun disableAddon(
    components: Components,
    addon: Addon,
  ) {
    val addonManager = components.addonManager

    addonManager.disableAddon(
      addon = addon,
      source = EnableSource.USER,
      onSuccess = {
        logger.info("Add-on: '${addon.id}' disabled.")
      },
      onError = { err ->
        logger.error("Failed to disable add-on: '${addon.id}'", err)
      }
    )
  }
}
