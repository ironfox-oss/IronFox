package org.ironfoxoss.ironfox.utils

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.ext.getPreferenceKey

/**
 * IronFox Fenix Preference Utilities
 *
 * @param context Application context
 */
class IFPrefUtils(private val context: Context) {
  private val logger = Logger("IFPrefUtils")

  internal val sharedPrefs: SharedPreferences = context.components.settings.preferences

  /**
   * Clear a preference from a resource ID
   *
   * @param resID Resource ID
   */
  fun clearPref(resID: Int) {
    val pref = context.getPreferenceKey(resID)
    if (sharedPrefs.contains(pref)) {
      sharedPrefs.edit { remove(pref) }
    }
    logger.debug("clearPref: Cleared pref: '${pref}'")
  }

  /**
   * Clear a preference from a string
   *
   * @param pref Preference key
   */
  fun clearStrPref(pref: String) {
    if (sharedPrefs.contains(pref)) {
      sharedPrefs.edit { remove(pref) }
    }
    logger.debug("clearStrPref: Cleared pref: '${pref}'")
  }

  /**
   * Check if a preference from a resource ID exists
   *
   * @param resID Resource ID
   */
  fun prefExists(resID: Int): Boolean {
    val pref = context.getPreferenceKey(resID)
    return sharedPrefs.contains(pref)
  }

  /**
   * Check if a preference from a string exists
   *
   * @param pref Preference key
   */
  fun strPrefExists(pref: String): Boolean {
    return sharedPrefs.contains(pref)
  }

  /**
   * Return the current value of a boolean preference from a resource ID
   *
   * @param resID Resource ID
   */
  fun getBoolPref(resID: Int): Boolean {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      logger.warn("getBoolPref: Pref does not exist: '${pref}'")
    }
    return sharedPrefs.getBoolean(pref, false)
  }

  /**
   * Return the current value of a boolean preference from a string
   *
   * @param pref Preference key
   */
  fun getStrBoolPref(pref: String): Boolean {
    if (!sharedPrefs.contains(pref)) {
      logger.warn("getStrBoolPref: Pref does not exist: '${pref}'")
    }
    return sharedPrefs.getBoolean(pref, false)
  }

  /**
   * Return the current value of an integer preference from a resource ID
   *
   * @param resID Resource ID
   */
  fun getIntPref(resID: Int): Int {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      logger.warn("getIntPref: Pref does not exist: '${pref}'")
    }
    return sharedPrefs.getInt(pref, 0)
  }

  /**
   * Return the current value of an integer preference from a string
   *
   * @param pref Preference key
   */
  fun getStrIntPref(pref: String): Int {
    if (!sharedPrefs.contains(pref)) {
      logger.warn("getStrIntPref: Pref does not exist: '${pref}'")
    }
    return sharedPrefs.getInt(pref, 0)
  }

  /**
   * Return the current value of a string preference from a resource ID
   *
   * @param resID Resource ID
   */
  fun getStringPref(resID: Int): String {
    val pref = context.getPreferenceKey(resID)
    val sharedPrefValue = sharedPrefs.getString(pref, null)

    if (sharedPrefValue == null) {
      logger.warn("getStringPref: Pref does not exist: '${pref}'")
      return "does-not-exist"
    } else {
      return sharedPrefValue
    }
  }

  /**
   * Return the current value of a string preference from a string
   *
   * @param pref Preference key
   */
  fun getStrStringPref(pref: String): String {
    val sharedPrefValue = sharedPrefs.getString(pref, null)

    if (sharedPrefValue == null) {
      logger.warn("getStrStringPref: Pref does not exist: '${pref}'")
      return "does-not-exist"
    } else {
      return sharedPrefValue
    }
  }

  /**
   * Return the current value of a StringSet preference from a resource ID
   *
   * @param resID Resource ID
   */
  fun getStringSetPref(resID: Int): Set<String> {
    val pref = context.getPreferenceKey(resID)
    val sharedPrefValue = sharedPrefs.getStringSet(pref, null)

    if (sharedPrefValue == null) {
      logger.warn("getStringSetPref: Pref does not exist: '${pref}'")
      return emptySet()
    } else {
      return sharedPrefValue
    }
  }

  /**
   * Return the current value of a StringSet preference from a string
   *
   * @param pref Preference key
   */
  fun getStrStringSetPref(pref: String): Set<String> {
    val sharedPrefValue = sharedPrefs.getStringSet(pref, null)

    if (sharedPrefValue == null) {
      logger.warn("getStrStringSetPref: Pref does not exist: '${pref}'")
      return emptySet()
    } else {
      return sharedPrefValue
    }
  }

  /**
   * Return the current value of a float preference from a resource ID
   *
   * @param resID Resource ID
   */
  fun getFloatPref(resID: Int): Float {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      logger.warn("getFloatPref: Pref does not exist: '${pref}'")
    }
    return sharedPrefs.getFloat(pref, 0f)
  }

  /**
   * Return the current value of a float preference from a string
   *
   * @param pref Preference key
   */
  fun getStrFloatPref(pref: String): Float {
    if (!sharedPrefs.contains(pref)) {
      logger.warn("getStrFloatPref: Pref does not exist: '${pref}'")
    }
    return sharedPrefs.getFloat(pref, 0f)
  }

  /**
   * Return the current value of a long preference from a resource ID
   *
   * @param resID Resource ID
   */
  fun getLongPref(resID: Int): Long {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      logger.warn("getLongPref: Pref does not exist: '${pref}'")
    }
    return sharedPrefs.getLong(pref, 0L)
  }

  /**
   * Return the current value of a long preference from a string
   *
   * @param pref Preference key
   */
  fun getStrLongPref(pref: String): Long {
    if (!sharedPrefs.contains(pref)) {
      logger.warn("getStrLongPref: Pref does not exist: '${pref}'")
    }
    return sharedPrefs.getLong(pref, 0L)
  }

  /**
   * Set the value of a boolean preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setBoolPref(resID: Int, value: Boolean) {
    val pref = context.getPreferenceKey(resID)
    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getBoolean(pref, !value) == value)) {
      return
    }
    sharedPrefs.edit { putBoolean(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setBoolPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the value of a boolean preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrBoolPref(pref: String, value: Boolean) {
    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getBoolean(pref, !value) == value)) {
      return
    }
    sharedPrefs.edit { putBoolean(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setStrBoolPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the default value of a boolean preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setDefaultBoolPref(resID: Int, value: Boolean) {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putBoolean(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setDefaultBoolPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the default value of a boolean preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrDefaultBoolPref(pref: String, value: Boolean) {
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putBoolean(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setStrDefaultBoolPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the value of an integer preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setIntPref(resID: Int, value: Int) {
    val pref = context.getPreferenceKey(resID)
    // Determine the test value we should use
    val testValue = if (value == 0) {
      1
    } else {
      0
    }

    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getInt(pref, testValue) == value)) {
      return
    }

    sharedPrefs.edit { putInt(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setIntPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the value of an integer preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrIntPref(pref: String, value: Int) {
    // Determine the test value we should use
    val testValue = if (value == 0) {
      1
    } else {
      0
    }

    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getInt(pref, testValue) == value)) {
      return
    }

    sharedPrefs.edit { putInt(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setStrIntPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the default value of an integer preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setDefaultIntPref(resID: Int, value: Int) {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putInt(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setDefaultIntPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the default value of an integer preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrDefaultIntPref(pref: String, value: Int) {
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putInt(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setStrDefaultIntPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the value of a string preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setStringPref(resID: Int, value: String) {
    val pref = context.getPreferenceKey(resID)
    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getString(pref, null) == value)) {
      return
    }
    sharedPrefs.edit { putString(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setStringPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the value of a string preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrStringPref(pref: String, value: String) {
    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getString(pref, null) == value)) {
      return
    }
    sharedPrefs.edit { putString(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setStrStringPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the default value of a string preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setDefaultStringPref(resID: Int, value: String) {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putString(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setDefaultStringPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the default value of a string preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrDefaultStringPref(pref: String, value: String) {
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putString(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setStrDefaultStringPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the value of a StringSet preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setStringSetPref(resID: Int, value: Set<String>) {
    val pref = context.getPreferenceKey(resID)
    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getStringSet(pref, null) == value)) {
      return
    }
    sharedPrefs.edit { putStringSet(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setStringSetPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the value of a StringSet preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrStringSetPref(pref: String, value: Set<String>) {
    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getStringSet(pref, null) == value)) {
      return
    }
    sharedPrefs.edit { putStringSet(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setStrStringSetPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the default value of a StringSet preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setDefaultStringSetPref(resID: Int, value: Set<String>) {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putStringSet(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setDefaultStringSetPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the default value of a StringSet preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrDefaultStringSetPref(pref: String, value: Set<String>) {
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putStringSet(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setStrDefaultStringSetPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the value of a float preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setFloatPref(resID: Int, value: Float) {
    val pref = context.getPreferenceKey(resID)
    // Determine the test value we should use
    val testValue = if (value == 0f) {
      1f
    } else {
      0f
    }

    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getFloat(pref, testValue) == value)) {
      return
    }

    sharedPrefs.edit { putFloat(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setFloatPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the value of a float preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrFloatPref(pref: String, value: Float) {
    // Determine the test value we should use
    val testValue = if (value == 0f) {
      1f
    } else {
      0f
    }

    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getFloat(pref, testValue) == value)) {
      return
    }

    sharedPrefs.edit { putFloat(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setStrFloatPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the default value of a float preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setDefaultFloatPref(resID: Int, value: Float) {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putFloat(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setDefaultFloatPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the default value of a float preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrDefaultFloatPref(pref: String, value: Float) {
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putFloat(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setStrDefaultFloatPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the value of a long preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setLongPref(resID: Int, value: Long) {
    val pref = context.getPreferenceKey(resID)
    // Determine the test value we should use
    val testValue = if (value == 0L) {
      1L
    } else {
      0L
    }

    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getLong(pref, testValue) == value)) {
      return
    }

    sharedPrefs.edit { putLong(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setLongPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the value of a long preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrLongPref(pref: String, value: Long) {
    // Determine the test value we should use
    val testValue = if (value == 0L) {
      1L
    } else {
      0L
    }

    // If the pref values already match, we don't have to do anything
    if (sharedPrefs.contains(pref) && (sharedPrefs.getLong(pref, testValue) == value)) {
      return
    }

    sharedPrefs.edit { putLong(pref, value) }
    sharedPrefs.edit { commit() }
    logger.debug("setStrLongPref: Set pref: '${pref}' to value: '${value}'")
  }

  /**
   * Set the default value of a long preference from a resource ID
   *
   * @param resID Resource ID
   * @param value Preference value
   */
  fun setDefaultLongPref(resID: Int, value: Long) {
    val pref = context.getPreferenceKey(resID)
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putLong(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setDefaultLongPref: Set pref: '${pref}' to value: '${value}'")
    }
  }

  /**
   * Set the default value of a long preference from a string
   *
   * @param pref Preference key
   * @param value Preference value
   */
  fun setStrDefaultLongPref(pref: String, value: Long) {
    if (!sharedPrefs.contains(pref)) {
      sharedPrefs.edit { putLong(pref, value) }
      sharedPrefs.edit { commit() }
      logger.debug("setStrDefaultLongPref: Set pref: '${pref}' to value: '${value}'")
    }
  }
}
