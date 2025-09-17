/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.onboarding.store

import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.MiddlewareContext

class PrivacyPreferencesTelemetryMiddleware :
    Middleware<PrivacyPreferencesState, PrivacyPreferencesAction> {
    override fun invoke(
        context: MiddlewareContext<PrivacyPreferencesState, PrivacyPreferencesAction>,
        next: (PrivacyPreferencesAction) -> Unit,
        action: PrivacyPreferencesAction,
    ) {}
}
