/* Hi, I'm a stub. ;) */

package org.mozilla.fenix.wallpapers

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class WallpaperDownloader(
    private val storageRootDirectory: Any?,
    private val client: Any?,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) {
    suspend fun downloadWallpaper(wallpaper: Wallpaper): Wallpaper.ImageFileState = withContext(dispatcher) {
        return@withContext Wallpaper.ImageFileState.Downloaded
    }

    suspend fun downloadThumbnail(wallpaper: Wallpaper): Wallpaper.ImageFileState = withContext(dispatcher) {
        return@withContext Wallpaper.ImageFileState.Downloaded
    }
}
