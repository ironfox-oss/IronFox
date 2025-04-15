
//

//
// Copyright (C) 2024-2025 celenity
//
// This file is part of Phoenix.
//
// Phoenix is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// Phoenix is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Phoenix. If not, see https://www.gnu.org/licenses/.
//

// This file contains preferences shared across Phoenix 'Extended' configs.

/* INDEX 

001: WEBRTC
002: ATTACK SURFACE REDUCTION
003: MISC. PRIVACY
004: MISC.

*/

/*** 001 WEBRTC ***/
// This will likely break WebRTC...

/// Always exclude local IP addresses, even in trusted scenarios
pref("media.peerconnection.ice.no_host", true);

/// Force a single candidate for ICE generation
pref("media.peerconnection.ice.default_address_only", true);

/// Only use TURN servers/relays
// No P2P
// https://gitlab.torproject.org/tpo/applications/mullvad-browser/-/issues/40#note_2884663
pref("media.peerconnection.ice.relay_only", true);

pref("browser.phoenix.status.extended", "001");

/*** 002 ATTACK SURFACE REDUCTION ***/

/// Disable WebAssembly (WASM)
// https://spectrum.ieee.org/more-worries-over-the-security-of-web-assembly
pref("javascript.options.wasm", false);

pref("browser.phoenix.status.extended", "002");

/*** 003 MISC. PRIVACY ***/

/// Only send cross-origin referers if hosts match
// https://wiki.mozilla.org/Security/Referrer
pref("network.http.referer.XOriginPolicy", 2);

pref("browser.phoenix.status.extended", "003");

/*** 004 MISC. ***/

/// Prevent sites from automatically refreshing
pref("accessibility.blockautorefresh", true);
pref("browser.meta_refresh_when_inactive.disabled", true); // [DEFAULT - Android]

/// Use stricter media autoplay blocking
// Default = 0
pref("media.autoplay.blocking_policy", 2);

pref("browser.phoenix.status.extended", "004");

pref("browser.phoenix.status.extended", "successfully applied :D", locked);


//

//
// Copyright (C) 2024-2025 celenity
//
// This file is part of Phoenix.
//
// Phoenix is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// Phoenix is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Phoenix. If not, see https://www.gnu.org/licenses/.
//

// This file contains preferences specific to Phoenix (Extended) on Android.

/* INDEX 

001: FINGERPRINTING PROTECTION

*/

/*** 001 FINGERPRINTING PROTECTION ***/

/// Further harden FPP...
// As explained here: https://codeberg.org/celenity/Phoenix/wiki/Extended#fingerprinting
// Compared to standard, this just removes '-JSDateTimeUTC' - meaning timezone is spoofed to UTC-0
pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CanvasImageExtractionPrompt,-CanvasExtractionBeforeUserInputIsBlocked,-CSSPrefersColorScheme,-FrameRate,-JSLocale");

pref("browser.phoenix.status.extended.android", "001");

/*** 002 MISC. PRIVACY + SECURITY ***/

/// Disable WebGL
// PRIVACY: Fingerprinting concerns
// SECURITY: Attack Surface Reduction
// https://blog.browserscan.net/docs/webgl-fingerprinting
// https://security.stackexchange.com/questions/13799/is-webgl-a-security-concern
// On desktop we're no longer setting/recommending this in favor of the built-in `Block WebGL` filterlist in uBlock Origin (and I'm sure we'll also override this on IronFox once we get our custom config working...), but on Android we can't control uBlock Origin/set policies, so let's make sure this is disabled.
pref("webgl.disabled", true);

pref("browser.phoenix.status.extended.android", "002");

pref("browser.phoenix.status.extended.android", "successfully applied :D", locked);

