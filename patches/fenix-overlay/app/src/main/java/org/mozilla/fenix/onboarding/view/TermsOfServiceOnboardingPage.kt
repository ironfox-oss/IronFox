package org.mozilla.fenix.onboarding.view

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import mozilla.components.compose.base.button.FilledButton
import org.mozilla.fenix.theme.FirefoxTheme

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
    Surface {
        BoxWithConstraints(
            modifier = Modifier.padding(horizontal = 16.dp),
        ) {
            val boxWithConstraintsScope = this

            // Base
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState()),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.SpaceBetween,
            ) {
                Spacer(Modifier)

                with(pageState) {
                    // Main content group
                    Column(
                        modifier = Modifier
                            .padding(vertical = 32.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center,
                    ) {
                        Image(
                            painter = painterResource(id = imageRes),
                            contentDescription = null,
                            modifier = Modifier
                                .heightIn(max = imageHeight(boxWithConstraintsScope))
                                .height(167.dp)
                                .width(161.dp),
                        )

                        Spacer(Modifier.height(24.dp))

                        Text(
                            text = title,
                            color = FirefoxTheme.colors.textPrimary,
                            textAlign = TextAlign.Center,
                            style = FirefoxTheme.typography.headline5,
                        )

                        Spacer(Modifier.height(8.dp))

                        Text(
                            text = description,
                            color = FirefoxTheme.colors.textSecondary,
                            textAlign = TextAlign.Center,
                            style = FirefoxTheme.typography.subtitle1,
                        )
                    }

                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(bottom = 24.dp),
                    ) {
                        Spacer(Modifier.height(24.dp))

                        FilledButton(
                            text = primaryButton.text,
                            modifier = Modifier
                            .width(width = FirefoxTheme.layout.size.maxWidth.small),
                            onClick = primaryButton.onClick,
                        )
                    }
                }
            }
        }
    }
}
