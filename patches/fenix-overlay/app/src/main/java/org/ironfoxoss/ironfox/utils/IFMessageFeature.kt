package org.ironfoxoss.ironfox.utils

import android.app.Activity
import android.content.Intent
import android.view.ViewGroup
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.fragment.app.Fragment
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.base.feature.ViewBoundFeatureWrapper
import mozilla.components.support.base.log.logger.Logger
import org.ironfoxoss.core.R as ironfoxR
import org.ironfoxoss.ironfox.utils.Action
import org.ironfoxoss.ironfox.utils.IFMessageScreen
import org.ironfoxoss.ironfox.utils.IFMessageState
import org.mozilla.fenix.R as fenixR
import org.mozilla.fenix.ext.components
import org.mozilla.fenix.theme.FirefoxTheme
import org.mozilla.fenix.utils.Settings

/**
 * Manages the display of in-app messages/pop-ups to users.
 */
class IFMessageFeature(
  private val activity: Activity,
  private val settings: Settings,
  private val navigateToDohSettings: () -> Unit,
) : LifecycleAwareFeature {
  private val logger = Logger("IFMessageFeature")

  override fun start() {
    showDohMigrationMessage()
  }

  override fun stop() {}

  // Check if a user is currently using Mullvad DNS
  internal fun isUsingMullvad(): Boolean {
    val dohUrl: String = settings.dohProviderUrl
    return dohUrl == "https://base.dns.mullvad.net/dns-query" || dohUrl == "https://dns.mullvad.net/dns-query"
  }

  // Check if we need to show the user our DoH migration message
  internal fun shouldShowDohMigrationMessage(): Boolean {
    val shownDohMigrationMessage: Boolean = settings.ironfox.shownDohMigrationMessage

    if (shownDohMigrationMessage) {
      return false
    }

    val isUsingMullvad: Boolean = isUsingMullvad()

    if (!isUsingMullvad) {
      settings.ironfox.shownDohMigrationMessage = true
      return false
    }

    return true
  }

  private fun showDohMigrationMessage() {
    if (!shouldShowDohMigrationMessage()) {
      return
    }

    logger.info("Showing DoH migration message...")

    val onCloseButtonClicked = {
      logger.info("Closed the DoH migration message.")
      settings.ironfox.shownDohMigrationMessage = true
    }

    showMessage(
      messageState = getDohMigrationMessageState(),
      onCloseButtonClicked = onCloseButtonClicked,
    )
  }

  internal fun getDohMigrationMessageState() =
    IFMessageState(
      imageRes = fenixR.drawable.ic_ironfox_warning,
      title = activity.getString(ironfoxR.string.ironfox_doh_migration_message_title),
      description = activity.getString(ironfoxR.string.ironfox_doh_migration_message_desc),
      primaryButton =
        Action(
          text = activity.getString(ironfoxR.string.ironfox_doh_migration_button),
          onClick = {
            logger.info("Clicked DoH migration message button.")
            navigateToDohSettings()
          },
        ),
    )

  private fun showMessage(
    messageState: IFMessageState,
    onCloseButtonClicked: () -> Unit = {},
  ) {
    val decorView = activity.window.decorView as? ViewGroup
    if (decorView == null) {
      logger.error("decorView was null.")
      return
    }

    if (decorView.findViewWithTag<ComposeView>(IF_MESSAGE_TAG) != null) {
      logger.error("Message dialog is already shown!")
      return
    }

    val composeView =
      ComposeView(activity).apply {
        tag = IF_MESSAGE_TAG
      }
    val removeDialogView = {
      logger.info("Removing messsage dialog...")
      decorView.removeView(composeView)
    }

    composeView.apply {
      setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
      setContent {
        FirefoxTheme {
          IFMessageScreen(
            messageState = messageState,
            onCloseButtonClicked = onCloseButtonClicked,
            removeDialogView = removeDialogView,
          )
        }
      }
    }

    decorView.addView(composeView)
  }

  companion object {
    private const val IF_MESSAGE_TAG = "ironfox_message"

    /**
     * Convenience method to register [IFMessageFeature] with a [Fragment]. Upon destruction of the
     * fragment's view, the binding will be unregistered and all references cleared.
     *
     * @param fragment The [Fragment] to register with.
     * @param binding The [ViewBoundFeatureWrapper] to bind the feature to.
     * @param navigateToDohSettings Invoked when the user chooses to navigate to DoH settings.
     */
    fun register(
      fragment: Fragment,
      binding: ViewBoundFeatureWrapper<IFMessageFeature>,
      navigateToDohSettings: () -> Unit,
    ) {
      val components = fragment.requireContext().components
      val settings = components.settings

      binding.set(
        feature =
          IFMessageFeature(
            activity = fragment.requireActivity(),
            settings = settings,
            navigateToDohSettings = navigateToDohSettings,
          ),
        owner = fragment.viewLifecycleOwner,
        view = fragment.requireView(),
      )
    }
  }
}
