package org.ironfoxoss.ironfox.utils

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.platform.LocalContext
import mozilla.components.compose.base.theme.AcornColors
import mozilla.components.compose.base.theme.AcornTheme
import mozilla.components.compose.base.theme.acornDarkColorScheme
import mozilla.components.compose.base.theme.acornLightColorScheme
import mozilla.components.compose.base.theme.acornPrivateColorScheme
import mozilla.components.compose.base.theme.darkColorPalette
import mozilla.components.compose.base.theme.lightColorPalette
import mozilla.components.compose.base.theme.privateColorPalette
import mozilla.components.compose.base.theme.toM3ColorScheme
import mozilla.components.compose.base.utils.inComposePreview
import mozilla.components.ui.colors.PhotonColors
import org.mozilla.fenix.ext.settings
import org.mozilla.fenix.theme.Theme
import org.mozilla.fenix.theme.Theme.Dark
import org.mozilla.fenix.theme.Theme.Light
import org.mozilla.fenix.theme.Theme.Oled
import org.mozilla.fenix.theme.Theme.Private

/**
 * @author Akash Yadav
 */
object IronFoxThemeManager {

	@Composable
	@ReadOnlyComposable
	fun getTheme(allowPrivateTheme: Boolean = true): Theme {
		if (allowPrivateTheme &&
			!inComposePreview &&
			LocalContext.current.settings().lastKnownMode.isPrivate
		) {
			return Private
		}

		if (isSystemInDarkTheme()) {
			if (LocalContext.current.settings().ironfox.shouldUseOledTheme) {
				return Oled
			}

			return Dark
		}

		return Light
	}
}

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

@Composable
fun IronFoxTheme(
	theme: Theme = IronFoxThemeManager.getTheme(),
	content: @Composable () -> Unit,
) {
	val colors: AcornColors = when (theme) {
		Light -> lightColorPalette
		Dark -> darkColorPalette
		Oled -> oledColorPalette
		Private -> privateColorPalette
	}

	val colorScheme: ColorScheme = when (theme) {
		Light -> acornLightColorScheme()
		Dark -> acornDarkColorScheme()
		Oled -> acornOledColorScheme()
		Private -> acornPrivateColorScheme()
	}

	AcornTheme(
		colors = colors,
		colorScheme = colorScheme,
		content = content,
	)
}
