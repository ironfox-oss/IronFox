package org.mozilla.fenix.onboarding.view

import android.content.Context
import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.BoxWithConstraintsScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.compose.base.button.FilledButton
import mozilla.components.support.base.log.logger.Logger
import org.ironfoxoss.ironfox.utils.IronFoxAddons
import org.ironfoxoss.ironfox.utils.IronFoxPreferences
import org.mozilla.fenix.R
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.onboarding.view.IfPreferencesContentState.Configuration
import org.mozilla.fenix.onboarding.view.IfPreferencesContentState.Error
import org.mozilla.fenix.onboarding.view.IfPreferencesContentState.Progress
import org.mozilla.fenix.theme.FirefoxTheme

/**
 * The default ratio of the image height to the parent height.
 */
private const val IMAGE_HEIGHT_RATIO_DEFAULT = 0.2f

/**
 * The ratio of the image height to the parent height for medium sized devices.
 */
private const val IMAGE_HEIGHT_RATIO_MEDIUM = 0.15f

/**
 * The ratio of the image height to the parent height for small devices.
 */
private const val IMAGE_HEIGHT_RATIO_SMALL = 0.1f

private sealed interface IfPreferencesContentState {

    /**
     * Show IronFox preference switches.
     */
    data class Configuration(
        val optionIndex: Int,
    ) : IfPreferencesContentState

    /**
     * Show a progress bar with a message.
     */
    data class Progress(val message: String) : IfPreferencesContentState

    /**
     * Show an error message.
     */
    data class Error(val message: String) : IfPreferencesContentState
}

private data class IfPreferencesSwitchStates(
    val jitEnabled: Boolean = false,
    val safeBrowsingEnabled: Boolean = true,
    val spoofEnglish: Boolean = true,
    val installUBlock: Boolean = true,
)

private val logger = Logger("IronFoxOnboardingPreferences")

@Composable
fun IronFoxPreferencesOnboardingPage(
    pageState: OnboardingPageState,
) {
    BoxWithConstraints {
        val boxWithConstraintsScope = this
        Column(
            modifier = Modifier
                .background(FirefoxTheme.colors.layer1)
                .padding(horizontal = 16.dp, vertical = 24.dp)
                .fillMaxSize()
                .verticalScroll(rememberScrollState()),

            verticalArrangement = Arrangement.SpaceBetween,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            with(pageState) {
                Spacer(Modifier)

                Image(
                    painter = painterResource(id = imageRes),
                    contentDescription = "",
                    modifier = Modifier.height(mainImageHeight(boxWithConstraintsScope)),
                )

                Spacer(Modifier.height(16.dp))

                val preferenceOptions = remember { ifPreferenceOptions!! }
                var currentPreferenceIndex by remember { mutableIntStateOf(0) }

                var contentState by remember {
                    mutableStateOf<IfPreferencesContentState>(
                        Configuration(currentPreferenceIndex),
                    )
                }

                var switchStates by remember {
                    mutableStateOf(IfPreferencesSwitchStates())
                }

                val context = LocalContext.current
                val onContentStateChange = remember {
                    { newState: IfPreferencesContentState ->
                        contentState = newState
                    }
                }

                val applyPreference: suspend (IfPreferenceOption) -> Unit =
                    remember(context, switchStates, primaryButton, onContentStateChange) {
                        { option ->
                            applyPreference(
                                context,
                                option,
                                switchStates,
                                onContentStateChange,
                            )
                        }
                    }

                val applyAction: () -> Unit = remember(
                    applyPreference,
                    preferenceOptions,
                    currentPreferenceIndex,
                    onContentStateChange,
                    primaryButton,
                ) {
                    {
                        CoroutineScope(Dispatchers.Default).launch {
                            applyPreference(preferenceOptions[currentPreferenceIndex])
                            if (currentPreferenceIndex < preferenceOptions.lastIndex) {
                                onContentStateChange(Configuration(++currentPreferenceIndex))
                            } else {
                                withContext(Dispatchers.Main) {
                                    primaryButton.onClick()
                                }
                            }
                        }
                    }
                }

                BackHandler(currentPreferenceIndex > 0) {
                    onContentStateChange(Configuration(--currentPreferenceIndex))
                }

                (contentState as? Configuration?)?.also { configuration ->
                    Text(
                        text = title,
                        color = FirefoxTheme.colors.textPrimary,
                        textAlign = TextAlign.Center,
                        style = FirefoxTheme.typography.headline5,
                    )

                    Spacer(Modifier.height(8.dp))

                    Text(
                        text = preferenceOptions[configuration.optionIndex].caption,
                        color = FirefoxTheme.colors.textPrimary,
                        textAlign = TextAlign.Center,
                        style = FirefoxTheme.typography.body2,
                    )
                }

                Spacer(Modifier.height(32.dp))

                AnimatedContent(
                    targetState = contentState,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                ) { currentState ->
                    when (currentState) {
                        is Configuration -> IronFoxPreferenceConfiguration(
                            option = preferenceOptions[currentState.optionIndex],
                            modifier = Modifier.fillMaxSize(),
                            state = switchStates,
                            onUpdateSwitchStates = { newSwitchStates ->
                                switchStates = newSwitchStates
                            },
                        )

                        is Progress -> IronFoxPreferencesProgress(
                            state = currentState,
                        )

                        is Error -> IronFoxPreferencesError(
                            state = currentState,
                            onRetry = applyAction,
                        )
                    }
                }

                if (contentState is Configuration) {
                    Spacer(modifier = Modifier.height(16.dp))

                    FilledButton(
                        text = if (preferenceOptions.lastIndex == currentPreferenceIndex) {
                            primaryButton.text
                        } else {
                            stringResource(R.string.onboarding_save_and_continue_button)
                        },
                        modifier = Modifier
                            .width(width = FirefoxTheme.layout.size.maxWidth.small)
                            .semantics {
                                testTag = title + "onboarding_card.positive_button"
                            },
                        onClick = applyAction,
                    )
                }
            }
        }
    }
}

@Composable
private fun IronFoxPreferenceConfiguration(
    option: IfPreferenceOption,
    state: IfPreferencesSwitchStates,
    onUpdateSwitchStates: (IfPreferencesSwitchStates) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier) {
        IronFoxPreferenceSwitchItem(
            option = option,
            isChecked = when (option.preferenceType) {
                IfPreferenceType.JS_JIT -> state.jitEnabled
                IfPreferenceType.INSTALL_UBLOCK -> state.installUBlock
                IfPreferenceType.SAFE_BROWSING -> state.safeBrowsingEnabled
                IfPreferenceType.SPOOF_ENGLISH -> state.spoofEnglish
                IfPreferenceType.DEFAULT -> throw UnsupportedOperationException()
            },
            modifier = Modifier
                .fillMaxWidth()
                .wrapContentHeight(),
            onPreferenceChange = { type ->
                onUpdateSwitchStates(
                    when (type) {
                        IfPreferenceType.JS_JIT -> state.copy(jitEnabled = !state.jitEnabled)
                        IfPreferenceType.INSTALL_UBLOCK -> state.copy(installUBlock = !state.installUBlock)
                        IfPreferenceType.SAFE_BROWSING -> state.copy(safeBrowsingEnabled = !state.safeBrowsingEnabled)
                        IfPreferenceType.SPOOF_ENGLISH -> state.copy(spoofEnglish = !state.spoofEnglish)
                        IfPreferenceType.DEFAULT -> throw UnsupportedOperationException()
                    },
                )
            },
        )

        Spacer(modifier = Modifier.height(32.dp))

        Text(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth(),
            text = option.description,
            style = FirefoxTheme.typography.body2,
            color = FirefoxTheme.colors.textSecondary,
        )
    }
}

private suspend fun applyPreference(
    context: Context,
    option: IfPreferenceOption,
    state: IfPreferencesSwitchStates,
    onContentStateChange: (IfPreferencesContentState) -> Unit,
) {
    when (option.preferenceType) {
        IfPreferenceType.DEFAULT -> {}
        IfPreferenceType.JS_JIT -> {
            IronFoxPreferences.setJITEnabled(
                context,
                state.jitEnabled,
            )
        }

        IfPreferenceType.SAFE_BROWSING -> {
            IronFoxPreferences.setSafeBrowsingEnabled(
                context,
                state.safeBrowsingEnabled,
            )
        }

        IfPreferenceType.SPOOF_ENGLISH -> {
            IronFoxPreferences.setSpoofEnglishEnabled(
                context,
                state.spoofEnglish,
            )
        }

        IfPreferenceType.INSTALL_UBLOCK -> {
            installUBlockOrigin(
                context,
                state.installUBlock,
                onContentStateChange,
            )
        }
    }
}

private suspend fun installUBlockOrigin(
    context: Context,
    shouldInstallUBlock: Boolean,
    onContentStateChange: (IfPreferencesContentState) -> Unit,
) {
    onContentStateChange(
        Progress(
            context.getString(R.string.onboarding_state_installing_ublock),
        ),
    )

    if (!shouldInstallUBlock) {
        return
    }

    val components = context.components
    val result = IronFoxAddons.installAddon(components, IronFoxAddons.UBLOCK_ORIGIN)
    if (result.isFailure) {
        logger.error("Failed to install uBlock Origin", result.exceptionOrNull())
        onContentStateChange(
            Error(
                context.getString(
                    R.string.onboarding_state_installing_ublock_error,
                    result.exceptionOrNull()?.message ?: "Unknown error",
                ),
            ),
        )
    }
}

@Composable
private fun IronFoxPreferenceSwitchItem(
    option: IfPreferenceOption,
    isChecked: Boolean,
    modifier: Modifier = Modifier,
    onPreferenceChange: (IfPreferenceType) -> Unit,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clickable(
                onClick = {
                    onPreferenceChange(option.preferenceType)
                },
            )
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text(
            modifier = Modifier.weight(1f),
            text = option.label,
            style = FirefoxTheme.typography.body1,
            color = FirefoxTheme.colors.textPrimary,
        )

        Switch(
            checked = isChecked,
            onCheckedChange = { onPreferenceChange(option.preferenceType) },
            modifier = Modifier.align(Alignment.CenterVertically),
        )
    }
}

@Composable
private fun IronFoxPreferencesProgress(
    state: Progress,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(24.dp),
        ) {
            Text(
                text = state.message,
                style = FirefoxTheme.typography.body1,
                color = FirefoxTheme.colors.textPrimary,
            )

            LinearProgressIndicator(
                modifier = Modifier
                    .padding(horizontal = 32.dp)
                    .fillMaxWidth(),
            )
        }
    }
}

@Composable
private fun IronFoxPreferencesError(
    state: Error,
    modifier: Modifier = Modifier,
    onRetry: () -> Unit,
) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text(
            text = state.message,
            textAlign = TextAlign.Center,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
        )

        FilledButton(
            text = stringResource(R.string.onboarding_action_retry),
            modifier = Modifier
                .width(width = FirefoxTheme.layout.size.maxWidth.small),
            onClick = onRetry,
        )
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
