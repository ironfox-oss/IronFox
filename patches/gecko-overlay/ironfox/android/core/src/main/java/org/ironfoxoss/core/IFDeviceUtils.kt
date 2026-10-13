package org.ironfoxoss.core

import android.content.Context
import android.content.pm.ActivityInfo
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.content.res.Resources

/**
 * IronFox Device Utilities
 *
 */
object IFDeviceUtils {
  /**
   * Check if we are on an Android TV (or Fire TV) device
   *
   * @param context Application context
   */
  fun isTV(context: Context): Boolean {
    val resources: Resources = context.resources
    val packageManager: PackageManager = context.packageManager

    val uiMode: Int = resources.configuration.uiMode
    val uiModeType = uiMode and Configuration.UI_MODE_TYPE_MASK

    return uiModeType == Configuration.UI_MODE_TYPE_TELEVISION ||
      packageManager.hasSystemFeature("amazon.hardware.fire_tv") ||
      packageManager.hasSystemFeature("com.google.android.tv") ||
      packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK) ||
      packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK_ONLY) ||
      packageManager.hasSystemFeature(PackageManager.FEATURE_LIVE_TV) ||
      @Suppress("DEPRECATION") packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION)
  }

  // Get landscape mode
  const val landscapeMode: Int = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
}
