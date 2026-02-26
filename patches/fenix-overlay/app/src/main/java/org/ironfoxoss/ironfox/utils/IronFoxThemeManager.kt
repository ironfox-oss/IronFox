package org.ironfoxoss.ironfox.utils

import android.content.Context
import androidx.compose.material3.ColorScheme
import mozilla.components.compose.base.theme.AcornColors
import mozilla.components.compose.base.theme.acornDarkColorScheme
import mozilla.components.compose.base.theme.buildColorScheme
import mozilla.components.compose.base.theme.darkColorPalette
import mozilla.components.ui.colors.PhotonColors

val oledColorPalette = darkColorPalette.copy(
	layer2 = PhotonColors.DarkGrey90,
	layer3 = PhotonColors.DarkGrey80,
)

val darkScheme = acornDarkColorScheme()

fun acornOledColorScheme(): ColorScheme = buildColorScheme(
	primary = darkScheme.primary,
	primaryContainer = darkScheme.primaryContainer,
	inversePrimary = darkScheme.inversePrimary,
    secondary = darkScheme.secondary,
	secondaryContainer = darkScheme.secondaryContainer,
    tertiary = darkScheme.tertiary,
	tertiaryContainer = darkScheme.tertiaryContainer,
	surface = PhotonColors.Black,
    onSurface = darkScheme.onSurface,
    surfaceTint = darkScheme.surfaceTint,
	inverseSurface = PhotonColors.LightGrey10,
    inverseOnSurface = PhotonColors.DarkGrey60,
    error = darkScheme.error,
	errorContainer = darkScheme.errorContainer,
	outline = PhotonColors.LightGrey90,
	outlineVariant = PhotonColors.DarkGrey30,
    scrim = darkScheme.scrim,
	surfaceBright = PhotonColors.DarkGrey70,
    surfaceDim = darkScheme.surfaceDim,
	surfaceContainer = PhotonColors.Black,
	surfaceContainerHigh = PhotonColors.DarkGrey70,
	surfaceContainerHighest = PhotonColors.DarkGrey60,
	surfaceContainerLow = PhotonColors.DarkGrey90,
	surfaceContainerLowest = PhotonColors.Black,
)

fun AcornColors.maybeApplyOledColors(context: Context): AcornColors {
	if (IronFoxPreferences.shouldUseOledTheme(context)) {
		return oledColorPalette
	}

	return this
}

fun ColorScheme.maybeApplyOledColors(context: Context): ColorScheme {
	if (IronFoxPreferences.shouldUseOledTheme(context)) {
		return acornOledColorScheme()
	}

	return this
}
