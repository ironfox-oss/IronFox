/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.components

import android.app.Activity
import androidx.annotation.VisibleForTesting
import java.util.Date

class PlayStoreReviewPromptController(
    private val numberOfAppLaunches: () -> Int,
) {
    suspend fun tryPromptReview(activity: Activity) {}
}

@VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
fun recordReviewPromptEvent(
    reviewInfoAsString: String,
    numberOfAppLaunches: Int,
    now: Date,
) {}
