package org.ironfoxoss.ironfox.updater

import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.longOrNull

/**
 * A downloadable build advertised by the update feed.
 *
 * @property version The human readable version.
 * @property releaseNotesUrl Where the user can read about this build.
 * @property versionCode The Android version code of the APK.
 * @property sha512 The lowercase or uppercase hex SHA-512 of the APK.
 * @property apkUrl Where to download the APK.
 */
data class UpdateOffer(
  val version: String,
  val releaseNotesUrl: String,
  val versionCode: Long,
  val sha512: String,
  val apkUrl: String,
)

/** Thrown when the update feed is not shaped as expected. */
class ManifestException(message: String, cause: Throwable? = null) : Exception(message, cause)

/** Parses the IronFox update feed. */
object UpdateManifest {

  /**
   * Returns the offer for [packageName] and [variant]; unknown keys are ignored.
   *
   * @throws ManifestException if the feed is malformed or lacks the package, the variant or a field.
   */
  fun parse(json: String, packageName: String, variant: Variant): UpdateOffer {
    val packageEntry = parseRoot(json).objectAt(packageName)
    val variantEntry = packageEntry.objectAt(variant.feedKey)
    return UpdateOffer(
      version = packageEntry.stringAt("version"),
      releaseNotesUrl = packageEntry.stringAt("release-notes"),
      versionCode = variantEntry.longAt("version-code"),
      sha512 = variantEntry.stringAt("sha512sum"),
      apkUrl = variantEntry.stringAt("url"),
    )
  }

  private fun parseRoot(json: String): JsonObject {
    val root = try {
      Json.parseToJsonElement(json)
    } catch (e: SerializationException) {
      throw ManifestException("Update feed is not valid JSON", e)
    } catch (e: IllegalArgumentException) {
      throw ManifestException("Update feed is not valid JSON", e)
    }
    return root as? JsonObject ?: throw ManifestException("Update feed root is not an object")
  }

  private fun JsonObject.objectAt(key: String): JsonObject =
    this[key] as? JsonObject ?: throw ManifestException("Update feed has no object '$key'")

  private fun JsonObject.stringAt(key: String): String {
    val primitive = this[key] as? JsonPrimitive
    return primitive?.takeIf { it.isString }?.content
      ?: throw ManifestException("Update feed has no string '$key'")
  }

  private fun JsonObject.longAt(key: String): Long {
    val primitive = this[key] as? JsonPrimitive
    return primitive?.takeUnless { it.isString }?.longOrNull
      ?: throw ManifestException("Update feed has no integer '$key'")
  }
}
