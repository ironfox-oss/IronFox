//
// The Phoenix shall rise from the ashes of what fell before it.

// Welcome to the heart of the Phoenix.
// This file contains preferences shared across all Phoenix configs, platforms (Desktop & Android), and Dove.

pref("browser.phoenix.version", "2025.01.22.1", locked);

// 000 ABOUT:CONFIG

/// Ensure that about:config is always enabled...
pref("general.aboutConfig.enable", true, locked); // [DEFAULT on Desktop]

// Disable annoying warnings when attempting to access the about:config
pref("browser.aboutConfig.showWarning", false);
pref("general.warnOnAboutConfig", false);

pref("browser.phoenix.core.status", "000", locked);

// 001 DATA COLLECTION

// A lot of defense in depth...

/// Shield Studies/Normandy/Nimbus
// We also set "DisableFirefoxStudies" in policies 
// https://mozilla.github.io/policy-templates/#disablefirefoxstudies
// https://mozilla.github.io/normandy/
// https://wiki.mozilla.org/Firefox/Shield/Shield_Studies
// https://support.mozilla.org/kb/shield
// https://support.mozilla.org/kb/how-stop-firefox-making-automatic-connections#w_experiments-or-studies
// https://wiki.mozilla.org/Advocacy/heartbeat
// https://experimenter.info/
// resource://nimbus/ExperimentAPI.sys.mjs

pref("app.normandy.api_url", "", locked);
pref("app.normandy.enabled", false, locked);
pref("app.normandy.first_run", false, locked);
pref("app.normandy.last_seen_buildid", "", locked);
pref("app.normandy.logging.level", 70); // Limits logging to fatal only
pref("app.normandy.user_id", "", locked);
pref("app.shield.optoutstudies.enabled", false, locked);
pref("messaging-system.log", "off"); // Disables logging
pref("messaging-system.rsexperimentloader.enabled", false, locked);
pref("messaging-system.rsexperimentloader.collection_id", "", locked);
pref("nimbus.appId", "", locked); // https://searchfox.org/mozilla-central/source/toolkit/components/backgroundtasks/defaults/backgroundtasks_browser.js
pref("toolkit.telemetry.pioneer-new-studies-available", false, locked);

/// Origin Trials
// https://wiki.mozilla.org/Origin_Trials

pref("dom.origin-trials.enabled", false, locked);

/// Crash Reporting
// https://github.com/mozilla-services/socorro
// https://wiki.mozilla.org/Socorro
// https://firefox-source-docs.mozilla.org/tools/sanitizer/asan_nightly.html

pref("asanreporter.apiurl", "", locked);
pref("asanreporter.clientid", "", locked);
pref("breakpad.reportURL", "", locked);
pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false, locked); // [DEFAULT]
pref("browser.crashReports.unsubmittedCheck.enabled", false, locked); // [DEFAULT on Stable - but set to true on Nightly :/]
pref("browser.tabs.crashReporting.includeURL", false, locked); // [DEFAULT] - Defense in depth
pref("browser.tabs.crashReporting.sendReport", false, locked);
pref("toolkit.crashreporter.include_context_heap", false, locked); // Defense in depth

/// X-Frame Options Error Reporting
// https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/xfocsp-error-report-ping.html

pref("security.xfocsp.errorReporting.automatic", false, locked); // [DEFAULT]
pref("security.xfocsp.errorReporting.enabled", false, locked);

/// Coverage
// https://blog.mozilla.org/data/2018/08/20/effectively-measuring-search-in-firefox/
// https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/pings/CoveragePing.sys.mjs

pref("toolkit.coverage.enabled", false, locked); // [DEFAULT]
pref("toolkit.coverage.endpoint.base", "", locked);
pref("toolkit.coverage.opt-out", true, locked); // [HIDDEN]
pref("toolkit.telemetry.coverage.opt-out", true, locked); // [HIDDEN]

/// Misc. Telemetry
/// We also configure "DisableTelemetry" & "ImproveSuggest" in policies 
// https://mozilla.github.io/policy-templates/#disabletelemetry 
// https://mozilla.github.io/policy-templates/#firefoxsuggest
// https://searchfox.org/mozilla-central/source/testing/geckodriver/src/prefs.rs
// https://wiki.mozilla.org/QA/Telemetry
// https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html 
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
// https://searchfox.org/mozilla-central/source/remote/shared/RecommendedPreferences.sys.mjs
// https://searchfox.org/mozilla-central/source/testing/profiles/perf/user.js

pref("browser.aboutwelcome.log", "off"); // Disable logging
pref("browser.newtabpage.activity-stream.feeds.telemetry", false, locked);
pref("browser.newtabpage.activity-stream.impressionId", "", locked);
pref("browser.newtabpage.activity-stream.telemetry", false, locked);
pref("browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint", "", locked);
pref("browser.newtabpage.activity-stream.telemetry.ut.events", false, locked);
pref("browser.places.interactions.enabled", false, locked); // https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js
pref("browser.privacySegmentation.preferences.show", false, locked); // [DEFAULT, at least on Nightly]
pref("browser.rights.3.shown", true);
pref("browser.search.serpEventTelemetryCategorization.enabled", false, locked);
pref("browser.search.serpEventTelemetryCategorization.regionEnabled", false, locked); // [DEFAULT, at least on Nightly]
pref("browser.urlbar.quicksuggest.dataCollection.enabled", false, locked); // [DEFAULT]
pref("browser.urlbar.quicksuggest.onboardingDialogChoice", "reject_2", locked); // [HIDDEN] https://searchfox.org/mozilla-central/source/browser/components/urlbar/docs/firefox-suggest-telemetry.rst https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/docs/data/environment.rst https://searchfox.org/mozilla-central/source/browser/components/urlbar/tests/quicksuggest/browser/browser_quicksuggest_onboardingDialog.js
pref("datareporting.dau.cachedUsageProfileID", "beefbeef-beef-beef-beef-beeefbeefbee", locked); // [HIDDEN] https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/app/ClientID.sys.mjs#44
pref("datareporting.healthreport.documentServerURI", "", locked); // [HIDDEN]
pref("datareporting.healthreport.logging.consoleEnabled", false); // [HIDDEN]
pref("datareporting.healthreport.service.enabled", false, locked); // [HIDDEN]
pref("datareporting.healthreport.service.firstRun", false, locked); // [HIDDEN]
pref("datareporting.healthreport.uploadEnabled", false, locked);
pref("datareporting.policy.dataSubmissionEnabled", false, locked);
pref("datareporting.policy.dataSubmissionPolicyAccepted", false, locked);
pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true, locked);
pref("datareporting.policy.firstRunURL", "", locked);
pref("dom.security.unexpected_system_load_telemetry_enabled", false, locked);
pref("identity.fxaccounts.telemetry.clientAssociationPing.enabled", false, locked);
pref("identity.fxaccounts.account.telemetry.sanitized_uid", "", locked);
pref("network.jar.record_failure_reason", false, locked); // https://searchfox.org/mozilla-release/source/modules/libpref/init/StaticPrefList.yaml#14397
pref("network.traffic_analyzer.enabled", false, locked); // https://searchfox.org/mozilla-release/source/modules/libpref/init/StaticPrefList.yaml#13191
pref("network.trr.confirmation_telemetry_enabled", false, locked);
pref("nimbus.telemetry.targetingContextEnabled", false, locked); // https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js#2001
pref("privacy.imageInputTelemetry.enableTestMode", false, locked); // [HIDDEN] "Event Telemetry" https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15549
pref("privacy.trackingprotection.emailtracking.data_collection.enabled", false, locked);
pref("toolkit.content-background-hang-monitor.disabled", true, locked); // BHR https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#16720
pref("toolkit.telemetry.archive.enabled", false, locked);
pref("toolkit.telemetry.bhrPing.enabled", false, locked);
pref("toolkit.telemetry.cachedClientID", "c0ffeec0-ffee-c0ff-eec0-ffeec0ffeec0", locked);
pref("toolkit.telemetry.cachedProfileGroupID", "decafdec-afde-cafd-ecaf-decafdecafde", locked);
pref("toolkit.telemetry.dap.helper.hpke", "", locked);
pref("toolkit.telemetry.dap.helper.url", "", locked);
pref("toolkit.telemetry.dap.leader.hpke", "", locked);
pref("toolkit.telemetry.dap.leader.url", "", locked);
pref("toolkit.telemetry.dap.logLevel", "Off");
pref("toolkit.telemetry.dap_enabled", false, locked); // [DEFAULT]
pref("toolkit.telemetry.dap_helper", "", locked);
pref("toolkit.telemetry.dap_helper_owner", "", locked);
pref("toolkit.telemetry.dap_leader", "", locked);
pref("toolkit.telemetry.dap_leader_owner", "", locked);
pref("toolkit.telemetry.dap_task1_enabled", false, locked); // [DEFAULT]
pref("toolkit.telemetry.dap_task1_taskid", "", locked); // [DEFAULT]
pref("toolkit.telemetry.dap_visit_counting_enabled", false, locked); // [DEFAULT]
pref("toolkit.telemetry.dap_visit_counting_experiment_list", "[]", locked); // [DEFAULT]
pref("toolkit.telemetry.debugSlowSql", false); // [DEFAULT]
pref("toolkit.telemetry.enabled", false, locked);  // [DEFAULT on Stable Desktop, not on Nightly & elsewhere...]
pref("toolkit.telemetry.firstShutdownPing.enabled", false, locked);
pref("toolkit.telemetry.healthping.enabled", false, locked); // [HIDDEN]
pref("toolkit.telemetry.newProfilePing.enabled", false, locked);
pref("toolkit.telemetry.pioneerId", "", locked); // [HIDDEN]
pref("toolkit.telemetry.previousBuildID", "", locked);
pref("toolkit.telemetry.reportingpolicy.firstRun", false, locked);
pref("toolkit.telemetry.server", "data;", locked);
pref("toolkit.telemetry.server_owner", "", locked);
pref("toolkit.telemetry.shutdownPingSender.backgroundtask.enabled", false, locked); // [DEFAULT]
pref("toolkit.telemetry.shutdownPingSender.enabled", false, locked);
pref("toolkit.telemetry.shutdownPingSender.enabledFirstSession", false, locked); // [DEFAULT]
pref("toolkit.telemetry.testing.suppressPingsender", true, locked); // [HIDDEN]
pref("toolkit.telemetry.translations.logLevel", "Off");
pref("toolkit.telemetry.unified", false, locked);
pref("toolkit.telemetry.updatePing.enabled", false, locked);
pref("toolkit.telemetry.user_characteristics_ping.current_version", 0, locked); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.last_version_sent", 0, locked); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.logLevel", "Off");
pref("toolkit.telemetry.user_characteristics_ping.opt-out", true, locked);
pref("toolkit.telemetry.user_characteristics_ping.send-once", false, locked); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.uuid", "", locked); // [DEFAULT]

/// Misc. UX - Harmless but does not apply to us

pref("app.normandy.shieldLearnMoreUrl", "");
pref("datareporting.healthreport.infoURL", "");
pref("extensions.recommendations.privacyPolicyUrl", "");
pref("toolkit.crashreporter.infoURL", "");
pref("toolkit.datacollection.infoURL", "");

pref("browser.phoenix.core.status", "001", locked);

// 002 MOZILLA CRAP™

/// Disable "Privacy-Preserving Attribution"
// https://support.mozilla.org/kb/privacy-preserving-attribution

pref("dom.origin-trials.private-attribution.state", 2, locked); // [DEFAULT]
pref("dom.private-attribution.submission.enabled", false, locked); // [DEFAULT]

/// Firefox Recommendations & "Discovery"

pref("browser.dataFeatureRecommendations.enabled", false, locked); // [DEFAULT]
pref("browser.discovery.enabled", false);
pref("browser.discovery.sites", "");
pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false, locked);
pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false, locked);
pref("extensions.getAddons.browseAddons", ""); // Android?
pref("extensions.getAddons.discovery.api_url", "data;"); // https://searchfox.org/mozilla-central/source/testing/profiles/common/user.js
pref("extensions.getAddons.showPane", false);
pref("extensions.htmlaboutaddons.recommendations.enabled", false);
pref("extensions.recommendations.themeRecommendationUrl", "");
pref("extensions.webservice.discoverURL", "");

/// Fakespot

pref("browser.newtabpage.activity-stream.contextualContent.fakespot.enabled", false);
pref("browser.shopping.experience2023.active", false);
pref("browser.shopping.experience2023.ads.enabled", false, locked); // [DEFAULT]
pref("browser.shopping.experience2023.ads.exposure", false, locked); // [HIDDEN]
pref("browser.shopping.experience2023.ads.userEnabled", false, locked);
pref("browser.shopping.experience2023.autoOpen.enabled", false); // [DEFAULT]
pref("browser.shopping.experience2023.autoOpen.userEnabled", false);
pref("browser.shopping.experience2023.enabled", false); // [DEFAULT]
pref("browser.shopping.experience2023.integratedSidebar", false); // [DEFAULT]
pref("browser.shopping.experience2023.optedIn", 2);
pref("browser.shopping.experience2023.shoppingSidebar", false);
pref("browser.shopping.experience2023.survey.enabled", false);
pref("browser.shopping.experience2023.survey.hasSeen", true);
pref("browser.urlbar.fakespot.featureGate", false); // [DEFAULT]
pref("browser.urlbar.suggest.fakespot", false);
pref("toolkit.shopping.ohttpConfigURL", "");
pref("toolkit.shopping.ohttpRelayURL", "");

/// Pocket

pref("browser.newtabpage.activity-stream.discoverystream.recentSaves.enabled", false);
pref("browser.newtabpage.activity-stream.discoverystream.saveToPocketCard.enabled", false);
pref("browser.newtabpage.activity-stream.discoverystream.sendToPocket.enabled", false);
pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
pref("browser.urlbar.pocket.featureGate", false);
pref("browser.urlbar.suggest.pocket", false);
pref("extensions.pocket.enabled", false);

/// Firefox Relay

pref("signon.firefoxRelay.feature", "disabled");

/// "Interest-based Content Relevance Ranking"
// https://bugzilla.mozilla.org/show_bug.cgi?id=1886207

pref("toolkit.contentRelevancy.enabled", false, locked);
pref("toolkit.contentRelevancy.ingestEnabled", false, locked);
pref("toolkit.contentRelevancy.log", false, locked);

/// "Top Sites"/Sponsored content/etc.
// https://searchfox.org/mozilla-central/source/toolkit/components/nimbus/FeatureManifest.yaml

pref("browser.newtabpage.activity-stream.default.sites", "");
pref("browser.newtabpage.activity-stream.discoverystream.spocTopsitesPlacement.enabled", false, locked);
pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false, locked);
pref("browser.newtabpage.activity-stream.improvesearch.noDefaultSearchTile", true); // [DEFAULT]
pref("browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts", false);
pref("browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned", "");
pref("browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines", "");
pref("browser.newtabpage.activity-stream.feeds.section.topstories", false, locked);
pref("browser.newtabpage.activity-stream.feeds.section.topstories.options", "{\"hidden\":true}", locked);
pref("browser.newtabpage.pinned", "");
pref("browser.partnerlink.attributionURL", "", locked);
pref("browser.partnerlink.campaign.topsites", "", locked);
pref("browser.topsites.component.enabled", false, locked); // [DEFAULT]
pref("browser.topsites.contile.enabled", false, locked);
pref("browser.topsites.contile.endpoint", "", locked);
pref("browser.topsites.contile.sov.enabled", false, locked);
pref("browser.topsites.useRemoteSetting", false, locked);
pref("browser.urlbar.sponsoredTopSites", false, locked);

/// Misc. Activity Stream (about:home)
// We also configure "FirefoxHome" in policies
// https://mozilla.github.io/policy-templates/#firefoxhome
// https://searchfox.org/mozilla-central/source/testing/geckodriver/src/prefs.rs
// https://searchfox.org/mozilla-central/source/toolkit/components/nimbus/FeatureManifest.yaml

pref("browser.newtabpage.activity-stream.asrouter.providers.cfr", "null", locked);
pref("browser.newtabpage.activity-stream.asrouter.providers.cfr-fxa", "null", locked);
pref("browser.newtabpage.activity-stream.asrouter.providers.message-groups", "null", locked);
pref("browser.newtabpage.activity-stream.asrouter.providers.messaging-experiments", "null", locked);
pref("browser.newtabpage.activity-stream.asrouter.providers.onboarding", "null", locked);
pref("browser.newtabpage.activity-stream.asrouter.providers.snippets", "null", locked);
pref("browser.newtabpage.activity-stream.asrouter.useRemoteL10n", false);
pref("browser.newtabpage.activity-stream.discoverystream.config", "[]", locked);
pref("browser.newtabpage.activity-stream.discoverystream.contextualContent.enabled", false, locked);
pref("browser.newtabpage.activity-stream.discoverystream.contextualContent.feeds", "", locked);
pref("browser.newtabpage.activity-stream.discoverystream.enabled", false, locked);
pref("browser.newtabpage.activity-stream.discoverystream.endpoints", "", locked);
pref("browser.newtabpage.activity-stream.discoverystream.endpointSpocsClear", "", locked);
pref("browser.newtabpage.activity-stream.discoverystream.onboardingExperience.dismissed", true, locked);
pref("browser.newtabpage.activity-stream.discoverystream.onboardingExperience.enabled", false, locked);
pref("browser.newtabpage.activity-stream.discoverystream.personalization.enabled", false, locked);
pref("browser.newtabpage.activity-stream.discoverystream.recs.personalized", false, locked);
pref("browser.newtabpage.activity-stream.discoverystream.spocs.personalized", false, locked);
pref("browser.newtabpage.activity-stream.discoverystream.spocs-endpoint", "", locked); // [DEFAULT]
pref("browser.newtabpage.activity-stream.discoverystream.spocs-endpoint-query", "", locked); // [DEFAULT]
pref("browser.newtabpage.activity-stream.discoverystream.sponsored-collections.enabled", false, locked); // [DEFAULT]
pref("browser.newtabpage.activity-stream.discoverystream.topicSelection.enabled", false, locked);
pref("browser.newtabpage.activity-stream.discoverystream.topicSelection.onboarding.enabled", false, locked); // [DEFAULT]
pref("browser.newtabpage.activity-stream.feeds.discoverystreamfeed", false, locked);
pref("browser.newtabpage.activity-stream.feeds.recommendationprovider", false, locked);
pref("browser.newtabpage.activity-stream.feeds.snippets", false, locked);
pref("browser.newtabpage.activity-stream.showSponsored", false, locked);
pref("browser.newtabpage.activity-stream.system.showSponsored", false, locked);
pref("browser.newtabpage.activity-stream.tippyTop.service.endpoint", "", locked);
pref("browser.newtabpage.activity-stream.unifiedAds.adsFeed.enabled", false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.adsFeed.tiles.enabled", false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.enabled", false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.endpoint", "", locked);
pref("browser.newtabpage.activity-stream.unifiedAds.spocs.enabled", false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.tiles.enabled", false, locked);
pref("messaging-system.askForFeedback", false, locked);

/// Firefox Suggest
// We also configure "FirefoxSuggest" & "UrlbarInterventions" in policies
// https://mozilla.github.io/policy-templates/#firefoxsuggest
// https://mozilla.github.io/policy-templates/#usermessaging
// https://mozilla-services.github.io/merino/firefox.html
// https://github.com/mozilla-services/merino-py

pref("browser.newtabpage.activity-stream.discoverystream.merino-feed-experiment", false);
pref("browser.newtabpage.activity-stream.discoverystream.merino-provider.enabled", false);
pref("browser.newtabpage.activity-stream.discoverystream.merino-provider.endpoint", "");
pref("browser.urlbar.addons.featureGate", false);
pref("browser.urlbar.groupLabels.enabled", false);
pref("browser.urlbar.mdn.featureGate", false);
pref("browser.urlbar.merino.endpointURL", "");
pref("browser.urlbar.merino.providers", "");
pref("browser.urlbar.quicksuggest.contextualOptIn", false);
pref("browser.urlbar.quicksuggest.enabled", false);
pref("browser.urlbar.quicksuggest.hideSettingsUI", true);
pref("browser.urlbar.quicksuggest.scenario", "offline");
pref("browser.urlbar.quicksuggest.shouldShowOnboardingDialog", false);
pref("browser.urlbar.quicksuggest.showedOnboardingDialog", true);
pref("browser.urlbar.quicksuggest.sponsoredPriority", false, locked);
pref("browser.urlbar.suggest.addons", false);
pref("browser.urlbar.suggest.mdn", false);
pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
pref("browser.urlbar.suggest.quicksuggest.sponsored", false, locked);
pref("browser.urlbar.suggest.trending", false);
pref("browser.urlbar.suggest.weather", false);
pref("browser.urlbar.suggest.yelp", false);
pref("browser.urlbar.trending.featureGate", false);
pref("browser.urlbar.weather.featureGate", false);
pref("browser.urlbar.yelp.featureGate", false);

/// Misc. Promotions

pref("browser.contentblocking.report.hide_vpn_banner", true, locked);
pref("browser.contentblocking.report.lockwise.enabled", false);
pref("browser.contentblocking.report.monitor.enabled", false); // [DEFAULT]
pref("browser.contentblocking.report.proxy.enabled", false); // [DEFAULT]
pref("browser.contentblocking.report.proxy_extension.url", "", locked);
pref("browser.contentblocking.report.show_mobile_app", false, locked);
pref("browser.contentblocking.report.vpn-android.url", "", locked);
pref("browser.contentblocking.report.vpn-ios.url", "", locked);
pref("browser.contentblocking.report.vpn-promo.url", "", locked);
pref("browser.newtabpage.activity-stream.newtabWallpapers.highlightDismissed", true);
pref("browser.newtabpage.activity-stream.newtabWallpapers.highlightEnabled", false);
pref("browser.preferences.moreFromMozilla", false, locked);
pref("browser.privatebrowsing.vpnpromourl", "", locked);
pref("browser.promo.cookiebanners.enabled", false, locked);
pref("browser.promo.focus.enabled", false, locked);
pref("browser.promo.pin.enabled", false, locked);
pref("browser.protections_panel.infoMessage.seen", true); // Disables ETP Banner
pref("browser.vpn_promo.enabled", false, locked);
pref("cookiebanners.ui.desktop.showCallout", false);
pref("identity.fxaccounts.toolbar.pxiToolbarEnabled", false, locked);
pref("identity.fxaccounts.toolbar.pxiToolbarEnabled.monitorEnabled", false, locked);
pref("identity.fxaccounts.toolbar.pxiToolbarEnabled.relayEnabled", false, locked);
pref("identity.fxaccounts.toolbar.pxiToolbarEnabled.vpnEnabled", false, locked);
pref("identity.mobilepromo.android", "", locked);
pref("identity.mobilepromo.ios", "", locked);
pref("identity.sendtabpromo.url", "", locked);

/// Kill about:welcome & Onboarding

pref("browser.aboutwelcome.enabled", false);
pref("browser.EULA.override", true); // https://searchfox.org/mozilla-central/source/testing/profiles/perf/user.js
pref("browser.startup.homepage_override.mstone", "ignore");
pref("browser.suppress_first_window_animation", true); // [DEFAULT]
pref("browser.usedOnWindows10.introURL", ""); // https://searchfox.org/mozilla-central/source/remote/shared/RecommendedPreferences.sys.mjs
pref("startup.homepage_override_url", "");
pref("startup.homepage_override_url_nimbus", "");
pref("startup.homepage_welcome_url", "");
pref("startup.homepage_welcome_url.additional", "");

/// Kill "Feature Tours"

pref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");
pref("browser.pdfjs.feature-tour", "{\"screen\":\"\",\"complete\":true}");

/// Prevent Mozilla domains from having special privileges
// https://firefox-source-docs.mozilla.org/dom/ipc/process_model.html#privileged-mozilla-content

pref("browser.tabs.remote.separatePrivilegedMozillaWebContentProcess", false, locked); // [DEFAULT]
pref("browser.tabs.remote.separatedMozillaDomains", "", locked);
pref("browser.uitour.enabled", false, locked);
pref("browser.uitour.loglevel", "Off");
pref("browser.uitour.requireSecure", true, locked); // [DEFAULT]
pref("browser.uitour.surveyDuration", 0, locked);
pref("browser.uitour.url", "", locked);
pref("dom.ipc.processCount.privilegedmozilla", 0, locked);
pref("extensions.webapi.testing", false, locked); // [DEFAULT] https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#5445
pref("extensions.webextensions.restrictedDomains", "");
pref("permissions.manager.defaultsUrl", "", locked);
pref("services.sync.addons.trustedSourceHostnames", "");
pref("svg.context-properties.content.allowed-domains", "", locked); // [DEFAULT]

/// Disable Mozilla Web Compatibility Reporter
// Harmless from a privacy perspective - We just don't want to waste Mozilla's time due to our custom set-up...
// Also acts as attack surface reduction & a potential performance improvement

pref("extensions.webcompat-reporter.enabled", false, locked); // [DEFAULT]
pref("extensions.webcompat-reporter.newIssueEndpoint", "", locked);
pref("ui.new-webcompat-reporter.enabled", false, locked); // https://searchfox.org/mozilla-central/source/toolkit/components/nimbus/FeatureManifest.yaml#3604
pref("ui.new-webcompat-reporter.send-more-info-link", false, locked); // [DEFAULT]

pref("browser.phoenix.core.status", "002", locked);

// 003 Search & URL Bar

/// Allow adding custom search engines in about:preferences#search

pref("browser.urlbar.update2.engineAliasRefresh", true);

/// Never trim URLs

pref("browser.urlbar.trimHttps", false);
pref("browser.urlbar.trimURLs", false);

/// Allow using a different search engine in Private Windows vs. Normal Windows

pref("browser.search.separatePrivateDefault.ui.enabled", true);

// Ensure by default we use same search engine in both Private & Normal Windows
// Otherwise, Firefox's private search appears to default to Google... :/

pref("browser.search.separatePrivateDefault", false);

// Prompt to use Private Browsing

pref("browser.search.separatePrivateDefault.urlbarResult.enabled", true); // [HIDDEN]

// Remove Search Engine Placeholders

pref("browser.urlbar.placeholderName", "");
pref("browser.urlbar.placeholderName.private", "");

/// Always show Punycode - Helps prevent phishing & IDN Homograph Attacks
// https://wikipedia.org/wiki/IDN_homograph_attack

pref("network.IDN_show_punycode", true);

/// Do not autofill/autocomplete URLs by default

pref("browser.urlbar.autoFill", false);

// Always show URL instead of search terms

pref("browser.urlbar.showSearchTerms.enabled", false);
pref("browser.urlbar.showSearchTerms.featureGate", false);

/// Enforce that JavaScript URLS are excluded from results

pref("browser.urlbar.filter.javascript", true); // [DEFAULT]

/// Disable "Recent Searches" being suggested since we disable Search & Form History anyways

pref("browser.urlbar.recentsearches.featureGate", false);
pref("browser.urlbar.suggest.recentsearches", false);

// Nice to have

pref("browser.urlbar.clipboard.featureGate", false);
pref("browser.urlbar.suggest.bookmark", true);
pref("browser.urlbar.suggest.calculator", true);
pref("browser.urlbar.suggest.clipboard", false);
pref("browser.urlbar.suggest.engines", false);
pref("browser.urlbar.suggest.history", false);
pref("browser.urlbar.suggest.openpage", true);
pref("browser.urlbar.unitConversion.enabled", true);

pref("browser.phoenix.core.status", "003", locked);

// 004 Implicit Connections

/// Disable Network Prefetching
// https://developer.mozilla.org/docs/Glossary/Prefetch

pref("browser.places.speculativeConnect.enabled", false);
pref("browser.urlbar.speculativeConnect.enabled", false);
pref("dom.prefetch_dns_for_anchor_http_document", false); // https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/42684
pref("dom.prefetch_dns_for_anchor_https_document", false); // [DEFAULT] https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/42684
pref("network.dns.disablePrefetch", true);
pref("network.dns.disablePrefetchFromHTTPS", true); // [DEFAULT]
pref("network.dns.prefetch_via_proxy", false); // [DEFAULT]
pref("network.http.speculative-parallel-limit", 0);
pref("network.predictor.enable-hover-on-ssl", false); // [DEFAULT]
pref("network.predictor.enable-prefetch", false); // [DEFAULT]
pref("network.predictor.enabled", false);
pref("network.prefetch-next", false);

/// Disable Preconnect
// https://github.com/uBlockOrigin/uBlock-issues/issues/2913
// https://developer.mozilla.org/docs/Web/HTML/Attributes/rel/preconnect

pref("network.preconnect", false);

/// Disable Early Hints
// https://developer.mozilla.org/docs/Web/HTTP/Status/103
// https://github.com/bashi/early-hints-explainer/blob/main/explainer.md
// Ex. like Cromite https://github.com/uazo/cromite/blob/master/build/patches/Client-hints-overrides.patch

pref("network.early-hints.enabled", false);
pref("network.early-hints.preconnect.enabled", false);
pref("network.early-hints.preconnect.max_connections", 0);

/// Disable Search Suggestions

pref("browser.search.suggest.enabled", false); // [DEFAULT - Android]
pref("browser.search.suggest.enabled.private", false); // [DEFAULT - Android]
pref("browser.urlbar.showSearchSuggestionsFirst", false);
pref("browser.urlbar.suggest.searches", false);

/// Prevent leaking single word searches to DNS provider

pref("browser.fixup.dns_first_for_single_words", false); // [DEFAULT]
pref("browser.urlbar.dnsResolveSingleWordsAfterSearch", 0);

/// Prevent middle click on new tab button opening URLs or searches from clipboard

pref("browser.tabs.searchclipboardfor.middleclick", false);

pref("browser.phoenix.core.status", "004", locked);

// 005 HTTP(S) - Mixed Content & General Network Hardening

/// Enforce using HTTPS as much as possible

pref("dom.security.https_first", true);
pref("dom.security.https_first_for_custom_ports", true); // [DEFAULT, DEFENSE IN DEPTH]
pref("dom.security.https_first_pbm", true); // [DEFAULT]
pref("dom.security.https_first_schemeless", true);
pref("dom.security.https_only_mode", true);
pref("dom.security.https_only_mode.upgrade_local", true);
pref("dom.security.https_only_mode_pbm", true);
pref("security.mixed_content.block_active_content", true);
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

pref("security.insecure_connection_text.enabled", true);
pref("security.insecure_connection_text.pbmode.enabled", true);
pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
pref("security.warn_submit_secure_to_insecure", true); // Warn when submitting a form from HTTP to HTTPS

/// Show detailed information on insecure warning pages

pref("browser.xul.error_pages.expert_bad_cert", true);

/// Disable TLS 1.3 0-RTT (Not forward secret)
// https://github.com/tlswg/tls13-spec/issues/1001

pref("network.http.http3.enable_0rtt", false); // For HTTP3 https://bugzilla.mozilla.org/show_bug.cgi?id=1689550
pref("security.tls.enable_0rtt_data", false);

/// Require safe renegotiations - Disables connections to servers without RFC 5746
// https://wiki.mozilla.org/Security:Renegotiation

pref("security.ssl.require_safe_negotiation", true);

/// Enforce preloading intermediates
// https://wiki.mozilla.org/Security/CryptoEngineering/Intermediate_Preloading

pref("security.remote_settings.intermediates.enabled", true); // [DEFAULT]

/// Never downgrade to insecure TLS 1.0/1.1

pref("security.tls.insecure_fallback_hosts", ""); // [DEFAULT]
pref("security.tls.version.enable-deprecated", false, locked); // [DEFAULT]

/// Enforce TLS 1.3 downgrade protection
// https://bugzilla.mozilla.org/show_bug.cgi?id=1576790

pref("security.tls.hello_downgrade_check", true); // [DEFAULT]

/// Only load secure websockets from HTTPS pages

pref("network.websocket.allowInsecureFromHTTPS", false); // [DEFAULT]

/// Block access to Addon Manager over insecure protocols...
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#5452

pref("extensions.webapi.testing.http", false); // [DEFAULT]

/// Enable Post Quantum Key Agreement (Kyber)

pref("media.webrtc.enable_pq_dtls", true);
pref("network.http.http3.enable_kyber", true);
pref("security.tls.enable_kyber", true);

/// Enforce MITM Detection
// https://bugzilla.mozilla.org/show_bug.cgi?id=1529643

pref("security.certerrors.mitm.priming.enabled", true); // [DEFAULT]

/// Disable Captive Portal Detection & Connectivity Checks
// Privacy & security concerns, and in general best handled by the OS.
// https://support.mozilla.org/kb/how-stop-firefox-making-automatic-connections#w_network-detection
// https://www.eff.org/deeplinks/2017/08/how-captive-portals-interfere-wireless-security-and-privacy

pref("captivedetect.canonicalURL", "");
pref("network.captive-portal-service.enabled", false);
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

pref("browser.phoenix.core.status", "005", locked);

// 006 DNS

/// Disable Mozilla's DoH Rollout

pref("doh-rollout.disable-heuristics", true, locked); // [HIDDEN]
pref("doh-rollout.enabled", false, locked); // [HIDDEN]
pref("doh-rollout.skipHeuristicsCheck", true, locked); // [HIDDEN]
pref("doh-rollout.uri", "", locked); // [HIDDEN]

/// Enable DoH & Set to Quad9 by default

pref("network.trr.default_provider_uri", "https://dns.quad9.net/dns-query");
pref("network.trr.mode", 3);

/// Improve list of built-in DoH Providers

pref("doh-rollout.provider-list", '[{"UIName":"Quad9 - Real-time Malware Protection","uri":"https://dns.quad9.net/dns-query"}, {"UIName":"DNS0 (ZERO) - Hardened Real-time Malware Protection","uri":"https://zero.dns0.eu"}, {"UIName":"DNS0 - Real-time Malware Protection","uri":"https://dns0.eu"}, {"UIName":"Mullvad - Ad/Tracking/Limited Malware Protection","uri":"https://base.dns.mullvad.net/dns-query"}, {"UIName":"AdGuard (Public) - Ad/Tracking Protection","uri":"https://dns.adguard-dns.com/dns-query"}, {"UIName":"Mullvad - No Filtering","uri":"https://dns.mullvad.net/dns-query"}, {"UIName":"Wikimedia - No Filtering","uri":"https://wikimedia-dns.org/dns-query"}, {"UIName":"AdGuard (Public) - No Filtering","uri":"https://unfiltered.adguard-dns.com/dns-query"}, {"UIName":"DNS0 - Kids","uri":"https://kids.dns0.eu"}, {"UIName":"Mullvad - Family","uri":"https://family.dns.mullvad.net/dns-query"}, {"UIName":"AdGuard (Public) - Family Protection","uri":"https://family.adguard-dns.com/dns-query"}, {"UIName":"Mullvad - Ad/Tracking/Limited Malware/Social Media Protection","uri":"https://extended.dns.mullvad.net/dns-query"}, {"UIName":"Mullvad - Ad/Tracking/Limited Malware/Social Media/Adult/Gambling Protection","uri":"https://all.dns.mullvad.net/dns-query"}]');

/// Skip DoH Connectivity Checks

pref("network.connectivity-service.DNS_HTTPS.domain", "");
pref("network.trr.confirmationNS", "skip");

/// Never disable DoH from registry checks
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml

pref("network.notify.checkForNRPT", false);
pref("network.notify.checkForProxies", false);

/// Enable EncryptedClientHello
// https://blog.cloudflare.com/announcing-encrypted-client-hello

pref("network.dns.echconfig.enabled", true); // [DEFAULT]
pref("network.dns.http3_echconfig.enabled", true); // [DEFAULT]

/// Enable Native DNS HTTPS Lookups

pref("network.dns.native_https_query", true); // [DEFAULT]

/// Fix IPv6 connectivity when DoH is enabled
// https://codeberg.org/divested/brace/pulls/5

pref("network.dns.preferIPv6", true);

pref("browser.phoenix.core.status", "006", locked);

// 007 CERTIFICATES

/// Enforce OCSP & Stapling

pref("security.OCSP.enabled", 1); // [DEFAULT - Desktop]
pref("security.ssl.enable_ocsp_must_staple", true); // [DEFAULT]
pref("security.ssl.enable_ocsp_stapling", true); // [DEFAULT]

/// Hard-fail OCSP by default
// Personally have not ran into any issues from this in YEARS... & it provides a significant security improvement
// Can reconsider if people start having issues

pref("security.OCSP.require", true);

/// Enable CRLite & use where possible

pref("security.pki.crlite_mode", 2);
pref("security.remote_settings.crlite_filters.enabled", true);

/// Make exceptions for certificate errors session only

pref("security.certerrors.permanentOverride", false);

/// Enforce Strict Certificate Pinning
// https://wiki.mozilla.org/SecurityEngineering/Public_Key_Pinning#How_to_use_pinning

pref("security.cert_pinning.enforcement_level", 2);

/// Disable third-party/OS-level root certificates
// I've been torn on how to handle this, but IMO the safest way forward is disabling this functionality in Firefox.
// This is commonly abused by malware/etc. and it's even overriden by certain software/garbage AV's...
// Ex. https://support.kaspersky.com/common/compatibility/14620#block3
// Since this is something programs actively try to override, I don't see a safe way to support this, so we'll lock it.
// We still allow users to manually import certificates into Firefox... 
// So we can ensure users are aware of certificates they add and are making this decision consciously.
// security.osclientcerts.autoload can be left alone - https://groups.google.com/a/mozilla.org/g/enterprise/c/XiW-ZidMaII
// We also set "ImportEnterpriseRoots" in policies
// https://mozilla.github.io/policy-templates/#certificates--importenterpriseroots

pref("security.enterprise_roots.enabled", false); // [DEFAULT - Android]

/// Enable & Enforce Certificate Transparency
// https://wiki.mozilla.org/SecurityEngineering/Certificate_Transparency
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15868

pref("security.pki.certificate_transparency.mode", 2); // [DEFAULT: 0]
pref("security.pki.certificate_transparency.disable_for_hosts", ""); // [DEFAULT]
pref("security.pki.certificate_transparency.disable_for_spki_hashes", ""); // [DEFAULT]

pref("browser.phoenix.core.status", "007", locked);

// 008 DOWNLOADS

/// Always prompt before downloading files

pref("browser.download.always_ask_before_handling_new_types", true);
pref("browser.download.useDownloadDir", false);

// Always notify when downloading files

pref("browser.download.alwaysOpenPanel", true); // [DEFAULT - Desktop]

// Enforce blocking insecure downloads

pref("dom.block_download_insecure", true); // [DEFAULT]

pref("browser.phoenix.core.status", "008", locked);

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
pref("browser.safebrowsing.downloads.remote.url", "https://sb-ssl.google.com/safebrowsing/clientreport/download?key=%GOOGLE_SAFEBROWSING_API_KEY%"); // [DEFAULT]

/// Enforce that no data is shared with Google
// https://bugzilla.mozilla.org/show_bug.cgi?id=1351147

pref("browser.safebrowsing.provider.google.dataSharing.enabled", false, locked); // [DEFAULT]
pref("browser.safebrowsing.provider.google4.dataSharing.enabled", false, locked); // [DEFAULT]
pref("browser.safebrowsing.provider.google4.dataSharingURL", "", locked);

/// Show advanced details on pages blocked by Safe Browsing by default

pref("browser.xul.error_pages.show_safe_browsing_details_on_load", true);

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

pref("browser.phoenix.core.status", "009", locked);

// 010 GEOLOCATION

/// Prevent Wi-Fi Scanning

pref("browser.region.network.scan", false); // [DEFAULT]
pref("geo.wifi.scan", false); // [HIDDEN] https://searchfox.org/mozilla-release/source/remote/shared/RecommendedPreferences.sys.mjs#299

/// Disable "Region Updates"
// https://firefox-source-docs.mozilla.org/toolkit/modules/toolkit_modules/Region.html

pref("browser.region.network.url", "");
pref("browser.region.update.enabled", false);

/// Geolocation Provider

/// Set BeaconDB as the network Geolocation provider instead of Google...

pref("geo.provider.network.url", "https://api.beacondb.net/v1/geolocate");

pref("browser.phoenix.core.status", "010", locked);

// 011 AI
// https://support.mozilla.org/kb/ai-chatbot

/// Ensure that AI functionality is disabled by default

pref("browser.ml.chat.enabled", false); // [DEFAULT] - AI Chatbot
pref("browser.ml.chat.shortcuts", false); // Pop-up when highlighting text
pref("browser.ml.enable", false); // [DEFAULT, except for Nightly] - "Experimental Machine Learning Inference Engine"

/// If AI Chatbot is enabled, set it to DuckDuckGo AI Chat by default
/// Unfortunately this is not compatible with the pop-up when selecting text. There is also not a way at the moment to add it as a persistent option.

pref("browser.ml.chat.provider", "https://duckduckgo.com/?q=DuckDuckGo+AI+Chat&ia=chat");

/// If AI Chatbot is enabled, remove built-in Anthropic Claude, ChatGPT, Google Gemini, & Le Chat Mistral options due to the terrible privacy policies...
/// HuggingChat is generally solid, though it does leave room for some questions, best option out of the built-in

pref("browser.ml.chat.providers", "huggingchat");

/// Allow toggling AI via about:preferences#experimental by default

pref("browser.ml.chat.hideFromLabs", false);

/// If pop-up when highlighting text is enabled, allow typing a custom prompt based on your selection

pref("browser.ml.chat.shortcuts.custom", true); // [DEFAULT]

/// Disable AI/ML "Autofill Experiment"...
// https://searchfox.org/mozilla-central/source/toolkit/components/formautofill/MLAutofill.sys.mjs

pref("extensions.formautofill.ml.experiment.enabled", false);

pref("browser.phoenix.core.status", "011", locked);

// 012 WEBRTC

/// Enable mDNS Host Obfuscation to prevent leaking local IP addresses
// https://bugzilla.mozilla.org/show_bug.cgi?id=1588817

pref("media.peerconnection.ice.obfuscate_host_addresses", true); // [DEFAULT - Desktop]

/// If a proxy is configured, ensure WebRTC isn't bypassing it
// https://bugzilla.mozilla.org/show_bug.cgi?id=1790270

pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);

pref("privacy.webrtc.allowSilencingNotifications", true);
pref("privacy.webrtc.globalMuteToggles", true);
pref("privacy.webrtc.hideGlobalIndicator", false);
pref("privacy.webrtc.sharedTabWarning", true);

/// Always sandbox Media Transport
// https://searchfox.org/mozilla-central/source/security/sandbox/common/SandboxSettings.cpp

pref("media.peerconnection.mtransport_process", true); // [DEFAULT]

pref("browser.phoenix.core.status", "012", locked);

// 013 DISK AVOIDANCE

/// Disable Search & Form History - Can be leaked to sites
// https://blog.mindedsecurity.com/2011/10/autocompleteagain.html

pref("browser.formfill.enable", false);

/// Disable caching, might reconsider since we clear cache on exit anyways

pref("browser.cache.disk.enable", false);
pref("browser.cache.disk_cache_ssl", false);
pref("browser.privatebrowsing.forceMediaMemoryCache", true);

/// Prevent storing unnecessary extra session data

pref("browser.sessionstore.privacy_level", 2);

/// Sanitize on exit
// Clears browsing history, cache, download history, & sessions on exit by default

pref("privacy.clearHistory.cache", true);
pref("privacy.clearHistory.historyFormDataAndDownloads", true);
pref("privacy.clearSiteData.cache", true);
pref("privacy.clearSiteData.historyFormDataAndDownloads", true);
pref("privacy.clearOnShutdown.cache", true);
pref("privacy.clearOnShutdown.downloads", true);
pref("privacy.clearOnShutdown.formdata", true);
pref("privacy.clearOnShutdown.history", true);
pref("privacy.clearOnShutdown.offlineApps", true);
pref("privacy.clearOnShutdown.sessions", true);
pref("privacy.clearOnShutdown_v2.cache", true);
pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", true);
pref("privacy.cpd.cache", true);
pref("privacy.cpd.formdata", true);
pref("privacy.sanitize.sanitizeOnShutdown", true); // Allows selectively clearing data on shutdown

/// Set time range when manually clearing data to "everything" by default

pref("privacy.sanitize.timeSpan", 0);

// Prevent automatically sharing Firefox Sync accounts...

pref("identity.fxaccounts.migrateToDevEdition", false);

/// Prevent logging blocked domains in about:protections

pref("browser.contentblocking.cfr-milestone.enabled", false);
pref("browser.contentblocking.database.enabled", false); // [DEFAULT - Android]

/// Disable favicons in shortcuts, prevents .ico files from persisting even after deletion

pref("browser.shell.shortcutFavicons", false);

/// Delete cached files from windows opened with external applications

pref("browser.download.start_downloads_in_tmp_dir", true);
pref("browser.helperApps.deleteTempFileOnExit", true);

// Prevent exposing content in the window title for Private Browsing windows
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js

pref("privacy.exposeContentTitleInWindow.pbm", false);

/// When a file is deleted in Firefox, also remove from session list & history 
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js

pref("browser.download.clearHistoryOnDelete", 2);

/// Adds a fire button in Private Browsing Windows to reset session

pref("browser.privatebrowsing.resetPBM.enabled", true);

/// Disable LaterRun
// https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/41568
// https://bugzilla.mozilla.org/show_bug.cgi?id=1200639

pref("browser.laterrun.enabled", false);

/// Prevent coloring visited links

pref("layout.css.visited_links_enabled", false);

/// Disable collecting & generating background thumbnails

pref("browser.pagethumbnails.capturing_disabled", true); // [HIDDEN]

pref("browser.phoenix.core.status", "013", locked);

// 014 EXTENSIONS

/// Only allow installing extensions from profile & application directories (Prevents extensions being installed from the system/via other software)
// https://archive.is/DYjAM
// https://github.com/arkenfox/user.js/blob/master/user.js#L612

pref("extensions.autoDisableScopes", 15, locked); // [DEFAULT] Defense in depth, ensures extensions installed via directories are disabled by default...
pref("extensions.enabledScopes", 5); // [DEFAULT]

/// Only allow signed extensions

pref("extensions.langpacks.signatures.required", true); // [DEFAULT]
pref("xpinstall.whitelist.required", true); // [DEFAULT]

/// Block extensions signed with weak signature algorithms

pref("xpinstall.signatures.weakSignaturesTemporarilyAllowed", false); // [HIDDEN]

/// Enforce Extension Blocklist

pref("extensions.blocklist.enabled", true); // [DEFAULT]

/// Never bypass 3rd party extension install prompts

pref("extensions.postDownloadThirdPartyPrompt", false, locked);

/// Allow LocalCDN to work on quarantined domains

pref("extensions.quarantineIgnoredByUser.{b86e4813-687a-43e6-ab65-0bde4ab75758}", true);

/// Allow Mullvad's extension to work on quarantined domains

pref("extensions.quarantineIgnoredByUser.{d19a89b9-76c1-4a61-bcd4-49e8de916403}", true);

pref("browser.phoenix.core.status", "014", locked);

// 015 PDF.js

/// Disable JavaScript

pref("pdfjs.enableScripting", false);

/// Disable XFA
// https://insert-script.blogspot.com/2019/01/adobe-reader-pdf-callback-via-xslt.html
// https://www.sentinelone.com/blog/malicious-pdfs-revealing-techniques-behind-attacks/
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=xfa
// https://wikipedia.org/wiki/XFA
// Not even a standard...

pref("pdfjs.enableXfa", false);

/// Never allow documents to prevent copying text

pref("pdfjs.enablePermissions", false); // [DEFAULT]

/// Prevent checking if default PDF viewer
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js

pref("browser.shell.checkpDF", false);
pref("browser.shell.checkpDF.silencedByUser", true);

/// Never open Microsoft Edge for PDFs
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml

pref("browser.pdf.launchDefaultEdgeAsApp", false);

/// Open PDFs in browser where possible

pref("browser.download.open_pdf_attachments_inline", true); // [DEFAULT - Android]

/// Show sidebar by default when viewing PDFs

pref("pdfjs.sidebarViewOnLoad", 2); // [HIDDEN]

pref("browser.phoenix.core.status", "015", locked);

// 016 MISC. PRIVACY

/// Enable ETP Strict

pref("browser.contentblocking.category", "strict", locked);

/// Enforce container isolation of about:home content

pref("browser.discovery.containers.enabled", true); // [DEFAULT]

/// Enforce Do Not Track & Global Privacy Control

pref("privacy.donottrackheader.enabled", true);
pref("privacy.globalprivacycontrol.enabled", true);
pref("privacy.globalprivacycontrol.functionality.enabled", true); // [DEFAULT]
pref("privacy.globalprivacycontrol.pbmode.enabled", true); // [DEFAULT]

/// Disable Reporting API
// https://w3c.github.io/reporting/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1492036

pref("dom.reporting.crash.enabled", false);
pref("dom.reporting.enabled", false); // [DEFAULT]
pref("dom.reporting.featurePolicy.enabled", false);
pref("dom.reporting.header.enabled", false);

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

pref("network.http.referer.policy.trackers", 1);
pref("network.http.referer.policy.trackers.pbmode", 1);

/// Disable Hyperlink Auditing (Click Tracking)
// https://www.bleepingcomputer.com/news/software/major-browsers-to-prevent-disabling-of-click-tracking-privacy-risk/

pref("browser.send_pings", false); // [DEFAULT]
pref("browser.send_pings.max_per_link", 0); // [DEFENSE IN DEPTH]
pref("browser.send_pings.require_same_host", true); // [DEFENSE IN DEPTH]

/// Improve built-in query stripping to be on par with LibreWolf & Brave
// https://codeberg.org/librewolf/settings/src/branch/master/librewolf.cfg#L77

pref("privacy.query_stripping.strip_list", "__hsfp __hssc __hstc __s _hsenc _openstat dclid fbclid gbraid gclid hsCtaTracking igshid mc_eid ml_subscriber ml_subscriber_hash msclkid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id rb_clickid s_cid twclid vero_conv vero_id wbraid wickedid yclid");

/// Strip tracking parameters from URLs when shared by default

pref("privacy.query_stripping.strip_on_share.enabled", true); // [DEFAULT]

/// Ensure we never save clipboard history/clipboard contents to the cloud...

pref("clipboard.copyPrivateDataToClipboardCloudOrHistory", false); // [DEFAULT]

/// Enable Smartblock Embeds/Placeholders
// Makes certain resources click to load

pref("extensions.webcompat.smartblockEmbeds.enabled", true); // [DEFAULT on Nightly]

/// Enable Cookies Having Independent Partitioned State (CHIPS)
// This allows websites to set cookies with a 'Partitioned' attribute, meaning they're limited in scope
// We still use ETP Strict for partioning anyways, so this could be useful as a defense in depth if a user decides to allow a specific domain (or domains) to access a third party cookie
// https://developer.mozilla.org/docs/Web/HTTP/Headers/Set-Cookie#partitioned
// https://developer.mozilla.org/docs/Web/Privacy/Privacy_sandbox/Partitioned_cookies
// https://github.com/privacycg/CHIPS

pref("network.cookie.CHIPS.enabled", true); // [DEFAULT on Nightly]

/// If a remote AutoConfig is being used, ensure identifying info is never shared...

pref("autoadmin.append_emailaddr", false, locked);
pref("mail.identity.useremail", "", locked);

pref("browser.phoenix.core.status", "016", locked);

// 017 FINGERPRINTING PROTECTION

/// Unbreak websites with FPP (if enabled)
// Currently covers Apple Maps (completely broken)

pref("privacy.fingerprintingProtection.granularOverrides", "[{\"firstPartyDomain\": \"apple.com\", \"overrides\": \"-WebGLRenderCapability\"}]");

/// Round window sizes

pref("privacy.window.maxInnerHeight", 900);
pref("privacy.window.maxInnerWidth", 1600);

/// Target 1080P instead of 480P for video playback...
// This is the same as Nightly uses
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15315

pref("privacy.resistFingerprinting.target_video_res", 1080); // [DEFAULT for Nightly]

/// Spoof locale to English by default

pref("privacy.spoof_english", 2);

/// Enable light mode by default
// This matches with RFP...

pref("layout.css.prefers-color-scheme.content-override", 1);

/// Disable WebGPU
// https://browserleaks.com/webgpu

pref("dom.webgpu.enabled", false); // [DEFAULT]

/// Disable failIfMajorPerformanceCaveat in WebGL contexts...
// https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/18603

pref("webgl.disable-fail-if-major-performance-caveat", true); // [DEFAULT]

/// Prevent using system colors

pref("browser.display.use_system_colors", false);

/// Prevent using system accent colors

pref("widget.non-native-theme.use-theme-accent", false);

/// Enable fdlibm for Math.sin, Math.cos, and Math.tan
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#8720
// https://groups.google.com/a/mozilla.org/g/dev-platform/c/0dxAO-JsoXI/m/eEhjM9VsAgAJ

pref("javascript.options.use_fdlibm_for_sin_cos_tan", true);

pref("browser.phoenix.core.status", "017", locked);

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

/// If password manager is enabled, enable alerts for breached & vulnerable passwords by default, harmless and never sends passwords or sensitive data to Mozilla
// https://support.mozilla.org/kb/mozilla-monitor-faq#w_does-mozilla-monitor-know-my-passwords
// https://blog.mozilla.org/security/2018/06/25/scanning-breached-accounts-k-anonymity/
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js

pref("signon.management.page.breach-alerts.enabled", true); // [DEFAULT]
pref("signon.management.page.vulnerable-passwords.enabled", true); // [DEFAULT]

/// If password manager is enabled, enable strong password generation by default

pref("signon.generation.enabled", true); // [DEFAULT]

/// Prevent cross-origin sub-resources from opening HTTP authentication dialogs

pref("network.auth.subresource-http-auth-allow", 1);

/// Disable Windows SSO

pref("network.http.windows-sso.container-enabled.0", false);
pref("network.http.windows-sso.enabled", false); // [DEFAULT]

/// Disable Microsoft Entra

pref("network.http.microsoft-entra-sso.container-enabled.0", false);
pref("network.http.microsoft-entra-sso.enabled", false); // [DEFAULT]
pref("network.microsoft-sso-authority-list", ""); // DEFENSE IN DEPTH

/// Prevent using Negotiate authentication by default 
// https://people.redhat.com/mikeb/negotiate/

pref("network.negotiate-auth.trusted-uris", ""); // [DEFAULT]

/// Enforce crashing on insecure password input

pref("intl.allow-insecure-text-input", false); // [DEFAULT]

/// Protect against password spoofing for cross-domain auth requests
// https://bugzilla.mozilla.org/show_bug.cgi?id=791594
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js

pref("privacy.authPromptSpoofingProtection", true); // [DEFAULT]

pref("browser.phoenix.core.status", "018", locked);

// 019 ATTACK SURFACE REDUCTION

/// Disable JavaScript Just-in-time Compilation (JIT)
// https://microsoftedge.github.io/edgevr/posts/Super-Duper-Secure-Mode/
// https://firefox-source-docs.mozilla.org/js/index.html#javascript-jits
// https://codeberg.org/rusty-snake/firefox-config/src/branch/main/assets/user-overrides.js#L60

pref("javascript.options.baselinejit", false); // Baseline Compiler
pref("javascript.options.blinterp", false); // Baseline Interpreter 
pref("javascript.options.ion", false); // WarpMonkey
pref("javascript.options.main_process_disable_jit", true); // https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#8761
pref("javascript.options.native_regexp", false); // irregexp https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/21865 https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
pref("javascript.options.wasm_baselinejit", false); // WASM Baseline Compiler

/// Disable JIT (Ion/WarpMonkey) for extensions
// This is the default, but setting here lets us expose it...

pref("javascript.options.jit_trustedprincipals", false); // [DEFAULT]

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

/// Disable SharedArrayBuffer using window.postMessage
// https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer
// https://developer.mozilla.org/docs/Web/API/Window/postMessage
// https://blog.mozilla.org/security/2018/01/03/mitigations-landing-new-class-timing-attack/
// https://github.com/tc39/ecma262/issues/1435
// By default, Firefox restricts the use of SharedArrayBuffer - this fully disables it.

pref("dom.postMessage.sharedArrayBuffer.bypassCOOP_COEP.insecure.enabled", false); // [DEFAULT]
pref("dom.postMessage.sharedArrayBuffer.withCOOP_COEP", false);

pref("browser.phoenix.core.status", "019", locked);

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

pref("security.default_personal_cert", "Ask Every Time", locked); // [DEFAULT]

/// Disable Accessibility Services
// https://web.archive.org/web/20240608190300/support.mozilla.org/en-US/kb/accessibility-services
// "Firefox Accessibility Service is a technology built into Firefox that provides 3rd party applications running on the same device the ability to inspect, monitor, visualize, and alter web page content hosted within Firefox."

pref("accessibility.force_disabled", 1);
pref("devtools.accessibility.enabled", false); // https://firefox-source-docs.mozilla.org/devtools-user/accessibility_inspector/

/// Enforce that Content Analysis is disabled
/// We also set "ContentAnalysis" in policies
// https://mozilla.github.io/policy-templates/#contentanalysis
// https://github.com/chromium/content_analysis_sdk

pref("browser.contentanalysis.default_result", 0, locked); // [DEFAULT]
pref("browser.contentanalysis.enabled", false, locked); // [DEFAULT]
pref("browser.contentanalysis.interception_point.clipboard.enabled", false, locked);
pref("browser.contentanalysis.interception_point.drag_and_drop.enabled", false, locked);
pref("browser.contentanalysis.interception_point.file_upload.enabled", false, locked);
pref("browser.contentanalysis.interception_point.print.enabled", false, locked);
pref("browser.contentanalysis.show_blocked_result", true, locked); // [DEFAULT] - Always notify users when Content Analysis blocks access to something...

/// Enforce Site Isolation & Isolate all websites
// https://wiki.mozilla.org/Project_Fission

pref("dom.ipc.processCount.webIsolated", 1);
pref("fission.autostart", true); // [DEFAULT]
pref("fission.autostart.session", true); // [DEFAULT]
pref("fission.disableSessionHistoryInParent", false); // [DEFAULT] SHIP, required for Fission

/// Always run extensions OOP (out of process...)
// https://bugzilla.mozilla.org/show_bug.cgi?id=1613141
// https://bugzilla.mozilla.org/show_bug.cgi?id=1880856
// https://groups.google.com/g/tb-planning/c/p4MUTMNYBVo

pref("extensions.webextensions.remote", true); // [DEFAULT]

/// Yes, this is a real pref... 
// https://searchfox.org/mozilla-central/source/testing/profiles/common/user.js

pref("security.turn_off_all_security_so_that_viruses_can_take_over_this_computer", false, locked); // [HIDDEN - DEFAULT]

/// Enable GPU Sandboxing
// https://www.ghacks.net/2023/01/17/firefox-110-will-launch-with-gpu-sandboxing-on-windows/

pref("security.sandbox.gpu.level", 1);

/// Protect against CSRF Attacks (Like Chromium)
// https://groups.google.com/a/mozilla.org/g/dev-platform/c/6PZtLH7c6JQ
// https://hacks.mozilla.org/2020/08/changes-to-samesite-cookie-behavior/
// https://web.dev/articles/samesite-cookies-explained
// https://help.salesforce.com/s/articleView?id=000389944&type=1
// https://portswigger.net/web-security/csrf/bypassing-samesite-restrictions
// https://web.dev/articles/schemeful-samesite

pref("network.cookie.sameSite.laxByDefault", true);
pref("network.cookie.sameSite.noneRequiresSecure", true);
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

/// Disable Win32k System Calls
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15638
// https://security.googleblog.com/2016/10/disclosing-vulnerabilities-to-protect.html
// https://docs.google.com/document/d/1gJDlk-9xkh6_8M_awrczWCaUuyr0Zd2TKjNBCiPO_G4/edit

pref("security.sandbox.content.win32k-disable", true); // [DEFAULT]
pref("security.sandbox.gmp.win32k-disable", true);
pref("security.sandbox.socket.win32k-disable", true); // [DEFAULT]

// Ensure that Firefox can't access the system's Shell...
// https://www.stigviewer.com/stig/mozilla_firefox/2019-12-12/finding/V-15771

pref("network.protocol-handler.external.shell", false, locked); // [DEFAULT]

// Always warn users before launching other apps...

pref("network.protocol-handler.warn-external.mailto", true);
pref("network.protocol-handler.warn-external-default", true); // [DEFAULT]
pref("security.external_protocol_requires_permission", true); // [DEFAULT]

/// Enforce various other important security-related prefs
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15473

pref("dom.block_external_protocol_in_iframes", true); // [DEFAULT]
pref("dom.block_external_protocol_navigation_from_sandbox", true); // [DEFAULT]
pref("security.all_resource_uri_content_accessible", false); // [DEFAULT]
pref("security.allow_eval_in_parent_process", false); //[DEFAULT on standard Firefox releases only, not on ex. Thunderbird & other builds]
pref("security.allow_eval_with_system_principal", false); // [DEFAULT on standard Firefox releases only, not on ex. Thunderbird & other builds]
pref("security.allow_parent_unrestricted_js_loads", false); // [DEFAULT on standard Firefox releases only, not on ex. Thunderbird & other builds]
pref("security.allow_unsafe_parent_loads", false); // [DEFAULT]
pref("security.data_uri.block_toplevel_data_uri_navigations", true); // [DEFAULT]

/// Always use a separate content process for `file://` URLs
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#1848

pref("browser.tabs.remote.separateFileUriProcess", true); // [DEFAULT]

/// Never skip the assertion that about:pages don't have content security policies (CSP)
// This is default on Standard Firefox releases, but not on ex. Thunderbird & other builds
// https://searchfox.org/comm-central/source/mozilla/modules/libpref/init/StaticPrefList.yaml#3987

pref("dom.security.skip_about_page_has_csp_assert", false);

/// Apply CSP to internal browser.xhtml
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15628

pref("security.browser_xhtml_csp.enabled", true); // [HIDDEN]

/// Enable Trusted Types (Like Chromium)
// https://w3c.github.io/trusted-types/dist/spec/
// https://developer.mozilla.org/docs/Web/API/Trusted_Types_API
// https://www.theregister.com/2023/12/21/mozilla_decides_trusted_types_is/

pref("dom.security.trusted_types.enabled", true);

/// Prevent marking JIT code pages as both writable and executable, only one or the other...
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#8714
// Might cause issues in certain specific set-ups
// https://bugzilla.mozilla.org/show_bug.cgi?id=1876632

pref("javascript.options.content_process_write_protect_code", true);

/// Enable Opaque Response Blocking
// https://github.com/annevk/orb

pref("browser.opaqueResponseBlocking", true);
pref("browser.opaqueResponseBlocking.javascriptValidator", true); // [DEFAULT]

/// Enable the 'credentialless' COEP (Cross-Origin-Embedder-Policy) Header
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#1829

pref("browser.tabs.remote.coep.credentialless", true); // [DEFAULT - Desktop & Nightly Android]
pref("dom.origin-trials.coep-credentialless.state", 1); // https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#3447

/// Prevent remoteTypes from triggering process switches they shouldn't be able to...
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js#1035

pref("browser.tabs.remote.enforceRemoteTypeRestrictions", true); // [DEFAULT on Nightly]

/// If a remote AutoConfig is being used, block it from gaining privileged browser access...
// https://www.mozilla.org/firefox/62.0/releasenotes/

pref("general.config.sandbox_enabled", true, locked);

pref("browser.phoenix.core.status", "020", locked);

// 021 BLOCK COOKIE BANNERS

pref("cookiebanners.service.mode", 1);
pref("cookiebanners.service.mode.privateBrowsing", 1);
pref("cookiebanners.service.enableGlobalRules", true);
pref("cookiebanners.ui.desktop.enabled", true);

pref("browser.phoenix.core.status", "021", locked);

// 022 MEDIA

/// Always sandbox GMP
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml

pref("media.gmp.insecure.allow", false); // [DEFAULT]

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

pref("browser.eme.ui.enabled", false);
pref("media.clearkey.persistent-license.enabled", false); // [DEFAULT]
pref("media.clearkey.test-key-systems.enabled", false); // [DEFAULT]
pref("media.eme.enabled", false);
pref("media.eme.encrypted-media-encryption-scheme.enabled", false);
pref("media.eme.hdcp-policy-check.enabled", false);
pref("media.eme.require-app-approval", true); // [DEFAULT - DEFENSE IN DEPTH]: Enforce locking DRM behind permission https://searchfox.org/mozilla-central/source/mobile/android/app/geckoview-prefs.js#304
pref("media.eme.wmf.clearkey.enabled", false); // [DEFAULT]
pref("media.gmp-widevinecdm.enabled", false);
pref("media.gmp-widevinecdm.visible", false);
pref("media.gmp-widevinecdm-l1.enabled", false);
pref("media.gmp-widevinecdm-l1.visible", false);
pref("media.mediadrm-widevinecdm.visible", false); // https://searchfox.org/mozilla-central/source/mobile/android/app/geckoview-prefs.js#320

pref("browser.phoenix.core.status", "022", locked);

// 023 UPDATES

/// Browser Updates

pref("app.update.badgeWaitTime", 0); // Immediately show badge on hamburger menu when update is available
pref("app.update.notifyDuringDownload", true); // Ensure that users are notified when an update is downloaded
pref("app.update.promptWaitTime", 3600); // Decrease time between update prompts, default is very generous...
pref("browser.startup.upgradeDialog.enabled", true); // Enables showing a dialog/pop-up on major upgrades

/// Check for extension/theme updates hourly
// Default is once every 24 hours...

pref("extensions.update.interval", 3600);

/// Ensure we're always updating extensions by default

pref("extensions.systemAddon.update.enabled", true); // [DEFAULT]
pref("extensions.update.autoUpdateDefault", true); // [HIDDEN]
pref("extensions.update.enabled", true); // [DEFAULT]
pref("media.gmp-manager.updateEnabled", true);

/// Ensure we always notify users for extension updates by default
// https://searchfox.org/mozilla-central/source/remote/shared/RecommendedPreferences.sys.mjs#253

pref("extensions.update.notifyUser", true); // [HIDDEN]

pref("browser.phoenix.core.status", "023", locked);

// 024 DEBUGGING

// Allow Remote debugging, as it can be useful (especially on Android) - but ONLY per-session

pref("devtools.debugger.remote-enabled", false, sticky); // [DEFAULT]

/// Enforce local debugging only

pref("devtools.debugger.force-local", true, locked); // [DEFAULT]
pref("devtools.inspector.remote", false, locked);

// Always prompt before connecting...

pref("devtools.debugger.prompt-connection", true, locked); // [DEFAULT]

/// Ensure that URLs are not being logged in Reader errors

pref("reader.errors.includeURLs", false); // [DEFAULT]

pref("browser.phoenix.core.status", "024", locked);

/// 025 MISC.

/// Block Web Notifications
/// I have yet to see a legitimate use-case for websites using push notifications...
// but I see them constantly abused for malicious purposes & spam

pref("permissions.default.desktop-notification", 2);

/// Enable Firefox's newer 'Felt privacy' design for Private Browsing & Certificate Errors

pref("browser.privatebrowsing.felt-privacy-v1", true);
pref("security.certerrors.felt-privacy-v1", true);

/// Show 'Always ask' for camera & microphone in the permissions drop-down (when that's what the user chose...)

pref("permissions.media.show_always_ask.enabled", true);

/// Disable WebVTT Testing Events
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml

pref("media.webvtt.testing.events", false); // [DEFAULT]

/// Always allow installing "incompatible" add-ons
// Especially useful on Android & Thunderbird...

pref("extensions.strictCompatibility", false);

/// Disable middle mouse clicks from pasting clipboard contents by default
// Too easy to accidentally press...

pref("middlemouse.paste", false);

/// Enable Containers & isolate permissions per container

pref("permissions.isolateBy.userContext", true);
pref("privacy.userContext.enabled", true);
pref("privacy.userContext.ui.enabled", true);

/// Prevent Firefox from automatically guessing which container to open an external link in, instead stick to the default
// This can lead to cross contamination for those who keep separate containers exclusively for specific websites.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1874599#c8

pref("browser.link.force_default_user_context_id_for_external_opens", true);

/// Never hide any extensions in about:debugging

pref("devtools.aboutdebugging.showHiddenAddons", true, locked);

/// Enable Desktop Profiles UI
// Only works on Nightly?

pref("browser.profiles.enabled", true);

/// Force pop-up windows to open in new tabs instead

pref("browser.link.open_newwindow", 3); // [DEFAULT]
pref("browser.link.open_newwindow.restriction", 0);

/// Always block pop-ups by default

pref("dom.disable_open_during_load", true); // [DEFAULT]

/// Limit what events can cause pop-ups

pref("dom.popup_allowed_events", "click dblclick");

/// Notify on Pop-up blocking by default

pref("privacy.popups.showBrowserMessage", true);

/// Prevent scripts from moving, resizing, and messing with windows

pref("dom.disable_window_flip", true); // [DEFAULT - Desktop]
pref("dom.disable_window_move_resize", true); // [DEFAULT - Android]

/// Disable annoying Web Speech API errors

pref("media.webspeech.synth.dont_notify_on_error", true); // [HIDDEN]

/// Disable weather on about:home by default

pref("browser.newtabpage.activity-stream.showWeather", false);

/// Disable Firefox "Reset/Refresh Profile" prompt
/// This could cause Phoenix users serious issues, especially those with user.js files...

pref("browser.disableResetPrompt", true, locked);

pref("browser.phoenix.core.status", "025", locked);

// 026 PERFORMANCE
// A lot of these taken from https://github.com/yokoffing/Betterfox/blob/main/Fastfox.js

pref("browser.sessionhistory.max_total_viewers", 7); // [Default = -1 (Automatic)]
pref("browser.sessionstore.max_tabs_undo", 7); // [Default = 10]
pref("content.notify.interval", 100000); // [Default = 120000] https://searchfox.org/mozilla-central/rev/c1180ea13e73eb985a49b15c0d90e977a1aa919c/modules/libpref/init/StaticPrefList.yaml#1824-1834
pref("extensions.logging.enabled", false); // [DEFAULT] https://searchfox.org/mozilla-central/source/mobile/android/app/geckoview-prefs.js#232
pref("gfx.canvas.accelerated.cache-items", 4096); // [Default = 2048]
pref("gfx.canvas.accelerated.cache-size", 512); // [Default = 256]
pref("gfx.content.skia-font-cache-size", 20); // [Default = 5]
pref("gfx.webrender.all", true);
pref("image.mem.decode_bytes_at_a_time", 32768); // [Default = 16384]
pref("image.mem.shared.unmap.min_expiration_ms", 120000); // [Default = 60000]
pref("layout.css.report_errors", false); // https://searchfox.org/mozilla-central/source/mobile/android/app/geckoview-prefs.js#299
pref("media.memory_cache_max_size", 65536); // [Default = 8192]
pref("network.dnsCacheEntries", 1000); // [Default = 400]
pref("network.dnsCacheExpiration", 3600); // [Default = 60]
pref("network.dnsCacheExpirationGracePeriod", 240); // [Default = 60]
pref("network.http.max-persistent-connections-per-proxy", 48); // [Default = 20]
pref("network.http.max-persistent-connections-per-server", 10); // [Default = 6]
pref("network.http.max-urgent-start-excessive-connections-per-host", 5); // [Default = 3]

pref("browser.phoenix.core.status", "026", locked);

// 027 SCROLLING
// Taken directly from https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js

pref("apz.overscroll.enabled", true);
pref("general.autoScroll", true);
pref("general.smoothScroll", true); // [DEFAULT]

pref("browser.phoenix.core.status", "027", locked);

// 028 Personal Touch 💜

/// Things that are  nice to have™
// Not directly privacy & security related

pref("browser.bookmarks.autoExportHTML", true);
pref("browser.bookmarks.openInTabClosesMenu", false);
pref("browser.compactmode.show", true);
pref("browser.mailto.dualPrompt", false); // Prevent prompting to use as mailto handler
pref("browser.mailto.prompt.os", false); // Prevent prompting to use as mailto handler
pref("browser.menu.showViewImageInfo", true);
pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);
pref("browser.newtabpage.activity-stream.newtabWallpapers.enabled", true);
pref("browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled", true);
pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
pref("browser.newtabpage.activity-stream.section.highlights.includeBookmarks", false);
pref("browser.newtabpage.activity-stream.section.highlights.includeDownloads", false);
pref("browser.newtabpage.activity-stream.section.highlights.includeVisited", false);
pref("browser.newtabpage.activity-stream.showRecentSaves", false);
pref("browser.preferences.experimental", true);
pref("browser.privateWindowSeparation.enabled", false);
pref("browser.search.openintab", true);
pref("browser.search.widget.inNavBar", true);
pref("browser.spin_cursor_while_busy", true);
pref("browser.tabs.loadBookmarksInTabs", true);
pref("browser.tabs.unloadTabInContextMenu", true); // Adds an 'Unload tab' option to context menu when right clicking tabs
pref("browser.toolbars.bookmarks.visibility", "always"); // Always show the Bookmarks toolbar by default
pref("browser.translations.alwaysTranslateLanguages", "bg,ca,cs,da,de,el,en,es,et,fi,fr,hr,hu,id,it,lv,lt,nl,pl,pt,ro,ru,sk,sl,sr,sv,tr,uk,vi");
pref("browser.translations.automaticallyPopup", true); // [DEFAULT]
pref("browser.translations.enable", true); // [DEFAULT]
pref("browser.translations.select.enable", true);
pref("devtools.chrome.enabled", true);
pref("devtools.command-button-measure.enabled", true);
pref("devtools.command-button-rulers.enabled", true);
pref("devtools.command-button-screenshot.enabled", true);
pref("devtools.dom.enabled", true);
pref("devtools.debugger.ui.editor-wrapping", true);
pref("devtools.webconsole.timestampMessages", true); // Enable timestamps in the web console by default
pref("findbar.highlightAll", true);
pref("full-screen-api.transition-duration.enter", "0 0"); // [Default = 200 200]
pref("full-screen-api.transition-duration.leave", "0 0"); // [Default = 200 200]
pref("full-screen-api.warning.delay", -1); // [Default = -1 (Automatic)]
pref("full-screen-api.warning.timeout", 0); // [Default = 3000]
pref("security.xfocsp.hideOpenInNewWindow", false);
pref("toolkit.cosmeticAnimations.enabled", true); // [DEFAULT, HIDDEN] Allows disabling browser animations, exposes it in the about:config https://searchfox.org/mozilla-release/source/remote/test/puppeteer/packages/browsers/src/browser-data/firefox.ts#389
pref("ui.prefersReducedMotion", 0); // [DEFAULT, HIDDEN] Allows disabling certain UI animations, exposes it in the about:config https://searchfox.org/mozilla-release/source/browser/tools/mozscreenshots/mozscreenshots/extension/TestRunner.sys.mjs#122
pref("view_source.wrap_long_lines", true); // [DEFAULT]

pref("browser.phoenix.core.status", "028", locked);

// 029 Sync more prefs
// Note that for this to work, the below prefs must be set on BOTH the device you are syncing from & to...
// Useful especially if you override our defaults

pref("services.sync.prefs.sync.browser.aboutConfig.showWarning", true);
pref("services.sync.prefs.sync.browser.bookmarks.autoExportHTML", true);
pref("services.sync.prefs.sync.browser.bookmarks.openInTabClosesMenu", true);
pref("services.sync.prefs.sync.browser.compactmode.show", true);
pref("services.sync.prefs.sync.browser.mailto.dualPrompt", true);
pref("services.sync.prefs.sync.browser.mailto.prompt.os", true);
pref("services.sync.prefs.sync.browser.meta_refresh_when_inactive.disabled", true);
pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.discoverystream.recentSaves.enabled", true);
pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.feeds.places", true);
pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", true);
pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.newtabWallpapers.enabled", true);
pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled", true);
pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.showRecentSaves", true);
pref("services.sync.prefs.sync.browser.preferences.experimental", true);
pref("services.sync.prefs.sync.browser.privateWindowSeparation.enabled", true);
pref("services.sync.prefs.sync.browser.search.openintab", true);
pref("services.sync.prefs.sync.browser.spin_cursor_while_busy", true);
pref("services.sync.prefs.sync.browser.tabs.loadBookmarksInTabs", true);
pref("services.sync.prefs.sync.browser.translations.alwaysTranslateLanguages", true);
pref("services.sync.prefs.sync.browser.translations.automaticallyPopup", true);
pref("services.sync.prefs.sync.browser.translations.enable", true);
pref("services.sync.prefs.sync.browser.translations.newSettingsUI.enable", true);
pref("services.sync.prefs.sync.browser.translations.select.enable", true);
pref("services.sync.prefs.sync.browser.urlbar.openintab", true);
pref("services.sync.prefs.sync.devtools.chrome.enabled", true);
pref("services.sync.prefs.sync.devtools.command-button-measure.enabled", true);
pref("services.sync.prefs.sync.devtools.command-button-rulers.enabled", true);
pref("services.sync.prefs.sync.devtools.command-button-screenshot.enabled", true);
pref("services.sync.prefs.sync.devtools.debugger.ui.editor-wrapping", true);
pref("services.sync.prefs.sync.devtools.dom.enabled", true);
pref("services.sync.prefs.sync.findbar.highlightAll", true);
pref("services.sync.prefs.sync.full-screen-api.transition-duration.enter", true);
pref("services.sync.prefs.sync.full-screen-api.transition-duration.leave", true);
pref("services.sync.prefs.sync.full-screen-api.warning.delay", true);
pref("services.sync.prefs.sync.full-screen-api.warning.timeout", true);
pref("services.sync.prefs.sync.security.xfocsp.hideOpenInNewWindow", true);
pref("services.sync.prefs.sync.toolkit.legacyUserProfileCustomizations.stylesheets", true);
pref("services.sync.prefs.sync.view_source.wrap_long_lines", true);
pref("services.sync.prefs.sync.media.autoplay.blocking_policy", true);
pref("services.sync.prefs.sync.media.gmp-gmpopenh264.enabled", true);
pref("services.sync.prefs.sync.media.gmp-gmpopenh264.provider.enabled", true);
pref("services.sync.prefs.sync.media.gmp-gmpopenh264.visible", true);
pref("services.sync.prefs.sync.media.gmp-provider.enabled", true);
pref("services.sync.prefs.sync.general.warnOnAboutConfig", true);
pref("services.sync.prefs.sync.extensions.webextensions.restrictedDomains", true);
pref("services.sync.prefs.sync.app.releaseNotesURL", true);
pref("services.sync.prefs.sync.app.releaseNotesURL.aboutDialog", true);
pref("services.sync.prefs.sync.app.releaseNotesURL.prompt", true);
pref("services.sync.prefs.sync.extensions.getAddons.search.browseURL", true);
pref("services.sync.prefs.sync.browser.firefox-view.search.enabled", true);
pref("services.sync.prefs.sync.browser.firefox-view.virtual-list.enabled", true);
pref("services.sync.prefs.sync.browser.tabs.firefox-view-newIcon", true);
pref("services.sync.prefs.sync.browser.tabs.firefox-view-next", true);
pref("services.sync.prefs.sync.browser.urlbar.update2.engineAliasRefresh", true);
pref("services.sync.prefs.sync.browser.search.separatePrivateDefault.ui.enabled", true);
pref("services.sync.prefs.sync.browser.search.separatePrivateDefault.urlbarResult.enabled", true);
pref("services.sync.prefs.sync.network.IDN_show_punycode", true);
pref("services.sync.prefs.sync.browser.urlbar.clipboard.featureGate", true);
pref("services.sync.prefs.sync.browser.urlbar.suggest.calculator", true);
pref("services.sync.prefs.sync.browser.urlbar.suggest.clipboard", true);
pref("services.sync.prefs.sync.browser.urlbar.unitConversion.enabled", true);
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
pref("services.sync.prefs.sync.permissions.default.camera", true);
pref("services.sync.prefs.sync.permissions.default.geo", true);
pref("services.sync.prefs.sync.permissions.default.microphone", true);
pref("services.sync.prefs.sync.geo.provider.network.url", true);
pref("services.sync.prefs.sync.geo.provider.use_corelocation", true);
pref("services.sync.prefs.sync.geo.provider.use_geoclue", true);
pref("services.sync.prefs.sync.geo.provider.ms-windows-location", true);
pref("services.sync.prefs.sync.browser.geolocation.warning.infoURL", true);
pref("services.sync.prefs.sync.privacy.webrtc.globalMuteToggles", true);
pref("services.sync.prefs.sync.browser.cache.disk.enable", true);
pref("services.sync.prefs.sync.browser.cache.disk_cache_ssl", true);
pref("services.sync.prefs.sync.browser.cache.memory.enable", true);
pref("services.sync.prefs.sync.browser.cache.memory.capacity", true);
pref("services.sync.prefs.sync.privacy.clearHistory.historyFormDataAndDownloads", true);
pref("services.sync.prefs.sync.privacy.clearSiteData.historyFormDataAndDownloads", true);
pref("services.sync.prefs.sync.privacy.sanitize.timeSpan", true);
pref("services.sync.prefs.sync.browser.privatebrowsing.resetPBM.enabled", true);
pref("services.sync.prefs.sync.extensions.quarantineIgnoredByUser.{b86e4813-687a-43e6-ab65-0bde4ab75758}", true);
pref("services.sync.prefs.sync.extensions.quarantineIgnoredByUser.{d19a89b9-76c1-4a61-bcd4-49e8de916403}", true);
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
pref("services.sync.prefs.sync.layout.forms.reveal-password-context-menu.enabled", true);
pref("services.sync.prefs.sync.signon.management.page.vulnerable-passwords.enabled", true);
pref("services.sync.prefs.sync.network.negotiate-auth.trusted-uris", true);
pref("services.sync.prefs.sync.cookiebanners.service.mode", true);
pref("services.sync.prefs.sync.cookiebanners.service.mode.privateBrowsing", true);
pref("services.sync.prefs.sync.cookiebanners.service.enableGlobalRules", true);
pref("services.sync.prefs.sync.cookiebanners.ui.desktop.enabled", true);
pref("services.sync.prefs.sync.userContent.player.click_to_play", true);
pref("services.sync.prefs.sync.app.update.badgeWaitTime", true);
pref("services.sync.prefs.sync.app.update.notifyDuringDownload", true);
pref("services.sync.prefs.sync.app.update.promptWaitTime", 3600);
pref("services.sync.prefs.sync.privacy.userContext.ui.enabled", true);
pref("services.sync.prefs.sync.browser.profiles.enabled", true);
pref("services.sync.prefs.sync.privacy.popups.showBrowserMessage", true);
pref("services.sync.prefs.sync.browser.cache.disk.metadata_memory_limit", true);
pref("services.sync.prefs.sync.browser.cache.jsbc_compression_level", true);
pref("services.sync.prefs.sync.browser.sessionstore.interval", true);
pref("services.sync.prefs.sync.browser.sessionstore.max_tabs_undo", true);
pref("services.sync.prefs.sync.browser.sessionhistory.max_total_viewers", true);
pref("services.sync.prefs.sync.browser.tabs.min_inactive_duration_before_unload", true);
pref("services.sync.prefs.sync.browser.toolbars.bookmarks.visibility", true);
pref("services.sync.prefs.sync.content.notify.interval", true);
pref("services.sync.prefs.sync.dom.security.https_only_mode_send_http_background_request", true);
pref("services.sync.prefs.sync.extensions.logging.enabled", true);
pref("services.sync.prefs.sync.general.smoothScroll.currentVelocityWeighting", true);
pref("services.sync.prefs.sync.general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", true);
pref("services.sync.prefs.sync.general.smoothScroll.msdPhysics.enabled", true);
pref("services.sync.prefs.sync.general.smoothScroll.msdPhysics.motionBeginSpringConstant", true);
pref("services.sync.prefs.sync.general.smoothScroll.msdPhysics.regularSpringConstant", true);
pref("services.sync.prefs.sync.general.smoothScroll.msdPhysics.slowdownMinDeltaMS", true);
pref("services.sync.prefs.sync.general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", true);
pref("services.sync.prefs.sync.general.smoothScroll.msdPhysics.slowdownSpringConstant", true);
pref("services.sync.prefs.sync.general.smoothScroll.stopDecelerationWeighting", true);
pref("services.sync.prefs.sync.gfx.canvas.accelerated.cache-items", true);
pref("services.sync.prefs.sync.gfx.canvas.accelerated.cache-size", true);
pref("services.sync.prefs.sync.gfx.content.skia-font-cache-size", true);
pref("services.sync.prefs.sync.gfx.webrender.all", true);
pref("services.sync.prefs.sync.gfx.webrender.compositor", true);
pref("services.sync.prefs.sync.image.mem.decode_bytes_at_a_time", true);
pref("services.sync.prefs.sync.image.mem.shared.unmap.min_expiration_ms", true);
pref("services.sync.prefs.sync.javascript.options.wasm", true);
pref("services.sync.prefs.sync.layout.css.grid-template-masonry-value.enabled", true);
pref("services.sync.prefs.sync.layout.css.report_errors", true);
pref("services.sync.prefs.sync.media.cache_readahead_limit", true);
pref("services.sync.prefs.sync.media.cache_resume_threshold", true);
pref("services.sync.prefs.sync.media.ffmpeg.vaapi.enabled", true);
pref("services.sync.prefs.sync.media.memory_cache_max_size", true);
pref("services.sync.prefs.sync.media.peerconnection.ice.default_address_only", true);
pref("services.sync.prefs.sync.media.peerconnection.ice.no_host", true);
pref("services.sync.prefs.sync.mousewheel.default.delta_multiplier_y", true);
pref("services.sync.prefs.sync.network.buffer.cache.count", true);
pref("services.sync.prefs.sync.network.buffer.cache.size", true);
pref("services.sync.prefs.sync.network.dnsCacheEntries", true);
pref("services.sync.prefs.sync.network.dnsCacheExpiration", true);
pref("services.sync.prefs.sync.network.dnsCacheExpirationGracePeriod", true);
pref("services.sync.prefs.sync.network.http.max-connections", true);
pref("services.sync.prefs.sync.network.http.max-persistent-connections-per-proxy", true);
pref("services.sync.prefs.sync.network.http.max-persistent-connections-per-server", true);
pref("services.sync.prefs.sync.network.http.max-urgent-start-excessive-connections-per-host", true);
pref("services.sync.prefs.sync.network.http.referer.XOriginPolicy", true);
pref("services.sync.prefs.sync.webgl.disabled", true);

pref("browser.phoenix.core.status", "029", locked);

// 030 Specialized/Custom configs

/// Configure the behavior of remote autoconfig files (if active)

pref("autoadmin.failover_to_cached", true);
pref("autoadmin.offline_failover", true);
pref("autoadmin.refresh_interval", 60);

pref("browser.phoenix.core.status", "030", locked);

pref("browser.phoenix.core.status", "successfully applied :D", locked);

//
// This config manually enables various protections from ETP/Strict
// Useful for ex. Android & Thunderbird, where ETP Strict either isn't supported or doesn't cover the same protections.

pref("network.cookie.cookieBehavior", 5);
pref("network.cookie.cookieBehavior.optInPartitioning", true);
pref("network.cookie.cookieBehavior.optInPartitioning.pbmode", true);
pref("network.cookie.cookieBehavior.pbmode", 5);
pref("network.cookie.cookieBehavior.trackerCookieBlocking", true);
pref("network.http.referer.disallowCrossSiteRelaxingDefault", true);
pref("network.http.referer.disallowCrossSiteRelaxingDefault.pbmode", true);
pref("network.http.referer.disallowCrossSiteRelaxingDefault.pbmode.top_navigation", true);
pref("network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation", true);
pref("privacy.bounceTrackingProtection.enabled", true);
pref("privacy.bounceTrackingProtection.mode", 1); // Fully enables Bounce Tracking Protection - https://searchfox.org/mozilla-central/source/toolkit/components/antitracking/bouncetrackingprotection/nsIBounceTrackingProtection.idl#11
pref("privacy.fingerprintingProtection", true);
pref("privacy.fingerprintingProtection.pbmode", true);
pref("privacy.partition.always_partition_third_party_non_cookie_storage", true);
pref("privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage", false);
pref("privacy.partition.bloburl_per_partition_key", true);
pref("privacy.partition.network_state.ocsp_cache", true);
pref("privacy.partition.network_state.ocsp_cache.pbmode", true);
pref("privacy.query_stripping.enabled", true);
pref("privacy.query_stripping.enabled.pbmode", true);
pref("privacy.socialtracking.block_cookies.enabled", true);
pref("privacy.trackingprotection.cryptomining.enabled", true);
pref("privacy.trackingprotection.emailtracking.enabled", true);
pref("privacy.trackingprotection.emailtracking.pbmode.enabled", true);
pref("privacy.trackingprotection.enabled", true);
pref("privacy.trackingprotection.fingerprinting.enabled", true);
pref("privacy.trackingprotection.pbmode.enabled", true);
pref("privacy.trackingprotection.socialtracking.enabled", true);

pref("browser.phoenix.etp-strict.status", "successfully applied :D", locked);

//

// This file contains preferences specific to Phoenix on Android.

// 001 MOZILLA CRAP™

/// Remove Mozilla URL tracking params

pref("extensions.getAddons.search.browseURL", "https://addons.mozilla.org/%LOCALE%/android/search?q=%TERMS%");

pref("browser.phoenix.android.status", "001", locked);

// 002 SAFE BROWSING

/// Enable Safe Browsing by default

pref("browser.safebrowsing.features.malware.update", true); // [DEFAULT]
pref("browser.safebrowsing.features.phishing.update", true); // [DEFAULT]

pref("browser.phoenix.android.status", "002", locked);

// 003 EXTENSIONS

/// Only allow signed extensions

pref("xpinstall.signatures.required", true); // [DEFAULT]

pref("browser.phoenix.android.status", "003", locked);

// 004 FINGERPRINTING PROTECTION

/// Harden FPP (which we already enable above) to match RFP with a few exceptions...
// As explained here: https://codeberg.org/celenity/Phoenix/issues/46
// https://discuss.privacyguides.net/t/does-partial-resistfingerprinting-make-any-sense/18827/4
// List of targets: https://searchfox.org/mozilla-central/source/toolkit/components/resistfingerprinting/RFPTargets.inc
// Easily build your own (global) override list: https://raw.githack.com/rindeal/Firefox-FPP-Override-List-Editor/master/FirefoxFPPOverrideListEditor.html

pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt,-CSSPrefersColorScheme,-FrameRate,-JSDateTimeUTC");

/// Enable dynamic rounding of content dimensions
// https://bugzilla.mozilla.org/show_bug.cgi?id=1407366

pref("privacy.resistFingerprinting.letterboxing", true); // [HIDDEN]

pref("browser.phoenix.android.status", "004", locked);

// 005 MISC. SECURITY

// Always warn users before launching other apps...

pref("network.protocol-handler.warn-external.file", true);
pref("network.protocol-handler.warn-external.sms", true);
pref("network.protocol-handler.warn-external.tel", true);
pref("network.protocol-handler.warn-external.vnd.youtube", true);

pref("browser.phoenix.android.status", "005", locked);

pref("browser.phoenix.android.status", "successfully applied :D", locked);

//

// This file contains preferences shared across Phoenix 'Extended' configs.

// 001 ADVANCED FINGERPRINTING PROTECTION

/// Disable WebGL
// https://blog.browserscan.net/docs/webgl-fingerprinting
// https://security.stackexchange.com/questions/13799/is-webgl-a-security-concern

pref("webgl.disabled", true);

pref("browser.phoenix.extended.core.status", "001", locked);

// 002 WEBRTC

/// Never leak IP addresses, even in trusted scenarios
// This *will* break WebRTC

pref("media.peerconnection.ice.default_address_only", true);
pref("media.peerconnection.ice.no_host", true);

pref("browser.phoenix.extended.core.status", "002", locked);

// 003 MISC. PRIVACY

/// Disable dFPI Heuristics
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15404

pref("privacy.restrict3rdpartystorage.heuristic.opened_window_after_interaction", false);
pref("privacy.restrict3rdpartystorage.heuristic.recently_visited", false);
pref("privacy.restrict3rdpartystorage.heuristic.redirect", false); // [DEFAULT - Android]
pref("privacy.restrict3rdpartystorage.heuristic.window_open", false); // [DEFAULT - Android]

/// Only send cross-origin referers if hosts match

pref("network.http.referer.XOriginPolicy", 2);

pref("browser.phoenix.extended.core.status", "003", locked);

// 004 ATTACK SURFACE REDUCTION

/// Disable WebAssembly
// https://spectrum.ieee.org/more-worries-over-the-security-of-web-assembly

pref("javascript.options.wasm", false);

pref("browser.phoenix.extended.core.status", "004", locked);

// 005 MISC.

/// Prevent sites from automatically refreshing

pref("accessibility.blockautorefresh", true);
pref("browser.meta_refresh_when_inactive.disabled", true); // [DEFAULT - Android]

/// Stricter Autoplay Blocking

pref("media.autoplay.blocking_policy", 2); // [Default = 0]

pref("browser.phoenix.extended.core.status", "005", locked);

pref("browser.phoenix.extended.core.status", "successfully applied :D", locked);

//

// This file contains preferences specific to Phoenix (Extended) on Android.

// 001 ADVANCED FINGERPRINTING PROTECTION

/// Further harden FPP...
// As explained here: https://codeberg.org/celenity/Phoenix/issues/46
// Compared to standard, this just removes '-JSDateTimeUTC' - meaning timezone is spoofed to UTC-0...

pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CanvasImageExtractionPrompt,-CanvasExtractionBeforeUserInputIsBlocked,-CSSPrefersColorScheme,-FrameRate");

pref("browser.phoenix.extended.android.status", "001", locked);

pref("browser.phoenix.extended.android.status", "successfully applied :D", locked);

