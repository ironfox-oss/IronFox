# Safe Browsing

**IronFox enables Google Safe Browsing by default to provide users with real-time protection against malware, phishing, and other threats**.

Firefox's Safe Browsing implementation is [very well-designed from a privacy perspective](https://feeding.cloud.geek.nz/posts/how-safe-browsing-works-in-firefox/). It is free and open source, and unlike Chromium browsers on Android, does **not** rely on Google Play Services.

On top of [Firefox's already privacy-respecting design and implementation of Safe Browsing](https://support.mozilla.org/kb/how-does-phishing-and-malware-protection-work), we take additional measures to further improve privacy for users, by routing connections to Google through our [proxy](https://gitlab.com/ironfox-oss/safebrowsing-proxy).

**When Safe Browsing is enabled**, IronFox will periodically update its database *(through our proxy)* to provide protection against the latest threats. Additionally, if a potential match for a malicious website is found, IronFox might submit a partial hash of the suspected URL to Google *(through our proxy)*.

**At the cost of security**, you can disable Safe Browsing if desired, by navigating to `Settings` -> `Privacy and security` -> `Enable Safe Browsing`.

**If you'd like to keep Safe Browsing enabled, but prefer to disable our proxy and connect to Google directly**, you can do this by navigating to your `about:config`, and following these steps:

- Find the `browser.safebrowsing.provider.ironfox.lists` preference. Select and **Copy** its current value, and change it to `disabled`.
- Find the `browser.safebrowsing.provider.google4.lists` preference, and change its value to the value of the `browser.safebrowsing.provider.ironfox.lists` preference that you copied before.

If you'd like to revert back to using our proxy, you can do so at any time by resetting the values of the `browser.safebrowsing.provider.google4.lists` and `browser.safebrowsing.provider.ironfox.lists` preferences.
