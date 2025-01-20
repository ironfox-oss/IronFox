//
// Extended hardening.

// We can do better.

// 001 ADVANCED FINGERPRINTING PROTECTION

/// Further harden FPP...
// As explained here: https://codeberg.org/celenity/Phoenix/issues/46

pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CanvasImageExtractionPrompt,-CanvasExtractionBeforeUserInputIsBlocked,-CSSPrefersColorScheme,-FrameRate");

/// Disable WebGL
// https://blog.browserscan.net/docs/webgl-fingerprinting
// https://security.stackexchange.com/questions/13799/is-webgl-a-security-concern

pref("webgl.disabled", true);

pref("browser.phoenix.cfg.extended.status", "001", locked);

/// 002 WEBRTC

// Never leak IP addresses - This *will* break WebRTC

pref("media.peerconnection.ice.default_address_only", true);
pref("media.peerconnection.ice.no_host", true);

pref("browser.phoenix.cfg.extended.status", "002", locked);

// 003 MISC. PRIVACY

/// Disable dFPI Heuristics
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15404

pref("privacy.restrict3rdpartystorage.heuristic.opened_window_after_interaction", false);
pref("privacy.restrict3rdpartystorage.heuristic.recently_visited", false);
pref("privacy.restrict3rdpartystorage.heuristic.redirect", false); // [DEFAULT]
pref("privacy.restrict3rdpartystorage.heuristic.window_open", false); // [DEFAULT]

/// Only send cross-origin referers if hosts match

pref("network.http.referer.XOriginPolicy", 2);

pref("browser.phoenix.cfg.extended.status", "003", locked);

// 004 ATTACK SURFACE REDUCTION

/// Disable WebAssembly
// https://spectrum.ieee.org/more-worries-over-the-security-of-web-assembly

pref("javascript.options.wasm", false);

pref("browser.phoenix.cfg.extended.status", "004", locked);

// 005 MISC.

/// Prevent sites from automatically refreshing

pref("browser.meta_refresh_when_inactive.disabled", true); // [DEFAULT]

/// Stricter Autoplay Blocking

pref("media.autoplay.blocking_policy", 2); // [Default = 0]

pref("browser.phoenix.cfg.extended.status", "005", locked);

pref("browser.phoenix.cfg.extended.status", "successfully applied :D", locked);
