package org.ironfoxoss.ironfox.updater

import java.io.IOException
import java.util.concurrent.TimeUnit
import mozilla.components.concept.fetch.Client
import mozilla.components.concept.fetch.Request
import mozilla.components.concept.fetch.Response
import mozilla.components.concept.fetch.isSuccess

/**
 * Fetches URLs while keeping every hop on a [HostAllowlist].
 *
 * Requests are conservative, cookie-less and uncached. Redirects are followed manually so each target can be
 * checked before it is requested.
 */
class AllowlistedFetcher(
  private val client: Client,
  private val allowlist: HostAllowlist,
) {
  /**
   * Returns the successful response for [url]; the caller must close it.
   *
   * @throws SecurityException if [url] or any redirect target is not allowed.
   * @throws IOException on network failure, a non-success status or too many redirects.
   */
  fun fetch(url: String, timeoutSeconds: Long): Response {
    var current = url
    repeat(MAX_REDIRECTS + 1) {
      allowlist.requireAllowed(current)
      val response = client.fetch(requestFor(current, timeoutSeconds))
      if (response.status !in REDIRECT_STATUSES) return response.requireSuccess()
      val location = response.headers["Location"]
      response.close()
      current = allowlist.requireAllowedRedirect(
        current,
        location ?: throw IOException("Redirect from $current has no Location"),
      )
    }
    throw IOException("Too many redirects fetching $url")
  }

  private fun requestFor(url: String, timeoutSeconds: Long) = Request(
    url = url,
    connectTimeout = timeoutSeconds to TimeUnit.SECONDS,
    readTimeout = timeoutSeconds to TimeUnit.SECONDS,
    redirect = Request.Redirect.MANUAL,
    cookiePolicy = Request.CookiePolicy.OMIT,
    useCaches = false,
    conservative = true,
  )

  private fun Response.requireSuccess(): Response {
    if (!isSuccess) {
      close()
      throw IOException("Unexpected HTTP status $status from $url")
    }
    return this
  }

  private companion object {
    const val MAX_REDIRECTS = 5
    val REDIRECT_STATUSES = setOf(301, 302, 303, 307, 308)
  }
}
