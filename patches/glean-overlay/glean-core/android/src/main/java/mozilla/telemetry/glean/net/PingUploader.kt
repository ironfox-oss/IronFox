/* Hi, I'm a stub. ;) */

package mozilla.telemetry.glean.net

typealias HeadersList = Map<String, String>

interface PingUploader {
    fun upload(request: CapablePingUploadRequest): UploadResult
}

data class PingUploadRequest(
    val url: String,
    val data: ByteArray,
    val headers: HeadersList,
    val uploaderCapabilities: List<String>,
)

class CapablePingUploadRequest(val request: PingUploadRequest) {
    fun capable(f: (uploaderCapabilities: List<String>) -> Boolean): PingUploadRequest? = null
}
