package org.ironfoxoss.ironfox.utils

import android.content.res.Configuration
import org.mozilla.fenix.R

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
    if (wallpaperName == "algae") {
      return R.drawable.algae_landscape
    } else if (wallpaperName == "black") {
      return R.drawable.black_landscape
    } else if (wallpaperName == "colorful-bubbles") {
      return R.drawable.colorful_bubbles_landscape
    } else if (wallpaperName == "dark-dune") {
      return R.drawable.dark_dune_landscape
    } else if (wallpaperName == "deep-blue") {
      return R.drawable.deep_blue_landscape
    } else if (wallpaperName == "dune") {
      return R.drawable.dune_landscape
    } else if (wallpaperName == "firey-red") {
      return R.drawable.firey_red_landscape
    } else if (wallpaperName == "red") {
      return R.drawable.red_landscape
    } else if (wallpaperName == "white") {
      return R.drawable.white_landscape
    } else {
      return R.drawable.pink_landscape
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
    if (wallpaperName == "algae") {
      return R.drawable.algae_portrait
    } else if (wallpaperName == "black") {
      return R.drawable.black_portrait
    } else if (wallpaperName == "colorful-bubbles") {
      return R.drawable.colorful_bubbles_portrait
    } else if (wallpaperName == "dark-dune") {
      return R.drawable.dark_dune_portrait
    } else if (wallpaperName == "deep-blue") {
      return R.drawable.deep_blue_portrait
    } else if (wallpaperName == "dune") {
      return R.drawable.dune_portrait
    } else if (wallpaperName == "firey-red") {
      return R.drawable.firey_red_portrait
    } else if (wallpaperName == "red") {
      return R.drawable.red_portrait
    } else if (wallpaperName == "white") {
      return R.drawable.white_portrait
    } else {
      return R.drawable.pink_portrait
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
    if (wallpaperName == "algae") {
      return R.drawable.algae_thumbnail
    } else if (wallpaperName == "black") {
      return R.drawable.black_thumbnail
    } else if (wallpaperName == "colorful-bubbles") {
      return R.drawable.colorful_bubbles_thumbnail
    } else if (wallpaperName == "dark-dune") {
      return R.drawable.dark_dune_thumbnail
    } else if (wallpaperName == "deep-blue") {
      return R.drawable.deep_blue_thumbnail
    } else if (wallpaperName == "dune") {
      return R.drawable.dune_thumbnail
    } else if (wallpaperName == "firey-red") {
      return R.drawable.firey_red_thumbnail
    } else if (wallpaperName == "red") {
      return R.drawable.red_thumbnail
    } else if (wallpaperName == "white") {
      return R.drawable.white_thumbnail
    } else {
      return R.drawable.pink_thumbnail
    }
  }
}
