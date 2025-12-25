/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.onboarding

import org.mozilla.fenix.onboarding.view.OnboardingTermsOfServiceEventHandler

class DefaultOnboardingTermsOfServiceEventHandler(
    private val telemetryRecorder: Any?,
    private val openLink: (String) -> Unit,
    private val showManagePrivacyPreferencesDialog: () -> Unit,
    private val settings: Any?,
) : OnboardingTermsOfServiceEventHandler {
    override fun onTermsOfServiceLinkClicked(url: String) {}
    override fun onPrivacyNoticeLinkClicked(url: String) {}
    override fun onManagePrivacyPreferencesLinkClicked() {}
    override fun onAcceptTermsButtonClicked(nowMillis: Long) {}
}
