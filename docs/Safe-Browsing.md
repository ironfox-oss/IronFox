# Safe Browsing

**IronFox enables Google Safe Browsing by default to provide users with real-time protection against malware, phishing, and other threats**.

Firefox's Safe Browsing implementation is [very well-designed from a privacy perspective](https://feeding.cloud.geek.nz/posts/how-safe-browsing-works-in-firefox/). It is free and open source, and unlike Chromium browsers on Android, does **not** rely on Google Play Services.

On top of [Firefox's already privacy-respecting design and implementation of Safe Browsing](https://support.mozilla.org/kb/how-does-phishing-and-malware-protection-work), we take additional measures to further improve privacy for users, by routing connections to Google through our [proxy](https://gitlab.com/ironfox-oss/safebrowsing-proxy).

**When Safe Browsing is enabled**, IronFox will periodically update its database *(through our proxy)* to provide protection against the latest threats. Additionally, if a potential match for a malicious website is found, IronFox might submit a partial hash of the suspected URL to Google *(through our proxy)*.

**At the cost of security**, you can disable Safe Browsing if desired, by navigating to `Settings` -> `IronFox` -> `IronFox settings` -> `Security` -> `Enable Safe Browsing`.

**If you'd like to keep Safe Browsing enabled, but prefer to disable our proxy and connect to Google directly**, you can do this by setting the following preferences in your [`about:config`](about:config):

- `browser.safebrowsing.provider.google4.gethashURL` -> `https://safebrowsing.googleapis.com/v4/fullHashes:find?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST`
- `browser.safebrowsing.provider.google4.updateURL` -> `https://safebrowsing.googleapis.com/v4/threatListUpdates:fetch?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST`
- `browser.safebrowsing.provider.google5.gethashURL` -> `https://safebrowsing.googleapis.com/v5/hashes:search?key=%GOOGLE_SAFEBROWSING_API_KEY%`
- `browser.safebrowsing.provider.google5.updateURL` -> `https://safebrowsing.googleapis.com/v5/hashLists:batchGet?key=%GOOGLE_SAFEBROWSING_API_KEY%`

If you'd like to revert back to using our proxy, you can do so at any time by resetting the values of the `browser.safebrowsing.provider.google4.gethashURL`, `browser.safebrowsing.provider.google4.updateURL`, `browser.safebrowsing.provider.google5.gethashURL`, and `browser.safebrowsing.provider.google5.updateURL` preferences.
