//
// The Phoenix shall rise from the ashes of what fell before it.
// RIP Mull.

pref("browser.phoenix.version", "2025.01.06.1");

// Let's begin.

// 000 ABOUT:CONFIG

/// Enable about:config support on Android
// Note that regardless of this pref, you can also access the about:config via chrome://geckoview/content/config.xhtml.
pref("general.aboutConfig.enable", true);

/// Disable annoying warnings when attempting to access the about:config
pref("general.warnOnAboutConfig", false);

pref("browser.phoenix.000.applied", true);

// 001 DATA COLLECTION

/// Shield Studies/Normandy/Nimbus
// https://mozilla.github.io/normandy/
// https://wiki.mozilla.org/Firefox/Shield/Shield_Studies
// https://support.mozilla.org/kb/shield
// https://support.mozilla.org/kb/how-stop-firefox-making-automatic-connections#w_experiments-or-studies
// https://wiki.mozilla.org/Advocacy/heartbeat
// https://experimenter.info/
// resource://nimbus/ExperimentAPI.sys.mjs

pref("app.normandy.api_url", ""); // [HIDDEN]
pref("app.normandy.enabled", false); // [HIDDEN]
pref("app.normandy.first_run", false); // [HIDDEN]
pref("app.normandy.last_seen_buildid", ""); // [HIDDEN]
pref("app.normandy.logging.level", 70);  // [HIDDEN], Limits logging to fatal only
pref("app.normandy.user_id", ""); // [HIDDEN]
pref("app.shield.optoutstudies.enabled", false); // [HIDDEN]
pref("messaging-system.log", "off"); // Disables logging
pref("messaging-system.rsexperimentloader.enabled", false); // [HIDDEN]
pref("messaging-system.rsexperimentloader.collection_id", ""); // [HIDDEN]
pref("nimbus.appId", "");  // [HIDDEN], https://searchfox.org/mozilla-central/source/toolkit/components/backgroundtasks/defaults/backgroundtasks_browser.js
pref("toolkit.telemetry.pioneer-new-studies-available", false); // [HIDDEN]

/// WebVTT Testing Events
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml

pref("media.webvtt.testing.events", false); // [DEFAULT]

/// Origin Trials
// https://wiki.mozilla.org/Origin_Trials

pref("dom.origin-trials.enabled", false);

/// Crash Reporting
// https://github.com/mozilla-services/socorro
// https://wiki.mozilla.org/Socorro
// https://firefox-source-docs.mozilla.org/tools/sanitizer/asan_nightly.html

pref("breakpad.reportURL", "");
pref("browser.tabs.crashReporting.includeURL", false); // [DEFAULT} - Defense in depth
pref("browser.tabs.crashReporting.sendReport", false);
pref("toolkit.crashreporter.include_context_heap", false); // [DEFAULT] - Defense in depth

/// X-Frame Options Error Reporting
// https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/xfocsp-error-report-ping.html

pref("security.xfocsp.errorReporting.automatic", false); // [DEFAULT]
pref("security.xfocsp.errorReporting.enabled", false);

/// Coverage
// https://blog.mozilla.org/data/2018/08/20/effectively-measuring-search-in-firefox/
// https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/pings/CoveragePing.sys.mjs

pref("toolkit.coverage.enabled", false); // [HIDDEN - DEFAULT]
pref("toolkit.coverage.endpoint.base", ""); // [HIDDEN]
pref("toolkit.coverage.opt-out", true); // [HIDDEN]
pref("toolkit.telemetry.coverage.opt-out", true); // [HIDDEN]

/// Misc. Telemetry
// https://searchfox.org/mozilla-central/source/testing/geckodriver/src/prefs.rs
// https://wiki.mozilla.org/QA/Telemetry
// https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html 
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
// https://searchfox.org/mozilla-central/source/remote/shared/RecommendedPreferences.sys.mjs
// https://searchfox.org/mozilla-central/source/testing/profiles/perf/user.js

pref("browser.places.interactions.enabled", false); // [HIDDEN] https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js
pref("browser.search.serpEventTelemetryCategorization.enabled", false); // [HIDDEN]
pref("browser.search.serpEventTelemetryCategorization.regionEnabled", false); // [HIDDEN]
pref("browser.search.serpMetricsRecordedCounter", 0); // [HIDDEN - DEFAULT]
pref("datareporting.dau.cachedUsageProfileID", "beefbeef-beef-beef-beef-beeefbeefbee"); // [HIDDEN] https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/app/ClientID.sys.mjs#44
pref("datareporting.healthreport.documentServerURI", ""); // [HIDDEN]
pref("datareporting.healthreport.logging.consoleEnabled", false); // [HIDDEN]
pref("datareporting.healthreport.service.enabled", false); // [HIDDEN]
pref("datareporting.healthreport.service.firstRun", false); // [HIDDEN]
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("datareporting.policy.dataSubmissionPolicyAccepted", false); // [HIDDEN]
pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
pref("datareporting.policy.firstRunURL", "");
pref("dom.security.unexpected_system_load_telemetry_enabled", false);
pref("network.jar.record_failure_reason", false); // [DEFAULT] - https://searchfox.org/mozilla-release/source/modules/libpref/init/StaticPrefList.yaml#14397
pref("network.traffic_analyzer.enabled", false); // https://searchfox.org/mozilla-release/source/modules/libpref/init/StaticPrefList.yaml#13298
pref("network.trr.confirmation_telemetry_enabled", false);
pref("nimbus.telemetry.targetingContextEnabled", false); // [HIDDEN] https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js#2001
pref("privacy.imageInputTelemetry.enableTestMode", false); // [DEFAULT] "Event Telemetry" https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15549
pref("privacy.trackingprotection.emailtracking.data_collection.enabled", false);
pref("toolkit.content-background-hang-monitor.disabled", true);
pref("toolkit.telemetry.archive.enabled", false); // [HIDDEN]
pref("toolkit.telemetry.bhrPing.enabled", false); // [HIDDEN]
pref("toolkit.telemetry.cachedClientID", "c0ffeec0-ffee-c0ff-eec0-ffeec0ffeec0");
pref("toolkit.telemetry.cachedProfileGroupID", "decafdec-afde-cafd-ecaf-decafdecafde");
pref("toolkit.telemetry.dap.helper.hpke", "");
pref("toolkit.telemetry.dap.helper.url", "");
pref("toolkit.telemetry.dap.leader.hpke", "");
pref("toolkit.telemetry.dap.leader.url", "");
pref("toolkit.telemetry.dap.logLevel", "Off");
pref("toolkit.telemetry.dap_enabled", false); // [DEFAULT]
pref("toolkit.telemetry.dap_task1_enabled", false); // [DEFAULT]
pref("toolkit.telemetry.dap_task1_taskid", ""); // [DEFAULT]
pref("toolkit.telemetry.dap_visit_counting_enabled", false); // [DEFAULT]
pref("toolkit.telemetry.dap_visit_counting_experiment_list", "[]"); // [DEFAULT]
pref("toolkit.telemetry.debugSlowSql", false); // [DEFAULT]
pref("toolkit.telemetry.enabled", false); // [DEFAULT on Stable, Focus, & Klar - Beta & Nightly are set to true...]
pref("toolkit.telemetry.healthping.enabled", false); // [HIDDEN]
pref("toolkit.telemetry.newProfilePing.enabled", false);
pref("toolkit.telemetry.pioneerId", ""); // [HIDDEN]
pref("toolkit.telemetry.previousBuildID", ""); // [HIDDEN]
pref("toolkit.telemetry.reportingpolicy.firstRun", false); // [HIDDEN]
pref("toolkit.telemetry.server", "data;");
pref("toolkit.telemetry.server_owner", "");
pref("toolkit.telemetry.shutdownPingSender.backgroundtask.enabled", false); // [HIDDEN]
pref("toolkit.telemetry.shutdownPingSender.enabled", false); // [HIDDEN]
pref("toolkit.telemetry.shutdownPingSender.enabledFirstSession", false); // [HIDDEN]
pref("toolkit.telemetry.testing.suppressPingsender", true); // [HIDDEN]
pref("toolkit.telemetry.translations.logLevel", "Off");
pref("toolkit.telemetry.unified", false); // [DEFAULT]
pref("toolkit.telemetry.updatePing.enabled", false); // [HIDDEN]
pref("toolkit.telemetry.user_characteristics_ping.current_version", 0); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.last_version_sent", 0); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.logLevel", "Off");
pref("toolkit.telemetry.user_characteristics_ping.opt-out", true);
pref("toolkit.telemetry.user_characteristics_ping.send-once", false); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.uuid", ""); // [DEFAULT]

/// Misc. UX - Harmless but does not apply to us

pref("app.normandy.shieldLearnMoreUrl", ""); // [HIDDEN]
pref("datareporting.healthreport.infoURL", ""); // [HIDDEN]
pref("extensions.recommendations.privacyPolicyUrl", ""); // [DEFAULT]
pref("toolkit.crashreporter.infoURL", ""); // [HIDDEN]
pref("toolkit.datacollection.infoURL", ""); // [HIDDEN]

pref("browser.phoenix.001.applied", true);

// 002 MOZILLA CRAP™

/// Firefox Recommendations & "Discovery"
// https://support.mozilla.org/kb/recommendations-firefox
// https://support.mozilla.org/kb/personalized-extension-recommendations

pref("extensions.getAddons.browseAddons", "");
pref("extensions.getAddons.discovery.api_url", "data;"); // [HIDDEN] https://searchfox.org/mozilla-central/source/testing/profiles/common/user.js
pref("extensions.getAddons.showPane", false); // [HIDDEN]
pref("extensions.htmlaboutaddons.recommendations.enabled", false);
pref("extensions.recommendations.themeRecommendationUrl", ""); // [DEFAULT]

/// Fakespot

pref("toolkit.shopping.ohttpConfigURL", "");
pref("toolkit.shopping.ohttpRelayURL", "");

/// Prevent Mozilla domains from having special privileges
// https://firefox-source-docs.mozilla.org/dom/ipc/process_model.html#privileged-mozilla-content

pref("browser.tabs.remote.separatePrivilegedMozillaWebContentProcess", false); // [DEFAULT]
pref("browser.tabs.remote.separatedMozillaDomains", "");
pref("dom.ipc.processCount.privilegedmozilla", 0);
pref("extensions.webextensions.restrictedDomains", "");
pref("svg.context-properties.content.allowed-domains", ""); // [DEFAULT]

/// Remove Mozilla URL tracking params

pref("extensions.getAddons.search.browseURL", "https://addons.mozilla.org/%LOCALE%/android/search?q=%TERMS%");

/// Disable Mozilla Web Compatibility Reporter
// Harmless from a privacy perspective - We just don't want to waste Mozilla's time due to our custom set-up...
// Also acts as attack surface reduction & a potential performance improvement

pref("extensions.webcompat-reporter.enabled", false); // [DEFAULT except for Beta & Nightly releases...]
pref("extensions.webcompat-reporter.newIssueEndpoint", "");

pref("browser.phoenix.002.applied", true);

// 003 Search & URL Bar

/// Allow using a different search engine in Private Windows vs. Normal Windows

pref("browser.search.separatePrivateDefault.ui.enabled", true);

// Prompt to use Private Browsing

pref("browser.search.separatePrivateDefault.urlbarResult.enabled", true); // [HIDDEN]

/// Always show Punycode - Helps prevent phishing & IDN Homograph Attacks
// https://wikipedia.org/wiki/IDN_homograph_attack

pref("network.IDN_show_punycode", true);

pref("browser.phoenix.003.applied", true);

// 004 Implicit Connections

/// Disable Network Prefetching
// https://developer.mozilla.org/docs/Glossary/Prefetch

pref("browser.places.speculativeConnect.enabled", false); // [HIDDEN]
pref("browser.urlbar.speculativeConnect.enabled", false); // [HIDDEN]
pref("network.dns.disablePrefetch", true);
pref("network.dns.disablePrefetchFromHTTPS", true);
pref("network.http.speculative-parallel-limit", 0);
pref("network.predictor.enable-hover-on-ssl", false); // [DEFAULT]
pref("network.predictor.enable-prefetch", false);
pref("network.predictor.enabled", false);
pref("network.prefetch-next", false);

/// Disable Search Suggestions

pref("browser.search.suggest.enabled", false);
pref("browser.search.suggest.enabled.private", false);

pref("browser.phoenix.004.applied", true);

// 005 HTTP(S) - Mixed Content & General Network Hardening

/// Enforce using HTTPS as much as possible

pref("dom.security.https_first", true); // [DEFAULT on Beta & Nightly]
pref("dom.security.https_first_for_custom_ports", true); // [DEFAULT, DEFENSE IN DEPTH]
pref("dom.security.https_first_pbm", true); // [DEFAULT]
pref("dom.security.https_first_schemeless", true); // [DEFAULT]
pref("dom.security.https_only_mode", true);
pref("dom.security.https_only_mode.upgrade_local", true);
pref("dom.security.https_only_mode_pbm", true);
pref("security.mixed_content.block_active_content", true); // [DEFAULT]
pref("security.mixed_content.block_display_content", true);
pref("security.mixed_content.block_object_subrequest", true);
pref("security.mixed_content.upgrade_display_content", true);
pref("security.mixed_content.upgrade_display_content.audio", true); // [DEFAULT]
pref("security.mixed_content.upgrade_display_content.image", true); // [DEFAULT]
pref("security.mixed_content.upgrade_display_content.video", true); // [DEFAULT]

/// Prevent sending HTTP requests to websites that do not respond quickly to check if they support HTTPS

pref("dom.security.https_only_mode_send_http_background_request", false);

/// Show suggestions when an HTTPS page can not be found 

pref("dom.security.https_only_mode_error_page_user_suggestions", true);

/// Always warn on insecure webpages

pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
pref("security.warn_submit_secure_to_insecure", true); // [DEFAULT] - Warn when submitting a form from HTTP to HTTPS

/// Show detailed information on insecure warning pages

pref("browser.xul.error_pages.expert_bad_cert", true);

/// Disable TLS1.3 0-RTT (Not forward secret)
// https://github.com/tlswg/tls13-spec/issues/1001

pref("security.tls.enable_0rtt_data", false);

// Require safe renegotiations - Disables RFC 5746

pref("security.ssl.require_safe_negotiation", true);

/// Enforce preloading intermediates
// https://wiki.mozilla.org/Security/CryptoEngineering/Intermediate_Preloading

pref("security.remote_settings.intermediates.enabled", true); // [DEFAULT]

/// Never downgrade to insecure TLS 1.0/1.1

pref("security.tls.insecure_fallback_hosts", ""); // [DEFAULT]
pref("security.tls.version.enable-deprecated", false); // [DEFAULT]

/// Enforce TLS 1.3 downgrade protection
// https://bugzilla.mozilla.org/show_bug.cgi?id=1576790

pref("security.tls.hello_downgrade_check", true); // [DEFAULT]

/// Only load secure websockets from HTTPS pages

pref("network.websocket.allowInsecureFromHTTPS", false); // [DEFAULT]

/// Enable Post Quantum Key Agreement (Kyber)

pref("media.webrtc.enable_pq_dtls", true); // [DEFAULT]
pref("network.http.http3.enable_kyber", true);
pref("security.tls.enable_kyber", true);

/// Disable Captive Portal Detection & Connectivity Checks
// Privacy & security concerns, and in general best handled by the OS.
// https://support.mozilla.org/kb/how-stop-firefox-making-automatic-connections#w_network-detection
// https://www.eff.org/deeplinks/2017/08/how-captive-portals-interfere-wireless-security-and-privacy

pref("captivedetect.canonicalContent", "");
pref("captivedetect.canonicalURL", "");
pref("network.captive-portal-service.enabled", false); // [DEFAULT]
pref("network.connectivity-service.DNSv4.domain", "");
pref("network.connectivity-service.DNSv6.domain", "");
pref("network.connectivity-service.enabled", false);
pref("network.connectivity-service.IPv4.url", "");
pref("network.connectivity-service.IPv6.url", "");

/// Prevent Proxy bypasses & undesired information leakage

pref("network.file.disable_unc_paths", true); // [HIDDEN]
pref("network.gio.supported-protocols", ""); // [HIDDEN]
pref("network.proxy.allow_bypass", false);
pref("network.proxy.failover_direct", false);
pref("network.proxy.socks_remote_dns", true);
pref("network.proxy.socks5_remote_dns", true); // [DEFAULT]

pref("browser.phoenix.005.applied", true);

// 006 DNS

/// Disable Mozilla's DoH Rollout

pref("doh-rollout.disable-heuristics", true); // [HIDDEN]
pref("doh-rollout.enabled", false); // [HIDDEN]
pref("doh-rollout.skipHeuristicsCheck", true); // [HIDDEN]
pref("doh-rollout.uri", ""); // [HIDDEN]
pref("network.trr.default_provider_uri", "");

/// Enable DoH & Set to Quad9 by default

pref("network.trr.custom_uri", "https://dns.quad9.net/dns-query");
pref("network.trr.mode", 3);
pref("network.trr.uri", "https://dns.quad9.net/dns-query");

/// Skip DoH Connectivity Checks

pref("network.connectivity-service.DNS_HTTPS.domain", "");
pref("network.trr.confirmationNS", "skip");

/// Never disable DoH from registry checks
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml

pref("network.notify.checkForNRPT", false);
pref("network.notify.checkForProxies", false);

/// Enforce EncryptedClientHello
// We also set "DisableEncryptedClientHello" in policies
// https://mozilla.github.io/policy-templates/#disableencryptedclienthello
// https://blog.cloudflare.com/announcing-encrypted-client-hello

pref("network.dns.echconfig.enabled", true); // [DEFAULT]
pref("network.dns.http3_echconfig.enabled", true); // [DEFAULT]

/// Enable Native DNS HTTPS Lookups

pref("network.dns.native_https_query", true); // [DEFAULT]

/// Fix IPv6 connectivity when DoH is enabled
// https://codeberg.org/divested/brace/pulls/5

pref("network.dns.preferIPv6", true);

pref("browser.phoenix.006.applied", true);

// 007 CERTIFICATES

/// Enforce OCSP & Stapling

pref("security.OCSP.enabled", 1); // [Default = 2, which only checks EV certificates... 1 checks both DV & EV certs, default on desktop]
pref("security.ssl.enable_ocsp_must_staple", true); // [DEFAULT]
pref("security.ssl.enable_ocsp_stapling", true); // [DEFAULT]

/// Hard-fail OCSP by default
// Personally have not ran into any issues from this in YEARS... & it provides a significant security improvement
// Can reconsider if people start having issues

pref("security.OCSP.require", true);

/// Enable CRLite & use where possible

pref("security.pki.crlite_mode", 2); // [DEFAULT on Nightly]
pref("security.remote_settings.crlite_filters.enabled", true); // [DEFAULT on Nightly]

/// Enforce Strict Certificate Pinning

pref("security.cert_pinning.enforcement_level", 2);

/// Enable & Enforce Certificate Transparency
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15868

pref("security.pki.certificate_transparency.mode", 2); // [Default = 0]
pref("security.pki.certificate_transparency.disable_for_hosts", ""); // [DEFAULT]
pref("security.pki.certificate_transparency.disable_for_spki_hashes", ""); // [DEFAULT]

pref("browser.phoenix.007.applied", true);

// 008 DOWNLOADS

/// Always prompt before downloading files

pref("browser.download.always_ask_before_handling_new_types", true);
pref("browser.download.useDownloadDir", false);

// Enforce blocking insecure downloads

pref("dom.block_download_insecure", true); // [DEFAULT]

pref("browser.phoenix.008.applied", true);

// 009 SAFE BROWSING

/// Enable Safe Browsing by default
// This won't do anything if you don't have an API key from Google, though doesn't hurt...
// Harmless from a privacy perspective due to the below changes, also effective at preventing real-time malicious domains and downloads.
// We will of course **ALWAYS** give users the ability to disable.

pref("browser.safebrowsing.blockedURIs.enabled", true); // [DEFAULT]
pref("browser.safebrowsing.downloads.enabled", true);
pref("browser.safebrowsing.malware.enabled", true); // [DEFAULT]
pref("browser.safebrowsing.phishing.enabled", true); // [DEFAULT]
pref("browser.safebrowsing.provider.google.gethashURL", "https://safebrowsing.google.com/safebrowsing/gethash?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2"); // [DEFAULT]
pref("browser.safebrowsing.provider.google.updateURL", "https://safebrowsing.google.com/safebrowsing/downloads?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2&key=%GOOGLE_SAFEBROWSING_API_KEY%"); // [DEFAULT]
pref("browser.safebrowsing.provider.google4.gethashURL", "https://safebrowsing.googleapis.com/v4/fullHashes:find?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST"); // [DEFAULT]
pref("browser.safebrowsing.provider.google4.updateURL", "https://safebrowsing.googleapis.com/v4/threatListUpdates:fetch?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST"); // [DEFAULT]

/// Prevent sending metadata of downloaded files to Google
// https://support.mozilla.org/kb/how-does-phishing-and-malware-protection-work#w_how-does-phishing-and-malware-protection-work-in-firefox
// https://feeding.cloud.geek.nz/posts/how-safe-browsing-works-in-firefox/

pref("browser.safebrowsing.downloads.remote.enabled", false);
pref("browser.safebrowsing.downloads.remote.url", "");

/// Enforce that no data is shared with Google
// https://bugzilla.mozilla.org/show_bug.cgi?id=1351147

pref("browser.safebrowsing.provider.google.dataSharing.enabled", false); // [DEFAULT]
pref("browser.safebrowsing.provider.google4.dataSharing.enabled", false); // [DEFAULT]
pref("browser.safebrowsing.provider.google4.dataSharingURL", "");

/// Show advanced details on pages blocked by Safe Browsing by default

pref("browser.xul.error_pages.show_safe_browsing_details_on_load", true); // [HIDDEN]

/// By default, when you report a Safe Browsing false positive, it sends the URL to both Mozilla & Google (NOT PROXIED), as well as your locale to Mozilla
// Ex. https://en-us.phish-error.mozilla.com/?url=example.org - Which redirects you directly to https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=example.org 
// We can improve privacy & speed by sending the domain *only* to Google & without sending your locale to anyone
// We could also potentially strip tpl=mozilla which tells Google the request is from Firefox - though it looks like there is a different page for Firefox users with a better privacy policy, so we will leave it for now
// Unclear whether 'MalwareMistake' is used, but we can set it anyways

pref("browser.safebrowsing.provider.google.reportMalwareMistakeURL", "https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=");
pref("browser.safebrowsing.provider.google.reportPhishMistakeURL", "https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=");
pref("browser.safebrowsing.provider.google4.reportMalwareMistakeURL", "https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=");
pref("browser.safebrowsing.provider.google4.reportPhishMistakeURL", "https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=");

/// Similar behavior also appears to happen when you report a URL to Safe Browsing

pref("browser.safebrowsing.reportPhishURL", "https://safebrowsing.google.com/safebrowsing/report_phish/?tpl=mozilla&url=");

/// Unclear whether these are actually used or not, but looks like Firefox has some kind of functionality to view a "report" from Safe Browsing about the safety, history, & general status of a site
// By default, it unnecessarily redirects from ex. https://safebrowsing.google.com/safebrowsing/diagnostic?site=example.org to https://transparencyreport.google.com/safe-browsing/search?url=example.org
// We can skip the redirect to improve speed

pref("browser.safebrowsing.provider.google.reportURL", "https://transparencyreport.google.com/safe-browsing/search?url=");
pref("browser.safebrowsing.provider.google4.reportURL", "https://transparencyreport.google.com/safe-browsing/search?url=");

pref("browser.phoenix.009.applied", true);

// 010 GEOLOCATION

/// Prevent Wi-Fi Scanning

pref("browser.region.network.scan", false); // [DEFAULT]
pref("geo.wifi.scan", false); // [HIDDEN] https://searchfox.org/mozilla-release/source/remote/shared/RecommendedPreferences.sys.mjs#299

/// Disable "Region Updates"
// https://firefox-source-docs.mozilla.org/toolkit/modules/toolkit_modules/Region.html

pref("browser.region.network.url", "");
pref("browser.region.update.enabled", false);

/// Geo Provider
// Enable BeaconDB as a fallback for retrieving geolocation instead of Google

pref("geo.provider.network.url", "https://beacondb.net/v1/geolocate");

pref("browser.phoenix.010.applied", true);

// 011 AI
// https://support.mozilla.org/kb/ai-chatbot

/// Ensure that AI functionality is disabled by default

pref("browser.ml.enable", false); // [DEFAULT, except for Nightly] - "Experimental Machine Learning Inference Engine"

pref("browser.phoenix.011.applied", true);

// 012 WEBRTC

/// Enable mDNS Host Obfuscation to prevent leaking local IP addresses
// https://bugzilla.mozilla.org/show_bug.cgi?id=1588817

pref("media.peerconnection.ice.obfuscate_host_addresses", true);

/// If a proxy is configured, ensure WebRTC isn't bypassing it
// https://bugzilla.mozilla.org/show_bug.cgi?id=1790270

pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);

pref("browser.phoenix.012.applied", true);

// 013 DISK AVOIDANCE

/// Disable Search & Form History - Can be leaked to sites
// https://blog.mindedsecurity.com/2011/10/autocompleteagain.html

pref("browser.formfill.enable", false);

/// Disable caching, might reconsider since we clear cache on exit anyways

pref("browser.cache.disk.enable", false);
pref("browser.cache.disk_cache_ssl", false);
pref("browser.cache.memory.enable", false);
pref("browser.cache.memory.capacity", 0);
pref("browser.privatebrowsing.forceMediaMemoryCache", true);

/// Prevent storing unnecessary extra session data

pref("browser.sessionstore.privacy_level", 2);

/// Clear cache on exit

pref("privacy.clearOnShutdown.cache", true);
pref("privacy.clearOnShutdown_v2.cache", true);
pref("privacy.sanitize.sanitizeOnShutdown", true); // Allows selectively clearing data on shutdown

/// Prevent logging blocked domains in about:protections

pref("browser.contentblocking.database.enabled", false); // [DEFAULT]

/// Delete cached files from windows opened with external applications

pref("browser.download.start_downloads_in_tmp_dir", true);
pref("browser.helperApps.deleteTempFileOnExit", true);

/// Prevent coloring visited links

pref("layout.css.visited_links_enabled", false);

/// Disable collecting & generating background thumbnails

pref("browser.pagethumbnails.capturing_disabled", true); // [HIDDEN]

pref("browser.phoenix.013.applied", true);

// 014 EXTENSIONS

// Only allow installing extensions from profile & application directories (Prevents extensions being installed from the system/via other software)
/// https://archive.is/DYjAM
/// https://github.com/arkenfox/user.js/blob/master/user.js#L612

pref("extensions.enabledScopes", 5); // [DEFAULT]
pref("extensions.autoDisableScopes", 15); // [DEFAULT] Defense in depth, ensures extensions installed via directories are disabled by default...

// Only allow signed extensions

pref("extensions.langpacks.signatures.required", true); // [DEFAULT]
pref("xpinstall.signatures.required", true); // [DEFAULT]
pref("xpinstall.whitelist.required", true); // [DEFAULT]

// Block extensions signed with weak signature algorithms

pref("xpinstall.signatures.weakSignaturesTemporarilyAllowed", false); // [HIDDEN]

// Enforce Extension Blocklist

pref("extensions.blocklist.enabled", true); // [DEFAULT]

pref("browser.phoenix.014.applied", true);

// 015 PDF.js

/// Disable JavaScript

pref("pdfjs.enableScripting", false); // [HIDDEN]

/// Disable XFA
// https://insert-script.blogspot.com/2019/01/adobe-reader-pdf-callback-via-xslt.html
// https://www.sentinelone.com/blog/malicious-pdfs-revealing-techniques-behind-attacks/
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=xfa
// https://wikipedia.org/wiki/XFA
// Not even a standard...

pref("pdfjs.enableXfa", false); // [HIDDEN]

/// Never allow documents to prevent copying text

pref("pdfjs.enablePermissions", false); // [HIDDEN]

/// Open PDFs in browser where possible

pref("browser.download.open_pdf_attachments_inline", true); // [DEFAULT]

/// Show sidebar by default when viewing PDFs

pref("pdfjs.sidebarViewOnLoad", 2); // [HIDDEN]

pref("browser.phoenix.015.applied", true);

// 016 FINGERPRINTING PROTECTION

/// Set RFP to spoof the English locale by default

pref("privacy.spoof_english", 2);

/// Round window sizes

pref("privacy.window.maxInnerHeight", 900);
pref("privacy.window.maxInnerWidth", 1600);

/// Enable RFP letterboxing

pref("privacy.resistFingerprinting.letterboxing", true); // [HIDDEN]

/// If RFP is enabled, unbreak Apple Maps by default

pref("privacy.resistFingerprinting.exemptedDomains", "*.example.invalid,beta.maps.apple.com");

/// Disable WebGPU
// https://browserleaks.com/webgpu

pref("dom.webgpu.enabled", false); // [DEFAULT]

/// Enforce that WebGL stays disabled if it is disabled

pref("webgl.disable-fail-if-major-performance-caveat", false);

/// Prevent using system colors

pref("browser.display.use_system_colors", false); // [DEFAULT]

pref("browser.phoenix.016.applied", true);

// 017 MISC. PRIVACY

/// Ensure ETP is set to Strict

pref("browser.contentblocking.category", "strict");

/// Enable various important ETP protections...
/// Usually unnecessary & covered by enabling ETP Strict - though based on my testing, these don't appear to be always set automatically for Fenix.

pref("network.cookie.cookieBehavior", 5); // [DEFAULT]
pref("network.cookie.cookieBehavior.optInPartitioning", true);
pref("network.cookie.cookieBehavior.pbmode", 5); // [DEFAULT]
pref("network.http.referer.disallowCrossSiteRelaxingDefault", true); // [DEFAULT]
pref("network.http.referer.disallowCrossSiteRelaxingDefault.pbmode", true); // [DEFAULT]
pref("network.http.referer.disallowCrossSiteRelaxingDefault.pbmode.top_navigation", true); // [DEFAULT]
pref("network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation", true);
pref("privacy.fingerprintingProtection", true);
pref("privacy.fingerprintingProtection.pbmode", true); // [DEFAULT]
pref("privacy.partition.always_partition_third_party_non_cookie_storage", true); // [DEFAULT]
pref("privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage", false); // [DEFAULT]
pref("privacy.partition.bloburl_per_partition_key", true); // [DEFAULT]
pref("privacy.partition.network_state.ocsp_cache", true); // [DEFAULT]
pref("privacy.partition.network_state.ocsp_cache.pbmode", true); // [DEFAULT]
pref("privacy.query_stripping.enabled", true);
pref("privacy.query_stripping.enabled.pbmode", true);
pref("privacy.socialtracking.block_cookies.enabled", true); // [DEFAULT]
pref("privacy.trackingprotection.cryptomining.enabled", true); // [DEFAULT]
pref("privacy.trackingprotection.emailtracking.enabled", true); // [DEFAULT]
pref("privacy.trackingprotection.emailtracking.pbmode.enabled", true); // [DEFAULT]
pref("privacy.trackingprotection.enabled", true);
pref("privacy.trackingprotection.fingerprinting.enabled", true); // [DEFAULT]
pref("privacy.trackingprotection.pbmode.enabled", true);
pref("privacy.trackingprotection.socialtracking.enabled", true); // [DEFAULT]

/// Enforce Do Not Track & Global Privacy Control

pref("privacy.donottrackheader.enabled", true);
pref("privacy.globalprivacycontrol.enabled", true);
pref("privacy.globalprivacycontrol.functionality.enabled", true); // [DEFAULT]
pref("privacy.globalprivacycontrol.pbmode.enabled", true); // [DEFAULT]

/// Disable "Privacy-Preserving Attribution"
// https://support.mozilla.org/kb/privacy-preserving-attribution

pref("dom.origin-trials.private-attribution.state", 0);
pref("dom.private-attribution.submission.enabled", false); // [DEFAULT]

/// Disable Reporting API
// https://w3c.github.io/reporting/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1492036

pref("dom.reporting.crash.enabled", false); // [DEFAULT]
pref("dom.reporting.enabled", false); // [DEFAULT]
pref("dom.reporting.featurePolicy.enabled", false); // [DEFAULT]
pref("dom.reporting.header.enabled", false); // [DEFAULT]

/// Disable Network Error Logging
// https://w3c.github.io/network-error-logging/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1145235
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#12829

pref("network.http.network_error_logging.enabled", false); // [DEFAULT]

/// Disable Network Information API
// https://developer.mozilla.org/docs/Web/API/Network_Information_API
// https://bugzilla.mozilla.org/show_bug.cgi?id=1057169
// https://bugzilla.mozilla.org/show_bug.cgi?id=1637922

pref("dom.netinfo.enabled", false); // [DEFAULT]

/// Trim cross-origin referers (Like Safari)

pref("network.http.referer.XOriginTrimmingPolicy", 2);

/// Restrict tracking referers

pref("network.http.referer.defaultPolicy.trackers", 1);
pref("network.http.referer.defaultPolicy.trackers.pbmode", 1);

/// Disable Hyperlink Auditing (Click Tracking)
// https://www.bleepingcomputer.com/news/software/major-browsers-to-prevent-disabling-of-click-tracking-privacy-risk/

pref("browser.send_pings", false); // [DEFAULT]
pref("browser.send_pings.max_per_link", 0); // [DEFENSE IN DEPTH]
pref("browser.send_pings.require_same_host", true); // [DEFENSE IN DEPTH]

/// Improve built-in query stripping to be on par with LibreWolf & Brave
// https://codeberg.org/librewolf/settings/src/branch/master/librewolf.cfg#L77

pref("privacy.query_stripping.strip_list", "__hsfp __hssc __hstc __s _hsenc _openstat dclid fbclid gbraid gclid hsCtaTracking igshid mc_eid ml_subscriber ml_subscriber_hash msclkid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id rb_clickid s_cid twclid vero_conv vero_id wbraid wickedid yclid");

/// Strip tracking parameters from URLs when shared by default

pref("privacy.query_stripping.strip_on_share.enabled", true);

pref("browser.phoenix.017.applied", true);

// 018 PASSWORDS & AUTHENTICATION

/// Disable Autofill

pref("signon.autofillForms", false);
pref("signon.autofillForms.http", false); // [DEFAULT]
pref("signon.formlessCapture.enabled", false);
pref("signon.privateBrowsingCapture.enabled", false);

/// Always allow showing password when hidden

pref("layout.forms.reveal-password-button.enabled", true);
pref("layout.forms.reveal-password-context-menu.enabled", true); // [DEFAULT]

/// Prevent websites from dictating whether to allow filling passwords
// https://blog.0xbadc0de.be/archives/124

pref("signon.storeWhenAutocompleteOff", false);

/// Never truncate passwords
// https://www.ghacks.net/2020/05/18/firefox-77-wont-truncate-text-exceeding-max-length-to-address-password-pasting-issues/

pref("editor.truncate_user_pastes", false);

/// Disable Password Manager by default - Insecure & unencrypted
/// You should instead use something like Bitwarden or Proton Pass

pref("extensions.formautofill.addresses.enabled", false);
pref("extensions.formautofill.creditCards.enabled", false);
pref("signon.rememberSignons", false);

/// If password manager is enabled, enable strong password generation by default

pref("signon.generation.enabled", true); // [DEFAULT]

/// Prevent cross-origin sub-resources from opening HTTP authentication dialogs

pref("network.auth.subresource-http-auth-allow", 1);

/// Disable Windows SSO

pref("network.http.windows-sso.enabled", false); // [DEFAULT]
pref("network.http.windows-sso.container-enabled.0", false);

/// Disable Microsoft Entra

pref("network.http.microsoft-entra-sso.enabled", false); // [DEFAULT]
pref("network.http.microsoft-entra-sso.container-enabled.0", false);
pref("network.microsoft-sso-authority-list", ""); // DEFENSE IN DEPTH

/// Prevent using Negotiate authentication by default 
// https://people.redhat.com/mikeb/negotiate/

pref("network.negotiate-auth.trusted-uris", ""); // [DEFAULT]

pref("browser.phoenix.018.applied", true);

// 019 ATTACK SURFACE REDUCTION

/// Disable JavaScript Just-in-time Compilation (JIT)
// https://microsoftedge.github.io/edgevr/posts/Super-Duper-Secure-Mode/

pref("javascript.options.baselinejit", false);
pref("javascript.options.ion", false);
pref("javascript.options.native_regexp", false); //  https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/21865 https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
pref("javascript.options.wasm_baselinejit", false);

/// Disable ASM.JS (More JIT)
// https://rh0dev.github.io/blog/2017/the-return-of-the-jit/

pref("javascript.options.asmjs", false);

/// Disable MathML
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=mathml 

pref("mathml.disabled", true);

/// Disable Graphite & SVG OpenType fonts
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=firefox+graphite
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=firefox+svg

pref("gfx.font_rendering.graphite.enabled", false);
pref("gfx.font_rendering.opentype_svg.enabled", false);

pref("browser.phoenix.019.applied", true);

// 020 MISC. SECURITY

// Prevent websites from automatically downloading as many files as they want to a user's device...
// Can be used for denial of service
// Allows overriding for specific downloads if needed
// https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/41764
// Ex. also enabled by Tor Browser

pref("browser.download.enable_spam_prevention", true);

// Do not disable Spectre mitigations for isolated content...
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#8689

pref("javascript.options.spectre.disable_for_isolated_content", false);

// If a website asks for a certificate, always prompt the user
// Never automatically select one...
// https://www.stigviewer.com/stig/mozilla_firefox/2023-06-05/finding/V-251547

pref("security.default_personal_cert", "Ask Every Time"); // [DEFAULT]

/// Disable Accessibility Services
// https://support.mozilla.org/kb/accessibility-services#w_malware-and-adware

pref("accessibility.force_disabled", 1);

/// Enforce that Content Analysis is disabled
// https://github.com/chromium/content_analysis_sdk

pref("browser.contentanalysis.default_result", 0); // [DEFAULT]
pref("browser.contentanalysis.enabled", false); // [DEFAULT]
pref("browser.contentanalysis.interception_point.clipboard.enabled", false);
pref("browser.contentanalysis.interception_point.drag_and_drop.enabled", false);
pref("browser.contentanalysis.interception_point.file_upload.enabled", false);
pref("browser.contentanalysis.interception_point.print.enabled", false);

/// Enable Site Isolation & Isolate all websites
// https://wiki.mozilla.org/Project_Fission
// This used to cause weird issues & breakage on Android, and was impossible to disable once enabled; though the situation appears to have changed drastically.
// It appears to now be possible to disable fission after enabling, and it also seems to be at the point where (as of December 2024), Mozilla is even rolling it out to Nightly users...
// https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/nimbus-mobile-experiments/changeset?_expected=0
// I don't see any reason why we shouldn't enable it by default at this point.

pref("dom.ipc.processCount.webIsolated", 1); // [DEFAULT]
pref("fission.autostart", true);
pref("fission.autostart.session", true);

/// Enable GPU Sandboxing

pref("security.sandbox.gpu.level", 1);

/// Protect against CSRF Attacks (Like Chromium)
// https://groups.google.com/a/mozilla.org/g/dev-platform/c/6PZtLH7c6JQ
// https://hacks.mozilla.org/2020/08/changes-to-samesite-cookie-behavior/
// https://web.dev/articles/samesite-cookies-explained
// https://help.salesforce.com/s/articleView?id=000389944&type=1
// https://portswigger.net/web-security/csrf/bypassing-samesite-restrictions
// https://web.dev/articles/schemeful-samesite

pref("network.cookie.sameSite.laxByDefault", true);
pref("network.cookie.sameSite.noneRequiresSecure", true); // [DEFAULT]
pref("network.cookie.sameSite.schemeful", true);

/// Enforce Strict file:// Origin Policy
// https://stuffandnonsense.co.uk/blog/firefoxs_file_uri_origin_policy_and_web_fonts
// https://stackoverflow.com/questions/2856502/css-font-face-not-working-with-firefox-but-working-with-chrome-and-ie

pref("security.fileuri.strict_origin_policy", true); // [DEFAULT]

/// Always protect against MIME Exploits
// https://www.pcmag.com/encyclopedia/term/mime-exploit

pref("security.block_fileuri_script_with_wrong_mime", true);
pref("security.block_Worker_with_wrong_mime", true); // [DEFAULT]

/// Never load Navigator Media Objects & getUserMedia Support in insecure contexts
// https://developer.mozilla.org/docs/Web/API/Navigator/mediaDevices
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml

pref("media.devices.insecure.enabled", false); // [DEFAULT]
pref("media.getusermedia.insecure.enabled", false); // [DEFAULT]

// Ensure that Firefox can't access the system's Shell...
// https://www.stigviewer.com/stig/mozilla_firefox/2019-12-12/finding/V-15771

pref("network.protocol-handler.external.shell", false); // [DEFAULT]

// Always warn users before launching other apps...

pref("network.protocol-handler.warn-external-default", true); // [DEFAULT]
pref("network.protocol-handler.warn-external.file", true);
pref("network.protocol-handler.warn-external.mailto", true);
pref("network.protocol-handler.warn-external.sms", true);
pref("network.protocol-handler.warn-external.tel", true);
pref("network.protocol-handler.warn-external.vnd.youtube", true);
pref("security.external_protocol_requires_permission", true); // [DEFAULT]

/// Never skip the assertion that about:pages don't have content security policies (CSP)
// https://searchfox.org/comm-central/source/mozilla/modules/libpref/init/StaticPrefList.yaml#3987

pref("dom.security.skip_about_page_has_csp_assert", false); // [DEFAULT]

/// Enable Trusted Types (Like Chromium)
// https://w3c.github.io/trusted-types/dist/spec/
// https://developer.mozilla.org/docs/Web/API/Trusted_Types_API
// https://www.theregister.com/2023/12/21/mozilla_decides_trusted_types_is/

pref("dom.security.trusted_types.enabled", true);

pref("browser.phoenix.020.applied", true);

// 021 BLOCK COOKIE BANNERS

pref("cookiebanners.service.mode", 1);
pref("cookiebanners.service.mode.privateBrowsing", 1); // [DEFAULT on Nightly]
pref("cookiebanners.service.enableGlobalRules", true); // [DEFAULT]

pref("browser.phoenix.021.applied", true);

// 022 MEDIA

/// Enforce validating signature for GMP when updating
// https://searchfox.org/mozilla-central/source/modules/libpref/init/all.js

pref("media.gmp-manager.cert.checkAttributes", true); // [DEFAULT]
pref("media.gmp-manager.cert.requireBuiltIn", true); // [DEFAULT]
pref("media.gmp-manager.checkContentSignature", true); // [DEFAULT]

/// Disable Autoplay by default

pref("media.autoplay.default", 5);
pref("userContent.player.click_to_play", true); // [HIDDEN] https://github.com/black7375/Firefox-UI-Fix/wiki/Options#defaults-6

/// DRM
// Garbage technology with freedom, privacy, & security concerns
// https://www.eff.org/deeplinks/2017/10/drms-dead-canary-how-we-just-lost-web-what-we-learned-it-and-what-we-need-do-next

pref("media.clearkey.persistent-license.enabled", false); // [DEFAULT]
pref("media.clearkey.test-key-systems.enabled", false); // [DEFAULT]
pref("media.eme.enabled", false);
pref("media.eme.encrypted-media-encryption-scheme.enabled", false);
pref("media.eme.hdcp-policy-check.enabled", false);
pref("media.eme.require-app-approval", true); // [DEFAULT - DEFENSE IN DEPTH]: Enforce locking DRM behind permission https://searchfox.org/mozilla-central/source/mobile/android/app/geckoview-prefs.js#304
pref("media.gmp-widevinecdm.visible", false);
pref("media.mediadrm-widevinecdm.visible", false); // https://searchfox.org/mozilla-central/source/mobile/android/app/geckoview-prefs.js#320

pref("browser.phoenix.022.applied", true);

// 023 UPDATES

/// Ensure we're always updating extensions by default

pref("extensions.systemAddon.update.enabled", true); // [DEFAULT]
pref("extensions.update.autoUpdateDefault", true); // [HIDDEN]
pref("extensions.update.enabled", true); // [DEFAULT]

/// Ensure we always notify users for extension updates by default
// https://searchfox.org/mozilla-central/source/remote/shared/RecommendedPreferences.sys.mjs#253

pref("extensions.update.notifyUser", true); // [HIDDEN]

pref("browser.phoenix.023.applied", true);

// 024 DEBUGGING

/// Enforce local debugging only

pref("devtools.debugger.force-local", true); // [DEFAULT]
pref("devtools.debugger.remote-enabled", false); // [DEFAULT]
pref("devtools.inspector.remote", false);

// Always prompt before connecting...

pref("devtools.debugger.prompt-connection", true); // [DEFAULT]

/// Ensure that URLs are not being logged in Reader errors

pref("reader.errors.includeURLs", false); // [DEFAULT]

pref("browser.phoenix.024.applied", true);

/// 025 MISC.

/// Always allow installing "incompatible" add-ons

pref("extensions.strictCompatibility", false); // [DEFAULT]

/// Disable middle mouse clicks from pasting clipboard contents by default
// Too easy to accidentally press...

pref("middlemouse.paste", false);

/// Enable Containers & isolate permissions per container

pref("permissions.isolateBy.userContext", true);
pref("privacy.userContext.enabled", true); // [HIDDEN]
pref("privacy.userContext.ui.enabled", true); // [HIDDEN]

/// Force pop-up windows to open in new tabs instead

pref("browser.link.open_newwindow", 3); // [DEFAULT]
pref("browser.link.open_newwindow.restriction", 0); // [DEFAULT]

/// Always block pop-ups by default

pref("dom.disable_open_during_load", true); // [DEFAULT]

/// Limit what events can cause pop-ups

pref("dom.popup_allowed_events", "click dblclick");

/// Prevent scripts from moving, resizing, and messing with windows

pref("dom.disable_window_flip", true);
pref("dom.disable_window_move_resize", true); // [DEFAULT]

/// Disable annoying Web Speech API errors

pref("media.webspeech.synth.dont_notify_on_error", true); // [HIDDEN]

pref("browser.phoenix.025.applied", true);

// 026 PERFORMANCE
// A lot of these taken from https://github.com/yokoffing/Betterfox/blob/main/Fastfox.js

pref("browser.sessionstore.max_tabs_undo", 7); // [Default = 10]
pref("browser.sessionhistory.max_total_viewers", 7); // [Default = -1 (Automatic)]
pref("content.notify.interval", 100000); // [Default = 120000] https://searchfox.org/mozilla-central/rev/c1180ea13e73eb985a49b15c0d90e977a1aa919c/modules/libpref/init/StaticPrefList.yaml#1824-1834
pref("extensions.logging.enabled", false); // [DEFAULT] https://searchfox.org/mozilla-central/source/mobile/android/app/geckoview-prefs.js#232
pref("gfx.canvas.accelerated.cache-items", 4096); // [Default = 2048]
pref("gfx.canvas.accelerated.cache-size", 512); // [Default = 256]
pref("gfx.content.skia-font-cache-size", 20); // [Default = 5]
pref("gfx.webrender.all", true);
pref("image.mem.decode_bytes_at_a_time", 32768); // [Default = 16384]
pref("image.mem.shared.unmap.min_expiration_ms", 120000); // [Default = 60000]
pref("layout.css.grid-template-masonry-value.enabled", true); // https://developer.mozilla.org/docs/Web/CSS/CSS_Grid_Layout/Masonry_Layout
pref("layout.css.report_errors", false); // [DEFAULT] - https://searchfox.org/mozilla-central/source/mobile/android/app/geckoview-prefs.js#299
pref("media.memory_cache_max_size", 65536); // [Default = 8192]
pref("network.dnsCacheEntries", 1000); // [Default = 400]
pref("network.dnsCacheExpiration", 3600); // [Default = 60]
pref("network.dnsCacheExpirationGracePeriod", 240); // [Default = 60]
pref("network.http.max-persistent-connections-per-proxy", 48); // [Default = 20]
pref("network.http.max-persistent-connections-per-server", 10); // [Default = 6]
pref("network.http.max-urgent-start-excessive-connections-per-host", 5); // [Default = 3]

pref("browser.phoenix.026.applied", true);

// 027 SMOOTH SCROLLING

pref("general.smoothScroll", true); // [DEFAULT]

pref("browser.phoenix.027.applied", true);

// 028 Personal Touch 💜

/// Things that are  nice to have™
// Not directly privacy & security related

pref("browser.translations.alwaysTranslateLanguages", "bg,ca,cs,da,de,el,en,es,et,fi,fr,hr,hu,id,it,lv,lt,nl,pl,pt,ro,ru,sk,sl,sr,sv,tr,uk,vi");
pref("browser.translations.automaticallyPopup", true); // [DEFAULT]
pref("browser.translations.enable", true); // [DEFAULT]
pref("browser.translations.select.enable", true);
pref("devtools.chrome.enabled", true);
pref("findbar.highlightAll", true);
pref("full-screen-api.transition-duration.enter", "0 0"); // [Default = 200 200]
pref("full-screen-api.transition-duration.leave", "0 0"); // [Default = 200 200]
pref("full-screen-api.warning.delay", -1); // [Default = -1 (Automatic)]
pref("full-screen-api.warning.timeout", 0); // [Default = 3000]
pref("security.xfocsp.hideOpenInNewWindow", false);
pref("view_source.wrap_long_lines", true); // [DEFAULT]

pref("browser.phoenix.028.applied", true);

// 029 Sync more prefs
// Note that for this to work, the below prefs must be set on BOTH the device you are syncing from & to...
// Useful especially if you override our defaults

pref("services.sync.prefs.sync.browser.aboutConfig.showWarning", true);
pref("services.sync.prefs.sync.browser.meta_refresh_when_inactive.disabled", true);
pref("services.sync.prefs.sync.browser.translations.alwaysTranslateLanguages", true);
pref("services.sync.prefs.sync.browser.translations.automaticallyPopup", true);
pref("services.sync.prefs.sync.browser.translations.enable", true);
pref("services.sync.prefs.sync.browser.translations.newSettingsUI.enable", true);
pref("services.sync.prefs.sync.browser.translations.select.enable", true);
pref("services.sync.prefs.sync.devtools.chrome.enabled", true);
pref("services.sync.prefs.sync.findbar.highlightAll", true);
pref("services.sync.prefs.sync.full-screen-api.transition-duration.enter", true);
pref("services.sync.prefs.sync.full-screen-api.transition-duration.leave", true);
pref("services.sync.prefs.sync.full-screen-api.warning.delay", true);
pref("services.sync.prefs.sync.full-screen-api.warning.timeout", true);
pref("services.sync.prefs.sync.security.xfocsp.hideOpenInNewWindow", true);
pref("services.sync.prefs.sync.view_source.wrap_long_lines", true);
pref("services.sync.prefs.sync.media.autoplay.blocking_policy", true);
pref("services.sync.prefs.sync.media.gmp-gmpopenh264.enabled", true);
pref("services.sync.prefs.sync.media.gmp-gmpopenh264.provider.enabled", true);
pref("services.sync.prefs.sync.media.gmp-gmpopenh264.visible", true);
pref("services.sync.prefs.sync.media.gmp-provider.enabled", true);
pref("services.sync.prefs.sync.general.warnOnAboutConfig", true);
pref("services.sync.prefs.sync.extensions.webextensions.restrictedDomains", true);
pref("services.sync.prefs.sync.extensions.getAddons.search.browseURL", true);
pref("services.sync.prefs.sync.browser.search.separatePrivateDefault.ui.enabled", true);
pref("services.sync.prefs.sync.browser.search.separatePrivateDefault.urlbarResult.enabled", true);
pref("services.sync.prefs.sync.network.IDN_show_punycode", true);
pref("services.sync.prefs.sync.dom.security.https_only_mode_error_page_user_suggestions", true);
pref("services.sync.prefs.sync.browser.xul.error_pages.expert_bad_cert", true);
pref("services.sync.prefs.sync.network.trr.custom_uri", true);
pref("services.sync.prefs.sync.network.trr.mode", true);
pref("services.sync.prefs.sync.network.trr.uri", true);
pref("services.sync.prefs.sync.doh-rollout.provider-list", true);
pref("services.sync.prefs.sync.network.dns.native_https_query", true);
pref("services.sync.prefs.sync.security.OCSP.require", true);
pref("services.sync.prefs.sync.security.ssl.require_safe_negotiation", true);
pref("services.sync.prefs.sync.browser.xul.error_pages.show_safe_browsing_details_on_load", true);
pref("services.sync.prefs.sync.browser.safebrowsing.provider.google.reportMalwareMistakeURL", true);
pref("services.sync.prefs.sync.browser.safebrowsing.provider.google.reportPhishMistakeURL", true);
pref("services.sync.prefs.sync.browser.safebrowsing.provider.google4.reportMalwareMistakeURL", true);
pref("services.sync.prefs.sync.browser.safebrowsing.provider.google4.reportPhishMistakeURL", true);
pref("services.sync.prefs.sync.browser.safebrowsing.reportPhishURL", true);
pref("services.sync.prefs.sync.browser.safebrowsing.provider.google.reportURL", true);
pref("services.sync.prefs.sync.browser.safebrowsing.provider.google4.reportURL", true);
pref("services.sync.prefs.sync.geo.provider.network.url", true);
pref("services.sync.prefs.sync.browser.cache.disk.enable", true);
pref("services.sync.prefs.sync.browser.cache.disk_cache_ssl", true);
pref("services.sync.prefs.sync.browser.cache.memory.enable", true);
pref("services.sync.prefs.sync.browser.cache.memory.capacity", true);
pref("services.sync.prefs.sync.browser.download.open_pdf_attachments_inline", true);
pref("services.sync.prefs.sync.pdfjs.sidebarViewOnLoad", true);
pref("services.sync.prefs.sync.intl.accept_languages", true);
pref("services.sync.prefs.sync.intl.locale.requested", true);
pref("services.sync.prefs.sync.middlemouse.paste", true);
pref("services.sync.prefs.sync.privacy.antitracking.enableWebcompat", true);
pref("services.sync.prefs.sync.privacy.fingerprintingProtection.remoteOverrides.enabled", true);
pref("services.sync.prefs.sync.privacy.spoof_english", true);
pref("services.sync.prefs.sync.privacy.resistFingerprinting", true);
pref("services.sync.prefs.sync.privacy.resistFingerprinting.letterboxing", true);
pref("services.sync.prefs.sync.privacy.restrict3rdpartystorage.heuristic.opened_window_after_interaction", true);
pref("services.sync.prefs.sync.privacy.restrict3rdpartystorage.heuristic.recently_visited", true);
pref("services.sync.prefs.sync.privacy.restrict3rdpartystorage.heuristic.redirect", true);
pref("services.sync.prefs.sync.privacy.restrict3rdpartystorage.heuristic.window_open", true);
pref("services.sync.prefs.sync.privacy.query_stripping.strip_list", true);
pref("services.sync.prefs.sync.layout.forms.reveal-password-button.enabled", true);
pref("services.sync.prefs.sync.network.negotiate-auth.trusted-uris", true);
pref("services.sync.prefs.sync.cookiebanners.service.mode", true);
pref("services.sync.prefs.sync.cookiebanners.service.mode.privateBrowsing", true);
pref("services.sync.prefs.sync.cookiebanners.service.enableGlobalRules", true);
pref("services.sync.prefs.sync.userContent.player.click_to_play", true);
pref("services.sync.prefs.sync.privacy.userContext.ui.enabled", true);
pref("services.sync.prefs.sync.browser.sessionstore.interval", true);
pref("services.sync.prefs.sync.browser.sessionstore.max_tabs_undo", true);
pref("services.sync.prefs.sync.browser.sessionhistory.max_total_viewers", true);
pref("services.sync.prefs.sync.browser.tabs.min_inactive_duration_before_unload", true);
pref("services.sync.prefs.sync.content.notify.interval", true);
pref("services.sync.prefs.sync.dom.security.https_only_mode_send_http_background_request", true);
pref("services.sync.prefs.sync.extensions.logging.enabled", true);
pref("services.sync.prefs.sync.gfx.canvas.accelerated.cache-items", true);
pref("services.sync.prefs.sync.gfx.canvas.accelerated.cache-size", true);
pref("services.sync.prefs.sync.gfx.content.skia-font-cache-size", true);
pref("services.sync.prefs.sync.image.mem.decode_bytes_at_a_time", true);
pref("services.sync.prefs.sync.image.mem.shared.unmap.min_expiration_ms", true);
pref("services.sync.prefs.sync.javascript.options.wasm", true);
pref("services.sync.prefs.sync.layout.css.grid-template-masonry-value.enabled", true);
pref("services.sync.prefs.sync.layout.css.report_errors", true);
pref("services.sync.prefs.sync.media.cache_readahead_limit", true);
pref("services.sync.prefs.sync.media.cache_resume_threshold", true);
pref("services.sync.prefs.sync.media.memory_cache_max_size", true);
pref("services.sync.prefs.sync.media.peerconnection.ice.default_address_only", true);
pref("services.sync.prefs.sync.media.peerconnection.ice.no_host", true);
pref("services.sync.prefs.sync.mousewheel.default.delta_multiplier_y", true);
pref("services.sync.prefs.sync.network.buffer.cache.count", true);
pref("services.sync.prefs.sync.network.buffer.cache.size", true);
pref("services.sync.prefs.sync.network.dnsCacheEntries", true);
pref("services.sync.prefs.sync.network.dnsCacheExpiration", true);
pref("services.sync.prefs.sync.network.dnsCacheExpirationGracePeriod", true);
pref("services.sync.prefs.sync.network.http.max-persistent-connections-per-proxy", true);
pref("services.sync.prefs.sync.network.http.max-persistent-connections-per-server", true);
pref("services.sync.prefs.sync.network.http.max-urgent-start-excessive-connections-per-host", true);
pref("services.sync.prefs.sync.network.http.referer.XOriginPolicy", true);
pref("services.sync.prefs.sync.webgl.disabled", true);

pref("browser.phoenix.029.applied", true);

pref("browser.phoenix.applied", true);
