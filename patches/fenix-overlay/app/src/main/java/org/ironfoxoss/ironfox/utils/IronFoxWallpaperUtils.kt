package org.ironfoxoss.ironfox.utils

import android.content.Context
import org.ironfoxoss.ironfox.utils.IronFoxPreferences
import org.ironfoxoss.ironfox.utils.IronFoxWallpaperDictionary

// Helpers for managing IronFox wallpapers

object IronFoxWallpaperUtils {

    /**
     * Set our desired preferences to confirm that a wallpaper has been successfully copied
     *
     * @param context The application context
     * @param wallpaperName Name of the copied wallpaper
     */
    fun wallpapersCopied(
        context: Context,
        wallpaperName: String
    ) {
        if (wallpaperName == IronFoxWallpaperDictionary.ALGAE_WALLPAPER_NAME) {
            IronFoxPreferences.setWallpaperAlgaeCopied(context, true)
            IronFoxPreferences.setWallpaperAlgaeInstalledVersion(context, IronFoxWallpaperDictionary.ALGAE_WALLPAPER_CURRENT_VERSION)
        } else if (wallpaperName == IronFoxWallpaperDictionary.COLORFUL_BUBBLES_WALLPAPER_NAME) {
            IronFoxPreferences.setWallpaperColorfulBubblesCopied(context, true)
            IronFoxPreferences.setWallpaperColorfulBubblesInstalledVersion(context, IronFoxWallpaperDictionary.COLORFUL_BUBBLES_WALLPAPER_CURRENT_VERSION)
        } else if (wallpaperName == IronFoxWallpaperDictionary.DARK_DUNE_WALLPAPER_NAME) {
            IronFoxPreferences.setWallpaperDarkDuneCopied(context, true)
            IronFoxPreferences.setWallpaperDarkDuneInstalledVersion(context, IronFoxWallpaperDictionary.DARK_DUNE_WALLPAPER_CURRENT_VERSION)
        } else if (wallpaperName == IronFoxWallpaperDictionary.DUNE_WALLPAPER_NAME) {
            IronFoxPreferences.setWallpaperDuneCopied(context, true)
            IronFoxPreferences.setWallpaperDuneInstalledVersion(context, IronFoxWallpaperDictionary.DUNE_WALLPAPER_CURRENT_VERSION)
        } else if (wallpaperName == IronFoxWallpaperDictionary.FIREY_RED_WALLPAPER_NAME) {
            IronFoxPreferences.setWallpaperFireyRedCopied(context, true)
            IronFoxPreferences.setWallpaperFireyRedInstalledVersion(context, IronFoxWallpaperDictionary.FIREY_RED_WALLPAPER_CURRENT_VERSION)
        }
    }

    /**
     * Determine whether we should copy a wallpaper
     *
     * @param context The application context
     * @param wallpaperName Name of the wallpaper to check
     */
    fun shouldCopyWallpaper(
        context: Context,
        wallpaperName: String
    ): Boolean {
        if (wallpaperName == IronFoxWallpaperDictionary.ALGAE_WALLPAPER_NAME) {
            return shouldCopyWallpaperAlgae(context)
        } else if (wallpaperName == IronFoxWallpaperDictionary.COLORFUL_BUBBLES_WALLPAPER_NAME) {
            return shouldCopyWallpaperColorfulBubbles(context)
        } else if (wallpaperName == IronFoxWallpaperDictionary.DARK_DUNE_WALLPAPER_NAME) {
            return shouldCopyWallpaperDarkDune(context)
        } else if (wallpaperName == IronFoxWallpaperDictionary.DUNE_WALLPAPER_NAME) {
            return shouldCopyWallpaperDune(context)
        } else if (wallpaperName == IronFoxWallpaperDictionary.FIREY_RED_WALLPAPER_NAME) {
            return shouldCopyWallpaperFireyRed(context)
        } else {
            return false
        }
    }

    /**
     * Determine whether we should copy the Algae wallpaper
     *
     * @param context The application context
     */
    internal fun shouldCopyWallpaperAlgae(
        context: Context
    ): Boolean {
        val algaeWallpaperCopied = IronFoxPreferences.wallpaperAlgaeCopied(context)
        return (!algaeWallpaperCopied || shouldUpdateWallpaperAlgae(context))
    }

    /**
     * Determine whether we should copy the Colorful Bubbles wallpaper
     *
     * @param context The application context
     */
    internal fun shouldCopyWallpaperColorfulBubbles(
        context: Context
    ): Boolean {
        val colorfulBubblesWallpaperCopied = IronFoxPreferences.wallpaperColorfulBubblesCopied(context)
        return (!colorfulBubblesWallpaperCopied || shouldUpdateWallpaperColorfulBubbles(context))
    }

    /**
     * Determine whether we should copy the Dark Dune wallpaper
     *
     * @param context The application context
     */
    internal fun shouldCopyWallpaperDarkDune(
        context: Context
    ): Boolean {
        val darkDuneWallpaperCopied = IronFoxPreferences.wallpaperDarkDuneCopied(context)
        return (!darkDuneWallpaperCopied || shouldUpdateWallpaperDarkDune(context))
    }

    /**
     * Determine whether we should copy the Dune wallpaper
     *
     * @param context The application context
     */
    internal fun shouldCopyWallpaperDune(
        context: Context
    ): Boolean {
        val duneWallpaperCopied = IronFoxPreferences.wallpaperDuneCopied(context)
        return (!duneWallpaperCopied || shouldUpdateWallpaperDune(context))
    }

    /**
     * Determine whether we should copy the Firey Red wallpaper
     *
     * @param context The application context
     */
    internal fun shouldCopyWallpaperFireyRed(
        context: Context
    ): Boolean {
        val fireyRedWallpaperCopied = IronFoxPreferences.wallpaperFireyRedCopied(context)
        return (!fireyRedWallpaperCopied || shouldUpdateWallpaperFireyRed(context))
    }

    /**
     * Determine whether we should update the Algae wallpaper
     *
     * @param context The application context
     */
    internal fun shouldUpdateWallpaperAlgae(
        context: Context
    ): Boolean {
        val algaeWallpaperCurrentVersion = IronFoxWallpaperDictionary.ALGAE_WALLPAPER_CURRENT_VERSION
        val algaeWallpaperInstalledVersion = IronFoxPreferences.getWallpaperAlgaeInstalledVersion(context)
        if (algaeWallpaperCurrentVersion <= algaeWallpaperInstalledVersion) {
            return false
        } else {
            return true
        }
    }

    /**
     * Determine whether we should update the Colorful Bubbles wallpaper
     *
     * @param context The application context
     */
    internal fun shouldUpdateWallpaperColorfulBubbles(
        context: Context
    ): Boolean {
        val colorfulBubblesWallpaperCurrentVersion = IronFoxWallpaperDictionary.COLORFUL_BUBBLES_WALLPAPER_CURRENT_VERSION
        val colorfulBubblesWallpaperInstalledVersion = IronFoxPreferences.getWallpaperColorfulBubblesInstalledVersion(context)
        if (colorfulBubblesWallpaperCurrentVersion <= colorfulBubblesWallpaperInstalledVersion) {
            return false
        } else {
            return true
        }
    }

    /**
     * Determine whether we should update the Dark Dune wallpaper
     *
     * @param context The application context
     */
    internal fun shouldUpdateWallpaperDarkDune(
        context: Context
    ): Boolean {
        val darkDuneWallpaperCurrentVersion = IronFoxWallpaperDictionary.DARK_DUNE_WALLPAPER_CURRENT_VERSION
        val darkDuneWallpaperInstalledVersion = IronFoxPreferences.getWallpaperDarkDuneInstalledVersion(context)
        if (darkDuneWallpaperCurrentVersion <= darkDuneWallpaperInstalledVersion) {
            return false
        } else {
            return true
        }
    }

    /**
     * Determine whether we should update the Dune wallpaper
     *
     * @param context The application context
     */
    internal fun shouldUpdateWallpaperDune(
        context: Context
    ): Boolean {
        val duneWallpaperCurrentVersion = IronFoxWallpaperDictionary.DUNE_WALLPAPER_CURRENT_VERSION
        val duneWallpaperInstalledVersion = IronFoxPreferences.getWallpaperDuneInstalledVersion(context)
        if (duneWallpaperCurrentVersion <= duneWallpaperInstalledVersion) {
            return false
        } else {
            return true
        }
    }

    /**
     * Determine whether we should update the Firey Red wallpaper
     *
     * @param context The application context
     */
    internal fun shouldUpdateWallpaperFireyRed(
        context: Context
    ): Boolean {
        val fireyRedWallpaperCurrentVersion = IronFoxWallpaperDictionary.FIREY_RED_WALLPAPER_CURRENT_VERSION
        val fireyRedWallpaperInstalledVersion = IronFoxPreferences.getWallpaperFireyRedInstalledVersion(context)
        if (fireyRedWallpaperCurrentVersion <= fireyRedWallpaperInstalledVersion) {
            return false
        } else {
            return true
        }
    }
}
