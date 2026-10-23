package org.ironfoxoss.ironfox.updater

import java.net.URI
import java.net.URISyntaxException

/**
 * Restricts the updater to HTTPS URLs on an explicit set of hosts.
 *
 * @param allowedHosts Comma separated host names; matching is exact and case-insensitive.
 * @param allowInsecureHttp Whether plain HTTP is accepted too. Only for testing against a local server; the host
 * still has to be listed and no other scheme is ever accepted.
 * @throws SecurityException if no host is listed.
 */
class HostAllowlist(allowedHosts: String, private val allowInsecureHttp: Boolean = false) {
  private val hosts: Set<String> = allowedHosts.split(",")
    .map { it.trim().lowercase() }
    .filter { it.isNotEmpty() }
    .toSet()

  init {
    if (hosts.isEmpty()) {
      throw SecurityException("Updater host allowlist is empty")
    }
  }

  /** Throws [SecurityException] unless [url] is an HTTPS (or, if enabled, HTTP) URL on an allowed host. */
  fun requireAllowed(url: String) {
    val uri = try {
      URI(url)
    } catch (e: URISyntaxException) {
      throw SecurityException("Updater URL is malformed: $url", e)
    }
    if (!isSchemeAllowed(uri.scheme)) {
      throw SecurityException("Updater URL is not HTTPS: $url")
    }
    val host = uri.host?.lowercase()
    if (host == null || host !in hosts) {
      throw SecurityException("Updater host '$host' is not allowed")
    }
  }

  /**
   * Resolves a redirect [location] against [currentUrl], checks the result, and returns it.
   *
   * @throws SecurityException if the redirect leaves the allowlist or HTTPS.
   */
  fun requireAllowedRedirect(currentUrl: String, location: String): String {
    val resolved = try {
      URI(currentUrl).resolve(location).toString()
    } catch (e: URISyntaxException) {
      throw SecurityException("Updater redirect is malformed: $location", e)
    } catch (e: IllegalArgumentException) {
      throw SecurityException("Updater redirect is malformed: $location", e)
    }
    requireAllowed(resolved)
    return resolved
  }

  private fun isSchemeAllowed(scheme: String?): Boolean =
    "https".equals(scheme, ignoreCase = true) || (allowInsecureHttp && "http".equals(scheme, ignoreCase = true))
}
