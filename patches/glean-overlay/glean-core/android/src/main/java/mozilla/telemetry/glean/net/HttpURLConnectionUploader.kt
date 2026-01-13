/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean.net

class HttpURLConnectionUploader : PingUploader {
    companion object {
        const val DEFAULT_CONNECTION_TIMEOUT = 0
        const val DEFAULT_READ_TIMEOUT = 0
    }

    override fun upload(request: CapablePingUploadRequest): UploadResult = Incapable(0)

    internal fun removeCookies(submissionUrl: String) {}

    internal fun doUpload(connection: Any?, data: ByteArray): Int = 200

    internal fun openConnection(url: String): Any? {
        return ""
    }
}
