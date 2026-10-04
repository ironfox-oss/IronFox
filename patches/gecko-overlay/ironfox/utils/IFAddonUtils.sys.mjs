// IronFox Gecko Add-on Utilities

const lazy = {};

ChromeUtils.defineESModuleGetters(lazy, {
  AddonManager:           "resource://gre/modules/AddonManager.sys.mjs",
  EventDispatcher:        "resource://gre/modules/Messaging.sys.mjs",
  GeckoViewWebExtension:  "resource://gre/modules/GeckoViewWebExtension.sys.mjs",
  IFPrefUtils:            "moz-src:///ironfox/utils/IFPrefUtils.sys.mjs",
});

ChromeUtils.defineLazyGetter(lazy, "log", () => {
  let { ConsoleAPI } = ChromeUtils.importESModule(
    "resource://gre/modules/Console.sys.mjs"
  );
  return new ConsoleAPI({
    prefix: "IFAddonUtils",
    maxLogLevel: "warn",
    maxLogLevelPref: "browser.ironfox.ifAddonUtils.loglevel",
  });
});

export const IFAddonUtils = {
  /**
   * Determine whether an add-on is built-in
   *
   * @param {string} id - Add-on ID
   * @return {boolean} - Returns `true` if the add-on is built-in; `false` otherwise
   */
  isAddonBuiltIn(id) {
    if (id === "fxa@mozac.org" || id === "icons@mozac.org" || id === "readerview@mozac.org" || id === "webcompat@mozilla.org") {
      return true;
    } else {
      return false;
    }
  },

  /**
   * Determine whether an add-on is uBlock Origin
   *
   * @param {string} url - Add-on URL
   * @return {boolean} - Returns `true` if the add-on is uBlock Origin; `false` otherwise
   */
  isUBlockOrigin(url) {
    if (url === "https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi") {
      return true;
    } else {
      return false;
    };
  },

  /**
   * Check if we are allowed to install an add-on (based on its URL)
   *
   * @param {string} url - Add-on URL
   * @return {boolean} - Returns `true` if the add-on can be installed; `false` otherwise
   */
  canInstallAddon(url) {
    if (typeof url !== "string") {
      lazy.log.error(
        `canInstallAddon: Add-on URL is not a string: '${url}'`
      );
      return;
    };

    // If the onboarding has not been completed and the add-on we're trying to install is uBlock Origin, always allow it
    if (!lazy.IFPrefUtils.getBoolPref("browser.ironfox.onboardingCompleted") && this.isUBlockOrigin(url)) {
      return true;
    };

    return lazy.IFPrefUtils.getBoolPref("xpinstall.enabled");
  },

  /**
   * Check if we are allowed to uninstall an add-on
   *
   * @param {string} id - Add-on ID
   * @return {boolean} - Returns `true` if the add-on can be uninstalled; `false` otherwise
   */
  canUninstallAddon(id) {
    // We should never try to uninstall a built-in add-on...
    return !this.isAddonBuiltIn(id);
  },

  /**
   * Check if an add-on is installed
   *
   * @param {string} id - Add-on ID
   * @return {boolean} - Returns `true` if the add-on is installed; `false` otherwise
   */
  async isAddonInstalled(id) {
    const addon = await lazy.AddonManager.getAddonByID(id);
    if (addon) {
      return true;
    } else {
      return false;
    };
  },

  /**
   * Check if an add-on is enabled
   *
   * @param {string} id - Add-on ID
   * @return {boolean} - Returns `true` if the add-on is enabled; `false` otherwise
   */
  async isAddonEnabled(id) {
    const addon = await lazy.AddonManager.getAddonByID(id);
    if (!addon) {
      // If the add-on is not installed, it's not enabled...
      lazy.log.debug(`isAddonEnabled: Add-on: '${id}' is not installed`);
      return false;
    } else {
      return !addon.appDisabled && !addon.softDisabled && !addon.userDisabled
    };
  },

  /**
   * If necessary, display a prompt to notify the user that add-on installation is currently disabled
   *
   */
  async displayInstallDisabledPrompt() {
    // If the prompt hasn't been displayed yet, display it
    if (!lazy.IFPrefUtils.getBoolPref("browser.ironfox.xpinstall.prompt.shown")) {
      await lazy.EventDispatcher.instance.sendRequest("GeckoView:WebExtension:OnInstallationFailed", {
        error: 99,
      });
      lazy.IFPrefUtils.setUserBoolPref("browser.ironfox.xpinstall.prompt.shown", true);
    };
  },

  /**
   * Install an add-on
   *
   * @param uri - Add-on URI
   */
  async installAddon(uri) {
    // First, ensure we're allowed to install the add-on
    if (!this.canInstallAddon(uri.spec)) {
      lazy.log.error(`installAddon: Not allowed to install add-on from URL: '${uri.spec}'`);
      await this.displayInstallDisabledPrompt();
      return;
    };
    const installId = Services.uuid.generateUUID().toString();
    let { extension } = await lazy.GeckoViewWebExtension.installWebExtension(
      installId,
      uri
    );
    if (extension) {
      await lazy.EventDispatcher.instance.sendRequest({
        type: "GeckoView:WebExtension:OnInstalled",
        extension,
      });
    } else {
      lazy.log.error("installAddon: Failed to install add-on: extension is null.");
    }
  },

  /**
   * Uninstall an add-on
   *
   * @param {string} id - Add-on ID
   */
  async uninstallAddon(id) {
    const addon = await lazy.AddonManager.getAddonByID(id);
    if (!addon) {
      // If the add-on is not installed, we can't uninstall it...
      lazy.log.error(`uninstallAddon: Add-on: '${id}' is not installed`);
      return;
    };

    // Ensure we're allowed to uninstall the add-on
    if (!this.canUninstallAddon(id)) {
      lazy.log.error(`uninstallAddon: Not allowed to uninstall add-on: '${id}'`);
      return;
    };

    let { extension } = await lazy.GeckoViewWebExtension.uninstallWebExtension(id);
    if (extension) {
      await lazy.EventDispatcher.instance.sendRequest({
        type: "GeckoView:WebExtension:OnUninstalled",
        extension,
      });
    } else {
      lazy.log.error("uninstallAddon: Failed to uninstall add-on: extension is null.");
    }
  },

  /**
   * Enable an add-on
   *
   * @param {string} id - Add-on ID
   */
  async enableAddon(id) {
    const addon = await lazy.AddonManager.getAddonByID(id);
    if (!addon) {
      // If the add-on is not installed, we can't enable it...
      lazy.log.error(`enableAddon: Add-on: '${id}' is not installed`);
      return;
    };

    // Check if the add-on is already enabled
    if (this.isAddonEnabled(id)) {
      lazy.log.debug(`enableAddon: Add-on: '${id}' is already enabled`);
      return;
    };

    let { extension } = await lazy.GeckoViewWebExtension.enableWebExtension(id, "user");
    if (extension) {
      await lazy.EventDispatcher.instance.sendRequest({
        type: "GeckoView:WebExtension:OnEnabled",
        extension,
      });
    } else {
      lazy.log.error("enableAddon: Failed to enable add-on: extension is null.");
    }
  },

  /**
   * Disable an add-on
   *
   * @param {string} id - Add-on ID
   */
  async disableAddon(id) {
    const addon = await lazy.AddonManager.getAddonByID(id);
    if (!addon) {
      // If the add-on is not installed, we can't disable it...
      lazy.log.error(`disableAddon: Add-on: '${id}' is not installed`);
      return;
    };

    // Check if the add-on is already disabled
    if (!this.isAddonEnabled(id)) {
      lazy.log.debug(`disableAddon: Add-on: '${id}' is already disabled`);
      return;
    };

    let { extension } = await lazy.GeckoViewWebExtension.disableWebExtension(id, "user");
    if (extension) {
      await lazy.EventDispatcher.instance.sendRequest({
        type: "GeckoView:WebExtension:OnDisabled",
        extension,
      });
    } else {
      lazy.log.error("disableAddon: Failed to disable add-on: extension is null.");
    }
  },
};
