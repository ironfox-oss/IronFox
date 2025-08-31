/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.onboarding

import org.mozilla.fenix.onboarding.view.OnboardingPageUiData

class OnboardingTelemetryRecorder {

    fun onOnboardingComplete(sequenceId: String, sequencePosition: String) {}

    fun onOnboardingStarted() {}

    fun onImpression(
        sequenceId: String,
        pageType: OnboardingPageUiData.Type,
        sequencePosition: String,
    ) {}

    fun onSetToDefaultClick(sequenceId: String, sequencePosition: String) {}

    fun onSyncSignInClick(sequenceId: String, sequencePosition: String) {}

    fun onNotificationPermissionClick(sequenceId: String, sequencePosition: String) {}

    fun onAddSearchWidgetClick(sequenceId: String, sequencePosition: String) {}

    fun onSkipSetToDefaultClick(sequenceId: String, sequencePosition: String) {}

    fun onSkipSignInClick(sequenceId: String, sequencePosition: String) {}

    fun onSkipAddWidgetClick(sequenceId: String, sequencePosition: String) {}

    fun onSkipTurnOnNotificationsClick(sequenceId: String, sequencePosition: String) {}

    fun onSelectToolbarPlacementClick(sequenceId: String, sequencePosition: String, toolbarPlacement: String) {}

    fun onSelectThemeClick(themeOption: String, sequenceId: String, sequencePosition: String) {}

    fun onPrivacyPolicyClick(sequenceId: String, sequencePosition: String) {}

    fun onTermsOfServiceLinkClick() {}

    fun onTermsOfServicePrivacyNoticeLinkClick() {}

    fun onTermsOfServiceManagePrivacyPreferencesLinkClick() {}

    fun onTermsOfServiceManagerAcceptTermsButtonClick() {}

    fun onMarketingDataContinueClicked(optIn: Boolean) {}

    fun onMarketingDataLearnMoreClick() = {}

    fun onMarketingDataOptInToggled(optIn: Boolean) {}

    companion object {
        private const val ACTION_IMPRESSION = "impression"
        private const val ACTION_CLICK = "click"
        private const val ET_ONBOARDING_CARD = "onboarding_card"
        private const val ET_PRIMARY_BUTTON = "primary_button"
        private const val ET_SECONDARY_BUTTON = "secondary_button"
    }
}
