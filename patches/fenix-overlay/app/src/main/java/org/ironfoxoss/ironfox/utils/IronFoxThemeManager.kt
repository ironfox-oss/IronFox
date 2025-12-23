package org.ironfoxoss.ironfox.utils

import android.content.Context
import androidx.compose.material3.ColorScheme
import mozilla.components.compose.base.theme.AcornColors
import mozilla.components.compose.base.theme.acornDarkColorScheme
import mozilla.components.compose.base.theme.darkColorPalette
import mozilla.components.compose.base.theme.toM3ColorScheme
import mozilla.components.ui.colors.PhotonColors

val oledColorPalette = darkColorPalette.copy(
	layer1 = PhotonColors.Black,
	layer2 = PhotonColors.DarkGrey90,
	layer3 = PhotonColors.DarkGrey80,
	layer4Start = PhotonColors.Black,
	layer4Center = PhotonColors.Black,
	layer4End = PhotonColors.Black,
	actionTertiary = PhotonColors.DarkGrey80,
	borderPrimary = PhotonColors.DarkGrey70,
)

fun acornOledColorScheme(): ColorScheme {
	val darkScheme = acornDarkColorScheme()
	return oledColorPalette.toM3ColorScheme(
		primary = darkScheme.primary,
		primaryContainer = darkScheme.primaryContainer,
		inversePrimary = darkScheme.inversePrimary,
		secondaryContainer = darkScheme.secondaryContainer,
		tertiaryContainer = darkScheme.tertiaryContainer,
		errorContainer = darkScheme.errorContainer,
		surface = PhotonColors.Black,
		inverseSurface = PhotonColors.LightGrey10,
		outline = PhotonColors.LightGrey90,
		outlineVariant = PhotonColors.DarkGrey30,
		surfaceBright = PhotonColors.DarkGrey70,
		surfaceContainer = PhotonColors.Black,
		surfaceContainerHigh = PhotonColors.DarkGrey70,
		surfaceContainerHighest = PhotonColors.DarkGrey60,
		surfaceContainerLow = PhotonColors.DarkGrey90,
		surfaceContainerLowest = PhotonColors.Black,
	)
}

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
