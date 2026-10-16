package org.ironfoxoss.ironfox.utils

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import mozilla.components.compose.base.button.FilledButton
import mozilla.components.compose.base.button.IconButton
import mozilla.components.compose.base.button.OutlinedButton
import mozilla.components.ui.icons.R as iconsR
import org.ironfoxoss.ironfox.utils.IFMessageState
import org.mozilla.fenix.R as fenixR
import org.mozilla.fenix.theme.FirefoxTheme

val maxCardWidth = 360.dp

/**
 * A screen for displaying in-app messages/pop-ups to users.
 *
 * @param onCloseButtonClicked Executes when the close button is clicked.
 * @param removeDialogView Removes the dialog's view from the window.
 */
@Composable
fun IFMessageScreen(
  messageState: IFMessageState,
  onCloseButtonClicked: () -> Unit,
  removeDialogView: () -> Unit,
) {
  Dialog(
    onDismissRequest = {
      // Intentionally unused. The dialog can only be dismissed via the close button or page actions.
    },
    properties =
      DialogProperties(
        dismissOnBackPress = false,
        dismissOnClickOutside = false,
        usePlatformDefaultWidth = true,
      ),
  ) {
    Box(
      modifier = Modifier.fillMaxWidth().systemBarsPadding(),
      contentAlignment = Alignment.Center,
    ) {
      MessageContent(
        messageState = messageState,
        onCloseButtonClicked = onCloseButtonClicked,
        removeDialogView = removeDialogView,
      )
    }
  }
}

@Composable
private fun MessageContent(
  messageState: IFMessageState,
  onCloseButtonClicked: () -> Unit,
  removeDialogView: () -> Unit,
) {
  // Disables the buttons after the first click, so a rapid double-tap can't trigger them twice.
  var isDismissed by remember { mutableStateOf(false) }

  @Composable
  fun Content() {
    Column(
      modifier = Modifier.fillMaxWidth(),
      verticalArrangement = Arrangement.spacedBy(36.dp),
    ) {
      Text(
        text = messageState.title,
        style = MaterialTheme.typography.headlineSmall,
      )

      Box(
        modifier = Modifier.height(150.dp).fillMaxWidth(),
        contentAlignment = Alignment.Center,
      ) {
        Image(
          painter = painterResource(messageState.imageRes),
          contentDescription = null, // Decorative only.
        )
      }

      Text(
        text = messageState.description,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        style = FirefoxTheme.typography.subtitle1,
      )
    }
  }

  Card(
    modifier = Modifier.widthIn(max = maxCardWidth).fillMaxWidth(),
    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceBright),
  ) {
    IconButton(
      onClick = {
        isDismissed = true
        onCloseButtonClicked()
        removeDialogView()
      },
      enabled = !isDismissed,
      contentDescription = stringResource(fenixR.string.onboarding_home_content_description_close_button),
      modifier = Modifier.align(Alignment.End),
    ) {
      Icon(
        painter = painterResource(id = iconsR.drawable.mozac_ic_cross_24),
        contentDescription = null, // Uses the parent content description.
      )
    }

    Column(
      modifier = Modifier.fillMaxWidth().padding(16.dp).verticalScroll(rememberScrollState()),
      horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      Content()

      Spacer(Modifier.height(36.dp))

      FilledButton(
        modifier = Modifier.width(FirefoxTheme.layout.size.maxWidth.small),
        text = messageState.primaryButton.text,
        enabled = !isDismissed,
        onClick = {
          isDismissed = true
          messageState.primaryButton.onClick()
          removeDialogView()
        },
      )

      messageState.secondaryButton?.let {
        OutlinedButton(
          modifier = Modifier.width(FirefoxTheme.layout.size.maxWidth.small),
          text = it.text,
          enabled = !isDismissed,
          onClick = {
            isDismissed = true
            it.onClick()
            removeDialogView()
          },
        )
      }
    }
  }
}
