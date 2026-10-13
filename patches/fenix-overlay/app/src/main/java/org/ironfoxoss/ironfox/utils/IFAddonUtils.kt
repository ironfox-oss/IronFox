package org.ironfoxoss.ironfox.utils

import android.content.Context
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.webextension.EnableSource
import mozilla.components.concept.engine.webextension.InstallationMethod
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.AddonManagerException
import mozilla.components.support.base.log.logger.Logger
import org.ironfoxoss.core.IFDeviceUtils
import org.mozilla.fenix.components.Components
import org.mozilla.fenix.ext.components

/**
 * IronFox Fenix Add-on Utilities
 *
 */
object IFAddonUtils {
  private val logger = Logger("IFAddonUtils")

  val CURSOR = Addon(
    id = "cursor@ironfoxoss.org",
    downloadUrl = "resource://android/assets/extensions/cursor/"
  )

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
    if (addon.id == CURSOR.id || addon.id == FXA_WEBCHANNEL.id || addon.id == ICONS.id ||
     addon.id == READERVIEW.id || addon.id == WEBCOMPAT.id) {
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
   */
  suspend fun installAddon(
    components: Components,
    addon: Addon,
  ): Result<Addon> = withContext(Dispatchers.IO) {
    runCatching {
      val addonManager = components.addonManager
      val addonInstalled = isAddonInstalled(components, addon)

      if (canInstallAddon(components, addon)) {
        logger.info("Installing add-on: '${addon.id}'...")
        val deferred = withContext(Dispatchers.Main) {
          val deferred = CompletableDeferred<Addon>()
          addonManager.installAddon(
            url = addon.downloadUrl,
            installationMethod = InstallationMethod.MANAGER,
            onSuccess = { result ->
              logger.info("Installed add-on: '${addon.id}'.")
              deferred.complete(result)
            },
            onError = { err ->
              logger.error("Failed to install add-on: '${addon.id}'!", err)
              deferred.completeExceptionally(err)
            }
          )

          deferred
        }

        deferred.await()
      } else {
        logger.error("Unable to install add-on: '${addon.id}'!")
      }

      addon
    }
  }

  /**
   * Install a built-in add-on (from a `resource://` directory)
   * 
   * @param components Application components
   * @param runtime WebExtensionRuntime
   * @param addon The add-on we should install
   */
  fun installBuiltInAddon(
    components: Components,
    runtime: WebExtensionRuntime,
    addon: Addon,
  ) {
    // Ensure we're only using this method for built-in addons...
    if (!isAddonBuiltIn(addon)) {
      logger.error("Unable to install non-built-in add-on: '${addon.id}'!")
      return
    }

    // Ensure we have a resource URL
    if (!addon.downloadUrl.startsWith("resource://")) {
      logger.error("Unable to install built-in add-on from URL: '${addon.downloadUrl}'!")
      return
    }

    // Ensure we are actually allowed to install the add-on...
    if (!canInstallAddon(components, addon)) {
      logger.error("Unable to install add-on: '${addon.id}'!")
      return
    }

    logger.info("Installing add-on: '${addon.id}'...")
    runtime.installBuiltInWebExtension(
      addon.id,
      addon.downloadUrl,
      onSuccess = {
        logger.info("Installed built-in add-on: '${addon.id}'.")
      },
      onError = { throwable ->
        logger.error("Failed to install built-in add-on: '${addon.id}'!")
      },
    )
  }

  /**
   * Install the built-in virtual cursor add-on for TV users
   * 
   * @param context Application context
   * @param runtime WebExtensionRuntime
   */
  fun installCursorAddon(
    context: Context,
    runtime: WebExtensionRuntime,
  ) {
    val isTV: Boolean = IFDeviceUtils.isTV(context)
    val components: Components = context.components

    if (isTV) {
      installBuiltInAddon(components, runtime, CURSOR)
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

    // Ensure we are actually allowed to uninstall the add-on...
    if (!canUninstallAddon(addon)) {
      logger.error("Unable to uninstall add-on: '${addon.id}'!")
      return
    }

    logger.info("Uninstalling add-on: '${addon.id}'...")
    addonManager.uninstallAddon(
      addon = addon,
      onSuccess = {
        logger.info("Uninstalled add-on: '${addon.id}'.")
      },
      onError = { id, throwable ->
        logger.error("Failed to uninstall add-on: '${addon.id}'!")
      }
    )
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

    logger.info("Enabling add-on: '${addon.id}'...")
    addonManager.enableAddon(
      addon = addon,
      source = EnableSource.USER,
      onSuccess = {
        logger.info("Enabled add-on: '${addon.id}'.")
      },
      onError = { err ->
        logger.error("Failed to enable add-on: '${addon.id}'!", err)
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

    logger.info("Disabling add-on: '${addon.id}'...")
    addonManager.disableAddon(
      addon = addon,
      source = EnableSource.USER,
      onSuccess = {
        logger.info("Disabled add-on: '${addon.id}'.")
      },
      onError = { err ->
        logger.error("Failed to disable add-on: '${addon.id}'!", err)
      }
    )
  }
}
