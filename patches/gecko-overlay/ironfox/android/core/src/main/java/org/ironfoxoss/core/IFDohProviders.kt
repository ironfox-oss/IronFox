package org.ironfoxoss.core

/**
 * IronFox DNS over HTTPS providers
 *
 */
object IFDohProviders {
  // Mullvad (Base)
  const val mullvadBaseName = "Mullvad (Base) 🇸🇪"
  const val mullvadBaseUri = "https://base.dns.mullvad.net/dns-query"

  // Cloudflare
  /// (We don't provide the Uri variable here, as it's specified by `DohSettingsProvider.kt` directly)
  const val cloudflareName = "Cloudflare 🇺🇸"

  // Cloudflare (Malware Protection)
  const val cloudflareMalwareName = "Cloudflare (Malware Protection) 🇺🇸"
  const val cloudflareMalwareUri = "https://security.cloudflare-dns.com/dns-query"

  // DNS4EU (Ad Blocking)
  const val dns4EuAdBlockingName = "DNS4EU (Ad Blocking) 🇨🇿"
  const val dns4EuAdBlockingUri = "https://noads.joindns4.eu/dns-query"

  // DNS4EU (Protective)
  const val dns4EuProtectiveName = "DNS4EU (Protective) 🇨🇿"
  const val dns4EuProtectiveUri = "https://protective.joindns4.eu/dns-query"

  // DNS4EU (Unfiltered)
  const val dns4EuUnfilteredName = "DNS4EU (Unfiltered) 🇨🇿"
  const val dns4EuUnfilteredUri = "https://unfiltered.joindns4.eu/dns-query"

  // DNSBunker
  const val dnsBunkerName = "DNSBunker 🇩🇪"
  const val dnsBunkerUri = "https://dnsbunker.org/dns-query"

  // dnsforge.de (Blank)
  const val dnsForgeBlankName = "dnsforge.de (Blank) 🇩🇪"
  const val dnsForgeBlankUri = "https://blank.dnsforge.de/dns-query"

  // dnsforge.de (Hard)
  const val dnsForgeHardName = "dnsforge.de (Hard) 🇩🇪"
  const val dnsForgeHardUri = "https://hard.dnsforge.de/dns-query"

  // dnsforge.de (Normal)
  const val dnsForgeNormalName = "dnsforge.de (Normal) 🇩🇪"
  const val dnsForgeNormalUri = "https://dnsforge.de/dns-query"

  // Mullvad (Unfiltered)
  const val mullvadUnfilteredName = "Mullvad (Unfiltered) 🇸🇪"
  const val mullvadUnfilteredUri = "https://dns.mullvad.net/dns-query"
}
