# Frequently Asked Questions

- [How can I download IronFox?](#how-can-i-download-ironfox)
- [How should I download IronFox?](#how-should-i-download-ironfox)
- [Why isn't IronFox available on F-Droid?](#why-isnt-ironfox-available-on-f-droid)
- [Aren't Firefox-based browsers less secure than Chromium?](#arent-firefox-based-browsers-less-secure-than-chromium)
	- [So IronFox is insecure? Why should I use it then, what's the point?](#so-ironfox-is-insecure-why-should-i-use-it-then-whats-the-point)
- [Why is Google Safe Browsing supported and enabled by default?](#why-is-google-safe-browsing-supported-and-enabled-by-default)
- [Why does IronFox crash on GrapheneOS?](#why-does-ironfox-crash-on-grapheneos)
- [Can I use FIDO/U2F/Passkeys?](#can-i-use-fidou2fpasskeys)
- [Can I receive push notifications?](#can-i-receive-push-notifications)
- [Why isn't Resist Fingerprinting (RFP) enabled?](#why-isnt-resist-fingerprinting-rfp-enabled)
- [Why can't I install add-ons/extensions?](#why-cant-i-install-add-onsextensions)
- [What add-ons/extensions should I install?](#what-add-onsextensions-should-i-install)
- [Why is IronFox so slow?](#why-is-ironfox-so-slow)
- [Why can't I stream certain content from streaming services *(Ex. Amazon Prime Video, Apple TV+, Disney+, HBO Max, Hulu, Netflix, Peacock, Plex, Sling, Spotify, etc?)*](#why-cant-i-stream-certain-content-from-streaming-services-ex-amazon-prime-video-apple-tv-disney-hbo-max-hulu-netflix-peacock-plex-sling-spotify-etc)
- [Why can't I connect to certain websites?](#why-cant-i-connect-to-certain-websites)
- [Why are websites displayed in light mode?](#why-are-websites-displayed-in-light-mode)
- [Why do websites display the incorrect timezone?](#why-do-websites-display-the-incorrect-timezone)
- [Why are websites always displayed in English?](#why-are-websites-always-displayed-in-english)
- [Why do some fonts display incorrectly?](#why-do-some-fonts-display-incorrectly)
- [Why can't I see emojis?](#why-cant-i-see-emojis)
- [Why doesn't this website work?](#why-doesnt-this-website-work)

## How can I download IronFox?

You can currently download IronFox from [Accrescent](https://accrescent.app/app/org.ironfoxoss.ironfox), directly from [our GitLab releases](https://gitlab.com/ironfox-oss/IronFox/-/releases), or from [our F-Droid repository](https://fdroid.ironfoxoss.org/fdroid/repo/index.html).

## How *should* I download IronFox?

If possible, we highly recommend downloading IronFox from [Accrescent](https://accrescent.app/app/org.ironfoxoss.ironfox). If you're unfamiliar, [Accrescent](https://accrescent.app/) is an up-and-coming free and open source app store for Android, with a focus on [privacy and security](https://accrescent.app/features). Due to Accrescent's strong privacy and security properties, it's the most secure way to download and install IronFox; As a result, it's what we recommend using if possible.

For reference, Accrescent is also recommended by [GrapheneOS](https://grapheneos.org/), and supported by other privacy and security-focused projects, such as [Cake Wallet](https://cakewallet.com/), [Cryptomator](https://cryptomator.org/), [Molly](https://molly.im/), [IVPN](https://www.ivpn.net/en/), and [Organic Maps](https://organicmaps.app/).

## Why isn't IronFox available on F-Droid?

We currently do not support IronFox's inclusion in F-Droid's official repository, due to what we feel are significant privacy and security concerns. For more details, you can [read our issue where this was discussed here](https://gitlab.com/ironfox-oss/IronFox/-/issues/7).

We'd also recommend checking out [this article from privacy and security researchers](https://privsec.dev/posts/android/f-droid-security-issues/), [this post from the developer of WireGuard](https://gitlab.com/fdroid/fdroiddata/-/issues/3110#note_1613430404), and [this thread from GrapheneOS](https://infosec.exchange/@GrapheneOS@grapheneos.social/113900951182535101).

While we do provide our own [F-Droid repository](https://fdroid.ironfoxoss.org/fdroid/repo/index.html) for those who insist on using F-Droid, F-Droid's client isn't without its own privacy and security issues *(notably: [not properly notifying users of updates...](https://codeberg.org/celenity/Phoenix/issues/89#issuecomment-3145034))*, so other installation methods, such as [Accrescent](https://accrescent.app/app/org.ironfoxoss.ironfox), should be preferred if possible.

For those who do insist on using F-Droid to install and update IronFox, we would recommend using [F-Droid Basic](https://f-droid.org/packages/org.fdroid.basic/) as your preferred client of choice, as it is more secure than the standard F-Droid client, due to its reduced feature-set.

## Aren't Firefox-based browsers less secure than Chromium?

**Yes**. While we do as much as possible to improve the situation, IronFox is unfortunately also impacted by some of Firefox's fundamental issues. For more details, please see [our `Limitations` page](./Limitations#security).

Depending on your threat model, it may be preferable to use a Chromium-based browser, such as [Vanadium](https://grapheneos.org/features#vanadium) on GrapheneOS, or [Cromite](https://github.com/uazo/cromite).

We're deeply disappointed by Mozilla's lack of focus in this area, and we hope to see them improve in the future.

## So IronFox is **insecure**? Why should I use it then, what's the point?

I want to make an important distinction that I feel is often forgotten: something that is *less* secure is **NOT** necessarily *insecure*.

**Don't get me wrong**: As noted above, Firefox-based web browsers are objectively less secure than their Chromium counterparts. We are **not** trying to discredit Firefox's legitimate issues in this area.

**However**, *especially due to [the hardening that IronFox provides](./Features)*, assuming that users keep the browser up to date and follow other good privacy and security practices, we believe that IronFox is secure *enough* for most users and threat models.

While we do as much as we can to improve Firefox's security, we also feel that IronFox's primary strengths are in other areas. Notably, when compared to most Chromium browsers, IronFox offers users with stronger *privacy*, superior content blocking *([uBlock Origin](https://addons.mozilla.org/addon/ublock-origin/))*, more freedom, more customization, and more control *(ex. `about:config`)* over their browsing experience. IronFox also supports other important features missing from many of these browsers, such as extensions and end-to-end encrypted browser sync.

Additionally, with the notable exception of [Cromite](https://github.com/uazo/cromite), Chromium browsers on Android include proprietary Google Play libraries. **Unlike these browsers, IronFox is fully free and open source**. Unlike Chromium browsers, IronFox also supports [Google Safe Browsing](https://support.mozilla.org/kb/how-does-phishing-and-malware-protection-work) without Google Play Services. Thanks to our support for [UnifiedPush](https://unifiedpush.org/), we also provide support for push notifications without Google Play Services.

It should also be noted that Firefox-based web browsers, such as IronFox, help to promote browser engine diversity, and oppose [Google's browser engine monoculture/monopoly with Chromium](https://contrachrome.com/ContraChrome_en.pdf).

Even from a *security* perspective, IronFox has certain features that a majority of Chromium browsers still lack, such as [JavaScript Just-in-time Compilation *(JIT)*](https://microsoftedge.github.io/edgevr/posts/Super-Duper-Secure-Mode/) being disabled by default.

Ultimately, while Firefox-based web browsers *(including IronFox)* provide weaker security compared to their Chromium peers *(and this is indeed something important to consider and take into account)*, I wanted to highlight that IronFox brings lots of benefits to the table in *other* aspects, and that there are other important areas worth consideration.

**At the end of the day, I'm not going to tell you that IronFox is the perfect browser, or even that you should use it at all**. Which browser you should use depends on your [threat model](https://www.privacyguides.org/en/basics/threat-modeling/), personal preference, and values. **Most importantly, the browser you should use is the one that works best for you**. If that browser turns out to be IronFox? Great, welcome aboard! If not? No problem. I hope you at least learned something.

## Why is Google Safe Browsing supported and enabled by default?

Please see [our `Safe Browsing` page here](./Safe-Browsing).

## Why does IronFox crash on GrapheneOS?

On **GrapheneOS**, if the `Dynamic code loading via memory` exploit mitigation is enabled, IronFox might crash on launch with an error, stating `IronFox tried to perform DCL via memory`. Unfortunately, Firefox-based web browsers are currently incompatible with this protection.

If you encounter this issue, you can disable the `Dynamic code loading via memory` exploit mitigation for IronFox, by navigating to IronFox's `App info` *(You can get there by holding IronFox's app icon and selecting `App info`, *or* by navigating to `Settings` -> `Apps`, and finding + selecting `IronFox`), navigating to `Exploit protection` -> `Dynamic code loading via memory`, and selecting `Allowed`.

## Can I use FIDO/U2F/Passkeys?

Yes! While IronFox removes the proprietary [Google Play FIDO library](https://developers.google.com/android/reference/com/google/android/gms/fido/Fido), it replaces it with its FOSS [microG](https://github.com/microg/GmsCore/wiki) equivalent.

In addition to providing support for FIDO/U2F/Passkeys to users with **microG** installed, this can **also** be used **without microG or Google Play Services**, thanks to the excellent, free and open source [`HW Fido2 Provider` app](https://codeberg.org/s1m/hw-fido2-provider).

**NOTE**: After installing `HW Fido2 Provider`, ensure you set it as Android's `Preferred service for passwords, passkeys & autofill` *(On GrapheneOS, this is located at `Settings` -> `Passwords, passkeys & accounts` -> `Preferred service`)*.

## Can I receive push notifications?

Yes! While IronFox removes the proprietary [Google Play Firebase Messaging Library](https://firebase.google.com/docs/cloud-messaging/), it adds support for [UnifiedPush](https://unifiedpush.org/).

To use UnifiedPush, you'll first need to install and set-up a [distributor app](https://unifiedpush.org/users/distributors/) - we recommend [`Sunup`](https://unifiedpush.org/users/distributors/sunup/) for this.

After setting up your distributor, you can enable support for UnifiedPush by selecting the `Use UnifiedPush` option, located under `Advanced` in settings. You should then receive a prompt to restart IronFox; after restarting, you should be ready to go!

**NOTE**: By default, IronFox blocks prompts from websites to enable web notifications. If you'd like to receive notifications from websites, you can re-enable notifications prompts by navigating to `Privacy and security` -> `Site settings` -> `Permissions` -> `Notification` in settings, and selecting `Ask to allow`.

**NOTE**: To receive notifications while IronFox is in the background, [**GrapheneOS** users might unfortunately need to disable the `Dynamic code loading via storage` exploit protection for IronFox](https://gitlab.com/ironfox-oss/IronFox/-/issues/124). You can do this by navigating to IronFox's `App info` *(You can get there by holding IronFox's app icon and selecting `App info`, *or* by navigating to `Settings` -> `Apps`, and finding + selecting `IronFox`), navigating to `Exploit protection` -> `Dynamic code loading via storage`, and selecting `Allowed`.

## Why isn't Resist Fingerprinting (RFP) enabled?

[Resist Fingerprinting *(RFP)*](https://support.mozilla.org/kb/resist-fingerprinting) is Firefox's traditional fingerprinting protection, designed and intended for use by [Tor Browser](https://www.torproject.org/).

Unfortunately, due to it's design and intended use case, some of RFP's behavior is known to cause breakage and undesired behavior for users. RFP is also an all-or-nothing package, meaning you are forced to pick between having protection, or **no protection at all**.

Thankfully, for Firefox, Mozilla has recently developed [Suspected Fingerprinters Protection *(FPP)*](https://support.mozilla.org/kb/firefox-protection-against-fingerprinting#w_suspected-fingerprinters). **FPP** is far more flexible than RFP, as it allows users to enable or disable specific protections as needed, globally or on a per-site basis.

Due to RFP's issues, we enable **FPP** instead. Additionally, as Mozilla's default protections for FPP are currently very limited, we use our own [hardened configuration](https://gitlab.com/ironfox-oss/IronFox/-/blob/dev/patches/gecko-overlay/toolkit/components/resistfingerprinting/RFPTargetsDefault.inc) for it. Our hardened configuration is designed to match RFP, but with exceptions to avoid certain behaviors that are known to cause issues and undesired behavior for users. You can see our [`Features` page](./Features#fingerprinting) for more details.

We also include [a list](https://gitlab.com/ironfox-oss/IronFox/-/blob/dev/patches/gecko-overlay/services/settings/dumps/main/ironfox-fingerprinting-protection-overrides.json) of default overrides to fix breakage or harden protection on a per-site basis. If desired, you can disable our overrides, as well as overrides from Mozilla that serve a similar purpose, by setting `privacy.fingerprintingProtection.remoteOverrides.enabled` to `false` in your [`about:config`](about:config).

**Due to our use of FPP, and the reasons listed above, RFP is NOT recommended or supported**.

## Why can't I install add-ons/extensions?

By default, due to privacy and security concerns, IronFox disables the installation of add-ons. This has **no** impact on already installed extensions, and updates to those extensions.

To allow the installation of add-ons, **at the cost of privacy and security**, you can navigate to `Settings` -> `Advanced`, and select the option to `Allow installation of add-ons`. **It is recommended to disable this option when you are done installing your desired extension(s)**.

## What add-ons/extensions should I install?

Besides [uBlock Origin](https://addons.mozilla.org/addon/ublock-origin/)? Ideally, **none**.

In general, we highly recommend keeping your installed extensions to a minimum; **only use what you need**. Installing add-ons increases your attack surface, can help aid fingerprinting, degrades performance, and has various other concerns.

For more details, and information on why you don't actually need many of the extensions that you might think you do, take a look at [Arkenfox's `Extensions` wiki page](https://github.com/arkenfox/user.js/wiki/4.1-Extensions).

## Why is IronFox so slow?

By default, in order to improve security, IronFox disables [JavaScript Just-in-time Compilation *(JIT)*](https://microsoftedge.github.io/edgevr/posts/Super-Duper-Secure-Mode/). While this doesn't cause a noticeable difference on most modern devices, depending on your device, this might be what's causing the slowness you're experiencing.

**At the cost of security**, you can re-enable JIT by navigating to `Settings` -> `Privacy and security` -> `Site settings`, and selecting the option to `Enable JavaScript Just-in-time Compilation (JIT)`.

If re-enabling JIT doesn't give you the desired outcome, **at the cost of privacy**, you can re-enable disk cache by navigating to `Settings` -> `Privacy and security` -> `Site settings`, and selecting the option to `Enable disk cache`. You can also optionally enable it for secure webpages by selecting the option to `Enable disk cache for secure webpages` from the same screen.

If this *still* doesn't give you the desired outcome, please [file an issue](https://gitlab.com/ironfox-oss/IronFox/-/issues) and let us know!

## Why can't I stream certain content from streaming services (Ex. Amazon Prime Video, Apple TV+, Disney+, HBO Max, Hulu, Netflix, Peacock, Plex, Sling, Spotify, etc?)

IronFox does not support [Encrypted Media Extensions *(EME)*](https://wikipedia.org/wiki/Encrypted_Media_Extensions), due to privacy, security, freedom, and ideological concerns. For more details, see [this article](https://www.eff.org/deeplinks/2017/10/drms-dead-canary-how-we-just-lost-web-what-we-learned-it-and-what-we-need-do-next) from the EFF, as well as [this post](https://celenity.dev/posts/thoughts/drm/).

Unfortunately, certain streaming services *(such as the examples listed above)* arbitrarily prevent IronFox users *(as well as users of other privacy and security-focused projects)* from accessing content, by requiring EME for media playback. **When you encounter an issue due to this, please report this to the website's operator**! Please also [file an issue](https://codeberg.org/celenity/Phoenix/issues/new?template=.github%2fISSUE_TEMPLATE%2fweb-compat.yml), so that we can track/document impacted services.

**At your own risk**, **at the cost of privacy and security**, you can re-enable support for EME with a **not supported**, **not recommended** hidden setting, by navigating to `Settings` -> `About` -> `About IronFox`, tapping the `IronFox` logo 7 times until you see a message stating `Debug menu enabled`, navigating back to `Settings` -> `About` -> `Secret Settings`, and selecting the `Enable Encrypted Media Extensions (EME)` option. To play content, you will likely also need to enable the `Enable Widevine CDM` option from the same screen, which enables Google's Widevine Content Decryption Module *(CDM)*, provided by Android's [`MediaDrm` API](https://developer.android.com/reference/android/media/MediaDrm).

## Why can't I connect to certain websites?

By default, to improve security, IronFox [hard-fails](https://github.com/arkenfox/user.js/issues/1576) [OCSP](https://wikipedia.org/wiki/Online_Certificate_Status_Protocol) certificate revocation checks. Unfortunately, from time to time, OCSP servers can be down or inaccessible, which is most likely what's causing the connection issue you're experiencing.

**At the cost of security**, you can disable hard-failing OCSP certificate revocation checks, by navigating to `Settings` -> `Privacy and security`, and selecting the option to `Hard-fail OCSP revocation checks`. **It is highly recommended to re-enable this option as soon as possible after visiting the impacted website(s)**. **Please also report this issue to the website's operator**!

If you're still having connection issues, but can access the site from other browsers on your device, please [file an issue](https://gitlab.com/ironfox-oss/IronFox/-/issues) and let us know!

## Why are websites displayed in light mode?

By default, to protect against fingerprinting, IronFox sets the preferred website appearance to Light mode.

**At the cost of privacy**, you can change this by navigating to `Settings` -> `General` -> `Customization` -> `Website appearance`, and selecting `Dark` or `Follow browser theme`.

**NOTE**: The **[Dark Reader](https://addons.mozilla.org/addon/darkreader/)** add-on is known to cause severe performance issues on hardened Firefox-based browsers/configurations. Installing Dark Reader also poses privacy and security concerns, as detailed above. Dark Reader should be **AVOIDED** if possible, in favor of the `Website appearance` setting.

## Why do websites display the incorrect timezone?

By default, to protect against fingerprinting, IronFox spoofs the system's timezone to `UTC-0`.

**At the cost of privacy**, you can disable this protection globally by setting the value of `privacy.fingerprintingProtection.overrides` in your [`about:config`](about:config) to `-JSDateTimeUTC`. You can also disable this protection on a per-site basis by setting the value of `privacy.fingerprintingProtection.granularOverrides` in your [`about:config`](about:config) to `[{"firstPartyDomain":"example.com","overrides":"-JSDateTimeUTC"}]`, replacing `example.com` with the base domain of the website you'd like to disable timezone spoofing for.

**Please [file an issue](https://codeberg.org/celenity/Phoenix/issues/new?template=.github%2fISSUE_TEMPLATE%2fweb-compat.yml) for websites impacted by this, so that we can track/document the issue, and potentially add the site to [our list](https://gitlab.com/ironfox-oss/IronFox/-/blob/dev/patches/gecko-overlay/services/settings/dumps/main/ironfox-fingerprinting-protection-overrides.json) of default overrides**.

## Why are websites always displayed in English?

By default, to protect against fingerprinting, IronFox spoofs the preferred locale to English *(`en-US`)*.

**At the cost of privacy**, you can change this by navigating to `Settings` -> `General` -> `Language`, and selecting `Request English versions of webpages for stronger fingerprinting protection`.

## Why do some fonts display incorrectly?

By default, to protect against fingerprinting, IronFox restricts the visibility of fonts exposed to websites. Unfortunately, this is known to [cause issues with displaying certain text in Korean](https://gitlab.com/ironfox-oss/IronFox/-/issues/31).

**At the cost of privacy**, if you encounter this issue, you can disable this protection globally by setting the value of `privacy.fingerprintingProtection.overrides` in your [`about:config`](about:config) to `-FontVisibilityBaseSystem`. You can also disable this protection on a per-site basis by setting the value of `privacy.fingerprintingProtection.granularOverrides` in your [`about:config`](about:config) to `[{"firstPartyDomain":"example.com","overrides":"-FontVisibilityBaseSystem"}]`, replacing `example.com` with the base domain of the website you'd like to disable this protection for.

## Why can't I see emojis?

By default, to protect against fingerprinting, IronFox restricts the visibility of fonts exposed to websites. Unfortunately, this is known to break the display of emojis *(See [a testing page here](https://tmh.conlang.org/emoji-language/all-emoji.html))* for users on **Android 10** or lower.

If you encounter this issue, please upgrade to a newer version of Android as soon as possible ;)... but, for a work-around, **at the cost of privacy**, you can disable this protection globally by setting the value of `privacy.fingerprintingProtection.overrides` in your [`about:config`](about:config) to `-FontVisibilityBaseSystem,-FontVisibilityLangPack`. You can also disable this protection on a per-site basis by setting the value of `privacy.fingerprintingProtection.granularOverrides` in your [`about:config`](about:config) to `[{"firstPartyDomain":"example.com","overrides":"-FontVisibilityBaseSystem,-FontVisibilityLangPack"}]`, replacing `example.com` with the base domain of the website you'd like to disable this protection for.

## Why doesn't this website work?

For background, IronFox uses configs from **[Phoenix](https://phoenix.celenity.dev)** to harden and configure Gecko's preferences and underlying behavior. While it is both the goal of IronFox *and* Phoenix to provide users with a balance between strong privacy and security, while also preventing breakage where possible and preserving compatibility with websites, you may occasionally encounter issues.

As these issues generally stem from Gecko, **unless you're confident that the issue is caused by a IronFox-specific change**, please report the issue on [Phoenix's issue tracker](https://codeberg.org/celenity/Phoenix/issues/new?template=.github%2fISSUE_TEMPLATE%2fweb-compat.yml).

**If you're confident that the change is IronFox-specific**, please report the issue on [our issue tracker](https://gitlab.com/ironfox-oss/IronFox/-/issues) instead.

**Regardless of whether you're using Phoenix or IronFox's issue tracker**, please do the following before opening an issue:

- **Confirm that the website/issue is not already listed on [Phoenix's `Website Compatibility` page](https://phoenix.celenity.dev/compat)**
- **Ensure that IronFox is up-to-date, and confirm that the issue occurs on the latest release**
- **Verify that the issue does NOT occur on the latest release of vanilla Firefox from Mozilla** - *you can find [the latest `.apk`s here](https://ftp.mozilla.org/pub/fenix/releases/) - just find the version that corresponds to the version of IronFox you're using, this can be found by navigating to `Settings` -> `About` -> `About IronFox`*
- **If possible, please check if the issue occurs on a clean install of IronFox, without changing any settings** - *you can do this without impacting your current installation by using Android's [`Private Space`](https://source.android.com/docs/security/features/private-space) feature, or with [the Shelter app](https://github.com/PeterCxy/Shelter) if you're not on Android 15 or newer*
