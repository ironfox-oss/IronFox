package org.ironfoxoss.ironfox.updater

import java.io.File
import java.io.IOException
import java.io.InputStream
import org.ironfoxoss.core.IFConstants

/**
 * Downloads update APKs into the cache and keeps only the ones still worth having.
 *
 * @param fetcher Fetches the APK within the host allowlist.
 * @param cacheDir The app cache directory; APKs live in an `updates` folder inside it.
 * @param verifier Verifies every APK before it is handed out, including cached ones.
 */
class ApkDownloader(
  private val fetcher: AllowlistedFetcher,
  cacheDir: File,
  private val verifier: ApkVerifier,
) {
  private val updatesDir = File(cacheDir, UPDATES_DIR)

  /**
   * Returns a verified APK for [offer], reusing a cached one when it still verifies.
   *
   * @param onProgress Called with 0..100 while downloading, when the server reports the size.
   * @throws ApkVerificationException if the file fails verification; it is deleted.
   * @throws IOException on network or storage failure; no partial file is left behind.
   */
  fun obtain(offer: UpdateOffer, installedVariant: Variant, onProgress: (Int) -> Unit): File {
    val target = fileFor(offer)
    if (target.exists() && isStillValid(target, offer, installedVariant)) return target
    download(offer, target, onProgress)
    verifier.verify(target, offer, installedVariant)
    return target
  }

  /** Returns whether an APK for [offer] is already in the cache; it was verified before it was kept. */
  fun isCached(offer: UpdateOffer): Boolean = fileFor(offer).isFile

  /**
   * Deletes APKs for the installed build and older, for builds older than [keep], and any partial file.
   */
  fun cleanup(installedVersionCode: Long, keep: UpdateOffer?) {
    updatesDir.listFiles().orEmpty().forEach { file ->
      val versionCode = versionCodeOf(file)
      val superseded = versionCode == null ||
        !VersionCode.isNewerBuild(versionCode, installedVersionCode) ||
        (keep != null && versionCode shr BUILD_SHIFT < keep.versionCode shr BUILD_SHIFT)
      if (superseded) file.delete()
    }
  }

  private fun isStillValid(file: File, offer: UpdateOffer, installedVariant: Variant): Boolean =
    try {
      verifier.verify(file, offer, installedVariant)
      true
    } catch (_: ApkVerificationException) {
      false
    }

  private fun download(offer: UpdateOffer, target: File, onProgress: (Int) -> Unit) {
    if (!IFConstants.IRONFOX_UPDATER) return
    check(updatesDir.isDirectory || updatesDir.mkdirs()) { "Cannot create $updatesDir" }
    val partial = File(updatesDir, target.name + PARTIAL_SUFFIX)
    try {
      fetcher.fetch(offer.apkUrl, APK_TIMEOUT_SECONDS).use { response ->
        val total = response.headers["Content-Length"]?.toLongOrNull()
        response.body.useStream { input -> partial.copyFrom(input, total, onProgress) }
      }
      if (!partial.renameTo(target)) throw IOException("Cannot move $partial to $target")
    } finally {
      partial.delete()
    }
  }

  private fun File.copyFrom(input: InputStream, total: Long?, onProgress: (Int) -> Unit) {
    outputStream().use { output ->
      val buffer = ByteArray(COPY_BUFFER_BYTES)
      var copied = 0L
      while (true) {
        val read = input.read(buffer)
        if (read < 0) break
        output.write(buffer, 0, read)
        copied += read
        if (total != null && total > 0) onProgress((copied * PERCENT / total).toInt().coerceAtMost(PERCENT))
      }
    }
  }

  private fun fileFor(offer: UpdateOffer) = File(updatesDir, "$FILE_PREFIX${offer.versionCode}$FILE_SUFFIX")

  private fun versionCodeOf(file: File): Long? =
    file.name.removePrefix(FILE_PREFIX).removeSuffix(FILE_SUFFIX).toLongOrNull()
      ?.takeIf { file.name.startsWith(FILE_PREFIX) && file.name.endsWith(FILE_SUFFIX) }

  private companion object {
    const val APK_TIMEOUT_SECONDS = 30L
    const val BUILD_SHIFT = 3
    const val COPY_BUFFER_BYTES = 64 * 1024
    const val FILE_PREFIX = "ironfox-"
    const val FILE_SUFFIX = ".apk"
    const val PARTIAL_SUFFIX = ".part"
    const val PERCENT = 100
    const val UPDATES_DIR = "updates"
  }
}
