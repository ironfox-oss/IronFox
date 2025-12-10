/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components

import android.app.Activity
import org.mozilla.fenix.components.ReviewPromptAttemptResult.Displayed
import org.mozilla.fenix.components.ReviewPromptAttemptResult.Error
import org.mozilla.fenix.components.ReviewPromptAttemptResult.NotDisplayed
import org.mozilla.fenix.components.ReviewPromptAttemptResult.Unknown
import java.util.Date

class PlayStoreReviewPromptController(
    private val numberOfAppLaunches: () -> Int,
) {

    suspend fun tryPromptReview(
        activity: Activity,
        onNotDisplayed: () -> Unit = {},
        onError: () -> Unit = {},
    ) {}

    fun tryLaunchPlayStoreReview(activity: Activity) {}
}

enum class ReviewPromptAttemptResult {
    NotDisplayed,
    Displayed,
    Error,
    Unknown,
    ;

    companion object {
        fun from(reviewInfoAsString: String): ReviewPromptAttemptResult {
            return Displayed
        }
    }
}

fun recordReviewPromptEvent(
    promptAttemptResult: ReviewPromptAttemptResult,
    numberOfAppLaunches: Int,
    now: Date,
) {}
