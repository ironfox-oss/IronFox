package org.mozilla.fenix.onboarding.view

import android.content.Context
import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.LocalOverscrollFactory
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.compose.base.button.FilledButton
import org.ironfoxoss.core.R as ironfoxR
import org.mozilla.fenix.R as fenixR
import org.mozilla.fenix.compose.ScrollIndicator
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.onboarding.view.CONTENT_WEIGHT
import org.mozilla.fenix.onboarding.view.TITLE_TOP_SPACER_WEIGHT
import org.mozilla.fenix.onboarding.view.IfPreferenceUpdaterContentState.Configuration
import org.mozilla.fenix.onboarding.view.OnboardingPageState
import org.mozilla.fenix.theme.FirefoxTheme

private val IF_UPDATER_IMAGE_HEIGHT = 120.dp
private val IF_UPDATER_IMAGE_HEIGHT_SMALL_DEVICE = 88.dp

private sealed interface IfPreferenceUpdaterContentState {
  /**
   * Show IronFox updater preference switches.
   */
  data class Configuration(
    val optionIndex: Int,
  ) : IfPreferenceUpdaterContentState
}

private data class IfPreferenceUpdaterSwitchStates(
  val updaterEnabled: Boolean = true,
)

@Composable
fun IronFoxPreferenceUpdaterOnboardingPage(
  pageState: OnboardingPageState,
) {
  Card(
    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceBright),
    elevation = CardDefaults.cardElevation(if (!pageState.isSmallDevice) 6.dp else 0.dp),
  ) {
    val verticalPadding = if (pageState.isSmallDevice) 0.dp else FirefoxTheme.layout.space.static300
    Column(
      modifier =
        Modifier.padding(
          horizontal = FirefoxTheme.layout.space.static200,
          vertical = verticalPadding,
        ),
      horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      with(pageState) {
        val scrollState = rememberScrollState()
        if (pageState.isSmallDevice) {
          Spacer(modifier = Modifier.height(16.dp))
        } else {
          Spacer(modifier = Modifier.weight(TITLE_TOP_SPACER_WEIGHT))
        }

        val preferenceOptions = remember { ifPreferenceUpdaterOptions!! }
        var currentPreferenceIndex by remember { mutableIntStateOf(0) }

        var contentState by remember {
          mutableStateOf<IfPreferenceUpdaterContentState>(
            Configuration(currentPreferenceIndex),
          )
        }

        val context = LocalContext.current

        var switchStates by remember {
          mutableStateOf(IfPreferenceUpdaterSwitchStates())
        }

        val onContentStateChange = remember {
          { newState: IfPreferenceUpdaterContentState ->
            contentState = newState
          }
        }

        val applyPreference: suspend (IfPreferenceUpdaterOption) -> Unit =
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

        Box(modifier = Modifier.weight(CONTENT_WEIGHT).fillMaxWidth()) {
          CompositionLocalProvider(LocalOverscrollFactory provides null) {
            Column(
              modifier =
                Modifier.fillMaxSize()
                  .padding(end = FirefoxTheme.layout.space.static150)
                  .verticalScroll(scrollState),
              horizontalAlignment = Alignment.CenterHorizontally,
            ) {
              Header(pageState)

              (contentState as? Configuration?)?.also { configuration ->
                Text(
                  text = preferenceOptions[configuration.optionIndex].caption,
                  textAlign = TextAlign.Center,
                  style = FirefoxTheme.typography.body2,
                )
              }

              Spacer(Modifier.height(32.dp))

              AnimatedContent(
                targetState = contentState,
                modifier = Modifier.fillMaxWidth(),
              ) { currentState ->
                when (currentState) {
                  is Configuration -> 
                    IronFoxPreferenceUpdaterConfiguration(
                      option = preferenceOptions[currentState.optionIndex],
                      modifier = Modifier.fillMaxWidth(),
                      state = switchStates,
                      onUpdateSwitchStates = { newSwitchStates ->
                        switchStates = newSwitchStates
                      },
                    )
                }
              }
            }
            ScrollIndicator(
              scrollState = scrollState,
              modifier = Modifier.align(Alignment.CenterEnd),
              enabled = pageState.isSmallDevice,
            )
          }
        }
        if (contentState is Configuration) {
          Spacer(modifier = Modifier.height(16.dp))

          FilledButton(
            text = if (preferenceOptions.lastIndex == currentPreferenceIndex) {
              primaryButton.text
            } else {
              stringResource(fenixR.string.nova_onboarding_continue_button)
            },
            modifier =
              Modifier.width(width = FirefoxTheme.layout.size.maxWidth.small)
                .defaultMinSize(minHeight = FirefoxTheme.layout.size.static600),
              onClick = applyAction,
          )
        }
      }
    }
  }
}

@Composable
private fun IronFoxPreferenceUpdaterConfiguration(
  option: IfPreferenceUpdaterOption,
  state: IfPreferenceUpdaterSwitchStates,
  onUpdateSwitchStates: (IfPreferenceUpdaterSwitchStates) -> Unit,
  modifier: Modifier = Modifier,
) {
  Column(modifier = modifier) {
    IronFoxPreferenceUpdaterSwitchItem(
      option = option,
      isChecked = when (option.preferenceType) {
        IfPreferenceUpdaterType.UPDATER -> state.updaterEnabled
        IfPreferenceUpdaterType.DEFAULT -> throw UnsupportedOperationException()
      },
      modifier = Modifier
        .fillMaxWidth()
        .wrapContentHeight(),
      onPreferenceChange = { type ->
        onUpdateSwitchStates(
          when (type) {
            IfPreferenceUpdaterType.UPDATER -> state.copy(updaterEnabled = !state.updaterEnabled)
            IfPreferenceUpdaterType.DEFAULT -> throw UnsupportedOperationException()
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
      color = MaterialTheme.colorScheme.onSurfaceVariant,
    )
  }
}

private suspend fun applyPreference(
  context: Context,
  option: IfPreferenceUpdaterOption,
  state: IfPreferenceUpdaterSwitchStates,
  onContentStateChange: (IfPreferenceUpdaterContentState) -> Unit,
) {
  when (option.preferenceType) {
    IfPreferenceUpdaterType.DEFAULT -> {}
    IfPreferenceUpdaterType.UPDATER -> {
      context.components.settings.ironfox.updaterEnabled = state.updaterEnabled
    }
  }
}

@Composable
private fun IronFoxPreferenceUpdaterSwitchItem(
  option: IfPreferenceUpdaterOption,
  isChecked: Boolean,
  modifier: Modifier = Modifier,
  onPreferenceChange: (IfPreferenceUpdaterType) -> Unit,
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
    )

    Switch(
      checked = isChecked,
      onCheckedChange = { onPreferenceChange(option.preferenceType) },
      modifier = Modifier.align(Alignment.CenterVertically),
    )
  }
}

@Composable
private fun Header(pageState: OnboardingPageState) {
  Image(
    painter = painterResource(id = pageState.imageRes),
    contentDescription = null,
    modifier =
      Modifier.height(pageState.imageHeight()),
  )

  Spacer(Modifier.height(20.dp))

  Text(
    text = pageState.title,
    textAlign = TextAlign.Center,
    style = MaterialTheme.typography.headlineMedium,
  )

  Spacer(Modifier.height(10.dp))
}

private fun OnboardingPageState.imageHeight() =
  if (isSmallDevice) {
    IF_UPDATER_IMAGE_HEIGHT_SMALL_DEVICE
  } else {
    IF_UPDATER_IMAGE_HEIGHT
  }
