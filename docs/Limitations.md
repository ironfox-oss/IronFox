# Limitations

Your web browser is a tool; as such, it's important to use the right tool for the right job. You wouldn't use a bulldozer to unscrew a screw, or a feather as a knife.

Please take the time to [threat model](https://www.privacyguides.org/en/basics/threat-modeling/). Determine what you're trying to protect, why you're trying to protect it, who you're trying to protect it from, etc. **Everyone** has their own unique threat model and different needs, goals, and desires; you must determine yours.

**When using IronFox, you must understand the following**:

## Fingerprinting

IronFox can **not** defeat sophisticated fingerprinting. **Nothing besides [Tor Browser](https://www.torproject.org/) can**. Please use Tor Browser if your threat model calls for it *(Ex. whistleblowers, political dissidents, journalists, etc.)*. IronFox [still takes steps to protect users against fingerprinting](./Features#fingerprinting) *(which we believe are sufficient for most threat models)*, but this is something important to keep in mind.

## Security

While we do as much as possible to improve the situation, it should be noted that Firefox-based web browsers, including IronFox, have security deficiencies when compared to Chromium. This is *especially* notable on Android. For more details, see [this article from GrapheneOS](https://grapheneos.org/usage#web-browsing), and [this article from madaidan *(a security researcher)*](https://madaidans-insecurities.github.io/firefox-chromium.html).

Depending on your threat model, it may be preferable to use a Chromium-based browser, such as [Vanadium](https://grapheneos.org/features#vanadium) on GrapheneOS, or [Cromite](https://github.com/uazo/cromite).
