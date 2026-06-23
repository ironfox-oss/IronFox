// IronFox Gecko Preference Utilities

const lazy = {};

ChromeUtils.defineLazyGetter(lazy, "log", () => {
  let { ConsoleAPI } = ChromeUtils.importESModule(
    "resource://gre/modules/Console.sys.mjs"
  );
  return new ConsoleAPI({
    prefix: "IFPrefUtils",
    maxLogLevel: "warn",
    maxLogLevelPref: "browser.ironfox.ifPrefUtils.loglevel",
  });
});

export const IFPrefUtils = {
  /**
   * Check if a Gecko preference has a default value
   *
   * @param {string} pref - Preference name
   * @return {boolean} - Returns `true` if the preference exists and has a default value; `false` otherwise
   */
  prefHasDefaultValue(pref) {
    if (Services.prefs.prefHasDefaultValue(pref)) {
      return true;
    } else {
      return false;
    };
  },

  /**
   * Check if a Gecko preference has a user value
   *
   * @param {string} pref - Preference name
   * @return {boolean} - Returns `true` if the preference exists and has a user value; `false` otherwise
   */
  prefHasUserValue(pref) {
    if (Services.prefs.prefHasUserValue(pref)) {
      return true;
    } else {
      return false;
    };
  },

  /**
   * Check if a Gecko preference exists on a specified branch
   *
   * @param {string} pref - Preference name
   * @param {string} branch - Preference branch ("default" or "user")
   * @return {boolean} - Returns `true` if the preference exists on the specified branch; `false` otherwise
   */
  prefExistsOnBranch(pref, branch) {
    // Ensure we have a valid pref branch
    if (branch !== "default" && branch !== "user") {
      lazy.log.error(
        `prefExistsOnBranch: Invalid branch (${branch}) for pref: ${pref}`
      );
      return false;
    };

    if ((branch === "default" && Services.prefs.prefHasDefaultValue(pref)) ||
     (branch === "user" && Services.prefs.prefHasUserValue(pref))) {
      return true;
    } else {
      return false;
    };
  },

  /**
   * Clear the user value of a Gecko preference
   *
   * @param {string} pref - Preference name
   */
  clearPref(pref) {
    Services.prefs.clearUserPref(pref);
    lazy.log.debug(
      `clearPref: Cleared pref: ${pref}`
    );
  },

  /**
   * Check if a Gecko preference exists
   *
   * @param {string} pref - Preference name
   * @return {boolean} - Returns `true` if the preference exists; `false` otherwise
   */
  prefExists(pref) {
    // A preference has to have a default or user value for it to exist -
    // so, if it doesn't, we know the pref doesn't exist
    if (Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref)) {
      return true;
    } else {
      return false;
    };
  },

  /**
   * Lock a Gecko preference
   *
   * @param {string} pref - Preference name
   */
  lockPref(pref) {
    // Ensure our pref exists and has a default value
    if (Services.prefs.prefHasDefaultValue(pref)) {
      // Lock our preference
      Services.prefs.lockPref(pref);
      lazy.log.debug(
        `lockPref: Locked pref: ${pref}`
      );
    } else {
      lazy.log.error(
        `lockPref: Unable to lock pref without default value: ${pref}`
      );
    };
  },

  /**
   * Unlock a Gecko preference
   *
   * @param {string} pref - Preference name
   */
  unlockPref(pref) {
    // Ensure our pref exists and has a default value
    if (Services.prefs.prefHasDefaultValue(pref)) {
      // Unlock our preference
      Services.prefs.unlockPref(pref);
      lazy.log.debug(
        `unlockPref: Unlocked pref: ${pref}`
      );
    } else {
      lazy.log.error(
        `unlockPref: Unable to unlock pref without default value: ${pref}`
      );
    };
  },

  /**
   * Return the current value of a Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {string | integer | boolean} - Preference value
   */
  getPref(pref) {
    return getCurrentValue(pref);
  },

  /**
   * Return the default value of a Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {string | integer | boolean} - Preference value
   */
  getDefaultPref(pref) {
    return getPrefFromBranch(pref, "default");
  },

  /**
   * Return the user value of a Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {string | integer | boolean} - Preference value
   */
  getUserPref(pref) {
    return getPrefFromBranch(pref, "user");
  },

  /**
   * Return the current value of a boolean Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {boolean} - Preference value
   */
  getBoolPref(pref) {
    const value = getCurrentValue(pref);
    if (typeof value === "boolean") {
      return value
    } else {
      throw new Error(`getBoolPref: Pref did not return boolean value: ${pref}`);
    };
  },

  /**
   * Return the default value of a boolean Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {boolean} - Preference value
   */
  getDefaultBoolPref(pref) {
    const value = getPrefFromBranch(pref, "default");
    if (typeof value === "boolean") {
      return value
    } else {
      throw new Error(`getDefaultBoolPref: Pref did not return boolean value: ${pref}`);
    };
  },

  /**
   * Return the user value of a boolean Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {boolean} - Preference value
   */
  getUserBoolPref(pref) {
    const value = getPrefFromBranch(pref, "user");
    if (typeof value === "boolean") {
      return value
    } else {
      throw new Error(`getUserBoolPref: Pref did not return boolean value: ${pref}`);
    };
  },

  /**
   * Return the current value of an integer Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {integer} - Preference value
   */
  getIntPref(pref) {
    const value = getCurrentValue(pref);
    if (typeof value === "number" && Number.isInteger(value)) {
      return value
    } else {
      throw new Error(`getIntPref: Pref did not return integer value: ${pref}`);
    };
  },

  /**
   * Return the default value of an integer Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {integer} - Preference value
   */
  getDefaultIntPref(pref) {
    const value = getPrefFromBranch(pref, "default");
    if (typeof value === "number" && Number.isInteger(value)) {
      return value
    } else {
      throw new Error(`getDefaultIntPref: Pref did not return integer value: ${pref}`);
    };
  },

  /**
   * Return the user value of an integer Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {integer} - Preference value
   */
  getUserIntPref(pref) {
    const value = getPrefFromBranch(pref, "user");
    if (typeof value === "number" && Number.isInteger(value)) {
      return value
    } else {
      throw new Error(`getUserIntPref: Pref did not return integer value: ${pref}`);
    };
  },

  /**
   * Return the current value of a string Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {boolean} - Preference value
   */
  getStringPref(pref) {
    const value = getCurrentValue(pref);
    if (typeof value === "string") {
      return value
    } else {
      throw new Error(`getStringPref: Pref did not return string value: ${pref}`);
    };
  },

  /**
   * Return the default value of a string Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {string} - Preference value
   */
  getDefaultStringPref(pref) {
    const value = getPrefFromBranch(pref, "default");
    if (typeof value === "string") {
      return value
    } else {
      throw new Error(`getDefaultStringPref: Pref did not return string value: ${pref}`);
    };
  },

  /**
   * Return the user value of a string Gecko preference
   *
   * @param {string} pref - Preference name
   * @return {string} - Preference value
   */
  getUserStringPref(pref) {
    const value = getPrefFromBranch(pref, "user");
    if (typeof value === "string") {
      return value
    } else {
      throw new Error(`getUserStringPref: Pref did not return string value: ${pref}`);
    };
  },

  /**
   * Set and lock a Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {string | integer | boolean} value - Preference value
   */
  setAndLockPref(pref, value) {
    // Check our value type
    if (typeof value === "number" && !Number.isInteger(value)) {
      lazy.log.error(
        `setAndLockPref: Unable to set non-integer value for pref: ${pref}`
      );
      return 
    };

    // Ensure our pref and value types match
    if (Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref)) {
      if (typeof value === "boolean" && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_BOOL) {
        lazy.log.error(
          `setAndLockPref: Pref type is not a boolean: ${pref}`
        );
        return;
      } else if (typeof value === "number" && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_INT) {
        lazy.log.error(
          `setAndLockPref: Pref type is not an integer: ${pref}`
        );
        return;
      } else if (typeof value === "string" && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_STRING) {
        lazy.log.error(
          `setAndLockPref: Pref type is not a string: ${pref}`
        );
        return;
      };
    };

    // Ensure our pref is unlocked
    if (Services.prefs.prefIsLocked(pref)) {
      Services.prefs.unlockPref(pref);
    };

    // Set our preference
    _setDefaultPref(pref, value);

    // Lock our preference
    Services.prefs.lockPref(pref);

    lazy.log.debug(
      `setAndLockPref: Set and locked pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Set the default value of a boolean Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {boolean} value - Preference value
   */
  setDefaultBoolPref(pref, value) {
    // Ensure we have a boolean value
    if (typeof value !== "boolean") {
      lazy.log.error(
        `setDefaultBoolPref: Value for pref: ${pref} is not a boolean: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_BOOL) {
      lazy.log.error(
        `setDefaultBoolPref: Pref type is not a boolean: ${pref}`
      );
      return;
    };

    // Set our preference
    _setDefaultPref(pref, value);
    lazy.log.debug(
      `setDefaultBoolPref: Set pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Set the user value of a boolean Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {boolean} value - Preference value
   */
  setUserBoolPref(pref, value) {
    // Ensure we have a boolean value
    if (typeof value !== "boolean") {
      lazy.log.error(
        `setUserBoolPref: Value for pref: ${pref} is not a boolean: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_BOOL) {
      lazy.log.error(
        `setUserBoolPref: Pref type is not a boolean: ${pref}`
      );
      return;
    };

    // Set our preference
    _setUserPref(pref, value);
    lazy.log.debug(
      `setUserBoolPref: Set pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Lock and set the default value of a boolean Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {boolean} value - Preference value
   */
  setAndLockBoolPref(pref, value) {
    // Ensure we have a boolean value
    if (typeof value !== "boolean") {
      lazy.log.error(
        `setAndLockBoolPref: Value for pref: ${pref} is not a boolean: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_BOOL) {
      lazy.log.error(
        `setAndLockBoolPref: Pref type is not a boolean: ${pref}`
      );
      return;
    };

    // Ensure our pref is unlocked
    if (Services.prefs.prefIsLocked(pref)) {
      Services.prefs.unlockPref(pref);
    };

    // Set our preference
    _setDefaultPref(pref, value);

    // Lock our preference
    Services.prefs.lockPref(pref);
    lazy.log.debug(
      `setAndLockBoolPref: Set and locked pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Unlock and set the default value of a boolean Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {boolean} value - Preference value
   */
  setAndUnlockBoolPref(pref, value) {
    // Ensure we have a boolean value
    if (typeof value !== "boolean") {
      lazy.log.error(
        `setAndUnlockBoolPref: Value for pref: ${pref} is not a boolean: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_BOOL) {
      lazy.log.error(
        `setAndUnlockBoolPref: Pref type is not a boolean: ${pref}`
      );
      return;
    };

    // Unlock our preference
    Services.prefs.unlockPref(pref);

    // Set our preference
    _setDefaultPref(pref, value);
    lazy.log.debug(
      `setAndUnlockBoolPref: Set and unlocked pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Set the default value of an integer Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {integer} value - Preference value
   */
  setDefaultIntPref(pref, value) {
    // Ensure we have an integer value
    if (typeof value !== "number" && !Number.isInteger(value)) {
      lazy.log.error(
        `setDefaultIntPref: Value for pref: ${pref} is not an integer: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_INT) {
      lazy.log.error(
        `setDefaultIntPref: Pref type is not an integer: ${pref}`
      );
      return;
    };

    // Set our pref
    _setDefaultPref(pref, value);
    lazy.log.debug(
      `setDefaultIntPref: Set pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Set the user value of an integer Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {integer} value - Preference value
   */
  setUserIntPref(pref, value) {
    // Ensure we have an integer value
    if (typeof value !== "number" && !Number.isInteger(value)) {
      lazy.log.error(
        `setUserIntPref: Value for pref: ${pref} is not an integer: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_INT) {
      lazy.log.error(
        `setUserIntPref: Pref type is not an integer: ${pref}`
      );
      return;
    };

    // Set our pref
    _setUserPref(pref, value);
    lazy.log.debug(
      `setUserIntPref: Set pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Lock and set the default value of an integer Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {integer} value - Preference value
   */
  setAndLockIntPref(pref, value) {
    // Ensure we have an integer value
    if (typeof value !== "number" && !Number.isInteger(value)) {
      lazy.log.error(
        `setAndLockIntPref: Value for pref: ${pref} is not an integer: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_INT) {
      lazy.log.error(
        `setAndLockIntPref: Pref type is not an integer: ${pref}`
      );
      return;
    };

    // Ensure our pref is unlocked
    if (Services.prefs.prefIsLocked(pref)) {
      Services.prefs.unlockPref(pref);
    };

    // Set our preference
    _setDefaultPref(pref, value);

    // Lock our preference
    Services.prefs.lockPref(pref);
    lazy.log.debug(
      `setAndLockIntPref: Set and locked pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Unlock and set the default value of an integer Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {integer} value - Preference value
   */
  setAndUnlockIntPref(pref, value) {
    // Ensure we have an integer value
    if (typeof value !== "number" && !Number.isInteger(value)) {
      lazy.log.error(
        `setAndUnlockIntPref: Value for pref: ${pref} is not an integer: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_INT) {
      lazy.log.error(
        `setAndUnlockIntPref: Pref type is not an integer: ${pref}`
      );
      return;
    };

    // Unlock our preference
    Services.prefs.unlockPref(pref);

    // Set our preference
    _setDefaultPref(pref, value);
    lazy.log.debug(
      `setAndUnlockIntPref: Set and unlocked pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Set the default value of a string Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {string} value - Preference value
   */
  setDefaultStringPref(pref, value) {
    // Ensure we have a string value
    if (typeof value !== "string") {
      lazy.log.error(
        `setDefaultStringPref: Value for pref: ${pref} is not a string: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_STRING) {
      lazy.log.error(
        `setDefaultStringPref: Pref type is not a string: ${pref}`
      );
      return;
    };

    // Set our pref
    _setDefaultPref(pref, value);
    lazy.log.debug(
      `setDefaultStringPref: Set pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Set the user value of a string Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {string} value - Preference value
   */
  setUserStringPref(pref, value) {
    // Ensure we have a string value
    if (typeof value !== "string") {
      lazy.log.error(
        `setUserStringPref: Value for pref: ${pref} is not a string: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_STRING) {
      lazy.log.error(
        `setUserStringPref: Pref type is not a string: ${pref}`
      );
      return;
    };

    // Set our pref
    _setUserPref(pref, value);
    lazy.log.debug(
      `setUserStringPref: Set pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Lock and set the default value of a string Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {string} value - Preference value
   */
  setAndLockStringPref(pref, value) {
    // Ensure we have a string value
    if (typeof value !== "string") {
      lazy.log.error(
        `setAndLockStringPref: Value for pref: ${pref} is not a string: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_STRING) {
      lazy.log.error(
        `setAndLockStringPref: Pref type is not a string: ${pref}`
      );
      return;
    };

    // Ensure our pref is unlocked
    if (Services.prefs.prefIsLocked(pref)) {
      Services.prefs.unlockPref(pref);
    };

    // Set our preference
    _setDefaultPref(pref, value);

    // Lock our preference
    Services.prefs.lockPref(pref);
    lazy.log.debug(
      `setAndLockStringPref: Set and locked pref: ${pref} to value: ${value}`
    );
  },

  /**
   * Unlock and set the default value of a string Gecko preference
   *
   * @param {string} pref - Preference name
   * @param {string} value - Preference value
   */
  setAndUnlockStringPref(pref, value) {
    // Ensure we have a string value
    if (typeof value !== "string") {
      lazy.log.error(
        `setAndUnlockStringPref: Value for pref: ${pref} is not a string: ${value}`
      );
      return;
    };

    // Check if our pref exists
    const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

    // Ensure our pref and value types match
    if (prefExists && Services.prefs.getPrefType(pref) !== Services.prefs.PREF_STRING) {
      lazy.log.error(
        `setAndUnlockStringPref: Pref type is not a string: ${pref}`
      );
      return;
    };

    // Unlock our preference
    Services.prefs.unlockPref(pref);

    // Set our preference
    _setDefaultPref(pref, value);
    lazy.log.debug(
      `setAndUnlockStringPref: Set and unlocked pref: ${pref} to value: ${value}`
    );
  }
};

// Helpers

/**
  * Return the value of a Gecko preference from a specified branch
  *
  * @param {string} pref - Preference name
  * @param {string} branch - Preference branch ("default" or "user")
  * @return {string | integer | boolean} - Preference value
  */
function getPrefFromBranch(pref, branch) {
  // Ensure we have a valid pref branch
  if (branch !== "default" && branch !== "user") {
    throw new Error(`getPrefFromBranch: Invalid branch (${branch}) for pref: ${pref}`);
  };

  // Confirm that the pref exists and actually has a value on our target branch
  if ((branch === "default" && !Services.prefs.prefHasDefaultValue(pref)) ||
   (branch === "user" && !Services.prefs.prefHasUserValue(pref))) {
    throw new Error(`getPrefFromBranch: Could not find pref: ${pref} on branch: ${branch}`);
  };

  // Check if our pref is locked
  const prefWasLocked = Services.prefs.prefIsLocked(pref);

  if (branch === "user" && prefWasLocked) {
    // If we're getting a user value, we need to ensure the pref is unlocked first to get our value
    Services.prefs.unlockPref(pref);
  };

  // Set our target pref branch
  const prefs =
    branch === "user"
      ? Services.prefs
      : Services.prefs.getDefaultBranch(null);

  const prefType = Services.prefs.getPrefType(pref);

  let prefValue;
  switch (prefType) {
    case Services.prefs.PREF_BOOL:
      prefValue = prefs.getBoolPref(pref);
      break;

    case Services.prefs.PREF_INT:
      prefValue = prefs.getIntPref(pref);
      break;

    case Services.prefs.PREF_STRING:
      prefValue = prefs.getStringPref(pref);
      break;

    default:
      throw new Error(`getPrefFromBranch: Unsupported type for pref: ${pref}`);
    };

  if (branch === "user" && prefWasLocked) {
    // We got our value, so re-lock the pref
    Services.prefs.lockPref(pref);
  };

  return prefValue;
};

/**
  * Return the *current* value of a Gecko preference
  * 
  * If the pref is locked OR doesn't have a user value: we return the default value
  * Otherwise: we return the user value
  *
  * @param {string} pref - Preference name
  * @return {string | integer | boolean} - Preference value
  */
function getCurrentValue(pref) {
  let branch;
  if (Services.prefs.prefIsLocked(pref) || !Services.prefs.prefHasUserValue(pref)) {
    branch = "default";
  } else if (Services.prefs.prefHasUserValue(pref)) {
    branch = "user";
  } else {
    throw new Error(`getCurrentValue: Pref missing value: ${pref}`);
  };
  return getPrefFromBranch(pref, branch);
};

/**
  * Set a Gecko preference to a default value
  *
  * @param {string} pref - Preference name
  * @param {string | integer | boolean} value - Preference value
  */
function _setDefaultPref(pref, value) {
  // Ensure we don't try to override a locked pref (since we're on the default branch)
  // Giving a locked pref a user value is fine, because the default/locked value
  // will still always be returned (unless the pref is unlocked; then we'll get the user value)
  if (Services.prefs.prefIsLocked(pref)) {
    throw new Error(`_setDefaultPref: Unable to override locked pref: ${pref}`);
  };

  // Set our target pref branch
  const prefs = Services.prefs.getDefaultBranch(null);

  // Check if our pref exists
  const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

  // Get our pref type
  let prefType;
  if (prefExists) {
    prefType = Services.prefs.getPrefType(pref);
  };

  switch (typeof value) {
    case "boolean":
      // Ensure the pref and value types match
      // (We don't want to set a boolean pref to a non-boolean value...)
      if (prefExists && prefType !== Services.prefs.PREF_BOOL) {
        throw new Error(
          `_setDefaultPref: Unable to set non-boolean pref: ${pref} to boolean value: ${value}`
        );
      };
      prefs.setBoolPref(pref, value);
      break;

    case "number":
      if (!Number.isInteger(value)) {
        throw new Error(`_setDefaultPref: Unable to set pref: ${pref} to non-integer value: ${value}`);
      }
      // Ensure the pref and value types match
      // (We don't want to set an integer pref to a non-integer value...)
      if (prefExists && prefType !== Services.prefs.PREF_INT) {
        throw new Error(
          `_setDefaultPref: Unable to set non-integer pref: ${pref} to integer value: ${value}`
        );
      };
      prefs.setIntPref(pref, value);
      break;

    case "string":
      // Ensure the pref and value types match
      // (We don't want to set a string pref to a non-string value...)
      if (prefExists && prefType !== Services.prefs.PREF_STRING) {
        throw new Error(
          `_setDefaultPref: Unable to set non-string pref: ${pref} to string value: ${value}`
        );
      };
      prefs.setStringPref(pref, value);
      break;

    default:
      throw new Error(`_setDefaultPref: Unsupported type for pref: ${pref}`);
  };
};

/**
  * Set a Gecko preference to a user value
  *
  * @param {string} pref - Preference name
  * @param {string | integer | boolean} value - Preference value
  */
function _setUserPref(pref, value) {
  // Set our target pref branch
  const defaultBranch = Services.prefs.getDefaultBranch(null);
  const prefs = Services.prefs;

  // Check if our pref exists
  const prefExists = Services.prefs.prefHasDefaultValue(pref) || Services.prefs.prefHasUserValue(pref);

  // Check if the pref is locked
  const prefWasLocked = Services.prefs.prefIsLocked(pref);

  // Get our pref type
  let prefType;
  if (prefExists) {
    prefType = Services.prefs.getPrefType(pref);
  };

  let valueMatchedDefault = false;

  switch (typeof value) {
    case "boolean":
      if (prefExists) {
        // Ensure the pref and value types match
        // (We don't want to set a boolean pref to a non-boolean value...)
        if (prefType !== Services.prefs.PREF_BOOL) {
          throw new Error(
            `_setUserPref: Unable to set non-boolean pref: ${pref} to boolean value: ${value}`
          );
        };

        // Firefox doesn't usually set a user pref if the default pref value matches
        // To work-around this, we can temporarily change the pref's default value, set our pref, and
        // revert it after
        if (value === defaultBranch.getBoolPref(pref)) {
          // Ensure the pref is unlocked (so we can actually change its default value...)
          Services.prefs.unlockPref(pref);
          
          defaultBranch.setBoolPref(pref, !value);
          valueMatchedDefault = true;
        };
      };
      prefs.setBoolPref(pref, value);
      if (valueMatchedDefault) {
        // We set our pref, so restore its default value
        defaultBranch.setBoolPref(pref, value);

        // If it was locked, re-lock it
        if (prefWasLocked) {
          Services.prefs.lockPref(pref);
        };
      };
      break;

    case "number":
      if (!Number.isInteger(value)) {
        throw new Error(`_setUserPref: Unable to set pref: ${pref} to non-integer value: ${value}`);
      }
      if (prefExists) {
        // Ensure the pref and value types match
        // (We don't want to set an integer pref to a non-integer value...)
        if (prefType !== Services.prefs.PREF_INT) {
          throw new Error(
            `_setUserPref: Unable to set non-integer pref: ${pref} to integer value: ${value}`
          );
        };

        // Firefox doesn't usually set a user pref if the default pref value matches
        // To work-around this, we can temporarily change the pref's default value, set our pref, and
        // revert it after
        if (value === defaultBranch.getIntPref(pref)) {
          // Ensure the pref is unlocked (so we can actually change its default value...)
          Services.prefs.unlockPref(pref);
          
          if (value === 0) {
            defaultBranch.setIntPref(pref, 1);
          } else {
            defaultBranch.setIntPref(pref, 0);
          };
          valueMatchedDefault = true;
        };
      };
      prefs.setIntPref(pref, value);
      if (valueMatchedDefault) {
        // We set our pref, so restore its default value
        defaultBranch.setIntPref(pref, value);

        // If it was locked, re-lock it
        if (prefWasLocked) {
          Services.prefs.lockPref(pref);
        };
      };
      break;

    case "string":
      if (prefExists) {
        // Ensure the pref and value types match
        // (We don't want to set a string pref to a non-string value...)
        if (prefType !== Services.prefs.PREF_STRING) {
          throw new Error(
            `_setUserPref: Unable to set non-string pref: ${pref} to string value: ${value}`
          );
        };

        // Firefox doesn't usually set a user pref if the default pref value matches
        // To work-around this, we can temporarily change the pref's default value, set our pref, and
        // revert it after
        if (value === defaultBranch.getStringPref(pref)) {
          // Ensure the pref is unlocked (so we can actually change its default value...)
          Services.prefs.unlockPref(pref);
          
          if (value === "_") {
            defaultBranch.setStringPref(pref, "-");
          } else {
            defaultBranch.setStringPref(pref, "_");
          };
          valueMatchedDefault = true;
        };
      };
      prefs.setStringPref(pref, value);
      if (valueMatchedDefault) {
        // We set our pref, so restore its default value
        defaultBranch.setStringPref(pref, value);

        // If it was locked, re-lock it
        if (prefWasLocked) {
          Services.prefs.lockPref(pref);
        };
      };
      break;

    default:
      throw new Error(`_setUserPref: Unsupported type for pref: ${pref}`);
  };
};
