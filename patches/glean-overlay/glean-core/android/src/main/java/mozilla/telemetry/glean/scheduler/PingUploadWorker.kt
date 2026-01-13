/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean.scheduler

import android.content.Context
import androidx.work.Constraints
import androidx.work.OneTimeWorkRequest
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.Worker
import androidx.work.WorkerParameters

internal fun buildConstraints(): Constraints = Constraints.Builder()
    .build()

internal inline fun <reified W : Worker> buildWorkRequest(tag: String): OneTimeWorkRequest {
    return OneTimeWorkRequestBuilder<W>()
        .build()
}

class PingUploadWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    companion object {
        internal const val PING_WORKER_TAG = ""

        internal fun enqueueWorker(context: Context) {}

        internal fun performUpload() {}

        internal fun cancel(context: Context) {}
    }

    override fun doWork(): Result = Result.success()
}
