//
// Extended hardening.

// We can do better.

// 001 ADVANCED FINGERPRINTING PROTECTION

/// Enable RFP (resistFingerprinting)
// https://github.com/arkenfox/user.js/blob/master/user.js#L745
// NOTE: You can add site exceptions to `privacy.resistFingerprinting.exemptedDomains` in your about:config

pref("privacy.resistFingerprinting", true);

/// Disable WebGL
// https://blog.browserscan.net/docs/webgl-fingerprinting
// https://security.stackexchange.com/questions/13799/is-webgl-a-security-concern

pref("webgl.disabled", true);

pref("browser.phoenix.extended.001.applied", true);

/// 002 WEBRTC

// Never leak IP addresses - This *will* break WebRTC

pref("media.peerconnection.ice.default_address_only", true);
pref("media.peerconnection.ice.no_host", true);

pref("browser.phoenix.extended.002.applied", true);

// 003 MISC. PRIVACY

/// Disable ETP WebCompat & Heuristics

pref("privacy.antitracking.enableWebcompat", false);
pref("privacy.restrict3rdpartystorage.heuristic.opened_window_after_interaction", false);
pref("privacy.restrict3rdpartystorage.heuristic.recently_visited", false);
pref("privacy.restrict3rdpartystorage.heuristic.redirect", false); // [DEFAULT]
pref("privacy.restrict3rdpartystorage.heuristic.window_open", false); // [DEFAULT]

/// Only send cross-origin referers if hosts match

pref("network.http.referer.XOriginPolicy", 2);

pref("browser.phoenix.extended.003.applied", true);

// 004 ATTACK SURFACE REDUCTION

/// Disable WebAssembly
// https://spectrum.ieee.org/more-worries-over-the-security-of-web-assembly

pref("javascript.options.wasm", false);

pref("browser.phoenix.extended.004.applied", true);

// 005 MISC.

/// Prevent sites from automatically refreshing

pref("browser.meta_refresh_when_inactive.disabled", true); // [DEFAULT]

/// Stricter Autoplay Blocking

pref("media.autoplay.blocking_policy", 2); // [Default = 0]

pref("browser.phoenix.extended.005.applied", true);

pref("browser.phoenix.extended.applied", true);
