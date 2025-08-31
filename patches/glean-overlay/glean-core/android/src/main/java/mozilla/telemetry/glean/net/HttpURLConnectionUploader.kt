/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean.net

import androidx.annotation.VisibleForTesting
import java.net.HttpURLConnection

class HttpURLConnectionUploader : PingUploader {
    companion object {
        const val DEFAULT_CONNECTION_TIMEOUT = 0
        const val DEFAULT_READ_TIMEOUT = 0
    }

    override fun upload(request: CapablePingUploadRequest): UploadResult = Incapable(0)

    internal fun removeCookies(submissionUrl: String) {}

    internal fun doUpload(connection: HttpURLConnection, data: ByteArray): Int = 200

    @VisibleForTesting
    internal fun openConnection(url: String): HttpURLConnection {
        return "" as HttpURLConnection
    }
}
