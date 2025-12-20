package org.ironfoxoss.ironfox.utils

import android.content.Context

object IronFoxConstants {

    /**
     * Check whether we are on a nightly build
     *
     * @param context The application context
     */
    fun isNightly(
        context: Context,
    ): Boolean {
        if (releaseChannel(context) == "nightly") {
            return true
        } else {
            return false
        }
    }

    /**
     * Check whether we are on a release build
     *
     * @param context The application context
     */
    fun isRelease(
        context: Context,
    ): Boolean {
        if (releaseChannel(context) == "release") {
            return true
        } else {
            return false
        }
    }

    /**
     * Determine our current release channel
     *
     * @param context The application context
     */
    fun releaseChannel(
        context: Context,
    ): String {
        if (context.packageName == "org.ironfoxoss.ironfox.nightly") {
            return "nightly"
        } else {
            return "release"
        }
    }

}
