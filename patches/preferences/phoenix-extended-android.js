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

// 001 ADVANCED FINGERPRINTING PROTECTION

/// Disable WebGL
// https://blog.browserscan.net/docs/webgl-fingerprinting
// https://security.stackexchange.com/questions/13799/is-webgl-a-security-concern

pref("webgl.disabled", true);

pref("browser.phoenix.status.extended", "001");

// 002 WEBRTC
// This will likely break WebRTC...

/// Force a single candidate for ICE generation
pref("media.peerconnection.ice.default_address_only", true);

/// Forcefully exclude local IP addresses, even in trusted scenarios
pref("media.peerconnection.ice.no_host", true);

/// Only use TURN servers/relays, no p2p...
// https://gitlab.torproject.org/tpo/applications/mullvad-browser/-/issues/40#note_2884663
pref("media.peerconnection.ice.relay_only", true);

pref("browser.phoenix.status.extended", "002");

// 003 MISC. PRIVACY

/// Disable TCP/dFPI storage access heuristics
// https://developer.mozilla.org/docs/Web/Privacy/State_Partitioning#storage_access_heuristics

pref("privacy.restrict3rdpartystorage.heuristic.opened_window_after_interaction", false);
pref("privacy.restrict3rdpartystorage.heuristic.recently_visited", false);
pref("privacy.restrict3rdpartystorage.heuristic.redirect", false); // [DEFAULT - Android]
pref("privacy.restrict3rdpartystorage.heuristic.window_open", false); // [DEFAULT - Android]

/// Only send cross-origin referers if hosts match
// https://wiki.mozilla.org/Security/Referrer

pref("network.http.referer.XOriginPolicy", 2);

pref("browser.phoenix.status.extended", "003");

// 004 ATTACK SURFACE REDUCTION

/// Disable WebAssembly
// https://spectrum.ieee.org/more-worries-over-the-security-of-web-assembly

pref("javascript.options.wasm", false);

pref("browser.phoenix.status.extended", "004");

// 005 MISC.

/// Prevent sites from automatically refreshing

pref("accessibility.blockautorefresh", true);
pref("browser.meta_refresh_when_inactive.disabled", true); // [DEFAULT - Android]

/// Stricter Autoplay Blocking

pref("media.autoplay.blocking_policy", 2); // [Default = 0]

pref("browser.phoenix.status.extended", "005");

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

// 001 ADVANCED FINGERPRINTING PROTECTION

/// Further harden FPP...
// As explained here: https://codeberg.org/celenity/Phoenix/issues/46
// Compared to standard, this just removes '-JSDateTimeUTC' - meaning timezone is spoofed to UTC-0...

pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CanvasImageExtractionPrompt,-CanvasExtractionBeforeUserInputIsBlocked,-CSSPrefersColorScheme,-FrameRate");

pref("browser.phoenix.status.extended.android", "successfully applied :D", locked);

