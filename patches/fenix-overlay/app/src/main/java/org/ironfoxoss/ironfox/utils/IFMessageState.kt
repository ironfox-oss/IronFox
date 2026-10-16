package org.ironfoxoss.ironfox.utils

import androidx.annotation.DrawableRes

/**
 * Model containing data for an in-app message/pop-up.
 *
 * @property imageRes Message image.
 * @property title Message title.
 * @property description Message description.
 * @property primaryButton [Action] for the primary button.
 * @property secondaryButton Optional [Action] for the secondary button.
 */
data class IFMessageState(
  @param:DrawableRes val imageRes: Int,
  val title: String,
  val description: String,
  val primaryButton: Action,
  val secondaryButton: Action? = null,
)

/** Model containing text and action for a button. */
data class Action(
  val text: String,
  val onClick: () -> Unit,
)
