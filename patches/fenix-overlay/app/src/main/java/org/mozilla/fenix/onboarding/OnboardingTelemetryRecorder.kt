/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.onboarding

import org.mozilla.fenix.onboarding.view.OnboardingPageUiData

class OnboardingTelemetryRecorder(
    private val onboardingReason: OnboardingReason,
    private val installSource: String,
) {
    fun onOnboardingComplete(sequenceId: String, sequencePosition: String, dismissedMethod: DismissedMethod = DismissedMethod.COMPLETED) {}
    fun onOnboardingStarted() {}
    fun onImpression(sequenceId: String, pageType: OnboardingPageUiData.Type, sequencePosition: String) {}
    fun onSetToDefaultClick(sequenceId: String, sequencePosition: String) {}
    fun onSyncSignInClick(sequenceId: String, sequencePosition: String) {}
    fun onNotificationPermissionClick(sequenceId: String, sequencePosition: String) {}
    fun onAddSearchWidgetClick(sequenceId: String, sequencePosition: String) {}
    fun onSkipSetToDefaultClick(sequenceId: String, sequencePosition: String) {}
    fun onSkipSignInClick(sequenceId: String, sequencePosition: String, elementType: String = ET_SECONDARY_BUTTON) {}
    fun onSkipAddWidgetClick(sequenceId: String, sequencePosition: String) {}
    fun onSkipTurnOnNotificationsClick(sequenceId: String, sequencePosition: String, elementType: String = ET_SECONDARY_BUTTON) {}
    fun onSelectToolbarPlacementClick(sequenceId: String, sequencePosition: String, toolbarPlacement: String) {}
    fun onSelectThemeClick(themeOption: String, sequenceId: String, sequencePosition: String) {}
    fun onPrivacyPolicyClick(sequenceId: String, sequencePosition: String) {}
    fun onTermsOfServiceLinkClick() {}
    fun onTermsOfServicePrivacyNoticeLinkClick() {}
    fun onTermsOfServiceManagePrivacyPreferencesLinkClick() {}
    fun onTermsOfServiceManagerAcceptTermsButtonClick() {}
    fun onMarketingDataContinueClicked(optIn: Boolean) {}
    fun onMarketingDataLearnMoreClick() {}
    fun onMarketingDataOptInToggled(optIn: Boolean) {}
    fun onNavigatedToNextPage() {}

    companion object {
        private const val ACTION_IMPRESSION = "impression"
        private const val ACTION_CLICK = "click"
        private const val ET_ONBOARDING_CARD = "onboarding_card"
        private const val ET_PRIMARY_BUTTON = "primary_button"
        private const val ET_SECONDARY_BUTTON = "secondary_button"
        const val ET_CARD_CLOSE_BUTTON = "card_close_button"
    }
}

enum class DismissedMethod(val telemetryId: String) {
    COMPLETED("completed"),
    SKIPPED("skipped"),
}
