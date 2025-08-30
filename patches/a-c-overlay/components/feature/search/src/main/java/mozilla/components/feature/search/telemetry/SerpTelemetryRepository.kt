/* Hi, I'm a stub. ;) */

package mozilla.components.feature.search.telemetry

import org.json.JSONObject
import java.io.File

class SerpTelemetryRepository(
    rootStorageDirectory: File,
    private val readJson: () -> JSONObject,
    collectionName: String,
    serverUrl: String = "",
    bucketName: String = "",
) {
    suspend fun updateProviderList(): List<SearchProviderModel> {
        return emptyList()
    }
}
