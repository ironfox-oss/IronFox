package org.mozilla.fenix.onboarding.redesign.view

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import mozilla.components.compose.base.button.FilledButton
import org.mozilla.fenix.onboarding.view.OnboardingPageState
import org.mozilla.fenix.theme.FirefoxTheme

/**
 * A Composable for replacing Mozilla's Terms of Service page with the IronFox welcome page.
 *
 * @param pageState The page content that's displayed.
 * @param eventHandler The event handler for all user interactions of this page.
 */
@Composable
fun TermsOfServiceOnboardingPageRedesign(
    pageState: OnboardingPageState,
    eventHandler: Any?,
) {
    Card(
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 6.dp),
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(modifier = Modifier.weight(TITLE_TOP_SPACER_WEIGHT))

            Column(
                modifier = Modifier
                    .weight(CONTENT_WEIGHT)
                    .verticalScroll(rememberScrollState()),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.SpaceBetween,
            ) {
                Header(pageState)

                Spacer(Modifier.weight(1f))

                Spacer(Modifier.height(26.dp))
            }

            FilledButton(
                text = pageState.primaryButton.text,
                modifier = Modifier
                    .width(width = FirefoxTheme.layout.size.maxWidth.small),
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
        modifier = Modifier
            .height(IconSize.heightDp)
            .width(IconSize.widthDp),
    )

    Spacer(Modifier.height(20.dp))

    Text(
        text = pageState.title,
        textAlign = TextAlign.Center,
        style = MaterialTheme.typography.headlineMedium,
    )

    Spacer(Modifier.height(10.dp))
}

private object IconSize {
    val heightDp = 60.dp
    val widthDp = 58.dp
}
