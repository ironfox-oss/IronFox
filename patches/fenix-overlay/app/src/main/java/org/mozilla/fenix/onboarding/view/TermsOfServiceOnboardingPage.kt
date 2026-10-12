package org.mozilla.fenix.onboarding.view

import androidx.compose.foundation.Image
import androidx.compose.foundation.LocalOverscrollFactory
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import mozilla.components.compose.base.button.FilledButton
import org.mozilla.fenix.compose.ScrollIndicator
import org.mozilla.fenix.onboarding.view.CONTENT_WEIGHT
import org.mozilla.fenix.onboarding.view.TITLE_TOP_SPACER_WEIGHT
import org.mozilla.fenix.onboarding.view.OnboardingPageState
import org.mozilla.fenix.theme.FirefoxTheme

private val IF_IMAGE_HEIGHT = 176.dp
private val IF_IMAGE_HEIGHT_SMALL_DEVICE = 130.dp

/**
 * A Composable for replacing Mozilla's Terms of Service page with the IronFox welcome page.
 *
 * @param pageState The page content that's displayed.
 * @param eventHandler The event handler for all user interactions of this page.
 */
@Composable
fun TermsOfServiceOnboardingPage(
  pageState: OnboardingPageState,
  eventHandler: Any?,
) {
  Card(
    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceBright),
    elevation = CardDefaults.cardElevation(if (!pageState.isSmallDevice) 6.dp else 0.dp),
  ) {
    val verticalPadding = if (pageState.isSmallDevice) 0.dp else FirefoxTheme.layout.space.static300
    Column(
      modifier = Modifier.padding(
        horizontal = FirefoxTheme.layout.space.static200,
        vertical = verticalPadding,
      ),
      horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      val scrollState = rememberScrollState()

      if (pageState.isSmallDevice) {
        Spacer(modifier = Modifier.height(16.dp))
      } else {
        Spacer(modifier = Modifier.weight(TITLE_TOP_SPACER_WEIGHT))
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

            Spacer(Modifier.weight(1f))

            Spacer(Modifier.height(26.dp))
          }

          ScrollIndicator(
            scrollState = scrollState,
            modifier = Modifier.align(Alignment.CenterEnd),
            enabled = pageState.isSmallDevice,
          )
        }
      }

      FilledButton(
        text = pageState.primaryButton.text,
        modifier =
          Modifier.width(width = FirefoxTheme.layout.size.maxWidth.small)
            .defaultMinSize(minHeight = FirefoxTheme.layout.size.static600),
        onClick = pageState.primaryButton.onClick,
      )
    }
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
    IF_IMAGE_HEIGHT_SMALL_DEVICE
  } else {
    IF_IMAGE_HEIGHT
  }
