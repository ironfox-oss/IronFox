# Network Connections

This page serves to document connections commonly made by IronFox. It will explain the purpose of each connection, what data is shared, and how to disable *(or override if applicable)* the connection if desired.

## Default

These connections are made **by default**, out of the box.

### [Add-on Updates](https://blog.mozilla.org/addons/how-to-turn-off-add-on-updates/)

- `https://versioncheck-bg.addons.mozilla.org/update/VersionCheck.php?reqVersion=2&*`

If you install add-ons from outside of the AMO *(`addons.mozilla.org`)*, you may notice additional connections to other servers as part of this functionality *(as specified by the extension(s) you install)*.

**Operator**: [Mozilla](https://www.mozilla.org/) - *[Privacy policy](https://www.mozilla.org/privacy/)*

**Purpose**: Downloads updates for installed extensions and themes.

**Type(s) of data shared**: Identifiers of installed add-ons, Current versions of installed add-ons, Browser version, User Agent, public IP address.

**How often the connection occurs**: Hourly *(`extensions.update.interval`)*.

**Control**: You can disable add-on updates globally by setting `extensions.update.enabled` to `false` in your [`about:config`](about:config).

You can also disable updates for individual add-ons by setting `extensions.{GUID}.update.enabled` to `false` in your [`about:config`](about:config), replacing `{GUID}` with the ID of your desired add-on *(IDs of your installed extensions can be found at [`about:support`](about:support))*. **For example**: if I wanted to disable updates for uBlock Origin, I would set `extensions.uBlock0@raymondhill.net.update.enabled` to `false`.

Note that disabling add-on updates is **NOT** recommended.

### [Autograph](https://github.com/mozilla-services/autograph)

- `https://content-signature-2.cdn.mozilla.net/g/chains/*`

**Operator**: [Mozilla](https://www.mozilla.org/) - *[Privacy policy](https://www.mozilla.org/privacy/)*

**Purpose**: Provides signing/verification for various functionality, including: [content signatures](https://github.com/mozilla-services/autograph/blob/main/signer/contentsignaturepki/README.md), and extension signing *([1](https://github.com/mozilla-services/autograph/blob/main/signer/xpi/README.md), [2](https://wiki.mozilla.org/Add-ons/Extension_Signing))*.

**Type(s) of data shared**: User Agent, public IP address.

**How often the connection occurs**: Every browser launch, and periodically after.

**Control**: This request can be disabled by appending `,content-signature-2.cdn.mozilla.net` to the value of `network.dns.localDomains` in your [`about:config`](about:config) *(or by blocking `content-signature-2.cdn.mozilla.net` on the network level)*; though it is **NOT** recommended to disable or block this connection.

### [DNS over HTTPS](https://wikipedia.org/wiki/DNS_over_HTTPS)

- `https://dns.quad9.net/dns-query`

**Operator**: [Quad9](https://quad9.net/) - *[Privacy policy](https://quad9.net/privacy/policy/)*

**Purpose**: Provides encrypted domain name resolution.

**Type(s) of data shared**: Domain names of servers you connect to, User Agent, public IP address.

**How often the connection occurs**: Every time you connect to a domain.

**Control**: You can change DNS providers by navigating to `Privacy and security` -> `DNS over HTTPS` in settings. Under `Max Protection` *(or your chosen mode)*-> `Choose provider:`, you can either select one of our presets:

- **AdGuard** - `https://dns.adguard-dns.com/dns-query` - *[Privacy policy](https://adguard.com/privacy.html)*
- **AdGuard (Unfiltered)** - `https://unfiltered.adguard-dns.com/dns-query` - *[Privacy policy](https://adguard.com/privacy.html)*
- **Cloudflare** - `https://mozilla.cloudflare-dns.com/dns-query` - *[Privacy policy](https://developers.cloudflare.com/1.1.1.1/privacy/cloudflare-resolver-firefox/)*
- **Cloudflare (Malware Protection)** - `https://security.cloudflare-dns.com/dns-query` - *[Privacy policy](https://developers.cloudflare.com/1.1.1.1/privacy/public-dns-resolver/)*
- **DNS4EU (Ad Blocking)** - `https://noads.joindns4.eu/dns-query` - *[Privacy policy](https://www.joindns4.eu/privacy-policy)*
- **DNS4EU (Protective)** - `https://protective.joindns4.eu/dns-query` - *[Privacy policy](https://www.joindns4.eu/privacy-policy)*
- **DNS4EU (Unfiltered)** - `https://unfiltered.joindns4.eu/dns-query` - *[Privacy policy](https://www.joindns4.eu/privacy-policy)*
- **Mullvad (Base)** - `https://base.dns.mullvad.net/dns-query` - *[Privacy policy](https://mullvad.net/help/privacy-policy)*
- **Mullvad (Unfiltered)** - `https://dns.mullvad.net/dns-query` - *[Privacy policy](https://mullvad.net/help/privacy-policy)*
- **NextDNS** - `https://firefox.dns.nextdns.io/` - *[Privacy policy](https://nextdns.io/privacy)*
- **Wikimedia** - `https://wikimedia-dns.org/dns-query` - *[Privacy policy](https://meta.wikimedia.org/wiki/Wikimedia_DNS#Privacy_policy)*

**Or** you can add your own provider by selecting `Custom`, and entering your desired URL.

You can also set DNS over HTTPS to use your system's DNS resolver, by selecting `Default Protection` from the same screen.

### Initial add-on installation

- `https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi`

**Operator**: [Mozilla](https://www.mozilla.org/) - *[Privacy policy](https://www.mozilla.org/privacy/)*

**Purpose**: Downloads and installs the [uBlock Origin](https://addons.mozilla.org/addon/ublock-origin/) extensions.

**Type(s) of data shared**: User Agent, public IP address.

**How often the connection occurs**: Once, on initial set-up.

**Control**: Uncheck the box to install uBlock Origin on the onboarding if desired, though doing so is **NOT** recommended.

### [Push Service](https://mozilla-push-service.readthedocs.io/en/latest/)

- `wss://push.services.mozilla.com/`

**Operator**: [Mozilla](https://www.mozilla.org/) - *[Privacy policy](https://www.mozilla.org/privacy/)*

**Purpose**: Provides support for [web push notifications](https://support.mozilla.org/kb/push-notifications-firefox) and [Remote Settings](https://searchfox.org/mozilla-central/rev/97feebcab27f1a92e70ceacaa77211e9eaba0e6e/services/settings/remote-settings.sys.mjs#593-609).

**Type(s) of data shared**: Random identifier *(`dom.push.userAgentID`)*, User Agent, public IP address.

**How often the connection occurs**: Every browser launch, and periodically after.

**Control**: You can disable this functionality by setting the following preferences in your [`about:config`](about:config):

- `dom.push.connection.enabled` -> `false`
- `dom.push.userAgentID` -> ` `

Note that disabling this feature is **NOT** recommended.

### [Remote Settings](https://remote-settings.readthedocs.io/en/latest/)

- `https://firefox.settings.services.mozilla.com/v1/buckets/blocklists/collections/*`
- `https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/*`
- `https://firefox.settings.services.mozilla.com/v1/buckets/monitor/collections/changes/changeset?_expected=*`
- `https://firefox.settings.services.mozilla.com/v1/buckets/security-state/collections/*`
- `https://firefox-settings-attachments.cdn.mozilla.net/bundles/security-state--intermediates.zip`
- `https://firefox-settings-attachments.cdn.mozilla.net/bundles/startup.json.mozlz4`
- `https://firefox-settings-attachments.cdn.mozilla.net/main-workspace/tracking-protection-lists/*`
- `https://firefox-settings-attachments.cdn.mozilla.net/security-state-staging/cert-revocations/*`

**Operator**: [Mozilla](https://www.mozilla.org/) - *[Privacy policy](https://www.mozilla.org/privacy/)*

**Purpose**: Downloads configurations and databases for [various functionality](https://mozilla-services.github.io/remote-settings-permissions/), including: [Add-on blocklists](https://firefox.settings.services.mozilla.com/v1/buckets/blocklists/collections/addons-bloomfilters/changeset?_expected=0), [Certificate Revocations](https://firefox.settings.services.mozilla.com/v1/buckets/security-state/collections/cert-revocations/changeset?_expected=0), [Certificate Transparency logs](https://firefox.settings.services.mozilla.com/v1/buckets/security-state/collections/ct-logs/changeset?_expected=0), [Intermediate Certificates](https://firefox.settings.services.mozilla.com/v1/buckets/security-state/collections/intermediates/changeset?_expected=0), [Tracking Protection lists](https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/tracking-protection-lists/changeset?_expected=0), [Translation models](https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/translations-models/changeset?_expected=0), etc.

**Type(s) of data shared**: User Agent, public IP address.

**How often the connection occurs**: Hourly *(`services.settings.poll_interval`)*.

**Control**: This functionality can be disabled globally by setting `browser.ironfox.services.settings.allowedCollections` to ` ` in your [`about:config`](about:config), though it is **NOT** recommended to disable this feature.

You can also disable certain individual parts of this functionality if desired by setting the following preferences in your [`about:config`](about:config):

- **[Add-on blocklists](https://support.mozilla.org/kb/add-ons-cause-issues-are-on-blocklist)**: `extensions.blocklist.enabled` -> `false`
- **[CRLite](https://blog.mozilla.org/security/2020/01/09/crlite-part-1-all-web-pki-revocations-compressed/) filters**: `security.remote_settings.crlite_filters.enabled` -> `false`
- **[Intermediate certificate](https://support.globalsign.com/ca-certificates/intermediate-certificates/overview-intermediate-certificates) downloads**: `security.remote_settings.intermediates.enabled` -> `false`
- **[Tracking blocklists](https://support.mozilla.org/kb/trackers-and-scripts-firefox-blocks-enhanced-track)**: `browser.safebrowsing.provider.mozilla.lists` -> `disabled`

Note that disabling this functionality is **NOT** recommended.

### [Safe Browsing](https://support.mozilla.org/kb/how-does-phishing-and-malware-protection-work)

- `https://safebrowsing.ironfoxoss.org/v4/fullHashes:find?$ct=application/x-protobuf&*`
- `https://safebrowsing.ironfoxoss.org/v4/threatListUpdates:fetch?$ct=application/x-protobuf&*`
- `https://safebrowsing.ironfoxoss.org/v5/hashes:search?*`
- `https://safebrowsing.ironfoxoss.org/v5/hashLists:batchGet?*`

**Operator**: [IronFox OSS](https://ironfoxoss.org/) - *[Privacy policy](https://codeberg.org/celenity/Phoenix/wiki/Transparency#google-safe-browsing)*

**Purpose**: Provides real-time protection against malware and phishing *([Proxies `https://safebrowsing.googleapis.com`](https://gitlab.com/ironfox-oss/safebrowsing-proxy))*.

**Type(s) of data shared**: [Partial URL hashes upon potential matches](https://feeding.cloud.geek.nz/posts/how-safe-browsing-works-in-firefox/), User Agent, public IP address.

**How often the connection occurs**: Every browser launch, and every 30 minutes after.

**Control**: See [our `Safe Browsing` page](https://gitlab.com/ironfox-oss/IronFox/-/blob/dev/docs/Safe-Browsing.md) for more details, including how to disable Safe Browsing or change providers if desired. Note that disabling Safe Browsing is **NOT** recommended.

### [System Add-on Updates](https://firefox-source-docs.mozilla.org/toolkit/mozapps/extensions/addon-manager/SystemAddons.html#system-add-on-updates)

- `https://archive.mozilla.org/pub/system-addons/*`
- `https://aus5.mozilla.org/update/3/SystemAddons/*`

**Operator**: [Mozilla](https://www.mozilla.org/) - *[Privacy policy](https://www.mozilla.org/privacy/)*

**Purpose**: Downloads and updates [system add-ons](https://firefox-source-docs.mozilla.org/toolkit/mozapps/extensions/addon-manager/SystemAddons.html).

**Type(s) of data shared**: Browser version, locale, OS, OS architecture, OS version, User Agent, public IP address.

**How often the connection occurs**: Hourly.

**Control**: You can disable this functionality by setting `extensions.systemAddon.update.enabled` to `false` in your [`about:config`](about:config); though this is **NOT** recommended.

### uBlock Origin

- `https://cdn.jsdelivr.net/gh/uBlockOrigin/uAssetsCDN@main/*` - *[Privacy Policy](https://www.jsdelivr.com/terms/privacy-policy)*
- `https://cdn.statically.io/gh/uBlockOrigin/uAssetsCDN/main/*` - *[Privacy Policy](https://statically.io/policies/privacy/)*
- `https://filters.adtidy.org/extension/ublock/filters/*` - *[Privacy Policy](https://adguard.com/privacy.html)*
- `https://gitlab.com/celenityy/BadBlock/-/raw/*` - *[Privacy Policy](https://about.gitlab.com/privacy/)*
- `https://gitlab.com/celenityy/Phoenix/-/raw/*` - *[Privacy Policy](https://about.gitlab.com/privacy/)*
- `https://gitlab.com/DandelionSprout/adfilt/-/raw/master/*` - *[Privacy Policy](https://about.gitlab.com/privacy/)*
- `https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/*` - *[Privacy Policy](https://about.gitlab.com/privacy/)*
- `https://malware-filter.gitlab.io/urlhaus-filter/urlhaus-filter-ag-online.txt` - *[Privacy Policy](https://about.gitlab.com/privacy/)*
- `https://malware-filter.pages.dev/urlhaus-filter-ag-online.txt` - *[Privacy Policy](https://www.cloudflare.com/privacypolicy/)*
- `https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext`
- `https://publicsuffix.org/list/public_suffix_list.dat` - *[Privacy policy](https://www.mozilla.org/privacy/)*
- `https://raw.githubusercontent.com/fmhy/FMHYFilterlist/main/filterlist-basic.txt` - *[Privacy Policy](https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement)*
- `https://raw.githubusercontent.com/yokoffing/filterlists/main/*` - *[Privacy Policy](https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement)*
- `https://secure.fanboy.co.nz/*`
- `https://someonewhocares.org/hosts/hosts`
- `https://ublockorigin.github.io/uAssets/*` - *[Privacy Policy](https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement)*
- `https://ublockorigin.github.io/uAssetsCDN/*` - *[Privacy Policy](https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement)*
- `https://ublockorigin.pages.dev/*` - *[Privacy Policy](https://www.cloudflare.com/privacypolicy/)*

**Purpose**: Downloads and updates for filterlists and other resources in uBlock Origin.

**Type(s) of data shared**: User Agent, public IP address.

**How often the connection occurs**: Periodically.

**Control**: You can disable uBlock Origin by navigating to `Advanced` -> `Extensions` -> `uBlock Origin` in settings, and selecting `Enabled`. You can also uninstall uBlock Origin entirely from the same screen, by selecting `Remove`; though disabling or uninstalling uBlock Origin is **NOT** recommended.

## Additional

The following are **optional**, **non-standard** connections that IronFox might make, depending on the features you decide to use.

### [Geolocation](https://support.mozilla.org/kb/does-firefox-share-my-location-websites)

- `https://api.beacondb.net/v1/geolocate`

**Operator**: [BeaconDB](https://beacondb.net/) - *[Privacy policy](https://beacondb.net/privacy/)*

**Purpose**: Serves as a fallback to provide geolocation when the system's provider is unavailable.

**Type(s) of data shared**: Strength and general information of nearby cellular towards and Wi-Fi networks *(if available/supported)*, User Agent, public IP address.

**How often the connection occurs**: When/if you grant a website permission to access your location **and** if your system's geolocation provider is unavailable.

**Control**: You can simply choose not to grant websites permission to access your location, **or** you can disable the network geolocation provider entirely by setting `geo.provider.network.url` to ` ` in your [`about:config`](about:config); though doing so may cause issues with geolocation if your system's geolocation provider is unavailable.

You can also change the network geolocation provider if desired by setting the value of `geo.provider.network.url` to your preferred URL in the [`about:config`](about:config).
