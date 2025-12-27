package org.ironfoxoss.ironfox.utils

import android.content.res.Configuration
import org.ironfoxoss.ironfox.utils.IronFoxWallpaperDictionary

// Helpers for managing IronFox wallpapers

object IronFoxWallpaperUtils {

    /**
     * Get a wallpaper's drawable resource
     *
     * @param wallpaperName The name of the wallpaper
     * @param orientation The desired wallpaper orientation
     */
    fun getWallpaperDrawable(
        wallpaperName: String,
        orientation: Int
    ): Int {
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            return getWallpaperDrawableLandscape(wallpaperName)
        } else {
            return getWallpaperDrawablePortrait(wallpaperName)
        }
    }

    /**
     * Get a wallpaper's landscape drawable resource
     *
     * @param wallpaperName The name of the wallpaper
     */
    internal fun getWallpaperDrawableLandscape(
        wallpaperName: String
    ): Int {
        if (wallpaperName == IronFoxWallpaperDictionary.algaeWallpaperName) {
            return IronFoxWallpaperDictionary.algaeLandscapeDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.blackWallpaperName) {
            return IronFoxWallpaperDictionary.blackLandscapeDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.colorfulBubblesWallpaperName) {
            return IronFoxWallpaperDictionary.colorfulBubblesLandscapeDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.darkDuneWallpaperName) {
            return IronFoxWallpaperDictionary.darkDuneLandscapeDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.deepBlueWallpaperName) {
            return IronFoxWallpaperDictionary.deepBlueLandscapeDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.duneWallpaperName) {
            return IronFoxWallpaperDictionary.duneLandscapeDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.fireyRedWallpaperName) {
            return IronFoxWallpaperDictionary.fireyRedLandscapeDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.redWallpaperName) {
            return IronFoxWallpaperDictionary.redLandscapeDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.whiteWallpaperName) {
            return IronFoxWallpaperDictionary.whiteLandscapeDrawable
        } else {
            return IronFoxWallpaperDictionary.pinkLandscapeDrawable
        }
    }

    /**
     * Get a wallpaper's portrait drawable resource
     *
     * @param wallpaperName The name of the wallpaper
     */
    internal fun getWallpaperDrawablePortrait(
        wallpaperName: String
    ): Int {
        if (wallpaperName == IronFoxWallpaperDictionary.algaeWallpaperName) {
            return IronFoxWallpaperDictionary.algaePortraitDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.blackWallpaperName) {
            return IronFoxWallpaperDictionary.blackPortraitDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.colorfulBubblesWallpaperName) {
            return IronFoxWallpaperDictionary.colorfulBubblesPortraitDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.darkDuneWallpaperName) {
            return IronFoxWallpaperDictionary.darkDunePortraitDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.deepBlueWallpaperName) {
            return IronFoxWallpaperDictionary.deepBluePortraitDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.duneWallpaperName) {
            return IronFoxWallpaperDictionary.dunePortraitDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.fireyRedWallpaperName) {
            return IronFoxWallpaperDictionary.fireyRedPortraitDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.redWallpaperName) {
            return IronFoxWallpaperDictionary.redPortraitDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.whiteWallpaperName) {
            return IronFoxWallpaperDictionary.whitePortraitDrawable
        } else {
            return IronFoxWallpaperDictionary.pinkPortraitDrawable
        }
    }

    /**
     * Get a wallpaper's thumbnail drawable resource
     *
     * @param wallpaperName The name of the wallpaper
     */
    fun getWallpaperDrawableThumbnail(
        wallpaperName: String
    ): Int {
        if (wallpaperName == IronFoxWallpaperDictionary.algaeWallpaperName) {
            return IronFoxWallpaperDictionary.algaeThumbnailDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.blackWallpaperName) {
            return IronFoxWallpaperDictionary.blackThumbnailDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.colorfulBubblesWallpaperName) {
            return IronFoxWallpaperDictionary.colorfulBubblesThumbnailDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.darkDuneWallpaperName) {
            return IronFoxWallpaperDictionary.darkDuneThumbnailDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.deepBlueWallpaperName) {
            return IronFoxWallpaperDictionary.deepBlueThumbnailDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.duneWallpaperName) {
            return IronFoxWallpaperDictionary.duneThumbnailDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.fireyRedWallpaperName) {
            return IronFoxWallpaperDictionary.fireyRedThumbnailDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.redWallpaperName) {
            return IronFoxWallpaperDictionary.redThumbnailDrawable
        } else if (wallpaperName == IronFoxWallpaperDictionary.whiteWallpaperName) {
            return IronFoxWallpaperDictionary.whiteThumbnailDrawable
        } else {
            return IronFoxWallpaperDictionary.pinkThumbnailDrawable
        }
    }
}
