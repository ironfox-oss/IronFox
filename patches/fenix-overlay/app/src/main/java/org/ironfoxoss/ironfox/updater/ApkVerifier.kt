package org.ironfoxoss.ironfox.updater

import java.io.File
import java.security.MessageDigest

/** Reads identity fields out of an APK file. */
interface ArchiveInspector {
    /** Returns the package name declared by [apk], or null if it cannot be read. */
    fun packageNameOf(apk: File): String?

    /** Returns the version code declared by [apk], or null if it cannot be read. */
    fun versionCodeOf(apk: File): Long?
}

/**
 * Thrown when a downloaded APK fails verification.
 *
 * @property reason The first check that failed.
 */
class ApkVerificationException(val reason: Reason) : Exception("APK verification failed: $reason") {
    /** The checks, in the order they run. */
    enum class Reason { HASH, PACKAGE, VERSION_CODE, VARIANT }
}

/**
 * Checks that a downloaded APK is the build the feed advertised.
 *
 * @param inspector Reads the package name and version code from the APK.
 * @param expectedPackage The package the APK must belong to.
 */
class ApkVerifier(
    private val inspector: ArchiveInspector,
    private val expectedPackage: String,
) {
    /**
     * Verifies [apk] against [offer] and the [installedVariant]; the file is deleted on failure.
     *
     * @throws ApkVerificationException naming the first failed check.
     */
    fun verify(apk: File, offer: UpdateOffer, installedVariant: Variant) {
        try {
            runChecks(apk, offer, installedVariant)
        } catch (e: ApkVerificationException) {
            apk.delete()
            throw e
        }
    }

    private fun runChecks(apk: File, offer: UpdateOffer, installedVariant: Variant) {
        fail(ApkVerificationException.Reason.HASH) { !apk.sha512Hex().equals(offer.sha512, ignoreCase = true) }
        fail(ApkVerificationException.Reason.PACKAGE) { inspector.packageNameOf(apk) != expectedPackage }
        val versionCode = inspector.versionCodeOf(apk)
        fail(ApkVerificationException.Reason.VERSION_CODE) { versionCode != offer.versionCode }
        fail(ApkVerificationException.Reason.VARIANT) { variantOrNull(offer.versionCode) != installedVariant }
    }

    private inline fun fail(reason: ApkVerificationException.Reason, failed: () -> Boolean) {
        if (failed()) throw ApkVerificationException(reason)
    }

    private fun variantOrNull(versionCode: Long): Variant? =
        runCatching { VersionCode.variantOf(versionCode) }.getOrNull()
}

internal fun File.sha512Hex(): String {
    val digest = MessageDigest.getInstance("SHA-512")
    inputStream().use { input ->
        val buffer = ByteArray(DIGEST_BUFFER_BYTES)
        while (true) {
            val read = input.read(buffer)
            if (read < 0) break
            digest.update(buffer, 0, read)
        }
    }
    return digest.digest().joinToString("") { "%02x".format(it) }
}

private const val DIGEST_BUFFER_BYTES = 64 * 1024
