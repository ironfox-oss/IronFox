# Features

This list is not exhaustive...

**NOTE**: IronFox uses configs from [Phoenix](https://phoenix.celenity.dev) to harden and configure Gecko's preferences. This page is focused on **IronFox-specific** changes; some changes from Phoenix that are major or overlap with ours for IronFox may be covered, but it won't cover everything. For more information on Phoenix's features, please see [the documentation here](https://codeberg.org/celenity/Phoenix/wiki/Features).

**⚠️ BEFORE PROCEEDING**: Please see our [`Limitations`](https://gitlab.com/ironfox-oss/IronFox/-/blob/dev/docs/Limitations.md) page to better understand what IronFox can and can not protect against.

## Privacy

- Blocks websites from accessing geolocation by default
- Clears browsing history on exit by default
- Clears cache on exit by default
- Clears download history on exit by default
- Clears open tabs on exit by default
- Disables autofill/autocompletion of URLs by default
- Disables disk cache by default, and adds a toggle to control it, located at `IronFox` -> `IronFox settings` -> `Privacy` -> `Enable disk cache` in settings
- Disables disk cache for secure webpages by default, and adds a toggle to control it, located at `IronFox` -> `IronFox settings` -> `Privacy` -> `Enable disk cache for secure webpages` in settings
- Disables network connectivity monitoring, and removes the `ACCESS_NETWORK_STATE` permission
- Disables search suggestions by default
- Disables trending search suggestions by default
- Enables [disk remnant avoidance](https://searchfox.org/mozilla-central/rev/ac81a39d/toolkit/moz.configure#3014) at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L495)
- Enables [DNS over HTTPS *(DoH)*](https://support.mozilla.org/kb/dns-over-https) with [Max Protection](https://support.mozilla.org/kb/dns-over-https#w_max-protection) *(without fallback)* by default, via [Quad9](https://quad9.net/)
- Enables Firefox's built-in [Cookie Banner Reduction](https://support.mozilla.org/kb/cookie-banner-reduction) by default, and exposes the toggle to enable/disable it for private browsing, located at `Privacy and security` -> `Cookie Banner Blocker in private browsing` in settings
- Enables [Global Privacy Control](https://globalprivacycontrol.org/) by default, and hides the UI to prevent users from easily/unnecessarily making themselves more fingerprintable
- Enables [proxy bypass protection](https://searchfox.org/mozilla-central/rev/ac81a39d/toolkit/moz.configure#1919) at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L501)
- Enables [Strict Enhanced Tracking Protection *(ETP Strict)*](https://support.mozilla.org/kb/enhanced-tracking-protection-firefox-desktop#w_strict-enhanced-tracking-protection)
- Includes a default, local set of homepage wallpapers, instead of downloading them from a server remotely
- Installs [uBlock Origin](https://addons.mozilla.org/firefox/addon/ublock-origin) by default, and configures it to provide stronger protection out of the box
- Prevents the browser from fetching favicons for homepage shortcuts/pins on launch, without prior user interaction
- Stubs the [Beacon API *(`navigator.sendBeacon`)*](https://developer.mozilla.org/docs/Web/API/Beacon_API)

## Fingerprinting

In order to combat fingerprinting, IronFox enables Mozilla's [Suspected Fingerprinters Protection (FPP)](https://support.mozilla.org/kb/firefox-protection-against-fingerprinting#w_suspected-fingerprinters). **However:** IronFox modifies the set of protections *([targets](https://searchfox.org/mozilla-central/source/toolkit/components/resistfingerprinting/RFPTargets.inc))* covered by FPP to match [Resist Fingerprinting (RFP)](https://support.mozilla.org/kb/resist-fingerprinting), but **with the following changes**:

- We allow first-party canvas data extraction, due to prompts unfortunately not being supported on Android *(Third parties are still blocked from extracting canvas data, and canvas data is still randomized when extracted)*
- We do not unconditionally spoof CSS [`prefers-color-scheme`](https://developer.mozilla.org/docs/Web/CSS/@media/prefers-color-scheme), to allow users to enable Dark mode if desired *(though we still enable light mode by default, see below)*
- We allow display of content over 60FPS

IronFox **additionally**:

- Includes bundled fonts at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/2609477a278f7e4a3681e5979b354d6063249edd/patches/gecko-overlay/mobile/android/ironfox.configure#L18), to improve compatibility, and to help provide users with a baseline/common set of fonts
- Prevents fingerprinting based on whether Firefox's internal PDF viewer *(`PDF.js`)* is enabled or disabled
- Sets the preferred website appearance *(CSS [`prefers-color-scheme`](https://developer.mozilla.org/docs/Web/CSS/@media/prefers-color-scheme))* to light mode by default, and adds an option to configure it independently of the browser's theme  *(Like Firefox on Desktop)*, located at `IronFox` -> `IronFox settings` -> `Preferred website appearance` in settings
- Spoofs the preferred locale for websites to English *(`en-US`)* by default, and adds a toggle to enable/disable it, located at `IronFox` -> `IronFox settings` -> `Privacy` -> `Request English versions of webpages` in settings

## Security

- Disables [accessibility services](https://developer.android.com/guide/topics/ui/accessibility/service) by default, and adds a toggle to enable/disable it, located at `IronFox` -> `IronFox settings` -> `Privacy and security` -> `Enable accessibility services` in settings
- Disables autofill of [form data](https://wiki.mozilla.org/Firefox/Features/Form_Autofill) and [log-in credentials](https://support.mozilla.org/kb/autofill-logins-firefox) by default
- Disables the browser's [built-in password manager](https://support.mozilla.org/kb/manage-your-logins-firefox-password-manager) by default
- Disables Firefox's built-in list of domains used to autocomplete URLs, to [prevent suggesting squatted domains that serve ads and malware](https://bugzilla.mozilla.org/show_bug.cgi?id=1842106#c0) to users
- Disables the [Gecko Profiler](https://firefox-source-docs.mozilla.org/tools/profiler/index.html) at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L465)
- Disables [HTTP Live Streaming *(HLS)*](https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/29859) at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/2609477a278f7e4a3681e5979b354d6063249edd/patches/gecko-overlay/mobile/android/ironfox.configure#L7)
- Disables installation of add-ons by default, and adds a toggle to enable/disable it, located at `IronFox` -> `IronFox settings` -> `Security` -> `Allow installation of add-ons` in settings
- Disables [JavaScript Just-in-time Compilation *(JIT)*](https://microsoftedge.github.io/edgevr/posts/Super-Duper-Secure-Mode/) by default, and adds a toggle to enable/disable it, located at  `IronFox` -> `IronFox settings` -> `Security` -> `Enable JavaScript Just-in-time Compilation (JIT)` in settings
- Disables [Parental Controls](https://searchfox.org/mozilla-central/source/toolkit/components/parentalcontrols/nsIParentalControlsService.idl) at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L473)
- Disables `SSLKEYLOGGING` at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/a3c9025e044b780adf43e14bc5dbc213d6119ce9/patches/disable-sslkeylogging.patch) *([1](https://bugzilla.mozilla.org/show_bug.cgi?id=1183318), [2](https://bugzilla.mozilla.org/show_bug.cgi?id=1915224))*
- Disables support for [GSS-API negotiate authentication](https://htmlpreview.github.io/?https://github.com/mdn/archived-content/blob/main/files/en-us/mozilla/integrated_authentication/raw.html) at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L471)
- Disables support for [WebDriver remote protocols](https://firefox-source-docs.mozilla.org/remote/index.html) at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L490)
- Enables the use of encrypted storage *([via Android's Keystore system](https://developer.android.com/privacy-and-security/keystore))* for Firefox account state and certain preferences
- Enables [Fission](https://wiki.mozilla.org/Project_Fission) *(basic per-site process isolation)* by default
- Enables [Google Safe Browsing](https://support.mozilla.org/kb/how-does-phishing-and-malware-protection-work) by default, with [a proxy](https://gitlab.com/ironfox-oss/safebrowsing-proxy) to protect the privacy of users, and adds a toggle to enable/disable it, located at `IronFox` -> `IronFox settings` -> `Security` -> `Enable Safe Browsing` in settings
- Enables [HTTPS-Only Mode](https://support.mozilla.org/kb/https-only-prefs) by default
- Expands the [list of domains](https://wiki.mozilla.org/SecurityEngineering/Public_Key_Pinning#Currently-pinned_Sites) supported by Firefox's [Strict Certificate Pinning](https://wiki.mozilla.org/SecurityEngineering/Public_Key_Pinning)
- [Hard-fails](https://github.com/arkenfox/user.js/issues/1576) OCSP certificate revocation checks by default, and adds a toggle to enable/disable it, located at `IronFox` -> `IronFox settings` -> `Security` -> `Hard-fail OCSP revocation checks` in settings
- Hardens the browser's built-in PDF Viewer *(PDF.js)*, with changes inspired by [GrapheneOS's PDF Viewer](https://github.com/GrapheneOS/PdfViewer)
- Hides the toggle to enable/disable [Remote Debugging](https://firefox-source-docs.mozilla.org/devtools/backend/protocol.html) from settings, and resets the preference per-session if configured via other means

## Enhancements

- Adds an [internal list](https://gitlab.com/ironfox-oss/IronFox/-/blob/dev/patches/gecko-overlay/services/settings/dumps/main/ironfox-fingerprinting-protection-overrides.json) to configure specific fingerprinting protections on a per-site basis, to reduce breakage and harden protection as needed *(This, as well as Mozilla's override list that serves a similar purpose, can be disabled if desired, by setting `privacy.fingerprintingProtection.remoteOverrides.enabled` to `false` in your `about:config`)*
- Adds an option to configure [the behavior of cross-origin referers](https://wiki.mozilla.org/Security/Referrer), located at `IronFox` -> `IronFox settings` -> `Privacy` -> `Cross-origin referer policy` in settings
- Adds a toggle to enable/disable IPv6 network connectivity, located at `IronFox` -> `IronFox settings` -> `Miscellaneous` -> `Enable IPv6 network connectivity` in settings
- Adds a toggle to enable/disable JavaScript, located at `IronFox` -> `IronFox settings` -> `Privacy and security` -> `Enable JavaScript` in settings
- Adds a toggle to enable/disable [Scalable Vector Graphics *(SVG)*](https://blog.mozilla.org/security/2016/11/30/fixing-an-svg-animation-vulnerability/), located at `IronFox` -> `IronFox settings` -> `Security` -> `Enable Scalable Vector Graphics (SVG)` in settings
- Adds a toggle to enable/disable the [tab bar](https://connect.mozilla.org/t5/discussions/tab-strip-for-firefox-android-now-available-in-firefox-nightly/m-p/60145), located at `General` -> `Customize` -> `Tab bar display` in settings
- Adds a toggle to enable/disable [WebAssembly *(WASM)*](https://spectrum.ieee.org/more-worries-over-the-security-of-web-assembly), located at `IronFox` -> `IronFox settings` -> `Security` -> `Enable WebAssembly (WASM)` in settings
- Adds a toggle to enable/disable WebGL *([1](https://blog.browserscan.net/docs/webgl-fingerprinting), [2](https://security.stackexchange.com/questions/13799/is-webgl-a-security-concern))* globally, located at `IronFox` -> `IronFox settings` -> `Privacy and security` -> `Enable WebGL` in settings
- Adds a toggle to enable/disable WebRTC *([1](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=webrtc), [2](https://x.com/GrapheneOS/status/1728921946396725618))* globally, located at `IronFox` -> `IronFox settings` -> `Security` -> `Enable WebRTC` in settings
- Allows zoom on all websites, even if they try to block it, by default
- Blocks [media autoplay](https://support.mozilla.org/kb/block-autoplay) by default
- Blocks web notifications by default
- Disables the `Collections` banner/placeholder on the homepage by default
- Disables the display of recent tabs *(`Jump back in`)* on the homepage by default
- Disables the display of recently visited bookmarks on the homepage by default
- Disables the display of recently visited websites on the homepage by default
- Disables history search suggestions by default
- Disables recent search suggestions by default
- Enables the `about:config`, and exposes it at `about:about`
- Expands the list of built-in DNS over HTTPS *(DoH)* resolvers to include [AdGuard](https://adguard-dns.io/public-dns.html), [AdGuard (Unfiltered)](https://adguard-dns.io/public-dns.html), [Cloudflare (Malware Protection)](https://developers.cloudflare.com/1.1.1.1/setup/#1111-for-families), [DNS0](https://www.dns0.eu/), [DNS0 (ZERO)](https://www.dns0.eu/zero), [DNS4EU (Ad Blocking)](https://www.joindns4.eu/for-public), [DNS4EU (Protective)](https://www.joindns4.eu/for-public), [DNS4EU (Unfiltered)](https://www.joindns4.eu/for-public), [Mullvad (Base)](https://mullvad.net/help/dns-over-https-and-dns-over-tls), [Mullvad (Unfiltered)](https://mullvad.net/help/dns-over-https-and-dns-over-tls), [Quad9](https://quad9.net/service/service-addresses-and-features/), and [Wikimedia](https://meta.wikimedia.org/wiki/Wikimedia_DNS)
- Exposes the secret setting to enable the composable toolbar
- Exposes the secret setting to enable the homepage search bar
- Exposes the secret setting to enable the menu redesign
- Exposes the secret setting to enable the Unified Trust Panel
- Exposes the secret setting to open the homepage as a new tab
- Exposes the setting to enable shortcut suggestions, located at `General` -> `Search` -> `Address bar` -> `Show shortcuts`
- Exposes the setting to lock private browsing tabs with biometrics, located at `Privacy and security` -> `Private browsing` -> `Use screen lock to hide tabs in private browsing`
- Hides the `Passwords` drop-down menu item if the browser's password manager is disabled
- Hides the `Sync and save data` drop-down menu item if Firefox Sync isn't signed in
- Prevents Firefox from adding random recently visited sites to shortcuts/pins on the homepage
- Prevents Firefox from hardcoding and resetting [various preferences](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L362) on start, to allow users to configure them from the `about:config` if desired
- Removes privacy-invasive search engines *(Baidu, Bing, Cốc Cốc, Ecosia, Google, Qwant, Reddit, Seznam, Yahoo, YouTube)*, and adds various privacy-respecting search engines *([DuckDuckGo (HTML)](https://html.duckduckgo.com/html/), [DuckDuckGo (Lite)](https://lite.duckduckgo.com/lite/), [DuckDuckGo (No AI)](https://noai.duckduckgo.com/), [Mojeek](https://www.mojeek.com/), [Mullvad Leta (w/ Brave's index)](https://leta.mullvad.net/), [Mullvad Leta (w/ Google's index)](https://leta.mullvad.net/), [Startpage](https://www.startpage.com/), and [Startpage (EU)](https://eu.startpage.com/))* by default, as well as the option to use no search engine at all
- Removes the search widget onboarding page
- Removes the unnecessary/unwanted `Customize homepage` button from the homepage
- Sets the default search engine to [DuckDuckGo](https://duckduckgo.com/)

## Misc

- Disables [Encrypted Media Extensions *(EME)*](https://www.eff.org/deeplinks/2017/10/drms-dead-canary-how-we-just-lost-web-what-we-learned-it-and-what-we-need-do-next)
- Removes the [Adjust](https://github.com/adjust/android_sdk) library
- Removes the [Google Play Advertising ID](https://developers.google.com/android/reference/com/google/android/gms/ads/identifier/AdvertisingIdClient.Info) library
- Removes the [Google Play In-App Reviews](https://developer.android.com/guide/playcore/in-app-review) library
- Removes the [Google Play Install Referrer](https://developer.android.com/google/play/installreferrer/library) library
- Removes the proprietary [Google Play Firebase Messaging](https://firebase.google.com/docs/cloud-messaging/) library, and adds support for [UnifiedPush](https://unifiedpush.org/)
- Removes the [Sentry](https://github.com/getsentry/sentry) library
- Replaces the proprietary [Google Play FIDO](https://developers.google.com/android/reference/com/google/android/gms/fido/Fido) library with its FOSS [microG](https://github.com/microg/GmsCore/wiki) equivalent

## Mozilla

- Adds support for installing add-ons without the privileged `mozAddonManager` API, and disables the `mozAddonManager` API by default, to allow uBlock Origin to run on `addons.mozilla.org`, to prevent exposing a list of the user's installed add-ons to Mozilla, and to reduce attack surface *([1](https://bugzilla.mozilla.org/show_bug.cgi?id=1952390#c4), [2](https://bugzilla.mozilla.org/show_bug.cgi?id=1384330))*
- Disables [contextual feature recommendations](https://firefox-source-docs.mozilla.org/browser/components/asrouter/docs/contextual-feature-recommendation.html), and unwanted promotional content
- Disables [Contile](https://mozilla-services.github.io/contile/) *(Sponsored tiles)*
- Disables crash reporting for Fenix *(Firefox for Android)* at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/a99ec7fe9353f4a450c8e41a295cdab4a59331a2/patches/fenix-disable-crash-reporting.patch#L161)
- Disables crash reporting for Gecko at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L455)
- Disables feedback surveys *(Microsurveys)*
- Disables fetching featured collections/recommendations and extension icons from AMO *(`services.addons.mozilla.org`)*
- Disables [Firefox Suggest](https://blog.mozilla.org/products/firefox/firefox-news/firefox-suggest/) by default
- Disables [MARS *(Mozilla Ad Routing Service)*](https://web.archive.org/web/20250716044248/https://ads.mozilla.org/assets/docs/openapi/mars-api.html)
- Disables Mozilla's [GeoIP/Region Service](https://firefox-source-docs.mozilla.org/toolkit/modules/toolkit_modules/Region.html)
- Disables nags encouraging users to interact with certain browser features
- Disables Pocket integration
- Disables prompts encouraging users to set the browser as the system default
- Disables remote configuration of search engines from Mozilla
- Disables telemetry and data collection for Fenix *(Firefox for Android)* at [build-time](https://gitlab.com/ironfox-oss/IronFox/-/blob/a99ec7fe9353f4a450c8e41a295cdab4a59331a2/patches/fenix-disable-telemetry.patch#L29)
- Disables telemetry and data collection for Gecko at build-time *([1](https://gitlab.com/ironfox-oss/IronFox/-/blob/70038ef6d4de4ebcf86c5c972465c272426a5b8f/patches/gecko-disable-telemetry.patch#L29), [2](https://gitlab.com/ironfox-oss/IronFox/-/blob/6eb1f610d036636908e1a2f0508847671994b345/scripts/prebuild.sh#L538))*
- Disables the ["Sent from Firefox" footer/link sharing feature](https://searchfox.org/mozilla-release/rev/34c2c305/mobile/android/fenix/app/nimbus.fml.yaml#307)
- Disables [Studies](https://support.mozilla.org/kb/how-opt-out-studies-firefox-android) and experimentation
- Disables [submission of crash reports](https://support.mozilla.org/kb/how-send-crash-report-firefox-android) to Mozilla
- Disables [submission of technical and interaction data](https://support.mozilla.org/kb/technical-and-interaction-data) to Mozilla
- Removes the built-in `Mozilla Android Components - Ads Telemetry` and `Mozilla Android Components - Search Telemetry` browser extensions
- Removes the Firefox Sync onboarding page
- Removes [the Glean library](https://docs.telemetry.mozilla.org/concepts/glean/glean.html) from GeckoView by building [GeckoView `Lite`, instead of GeckoView `Omni`](https://firefox-source-docs.mozilla.org/mobile/android/geckoview/contributor/geckoview-architecture.html#lite-and-omni-builds)
- Removes Mozilla's default pins/shortcuts from the homepage
- Removes Mozilla's URL referral parameters from the built-in DuckDuckGo and Wikipedia search engines
- Removes the [Web Compatibility Reporter](https://support.mozilla.org/kb/report-breakage-due-blocking)
- Prevents Fenix *(Firefox for Android)* from fetching/managing experiments with [Nimbus](https://experimenter.info/getting-started/engineers/getting-started-for-android-engineers/)
- Prevents Gecko from fetching/managing experiments with [Nimbus](https://experimenter.info/getting-started/engineers/getting-started-for-android-engineers/)
- Prevents Remote Settings from downloading collections that are not specified in preferences
