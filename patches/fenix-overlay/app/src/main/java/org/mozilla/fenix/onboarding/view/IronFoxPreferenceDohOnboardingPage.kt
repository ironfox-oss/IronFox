package org.mozilla.fenix.onboarding.view

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.BoxWithConstraintsScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuAnchorType
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTag
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import mozilla.components.compose.base.button.FilledButton
import org.ironfoxoss.ironfox.utils.FenixStringsDictionary
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.ext.settings
import org.mozilla.fenix.settings.doh.CustomProviderErrorState
import org.mozilla.fenix.settings.doh.DefaultDohSettingsProvider
import org.mozilla.fenix.settings.doh.DohSettingsState
import org.mozilla.fenix.settings.doh.DohUrlValidator
import org.mozilla.fenix.settings.doh.ProtectionLevel
import org.mozilla.fenix.settings.doh.Provider
import org.mozilla.fenix.settings.doh.UrlValidationException
import org.mozilla.fenix.settings.doh.root.AlertDialogAddCustomProvider
import org.mozilla.fenix.theme.FirefoxTheme

/**
 * The default ratio of the image height to the parent height.
 */
private const val IMAGE_HEIGHT_RATIO_DEFAULT = 0.2f

/**
 * The ratio of the image height to the parent height for medium sized devices.
 */
private const val IMAGE_HEIGHT_RATIO_MEDIUM = 0.1f

/**
 * The ratio of the image height to the parent height for small devices.
 */
private const val IMAGE_HEIGHT_RATIO_SMALL = 0.05f

private sealed interface IfPreferenceDohContentState {
    data object ModeSelection : IfPreferenceDohContentState
    data object ProviderSelection : IfPreferenceDohContentState
}

@Composable
fun IronFoxPreferenceDohOnboardingPage(
    pageState: OnboardingPageState,
) {
    Surface {
        BoxWithConstraints {
            val boxWithConstraintsScope = this
            Column(
                modifier = Modifier
                    .padding(horizontal = 16.dp, vertical = 24.dp)
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState()),

                verticalArrangement = Arrangement.SpaceBetween,
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                with(pageState) {
                    Spacer(Modifier)

                    val size = remember { mainImageHeight(boxWithConstraintsScope) }

                    Image(
                        painter = painterResource(id = imageRes),
                        contentDescription = "",
                        modifier = Modifier.size(size),
                    )

                    Spacer(Modifier.height(16.dp))

                    Column(
                        modifier = Modifier.padding(vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                    ) {
                        Text(
                            text = title,
                            textAlign = TextAlign.Center,
                            style = FirefoxTheme.typography.headline5,
                        )

                        Text(
                            text = description,
                            textAlign = TextAlign.Center,
                            style = FirefoxTheme.typography.body2,
                        )
                    }

                    Spacer(Modifier.height(32.dp))

                    var contentState by remember {
                        mutableStateOf<IfPreferenceDohContentState>(
                            IfPreferenceDohContentState.ModeSelection,
                        )
                    }

                    val updateContentState = remember {
                        { newState: IfPreferenceDohContentState ->
                            contentState = newState
                        }
                    }

                    BackHandler(contentState != IfPreferenceDohContentState.ModeSelection) {
                        when (contentState) {
                            IfPreferenceDohContentState.ModeSelection -> {}
                            IfPreferenceDohContentState.ProviderSelection -> {
                                contentState = IfPreferenceDohContentState.ModeSelection
                            }
                        }
                    }

                    val context = LocalContext.current
                    val dohSettingsProvider = remember(context) {
                        DefaultDohSettingsProvider(
                            engine = context.components.core.engine,
                            settings = context.settings(),
                        )
                    }

                    var dohSettingsState by remember(dohSettingsProvider) {
                        mutableStateOf(
                            DohSettingsState(
                                allProtectionLevels = listOf(
                                    ProtectionLevel.Default,
                                    ProtectionLevel.Increased,
                                    ProtectionLevel.Max,
                                ),
                                selectedProtectionLevel = dohSettingsProvider.getSelectedProtectionLevel(),
                                providers = dohSettingsProvider.getDefaultProviders(),
                                selectedProvider = dohSettingsProvider.getSelectedProvider(),
                            ),
                        )
                    }

                    val updateDohSettingsState = remember {
                        { newState: DohSettingsState ->
                            dohSettingsState = newState
                        }
                    }

                    val captionText = when (contentState) {
                        IfPreferenceDohContentState.ModeSelection -> stringResource(
                            when (dohSettingsState.selectedProtectionLevel) {
                                ProtectionLevel.Default -> FenixStringsDictionary.dohDefaultSummary
                                ProtectionLevel.Increased -> FenixStringsDictionary.dohIncreasedSummary
                                ProtectionLevel.Max -> FenixStringsDictionary.dohMaxSummary
                                ProtectionLevel.Off -> FenixStringsDictionary.dohOffSummary
                            },
                            stringResource(FenixStringsDictionary.appName),
                        )

                        IfPreferenceDohContentState.ProviderSelection ->
                            when (val provider = dohSettingsState.selectedProvider) {
                                is Provider.BuiltIn -> provider.url
                                is Provider.Custom -> provider.url
                                null -> ""
                            }
                    }

                    AnimatedContent(
                        targetState = contentState,
                        contentAlignment = Alignment.Center,
                    ) { currentState ->
                        when (currentState) {
                            IfPreferenceDohContentState.ModeSelection -> {
                                IronFoxPreferenceDoHModeSelection(
                                    state = dohSettingsState,
                                    onUpdateState = updateDohSettingsState,
                                )
                            }

                            IfPreferenceDohContentState.ProviderSelection ->
                                IronFoxPreferenceDoHProviderSelection(
                                    state = dohSettingsState,
                                    dohSettingsProvider = dohSettingsProvider,
                                    onUpdateState = updateDohSettingsState,
                                )
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    Text(
                        text = captionText,
                        style = FirefoxTheme.typography.caption,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center,
                    )

                    Spacer(modifier = Modifier.height(32.dp))

                    FilledButton(
                        text = primaryButton.text,
                        modifier = Modifier
                            .width(width = FirefoxTheme.layout.size.maxWidth.small)
                            .semantics {
                                testTag = title + "onboarding_card.positive_button"
                            },
                        onClick = {
                            applyDohSettings(
                                contentState = contentState,
                                onContentStateChange = updateContentState,
                                state = dohSettingsState,
                                dohSettingsProvider = dohSettingsProvider,
                            )
                        },
                    )
                }
            }
        }
    }
}

private fun OnboardingPageState.applyDohSettings(
    contentState: IfPreferenceDohContentState,
    onContentStateChange: (IfPreferenceDohContentState) -> Unit,
    state: DohSettingsState,
    dohSettingsProvider: DefaultDohSettingsProvider,
) {
    when (contentState) {
        IfPreferenceDohContentState.ModeSelection -> {
            if (state.selectedProtectionLevel is ProtectionLevel.Increased
                || state.selectedProtectionLevel is ProtectionLevel.Max
            ) {
                onContentStateChange(IfPreferenceDohContentState.ProviderSelection)
            } else {
                dohSettingsProvider.setProtectionLevel(
                    state.selectedProtectionLevel,
                    state.selectedProvider,
                )
                primaryButton.onClick()
            }
        }

        IfPreferenceDohContentState.ProviderSelection -> {
            // apply settings
            dohSettingsProvider.setProtectionLevel(
                state.selectedProtectionLevel,
                state.selectedProvider,
            )

            // set custom provider, if any
            (state.selectedProvider as? Provider.Custom?)?.also { provider ->
                dohSettingsProvider.setCustomProvider(provider.url)
            }

            // then proceed to the next page
            primaryButton.onClick()
        }
    }
}

@Suppress("UnusedReceiverParameter")
@Composable
private fun ColumnScope.IronFoxPreferenceDoHModeSelection(
    state: DohSettingsState,
    modifier: Modifier = Modifier,
    onUpdateState: (DohSettingsState) -> Unit,
) {
    val onSelect = remember {
        { newLevel: ProtectionLevel ->
            onUpdateState(state.copy(selectedProtectionLevel = newLevel))
        }
    }

    Column(
        modifier = modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Column(
            modifier = Modifier.width(IntrinsicSize.Max),
        ) {
            state.allProtectionLevels.forEach { level ->
                val selected = remember { level == state.selectedProtectionLevel }
                ModeSelectionRadioButton(
                    selected = selected,
                    onSelect = onSelect,
                    level = level,
                    state = state,
                )
            }
        }
    }
}

@Composable
private fun ModeSelectionRadioButton(
    selected: Boolean,
    onSelect: (ProtectionLevel) -> Unit,
    level: ProtectionLevel,
    state: DohSettingsState,
) {
    Row(
        modifier = Modifier
            .height(48.dp)
            .selectable(
                selected = selected,
                enabled = true,
                onClick = { onSelect(level) },
            )
            .padding(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        RadioButton(
            selected = state.selectedProtectionLevel == level,
            onClick = null,
            colors = RadioButtonDefaults.colors(selectedColor = ButtonDefaults.buttonColors().containerColor),
        )

        Text(
            text = stringResource(
                when (level) {
                    ProtectionLevel.Default -> FenixStringsDictionary.dohDefaultPreference
                    ProtectionLevel.Increased -> FenixStringsDictionary.dohIncreasedPreference
                    ProtectionLevel.Max -> FenixStringsDictionary.dohMaxPreference
                    ProtectionLevel.Off -> FenixStringsDictionary.dohOffSummary
                },
            ),
            style = FirefoxTheme.typography.body1,
            modifier = Modifier.padding(start = 16.dp),
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Suppress("UnusedReceiverParameter")
@Composable
private fun ColumnScope.IronFoxPreferenceDoHProviderSelection(
    state: DohSettingsState,
    dohSettingsProvider: DefaultDohSettingsProvider,
    modifier: Modifier = Modifier,
    onUpdateState: (DohSettingsState) -> Unit,
) {
    var expanded by remember {
        mutableStateOf(false)
    }

    val setProvider = remember {
        { newProvider: Provider, showCustomProviderDialog: Boolean ->
            onUpdateState(
                state.copy(
                    selectedProvider = newProvider,
                    isCustomProviderDialogOn = showCustomProviderDialog,
                ),
            )
        }
    }

    val providerName: (@Composable (Provider) -> String) = remember {
        { provider ->
            when (provider) {
                is Provider.BuiltIn -> provider.name
                is Provider.Custom -> stringResource(FenixStringsDictionary.dohCustomPreference)
            }
        }
    }

    Column(
        modifier = modifier,
    ) {
        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = it },
        ) {
            OutlinedTextField(
                modifier = Modifier.fillMaxWidth()
                    .menuAnchor(ExposedDropdownMenuAnchorType.PrimaryEditable, true),
                value = providerName(state.selectedProvider!!),
                onValueChange = {},
                readOnly = true,
                label = {
                    Text(
                        text = stringResource(FenixStringsDictionary.dohChooseProviderPreference),
                        modifier = Modifier.padding(top = 14.dp)
                    )
                },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            )

            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false },
            ) {
                state.providers.forEach { provider ->
                    DropdownMenuItem(
                        text = {
                            Text(
                                text = providerName(provider),
                                style = FirefoxTheme.typography.body1,
                                color = MaterialTheme.colorScheme.onSurface,
                            )
                        },
                        onClick = {
                            setProvider(provider, provider is Provider.Custom)
                            expanded = false
                        },
                    )
                }
            }
        }

        if (state.selectedProvider is Provider.Custom && state.isCustomProviderDialogOn) {
            AlertDialogAddCustomProvider(
                customProviderUrl = state.selectedProvider.url,
                customProviderErrorState = state.customProviderErrorState,
                onCustomCancelClicked = {

                    // user cancelled the dialog, reset provider to default
                    onUpdateState(
                        state.copy(
                            selectedProvider = dohSettingsProvider.getDefaultProviders().first(),
                        ),
                    )
                },
                onCustomAddClicked = { input ->
                    try {
                        val validUrl = DohUrlValidator.validate(input)
                        onUpdateState(
                            state.copy(
                                customProviderErrorState = CustomProviderErrorState.Valid,
                                selectedProvider = Provider.Custom(validUrl),
                                isCustomProviderDialogOn = false,
                            ),
                        )
                    } catch (e: UrlValidationException.NonHttpsUrlException) {
                        onUpdateState(
                            state.copy(
                                customProviderErrorState = CustomProviderErrorState.NonHttps,
                            ),
                        )
                    } catch (e: UrlValidationException.InvalidUrlException) {
                        onUpdateState(
                            state.copy(
                                customProviderErrorState = CustomProviderErrorState.Invalid,
                            ),
                        )
                    }
                },
            )
        }
    }
}

private fun mainImageHeight(boxWithConstraintsScope: BoxWithConstraintsScope): Dp {
    val imageHeightRatio: Float = when {
        boxWithConstraintsScope.maxHeight <= ONBOARDING_SMALL_DEVICE -> IMAGE_HEIGHT_RATIO_SMALL
        boxWithConstraintsScope.maxHeight <= ONBOARDING_MEDIUM_DEVICE -> IMAGE_HEIGHT_RATIO_MEDIUM
        else -> IMAGE_HEIGHT_RATIO_DEFAULT
    }
    return boxWithConstraintsScope.maxHeight.times(imageHeightRatio)
}
