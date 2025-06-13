//
// The Phoenix shall rise from the ashes of what fell before it.

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

// Welcome to the heart of the Phoenix.
// This file contains preferences shared across all Phoenix configs, platforms (Desktop & Android), and Dove.

pref("browser.phoenix.version", "2025.06.12.1", locked);

/* INDEX 

000: ABOUT:CONFIG
001: DATA COLLECTION
002: MOZILLA CRAP™
003: TRACKING PROTECTION
004: FINGERPRINTING PROTECTION
005: DISK AVOIDANCE
006: DOWNLOADS
007: HTTP(S)
008: IMPLICIT CONNECTIONS
009: SEARCH & URL BAR
010: DNS
011: PROXIES
012: WEBRTC
013: MEDIA
014: ATTACK SURFACE REDUCTION
015: PASSWORDS & AUTHENTICATION
016: EXTENSIONS
017: AI
018: GEOLOCATION
019: PDF.js
020: SAFE BROWSING
021: MISC. PRIVACY + SECURITY
022: MISC. PRIVACY
023: MISC. SECURITY
024: MISC.
025: DEBUGGING
026: PERFORMANCE
027: Personal Touch 💜
028: UPDATES
029: SYNC (DESKTOP ONLY)
030: SPECIALIZED/CUSTOM CONFIGS (DESKTOP ONLY)

*/

/* KEY

Unspecified = This preference should be set EVERYWHERE

[ANDROID-ONLY] = This preference should ONLY be set for Android

[NO-LINUX] = This preference should be set everywhere, EXCEPT for GNU/Linux
[NO-MAIL] = This preference should be set everywhere, EXCEPT for Thunderbird (Useful for ex. Dove)
[NO-OSX] = This preference should be set everywhere, EXCEPT for macOS
[NO-WINDOWS] = This preference should be set everywhere, EXCEPT for Windows

*/


/*** 000 ABOUT:CONFIG ***/

/// Disable annoying warnings when attempting to access the `about:config`
pref("general.warnOnAboutConfig", false);

/// Ensure that the `about:config` is always enabled
pref("general.aboutConfig.enable", true, locked); // [DEFAULT - non-Android]

/// Ensure our policies aren't overriden...
// https://searchfox.org/mozilla-central/source/toolkit/components/enterprisepolicies/EnterprisePoliciesParent.sys.mjs
pref("toolkit.policies.perUserDir", false, locked); // [HIDDEN] [DEFAULT]

pref("browser.phoenix.status", "000");

/*** 001 DATA COLLECTION ***/

// A lot of defense in depth...
// These also provide Attack Surface Reduction

/// Block domains
// Any domains listed here are redirected to `127.0.0.1`
// We'll use this primarily for Mozilla ad/telemetry domains, but we'll also use it for ads & trackers that appear on Mozilla properties and services, as well as ad/tracking/telemetry domains that appear on other default connections/services
// Ex. We use DuckDuckGo as our default search engine, so we'll nclude their analytics domains
// On IronFox, we link to our GitLab releases via the `What's New` alert, so we'll also cover their analytics domains, etc...
// But generally we'll want to keep this limited in favor of ex. uBlock Origin & other mechanisms.
pref("network.dns.localDomains", "250analytics.com,a.omappapi.com,ads.allizom.org,ads.mozilla.org,ads.nonprod.webservices.mozgcp.net,ads.prod.webservices.mozgcp.net,analytics.getpocket.com,analytics.google.com,analytics.withgoogle.com,anf1.fuzzing.mozilla.org,anonymco.com,api.divviup.org,asan-nightly-frontend-elb-1348905149.us-east-2.elb.amazonaws.com,braze.com,contile.services.mozilla.com,contile-images.services.mozilla.com,classify-client.nonprod.webservices.mozgcp.net,classify-client.prod.webservices.mozgcp.net,classify-client.services.mozilla.com,crash-reports.allizom.org,crash-reports.mozilla.com,crash-reports-xpsp2.mozilla.com,crash-stacks.mozilla.com,crash-stats.allizom.org,crash-stats.mozilla.com,crash-stats.mozilla.org,dap.services.mozilla.com,dap.nonprod.webservices.mozgcp.net,dap.prod.webservices.mozgcp.net,dap-09-3.api.divviup.org,data.mozilla.com,data-ingestion.prod.dataops.mozgcp.net,dataops.mozgcp.net,dataservices.mozgcp.net,discovery.addons.allizom.org,discovery.addons.mozilla.org,discovery.addons-dev.allizom.org,divviup.org,download-stats.mozilla.org,download-stats.r53-2.services.mozilla.com,experimenter.services.mozilla.com,experimenter.nonprod.webservices.mozgcp.net,experimenter.prod.webservices.mozgcp.net,fhr.data.mozilla.com,fhr.r53-2.services.mozilla.com,firefox-android-home-recommendations.getpocket.com,firefox-dns-perf-test.net,fuzzing.mozilla.org,google-analytics.com,google-analytics-cn.com,googleanalytics.com,googlesyndication.com,googlesyndication-cn.com,googletagmanager.com,googletagmanager-cn.com,googletagservices.com,googletagservices-cn.com,improving.duckduckgo.com,incoming.telemetry.mozilla.org,incoming.thunderbird.net,incoming-telemetry.thunderbird.net,ingestion-edge.prod.dataops.mozgcp.net,location.services.mozilla.com,locprod1-elb-eu-west-1.prod.mozaws.net,locprod2-elb-us-west-2.prod.mozaws.net,merino.nonprod.cloudops.mozgcp.net,merino.prod.cloudops.mozgcp.net,merino.services.mozilla.com,metrics-content.duckduckgo.com,mozilla-ohttp.fastly-edge.com,new-sentry.gitlab.net,nonprod.classify-client.nonprod.webservices.mozgcp.net,normandy.cdn.mozilla.net,normandy.nonprod.cloudops.mozgcp.net,normandy.prod.cloudops.mozgcp.net,normandy-cdn.services.mozilla.com,ohttp-gateway.prod.webservices.mozgcp.net,omappapi.com,pagead2.googlesyndication.com,pipeline-incoming-prod-elb-149169523.us-west-2.elb.amazonaws.com,prod.ads.prod.webservices.mozgcp.net,prod.classify-client.prod.webservices.mozgcp.net,prod.dap.prod.webservices.mozgcp.net,prod.data-ingestion.prod.dataops.mozgcp.net,prod.dataops.mozgcp.net,prod.experimenter.prod.webservices.mozgcp.net,prod.ingestion-edge.prod.dataops.mozgcp.net,prod.ohttp-gateway.prod.webservices.mozgcp.net,prod.sentry.prod.cloudops.mozgcp.net,prod-classifyclient.normandy.prod.cloudops.mozgcp.net,sdk.iad-05.braze.com,search.r53-2.services.mozilla.com,search.services.mozilla.com,self-repair.mozilla.org,self-repair.r53-2.services.mozilla.com,sentry.gitlab.net,sentry.io,sentry.nonprod.cloudops.mozgcp.net,sentry.prod.cloudops.mozgcp.net,sentry.prod.mozaws.net,sitereview.zscaler.com,snippets.allizom.org,snippets.cdn.mozilla.net,snippets.mozilla.com,snippets-prod.frankfurt.moz.works,snippets-prod.moz.works,snippets-prod.oregon-b.moz.works,snippets-stage.moz.works,snippets-stage.oregon-b.moz.works,snowplow.trx.gitlab.net,snowplowalb-1011729428.us-east-1.elb.amazonaws.com,snowplowprd.trx.gitlab.net,snowplowprdnlb-1490493263.us-east-2.elb.amazonaws.com,socorro.nonprod.webservices.mozgcp.net,socorro.prod.webservices.mozgcp.net,socorro-collector.services.mozilla.com,socorro-webapp-allizom.stage.mozaws.net,socorro-webapp.services.mozilla.com,spocs.getpocket.com,spocs.getpocket.dev,spocs.mozilla.net,ssl.google-analytics.com,ssl-google-analytics.l.google.com,stage.sentry.nonprod.cloudops.mozgcp.net,start.fedoraproject.org,start.thunderbird.net,start.ubuntu.com,start-stage.thunderbird.net,survey.mozilla.com,tagmanager.google.com,talkback.mozilla.org,talkback-public.mozilla.org,talkback-reports.mozilla.org,telemetry-coverage.mozilla.org,telemetry-coverage.r53-2.services.mozilla.com,telemetry-experiment.cdn.mozilla.net,telemetry-incoming.r53-2.services.mozilla.com,telemetry-incoming-a.r53-2.services.mozilla.com,telemetry-incoming-b.r53-2.services.mozilla.com,telemetry-prod-1054754349.us-east-1.elb.amazonaws.com,tiles-cdn.prod.ads.prod.webservices.mozgcp.net,updates.thunderbird.net,updates-stage.thunderbird.net,use-application-dns.net,vf.startpage.com,widgets.getpocket.com,www.250analytics.com,www.anonymco.com,www.google-analytics.com,www.google-analytics-cn.com,www.googleanalytics.com,www.googlesyndication.com,www.googlesyndication-cn.com,www.googletagmanager.com,www.googletagmanager-cn.com,www.googletagservices.com,www.googletagservices-cn.com,www.sentry.io,www-google-analytics.l.google.com,www-googletagmanager.l.google.com");

/// Disable Browser Usage Telemetry metrics
// https://searchfox.org/mozilla-central/source/browser/docs/BrowserUsageTelemetry.rst
// https://searchfox.org/mozilla-central/source/browser/modules/BrowserUsageTelemetry.sys.mjs
// https://searchfox.org/mozilla-central/source/toolkit/content/widgets/tabbox.js
pref("browser.engagement.ctrlTab.has-used", true, locked); // [HIDDEN - Android/Thunderbird]

/// Disable Coverage
// https://blog.mozilla.org/data/2018/08/20/effectively-measuring-search-in-firefox/
// https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/pings/CoveragePing.sys.mjs
// https://bugzilla.mozilla.org/show_bug.cgi?id=1487578
pref("toolkit.coverage.enabled", false, locked); // [DEFAULT]
pref("toolkit.coverage.endpoint.base", "", locked);
pref("toolkit.coverage.log-level", 70); // Limits logging to fatal only
pref("toolkit.coverage.opt-out", true, locked); // [HIDDEN]
pref("toolkit.telemetry.coverage.opt-out", true, locked); // [HIDDEN]

/// Disable Crash Reporting
// https://github.com/mozilla-services/socorro
// https://wiki.mozilla.org/Socorro
// https://firefox-source-docs.mozilla.org/tools/sanitizer/asan_nightly.html
// https://github.com/choller/firefox-asan-reporter
pref("asanreporter.apiurl", "", locked);
pref("asanreporter.clientid", "unknown", locked);
pref("asanreporter.loglevel", 70);
pref("breakpad.reportURL", "", locked);
pref("browser.crashReports.crashPull", false, locked); // [DEFAULT] Do not request crash reports for background processes from users https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/crash-reports-ondemand/changeset?_expected=0
pref("browser.crashReports.requestedNeverShowAgain", true, locked); // Do not request crash reports for background processes from users https://searchfox.org/mozilla-central/source/toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs
pref("toolkit.crashreporter.include_context_heap", false, locked);

/// Disable Data Reporting & Telemetry
/// We also configure "DisableTelemetry" & "ImproveSuggest" in policies on Desktop
// https://mozilla.github.io/policy-templates/#disabletelemetry 
// https://mozilla.github.io/policy-templates/#firefoxsuggest
// https://wiki.mozilla.org/QA/Telemetry
// https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html
// https://searchfox.org/mozilla-release/source/toolkit/components/glean/xpcom/FOG.cpp
// https://searchfox.org/mozilla-release/source/toolkit/components/telemetry/app/TelemetryUtils.sys.mjs
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
pref("browser.safebrowsing.features.emailtracking.datacollection.update", false, locked); // [HIDDEN] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("captchadetection.actor.enabled", false, locked); // Disable CAPTCHA Detection Pings https://searchfox.org/mozilla-central/source/toolkit/components/captchadetection
pref("captchadetection.loglevel", "Off");
pref("datareporting.dau.cachedUsageProfileID", "beefbeef-beef-beef-beef-beeefbeefbee", locked); // [HIDDEN] https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/app/ClientID.sys.mjs#44
pref("datareporting.dau.cachedUsageProfileGroupID", "b0bacafe-b0ba-cafe-b0ba-cafeb0bacafe", locked); // [HIDDEN] https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/app/ClientID.sys.mjs#44
pref("datareporting.healthreport.uploadEnabled", false, locked); // [DEFAULT - Android]
pref("datareporting.policy.dataSubmissionEnabled", false, locked);
pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true, locked);
pref("datareporting.policy.firstRunURL", "", locked);
pref("datareporting.usage.uploadEnabled", false, locked); // [HIDDEN - ANDROID] [DEFAULT - Android] Disables "daily usage pings" https://support.mozilla.org/kb/usage-ping-settings
pref("dom.security.unexpected_system_load_telemetry_enabled", false, locked); // [DEFAULT - non-Nightly]
pref("extensions.dataCollectionPermissions.enabled", false, locked); // [NIGHTLY] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/locales-preview/dataCollectionPermissions.ftl
pref("network.jar.record_failure_reason", false, locked); // [DEFAULT - non-Nightly] https://searchfox.org/mozilla-release/source/modules/libpref/init/StaticPrefList.yaml#14397
pref("network.traffic_analyzer.enabled", false, locked); // https://searchfox.org/mozilla-release/source/modules/libpref/init/StaticPrefList.yaml#13191
pref("network.trr.confirmation_telemetry_enabled", false, locked);
pref("nimbus.telemetry.targetingContextEnabled", false, locked); // [HIDDEN - ANDROID/THUNDERBIRD] [DEFAULT - Artifact builds] Targeting context telemetry - https://searchfox.org/mozilla-central/rev/f1e32fa7/browser/app/profile/firefox.js#2040
pref("privacy.imageInputTelemetry.enableTestMode", false, locked); // [HIDDEN] "Event Telemetry" https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15549
pref("privacy.trackingprotection.emailtracking.data_collection.enabled", false, locked);
pref("telemetry.fog.test.activity_limit", -1, locked); // Disable activity-based ping submission - ex. https://mozilla.github.io/glean/book/user/pings/baseline.html#scheduling
pref("telemetry.fog.test.inactivity_limit", -1, locked); // Disable inactivity-based ping submission - ex. https://mozilla.github.io/glean/book/user/pings/baseline.html#scheduling
pref("telemetry.fog.init_on_shutdown", false, locked); // Prevent Glean from initializing on shutdown https://searchfox.org/mozilla-central/source/toolkit/components/glean/docs/dev/preferences.md#49
pref("telemetry.fog.test.localhost_port", 70000, locked); // Force telemetry pings to be sent to localhost instead of Mozilla's servers, if they're somehow enabled... (port just has to be higher than 0, I chose 70000 as its invalid) - https://searchfox.org/mozilla-central/source/toolkit/components/glean/docs/dev/preferences.md#15
pref("telemetry.glean.internal.finalInactive", false, locked); // [DEFAULT] [HIDDEN] Disable early shutdown pings https://searchfox.org/mozilla-central/source/toolkit/components/glean/xpcom/FOG.cpp
pref("telemetry.glean.internal.maxPingsPerMinute", 0, locked); // [HIDDEN] Prevent Glean from sending pings https://searchfox.org/mozilla-central/source/toolkit/components/glean/xpcom/FOG.cpp
pref("telemetry.number_of_site_origin.min_interval", 999999999, locked);
pref("toolkit.content-background-hang-monitor.disabled", true, locked); // BHR https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#16720
pref("toolkit.telemetry.archive.enabled", false, locked); // [HIDDEN - Android]
pref("toolkit.telemetry.bhrPing.enabled", false, locked); // [HIDDEN - Android]
pref("toolkit.telemetry.cachedClientID", "c0ffeec0-ffee-c0ff-eec0-ffeec0ffeec0", locked); // [HIDDEN]
pref("toolkit.telemetry.cachedProfileGroupID", "decafdec-afde-cafd-ecaf-decafdecafde", locked); // [HIDDEN]
pref("toolkit.telemetry.collectInterval", 999999999, locked); // [HIDDEN]
pref("toolkit.telemetry.dap.helper.hpke", "", locked);
pref("toolkit.telemetry.dap.helper.url", "", locked);
pref("toolkit.telemetry.dap.leader.hpke", "", locked);
pref("toolkit.telemetry.dap.leader.url", "", locked);
pref("toolkit.telemetry.dap.logLevel", "Off");
pref("toolkit.telemetry.dap_enabled", false, locked); // [DEFAULT]
pref("toolkit.telemetry.dap_task1_enabled", false, locked); // [DEFAULT]
pref("toolkit.telemetry.dap_task1_taskid", "", locked); // [DEFAULT]
pref("toolkit.telemetry.dap_visit_counting_enabled", false, locked); // [DEFAULT]
pref("toolkit.telemetry.dap_visit_counting_experiment_list", "[]", locked); // [DEFAULT]
pref("toolkit.telemetry.debugSlowSql", false); // [DEFAULT]
pref("toolkit.telemetry.enabled", false, locked);  // [DEFAULT - non-Nightly]
pref("toolkit.telemetry.eventping.maximumFrequency", 999999999, locked); // [HIDDEN] Disable `event` pings
pref("toolkit.telemetry.eventping.minimumFrequency", 999999999, locked); // [HIDDEN] Disable `event` pings
pref("toolkit.telemetry.firstShutdownPing.enabled", false, locked); // [HIDDEN - Android]
pref("toolkit.telemetry.healthping.enabled", false, locked); // [HIDDEN]
pref("toolkit.telemetry.eventping.maximumFrequency", 999999999, locked); // [HIDDEN]
pref("toolkit.telemetry.eventping.minimumFrequency", 999999999, locked); // [HIDDEN]
pref("toolkit.telemetry.initDelay", 999999999, locked); // [HIDDEN] Prevent the Telemetry component from initializing
pref("toolkit.telemetry.log.dump", false); // [HIDDEN] [DEFAULT] - To expose via the `about:config`
pref("toolkit.telemetry.log.level", "Fatal"); // [HIDDEN] [Default: Warn]
pref("toolkit.telemetry.minSubsessionLength", 999999999, locked); // [HIDDEN]
pref("toolkit.telemetry.newProfilePing.delay", 999999999, locked); // [HIDDEN]
pref("toolkit.telemetry.newProfilePing.enabled", false, locked); // [HIDDEN - Android]
pref("toolkit.telemetry.overrideUpdateChannel", "release", locked); // [HIDDEN] [DEFENSE IN DEPTH] Always report channel as `release`, regardless of actual value https://docs.telemetry.mozilla.org/concepts/channels/channel_normalization
pref("toolkit.telemetry.previousBuildID", "", locked); // [HIDDEN]
pref("toolkit.telemetry.reportingpolicy.firstRun", false, locked); // [HIDDEN]
pref("toolkit.telemetry.scheduler.idleTickInterval", 999999999, locked); // [HIDDEN]
pref("toolkit.telemetry.scheduler.tickInterval", 999999999, locked); // [HIDDEN]
pref("toolkit.telemetry.send.overrideOfficialCheck", false, locked); // [HIDDEN] [DEFAULT] Never send pings on unofficial builds - https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html
pref("toolkit.telemetry.server", "data;", locked);
pref("toolkit.telemetry.server_owner", "", locked);
pref("toolkit.telemetry.shutdownPingSender.backgroundtask.enabled", false, locked); // [HIDDEN - Android/Thunderbird] [DEFAULT - desktop Firefox]
pref("toolkit.telemetry.shutdownPingSender.enabled", false, locked); // [HIDDEN - Android]
pref("toolkit.telemetry.shutdownPingSender.enabledFirstSession", false, locked); // [HIDDEN - Android] [DEFAULT]
pref("toolkit.telemetry.testing.disableFuzzingDelay", false, locked); // [DEFAULT] [HIDDEN] [DEFENSE IN DEPTH] Always delay sending pings between 0-1 AM
pref("toolkit.telemetry.testing.overridePreRelease", false, locked); // [HIDDEN] [DEFAULT] Never record extended/prelease data on release channels - https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html
pref("toolkit.telemetry.testing.overrideProductsCheck", false, locked); // [DEFAULT] Limit probes to only what is supported on the current product - https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html
pref("toolkit.telemetry.testing.suppressPingsender", true, locked); // [HIDDEN]
pref("toolkit.telemetry.translations.logLevel", "Off");
pref("toolkit.telemetry.unified", false, locked); // [DEFAULT - Android]
pref("toolkit.telemetry.untrustedModulesPing.frequency", 999999999, locked); // [HIDDEN]
pref("toolkit.telemetry.updatePing.enabled", false, locked); // [HIDDEN - Android]
pref("toolkit.telemetry.user_characteristics_ping.current_version", 0, locked); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.last_version_sent", 0, locked); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.logLevel", "Off");
pref("toolkit.telemetry.user_characteristics_ping.opt-out", true, locked);
pref("toolkit.telemetry.user_characteristics_ping.send-once", false, locked); // [DEFAULT]
pref("toolkit.telemetry.user_characteristics_ping.uuid", "", locked); // [DEFAULT]
pref("urlclassifier.features.emailtracking.datacollection.allowlistTables", "", locked); // https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("urlclassifier.features.emailtracking.datacollection.blocklistTables", "", locked); // https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs


/// Disable Experiments/Studies
// (Shield/Nimbus/Normandy)
// https://support.mozilla.org/kb/shield
// https://support.mozilla.org/kb/how-stop-firefox-making-automatic-connections#w_experiments-or-studies
// https://experimenter.info/
// https://wiki.mozilla.org/Firefox/Shield/Shield_Studies
// https://mozilla.github.io/normandy/
// https://wiki.mozilla.org/Advocacy/heartbeat
// resource://nimbus/ExperimentAPI.sys.mjs
// https://searchfox.org/mozilla-central/source/toolkit/components/backgroundtasks/defaults/backgroundtasks_browser.js
pref("app.normandy.run_interval_seconds", 0, locked); // [HIDDEN - Android/Thunderbird] Prevent fetching experiments - This pref is also used by Nimbus
pref("app.shield.optoutstudies.enabled", false, locked); // [HIDDEN - Android/Thunderbird]
pref("messaging-system.rsexperimentloader.collection_id", "", locked);
pref("nimbus.appId", "", locked);

pref("browser.places.interactions.log", false); // [DEFAULT] [HIDDEN] Disable logging https://searchfox.org/mozilla-central/source/browser/components/places/Interactions.sys.mjs

/// Disable OHTTP Telemetry [ANDROID-ONLY]
// https://searchfox.org/mozilla-central/source/widget/android/OhttpHelper.cpp [ANDROID-ONLY]
pref("network.ohttp.configURL", "", locked); // [ANDROID-ONLY] [NIGHTLY]
pref("network.ohttp.relayURL", "", locked); // [ANDROID-ONLY] [NIGHTLY]

/// Disable Origin Trials
// https://wiki.mozilla.org/Origin_Trials
pref("dom.origin-trials.enabled", false, locked);

/// Disable X-Frame Options Error Reporting
// https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/xfocsp-error-report-ping.html
pref("security.xfocsp.errorReporting.automatic", false, locked); // [DEFAULT]
pref("security.xfocsp.errorReporting.enabled", false, locked);

/// Prevent automatically uploading profiler data (from `about:logging`) to Mozilla
pref("toolkit.aboutLogging.uploadProfileToCloud", false); // [DEFAULT - non-Android]

/// Remove partner attribution
// These are *only* used for telemetry, and could potentially be used for fingerprinting
pref("app.distributor", "", locked); // [DEFAULT] [HIDDEN]
pref("app.distributor.channel", "", locked); // [DEFAULT] [HIDDEN]
pref("mozilla.partner.id", "", locked); // [DEFAULT] [HIDDEN]

pref("browser.phoenix.status", "001");

/*** 002 MOZILLA CRAP™ ***/

// Some of these also provide Attack Surface Reduction


/// Clear unnecessary/undesired Mozilla URLs
pref("datareporting.healthreport.infoURL", ""); // [HIDDEN - Android]
pref("extensions.getAddons.langpacks.url", ""); // [ANDROID-ONLY] Functionality isn't supported on Android, so no need to connect there - ex. https://services.addons.mozilla.org/api/v4/addons/language-tools/?app=android&type=language&appversion=138.0.1
pref("extensions.recommendations.privacyPolicyUrl", "");
pref("toolkit.crashreporter.infoURL", "");
pref("toolkit.datacollection.infoURL", "");


/// Disable add-on/feature recommendations
// https://support.mozilla.org/kb/recommendations-firefox
// https://searchfox.org/mozilla-central/source/toolkit/mozapps/extensions/content/aboutaddons.js
// https://searchfox.org/mozilla-central/source/browser/components/enterprisepolicies/Policies.sys.mjs
pref("browser.discovery.enabled", false, locked); // [HIDDEN - non-Desktop Firefox]
pref("browser.translations.panelShown", true, locked); // [HIDDEN]
pref("extensions.getAddons.browseAddons", "", locked); // [HIDDEN - non-Android]
pref("extensions.getAddons.discovery.api_url", "data;", locked);
pref("extensions.getAddons.showPane", false, locked);
pref("extensions.htmlaboutaddons.recommendations.enabled", false, locked);
pref("extensions.recommendations.hideNotice", true, locked); // [HIDDEN] "Some of these recommendations are personalized..." banner
pref("extensions.recommendations.themeRecommendationUrl", "", locked);
pref("extensions.ui.lastCategory", "addons://list/extension"); // [HIDDEN] Ensure default view of `about:addons` is always local/installed extensions
pref("extensions.webservice.discoverURL", "", locked); // [HIDDEN - non-Thunderbird]

/// Disable DoH Rollout/heuristics/steering
// This helps ensure Firefox doesn't override our/the user's DoH settings...
// https://searchfox.org/mozilla-central/source/toolkit/components/doh/DoHConfig.sys.mjs
// https://searchfox.org/mozilla-central/source/toolkit/components/doh/DoHController.sys.mjs
// https://searchfox.org/mozilla-central/source/toolkit/components/doh/DoHHeuristics.sys.mjs
// https://searchfox.org/mozilla-central/source/netwerk/docs/dns/dns-over-https-trr.md
// https://searchfox.org/mozilla-central/rev/f1e32fa7/mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntimeSettings.java#1625
pref("doh-rollout._testing", true, locked); // [HIDDEN]
pref("doh-rollout.disable-heuristics", true, locked); // [HIDDEN]
pref("doh-rollout.doneFirstRun", true, locked); // [HIDDEN]
pref("doh-rollout.doorhanger-decision", "UIDisabled", locked); // [HIDDEN]
pref("doh-rollout.enabled", false, locked); // [HIDDEN]
pref("doh-rollout.mode", 5, locked); // [HIDDEN]
pref("doh-rollout.provider-steering.enabled", false, locked); // [HIDDEN]
pref("doh-rollout.provider-steering.provider-list", "", locked); // [HIDDEN]
pref("doh-rollout.self-enabled", false, locked); // [HIDDEN]
pref("doh-rollout.skipHeuristicsCheck", true, locked); // [HIDDEN]
pref("doh-rollout.trr-selection.enabled", false, locked); // [HIDDEN]
pref("doh-rollout.trr-selection.provider-list", "", locked); // [HIDDEN]
pref("doh-rollout.uri", "", locked); // [HIDDEN]
pref("network.android_doh.autoselect_enabled", false, locked); // [DEFAULT] https://searchfox.org/mozilla-central/rev/f1e32fa7/modules/libpref/init/StaticPrefList.yaml#14585

/// Disable DoH performance measurements
// https://searchfox.org/mozilla-central/rev/3b58bde3/browser/components/BrowserGlue.sys.mjs#1196
// https://searchfox.org/mozilla-central/source/toolkit/components/doh/TRRPerformance.sys.mjs
pref("doh-rollout.trrRace.canonicalDomain", ""); // [HIDDEN] [Default = firefox-dns-perf-test.net]
pref("doh-rollout.trrRace.complete", true); // [HIDDEN]
pref("doh-rollout.trrRace.enabled", false); // [HIDDEN]
pref("doh-rollout.trrRace.popularDomains", ""); // [HIDDEN]
pref("doh-rollout.trrRace.randomSubdomainCount", 0); // [HIDDEN]

/// Disable 'Essential Domains Fallback'
// My concern here is the fact that this is fetched from Remote Settings - this could potentially be used to bypass our internal domain blocklist above + the firewall of users if they themselves choose to block specific domains for whatever reason
// I don't have a problem with this being a local dump though, as I can understand the usefulness of this (and being local would mitigate my concerns here) - but I'm not comfortable with the remote part
// This is currently unused anyways...
// https://searchfox.org/mozilla-central/source/netwerk/base/EssentialDomainsRemoteSettings.sys.mjs
// https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/moz-essential-domain-fallbacks/changeset?_expected=0
pref("network.essential_domains_fallback", false); // [DEFAULT]

/// Disable Fakespot
pref("toolkit.shopping.ohttpConfigURL", "");
pref("toolkit.shopping.ohttpRelayURL", "");



/// Disable Firefox Relay by default
pref("signon.firefoxRelay.feature", "disabled"); // [HIDDEN - Thunderbird]


/// Disable "Interest-based Content Relevance Ranking and Personalization"
// https://bugzilla.mozilla.org/show_bug.cgi?id=1886207
pref("toolkit.contentRelevancy.enabled", false, locked); // [HIDDEN - Android/Thunderbird] [DEFAULT]
pref("toolkit.contentRelevancy.ingestEnabled", false, locked); // [HIDDEN - Android/Thunderbird] [DEFAULT]
pref("toolkit.contentRelevancy.log", false); // [HIDDEN - Android/Thunderbird] [DEFAULT]

/// Disable mozAddonManager
// mozAddonManager prevents extensions from working on `addons.mozilla.org`/the specified domains
// This API also exposes a list of the user's installed add-ons to `addons.mozilla.org`/the specified domains...
// https://bugzilla.mozilla.org/show_bug.cgi?id=1952390#c4
// https://bugzilla.mozilla.org/show_bug.cgi?id=1384330
pref("extensions.webapi.testing", false); // [DEFAULT] Disables mozAddonManager on Mozilla testing domains
pref("extensions.webapi.testing.http", false); // [DEFAULT] Disables mozAddonManager on Mozilla testing domains using insecure protocols





/// Disable "Privacy-Preserving Attribution"
// https://support.mozilla.org/kb/privacy-preserving-attribution
pref("dom.origin-trials.private-attribution.state", 2, locked); // [DEFAULT]
pref("dom.private-attribution.submission.enabled", false, locked); // [DEFAULT]

/// Disable Remote Permissions
// This currently only allows overriding behavior for HTTPS-First (and only makes an exception for a testing domain...)
// We enforce HTTPS-Only Mode anyways, so this isn't relevant to us - and regardless, I don't think there should be remote/default overrides for a feature like this (or permissions in general...), best left up to the user.
// https://searchfox.org/mozilla-central/source/extensions/permissions/docs/remote.rst
// https://searchfox.org/mozilla-central/source/extensions/permissions/RemotePermissionService.sys.mjs
// https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/remote-permissions/changeset?_expected=0
// https://support.mozilla.org/kb/https-first
pref("permissions.manager.remote.enabled", false);

/// Disable Remote Settings 'Preview' Buckets
// Nice to expose via about:config
pref("services.settings.preview_enabled", false); // [HIDDEN, DEFAULT]



/// Disable the Web Compatibility Reporter
// Harmless - We just don't want to waste Mozilla's time due to our custom set-up...
// Also acts as a potential performance improvement
// https://searchfox.org/mozilla-central/source/toolkit/components/nimbus/FeatureManifest.yaml#3604
pref("extensions.webcompat-reporter.enabled", false); // [DEFAULT - non-Release/ESR]
pref("extensions.webcompat-reporter.newIssueEndpoint", "https://phoenix.celenity.dev/issues"); // Temporarily override to our URL instead of Mozilla's to work-around upstream bug - https://bugzilla.mozilla.org/show_bug.cgi?id=1963764

/// Opt out of add-on metadata updates
// Note: This prevents themes from displaying previews in `about:addons`
// https://blog.mozilla.org/addons/how-to-opt-out-of-add-on-metadata-updates/
pref("extensions.getAddons.cache.enabled", false);




/// Remove special privileges from Mozilla domains
// https://firefox-source-docs.mozilla.org/dom/ipc/process_model.html#privileged-mozilla-content
pref("browser.tabs.remote.separatePrivilegedMozillaWebContentProcess", false, locked); // [DEFAULT on Firefox Desktop]
pref("browser.tabs.remote.separatedMozillaDomains", "", locked);
pref("dom.ipc.processCount.privilegedmozilla", 0, locked);
pref("extensions.webextensions.restrictedDomains", "");
pref("permissions.manager.defaultsUrl", "", locked); // [HIDDEN - Android] [DEFAULT - Android]
pref("svg.context-properties.content.allowed-domains", "", locked); // [DEFAULT - Android/Thunderbird]

/// Remove tracking parameters from Mozilla URLs + prevent exposing locale & unnecessary information
// For info on the extension update (`extensions.update.`) URL parameters, see https://devdoc.net/web/developer.mozilla.org/en-US/docs/Install_Manifests.html & https://mozilla-balrog.readthedocs.io/en/latest/database.html
pref("app.support.baseURL", "https://support.mozilla.org/kb/");
pref("browser.backup.template.fallback-download.aurora", "https://www.mozilla.org/firefox/channel/desktop/#developer");
pref("browser.backup.template.fallback-download.beta", "https://www.mozilla.org/firefox/channel/desktop/#beta");
pref("browser.backup.template.fallback-download.esr", "https://www.mozilla.org/firefox/enterprise/#download");
pref("browser.backup.template.fallback-download.nightly", "https://www.mozilla.org/firefox/channel/desktop/#nightly");
pref("browser.backup.template.fallback-download.release", "https://www.mozilla.org/firefox/download/thanks/?s=direct");
pref("extensions.abuseReport.amoFormURL", "https://addons.mozilla.org/feedback/addon/%addonID%/");
pref("extensions.blocklist.addonItemURL", "https://addons.mozilla.org/blocked-addon/%addonID%/%addonVersion%/");
pref("extensions.getAddons.search.browseURL", "https://addons.mozilla.org/android/search?q=%TERMS%"); // [ANDROID-ONLY]
pref("extensions.update.background.url", "https://versioncheck-bg.addons.mozilla.org/update/VersionCheck.php?reqVersion=%REQ_VERSION%&id=%ITEM_ID%&version=%ITEM_VERSION%&status=%ITEM_STATUS%&appID=%APP_ID%&appVersion=%APP_VERSION%&currentAppVersion=%CURRENT_APP_VERSION%&updateType=%UPDATE_TYPE%"); // [NO-MAIL] Removes maximum app/browser version (maxAppVersion), operating system (appOS), ABI (appABI), locale (locale), and compatibility mode (compatMode)
pref("extensions.update.url", "https://versioncheck.addons.mozilla.org/update/VersionCheck.php?reqVersion=%REQ_VERSION%&id=%ITEM_ID%&version=%ITEM_VERSION%&status=%ITEM_STATUS%&appID=%APP_ID%&appVersion=%APP_VERSION%&currentAppVersion=%CURRENT_APP_VERSION%&updateType=%UPDATE_TYPE%"); // [NO-MAIL] Removes maximum app/browser version (maxAppVersion), operating system (appOS), ABI (appABI), locale (locale), and compatibility mode (compatMode)
pref("pdfjs.altTextLearnMoreUrl", "https://support.mozilla.org/kb/pdf-alt-text"); // [NO-MAIL]
pref("signon.firefoxRelay.learn_more_url", "https://support.mozilla.org/kb/relay-integration#w_frequently-asked-questions");
pref("signon.firefoxRelay.manage_url", "https://relay.firefox.com/accounts/profile/");
pref("signon.firefoxRelay.privacy_policy_url", "https://www.mozilla.org/privacy/subscription-services/");
pref("signon.firefoxRelay.terms_of_service_url", "https://www.mozilla.org/about/legal/terms/subscription-services/");

/// Skip Mozilla's `Privacy Notice` & `Terms of Use`
// https://github.com/mozilla/policy-templates/pull/1212
// https://searchfox.org/mozilla-central/source/browser/components/enterprisepolicies/Policies.sys.mjs
pref("datareporting.policy.dataSubmissionPolicyAcceptedVersion", 999, locked);
pref("datareporting.policy.dataSubmissionPolicyNotifiedTime", "999999999", locked);

pref("browser.phoenix.status", "002");

/*** 003 TRACKING PROTECTION ***/

/// Allow users to add URLs to ETP via the `about:config`
// Typically hidden, but can be useful useful, so we can expose this via the `about:config` to make it easier for users to find/add entries
// https://developer.mozilla.org/docs/Web/Privacy/Guides/Storage_Access_Policy#adding_custom_domains_to_the_tracking_protection_list
pref("urlclassifier.trackingAnnotationTable.testEntries", ""); // [HIDDEN] [DEFAULT]

/// Allow users to exclude URLs from ETP via the `about:config`
// These are typically hidden, but very useful (especially for testing/working around breakage), so we can expose this via the `about:config` to make it easier for users to find/add exclusions
pref("privacy.rejectForeign.allowList", ""); // [DEFAULT]
pref("urlclassifier.features.consentmanager.annotate.skipURLs", ""); // [HIDDEN] [DEFAULT]
pref("urlclassifier.features.cryptomining.skipURLs", ""); // [HIDDEN] [DEFAULT]
pref("urlclassifier.features.emailtracking.skipURLs", ""); // [HIDDEN] [DEFAULT]
pref("urlclassifier.features.fingerprinting.skipURLs", ""); // [HIDDEN] [DEFAULT]
pref("urlclassifier.features.socialtracking.skipURLs", ""); // [HIDDEN] [DEFAULT]
pref("urlclassifier.trackingSkipURLs", ""); // [HIDDEN] [DEFAULT]

/// Enable ETP Strict
// https://support.mozilla.org/kb/enhanced-tracking-protection-firefox-desktop?as=u#w_strict-enhanced-tracking-protection
pref("browser.contentblocking.category", "strict", locked); // [HIDDEN]

/// Manually enable ETP/Strict protections...
// These are typically configured by ETP Strict - but unfortunately Firefox doesn't set ETP Strict on the browser's first run :/
// So we need to also manually configure them. We still also use ETP Strict (not 'Custom') due to our enforcement of it, so we should be covered by Mozilla changes/updates for protections.
// Manually specifying these is also useful for cases like Android: where all protections aren't enabled with ETP Strict, and on Thunderbird: where ETP Strict doesn't exist at all...
// We're also configuring the 'CookieBehavior' & 'EnableTrackingProtection' policies on desktop.

//// Block known consent managers (CMPs)
pref("browser.safebrowsing.features.consentmanager.annotate.update", true); // [HIDDEN] [DEFAULT]
pref("privacy.trackingprotection.consentmanager.annotate_channels", true); // [DEFAULT]
pref("privacy.trackingprotection.consentmanager.skip.enabled", false); // [DEFAULT]
pref("privacy.trackingprotection.consentmanager.skip.pbmode.enabled", false);

//// Block known cryptominers
pref("privacy.trackingprotection.cryptomining.enabled", true); // [DEFAULT - non-Thunderbird]

//// Block known email trackers
pref("privacy.trackingprotection.emailtracking.enabled", true);
pref("privacy.trackingprotection.emailtracking.pbmode.enabled", true); // [DEFAULT]

//// Block known fingerprinters
pref("privacy.trackingprotection.fingerprinting.enabled", true); // [DEFAULT - non-Thunderbird]

//// Block known social trackers
pref("privacy.trackingprotection.socialtracking.enabled", true);

//// Block known trackers
pref("browser.safebrowsing.features.cryptomining.annotate.update", true); // [HIDDEN] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.features.cryptomining.update", true); // [HIDDEN - non-Android] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.features.emailtracking.update", true); // [HIDDEN] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.features.fingerprinting.annotate.update", true); // [HIDDEN] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.features.fingerprinting.update", true); // [HIDDEN - non-Android] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.features.socialtracking.annotate.update", true); // [HIDDEN] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.features.socialtracking.update", true); // [HIDDEN] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.features.trackingAnnotation.update", true); // [HIDDEN - non-Android] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.features.trackingProtection.update", true); // [HIDDEN - non-Android] [DEFAULT] https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.provider.mozilla.updateURL", "moz-sbrs:://antitracking"); // [DEFAULT - non-Thunderbird]
pref("privacy.trackingprotection.annotate_channels", true); // [DEFAULT]
pref("privacy.trackingprotection.enabled", true);
pref("privacy.trackingprotection.pbmode.enabled", true); // [DEFAULT - non-Android]

//// Block known trackers using the `strict` (Level 2) list
/// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#15192
/// https://searchfox.org/mozilla-central/source/toolkit/components/nimbus/FeatureManifest.yaml#2804
pref("privacy.annotate_channels.strict_list.enabled", true); // [DEFAULT - Android]
pref("privacy.annotate_channels.strict_list.pbmode.enabled", true); // [DEFAULT]

//// Block known tracking cookies
pref("network.cookie.cookieBehavior.trackerCookieBlocking", true); // [DEFAULT - Desktop] [HIDDEN - Android/Thunderbird]
pref("privacy.socialtracking.block_cookies.enabled", true); // [DEFAULT]

//// Enable Bounce Tracking Protection
/// https://support.mozilla.org/kb/enhanced-tracking-protection-firefox-desktop#w_bounce-tracking-protection
/// https://searchfox.org/mozilla-central/source/toolkit/components/antitracking/bouncetrackingprotection/nsIBounceTrackingProtection.idl#11
pref("privacy.bounceTrackingProtection.enabled", true); // [HIDDEN - Desktop] [DEFAULT] 
pref("privacy.bounceTrackingProtection.enableDryRunMode", false); // [HIDDEN - Desktop]
pref("privacy.bounceTrackingProtection.mode", 1); // [HIDDEN - Android/Thunderbird]

//// Enable Query Parameter Stripping
/// https://firefox-source-docs.mozilla.org/toolkit/components/antitracking/anti-tracking/query-stripping/index.html
pref("privacy.query_stripping.enabled", true);
pref("privacy.query_stripping.enabled.pbmode", true);
pref("privacy.query_stripping.redirect", true); // [DEFAULT]

//// Enable SmartBlock & UA overrides/injections
pref("extensions.webcompat.enable_shims", true); // [HIDDEN] [DEFAULT - non-Thunderbird]
pref("extensions.webcompat.perform_injections", true); // [HIDDEN] [DEFAULT - non-Thunderbird]
pref("extensions.webcompat.perform_ua_overrides", true); // [HIDDEN] [DEFAULT - non-Thunderbird]
pref("extensions.webcompat.smartblockEmbeds.enabled", true); // [HIDDEN - Android/Thunderbird] [DEFAULT - Desktop] - Enables Embeds/Placeholders to make certain resources click to load

//// Enable State Partitioning
pref("network.fetch.cache_partition_cross_origin", true); // [DEFAULT] Cross origin fetch/XHR requests
pref("privacy.partition.always_partition_third_party_non_cookie_storage", true); // [DEFAULT]
pref("privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage", false); // [DEFAULT]
pref("privacy.partition.bloburl_per_partition_key", true); // [DEFAULT]
pref("privacy.partition.network_state", true); // [DEFAULT]
pref("privacy.partition.network_state.ocsp_cache", true); // [DEFAULT]
pref("privacy.partition.network_state.ocsp_cache.pbmode", true); // [DEFAULT]
pref("privacy.partition.serviceWorkers", true); // [DEFAULT]

//// Enable Suspected Fingerprinters Protection (FPP)
/// https://support.mozilla.org/kb/firefox-protection-against-fingerprinting#w_suspected-fingerprinters
pref("privacy.fingerprintingProtection", true);
pref("privacy.fingerprintingProtection.pbmode", true); // [DEFAULT - non-Thunderbird]
pref("privacy.reduceTimerPrecision", true); // [DEFAULT]

//// Enable TCP/dFPI
/// https://support.mozilla.org/kb/introducing-total-cookie-protection-standard-mode
/// https://searchfox.org/mozilla-central/source/toolkit/components/nimbus/FeatureManifest.yaml#2828
pref("network.cookie.cookieBehavior", 5); // [DEFAULT - non-Thunderbird]
pref("network.cookie.cookieBehavior.optInPartitioning", true);
pref("network.cookie.cookieBehavior.optInPartitioning.pbmode", true);
pref("network.cookie.cookieBehavior.pbmode", 5); // [DEFAULT - non-Thunderbird]

//// Ignore less restricted referer policies (than the default)
/// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#12979
pref("network.http.referer.disallowCrossSiteRelaxingDefault", true); // [DEFAULT] - for cross-site requests
pref("network.http.referer.disallowCrossSiteRelaxingDefault.pbmode", true); // [DEFAULT] - for cross-site requests in Private Browsing
pref("network.http.referer.disallowCrossSiteRelaxingDefault.pbmode.top_navigation", true); // [DEFAULT] - for top navigations in Private Browsing
pref("network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation", true); // for top navigations

/// Lower the network priority of known trackers (if not blocked for whatever reason...)
pref("privacy.trackingprotection.lower_network_priority", true);

pref("browser.phoenix.status", "003");

/*** 004 FINGERPRINTING PROTECTION ***/

/// Always load fonts bundled with Firefox
// The default is -1 - which loads bundled fonts, EXCEPT on "low-memory" devices
// Hence, this could add extra entropy/add an extra fingerprinting vector for users on "low-memory" devices
// In general, this will ensure all users have the same standard behavior here
// https://bugzilla.mozilla.org/show_bug.cgi?id=1686274
// https://searchfox.org/mozilla-central/rev/20fc11f1/gfx/thebes/gfxFT2FontList.cpp#1615
pref("gfx.bundled-fonts.activate", 1);


/// Disable failIfMajorPerformanceCaveat in WebGL contexts
// https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/18603
pref("webgl.disable-fail-if-major-performance-caveat", true); // [DEFAULT]

/// Disable VP9 Benchmark
// This means that VP9 will always be enabled regardless of performance benchmarks (unless on a plaform where this isn't supported)
// This likely also results in a performance improvement, so that's nice
// https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/22548
pref("media.benchmark.vp9.threshold", 0);

/// Do not use the theme's toolbar color scheme for in-content pages by default
// https://searchfox.org/mozilla-central/source/toolkit/modules/LightweightThemeConsumer.sys.mjs
pref("browser.theme.unified-color-scheme", false); // [HIDDEN - non-Thunderbird] [DEFAULT - non-Thunderbird]

/// Enable canvas randomization for the browser chrome
pref("privacy.resistFingerprinting.randomization.canvas.disable_for_chrome", false); // [DEFAULT]

/// Enable fdlibm for Math.sin, Math.cos, and Math.tan
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#8720
// https://groups.google.com/a/mozilla.org/g/dev-platform/c/0dxAO-JsoXI/m/eEhjM9VsAgAJ
pref("javascript.options.use_fdlibm_for_sin_cos_tan", true); // [DEFAULT - non-Windows]

/// Enable light mode by default
// Matches with RFP & prevents exposing system theme
pref("layout.css.prefers-color-scheme.content-override", 1);

/// Ensure we use the standard Noto Color Emoji font by default (instead of ex. Samsung's if available) [ANDROID-ONLY]
// https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/43023 [ANDROID-ONLY]
pref("font.name-list.emoji", "Noto Color Emoji"); // [ANDROID-ONLY]


/// Harden FPP (which we enable at `003` in `Phoenix-Core`) to match RFP with a few exceptions...
// As explained here: https://codeberg.org/celenity/Phoenix/wiki/Android#fingerprinting [ANDROID-ONLY]
// This also improves security - Attack Surface Reduction, reduced timer precision
// List of targets: https://searchfox.org/mozilla-central/source/toolkit/components/resistfingerprinting/RFPTargets.inc
// Easily build your own (global) override list: https://raw.githack.com/rindeal/Firefox-FPP-Override-List-Editor/master/FirefoxFPPOverrideListEditor.html
pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt,-CSSPrefersColorScheme,-FrameRate,-JSDateTimeUTC"); // [ANDROID-ONLY]

/// Prevent enumeration of media devices
// Exceptions can be set via the `media.devices.enumerate.legacy.allowlist` pref
// https://bugzilla.mozilla.org/show_bug.cgi?id=1528042
pref("media.devices.enumerate.legacy.enabled", false); // [DEFAULT]

/// Prevent exposing WebGL Renderer Info
// So this is typically covered by RFP/FPP's 'WebGLRenderInfo' target, but some websites (ex. moviezapiya.fun) break when that target is set, due to the target disabling the debug renderer info (while spoofing the renderer query info to "Mozilla" for the vendor and renderer)
// So for cases like that, when the `WebGLRenderInfo` target is disabled, this will ensure the real vendor/renderer info is still not exposed (RFP/FPP's target here should still take precedent)
// Looks like this is fixed for 140, so we won't need these for long... - https://bugzilla.mozilla.org/show_bug.cgi?id=1966860
// https://searchfox.org/mozilla-central/source/dom/canvas/SanitizeRenderer.cpp
pref("webgl.enable-renderer-query", false); // Spoofs "Vendor" and "Renderer" to "Mozilla" (Like the `WebGLRenderInfo` target does)
pref("webgl.sanitize-unmasked-renderer", true); // [DEFAULT] [DEFENSE IN DEPTH]
pref("webgl.override-unmasked-renderer", "Mozilla"); // Attempts to spoof "Unmasked Renderer" Debug info to "Mozilla" (like FPP/RFP does for the WebGL renderer query), but Firefox seems to override to "Generic Renderer" anyways
pref("webgl.override-unmasked-vendor", "Mozilla"); // Spoofs "Unmasked Vendor" Debug info to "Mozilla" (like FPP/RFP does for the WebGL renderer query)

/// Prevent pre-allocating content processes
// These can cause certain values/settings to persist, even after a user changes them - which could result in leakage/fingerprinting concerns
// https://firefox-source-docs.mozilla.org/dom/ipc/process_model.html#preallocated-content
pref("dom.ipc.processPrelaunch.enabled", false); // [DEFAULT - Android]
pref("dom.ipc.processPrelaunch.fission.number", 0);

/// Prevent using system accent colors
pref("widget.non-native-theme.use-theme-accent", false); // [DEFAULT - non-Thunderbird Windows]

/// Prevent using system colors
// The `ui.use_standins_for_native_colors` pref does the same thing as the 'UseStandinsForNativeColors' RFP/FPP target (so it shouldn't interfere with FPP/RFP)
// But I also want to set this here to ensure users are protected if they disable FPP for whatever reason, or if they disable ETP/Strict for a specific site/add an exception
// https://searchfox.org/mozilla-central/rev/a589ce1e/layout/style/PreferenceSheet.cpp#69
pref("browser.display.use_system_colors", false); // [DEFAULT - non-Windows]
pref("ui.use_standins_for_native_colors", true);

/// Prompt to spoof locale to en-US
pref("privacy.spoof_english", 0); // [DEFAULT]

/// Provide example templates to make it easier for users to set custom FPP overrides if needed
pref("privacy.fingerprintingProtection.granularOverrides.0.example", '[{"firstPartyDomain":"example1.invalid","overrides":"+ProtectionIWantToEnableOnThisWebsite,-ProtectionIWantToDisableOnThisWebsite"},{"firstPartyDomain":"*","thirdPartyDomain":"example2.invalid","overrides":"+ThirdPartyDomainsAreSupportedToo"}]');
pref("privacy.fingerprintingProtection.overrides.0.example", "+ProtectionIWantToEnableGlobally,-ProtectionIWantToDisableGlobally");

/// Reset the fingerprinting randomization key daily (in addition to per-session/when the browser restarts)
// https://bugzilla.mozilla.org/show_bug.cgi?id=1816064
pref("privacy.resistFingerprinting.randomization.daily_reset.enabled", true);
pref("privacy.resistFingerprinting.randomization.daily_reset.private.enabled", true);

/// Round window sizes
pref("privacy.window.maxInnerHeight", 900); // [DEFAULT - non-Android/Thunderbird]
pref("privacy.window.maxInnerWidth", 1600);

/// Set a fixed temporary storage limit
// https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/41065
// https://bugzilla.mozilla.org/show_bug.cgi?id=1781277
pref("dom.quotaManager.temporaryStorage.fixedLimit", 52428800); // Ex. matches what Tor Browser uses & what Firefox uses by default in most cases

/// Set target video resolution to 1080p
// Default on ESR is still 480p...
pref("privacy.resistFingerprinting.target_video_res", 1080); // [DEFAULT - non-ESR]

/// Set zoom levels on a per-site basis
// Changing the zoom level globally can be fingerprintable
// Note: We also set the "SiteSpecificZoom" FPP/RFP target
pref("browser.zoom.siteSpecific", true); // [DEFAULT - non-Android]

/// So people don't freak out when they see RFP isn't enabled...
pref("privacy.resistFingerprinting.0.note", "RFP is disabled on purpose.");
pref("privacy.resistFingerprinting.1.note", "We use a hardened configuration of FPP instead.");
pref("privacy.resistFingerprinting.2.note", "Using RFP is not recommended or supported.");

/// Set FPP granular overrides (if the related target is enabled...)
// See here for details: https://codeberg.org/celenity/Phoenix/wiki/FPP-Overrides
pref("privacy.fingerprintingProtection.granularOverrides", '[{"firstPartyDomain":"google.ad","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ae","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.al","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.am","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.as","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.at","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.az","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ba","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.be","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.bf","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.bg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.bi","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.bj","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.bs","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.bt","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.by","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ca","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cat","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cd","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cf","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ch","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ci","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cl","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cn","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.ao","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.bw","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.ck","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.cr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.id","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.il","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.in","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.jp","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.ke","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.kr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.ls","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.ma","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.mz","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.nz","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.th","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.tz","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.ug","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.uk","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.uz","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.ve","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.vi","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.za","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.zm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.co.zw","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.af","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.ag","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.ar","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.au","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.bd","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.bh","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.bn","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.bo","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.br","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.bz","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.co","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.cu","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.cy","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.do","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.ec","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.eg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.et","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.fj","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.gh","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.gi","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.gt","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.hk","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.jm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.kh","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.kw","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.lb","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.ly","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.mm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.mt","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.mx","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.my","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.na","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.ng","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.ni","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.np","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.om","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.pa","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.pe","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.pg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.ph","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.pk","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.pr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.py","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.qa","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.sa","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.sb","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.sg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.sl","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.sv","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.tj","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.tr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.tw","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.ua","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.uy","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.vc","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.com.vn","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cv","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.cz","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.de","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.dj","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.dk","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.dm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.dz","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ee","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.es","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.fi","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.fm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.fr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ga","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ge","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.gg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.gl","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.gm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.gr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.gy","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.hn","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.hr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ht","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.hu","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ie","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.im","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.iq","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.is","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.it","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.je","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.jo","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.kg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ki","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.kz","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.la","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.li","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.lk","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.lt","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.lu","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.lv","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.md","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.me","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.mg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.mk","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ml","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.mn","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.mu","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.mv","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.mw","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ne","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.nl","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.no","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.nr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.nu","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.pl","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.pn","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ps","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.pt","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ro","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.rs","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ru","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.rw","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.sc","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.se","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.sh","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.si","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.sk","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.sn","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.so","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.sm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.sr","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.st","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.td","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.tg","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.tl","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.tm","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.tn","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.to","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.tt","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.vu","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"google.ws","overrides":"+CanvasRandomization,-JSDateTimeUTC"},{"firstPartyDomain":"aa.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.ae","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.ca","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.cn","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.co.jp","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.co.uk","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.co.za","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.com.au","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.com.be","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.com.br","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.com.mx","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.com.tr","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.de","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.eg","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.es","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.fr","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.ie","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.in","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.it","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.nl","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.pl","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.sa","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.se","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"amazon.sg","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"animepahe.ru","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"apple.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"apple.com.cn","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"apple.news","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt,+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"arcticfoxes.net","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"aria.im","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"bitcoinist.org","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"brave.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"bsky.app","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"cakepay.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt,-WebGLRenderInfo"},{"firstPartyDomain":"chatwave.org","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"chipotle.com","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"cinny.in","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"citybbq.com","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"cloudflare.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt,+JSDateTimeUTC"},{"firstPartyDomain":"cvs.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"discord.com","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"discord.gg","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt,+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"doordash.com","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"duesen.chat","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"element.io","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"epicgames.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"favicon.io","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt,+JSDateTimeUTC"},{"firstPartyDomain":"flieger.chat","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"g24.at","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"gemeinsam.jetzt","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"gitlab.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"gnulinux.club","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"goo.gl","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt,+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"gsi.go.jp","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"harkins.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"hot-chilli.im","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"icloud.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"icloud.com.cn","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"jerseymikes.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"kosmikdog.eu","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"kroger.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"letterboxd.com","overrides":"-ScreenRect"},{"firstPartyDomain":"medium.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"megacloud.blog","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"megacloud.store","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"moviezapiya.fun","overrides":"-WebGLRenderInfo,+JSDateTimeUTC"},{"firstPartyDomain":"mtrx.nz","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"neat.chat","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"nitro.chat","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"nope.chat","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"nperf.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"oblak.be","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"pcriot.org","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"pendora.io","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"pogo.com","thirdPartyDomain":"pogospike.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasExtractionFromThirdPartiesIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"photopea.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"pogospike.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"pornhub.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"proton.me","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"reddit.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"redditmedia.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"rezka-ua.in","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"riverside.fm","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"rollenspiel.chat","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"salespanel.io","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"socialnetwork24.com","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"southwest.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"stacksocial.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"studichat.de","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"synod.im","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"t.co","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt,+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"the-apothecary.club","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"tiktok.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"tileman.io","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt,+JSDateTimeUTC"},{"firstPartyDomain":"transfem.dev","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"unredacted.org","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"usps.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"utwente.io","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"viliusle.github.io","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"watchduty.org","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"we2.ee","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"x.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"yahoo.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"yatrix.org","overrides":"-JSDateTimeUTC"},{"firstPartyDomain":"youtu.be","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt,+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"youtube-nocookie.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"zoho.com","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"}{"firstPartyDomain":"zoho.com.au","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"zoho.eu","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"zoho.in","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"zoho.jp","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"zoho.sa","overrides":"+CanvasExtractionBeforeUserInputIsBlocked,+CanvasImageExtractionPrompt"},{"firstPartyDomain":"*","thirdPartyDomain":"apple.com","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"apple.news","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"bsky.app","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"cdn-apple.com","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"cdninstagram.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"cloudflare.com","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"discord.gg","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"*","thirdPartyDomain":"favicon.io","overrides":"+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"goo.gl","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"*","thirdPartyDomain":"googlevideo.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"*","thirdPartyDomain":"gravatar.com","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"*","thirdPartyDomain":"instagram.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"licdn.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"linkedin.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"loginwithamazon.com","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"megacloud.blog","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasExtractionFromThirdPartiesIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"*","thirdPartyDomain":"megacloud.store","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasExtractionFromThirdPartiesIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"*","thirdPartyDomain":"moviezapiya.fun","overrides":"+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"pinimg.com","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"pinterest.com","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"pornhub.com","overrides":"-CanvasExtractionBeforeUserInputIsBlocked,-CanvasExtractionFromThirdPartiesIsBlocked,-CanvasImageExtractionPrompt"},{"firstPartyDomain":"*","thirdPartyDomain":"recaptcha.net","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"recaptcha.net.cn","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"recaptcha-cn.net","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"redd.it","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"reddit.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"redditmedia.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"redditstatic.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"t.co","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"*","thirdPartyDomain":"tileman.io","overrides":"+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"tiktok.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"twitter.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"twimg.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"*","thirdPartyDomain":"vimeo.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"vimeocdn.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"x.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"youtu.be","overrides":"+CSSPrefersColorScheme,+FrameRate,+JSDateTimeUTC,+JSLocale"},{"firstPartyDomain":"*","thirdPartyDomain":"youtube.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"},{"firstPartyDomain":"*","thirdPartyDomain":"youtube-nocookie.com","overrides":"+CSSPrefersColorScheme,+JSDateTimeUTC"}]'); // [ANDROID-ONLY]

pref("browser.phoenix.status", "004");

/*** 005 DISK AVOIDANCE ***/

/// Allow permission manager to write to disk
// This is already Firefox's default - but it's hidden, so this exposes it via the `about:config`
// https://searchfox.org/mozilla-central/source/extensions/permissions/PermissionManager.cpp#758
pref("permissions.memory_only", false); // [HIDDEN] [DEFAULT]





/// Clear cache on exit by default
// We also disable disk cache entirely below...
pref("privacy.clearOnShutdown.cache", true);
pref("privacy.clearOnShutdown_v2.cache", true); // [DEFAULT - Desktop Firefox]
pref("privacy.sanitize.sanitizeOnShutdown", true);

/// Decrease the number of tabs saved in Session Store [NO-MAIL]
// Also improves performance [NO-MAIL]
// (Default = 10 for Android, 25 elsewhere) [NO-MAIL]
pref("browser.sessionstore.max_tabs_undo", 7); // [NO-MAIL]

/// Disable back/forward cache (bfcache)
// This helps ensure that sensitive data/user state is discarded as soon as possible
// https://web.dev/articles/bfcache
// https://github.com/uazo/cromite/blob/master/docs/FEATURES.md
// https://github.com/uazo/cromite/issues/1649
// https://kb.mozillazine.org/Browser.sessionhistory.max_total_viewers#Possible_values_and_their_effects
pref("browser.sessionhistory.max_total_viewers", 0); // (Default = -1 (Automatic) - which is 8 unless you're using a device with under 1GB of RAM)
pref("fission.bfcacheInParent", false);

/// Disable collection/generation of background thumbnails
// https://searchfox.org/mozilla-central/source/toolkit/components/thumbnails/PageThumbs.sys.mjs#629
pref("browser.pagethumbnails.capturing_disabled", true); // [HIDDEN]

/// Disable collection/generation of wireframes
// https://searchfox.org/mozilla-central/source/browser/components/sessionstore/PageWireframes.sys.mjs
pref("browser.history.collectWireframes", false); // [DEFAULT]

/// Disable coloring visited links
pref("layout.css.visited_links_enabled", false);




/// Disable Search & Form History
// Can be leaked to sites...
// https://blog.mindedsecurity.com/2011/10/autocompleteagain.html
pref("browser.formfill.enable", false);

/// Disable disk caching
pref("browser.cache.disk.enable", false);
pref("browser.cache.disk_cache_ssl", false);

/// Disable logging blocked domains to `about:protections`
pref("browser.contentblocking.database.enabled", false); // [DEFAULT - Android/Thunderbird]

/// Disable WebRTC history
// History will still gather when `about:webrtc` is open
// Also likely improves performance...
pref("media.aboutwebrtc.hist.enabled", false); // [DEFAULT - non-Nightly]


/// Increase the interval between between Session Store save operations
// Also improves performance
// (Default = 10000 (10 secs) for Android, 15000 (15 secs) elsewhere)
// https://searchfox.org/mozilla-central/source/toolkit/components/sessionstore/docs/utils.rst
pref("browser.sessionstore.interval", 60000); // 1 minute



/// Prevent clearing cookies by default

/// Prevent clearing passwords & site settings by default
pref("privacy.clearOnShutdown.siteSettings", false); // [HIDDEN - Android/Thunderbird] [DEFAULT]
pref("privacy.clearOnShutdown_v2.siteSettings", false); // [HIDDEN - Android/Thunderbird] [DEFAULT]



/// Prevent storing unnecessary extra session data
pref("browser.sessionstore.privacy_level", 2); // [HIDDEN - Thunderbird]

/// Prevent writing media cache (ex. for video streaming) to disk in private windows
pref("browser.privatebrowsing.forceMediaMemoryCache", true);

/// Remove cached files from browser windows opened with external applications
// https://bugzilla.mozilla.org/buglist.cgi?bug_id=302433,1738574
pref("browser.download.start_downloads_in_tmp_dir", true);
pref("browser.helperApps.deleteTempFileOnExit", true); // [DEFAULT - Thunderbird]




pref("browser.phoenix.status", "005");

/*** 006 DOWNLOADS ***/

/// Block insecure downloads
pref("dom.block_download_insecure", true); // [DEFAULT]

/// Disable extra download logging by default
// This lets us expose it in the about:config for Android/Thunderbird
pref("browser.download.loglevel", "Error"); // [DEFAULT, HIDDEN - Android/Thunderbird]

/// Notify when downloading files
pref("browser.download.alwaysOpenPanel", true); // [DEFAULT - Desktop] [HIDDEN - Android/Thunderbird]

/// Prevent adding downloads to "recent documents"...
pref("browser.download.manager.addToRecentDocs", false);

/// Prompt before downloading files
pref("browser.download.always_ask_before_handling_new_types", true);
pref("browser.download.useDownloadDir", false); // [DEFAULT - Thunderbird]

pref("browser.phoenix.status", "006");

/*** 007 HTTP(S) ***/

/// Allow users to bypass invalid certificate errors by default
// (To expose the preference via the `about:config`)
pref("security.certerror.hideAddException", false); // [DEFAULT] [HIDDEN]

/// Always preload intermediates
// https://wiki.mozilla.org/Security/CryptoEngineering/Intermediate_Preloading
pref("security.remote_settings.intermediates.enabled", true); // [DEFAULT]

/// Always warn on insecure webpages
pref("security.insecure_connection_text.enabled", true);
pref("security.insecure_connection_text.pbmode.enabled", true);
pref("security.ssl.treat_unsafe_negotiation_as_broken", true);

/// Always warn when submitting a form from HTTP to HTTPS, even on local IP addresses
pref("security.insecure_field_warning.ignore_local_ip_address", false);
pref("security.warn_submit_secure_to_insecure", true); // [DEFAULT]

/// Disable the automatic import of OS client authentication certificates
// (Ex. smart cards)
// This prevents loading Mozilla's PKCS#11 module (which then loads these certificates from the OS store).
// AFAICT this functionality is quite obscure, use is seemingly nonexistent outside of very specific environments (ex. enterprise/government).
// Those who do actually use this functionality may also not want the browser to automatically import/expose these certificates, as they have many other uses.
// These certificates can also still be imported in browser settings anyways, so those who do need to use this functionality still can that way.
// So I no reason to leave this enabled by default - disabling it reduces attack surface and gives more control to users.
// (For reference, Tor Browser also disables this)
// https://blog.mozilla.org/security/2020/04/14/expanding-client-certificates-in-firefox-75/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1637807
pref("security.osclientcerts.autoload", false); // [DEFAULT - Thunderbird]

/// Disable downgrades to insecure TLS 1.0/1.1
pref("security.tls.insecure_fallback_hosts", ""); // [DEFAULT]
pref("security.tls.version.enable-deprecated", false, locked); // [DEFAULT]

/// Disable insecure ciphers (Like Chromium & Tor Browser)
// https://gitlab.torproject.org/tpo/applications/mullvad-browser/-/issues/361#note_3089049
// https://bugzilla.mozilla.org/show_bug.cgi?id=1600437
// https://bugzilla.mozilla.org/show_bug.cgi?id=1036765
pref("security.ssl3.dhe_rsa_aes_128_sha", false); // [DEFAULT]
pref("security.ssl3.dhe_rsa_aes_256_sha", false); // [DEFAULT]
pref("security.ssl3.ecdhe_ecdsa_aes_128_sha", false); // [DEFAULT - Nightly] TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA
pref("security.ssl3.ecdhe_ecdsa_aes_256_sha", false); // [DEFAULT - Nightly] TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA

/// Disable Parental Controls
// https://searchfox.org/mozilla-central/source/toolkit/components/parentalcontrols/nsIParentalControlsService.idl
// https://searchfox.org/mozilla-central/source/netwerk/protocol/http/nsHttpHandler.cpp#547
pref("network.parental_controls_cached_state", false, locked); // [DEFAULT]

/// Disable sending background HTTP requests to websites that do not respond quickly to check if they support HTTPS
pref("dom.security.https_only_mode_send_http_background_request", false);

/// Disable third-party/OS-level root certificates
// I've been torn on how to handle this, but IMO the safest way forward is disabling this functionality in Firefox.
// This is commonly abused by malware/etc. and it's even overriden by certain software/garbage AV's...
// Ex. https://support.kaspersky.com/common/compatibility/14620#block3
// Since this is something programs actively try to override, I don't see a safe way to support this, so we'll lock it.
// We still allow users to manually import certificates into Firefox... 
// So we can ensure users are aware of certificates they add and are making this decision consciously.
pref("security.certerrors.mitm.auto_enable_enterprise_roots", false); // [ANDROID-ONLY] [DEFAULT]
pref("security.enterprise_roots.enabled", false); // [ANDROID-ONLY] [DEFAULT]

//// Ensure HTTP/3 isn't disabled when/if third-party/OS-level root certificates are found
pref("network.http.http3.disable_when_third_party_roots_found", false);

/// Disable TLS 1.3 0-RTT
// Not forward secret
// https://github.com/tlswg/tls13-spec/issues/1001
pref("network.http.http3.enable_0rtt", false); // For HTTP3 https://bugzilla.mozilla.org/show_bug.cgi?id=1689550
pref("security.tls.enable_0rtt_data", false);

/// Enable (+ enforce) Certificate Transparency
// https://wiki.mozilla.org/SecurityEngineering/Certificate_Transparency
pref("security.pki.certificate_transparency.mode", 2); // [DEFAULT - Nightly Desktop]
pref("security.pki.certificate_transparency.disable_for_hosts", ""); // [DEFAULT]
pref("security.pki.certificate_transparency.disable_for_spki_hashes", ""); // [DEFAULT]

/// Enable CRLite revocation checks & prioritize over OCSP
// https://blog.mozilla.org/security/2020/01/09/crlite-part-1-all-web-pki-revocations-compressed/
pref("security.pki.crlite_mode", 2); // [DEFAULT - Nightly]
pref("security.remote_settings.crlite_filters.enabled", true); // [DEFAULT - non-Android]

/// Enable Delegated Credentials
// https://wikipedia.org/wiki/Delegated_credential
pref("security.tls.enable_delegated_credentials", true); // [DEFAULT]

/// Enable MITM Detection
// https://github.com/arkenfox/user.js/issues/740
// https://bugzilla.mozilla.org/show_bug.cgi?id=1529643
pref("security.certerrors.mitm.priming.enabled", true); //[HIDDEN - Android/Thunderbird] [DEFAULT - non-Android/Thunderbird]
pref("security.certerrors.mitm.priming.endpoint", "https://mitmdetection.services.mozilla.com/"); //[HIDDEN - Android/Thunderbird] [DEFAULT - non-Android/Thunderbird]

/// Enable OCSP revocation checks + stapling
// (https://wikipedia.org/wiki/Online_Certificate_Status_Protocol
// https://blog.mozilla.org/security/2013/07/29/ocsp-stapling-in-firefox/
// https://blog.cloudflare.com/high-reliability-ocsp-stapling/#ocsp-must-staple
pref("security.OCSP.enabled", 1); // [DEFAULT - non-Android]
pref("security.ssl.enable_ocsp_must_staple", true); // [DEFAULT]
pref("security.ssl.enable_ocsp_stapling", true); // [DEFAULT]

/// Enable Post Quantum Key Agreement (Kyber)
pref("media.webrtc.enable_pq_dtls", true); // [DEFAULT]
pref("network.http.http3.enable_kyber", true); // [DEFAULT - non-Android]
pref("security.tls.client_hello.send_p256_keyshare", true); // [DEFAULT]
pref("security.tls.enable_kyber", true); // [DEFAULT - non-Android]

/// Enforce Strict Certificate Pinning
// https://wiki.mozilla.org/SecurityEngineering/Public_Key_Pinning#How_to_use_pinning
pref("security.cert_pinning.enforcement_level", 2);

/// Enforce TLS 1.3 downgrade protection
// https://bugzilla.mozilla.org/show_bug.cgi?id=1576790
pref("security.tls.hello_downgrade_check", true); // [DEFAULT]

/// Enforce using HTTPS as much as possible
pref("dom.securecontext.allowlist", ""); // [HIDDEN] [DEFAULT] https://searchfox.org/mozilla-central/rev/a589ce1e/dom/security/nsMixedContentBlocker.cpp#270
pref("dom.security.https_first", true);
pref("dom.security.https_first_for_custom_ports", true); // [DEFAULT] DEFENSE IN DEPTH
pref("dom.security.https_first_for_local_addresses", true);
pref("dom.security.https_first_for_unknown_suffixes", true);
pref("dom.security.https_first_pbm", true); // [DEFAULT]
pref("dom.security.https_first_schemeless", true);
pref("dom.security.https_only_mode", true);
pref("dom.security.https_only_mode.upgrade_local", true);
pref("dom.security.https_only_mode_pbm", true);
pref("security.mixed_content.block_active_content", true);
pref("security.mixed_content.block_display_content", false); // [DEFAULT] Unnecessary with the "security.mixed_content.upgrade_display_content" pref - "security.mixed_content.upgrade_display_content" tries to upgrade mixed content by default and still blocks it if fails, this pref ("security.mixed_content.block_display_content") just blocks all mixed content entirely, causing unnecessary breakage for users. https://github.com/mozilla/policy-templates/issues/1141
pref("security.mixed_content.block_object_subrequest", true);
pref("security.mixed_content.upgrade_display_content", true);
pref("security.mixed_content.upgrade_display_content.audio", true); // [DEFAULT]
pref("security.mixed_content.upgrade_display_content.image", true); // [DEFAULT]
pref("security.mixed_content.upgrade_display_content.video", true); // [DEFAULT]

/// Ensure we use the HSTS preload list
// https://searchfox.org/mozilla-central/source/remote/cdp/domains/parent/Security.sys.mjs
pref("network.stricttransportsecurity.preloadlist", true); // [DEFAULT]

/// Hard-fail OCSP revocation checks by default
// Significant security improvement
// https://github.com/arkenfox/user.js/issues/1576
pref("security.OCSP.require", true);

/// If HTTPS-Only Mode is disabled in favor of HTTPS-First, prevent automatically exempting domains (to ensure we always try HTTPS first...)
pref("dom.security.https_first_add_exception_on_failure", false);

/// Only allow certificate error exceptions per-session
pref("security.certerrors.permanentOverride", false); // [HIDDEN - Android/Thunderbird]

/// Only load secure websockets from HTTPS pages
pref("network.websocket.allowInsecureFromHTTPS", false); // [DEFAULT]

/// Require safe renegotiations
// Disables connections to servers without RFC 5746
// https://wiki.mozilla.org/Security:Renegotiation
pref("security.ssl.require_safe_negotiation", true);

/// Show detailed information on insecure warning pages
pref("browser.xul.error_pages.expert_bad_cert", true);

/// Show suggestions when an HTTPS page can not be found 
// Ex. If 'example.com' isn't secure, it may suggest 'www.example.com'
pref("dom.security.https_only_mode_error_page_user_suggestions", true);

pref("browser.phoenix.status", "007");

/*** 008 IMPLICIT CONNECTIONS ***/

/// Disable Early Hints (Like Cromite)
// https://github.com/uazo/cromite/blob/master/build/patches/Client-hints-overrides.patch
// https://developer.mozilla.org/docs/Web/HTTP/Status/103
// https://github.com/bashi/early-hints-explainer/blob/main/explainer.md
pref("network.early-hints.enabled", false);
pref("network.early-hints.over-http-v1-1.enabled", false);
pref("network.early-hints.preconnect.enabled", false);
pref("network.early-hints.preconnect.max_connections", 0);

/// Disable Network Prefetching
// https://developer.mozilla.org/docs/Glossary/Prefetch
pref("dom.prefetch_dns_for_anchor_http_document", false); // https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/42684
pref("dom.prefetch_dns_for_anchor_https_document", false); // [DEFAULT] https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/42684
pref("network.dns.disablePrefetch", true);
pref("network.dns.disablePrefetchFromHTTPS", true);
pref("network.dns.prefetch_via_proxy", false); // [DEFAULT]
pref("network.http.speculative-parallel-limit", 0); // [DEFAULT - Thunderbird]
pref("network.predictor.enable-hover-on-ssl", false); // [DEFAULT]
pref("network.predictor.enable-prefetch", false); // [DEFAULT]
pref("network.predictor.enabled", false);
pref("network.prefetch-next", false);

/// Disable Preconnect
// https://github.com/uBlockOrigin/uBlock-issues/issues/2913
// https://developer.mozilla.org/docs/Web/HTML/Attributes/rel/preconnect
pref("network.preconnect", false);



/// Prevent middle mouse clicks from pasting clipboard contents by default
// Way too easy to accidentally press...
pref("middlemouse.paste", false);

/// Prevent middle mouse clicks on new tab button opening URLs or searches from clipboard
pref("browser.tabs.searchclipboardfor.middleclick", false);
pref("middlemouse.contentLoadURL", false); // [DEFAULT]

pref("browser.phoenix.status", "008");

/*** 009 SEARCH & URL BAR ***/

/// Allow using a different search engine in normal vs. private Windows
pref("browser.search.separatePrivateDefault.ui.enabled", true);

/// Always show Punycode
// Protects against phishing & IDN Homograph Attacks
// https://wikipedia.org/wiki/IDN_homograph_attack
pref("network.IDN_show_punycode", true);


/// Disable Search Suggestions
// `browser.search.suggest.enabled` & `browser.search.suggest.enabled.private` appear to have no impact on Android & Thunderbird, but they're still defined there anyways.. so we can set them anyways
pref("browser.search.suggest.enabled", false); // [DEFAULT - Android]
pref("browser.search.suggest.enabled.private", false); // [DEFAULT]










/// Use same search engine in both normal & private browsing windows by default
// Otherwise, Firefox's default private search engine will set itself as Google, regardless of our default... :/
pref("browser.search.separatePrivateDefault", false);

pref("browser.phoenix.status", "009");

/*** 010 DNS ***/

/// Always warn before falling back from DoH to system DNS
pref("network.trr.display_fallback_warning", true);
pref("network.trr_ui.show_fallback_warning_option", true);


/// Disable DoH Connectivity Checks
pref("network.connectivity-service.DNS_HTTPS.domain", "");
pref("network.trr.confirmationNS", "skip");

/// Disable EDNS Client Subnet (ECS) to prevent leaking general location data to authoritative DNS servers...
// https://wikipedia.org/wiki/EDNS_Client_Subnet
pref("network.trr.disable-ECS", true); // [DEFAULT]

/// Disable falling back to system DNS by default
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml#13855
pref("network.trr.retry_on_recoverable_errors", true); // [DEFAULT]
pref("network.trr.strict_native_fallback", true); // https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/docs/data/environment.rst#438

/// Enable DoH without fallback & Set to Quad9 by default
pref("network.trr.default_provider_uri", "https://dns.quad9.net/dns-query");
pref("network.trr.mode", 3);

/// Enable EncryptedClientHello
// https://blog.cloudflare.com/announcing-encrypted-client-hello
pref("network.dns.echconfig.enabled", true); // [DEFAULT]
pref("network.dns.http3_echconfig.enabled", true); // [DEFAULT]

/// Enable native DNS HTTPS Lookups
pref("network.dns.native_https_query", true); // [DEFAULT]

/// Expose the DoH bootstrap pref, but don't configure by default
// This is the DNS server Firefox uses to resolve the address of your DoH server
// By default, Firefox just uses the system DNS
// This value MUST match the address of the DoH server you're using
// Ex. you could set this to "9.9.9.9" for Quad9
// We won't configure this by default to prevent unexpected breakage for users when switching DNS providers, but it's hidden - so we can at least expose it in the about:config
pref("network.trr.bootstrapAddr", ""); // [HIDDEN] [DEFAULT]

/// Fix IPv6 connectivity when DoH is enabled
// https://codeberg.org/divested/brace/pulls/5
pref("network.dns.preferIPv6", true);

/// Prevent bypassing DoH for /etc/HOSTS entries by default
// Protects against HOSTS file hijacking
// https://www.malwarebytes.com/blog/news/2016/09/hosts-file-hijacks
// https://www.microsoft.com/wdsi/threats/malware-encyclopedia-description?Name=SettingsModifier:Win32/HostsFileHijack
// https://www.microcenter.com/tech_center/article/6472/how-to-clean-the-windows-hosts-file-if-malware-has-tampered-with-it
pref("network.trr.exclude-etc-hosts", false);

/// Prevent disabling DoH from registry checks
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
pref("network.notify.checkForNRPT", false);
pref("network.notify.checkForProxies", false);

/// Prevent sending headers for DoH requests
pref("network.trr.send_accept-language_headers", false); // [DEFAULT]
pref("network.trr.send_empty_accept-encoding_headers", true); // [DEFAULT]
pref("network.trr.send_user-agent_headers", false); // [DEFAULT]

/// Temporarily exclude certain captive portal domains from DNS over HTTPS by default [ANDROID-ONLY]
// Android unfortunately doesn't currently prompt users to fallback from DNS over HTTPS when a site can't be found (like desktop does), which causes unexpected breakage for users, as it leaves them without a clear explanation of the issue and a way to add the exceptions [ANDROID-ONLY]
// I don't love the idea of doing this... so again, to clarify: these are temporary will be removed once Firefox adds the fallback UI [ANDROID-ONLY]
// Domains taken from: https://badblock.celenity.dev/#captive-whitelist [ANDROID-ONLY]
pref("network.trr.builtin-excluded-domains", "localhost,local,aainflight.com,acwifi.com,aircanadawifi.com,airtime.geemedia.com,alaskawifi.com,amtrakconnect.com,amtrakwifi.com,ana-inflight-wifi.com,app-yoda.arubathena.com,aruba.odyssys.net,arubanetworks.com,arubanetworks.com.cn,asset-acms.anuvu.cloud,auth.hpe.com,bap.aws.opennetworkexchange.net,btwifi.com,captive.o2wifi.co.uk,captive-2020.aio.cloudauth.net,captive-2022.aio.cloudauth.net,captivemgr.o2wifi.net.uk,captiveportal-login.belex.com,carnivalwifi.com,cbp-guest.cbp.dhs.gov,cdnhotspot.afd.azureedge.net,cdnhotspot.azureedge.net,central.access.network,cfr-mprtuam-01.cops.us1.pr.anuvu.cloud,checkout.aa.com,cloud.imedia.ie,connect.edge.ihg.com,connect-edge.ihg.com,connected.xfinity.com,controller.access.network,cust.blueprintrf.com,deltawifi.com,device-yoda2.arubadev.cloud.hpe.com,dlrguest-captive.disney.com,ee-wifi.ee.co.uk,etihadwi-fly.com,fedsso.yum.com,flyfi.com,freewlan.sbb.ch,gogoinair.com,gogoinflight.com,gp1.wendys.com,guestinternet.com,guestinternet.com.s3-website-us-east-1.amazonaws.com,hiltonwifi.com,hotspotportals.com,hs.imedia.ie,httpforever.com,iceportal.de,inflight.pacwisp.net,inflight-wifi.com,inflightinternet.com,internal2-public-device-nc-nlb-b71ba3c951b09682.elb.us-west-2.amazonaws.com,internal2-public-device-nlb-2e2273d4267c0682.elb.us-west-2.amazonaws.com,internetupgrade.marriott.com,kong-gtw-portal-apse2prod5-lb-1386339370.ap-southeast-2.elb.amazonaws.com,kong-gtw-portal-eu-lb-1104785228.eu-central-1.elb.amazonaws.com,kong-gtw-portal-mec1prod6-lb-2104849938.me-central-1.elb.amazonaws.com,kong-gtw-portal-production-lb-686216184.us-west-1.elb.amazonaws.com,kong-gtw-portal-use1prod2-lb-291057632.us-east-1.elb.amazonaws.com,krisworld.singaporeair.com,kw.sq.com,landing.sbb.ch,loggedin.wifigem.it,login.attwifi.com,login.cloud5.com,login.cloudi-fi.net,login.innflux.com,login.wifigem.com,login.windstream.com,login-awe-cluster.attwifi.com,login-federated.windstream.com,lounge.aa.com,lpv.attwifi.com,lufthansa-flynet.com,managedwifi.xfinity.com,massportwifi.com,marriottwifi.com,medallionclass.com,mscwifi.com,msftguest-virtual.partners.extranet.microsoft.com,mt1.datavalet.io,network-auth.com,neverssl.com,nossl.com,ofc-yoda2.arubadev.cloud.hpe.com,onboard.eurostar.com,onboard.sbb.ch,onboardicafe.com,portal.ac2.mist.com,portal.ac5.mist.com,portal.ac6.mist.com,portal.eu.mist.com,portal.gc1.mist.com,portal.gc2.mist.com,portal.gc3.mist.com,portal.mist.com,portal.moovmanage.com,qa-connect-edge.ihg.com,rcs.arubathena.com,rcs-m.arubathena.com,rcs-ng-yoda2.arubadev.cloud.hpe.com,regio-guide.de,rsc.att.com,rsc.wayport.net,rougewifi.com,sbux-j3.datavalet.io,sbux-portal.globalreachtech.com,sbux-portal.odyssys.net,secure.11os.com,secure.datavalet.io,secure.wayport.net,secure-login.attwifi.com,service.thecloud.net,shop.ba.com,singaporeair-krisworld.com,sso.wendys.com,stage.connect.edge.ihg.com,starbucks-east.datavalet.io,stay.marriottbonvoy.com,southwestwifi.com,thalysnet.com,thd.cloudauth.net,timhortonswifi.com,tvgreyhound.com,unitedprivatescreening.com,unitedwifi.com,universal-orlando.ampthink.com,viasat.com,virginwifi.com,wanderingwifi.com,we.windstream.com,weconnect.wendys.com,wifi.airasia.com,wifi.bahn.de,wifi.cathaypacific.com,wifi.delta.com,wifi.esa.com,wifi.kfc.com,wifi1.kfc.com,wifi2.kfc.com,wifi.panerabread.com,wifi.singaporeair.com,wifi.sncf,wifi.starbucks.com,wifi.tgv-lyria.com,wifi.tgvlyria.com,wifi.united.com,wifi.united.com.edgekey.net,wifi.we.co,wifi.xfinity.com,wifi-viarail.ca,wifi-xdb.boingohotspot.net,wifihotspot.io,wifilauncher.com,wifilauncher.com.s3-website.us-east-1.amazonaws.com,wifilrn-ch2-1p.xfinity.com,wifionboard.com,wirelessportal.americanexpress.com,wirelessportal.americanexpress.com.akadns.net,wirelessportal2.americanexpress.com.akadns.net,wlb1-1579773356.us-east-1.elb.amazonaws.com,yoda-cgqa.arubathena.com,yoda-cgqa-elb.arubathena.com,yoda2-ofc-nlb-f4f923213a2189c7.elb.us-west-2.amazonaws.com,yoda2-public-device-nlb-8343995ce4714f6f.elb.us-west-2.amazonaws.com,yoda2-rcs-nlb-0c9df3882f3f7416.elb.us-west-2.amazonaws.com,zugportal.de"); // [ANDROID-ONLY]

pref("browser.phoenix.status", "010");

/*** 011 PROXIES ***/

/// Prevent Firefox from automatically using the system's proxy configuration by default
// This is commonly abused by content filtering/monitoring/MITM software & malware (just like third-party/OS-level root certificates...)
// There are of course legitimate use cases for proxies, but those require manual set-up anyways... let's ensure the user is always in control and making the conscious decision to use a proxy (if at all)
// Also helps with performance as a bonus
// https://bugzilla.mozilla.org/show_bug.cgi?id=500983
// https://bugzilla.mozilla.org/show_bug.cgi?id=500983#c7
// https://superuser.com/questions/169303/why-are-my-browsers-suddenly-configured-to-use-a-proxy
pref("network.proxy.type", 0);

// Prevent bypasses/leakage

/// Always start proxy extensions (if installed) as soon as possible, instead of waiting for the first browser window to open
pref("extensions.webextensions.early_background_wakeup_on_request", true); // [HIDDEN - non-Android] [DEFAULT - Android]

/// Disable automatic failover from the proxy (if configured) to direct connections when certain system requests fail
// https://bugzilla.mozilla.org/show_bug.cgi?id=1720221
pref("network.proxy.failover_direct", false);

/// Disable file:///net
// https://bugzilla.mozilla.org/show_bug.cgi?id=1412081
pref("network.file.path_blacklist", ""); // [ANDROID-ONLY] [HIDDEN] [DEFAULT]

/// Disable GIO
// https://bugzilla.mozilla.org/1433507
pref("network.gio.supported-protocols", ""); // [HIDDEN]

/// Disable Uniform Naming Convention (UNC) file paths
// https://bugzilla.mozilla.org/1413868
pref("network.file.disable_unc_paths", true); // [HIDDEN]

/// Disable Wi-Fi Tickler
// Ex. disabled by the Proxy Bypass Protection build argument
// https://searchfox.org/mozilla-central/source/netwerk/base/Tickler.h
// https://searchfox.org/mozilla-central/source/netwerk/base/Tickler.cpp
pref("network.tickle-wifi.enabled", false); // [DEFAULT - non-Android]

/// Prevent bypassing the proxy (if configured) for system connections that include the `bypassProxy` flag
// https://bugzilla.mozilla.org/show_bug.cgi?id=1732792
pref("network.proxy.allow_bypass", false);

/// Use the proxy (if configured) for remote DNS lookups
pref("network.proxy.socks_remote_dns", true);
pref("network.proxy.socks5_remote_dns", true); // [DEFAULT]

pref("browser.phoenix.status", "011");

/*** 012 WEBRTC ***/

/// Allow user to silence notifications when screen sharing
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js#2452
pref("privacy.webrtc.allowSilencingNotifications", true); // [HIDDEN - Android/Thunderbird] [DEFAULT]
pref("privacy.webrtc.hideGlobalIndicator", false); // [HIDDEN - Android/Thunderbird] [DEFAULT]

/// Always sandbox Media Transport
// https://searchfox.org/mozilla-central/source/security/sandbox/common/SandboxSettings.cpp
pref("media.peerconnection.mtransport_process", true); // [HIDDEN - Android/Thunderbird] [DEFAULT]

/// Enable global toggles for muting the camera/microphone
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js#2452
pref("privacy.webrtc.globalMuteToggles", true); // [HIDDEN - Android]

/// Enable mDNS Host Obfuscation to prevent leaking local IP addresses
// https://bugzilla.mozilla.org/show_bug.cgi?id=1588817
pref("media.peerconnection.ice.obfuscate_host_addresses", true); // [DEFAULT - non-Android]

/// Prevent WebRTC from bypassing the proxy (if configured)
// https://bugzilla.mozilla.org/show_bug.cgi?id=1790270
pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);

/// Warn users when attempting to switch tabs in a window being shared over WebRTC
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js#2459
pref("privacy.webrtc.sharedTabWarning", true); // [HIDDEN - Android/Thunderbird]

pref("browser.phoenix.status", "012");

/*** 013 MEDIA ***/

/// Add DRM notes
pref("media.eme.enabled.3.note", "You will also need to enable the CDM."); // [ANDROID-ONLY]
pref("media.eme.enabled.4.note", "See media.mediadrm-widevinecdm.visible"); // [ANDROID-ONLY]
pref("media.gmp-widevinecdm.0.note", "See media.mediadrm-widevinecdm.visible"); // [ANDROID-ONLY]
pref("media.gmp-widevinecdm-l1.0.note", "See media.mediadrm-widevinecdm.visible"); // [ANDROID-ONLY]

/// Block media autoplay by default
// https://support.mozilla.org/kb/block-autoplay
pref("media.autoplay.default", 5);

/// Disable DRM
// Garbage technology with freedom, privacy, & security concerns
// https://www.eff.org/deeplinks/2017/10/drms-dead-canary-how-we-just-lost-web-what-we-learned-it-and-what-we-need-do-next
pref("media.clearkey.persistent-license.enabled", false); // [DEFAULT]
pref("media.clearkey.test-key-systems.enabled", false); // [DEFAULT]
pref("media.eme.enabled", false);
pref("media.eme.enabled.0.note", "DRM/EME is not recommended or supported.");
pref("media.eme.enabled.1.note", "Enabling it WILL compromise your privacy/security.");
pref("media.eme.enabled.2.note", "Proceed at your own caution.");
pref("media.eme.require-app-approval", true); // [ANDROID-ONLY] [DEFAULT] Ensure EME always requires permission (if enabled) - https://bugzilla.mozilla.org/show_bug.cgi?id=1620102 https://searchfox.org/mozilla-central/source/dom/media/eme/MediaKeySystemAccessPermissionRequest.h
pref("media.gmp-widevinecdm.enabled", false, locked); // [ANDROID-ONLY] media.mediadrm-widevinecdm.visible should be used instead - this is very broken, let's lock to avoid issues...
pref("media.gmp-widevinecdm.visible", false, locked); // [ANDROID-ONLY] media.mediadrm-widevinecdm.visible should be used instead - this is very broken, let's lock to avoid issues...
pref("media.gmp-widevinecdm-l1.enabled", false, locked); // [ANDROID-ONLY] media.mediadrm-widevinecdm.visible should be used instead - this is very broken, let's lock to avoid issues...
pref("media.gmp-widevinecdm-l1.visible", false, locked); // [ANDROID-ONLY] media.mediadrm-widevinecdm.visible should be used instead - this is very broken, let's lock to avoid issues...
pref("media.mediadrm-widevinecdm.visible", false); // [ANDROID-ONLY] Widevine MediaDrm/MediaKeySystem - https://developer.android.com/reference/android/media/MediaDrm https://bugzilla.mozilla.org/show_bug.cgi?id=1306219

/// Disable Gecko Media Plugins (GMP)
// This is currently only used for DRM & OpenH264 (both of which we disable)
// In general, I feel that these are unnecessary and best left to the operating system to support. They do also pose privacy & security concerns, so I don't see a reason to keep these enabled.
// https://wiki.mozilla.org/GeckoMediaPlugins
pref("media.gmp-provider.enabled", false);

/// Disable GMP local sources
// https://searchfox.org/mozilla-central/source/toolkit/modules/GMPUtils.sys.mjs
pref("media.gmp-manager.allowLocalSources", false);

/// Disable GMP logging by default (to expose via the `about:config`)
pref("media.gmp.log.dump", false); // [DEFAULT] [HIDDEN]
pref("media.gmp.log.level", 70); // [HIDDEN] Limits logging to fatal only

/// Disable HLS [ANDROID-ONLY]
// This uses an additional external library (ExoPlayer), and poses privacy & security concerns [ANDROID-ONLY]
// This is already the default for all platforms except Android [ANDROID-ONLY]
// https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/29859 [ANDROID-ONLY]
pref("media.hls.enabled", false); // [ANDROID-ONLY]

/// Disable OpenH264 (in favor of hardware decoding)
// Mozilla is currently shipping OpenH264 2.3.2, which is around ~2 years out of date... https://github.com/cisco/openh264/releases/tag/v2.3.1
// Currently susceptible to a high severity CVE: https://www.cve.org/CVERecord?id=CVE-2025-27091
// https://bugzilla.mozilla.org/show_bug.cgi?id=CVE-2025-27091
// Downloads are also still distributed over standard, unencrypted HTTP...
// https://searchfox.org/mozilla-central/source/toolkit/content/gmp-sources/openh264.json
pref("media.ffmpeg.allow-openh264", false); // [DEFAULT - non-Nightly]
pref("media.gmp-gmpopenh264.enabled", false);
pref("media.gmp-gmpopenh264.provider.enabled", false); // [HIDDEN]
pref("media.gmp-gmpopenh264.visible", false);
pref("media.webrtc.hw.h264.enabled", true); // [DEFAULT - Android] Enables H264 hardware decoding https://bugzilla.mozilla.org/show_bug.cgi?id=1717679




/// Validate signature when updating GMP (if enabled)
pref("media.gmp-manager.cert.checkAttributes", true); // [DEFAULT]
pref("media.gmp-manager.cert.requireBuiltIn", true); // [DEFAULT]
pref("media.gmp-manager.checkContentSignature", true); // [DEFAULT]

pref("browser.phoenix.status", "013");

/*** 014 ATTACK SURFACE REDUCTION ***/

/// Disable ASM.JS
// https://rh0dev.github.io/blog/2017/the-return-of-the-jit/
pref("javascript.options.asmjs", false);

/// Disable Graphite & SVG OpenType fonts
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=firefox+graphite
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=firefox+svg
pref("gfx.font_rendering.graphite.enabled", false);
pref("gfx.font_rendering.opentype_svg.enabled", false);

/// Disable JavaScript Just-in-time Compilation (JIT)
// https://microsoftedge.github.io/edgevr/posts/Super-Duper-Secure-Mode/
// https://firefox-source-docs.mozilla.org/js/index.html#javascript-jits
// https://codeberg.org/rusty-snake/firefox-config/src/branch/main/assets/user-overrides.js#L60
// https://codeberg.org/celenity/Phoenix/issues/93
pref("javascript.options.baselinejit", false); // Baseline Compiler
pref("javascript.options.ion", false); // WarpMonkey
pref("javascript.options.jithints", false); // Eager baseline hints https://bugzilla.mozilla.org/show_bug.cgi?id=1831572
pref("javascript.options.main_process_disable_jit", true); // [DEFAULT - iOS?] The JIT backend https://searchfox.org/mozilla-central/source/js/src/jit/JitOptions.cpp
pref("javascript.options.native_regexp", false); // irregexp https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/21865
pref("javascript.options.wasm_baselinejit", false); // WASM Baseline Compiler

/// Disable JPEG-XL
// https://github.com/mozilla/standards-positions/pull/1064
pref("image.jxl.enabled", false); // [DEFAULT]

/// Disable MathML
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=mathml 
pref("mathml.disabled", true);

/// Disable SharedArrayBuffer using window.postMessage
// https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer
// https://developer.mozilla.org/docs/Web/API/Window/postMessage
// https://blog.mozilla.org/security/2018/01/03/mitigations-landing-new-class-timing-attack/
// https://github.com/tc39/ecma262/issues/1435
// By default, Firefox restricts the use of SharedArrayBuffer - this fully disables it.
pref("dom.postMessage.sharedArrayBuffer.bypassCOOP_COEP.insecure.enabled", false); // [DEFAULT]
pref("dom.postMessage.sharedArrayBuffer.withCOOP_COEP", false); // [NO-MAIL]

/// Disable WebVR/WebXR
// https://developer.mozilla.org/docs/Web/API/WebXR_Device_API
pref("permissions.default.xr", 2); // [HIDDEN - Android/Thunderbird]

/// If JIT (Ion/WarpMonkey) is disabled, also disable it for extensions
// This is the default, but it's hidden - so setting it here lets us expose it...
// https://bugzilla.mozilla.org/show_bug.cgi?id=1599226
pref("javascript.options.jit_trustedprincipals", false);

pref("browser.phoenix.status", "014");

/*** 015 PASSWORDS & AUTHENTICATION ***/

/// Allow filling passwords on all websites, even if they try to block it...
// https://bugzilla.mozilla.org/show_bug.cgi?id=956906
// https://blog.0xbadc0de.be/archives/124
pref("signon.storeWhenAutocompleteOff", true); // [DEFAULT]

/// Always display a `reveal password` button in `password` `<input>` types 
// https://developer.mozilla.org/docs/Web/HTML/Element/input/password
pref("layout.forms.reveal-password-button.enabled", true);

/// Crash on insecure password input
pref("intl.allow-insecure-text-input", false); // [DEFAULT, HIDDEN - non-Nightly]

/// Disable Autofill
pref("signon.autofillForms", false);
pref("signon.autofillForms.http", false); // [DEFAULT]

/// Disable Basic authentication over HTTP
// This makes it require secure HTTPS
// https://chromeenterprise.google/policies/#BasicAuthOverHttpEnabled
// https://bugzilla.mozilla.org/show_bug.cgi?id=1763671
pref("network.http.basic_http_auth.enabled", false);

/// Disable formless capture of log-in credentials
// This gets very complicated very fast, and there's very little documentation on this - but TL;DR:
// Firefox's built-in password manager has historically prompted users to save passwords by detecting standard <form> elements and waiting for specific events (ex. `onsubmit`)
// The problem is that not all websites use <form> elements for password fields, meaning Firefox can't always use this standard method.
// So, in order to detect these "formless" password entries (to ask users whether they want to save the password), Firefox uses a heuristic that temporarily monitors & stores user keystrokes...
// Note that with this disabled, Firefox will still show a password icon in the URL bar that allows you to store credentials, this only impacts the actual pop-up (for sites with these "formless" password entires)
// Unfortunately, it appears that Fenix doesn't support showing a password icon in the URL bar like Firefox on desktop does - so we're going to override this (`signon.formlessCapture.enabled`) for Android (but we'll still keep formless capture disabled in private browsing with `signon.privateBrowsingCapture.enabled`, and we still disable the password manager itself by default anyways...)
// https://bugzilla.mozilla.org/show_bug.cgi?id=1119035#c2
// https://bugzilla.mozilla.org/show_bug.cgi?id=1166947
// https://bugzilla.mozilla.org/show_bug.cgi?id=1119077#c1
// https://gitlab.com/ironfox-oss/IronFox/-/issues/11 [ANDROID-ONLY]
pref("signon.privateBrowsingCapture.enabled", false);

/// Disable Microsoft SSO
// https://www.microsoft.com/security/business/identity-access/microsoft-entra-single-sign-on
// https://support.mozilla.org/kb/windows-sso
pref("network.http.microsoft-entra-sso.container-enabled.0", false);
pref("network.http.microsoft-entra-sso.enabled", false); // [DEFAULT]
pref("network.http.windows-sso.container-enabled.0", false);
pref("network.http.windows-sso.enabled", false); // [DEFAULT]
pref("network.microsoft-sso-authority-list", ""); // DEFENSE IN DEPTH

/// Disable NTLM
// https://www.silverfort.com/blog/understanding-the-security-risks-of-ntlm/
// https://htmlpreview.github.io/?https://github.com/mdn/archived-content/blob/main/files/en-us/mozilla/integrated_authentication/raw.html
// https://mozilla.github.io/policy-templates/#authentication
pref("network.auth.force-generic-ntlm", false); // [DEFAULT]
pref("network.auth.force-generic-ntlm-v1", false); // [DEFAULT]
pref("network.automatic-ntlm-auth.allow-non-fqdn", false); // [DEFAULT]
pref("network.automatic-ntlm-auth.allow-proxies", false);
pref("network.automatic-ntlm-auth.trusted-uris", ""); // [DEFAULT]

/// Disable NTLM/SPNEGO SSO in Private Browsing
// https://htmlpreview.github.io/?https://github.com/mdn/archived-content/blob/main/files/en-us/mozilla/integrated_authentication/raw.html
// https://mozilla.github.io/policy-templates/#authentication
pref("network.auth.private-browsing-sso", false); // [DEFAULT] [DEFENSE IN DEPTH]

/// Disable Password Manager by default - Insecure & unencrypted
// You should instead use a proper solution (ex. Bitwarden)
// https://www.wired.com/2016/08/browser-password-manager-probably-isnt-enough/
// https://support.mozilla.org/kb/manage-your-logins-firefox-password-manager
// https://wiki.mozilla.org/Firefox/Features/Form_Autofill
pref("extensions.formautofill.addresses.enabled", false);
pref("extensions.formautofill.creditCards.enabled", false);
pref("signon.rememberSignons", false); // [NO-MAIL]

/// Disable password truncation
// https://www.ghacks.net/2020/05/18/firefox-77-wont-truncate-text-exceeding-max-length-to-address-password-pasting-issues/
pref("editor.truncate_user_pastes", false);

/// Disable SPNEGO
// https://www.ibm.com/think/x-force/critical-remote-code-execution-vulnerability-spnego-extended-negotiation-security-mechanism
// https://htmlpreview.github.io/?https://github.com/mdn/archived-content/blob/main/files/en-us/mozilla/integrated_authentication/raw.html
// https://people.redhat.com/mikeb/negotiate/
// https://mozilla.github.io/policy-templates/#authentication
pref("network.negotiate-auth.allow-non-fqdn", false); // [DEFAULT]
pref("network.negotiate-auth.allow-proxies", false);
pref("network.negotiate-auth.delegation-uris", ""); // [DEFAULT]
pref("network.negotiate-auth.trusted-uris", ""); // [DEFAULT] Modified by ex. RedHat/Fedora


/// Enable anti-spoof confirmation prompts
pref("network.auth.confirmAuth.enabled", true);

/// Enable strong password generation (if the Password Manager is enabled) by default
pref("signon.generation.enabled", true); // [DEFAULT]

/// If the PaymentRequest API is enabled, ensure we always require user interaction...
pref("dom.payments.request.user_interaction_required", true); // [DEFAULT]

/// Prevent cross-origin sub-resources from opening HTTP authentication dialogs to protect against phishing
// (Meaning dialogs for embedded items are only presented when originating from the same site)
// https://support.mozilla.org/questions/1245144
pref("network.auth.non-web-content-triggered-resources-http-auth-allow", false); // [NO-MAIL] [DEFAULT - non-Thunderbird]
pref("network.auth.subresource-http-auth-allow", 1); // [NO-MAIL]
pref("network.auth.subresource-img-cross-origin-http-auth-allow", false); // [DEFAULT - non-Thunderbird]


pref("browser.phoenix.status", "015");

/*** 016 EXTENSIONS ***/

/// Allow enabling/disabling extensions per-container (if containers are enabled)
// This could allow for some extremely useful use-cases...
// Ex. With the Multi-Account Containers extension, you could use this to only allow certain extensions to access certain websites, regardless of the extension's permissions
pref("extensions.userContextIsolation.defaults.restricted", "[]"); // [HIDDEN] [DEFAULT]
pref("extensions.userContextIsolation.enabled", true); // [HIDDEN]

/// Allow LocalCDN (if installed) to work on restricted/quarantined domains by default
pref("extensions.quarantineIgnoredByUser.{b86e4813-687a-43e6-ab65-0bde4ab75758}", true);

/// Allow Mullvad's extension (if installed) to work on restricted/quarantined domains by default
pref("extensions.quarantineIgnoredByUser.{d19a89b9-76c1-4a61-bcd4-49e8de916403}", true);

/// Allow uBlock Origin (if installed) to work on restricted/quarantined domains by default
// This isn't necessary ATM (since uBlock Origin is 'recommended' by Mozilla - so it can already access quarantined domains), but we can still set this anyways for redundancy/to ensure we're always covered if anything changes in the future
// This is especially important for Thunderbird though - since uBlock Origin isn't 'recommended' there like it is on Firefox...
// https://support.mozilla.org/kb/quarantined-domains
pref("extensions.quarantineIgnoredByUser.uBlock0@raymondhill.net", true); // [HIDDEN]

/// Always allow installing "incompatible" add-ons
// Especially useful on Android & Thunderbird...
pref("extensions.strictCompatibility", false); // [DEFAULT - non-Thunderbird Release/Beta]

/// Always run extensions OOP (out of process...)
// https://bugzilla.mozilla.org/show_bug.cgi?id=1613141
// https://bugzilla.mozilla.org/show_bug.cgi?id=1880856
// https://groups.google.com/g/tb-planning/c/p4MUTMNYBVo
pref("extensions.webextensions.remote", true); // [DEFAULT]

/// Block extensions signed with weak signature algorithms [NO-MAIL]
pref("xpinstall.signatures.weakSignaturesTemporarilyAllowed", false); // [NO-MAIL] [HIDDEN] [DEFAULT]

/// Disable add-on sideloading
// Only allows installing extensions from profile & application directories (Prevents extensions being installed from the system/via other software)
// https://archive.is/DYjAM
// https://support.mozilla.org/kb/deploying-firefox-with-extensions
// https://searchfox.org/mozilla-central/source/toolkit/mozapps/extensions/internal/AddonSettings.sys.mjs#125
pref("extensions.autoDisableScopes", 15, locked); // [DEFAULT - non-Thunderbird] Defense in depth, ensures sideloaded extensions are always disabled by default...
pref("extensions.enabledScopes", 5); // [HIDDEN]
pref("extensions.installDistroAddons", false); // [DEFAULT - Android] [HIDDEN - non-Android]
pref("extensions.sideloadScopes", 0); // [HIDDEN]
pref("extensions.startupScanScopes", 0); // [DEFAULT - non-Thunderbird] [HIDDEN - Android]

/// Disable installation of add-ons + only allow enabling it per-session [DESKTOP]
// Includes extensions & themes
// Does NOT apply to Android's `Recommended` extensions (collections) found at `Settings` -> `Advanced` -> `Extensions`
// This doesn't impact already installed add-ons & add-ons installed by policies
// Firefox (on Desktop) will prompt to re-enable this when necessary
// Unfortunately Android and Thunderbird don't have a prompt like this :( - so we won't disable this by default there - but we'll still set the pref to `true` to expose it via the `about:config` 
// Setting this pref to `sticky` causes it to reset per session, which is quite nice from a security perspective, as it allows users to enable this functionality only when it's necessary...
// Ex: A user attempts to install an extension, sees the extra prompt/warning, and selects `Enable` (which temporarily sets this pref to `true`...). The user then proceeds to install the extension. On the next launch of Firefox, this pref is reset back to `false`, meaning the ability to install extensions is fully disabled without them even thinking about it
pref("xpinstall.enabled", true); // [HIDDEN] [DEFAULT]

/// Disable mozAddonManager
// mozAddonManager prevents extensions from working on `addons.mozilla.org` (`addons.thunderbird.net` for Thunderbird), and this API also exposes a list of the user's installed add-ons to `addons.mozilla.org` (`addons.thunderbird.net` for Thunderbird)...
// Note that disabling the following preferences unfortunately break installation of extensions from `addons.mozilla.org` on Android, and from `addons.thunderbird.net` on Thunderbird
// https://bugzilla.mozilla.org/show_bug.cgi?id=1952390#c4
// https://bugzilla.mozilla.org/show_bug.cgi?id=1384330
// https://github.com/thunderbird/addons-server/issues/332
pref("extensions.webapi.enabled", true); // [ANDROID-ONLY] [THUNDERBIRD] [DEFAULT]
pref("privacy.resistFingerprinting.block_mozAddonManager", false); // [ANDROID-ONLY] [THUNDERBIRD] [DEFAULT]

/// Enable Add-on Distribution Control (Install Origins)
// Prevents extensions being installed from websites that they don't specify in their manifest
// https://groups.google.com/g/firefox-dev/c/U7GpHE4R-ZY
// https://searchfox.org/mozilla-central/source/toolkit/mozapps/extensions/internal/XPIDatabase.sys.mjs#403
pref("extensions.install_origins.enabled", true);

/// Enable AMRemoteSettings by default to expose via the `about:config`
// Used for ex. updating the list of quarantined domains
// https://searchfox.org/mozilla-central/source/toolkit/mozapps/extensions/docs/AMRemoteSettings-overview.rst
// https://searchfox.org/mozilla-central/source/toolkit/mozapps/extensions/AddonManager.sys.mjs
pref("extensions.remoteSettings.disabled", false); // [HIDDEN] [DEFAULT]

/// Enable optional permission prompts
// https://bugzilla.mozilla.org/show_bug.cgi?id=1392176
pref("extensions.webextOptionalPermissionPrompts", true); // [DEFAULT]

/// Enable Mozilla's Extension Blocklist
pref("extensions.blocklist.enabled", true); // [DEFAULT]

/// Enable Manifest V3
// https://blog.mozilla.org/addons/2022/05/18/manifest-v3-in-firefox-recap-next-steps/
pref("extensions.manifestV3.enabled", true); // [DEFAULT]

/// Enable restricted/quarantined domains by default
// https://support.mozilla.org/kb/quarantined-domains
pref("extensions.quarantinedDomains.enabled", true); // [DEFAULT]
pref("extensions.quarantinedDomains.uiDisabled", false); // [DEFAULT] [HIDDEN]

/// Enable userScripts
// userScripts ran this way run in separate isolated sandboxes
// https://wiki.mozilla.org/WebExtensions/UserScripts
// https://bugzilla.mozilla.org/show_bug.cgi?id=1875475
pref("extensions.userScripts.mv3.enabled", true); // [DEFAULT]
pref("extensions.webextensions.userScripts.enabled", true); // [DEFAULT]

/// Ensure Firefox Multi-Account Containers can access all containers by default (if installed)
pref("extensions.userContextIsolation.@testpilot-container.restricted", "[]"); // [HIDDEN]

/// Ensure uBlock Origin can access all containers by default (if installed)
pref("extensions.userContextIsolation.uBlock0@raymondhill.net.restricted", "[]"); // [HIDDEN]

/// Ensure Web Compatibility interventions use the MV3 API instead of the older MV2 one
// https://searchfox.org/mozilla-central/rev/20fc11f1/modules/libpref/init/all.js#4090
pref("extensions.webcompat.useScriptingAPI", true); // [DEFAULT]

/// Harden CSP policy
// Compared to Firefox's default, this:
// Blocks scripts unless they're loaded from the same origin
// Blocks unsafe eval() - including WebAssembly (WASM)
// Upgrades network requests to HTTPS
// Etc...
pref("extensions.webextensions.base-content-security-policy", "script-src 'self' 'unsafe-inline'; upgrade-insecure-requests;"); // `unsafe-inline` is required for Web Compatibility interventions (`about:compat`)
pref("extensions.webextensions.base-content-security-policy.v3", "script-src 'self'; upgrade-insecure-requests;");
pref("extensions.webextensions.default-content-security-policy", "script-src 'self'; upgrade-insecure-requests;");
pref("extensions.webextensions.default-content-security-policy.v3", "script-src 'self'; upgrade-insecure-requests;"); // [DEFAULT]

/// Never allow installing extensions without first prompting the user
pref("extensions.postDownloadThirdPartyPrompt", false, locked); // [HIDDEN - Android/Thunderbird] https://github.com/arkenfox/user.js/issues/1090
pref("xpinstall.whitelist.add", "", locked); // [DEFAULT - non-Android] [HIDDEN - non-Android]
pref("xpinstall.whitelist.directRequest", false); // [HIDDEN] For direct URL requests https://searchfox.org/mozilla-central/rev/20fc11f1/toolkit/mozapps/extensions/internal/XPIInstall.sys.mjs#4463
pref("xpinstall.whitelist.fileRequest", false); // [DEFAULT - Android] [HIDDEN - non-Android] For `file://` requests https://searchfox.org/mozilla-central/rev/20fc11f1/toolkit/mozapps/extensions/internal/XPIInstall.sys.mjs#4475
pref("xpinstall.whitelist.required", true, locked); // [DEFAULT] This is the `Warn you when websites try to install add-ons` setting at `about:preferences#privacy`

/// Only allow installation and updates of extensions using Firefox's built-in certificates by default
pref("extensions.install.requireBuiltInCerts", true); // [HIDDEN]
pref("extensions.update.requireBuiltInCerts", true); // [HIDDEN]

/// Only allow installation of signed extensions by default [NO-MAIL]
// Unfortunately not supported on Thunderbird :( [NO-MAIL]
pref("extensions.langpacks.signatures.required", true); // [NO-MAIL] [DEFAULT - non-Thunderbird]
pref("xpinstall.signatures.required", true); // [NO-MAIL] [DEFAULT - non-Thunderbird]

/// Prevent automatically granting MV3 extensions optional host permissions by default
// These permissions can still be enabled manually at `about:addons`, from the 'Permissions' tab at the extension's settings page
pref("extensions.originControls.grantByDefault", false);

/// Prevent certain Mozilla extensions from accessing restricted/quarantined domains...
pref("extensions.quarantineIgnoredByUser.ads@mozac.org", false, locked); // Mozilla Android Components - Ads Telemetry...
pref("extensions.quarantineIgnoredByUser.cookies@mozac.org", false, locked); // Mozilla Android Components - Search Telemetry...
pref("extensions.quarantineIgnoredByUser.ddg@search.mozilla.org", false, locked); // DuckDuckGo - search engine...
pref("extensions.quarantineIgnoredByUser.wikipedia@search.mozilla.org", false, locked); // Wikipedia (en) - search engine...

/// Prevent extensions from opening pop-ups to remote websites
// https://bugzilla.mozilla.org/show_bug.cgi?id=1760608
// https://searchfox.org/mozilla-central/rev/20fc11f1/toolkit/components/extensions/ExtensionActions.sys.mjs#275
pref("extensions.manifestV2.actionsPopupURLRestricted", true); // [DEFAULT - Android]

/// Prevent extensions from opening pop-ups without user interaction
// https://searchfox.org/mozilla-central/rev/20fc11f1/browser/components/extensions/parent/ext-browserAction.js#1030
// https://searchfox.org/mozilla-central/rev/20fc11f1/mobile/shared/components/extensions/ext-browserAction.js#168
pref("extensions.openPopupWithoutUserGesture.enabled", false); // [DEFAULT - non-Nightly]

/// Prevent extensions from using the Gecko Profiler
// Includes certain Mozilla extensions by default
// https://firefox-source-docs.mozilla.org/tools/profiler/index.html
pref("extensions.geckoProfiler.acceptedExtensionIds", ""); // [DEFAULT - Android] [HIDDEN - Android]

/// Prevent unprivileged extensions from accessing experimental APIs by default
// https://searchfox.org/mozilla-central/source/toolkit/components/extensions/docs/basics.rst#142
pref("extensions.experiments.enabled", false); // [DEFAULT - non-Thunderbird]


/// Require secure origins to install add-ons
pref("extensions.install.requireSecureOrigin", true); // [HIDDEN]

pref("browser.phoenix.status", "016");

/*** 017 AI ***/

// https://support.mozilla.org/kb/ai-chatbot

/// Allow managing models from `about:addons`
// https://searchfox.org/mozilla-central/rev/20fc11f1/toolkit/mozapps/extensions/internal/ModelHubProvider.sys.mjs#20
pref("extensions.htmlaboutaddons.local_model_management", true); // [NIGHTLY] [DEFAULT]


/// Disable AI functionality by default
pref("browser.ml.enable", false); // [DEFAULT - non-Nightly] "Experimental Machine Learning Inference Engine"

/// Disable AI/ML "Autofill Experiment"
// https://searchfox.org/mozilla-central/source/toolkit/components/formautofill/MLAutofill.sys.mjs
pref("extensions.formautofill.ml.experiment.enabled", false); // [HIDDEN - Thunderbird]





pref("browser.phoenix.status", "017");

/*** 018 GEOLOCATION ***/


/// Disable logging Geolocation requests by default
// This is already Firefox's default setting - but setting it here exposes it in the `about:config` since it's hidden
// https://searchfox.org/mozilla-central/rev/f1e32fa7/dom/system/NetworkGeolocationProvider.sys.mjs#21
pref("geo.provider.network.logging.enabled", false); // [HIDDEN] [DEFAULT] 

pref("geo.prompt.open_system_prefs", false); // [WINDOWS-Only] Ensure users aren't prompted to open settings and enable it - https://searchfox.org/mozilla-central/rev/20fc11f1/modules/libpref/init/StaticPrefList.yaml#6406

/// Disable Mozilla's GeoIP/Region Service
// Prevents Firefox from monitoring the user's region/general location
// Note: Firefox will still use different regional search engines based on the browser/system locale (ex. tested with Wikipedia), but this prevents using geolocation
// https://firefox-source-docs.mozilla.org/toolkit/modules/toolkit_modules/Region.html
// https://searchfox.org/mozilla-central/source/toolkit/modules/Region.sys.mjs
pref("browser.region.local-geocoding", false); // [HIDDEN] [DEFAULT]
pref("browser.region.network.scan", false); // [DEFAULT] [DEFENSE IN DEPTH] Disable Wi-Fi scanning for these requests
pref("browser.region.network.url", "");
pref("browser.region.update.enabled", false);
pref("browser.search.region", "US"); // [HIDDEN]
pref("doh-rollout.home-region", "US"); // [HIDDEN]




/// Set BeaconDB as the default network Geolocation provider
// Default is Google :/
// https://searchfox.org/mozilla-central/source/dom/geolocation/Geolocation.cpp
// https://searchfox.org/mozilla-central/source/dom/geolocation/MLSFallback.h
pref("geo.provider.network.url", "https://api.beacondb.net/v1/geolocate");
pref("geo.provider.testing", false); // [HIDDEN] [DEFAULT] When set to `true`, this forces the use of the network Geolocation provider (BeaconDB for us), regardless of anything else - https://searchfox.org/mozilla-central/rev/f1e32fa7/dom/geolocation/Geolocation.cpp#779
pref("geo.provider.use_mls", true); // [NO-MAIL] [HIDDEN] [DEFAULT] Ensure the network Geolocation provider (BeaconDB for us) is enabled


pref("browser.phoenix.status", "018");

/*** 019 PDF.js ***/

/// Disable JavaScript
pref("pdfjs.enableScripting", false);

/// Disable XFA
// https://learn.microsoft.com/deployedge/microsoft-edge-policies#viewxfapdfiniemodeallowedorigins
// https://insert-script.blogspot.com/2019/01/adobe-reader-pdf-callback-via-xslt.html
// https://www.sentinelone.com/blog/malicious-pdfs-revealing-techniques-behind-attacks/
// https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=xfa
// https://wikipedia.org/wiki/XFA
// Not even a standard...
pref("pdfjs.enableXfa", false);

/// Enable the ability to add signatures
pref("pdfjs.enableSignatureEditor", true);

/// Never allow documents to prevent copying text
pref("pdfjs.enablePermissions", false); // [DEFAULT]

/// Open external links in new tabs/windows
// https://github.com/mozilla/pdf.js/blob/master/extensions/chromium/preferences_schema.json
pref("pdfjs.externalLinkTarget", 2);

/// Open PDFs inline where possible
pref("browser.download.open_pdf_attachments_inline", true); // [DEFAULT - Android]

/// Show sidebar by default when viewing PDFs
pref("pdfjs.sidebarViewOnLoad", 2);

pref("browser.phoenix.status", "019");

/*** 020 SAFE BROWSING ***/

/// By default, when you report a Safe Browsing false positive, it sends the URL to both Mozilla & Google (NOT PROXIED), as well as your locale to Mozilla
// Ex. https://en-us.phish-error.mozilla.com/?url=example.org - Which redirects you directly to https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=example.org 
// We can improve privacy & speed by sending the domain *only* to Google & without sending your locale to anyone
// We could also potentially strip tpl=mozilla which tells Google the request is from Firefox - though it looks like there is a different page for Firefox users with a better privacy policy, so we will leave it for now
// Unclear whether 'MalwareMistake' is used, but we can set it anyways
pref("browser.safebrowsing.provider.google.reportMalwareMistakeURL", "https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=");
pref("browser.safebrowsing.provider.google.reportPhishMistakeURL", "https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=");
pref("browser.safebrowsing.provider.google4.reportMalwareMistakeURL", "https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=");
pref("browser.safebrowsing.provider.google4.reportPhishMistakeURL", "https://safebrowsing.google.com/safebrowsing/report_error/?tpl=mozilla&url=");

//// Similar behavior also appears to happen when you report a URL to Safe Browsing
pref("browser.safebrowsing.reportPhishURL", "https://safebrowsing.google.com/safebrowsing/report_phish/?tpl=mozilla&url=");

/// Disable the legacy Safe Browsing API (v2.2...)
// https://code.google.com/archive/p/google-safe-browsing/wikis/Protocolv2Spec.wiki
// Has been nonfunctional since October 2018
// https://security.googleblog.com/2018/01/announcing-turndown-of-deprecated.html
// Let's make sure it's not used for defense in depth (and attack surface reduction...)
pref("browser.safebrowsing.provider.google.advisoryName", "Google Safe Browsing (Legacy)"); // Label it so it's clearly distinguishable if it is ever enabled for whatever reason...
pref("browser.safebrowsing.provider.google.gethashURL", "");
pref("browser.safebrowsing.provider.google.updateURL", "");

/// Enable an additional plug-in blocklist from Mozilla
pref("urlclassifier.blockedTable", "moztest-block-simple,mozplugin-block-digest256"); // [DEFAULT - Nightly]

/// Enable Safe Browsing by default
// This won't do anything if you don't have an API key from Google, though doesn't hurt...
// Harmless from a privacy perspective due to the below changes, also effective at preventing real-time malicious domains and downloads.
// We will of course **ALWAYS** give users the ability to disable.
// https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/SafeBrowsing.sys.mjs
pref("browser.safebrowsing.blockedURIs.enabled", true); // [DEFAULT]
pref("browser.safebrowsing.downloads.enabled", true); // [DEFAULT - non-Android]
pref("browser.safebrowsing.downloads.remote.url", "https://sb-ssl.google.com/safebrowsing/clientreport/download?key=%GOOGLE_SAFEBROWSING_API_KEY%"); // [DEFAULT]
pref("browser.safebrowsing.features.blockedURIs.update", true); // [DEFAULT, HIDDEN]
pref("browser.safebrowsing.features.downloads.update", true); // [DEFAULT, HIDDEN]
pref("browser.safebrowsing.features.malware.update", true); // [DEFAULT, HIDDEN - non-Android]
pref("browser.safebrowsing.features.phishing.update", true); // [DEFAULT, HIDDEN - non-Android] 
pref("browser.safebrowsing.id", "navclient-auto-ffox"); // [DEFAULT - Official] Ensure we use Mozilla's ID
pref("browser.safebrowsing.malware.enabled", true); // [DEFAULT]
pref("browser.safebrowsing.phishing.enabled", true); // [DEFAULT]
pref("browser.safebrowsing.update.enabled", true); // [DEFAULT, HIDDEN]
pref("urlclassifier.downloadAllowTable", "goog-downloadwhite-proto"); // [DEFAULT - non-Android]
pref("urlclassifier.downloadBlockTable", "goog-badbinurl-proto"); // [DEFAULT - non-Android]

/// Ensure users can override Safe Browsing warnings by default
pref("browser.safebrowsing.allowOverride", true); // [DEFAULT]

/// Prevent sending metadata of downloaded files to Google
// https://support.mozilla.org/kb/how-does-phishing-and-malware-protection-work#w_how-does-phishing-and-malware-protection-work-in-firefox
// https://feeding.cloud.geek.nz/posts/how-safe-browsing-works-in-firefox/
pref("browser.safebrowsing.downloads.remote.enabled", false);

/// Prevent sharing data with Google & Mozilla
// https://searchfox.org/mozilla-central/source/netwerk/url-classifier/nsChannelClassifier.cpp#364
// https://searchfox.org/mozilla-central/source/toolkit/components/url-classifier/nsUrlClassifierDBService.cpp#1964
// https://bugzilla.mozilla.org/show_bug.cgi?id=1351147
pref("browser.safebrowsing.provider.google.dataSharing.enabled", false, locked); // [DEFAULT] [HIDDEN - non-Android]
pref("browser.safebrowsing.provider.google.dataSharingURL", "", locked); // [DEFAULT] [HIDDEN]
pref("browser.safebrowsing.provider.google4.dataSharing.enabled", false, locked); // [DEFAULT]
pref("browser.safebrowsing.provider.google4.dataSharingURL", "", locked);
pref("browser.safebrowsing.provider.mozilla.dataSharing.enabled", false, locked); // [DEFAULT] [HIDDEN]
pref("browser.safebrowsing.provider.mozilla.dataSharingURL", "", locked); // [DEFAULT] [HIDDEN]

/// Proxy Safe Browsing
// These are using the servers we've set up for IronFox, hosted on our Cloudflare storage bucket (in EU jurisdiction)
pref("browser.safebrowsing.provider.google4.gethashURL", "https://safebrowsing.ironfoxoss.org/v4/fullHashes:find?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST");
pref("browser.safebrowsing.provider.google4.updateURL", "https://safebrowsing.ironfoxoss.org/v4/threatListUpdates:fetch?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST");

/// Unclear whether these are actually used or not, but looks like Firefox has some kind of functionality to view a "report" from Safe Browsing about the safety, history, & general status of a site
// By default, it unnecessarily redirects from ex. https://safebrowsing.google.com/safebrowsing/diagnostic?site=example.org to https://transparencyreport.google.com/safe-browsing/search?url=example.org
// We can skip the redirect to improve performance
pref("browser.safebrowsing.provider.google.reportURL", "https://transparencyreport.google.com/safe-browsing/search?url=");
pref("browser.safebrowsing.provider.google4.reportURL", "https://transparencyreport.google.com/safe-browsing/search?url=");

pref("browser.phoenix.status", "020");

/*** 021 MISC. PRIVACY + SECURITY ***/

/// Disable Accessibility Services
// PRIVACY: Can be used to monitor users by design
// SECURITY: Can be easily abused by bad actors, Attack Surface Reduction
// "Firefox Accessibility Service is a technology built into Firefox that provides 3rd party applications running on the same device the ability to inspect, monitor, visualize, and alter web page content hosted within Firefox."
// We need to ensure we're still accomodating for impaired users, but I feel this is something that must be handled by the browser instead of external software
// https://web.archive.org/web/20240608190300/support.mozilla.org/en-US/kb/accessibility-services
pref("accessibility.force_disabled", 1);

/// Disable automatic updates for OpenSearch engines
// PRIVACY: Unsolicited connections to search providers
// SECURITY: Could be abused to alter a user's search engine(s) without consent
// Doesn't appear to impact Mozilla's built-in search engines
// https://firefox-source-docs.mozilla.org/toolkit/search/Preferences.html#hidden
// https://developer.mozilla.org/docs/Web/XML/Guides/OpenSearch#supporting_automatic_updates_for_opensearch_plugins
pref("browser.search.update", false); // [DEFAULT - Android]

/// Disable Battery API (Navigator.getBattery)
// PRIVACY: Fingerprinting concerns, just plain creepy...
// SECURITY: Attack Surface Reduction
// NOTE: This only impacts chrome/certain privileged code; this is thankfully never exposed to websites
// I'm still not convinced that there's a legitimate use/need for this functionality though...
// https://developer.mozilla.org/docs/Web/API/Battery_Status_API
// https://developer.mozilla.org/docs/Web/API/Navigator/getBattery
// https://bugzilla.mozilla.org/show_bug.cgi?id=1313580
pref("dom.battery.enabled", false);

/// Disable Beacon API (Navigator.sendBeacon)
// PRIVACY: Used for analytics/tracking by design, see explanation below
// SECURITY: Attack Surface Reduction
// I was originally against disabling this, but after careful consideration, I've changed my position.
// The explicit, stated purpose/use case of this API is for analytics/tracking.
// Websites *can* obtain the data shared from this API through other means; though the other ways to obtain it are more disruptive and less reliable.
// Analytics/tracking is evidently not a use case that we, as the user agent, should support or assist with.
// I don't see a justification for adding APIs/features to support this hostile behavior. We are the user agent and must act in the best interest of users...
// Also disabled by ex. Cromite: https://github.com/uazo/cromite/blob/master/docs/FEATURES.md https://github.com/uazo/cromite/issues/1454
// https://developer.mozilla.org/docs/Web/API/Beacon_API
// https://developer.mozilla.org/docs/Web/API/Navigator/sendBeacon
// https://udn.realityripple.com/docs/Web/API/Navigator/sendBeacon
// https://w3c.github.io/beacon/#privacy-and-security
// https://bugzilla.mozilla.org/show_bug.cgi?id=1454252
pref("beacon.enabled", false);

/// Disable Clipboard API
// PRIVACY: Fingerprinting concerns, prevents monitoring users' clipboards without their consent
// SECURITY: Prevents leaking sensitive information (ex. passwords), Attack Surface Reduction
// NOTE: This only impacts extensions; this is thankfully never exposed to websites
// I'm still not convinced extensions need or should have access to this data though (While there are currently other ways for extensions to access clipboard data, those are deprecated and will presumably not be around for much longer)
// https://developer.mozilla.org/docs/Web/API/Clipboard
pref("dom.events.asyncClipboard.clipboardItem", false);
pref("dom.events.asyncClipboard.readText", false);
pref("dom.events.testing.asyncClipboard", false, locked); // [DEFAULT]

/// Disable Content Analysis SDK
// PRIVACY: Used for monitoring users by design
// SECURITY: Can be easily abused by bad actors, Attack Surface Reduction
// DESKTOP: We also set "ContentAnalysis" in policies
// https://mozilla.github.io/policy-templates/#contentanalysis
// https://github.com/chromium/content_analysis_sdk
pref("browser.contentanalysis.default_result", 0, locked); // [DEFAULT]
pref("browser.contentanalysis.enabled", false, locked); // [DEFAULT]
pref("browser.contentanalysis.interception_point.clipboard.enabled", false, locked);
pref("browser.contentanalysis.interception_point.drag_and_drop.enabled", false, locked);
pref("browser.contentanalysis.interception_point.file_upload.enabled", false, locked);
pref("browser.contentanalysis.interception_point.print.enabled", false, locked);
pref("browser.contentanalysis.max_connections", 0, locked); // Sets maximum number of allowed connections to 0
pref("browser.contentanalysis.show_blocked_result", true, locked); // [DEFAULT] - Always notify users when Content Analysis blocks access to something...
pref("browser.contentanalysis.silent_notifications", false, locked); // [DEFAULT] If Content Analysis is enabled, ensure notifications aren't silenced so that users are fully aware

/// Disable Federated Credential Management (FedCM) API
// PRIVACY: Provides support for "identity federation services"/third party sign-in - which can be used for tracking by design
// SECURITY: Attack Surface Reduction
// https://developer.mozilla.org/docs/Web/API/FedCM_API
// https://w3c-fedid.github.io/FedCM/
pref("dom.security.credentialmanagement.identity.enabled", false); // [DEFAULT - non-Nightly]
pref("dom.security.credentialmanagement.identity.heavyweight.enabled", false); // [DEFAULT - non-Nightly]
pref("dom.security.credentialmanagement.identity.lightweight.enabled", false); // [DEFAULT]


/// Disable Reporting API
// PRIVACY: Fingerprinting concerns, used for analytics by design
// SECURITY: Attack Surface Reduction
// https://w3c.github.io/reporting/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1492036
pref("dom.reporting.crash.enabled", false); // [DEFAULT]
pref("dom.reporting.delivering.maxFailures", 0); // [DEFENSE IN DEPTH]
pref("dom.reporting.delivering.maxReports", 0); // [DEFENSE IN DEPTH]
pref("dom.reporting.enabled", false); // [DEFAULT]
pref("dom.reporting.featurePolicy.enabled", false); // [DEFAULT]
pref("dom.reporting.header.enabled", false); // [DEFAULT]

/// Disable WebGPU
// PRIVACY: Fingerprinting concerns
// SECURITY: Attack Surface Reduction
// https://gpuweb.github.io/gpuweb/#privacy-considerations
// https://gpuweb.github.io/gpuweb/#security-considerations
// https://browserleaks.com/webgpu
pref("dom.webgpu.enabled", false); // [DEFAULT - non-Nightly]
pref("dom.webgpu.workers.enabled", false); // For DOM workers [DEFAULT - non-Nightly]

/// Disable WebMIDI
// PRIVACY: Fingerprinting concerns
// SECURITY: Attack Surface Reduction
// See "Privacy Considerations" & "Security Considerations": https://webaudio.github.io/web-midi-api
// Toggling 'dom.webmidi.enabled' itself could be fingerprintable, but setting these instead just causes the permission to be automatically denied at a random interval
// https://searchfox.org/mozilla-central/source/dom/midi/MIDIPermissionRequest.cpp#119
// Test: https://permission.site/
pref("dom.sitepermsaddon-provider.enabled", false);
pref("dom.webmidi.gated", true, locked); // [DEFAULT]

/// Enable Messaging Layer Security (MLS)
// PRIVACY: Ensures messages are only received by the intended recipient
// SECURITY: Protects the authenticity and integrity of messages
// Security layer for E2EE messaging
// https://wikipedia.org/wiki/Messaging_Layer_Security
// https://blog.mozilla.org/mozilla/messaging-layer-security-is-now-an-internet-standard/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1876002
pref("dom.origin-trials.mls.state", 1);

pref("browser.phoenix.status", "021");

/*** 022 MISC. PRIVACY ***/

/// Block ports currently known to be abused by Android apps for tracking/fingerprinting
// Currently blocked by default on Android - but assuming they don't cause issues, I'd also like to keep these blocked for other platforms (for defense in depth and in case this method of tracking is also being used elsewhere...)
// https://localmess.github.io/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1970141
pref("network.security.ports.banned", "29009, 29010, 30102, 30103, 12387, 12388, 12580, 12581, 12582, 12583, 12584, 12585, 12586, 12587, 12588, 12589, 12590, 12591"); // [DEFAULT - Android]

/// Disable CSP reporting
// Fingerprinting concerns, Used for analytics by design
// Also reduces unsolicited network activity and bandwidth consumption
// Glad we managed to convince Mozilla to add this :)
// https://bugzilla.mozilla.org/show_bug.cgi?id=1964249
pref("security.csp.reporting.enabled", false); // [NIGHTLY]


/// Disable Hyperlink Auditing (Click Tracking)
// https://www.bleepingcomputer.com/news/software/major-browsers-to-prevent-disabling-of-click-tracking-privacy-risk/
pref("browser.send_pings", false); // [DEFAULT]
pref("browser.send_pings.max_per_link", 0); // [DEFENSE IN DEPTH]
pref("browser.send_pings.require_same_host", true); // [DEFENSE IN DEPTH]

/// Disable Network Error Logging
// Fingerprinting concerns, Used for analytics by design
// https://developer.mozilla.org/docs/Web/HTTP/Network_Error_Logging
// https://w3c.github.io/network-error-logging/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1145235
// https://searchfox.org/mozilla-central/rev/a589ce1e/modules/libpref/init/StaticPrefList.yaml#13370
pref("network.http.network_error_logging.enabled", false); // [DEFAULT]

/// Disable online speech recognition
// https://searchfox.org/mozilla-central/source/dom/media/webspeech/recognition/OnlineSpeechRecognitionService.cpp
// https://searchfox.org/mozilla-central/source/dom/media/webspeech/recognition/SpeechRecognition.cpp
pref("media.webspeech.service.endpoint", "data;"); // [HIDDEN]

/// Disable referers when leaving .onion domains
// NOTE: Please use TOR BROWSER for accessing .onion domains...
pref("network.http.referer.hideOnionSource", true); // [DEFAULT]

/// Disable storage access heuristics
// https://developer.mozilla.org/docs/Web/Privacy/State_Partitioning#storage_access_heuristics
pref("dom.storage_access.auto_grants", false); // Automatic storage access grants
pref("privacy.restrict3rdpartystorage.heuristic.navigation", false); // [DEFAULT - non-desktop Nightly] 
pref("privacy.restrict3rdpartystorage.heuristic.opened_window_after_interaction", false);
pref("privacy.restrict3rdpartystorage.heuristic.recently_visited", false);
pref("privacy.restrict3rdpartystorage.heuristic.redirect", false); // [DEFAULT - Android]
pref("privacy.restrict3rdpartystorage.heuristic.window_open", false); // [DEFAULT - Android]

/// Disable TLS session identifiers [ANDROID-ONLY]
// Fingerprinting/tracking concerns [ANDROID-ONLY]
// I'm not worried about this for desktop since these are session-only, but I feel like the situation is very different for Android. Users likely leave the app open (and by extension: keep their browsing session active) for days at a time, much longer than on Desktop. [ANDROID-ONLY]
// So this does concern me and I think it's worth setting here. [ANDROID-ONLY]
// For reference, this is also disabled by ex. Cromite [ANDROID-ONLY]
// https://arxiv.org/abs/1810.07304 [ANDROID-ONLY]
pref("security.ssl.disable_session_identifiers", true); // [ANDROID-ONLY]

/// Enable Containers
// https://support.mozilla.org/kb/how-use-firefox-containers
// https://searchfox.org/mozilla-central/source/toolkit/components/contextualidentity/ContextualIdentityService.sys.mjs
pref("privacy.userContext.enabled", true); // [HIDDEN - Android] [DEFAULT - Firefox Desktop Nightly]

/// Enable Cookie Banner Reduction
// https://support.mozilla.org/kb/cookie-banner-reduction
pref("cookiebanners.bannerClicking.enabled", true); // [DEFAULT]
pref("cookiebanners.cookieInjector.enabled", true); // [DEFAULT]
pref("cookiebanners.service.mode", 1);
pref("cookiebanners.service.mode.privateBrowsing", 1);
pref("cookiebanners.service.enableGlobalRules", true); // [DEFAULT]
pref("cookiebanners.service.enableGlobalRules.subFrames", true); // [DEFAULT]

/// Enable Cookies Having Independent Partitioned State (CHIPS)
// This allows websites to set cookies with a 'Partitioned' attribute, meaning they're limited in scope
// We still use ETP Strict for partioning anyways, so this could be useful as a defense in depth if a user decides to allow a specific domain (or domains) to access a third party cookie
// https://developer.mozilla.org/docs/Web/Privacy/Privacy_sandbox/Partitioned_cookies
// https://developer.mozilla.org/docs/Web/HTTP/Headers/Set-Cookie#partitioned
// https://github.com/privacycg/CHIPS
pref("network.cookie.CHIPS.enabled", true); // [DEFAULT - Nightly]
pref("network.cookie.chips.partitionLimitDryRun", false); // [DEFAULT]

/// Enable Do Not Track & Global Privacy Control
// Do Not Track is also covered by ETP Strict, pref to be removed soon...
pref("privacy.donottrackheader.enabled", true);
pref("privacy.globalprivacycontrol.enabled", true);
pref("privacy.globalprivacycontrol.functionality.enabled", true); // [DEFAULT - non-Thunderbird]
pref("privacy.globalprivacycontrol.pbmode.enabled", true); // [DEFAULT - non-Thunderbird]




/// Exclude third party trackers from storage access heuristics (if enabled)
// https://developer.mozilla.org/docs/Web/Privacy/State_Partitioning#storage_access_heuristics
pref("dom.storage_access.auto_grants.exclude_third_party_trackers", true); // [DEFAULT - Nightly] Automatic storage access grants
pref("privacy.restrict3rdpartystorage.heuristic.exclude_third_party_trackers", true); // [DEFAULT - Nightly]

/// Improve built-in query stripping to be on par with LibreWolf and Brave
// See Mozilla's defaults here: https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/query-stripping/changeset?_expected=0
// https://codeberg.org/librewolf/settings/src/commit/e93018221243f0af7cdbbf737b6af17d70cde8aa/librewolf.cfg#L103
// https://github.com/brave/brave-core/blob/master/components/query_filter/utils.cc
pref("privacy.query_stripping.strip_list", "__hsfp __hssc __hstc __s _bhlid _branch_match_id _branch_referrer _gl _hsenc _kx _openstat at_recipient_id at_recipient_list bbeml bsft_clkid bsft_uid dclid et_rid fb_action_ids fb_comment_id fbclid gbraid gclid guce_referrer guce_referrer_sig hsCtaTracking igshid irclickid mc_eid mkt_tok ml_subscriber ml_subscriber_hash msclkid mtm_cid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id pk_cid rb_clickid s_cid sc_customer sc_eh sc_uid srsltid ss_email_id twclid unicorn_click_id vero_conv vero_id vgo_ee wbraid wickedid yclid ymclid ysclid");

//// Unbreak urldefense.com redirects
/// (ex. https://urldefense.com/v3/__https://www.portainer.io/hs/preferences-center/en/direct?data=W2nXS-N30h-M1W45lXqV2nFX8ZW3SzKNq3gnnN0W4cQh6C1Bnn1kW1VjfB24fr2-BW4mm3dy3T2wkqW2MWfBj49z9PPW4mqs512qWTfrW4px5K71Nn7N2W32DKbz1V7s-qW21bSln2KWpS4W1SdHmq2YwgS9W3P8RNt2r6W8pW49QSSt1_tcPsW3GSrf749CfyJW2PPdX33JPrgmW4hcHf84hm-NmW2FS2pd2sMKL-W2YGYkz43RS-9W4pjpV52t0rxlW3SB_f94psLW2W3_Sm6w2FGVTjW3K2-cG4fzZLWW2qDSdB3bzPyBW3j8X_q2PMxWzW36CtK22MvcXrW4hNdFB3DLWP3W3VMWNy3SYMyvW1Vs-MC43NZJNW4hLsTd2B1T2JW2sB9wk3DMh2mW2D0QS-2t04tYW43Cpv42Tz6SwW32rgcB3_SfvDW4mq1yB36nnnkW3BNLQw2YfSH9W49sKsP3z4zKPW3zd1YL1Zm6S3W4kmj3Z2sQ7WVW36xkSD2RSm5hW1Q0SqC30sK9ZW2-kSbQ2nH5KcW36fNc_2RjGNjW36pblN43qsbhW2CCNvJ3_SL29W1_sQHx4fqK9NW3Sy1cb4mpD3h0&utm_campaign=XNF&utm_source=hs_automation&utm_medium=email&utm_content=264158909&_hsenc=p2ANqtz--9JvIgI266aB1UVizENwYNYREZSotsXOhWcMNeKjZLJO9ZwmR9xlyfsQN2orbT25IymZ_vKUNTANMKQMVQBnzowi2339ExVoOKMJaHx0t2yn5esgg&_hsmi=264158909__;!!MlclJBHn!0eDf-zTf69h-IhFT9WDu2GIXAtCy6RENwguPVpTF1k2K-Nbnzy1NXix2Gj7azc8yDFyI2z3Tz4nTFuGe2hlLzsBl$)
/// https://github.com/brave/brave-browser/issues/41134
pref("privacy.query_stripping.allow_list", "urldefense.com");


/// Isolate permissions per container (if containers are enabled)
// https://support.mozilla.org/kb/how-use-firefox-containers
pref("permissions.isolateBy.userContext", true);

/// Isolate resources (ex. referrers & cookies) injected by extensions
// (ex. https://searchfox.org/mozilla-central/source/toolkit/components/extensions/test/xpcshell/test_ext_contentscript_antitracking.js)
pref("privacy.antitracking.isolateContentScriptResources", true); // [NIGHTLY]

/// Limit CSP reporting
// We block CSP reports with uBlock Origin by default (and disable them entirely on IronFox)
// Mozilla thankfully listened and added support for disabling CSP reports; but the pref (security.csp.reporting.enabled) is currently only available on Nightly, so we'll keep these for the time being, but eventually remove
// https://bugzilla.mozilla.org/show_bug.cgi?id=1964249
pref("security.csp.reporting.limit.count", 1); // [DEFAULT: 100]
pref("security.csp.reporting.limit.timespan", 999999999); // [DEFAULT: 2]
pref("security.csp.reporting.script-sample.max-length", 0); // [DEFAULT: 40]
pref("security.csp.truncate_blocked_uri_for_frame_navigations", true); // [DEFAULT] Ensure we truncate  blocked-uris

/// Limit maximum cookie lifetime to 6 months/180 days (Like Brave)
// Firefox's default is currently 400 days (34560000)
// https://github.com/brave/brave-browser/issues/3443
// https://github.com/fmarier/brave-core/commit/4d222df50a8dfaaabb31e9f2c5070c4db5ba8fd5
// For testing: https://setcookie.net/
pref("network.cookie.maxageCap", 15552000);


/// Prevent sharing identifying information if a remote AutoConfig is being used
// https://searchfox.org/mozilla-central/source/extensions/pref/autoconfig/src/nsAutoConfig.cpp#220
pref("autoadmin.append_emailaddr", false, locked); // [DEFAULT] [HIDDEN]

/// Prevent third parties from setting cookies unless the third party already has cookies as a first party (Like Safari)
// https://webkit.org/tracking-prevention/#the-default-cookie-policy
// https://bugzilla.mozilla.org/show_bug.cgi?id=1587182
pref("privacy.dynamic_firstparty.limitForeign", true);


/// Restrict tracking referers
pref("network.http.referer.defaultPolicy.trackers", 1);
pref("network.http.referer.defaultPolicy.trackers.pbmode", 1);

/// Set Cookie Banner Reduction rules locally
// Firefox typically downloads/uses these from Remote Settings, but this could be used to set cookies with arbitrary values - which raises concerns (for the same reasons that we disable uBlock Origin's `trusted` rules).
// So this sets the rules locally and prevents using the ones set remotely - allowing users to still take advantage of this feature, while providing them with a far safer approach.
// (This is especially important for Thunderbird, where it's not possible to use these rules otherwise in the first place...)
// These are taken directly from Firefox's Remote Settings: https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/cookie-banner-rules-list/changeset?_expected=0
// https://support.mozilla.org/kb/cookie-banner-reduction
pref("cookiebanners.listService.testRules", '[{"cookies":{"optOut":[{"name":"cookie_dismiss","value":"true"}]},"domains":["duh.de"],"id":"3b73c6b4-b746-462b-8f5e-054ffcd5f2b3"},{"click":{"optOut":"button.rejectAll","presence":"div.cookiebanner"},"domains":["destatis.de"],"id":"b337aaa7-683f-4c8c-8a22-75ab6ae301ff"},{"click":{"optOut":"button.cn-decline","presence":"div.cookie-notice"},"domains":["gls.de"],"id":"727d6577-ae04-4dc0-8ae3-c0af3f3787d5"},{"click":{"optIn":"button.fides-accept-all-button","optOut":"button.fides-reject-all-button","presence":"div#fides-banner"},"domains":["nytimes.com"],"id":"488f07f9-0a01-4118-aab3-2b817e9fe6dc"},{"click":{"optIn":"custom-button#consentAccept","presence":"main[data-consent-main]"},"domains":["rp-online.de"],"id":"06ae9b8e-909a-4f50-be66-0046a1a75ddf"},{"click":{"optIn":".cookie-consent-banner__btn-primary","presence":"#cookie-consent-banner"},"cookies":{"optOut":[{"name":"__tnw_cookieConsent","value":"{%22ad_storage%22:%22denied%22%2C%22analytics_storage%22:%22denied%22}"}]},"domains":["thenextweb.com"],"id":"02c3c5e1-03a6-426a-b00b-fa34f62322fd"},{"click":{"optIn":"div[data-tracking-opt-in-accept=\"true\"]","optOut":"div[data-tracking-opt-in-reject=\"true\"]","presence":"div[data-tracking-opt-in-overlay=\"true\"]"},"domains":["fandom.com"],"id":"D168AF87-F481-4AD7-BE78-28A59F798406"},{"cookies":{"optIn":[{"name":"d_prefs","value":"MToxLGNvbnNlbnRfdmVyc2lvbjoyLHRleHRfdmVyc2lvbjoxMDAw"}],"optOut":[{"name":"d_prefs","value":"MjoxLGNvbnNlbnRfdmVyc2lvbjoyLHRleHRfdmVyc2lvbjoxMDAw"},{"name":"twtr_pixel_opt_in","value":"N"}]},"domains":["twitter.com","x.com"],"id":"05b3b417-c4c7-4ed0-a3cf-43053e8b33ab"},{"click":{"optIn":"[data-cookiebanner=\"accept_button\"]","optOut":"[data-cookiebanner=\"accept_only_essential_button\"]","presence":"[data-testid=\"cookie-policy-manage-dialog\"]"},"domains":["facebook.com","instagram.com","messenger.com","meta.com","oculus.com","workplace.com"],"id":"d1d8ba36-ced7-4453-8b17-2e051e0ab1eb"},{"click":{"optIn":"#shopify-pc__banner__btn-accept","optOut":"#shopify-pc__banner__btn-decline","presence":"#shopify-pc__banner"},"domains":["decathlon.com.sa","decathlon.gp","decathlon.mq"],"id":"1da8a6ad-f894-400e-8b3d-2a281015b86d"},{"click":{"optIn":"#ppms_cm_agree-to-all","optOut":"#ppms_cm_reject-all","presence":"#ppms_cm_popup_overlay"},"cookies":{},"domains":["credit-agricole.pl"],"id":"5050fb9c-fd8a-44c2-817c-23d95f494190"},{"cookies":{"optOut":[{"name":"cookie_manager_cookie_marketing_enabled","value":"false"},{"name":"cookie_manager_cookie_necessary_enabled","value":"true"},{"name":"cookie_manager_cookie_statistic_enabled","value":"false"},{"name":"cookie_manager_policy_accepted","value":"true"}]},"domains":["credit-agricole.it"],"id":"1944a25e-6f16-434d-8c59-0493ba587fe7"},{"click":{"optIn":"#popin_tc_privacy_button_2","optOut":"#popin_tc_privacy_button_3","presence":"#tc-privacy-wrapper"},"cookies":{"optOut":[{"name":"TC_PRIVACY","value":"1%40006%7C86%7C3315%40%40%402524608000000%2C2524608000000%2C2524608000000%40"}]},"domains":["credit-agricole.fr"],"id":"f643be2a-b805-4ab0-9e67-929419e5c7c7"},{"click":{"optIn":".allow","optOut":".deny","presence":"#tarteaucitronWelcome"},"cookies":{"optOut":[{"name":"cookie_manager","value":"!atinternet=false!recaptcha=false!addthis=false!twitter=false!ezplatform=true!youtube=false!hidebanner=true"}]},"domains":["credit-agricole.de"],"id":"1e12c729-34ff-4aa5-9317-d19309affd2c"},{"click":{"optIn":".accept","optOut":".deny","presence":"#tarteaucitronAlertBig"},"cookies":{"optOut":[{"name":"cookie_manager","value":"!atinternet=false!recaptcha=false!addthis=false!linkedin=false!twitter=false!ezplatform=true!youtube=false!hidebanner=true"}]},"domains":["credit-agricole.com"],"id":"1f0a3536-5b09-426a-b6e6-b902c556cb8a"},{"cookies":{"optIn":[{"name":"_cookies_v2","value":"1"}]},"domains":["blablacar.com.br","blablacar.com.tr","blablacar.com.ua","blablacar.in","blablacar.mx","blablacar.rs","blablacar.ru"],"id":"2f4e1235-a360-46ca-bf26-8b09645ee3d5"},{"click":{"optIn":".allowAll","optOut":".denyAll","presence":".cookiesjsr-banner"},"cookies":{"optOut":[{"name":"cookiesjsr","value":"%7B%22functional%22%3Afalse%2C%22recaptcha%22%3Afalse%2C%22video%22%3Afalse%7D"}]},"domains":["mediamarktsaturn.com"],"id":"6f85da65-e44e-4d58-b87c-3e31861de3e0"},{"click":{"optIn":"#pwa-consent-layer-accept-all-button","optOut":"[data-test=\"pwa-consent-layer-deny-all\"]","presence":"[data-test=\"mms-privacy-layer\"]"},"cookies":{"optOut":[{"name":"pwaconsent","value":"v:1.0~required:1&clf:1,cli:1,gfb:1,gtm:1,jot:1,ocx:1|comfort:0&baz:0,cne:0,con:0,fix:0,gfa:0,goa:0,gom:0,grc:0,grv:0,inm:0,lib:0,lob:0,opt:0,orc:0,ore:0,pcl:0,sen:0,sis:0,spe:0,sst:0,swo:0,twi:0,usw:0,usz:0,yte:0|marketing:0&cri:0,eam:0,fab:0,fbc:0,fcm:0,gac:0,gad:0,gcl:0,gcm:0,gdv:0,gos:0,gse:0,msb:0,omp:0,pin:0,ttd:0,twt:0|"}]},"domains":["mediamarkt.at","mediamarkt.be","mediamarkt.de","mediamarkt.es","mediamarkt.nl","mediamarkt.pl","saturn.de"],"id":"2a2b8102-d276-4ece-afbd-005e8e917d18"},{"click":{"optIn":"#acceptAllQuick","optOut":"#rejectAllQuick","presence":"#gdpr-component","runContext":"child"},"cookies":{"optOut":[{"name":"cocos","value":"%7B%22funkcni%22%3Afalse%2C%22statisticke%22%3Afalse%2C%22reklamni%22%3Afalse%7D"},{"name":"cookieConsent","value":"%7B%22preferences%22%3Afalse%2C%22statistics%22%3Afalse%2C%22marketing%22%3Afalse%7D"},{"name":"corec","value":"%7B%22youtube%22%3Afalse%2C%22rtbhouse%22%3Afalse%2C%22google_recaptcha%22%3Atrue%2C%22foxentry_funkcni%22%3Afalse%2C%22tmobile_nezbytne%22%3Atrue%2C%22linkedin%22%3Afalse%2C%22medallia%22%3Afalse%2C%22tmobile_funkcni%22%3Afalse%2C%22tealium%22%3Afalse%2C%22adform%22%3Afalse%2C%22xaxis%22%3Afalse%2C%22twitter%22%3Afalse%2C%22appnexus%22%3Afalse%2C%22gemius%22%3Afalse%2C%22exponea%22%3Afalse%2C%22hotjar%22%3Afalse%2C%22tmobile_reklamni%22%3Afalse%2C%22facebook%22%3Afalse%2C%22inspectlet%22%3Afalse%2C%22cloudflare%22%3Afalse%2C%22google_ads%22%3Afalse%2C%22bing%22%3Afalse%2C%22foxentry_reklamni%22%3Afalse%2C%22clarity%22%3Afalse%2C%22seznam%22%3Afalse%2C%22tmobile_statisticke%22%3Afalse%2C%22google_analytics%22%3Afalse%2C%22rejectAllDate%22%3A%222024-03-28%22%7D"}]},"domains":["t-mobile.cz"],"id":"c7f03541-c93e-4939-a640-7c686d595986"},{"cookies":{"optOut":[{"name":"orange_cookieconsent_dismissed","value":"no"}]},"domains":["orange.sn"],"id":"24350444-6b01-46a5-b8a4-99f4d417f08f"},{"click":{"optIn":".js-consent-all-submit","optOut":".js-consent-bypass-button","presence":".fancybox-type-html"},"cookies":{"optOut":[{"name":"consent","value":"bypass"}]},"domains":["orange.jobs"],"id":"2e026e27-1356-40c8-a25c-24fbe4bf8af4"},{"click":{"optIn":"#consent_optin","optOut":"#consent_optout","presence":"#__tealiumGDPRecModal"},"cookies":{"optOut":[{"name":"CONSENTMGR","value":"c1:0%7Cc2:0%7Cc3:0%7Cc4:0%7Cc5:0%7Cc6:0%7Cc7:0%7Cc8:0%7Cc9:0%7Cc10:0%7Cc11:0%7Cc12:0%7Cc13:0%7Cc14:0%7Cc15:0%7Cts:2524608000000%7Cconsent:false"}]},"domains":["orange.es"],"id":"1626f70d-7761-467c-b3ed-56e324786902"},{"click":{"optIn":"#consent_prompt_submit","presence":"#__tealiumGDPRecModal"},"cookies":{"optOut":[{"name":"CONSENTMGR","value":"c1:0%7Cc6:0%7Cc9:0%7Cts:2524608000000%7Cconsent:false"}]},"domains":["orange.be"],"id":"2172b091-8b03-4f66-b20c-08c14e21c0aa"},{"click":{"optIn":".cookie-agree","optOut":".no-agree > a","presence":"#modal-cookie-info"},"cookies":{"optOut":[{"name":"site_cookie_info_i","value":"2"}]},"domains":["intersport.mk"],"id":"6fdb72ae-429c-49ad-87d3-4ff2675e5d29"},{"click":{"optIn":"#acceptAllCookiesBtn","optOut":"#acceptNecessaryCookiesBtn","presence":"#cookieConsentModal"},"cookies":{"optOut":[{"name":"ConsentV2","value":"[%22necessary%22]"}]},"domains":["intersport.fo"],"id":"1450d6da-220a-42dd-b523-1771343cbd90"},{"click":{"optIn":".js--cookie-banner-accept","optOut":".js--cookie-banner-save-required-settings","presence":".cookie-banner"},"domains":["intersport.de"],"id":"de176046-8be7-4876-8332-0559dfd0b70b"},{"click":{"optIn":".js-accept","optOut":".js-decline","presence":"#fancybox-container-1"},"cookies":{"optOut":[{"name":"ConsentChecked","value":"{\"userHasSetCookies\":true,\"functionalityCookies\":false,\"statisticCookies\":false,\"marketingCookies\":false}"}]},"domains":["intersport.bg","intersport.com.cy","intersport.gr","intersport.ro"],"id":"a8a9ddf7-1cf3-4252-b4f6-6d396e4c7ba7"},{"click":{"optIn":"#CybotCookiebotDialogBodyButtonAccept","optOut":"#CybotCookiebotDialogBodyButtonDecline","presence":"#CybotCookiebotDialog"},"cookies":{"optOut":[{"name":"CookieConsent","value":"{necessary:true%2Cpreferences:false%2Cstatistics:false%2Cmarketing:false%2Cmethod:%27explicit%27%2Cver:1%2Cutc:2524608000000%2Cregion:%27zz%27}"}]},"domains":["intersport.be"],"id":"9c762187-68bd-4d9b-b16c-014236082550"},{"click":{"optIn":"#acceptAllQuick","optOut":"#rejectAllQuick","presence":"#gdpr-component"},"cookies":{"optOut":[{"name":"cookieConsent","value":"%7B%22strictlyNecessary%22:true,%22preferences%22:false,%22marketing%22:false,%22statistics%22:false%7D"},{"name":"cookieConsentVersion","value":"V3"},{"name":"purpose_cookie","value":"1"},{"name":"receiver_cookie","value":"14"}]},"domains":["telekom.sk"],"id":"7b4506b2-1c6f-4afc-ab5f-892331cabad3"},{"click":{"optIn":"#cookiesModal #all-cookies-btn","optOut":"#cookiesModal #required-cookies-btn","presence":"#cookiesModal"},"cookies":{"optOut":[{"name":"cookieConsent","value":"%7B%22strictlyNecessary%22%3Atrue%2C%22marketing%22%3Afalse%2C%22statistics%22%3Afalse%2C%22preferences%22%3Afalse%7D"},{"name":"gdpr","value":"0"}]},"domains":["telekom.mk"],"id":"2858c963-0a13-4c5b-b7e8-c3f9b79c5b8d"},{"click":{"optIn":"#consentAcceptAll","optOut":"#rejectAll","presence":"#__tealiumGDPRecModal"},"cookies":{"optOut":[{"name":"CONSENTMGR","value":"c1:0%7Cc3:0%7Cc7:0%7Cts:2524608000000%7Cconsent:false"}]},"domains":["magentacloud.de","magentasport.de","t-systems.com","t-systems.jobs","telekom-hauptstadtrepraesentanz.com","telekom.com","telekom.de","telekom.jobs"],"id":"8907164e-17d8-4d27-b0a3-edda59f53dbe"},{"click":{"optIn":"#modals #accept-all","optOut":"#modals #decline-all","presence":"#modals"},"cookies":{"optOut":[{"name":"cookies","value":"%7B%22submitted%22%3A%222050-01-01T00%3A00%3A00Z%22%2C%22consent%22%3A%7B%22statistics%22%3Afalse%2C%22marketing%22%3Afalse%7D%7D"}]},"domains":["deutschetelekomitsolutions.sk"],"id":"2f9c701b-8b1f-4f44-82cc-e79d717e390f"},{"click":{"optIn":"#didomi-notice-agree-button","presence":"#didomi-notice"},"cookies":{},"domains":["decathlon.si","t-mobile.pl"],"id":"83ad4c2f-e59a-4295-a342-5db40fb81763"},{"click":{"optIn":".ch2-allow-all-btn","optOut":".ch2-deny-all-btn","presence":".ch2-dialog"},"domains":["cookiehub.com","semrush.com","vodafone.is"],"id":"305b6c0d-5b66-4b3f-bf0f-fb85db21fe60"},{"click":{"optIn":"#didomi-notice-agree-button","optOut":"#didomi-notice-x-button","presence":"#didomi-popup"},"cookies":{},"domains":["decathlon.ee"],"id":"e4b0998b-a54c-458d-935b-6ec957175711"},{"click":{"optIn":"#didomi-notice-agree-button","optOut":"#didomi-notice-disagree-button","presence":"#didomi-popup"},"cookies":{},"domains":["orange-business.com"],"id":"49719e34-a29a-4604-ae3c-b9835e286473"},{"click":{"optIn":"#didomi-notice-agree-button","optOut":"#didomi-notice-disagree-button","presence":"#didomi-popup"},"cookies":{},"domains":["blablacar.be","blablacar.co.uk","blablacar.cz","blablacar.de","blablacar.es","blablacar.fr","blablacar.hr","blablacar.hu","blablacar.it","blablacar.nl","blablacar.pl","blablacar.pt","blablacar.ro","blablacar.sk","decathlon-united.media","decathlon.at","decathlon.be","decathlon.com.dz","decathlon.de","decathlon.pl","decathlon.pt","decathlon.ro","decathlon.sk"],"id":"3b20cf84-991e-4155-8620-4e897d703530"},{"click":{"optIn":"#didomi-notice-agree-button","optOut":".didomi-continue-without-agreeing","presence":"#didomi-notice"},"cookies":{},"domains":["decathlon.cz","decathlon.it","hnonline.sk","orange.md","orange.sk"],"id":"5da98b86-9a16-47ec-8607-046744d93396"},{"click":{"optIn":"#didomi-notice-agree-button","optOut":".didomi-continue-without-agreeing","presence":"#didomi-popup"},"cookies":{},"domains":["decathlon.ch","decathlon.co.uk","decathlon.es","decathlon.fr","decathlon.hu","decathlon.media","decathlon.mt","decathlon.nl","decathlon.yoga","orange.pl","quechua.fr"],"id":"05b53737-a488-4312-b845-72d804872158"},{"click":{"optIn":"#cpnb-accept-btn","optOut":"#cpnb-decline-btn","presence":"#cpnb"},"cookies":{"optOut":[{"name":"cpnb_cookiesSettings","value":"%7B%22required-cookies%22%3A1%2C%22analytical-cookies%22%3A0%2C%22social-media-cookies%22%3A0%2C%22targeted-advertising-cookies%22%3A0%7D"},{"name":"cpnbCookiesDeclined","value":"1"}]},"domains":["vodafone.pf"],"id":"723c6f57-2399-4a6c-bd5e-83650d2db861"},{"click":{"optIn":"#dip-consent-summary-accept-all","optOut":"#dip-consent-summary-reject-all","presence":"#dip-consent"},"domains":["vodafone.de"],"id":"b85f7d67-d6d4-40ee-8472-a32b6cd01e0e"},{"click":{"optIn":"[value=\"allowAll\"]","optOut":"[value=\"saveNecessarily\"]","presence":".vfcc__overlay"},"cookies":{"optOut":[{"name":"vfconsents","value":"\"cvx:5|vt:2524608000000|vn:1|ci:1|funa:o|mktg:o|cond:1|dldt:2524608000000|cvd:5|cvu:5|cdd:2524608000000|vind:1\""}]},"domains":["vodafone.cz"],"id":"ba7bde95-93ff-43fd-845f-b8a396b46480"},{"click":{"optOut":".cookie-banner__close","presence":".cookie-banner"},"cookies":{"optOut":[{"name":"meta_connect_cookies_session","value":"true"}]},"domains":["metaconnect.com"],"id":"529b0511-417d-46e3-a601-4e9c8e662d01"},{"click":{"optIn":"#onetrust-accept-btn-handler","presence":"div#onetrust-consent-sdk"},"cookies":{},"domains":["gitlab.com","speedtest.net","name.com","mlb.com","qualtrics.com","tim.it","hotnews.ro","mashable.com","pcmag.com","barnesandnoble.com","politico.com","quillbot.com","newyorker.com","upwork.com","mediafax.ro","elisa.fi","blick.ch","tvn24.pl","olx.pl","olx.bg","gsp.ro","fastly.com","spotify.com","20min.ch","olx.ro","olx.pt","sportal.bg","gazeta.pl","romaniatv.net","teamviewer.com","ted.com","tripadvisor.com","webmd.com","cambridge.org","investing.com","businesswire.com","istockphoto.com","iso.org","quizlet.com","genius.com","jstor.org","trendmicro.com","duolingo.com","sophos.com","rte.ie","euro.com.pl","wired.com","arstechnica.com","gartner.com","thelancet.com","weebly.com","irishtimes.com","libertatea.ro","otomoto.pl","sport.pl","novini.bg","stiripesurse.ro","suomi24.fi","ziare.com","irishexaminer.com","tripadvisor.it","thejournal.ie","superbet.ro","g4media.ro","wyborcza.pl","nachrichten.at","tt.com","three.ie","tripadvisor.co.uk","dcnews.ro","vol.at","plotek.pl","howstuffworks.com","tripadvisor.de","acer.com","allaboutcookies.org","bankier.pl","brother.co.uk","brother.es","brother.it","digicert.com","epson.co.uk","fiverr.com","frontiersin.org","glassdoor.com","global.brother","gq-magazine.co.uk","ingka.com","inpost.pl","instructure.com","komputronik.pl","mediaexpert.pl","oleole.pl","ookla.com","otodom.pl","play.pl","prnewswire.com","salesforce.com","slack.com","thawte.com","ui.com","uisp.com","vodafone.com.tr","vodafone.it"],"id":"256259D5-28AA-44C4-A837-8A30424005BB"},{"click":{"optIn":"button#popin_tc_privacy_button_2","presence":"div#popin_tc_privacy_container_button"},"cookies":{"optIn":[],"optOut":[{"name":"TC_PRIVACY","value":"1@006%7C86%7C3315@@@1665406595598%2C1665406595598%2C1680958595598@"}]},"domains":["sparkasse.at"],"id":"850ca0e7-372f-4c9f-bfbd-76d38a076cf7"},{"click":{"optIn":".cc-btn.cc-allow","optOut":".cc-btn.cc-deny","presence":".cc-window.cc-banner"},"cookies":{"optOut":[{"name":"cookieconsent_status","value":"deny"}]},"domains":["decathlon.nc","decathlon.re","magnite.com","mecklenburg-vorpommern.de","omv.com","omv.at","omv.bg","omv.de","omv.nz","omv.no","omv.ro","omv.co.rs","omv.sk","omv.cz","omv.tn","omv.ae","omv.hu","omv.si","omv-gas.com","omv-gas.at","omv-gas.be","omv-gas.de","omv-gas.hu","omv-gas.nl","omv-gas.com.tr","omv-gas-storage.com","omvpetrom.com","petrom.ro","petrom.md","avanti.at","avanti-tankstellen.de","diskonttanken.at","tocimceneje.si"],"id":"8f401b10-02b6-4e05-88fa-c37012d4c8c0"},{"click":{"optIn":"button#onetrust-accept-btn-handler","optOut":".ot-pc-refuse-all-handler, #onetrust-reject-all-handler","presence":"div#onetrust-consent-sdk"},"cookies":{},"domains":["espncricinfo.com","blackboard.com","roche.com","apnews.com","nationalgeographic.com","espn.com","hotjar.com","marriott.com","hootsuite.com","wattpad.com","gamespot.com","apa.org","opendns.com","epicgames.com","zendesk.com","drei.at","ikea.com","search.ch","centrum.sk","zoom.us","pluska.sk","hp.com","ceskatelevize.cz","telenet.be","adobe.com","rottentomatoes.com","dhl.com","dhl.de","nvidia.com","cloudflare.com","webex.com","indeed.com","discord.com","sport.ro","ricardo.ch","stirileprotv.ro","1177.se","meinbezirk.at","orange.ro","ica.se","flashscore.pl","kuleuven.be","tutti.ch","post.at","rezultati.com","nbg.gr","behance.net","zemanta.com","grammarly.com","usatoday.com","cnet.com","npr.org","binance.com","linktr.ee","time.com","cisco.com","udemy.com","shutterstock.com","investopedia.com","cbsnews.com","okta.com","appsflyer.com","typepad.com","calendly.com","verisign.com","outbrain.com","zdnet.com","deloitte.com","hdfcbank.com","media.net","docker.com","avast.com","bluehost.com","nba.com","hostgator.com","scientificamerican.com","aljazeera.com","sahibinden.com","rackspace.com","namecheap.com","people.com","branch.io","tv2.dk","criteo.com","trustpilot.com","hm.com","mailchimp.com","surveymonkey.com","mckinsey.com","rollingstone.com","slate.com","dictionary.com","coursera.org","msn.com","chegg.com","variety.com","cnn.com","proximus.be","adevarul.ro","cnbc.com","oe24.at","reuters.com","booking.com","bluewin.ch","viaplay.dk","aib.ie","hbomax.com","rtlnieuws.nl","buienradar.be","viaplay.se","antena3.ro","statista.com","pixabay.com","constantcontact.com","atlassian.com","bmj.com","trendyol.com","meetup.com","vmware.com","bitbucket.org","viaplay.no","asana.com","freepik.com","heute.at","mtvuutiset.fi","buienradar.nl","nypost.com","panasonic.com","safeway.com","amd.com","atg.se","brother.de","brother.eu","brother.fr","corsair.com","crucial.com","dc.com","dn.no","epson.de","epson.es","epson.eu","epson.fr","epson.it","evga.com","fortnite.com","fujitsu.com","global.canon","gpuopen.com","info.lidl","inpost.es","inpost.eu","inpost.it","intel.com","intersport.at","intersport.com","intersport.com.tr","intersport.cz","intersport.dk","intersport.es","intersport.hu","intersport.nl","intersport.sk","kaufland.de","lg.com","lidl.co.uk","lidl.com","lidl.cz","lidl.de","lidl.fr","lidl.it","lidl.pl","lifewire.com","logitech.com","micron.com","mythomson.com","oki.com","otto.de","razer.com","rightmove.co.uk","sbb.ch","seagate.com","soundcloud.com","trello.com","unrealengine.com","vodafone.al","vodafone.co.uk","vodafone.es","vodafone.gr","vodafone.hu","vodafone.ie","vodafone.nl","vodafone.ro","askubuntu.com","mathoverflow.net","serverfault.com","stackapps.com","stackexchange.com","stackoverflow.com","superuser.com","carrefour.fr"],"id":"6c7366a0-4762-47b9-8eeb-04e86cc7a0cc"},{"click":{"optIn":"button#didomi-notice-agree-button","optOut":"button#didomi-notice-disagree-button","presence":"div#didomi-host"},"cookies":{},"domains":["doctolib.fr","pravda.sk","topky.sk","zoznam.sk","tvnoviny.sk","aukro.cz","krone.at","cas.sk","heureka.sk","free.fr","markiza.sk","willhaben.at","francetvinfo.fr","france.tv","france24.com","opodo.at","opodo.ch","opodo.co.uk","opodo.de","opodo.dk","opodo.fi","opodo.fr","opodo.it","opodo.nl","opodo.no","opodo.pl","opodo.pt","radiofrance.fr","rfi.fr","rtl.fr","6play.fr","marianne.net"],"id":"690aa076-4a8b-48ec-b52c-1443d44ff008"},{"click":{"optIn":"button#onetrust-accept-btn-handler","optOut":"button.onetrust-close-btn-handler","presence":"div#onetrust-consent-sdk"},"cookies":{},"domains":["allopneus.com","darty.com","e.leclerc","fnac.be","fnac.ch","fnac.com","fnac.pt","leclercdrive.fr","mondialrelay.fr","pasteur.fr"],"id":"2d821158-5945-4134-a078-56c6da4f678d"},{"click":{"optIn":"#popin_tc_privacy_button_3","optOut":"#popin_tc_privacy_button_2","presence":"#tc-privacy-wrapper"},"domains":["auto5.be","bouyguestelecom.fr","enedis.fr","fortuneo.fr","lcl.fr","norauto-franchise.com","norauto-pro.com","norauto.es","norauto.fr","norauto.it","norauto.pt","tf1.fr","tf1info.fr"],"id":"98D89E26-F4B6-4C2D-BABF-4295B922E433"},{"domains":["tumblr.com","paypal.com","amazon.co.uk","amazon.com.be","amazon.com.tr","amazon.de","amazon.es","amazon.fr","amazon.it","amazon.nl","amazon.pl","amazon.se"],"id":"disabled"},{"cookies":{"optOut":[{"name":"__Secure-HO_Cookie_Consent_Declined","value":"1"}]},"domains":["hetzner.com"],"id":"a8222cf2-8f6c-48df-8215-05a15d4ac592"},{"click":{"optIn":"#didomi-notice-agree-button","presence":"#didomi-popup"},"cookies":{},"domains":["decathlon.bg","decathlon.ca","decathlon.hr","decathlon.ie","decathlon.lt","decathlon.lv","decathlon.se","orange.lu","reverso.net"],"id":"05157ed1-12c2-4f84-9dff-718fae5bc096"},{"click":{"optIn":".t_cm_ec_continue_button","optOut":".t_cm_ec_reject_button","presence":"#__tealiumGDPRecModal"},"cookies":{"optOut":[{"name":"CONSENTMGR","value":"c1:0%7Cc2:0%7Cc3:0%7Cc4:0%7Cc5:0%7Cc6:0%7Cc7:0%7Cc8:0%7Cc9:0%7Cc10:0%7Cc11:0%7Cc12:0%7Cc13:0%7Cc14:0%7Cc15:0%7Cts:2524608000000%7Cconsent:false"}]},"domains":["vodafone.com"],"id":"a4cb7b9f-0a47-4fc8-ac4c-5e9d0d598531"},{"click":{"optIn":"button#didomi-notice-agree-button","optOut":"span.didomi-continue-without-agreeing","presence":"div#didomi-popup"},"cookies":{},"domains":["theconversation.com","leparisien.fr","lesechos.fr","numerama.com","jofogas.hu","orange.com","orange.fr","meteofrance.com","subito.it","hasznaltauto.hu","zdnet.de","zdnet.fr","intersport.fr","leboncoin.fr","boursorama.com","boursobank.com","intermarche.com","bricomarche.com","entrepot-du-bricolage.fr","lesnumeriques.com","seloger.com","societe.com","manomano.fr","pagesjaunes.fr","sncf-connect.com","largus.fr"],"id":"c1d7be10-151e-4a66-b83b-31a762869a97"},{"cookies":{"optOut":[{"name":"gdpr","value":"1"}]},"domains":["kinopoisk.ru","ya.ru","yandex.az","yandex.by","yandex.co.il","yandex.com","yandex.com.am","yandex.com.ge","yandex.com.tr","yandex.ee","yandex.eu","yandex.kz","yandex.lt","yandex.lv","yandex.md","yandex.pt","yandex.ru","yandex.tj","yandex.tm","yandex.uz","yandex.vc"],"id":"37319f5d-9484-4da8-aee1-570a78688da3"},{"click":{"optIn":"button#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"button#CybotCookiebotDialogBodyButtonDecline","presence":"div#CybotCookiebotDialog"},"cookies":{},"domains":["intermarche.be","intermarche.pl","intermarche.pt","intersport.hr","intersport.it","intersport.pl","intersport.si","issuu.com","telekom.ro","voetbal24.be","weforum.org"],"id":"019c0709-e9ef-4b0d-94bf-958d251a51b5"},{"click":{"optIn":"#gdpr-banner-accept","optOut":"#gdpr-banner-decline","presence":"#gdpr-banner"},"domains":["ebay.at","ebay.be","ebay.ca","ebay.ch","ebay.co.uk","ebay.com","ebay.com.au","ebay.com.hk","ebay.com.my","ebay.com.sg","ebay.de","ebay.es","ebay.fr","ebay.ie","ebay.it","ebay.nl","ebay.ph","ebay.pl","ebay.vn"],"id":"1e6d35e7-b907-4f5c-a09a-9f3336ef6e61"},{"click":{"optIn":"[data-t=\"acceptAllBtn\"]","optOut":"[data-t=\"continueWithoutAcceptingBtn\"]","presence":"[data-t=\"cookiesMessage\"]"},"cookies":{"optOut":[{"name":"cookie_policy_agreement","value":"3"},{"name":"dont-track","value":"1"},{"name":"f_c","value":"0"},{"name":"g_p","value":"0"}]},"domains":["chollometro.com","dealabs.com","hotukdeals.com","mydealz.de","pepper.com","pepper.it","pepper.pl","preisjaeger.at"],"id":"069f4d94-8031-4b83-b8f9-89752c5c1353"},{"click":{"optIn":".js-accept","optOut":".js-refuse","presence":".cookie-banner-buttons"},"domains":["emag.bg","emag.hu","emag.ro"],"id":"dbbccc0a-13ba-4cd8-9cf0-32420401be55"},{"click":{"optIn":"#kc-acceptAndHide","optOut":"#kc-denyAndHide","presence":".kc-onsent"},"domains":["intersport.fi","k-ruoka.fi"],"id":"282ff551-ce28-4b7f-9633-eaaa7ce89890"},{"click":{"optIn":"#uc-btn-accept-banner","optOut":"#uc-btn-deny-banner","presence":"#uc-main-banner"},"domains":["zalando.at","zalando.be","zalando.ch","zalando.co.uk","zalando.com","zalando.cz","zalando.de","zalando.dk","zalando.ee","zalando.es","zalando.fi","zalando.fr","zalando.hr","zalando.hu","zalando.ie","zalando.it","zalando.lt","zalando.lv","zalando.nl","zalando.no","zalando.pl","zalando.ro","zalando.se","zalando.si","zalando.sk"],"id":"3203ac4e-2454-4022-90fb-d4f51467ce20"},{"click":{"optIn":".ebu-cookies-layer__modal-buttons > .confirm","presence":"#cookiesModal"},"cookies":{"optOut":[{"name":"OPTOUTCONSENT","value":"1:1&2:0&3:0&4:0"}]},"domains":["vodafone.pt"],"id":"522a2d72-8131-406e-b058-b27ec07808fc"},{"click":{"optIn":"[data-testid=\"uc-accept-all-button\"]","optOut":"[data-testid=\"uc-deny-all-button\"]","presence":"#focus-lock-id"},"domains":["magenta.at","post.ch","rts.ch"],"id":"c40f3982-0372-4cdd-8aea-c150afd8328e"},{"click":{"optIn":"button.cc-banner__button-accept","optOut":"button.cc-banner__button-reject","presence":".cc-banner"},"cookies":{},"domains":["springer.com","nature.com"],"id":"9ab30eae-9592-47b1-b46e-7640c4316f14"},{"click":{},"cookies":{"optIn":[{"name":".consent","value":"fu1-ma1-pe1"}],"optOut":[{"name":".consent","value":"fu0-ma0-pe0"}]},"domains":["galaxus.de"],"id":"cc78c082-2dc6-4287-9a7c-168c591810fd"},{"click":{"optIn":".sp_choice_type_11","presence":".message-container > #notice","runContext":"child"},"cookies":{},"domains":["thetimes.co.uk","qz.com","privacy-mgmt.com","independent.co.uk","gizmodo.com","e24.no","thesun.co.uk","thesun.ie","focus.de","bild.de","computerbild.de","t-online.de","wetteronline.de","chip-kiosk.de","chip.de","chip.info","n-tv.de","newsnow.co.uk","telegraph.co.uk","theguardian.com","faz.net","sueddeutsche.de","rtl.de","gutefrage.net","express.de","tvspielfilm.de","finanzen.net","tag24.de","kino.de","heise.de","bunte.de","golem.de","meinestadt.de","berliner-zeitung.de","karlsruhe-insider.de","wetter.de"],"id":"d42bbaee-f96e-47e7-8e81-efc642518e97"},{"click":{"optIn":"button#didomi-notice-agree-button","presence":"div#didomi-host"},"cookies":{},"domains":["echo24.cz","jeuxvideo.com","24sata.hr","nova.cz","lidovky.cz","jutarnji.hr","vecernji.hr","sport.es","elespanol.com","in-pocasi.cz","20minutes.fr","actu.fr","hbvl.be","naszemiasto.pl","rtbf.be","20minutos.es","sudinfo.be","elpais.com","sinoptik.bg","lequipe.fr","abc.es","gva.be","eltiempo.es","eldiario.es","larazon.es","extra.cz","ladepeche.fr","marmiton.org","poslovni.hr","softonic.com","sydsvenskan.se","telecinco.es","giphy.com","filmstarts.de","funda.nl","idnes.cz","aktualne.cz","blesk.cz","centrum.cz","denik.cz","csfd.cz","hn.cz","moviepilot.de","chip.cz"],"id":"af4c5b38-d210-472b-9a07-21cbe53c85ab"},{"click":{"optIn":"#accept-btn","optOut":"#decline-btn","presence":"#privacy-manager-popin"},"domains":["canalplus.com"],"id":"7b2e3401-697f-440a-b418-8477fcf2cfeb"},{"click":{"optIn":".btn-ok","optOut":".btn-reject","presence":"#cookie-policy-info"},"cookies":{"optOut":[{"name":"isReadCookiePolicyDNT","value":"No"},{"name":"isReadCookiePolicyDNTAa","value":"false"}]},"domains":["asus.com"],"id":"8c949b75-4c7b-4559-8ade-780064af370a"},{"click":{"optOut":".sp_choice_type_13","presence":".message-container > #notice","runContext":"child"},"cookies":{},"domains":["aktuality.sk","sky.it","azet.sk","bloomberg.com","formula1.com"],"id":"ae8f7761-35ff-45b2-92df-7868ca288ad2"},{"click":{"optIn":"#c-bns #c-p-bn","optOut":"#c-bns button.grey","presence":"#cm"},"cookies":{"optOut":[{"name":"cc_cookie","value":"{\"level\":[\"necessary\"],\"revision\":0,\"data\":null,\"rfc_cookie\":false}"}]},"domains":["yazio.com"],"id":"B8CB497B-9E12-49A7-BA2A-B7842CAEDFC3"},{"click":{"optIn":"#rgpd-btn-index-accept","optOut":"#rgpd-btn-index-continue","presence":"#modalTpl"},"domains":["rueducommerce.fr"],"id":"BC3582FC-C5FA-4743-85E8-7E46F67629AB"},{"click":{"optIn":"#cookieConsentAcceptButton","optOut":"#cookieConsentRefuseButton","presence":"#cookieConsentBanner"},"domains":["ldlc.com","ldlc.pro","materiel.net"],"id":"4A767353-98B9-4284-857A-D98DC3ECDFE1"},{"click":{"optIn":"#header_tc_privacy_button_3","optOut":"#header_tc_privacy_button","presence":"#tc-privacy-wrapper"},"domains":["ovh.com","ovhcloud.com","ovhtelecom.fr"],"id":"17B1F270-F499-451C-AED5-5C737106F003"},{"click":{"optIn":"#popin_tc_privacy_button_2","optOut":"#optout_link","presence":"#tc-privacy-wrapper"},"domains":["laredoute.fr"],"id":"9022E9FE-2DC2-48DD-BE4A-EFA8A2C81E2B"},{"click":{"optIn":"#popin_tc_privacy_button_2","optOut":"#popin_tc_privacy_button","presence":"#tc-privacy-wrapper"},"domains":["quechoisir.org","quechoisirensemble.fr"],"id":"5D50AA8D-D00E-4A51-8D32-64965A0575CA"},{"click":{"optIn":"button#footer_tc_privacy_button_3","optOut":"button#footer_tc_privacy_button_2","presence":"div#tc-privacy-wrapper"},"cookies":{},"domains":["labanquepostale.fr"],"id":"6c1ebd2b-867a-40a5-8184-0ead733eae69"},{"click":{"optIn":"button.orejime-Notice-saveButton","optOut":"button.orejime-Notice-declineButton","presence":"div.orejime-Notice"},"domains":["service-public.fr"],"id":"7293dc4c-1d3d-4236-84a6-3c5cb3def55a"},{"cookies":{"optIn":[{"name":"cb","value":"1_2055_07_11_"}],"optOut":[{"name":"cb","value":"1_2055_07_11_2-3"}]},"domains":["threads.net"],"id":"c232eab8-f55a-436a-8033-478746d05d98"},{"click":{"optIn":"#footer_tc_privacy_button","optOut":"#footer_tc_privacy_button_2","presence":".tc-privacy-wrapper.tc-privacy-override.tc-privacy-wrapper"},"domains":["arte.tv","urssaf.fr"],"id":"cc818b41-7b46-46d3-9b17-cf924cbe87d1"},{"click":{"optIn":"button#footer_tc_privacy_button_2","optOut":"button#footer_tc_privacy_button_3","presence":"div#tc-privacy-wrapper"},"cookies":{},"domains":["cdiscount.com","laposte.net","laposte.fr"],"id":"1871561d-65f8-4972-8e8a-84fa9eb704b4"},{"click":{"optIn":"button#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"button#CybotCookiebotDialogBodyButtonDecline","presence":"div#CybotCookiebotDialog"},"cookies":{},"domains":["politiken.dk"],"id":"1006f951-cd51-47cc-9527-5036cef4b85a"},{"click":{"optIn":"#popin_tc_privacy_button","optOut":"#popin_tc_privacy_button_3","presence":"#tc-privacy-wrapper"},"domains":["dpd.com","dpdgroup.com","edf.fr","totalenergies.fr"],"id":"43ad2b6b-a57b-4f7a-9d76-e32e696ddc10"},{"click":{"optIn":".moove-gdpr-infobar-allow-all","optOut":".moove-gdpr-infobar-reject-btn","presence":"#moove_gdpr_cookie_info_bar"},"cookies":{"optIn":[{"name":"moove_gdpr_popup","value":"%7B%22strict%22%3A%221%22%2C%22thirdparty%22%3A%221%22%2C%22advanced%22%3A%221%22%7D"}],"optOut":[{"name":"moove_gdpr_popup","value":"%7B%22strict%22%3A%221%22%2C%22thirdparty%22%3A%220%22%2C%22advanced%22%3A%220%22%7D"}]},"domains":["endorfy.com"],"id":"1be1e4d7-bcad-4fc8-a348-ae64af8bcac7"},{"click":{"optIn":"#popin_tc_privacy_button","optOut":"#popin_tc_privacy_button_2","presence":"#tc-privacy-wrapper"},"domains":["but.fr"],"id":"3030D307-A610-4F3D-B589-D2BE133850D7"},{"click":{"optIn":".ei_btn_typ_validate","optOut":".ei_lb_btnskip","presence":"#cookieLB"},"domains":["creditmutuel.fr"],"id":"1B309A53-16B4-4BBE-91F4-86260A15B8E7"},{"click":{"optIn":"#wt-cli-accept-all-btn","presence":"#cookie-law-info-bar"},"cookies":{"optOut":[{"name":"viewed_cookie_policy","value":"yes"}]},"domains":["krux.tech","silentiumpc.com","spcgear.com"],"id":"04e919eb-13c2-4b37-bf7f-888767888640"},{"click":{"optIn":"#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"#CybotCookiebotDialogBodyLevelButtonLevelOptinDeclineAll","presence":"#cookiebanner"},"domains":["action.com","gog.com"],"id":"04afc564-14b2-4c56-b72d-47a26e121f3b"},{"click":{"optIn":".cc-allow","optOut":".cc-deny","presence":".cc-window"},"cookies":{"optIn":[{"name":"eclipse_cookieconsent_status","value":"allow"}],"optOut":[{"name":"eclipse_cookieconsent_status","value":"deny"}]},"domains":["adoptium.net","eclipse.dev","eclipse.org","glassfish.org","jakarta.ee","mbse-capella.org","oniroproject.org","open-vsx.org","openmdm.org","osgi.org","planeteclipse.org"],"id":"92361e84-664e-46b3-ae55-95bc185dc88e"},{"click":{"optIn":".cc-allow","optOut":".cc-dismiss","presence":".cc-window"},"domains":["dell.com","dell.eu","delltechnologies.com"],"id":"f1849b07-95e8-4ae0-a99d-24df5abbb3cb"},{"click":{"optIn":"#btn-allowAllCookie","optOut":"#btn-rejectAllCookie","presence":"#cc-window"},"cookies":{"optIn":[{"name":"_youtube_vimeo_vid","value":"allow"},{"name":"cookieControllerStatus","value":"allow"},{"name":"functionalCookieStatus","value":"allow"},{"name":"googleAnalyticsCookieStatus","value":"allow"}],"optOut":[{"name":"_youtube_vimeo_vid","value":"deny"},{"name":"cookieControllerStatus","value":"deny"},{"name":"functionalCookieStatus","value":"deny"},{"name":"googleAnalyticsCookieStatus","value":"deny"}]},"domains":["verbatim.co.il"],"id":"3c0e4924-29ee-4d9a-99ec-e4805a7ffed9"},{"click":{"optIn":"#cookiescript_accept","optOut":"#cookiescript_reject","presence":"#cookiescript_injected_wrapper"},"domains":["deskmodder.de","zyxel.com"],"id":"7AF1C34C-750E-44FC-A3C4-31FB61EBF71B"},{"click":{"optOut":"button[data-js-item=\"privacy-protection-default\"]","presence":".c-privacy-protection-banner"},"cookies":{},"domains":["bundeswehr.de"],"id":"52ad1edd-5696-482c-855d-a8d669f9e7f5"},{"click":{},"cookies":{"optOut":[{"name":"cookiehint","value":"{\"matomo\":0}"}]},"domains":["dataport.de"],"id":"1ae88c1b-2b26-49b2-98d0-f6b14a85e376"},{"click":{},"cookies":{"optOut":[{"name":"dp-cookie-consent","value":"false"}]},"domains":["bob-sh.de","bolapla-sh.de"],"id":"a70791ff-0001-4238-b68f-9ba8f1c00c96"},{"click":{},"cookies":{"optOut":[{"name":"BayernMatomo","value":"deaktiviert"}]},"domains":["bayern.de"],"id":"07228673-9d62-4c00-b18d-37e0fcfd37e7"},{"click":{},"cookies":{"optOut":[{"name":"gsbbanner","value":"closed"}]},"domains":["bmbf.de","bmj.de","bva.bund.de","bundesrechnungshof.de","schleswig-holstein.de","zoll.de"],"id":"b2a17900-dc1f-4273-bb0e-10e73c6f63bd"},{"click":{},"cookies":{"optOut":[{"name":"isTrackingConsentGiven","value":"false"}]},"domains":["bund.de"],"id":"431be341-e09a-4fb5-beac-3c4366caaaa0"},{"click":{"optIn":"#privacy-init-wall-button-accept","optOut":"#privacy-init-wall-button-deny","presence":"#privacy-init-wall"},"domains":["comdirect.de"],"id":"5DC4F89B-2A66-4B91-AE73-87954F3A0B4A"},{"click":{"optIn":"#ccmgt_explicit_accept","presence":"#GDPRConsentManagerContainer"},"domains":["stepstone.de"],"id":"3FD9FDA8-5F69-46C4-BA33-35FE3C804B4C"},{"click":{"optIn":"[data-testid=\"as24-cmp-accept-all-button\"]","presence":"#as24-cmp-popup"},"domains":["autoscout24.at","autoscout24.de"],"id":"46FECFD3-2384-450A-8CCC-53BCFE65DF4C"},{"click":{"optIn":".lnc-acceptCookiesButton","optOut":".lnc-declineCookiesButton","presence":".lnc-firstRunPopup"},"domains":["jw.org"],"id":"45AEAD27-6328-4B26-A235-4EA4D74A829E"},{"click":{"optIn":".cmp-accept","presence":"#cmp-modal"},"domains":["gamestar.de"],"id":"7D7FA535-719F-4637-8DE0-9F90B17AD7A7"},{"click":{"optIn":"#consent_wall_optin","optOut":"#consent_wall_optout","presence":"#consent-wall"},"domains":["1und1.de"],"id":"C553BBDC-632F-4F18-AA7D-D6C090E7A7A2"},{"click":{"optIn":".ccm--save-settings","optOut":".ccm--decline-cookies","presence":"#ccm-widget"},"domains":["kaufmich.com"],"id":"72A1389D-943D-4BF0-93D5-F274F7FD3CF2"},{"click":{"optIn":".kick__data-grid__main .kick__btn","presence":"#kick__logi-container"},"domains":["kicker.de"],"id":"E220B441-CAE6-4E4B-9F5D-BA167AE06812"},{"click":{"optIn":"#cookieBtnAll","optOut":"#cookieBtnContinue","presence":".cookie_consent_withings"},"domains":["withings.com"],"id":"0132691F-247B-4CB9-BF9B-0EB61B7435F3"},{"click":{},"cookies":{"optOut":[{"name":"cookiebanner","value":"closed"}]},"domains":["thw.de","service.bund.de"],"id":"58226c30-e975-42f3-99e4-ca140b91e96c"},{"click":{"optIn":".js-accept-cookies","optOut":".js-reject-cookies","presence":".js-consent-banner"},"cookies":{"optOut":[{"name":"OptanonAlertBoxClosed","value":"2030-01-01T00:00:00.000Z"}]},"domains":["stackoverflow.blog","stackoverflow.co","stackoverflowteams.com"],"id":"71443ce9-15b8-4e07-b51b-1f2158521ea9"},{"cookies":{"optOut":[{"name":"js-cookie-opt-in__consent","value":"needed"}]},"domains":["anexia.com","netcup.com","netcup.de","netcup.eu","netcup-news.de","netcup-sonderangebote.de"],"id":"dea34d82-9c05-4c08-9262-18a7f62be91e"},{"click":{},"cookies":{"optOut":[{"name":"cookie-allow-necessary","value":"1"},{"name":"cookie-allow-tracking","value":"0"},{"name":"cookie-banner","value":"hide"}]},"domains":["bundesfinanzministerium.de","bundesregierung.de"],"id":"84f68b1a-18a2-478c-bc8e-9ec32d4e3e80"},{"click":{"optIn":"a.cc-dismiss","presence":"div.cc-compliance"},"cookies":{"optIn":[{"name":"cookieconsent_status","value":"dismiss"}]},"domains":["021.rs","photobucket.com","brandenburg.de"],"id":"5371fb3e-3242-4864-9443-62116afe5f3c"},{"click":{"optIn":"a.cmpboxbtnyes ","presence":"div#cmpbox"},"cookies":{},"domains":["hoerzu.de","nzz.ch"],"id":"a2404864-0163-4f71-ab4c-915713f8f349"},{"click":{"optIn":"[data-cookieman-accept-all]","optOut":"[data-cookieman-accept-none]","presence":"#cookieman-modal"},"domains":["hfm-frankfurt.de"],"id":"5FF5EEB9-1045-4ACF-8A12-0630B71063F6"},{"click":{},"cookies":{"optOut":[{"name":"paydirektCookieAllowed","value":"false"},{"name":"paydirektCookieAllowedPWS","value":"{%22necessary%22:true,%22analytics%22:false}"}]},"domains":["paydirekt.de"],"id":"769dcf5b-afd1-438d-940d-3069ff4b2f51"},{"click":{"optIn":"button.iubenda-cs-accept-btn","optOut":"button.iubenda-cs-reject-btn","presence":"div#iubenda-cs-banner"},"cookies":{},"domains":["giallozafferano.it","virgilio.it","upfit.de","treedom.net"],"id":"65638975-8222-425c-9be0-3f41a51db13c"},{"click":{"optOut":"#zdf-cmp-deny-btn","presence":".zdf-cmp-modal-content"},"cookies":{},"domains":["zdf.de","3sat.de"],"id":"91484461-01AD-4D78-9ED8-D17C688F47E7"},{"click":{"optIn":".root__OblK1:not(.secondaryButton__N1rJw)","optOut":".root__OblK1.secondaryButton__N1rJw","presence":".root__XMKIj"},"cookies":{},"domains":["forbes.com"],"id":"30293090-f064-473a-ae0f-cd390507c1c7"},{"click":{"optIn":"[href=\"#accept\"]","optOut":"[href=\"#refuse\"]","presence":"div#cookie-consent-banner"},"cookies":{"optOut":[{"name":"cck1","value":"%7B%22cm%22%3Atrue%2C%22all1st%22%3Afalse%2C%22closed%22%3Atrue%7D"}]},"domains":["europa.eu"],"id":"0c74749a-8c53-4bb0-b31a-ab2f89b7f493"},{"click":{"optIn":".CookieBanner_buttonContainer__NOZxH:nth-child(1) button","optOut":".CookieBanner_buttonContainer__NOZxH:nth-child(2) button","presence":".CookieBanner_cookieBanner__R_BOh"},"domains":["cbinsights.com"],"id":"4CE0ADCF-E232-4F3B-981B-CA83A0C40874"},{"click":{"optIn":".modal-box__buttons--save-all","presence":".new-policy-box"},"cookies":{"optIn":[{"name":"polityka15","value":"security_storage%3Dtrue%26functionality_storage%3Dtrue%26analytics_storage%3Dtrue%26personalization_storage%3Dtrue%26ad_storage%3Dtrue"}],"optOut":[{"name":"polityka15","value":"security_storage%3Dtrue%26functionality_storage%3Dfalse%26analytics_storage%3Dfalse%26personalization_storage%3Dfalse%26ad_storage%3Dfalse"}]},"domains":["nazwa.pl"],"id":"ddff9528-161c-471e-bd2d-ba4d874a3931"},{"click":{"optIn":".cc-dismiss","optOut":".cc-deny","presence":".cc-window"},"cookies":{"optIn":[{"name":"cookieconsent_status","value":"dismiss"}],"optOut":[{"name":"cookieconsent_status","value":"deny"}]},"domains":["zotac.com"],"id":"4159a3d2-f331-4d56-b051-a753c7e1308a"},{"click":{"optIn":"[onclick*=\"cookie_Agree()\"]","optOut":"[onclick*=\"cookie_Disagree()\"]","presence":"#legal_notice"},"domains":["transcend-info.com"],"id":"5e0387bb-1f19-4f61-b587-49d995a691c9"},{"click":{"optIn":".tp-cookie-accept-all","presence":"#tp-cookie"},"cookies":{"optIn":[{"name":"tp_privacy_base","value":"1"},{"name":"tp_privacy_marketing","value":"1"}],"optOut":[{"name":"tp_privacy_base","value":"1"}]},"domains":["tp-link.com"],"id":"48e9b863-c642-4a7a-9ee5-c085d337233e"},{"click":{"optIn":".acceptAll","presence":".privacyArea"},"cookies":{"optIn":[{"name":"privacy","value":"{\"necessary\":\"ok\",\"functional\":\"ok\",\"marketing\":\"ok\"}"}],"optOut":[{"name":"privacy","value":"{\"necessary\":\"ok\"}"}]},"domains":["teamgroupinc.com"],"id":"9034f6e4-09ca-42a2-a8da-4f65968b8b36"},{"click":{"optIn":".btn_accept","presence":".syno_cookie_element"},"cookies":{"optIn":[{"name":"syno_confirm_v4_answer","value":"{\"necessary\":true,\"performance\":true,\"functionality\":true,\"targeting\":true}"}],"optOut":[{"name":"syno_confirm_v4_answer","value":"{\"necessary\":true,\"performance\":false,\"functionality\":false,\"targeting\":false}"}]},"domains":["synology.cn","synology.com"],"id":"d01204bd-8a94-4e6e-8ce4-d155b0681053"},{"click":{"optIn":"#cp-yes","optOut":"#cp-no","presence":"#cp-overlay"},"cookies":{"optIn":[{"name":"cookiepermission","value":"yes"}],"optOut":[{"name":"cookiepermission","value":"no"}]},"domains":["seasonic.com"],"id":"6c9b123a-ec42-4128-91a2-a4cdd65059bc"},{"click":{"optIn":"[value=\"Accept\"]","optOut":"[value=\"Reject\"]","presence":"#pp_info"},"domains":["gainward.com","palit.com"],"id":"c79fc6da-0143-46a0-abfc-debbd4d05f4b"},{"click":{"optIn":"#Footer_butAccept","optOut":"#Footer_butCancel","presence":"#Footer_Cookie"},"domains":["cablexpert.be","cablexpert.com","cablexpert.de","cablexpert.gr","cablexpert.nl","energenie.com","gembird.be","gembird.com","gembird.com.pl","gembird.es","gembird.nl","gembird3.com","gembird3.nl","gmb-online.nl","gmb.nl"],"id":"f7aa3175-3c2a-4458-b822-da0bd57c2524"},{"click":{"optIn":"#Cookies_consent_btn","optOut":"#Cookies_consent_internal_btn","presence":"#qkies_info"},"cookies":{"optIn":[{"name":"cookiesconsent","value":"true"}],"optOut":[{"name":"cookiesconsent","value":"internal"}]},"domains":["dreammachines.by","dreammachines.eu","dreammachines.io","dreammachines.nl","dreammachines.pl","dreammachines.ru"],"id":"c8cb50a3-7604-4de0-a0ac-c2e7b0ad45c0"},{"click":{"optIn":"[name=\"accept\"]","presence":".ck-notiz"},"cookies":{"optIn":[{"name":"cookieSettings","value":"%7B%22necessary%22%3Atrue%2C%22analytics%22%3Atrue%2C%22thirdParty%22%3Atrue%2C%22dismissed%22%3Atrue%7D"}],"optOut":[{"name":"cookieSettings","value":"%7B%22necessary%22%3Atrue%2C%22analytics%22%3Afalse%2C%22thirdParty%22%3Afalse%2C%22dismissed%22%3Atrue%7D"}]},"domains":["creative.com"],"id":"32fc1292-e26f-49c8-8de8-c41966c0bd34"},{"click":{"optIn":".cookie-accept","optOut":"#cookie-accept-technical","presence":".cookie-banner"},"cookies":{"optIn":[{"name":"_CookiePolicyHint","value":"true"},{"name":"cookie_functional","value":"on"},{"name":"cookie_marketing","value":"on"}],"optOut":[{"name":"_CookiePolicyHint","value":"true"}]},"domains":["bequiet.com"],"id":"de38e8a0-25d2-42d2-974d-04684e54b7ce"},{"click":{"optIn":"#cookiesPrivacyPolicyAllowBtn","optOut":"#cookiesPrivacyPolicyDenyBtn","presence":"#cookiesPrivacyPolicyContainerWrapper"},"cookies":{"optIn":[{"name":"cookiesPrivacyPolicy","value":"1"},{"name":"cookiesPrivacyPolicyExtended","value":"1"}],"optOut":[{"name":"cookiesPrivacyPolicy","value":"1"},{"name":"cookiesPrivacyPolicyExtended","value":"0"}]},"domains":["akyga.com"],"id":"3bf04e3c-efe8-49af-bf80-506f12ba2da4"},{"click":{"optIn":"button.fcQwZX","optOut":"button.fLZgds","presence":".kDNyTh.hbTFXs"},"domains":["androidpolice.com"],"id":"5B57603A-0CE0-4511-B324-18D34F60EC51"},{"click":{"optIn":"button[data-testid=\"allow-all-cookies-button\"]","optOut":"div[data-testid=\"cookie-popover\"] button:nth-child(2)","presence":"div[data-testid=\"cookie-popover\"]"},"domains":["ondo.finance"],"id":"50105C82-FEDE-424E-884D-430FA7BCBED"},{"click":{"optIn":"#gdpr-cookie-accept","presence":"#gdpr-cookie-message"},"cookies":{"optIn":[{"name":"cookieControl","value":"true"},{"name":"cookieControlPrefs","value":"[\"analytics\",\"marketing\"]"}],"optOut":[{"name":"cookieControl","value":"true"},{"name":"cookieControlPrefs","value":"[]"}]},"domains":["teamspeak.com"],"id":"8005fd7b-26ec-43c0-ad94-1c6834cc7905"},{"click":{},"cookies":{"optIn":[{"name":"happycow-cookie-policy","value":"1"}],"optOut":[{"name":"happycow-cookie-policy","value":"0"}]},"domains":["happycow.net"],"id":"4710a874-0ff4-4072-8476-36a22d7f698e"},{"click":{},"cookies":{"optIn":[{"name":"cookiebanner_accepted","value":"1"}]},"domains":["raspberrypi.com"],"id":"61dfb6a1-21b4-4f95-aa6d-946eb09f8511"},{"click":{"optOut":"button.js-decline-all-cookies","presence":"div.cookie-consent-spice"},"cookies":{},"domains":["thomann.de"],"id":"5aa2d4df-2a5d-4abf-bb5a-bd714951f790"},{"click":{"optIn":"button[data-testid=\"gdpr-btn-accept-all\"]","optOut":"button[data-testid=\"gdpr-btn-refuse-all\"]","presence":"[data-testid=\"cookie-banner\"]"},"domains":["deezer.com"],"id":"5bdcb3ce-6270-4270-af7b-d1fdef5cecb4"},{"click":{"optIn":"button[data-cookie_consent=\"1\"]","optOut":"button[data-cookie_consent=\"0\"]","presence":"#js_reveal_cookie_content"},"cookies":{},"domains":["voelkner.de"],"id":"bcf09922-64d7-4879-974a-119e8bd05fee"},{"click":{"optIn":"button[data-qa=\"privacy-settings-action-info\"]","optOut":"button[data-qa=\"privacy-settings-action-close\"]","presence":"[data-qa=\"privacy-settings\"]"},"domains":["lieferando.de","lieferando.at","just-eat.ch"],"id":"31d9971f-e23d-4dd9-a891-99a85d97ad19"},{"click":{"optIn":"button.osano-cm-accept-all","optOut":".osano-cm-denyAll","presence":"div.osano-cm-dialog__buttons"},"cookies":{},"domains":["slideshare.net","ieee.org","linuxfoundation.eu"],"id":"23710ccf-85e6-450e-953d-7ffc3f80bbf0"},{"click":{"optIn":"button#ccc-recommended-settings","optOut":"button#ccc-reject-settings","presence":"div#ccc"},"cookies":{},"domains":["metoffice.gov.uk","footballmanager.com","sigames.com"],"id":"9e4d932a-eaf9-44e4-a3ac-55861d66a7c3"},{"click":{},"cookies":{"optOut":[{"name":"cookieDeclined","value":"1"}]},"domains":["grundstoff.net"],"id":"ca62d977-4e2e-48ab-a186-055f9f3277e4"},{"click":{},"cookies":{"optOut":[{"name":"onleiheTracking","value":"false"}]},"domains":["onleihe.de"],"id":"c19b1009-d609-438c-8d7c-82fc7144eeaa"},{"click":{"optIn":"button.cm-btn-success","optOut":"button.cm-btn-danger","presence":"div#klaro"},"cookies":{},"domains":["karlsruhe.de"],"id":"63b5c74c-67ae-47f2-b0ba-10c03132ad6f"},{"click":{"optIn":"button.js-cookie-accept","optOut":"button.js-cookie-decline","presence":"div#toast-container"},"domains":["startnext.com"],"id":"312f32e1-a6bf-4e87-b7a6-7480345823cf"},{"click":{"optIn":".consentAgree","optOut":"#consentDisagree","presence":"div.consent"},"cookies":{},"domains":["strato.de"],"id":"18b1dd86-aee5-4697-b601-4fa320a75dbe"},{"click":{},"cookies":{"optOut":[{"name":"hidecookie","value":"true"}]},"domains":["vrn.de"],"id":"0ae7f461-8705-4222-b8ee-afa03e5150ff"},{"click":{},"cookies":{"optOut":[{"name":"consent_functional","value":"DENY"},{"name":"consent_marketing","value":"DENY"},{"name":"consent_technical","value":"ALLOW"},{"name":"consent_version","value":"2.6"}]},"domains":["huk24.de"],"id":"0fbacecc-fbda-4e4b-883f-9424790ccc74"},{"click":{},"cookies":{"optOut":[{"name":"cookie-preference","value":"1"}]},"domains":["korodrogerie.de"],"id":"cdd5646d-06b3-4fdf-8530-b7d8a93f03df"},{"click":{"optIn":"button.cl-consent__btn","optOut":"button.cl-consent__close-link","presence":"div#cl-consent"},"cookies":{},"domains":["hdblog.it","hdmotori.it"],"id":"342bd7ca-6502-4df7-bd3a-0b884b51aaa7"},{"click":{},"cookies":{"optOut":[{"name":"cookies_accepted","value":"false"}]},"domains":["mindfactory.de"],"id":"aa077f01-0574-4f1b-ad1b-3225c4dc59f7"},{"click":{"optIn":"button#cookieok","optOut":"button#cookiecancel","presence":"div#cookieconsent"},"cookies":{},"domains":["reichelt.de"],"id":"b81fc066-5cdd-4af6-b288-49de860e369a"},{"click":{"optIn":"button#cookie-consent-button","presence":"dialog.consent"},"domains":["computerbase.de"],"id":"2c73714d-0e9b-41a1-ad12-6bd15ddade67"},{"click":{"optIn":"button.cm-btn-accept-all","optOut":"button.cm-btn-accept","presence":"div#klaro"},"cookies":{},"domains":["lancom-systems.de"],"id":"efc6f62d-8d53-4f52-9dd3-172d9b04f5de"},{"click":{"optIn":"button.iubenda-cs-accept-btn","presence":"div#iubenda-cs-banner"},"cookies":{},"domains":["ansa.it"],"id":"8e55f0f4-262f-4d35-a461-47afea6e9069"},{"click":{"optIn":"button[data-component-name=\"consent\"]","optOut":"button[data-component-name=\"reject\"]","presence":".cookie-notice-banner"},"cookies":{},"domains":["shopify.com"],"id":"531324c9-83ba-4ba3-a488-3ebde87b10af"},{"click":{"optOut":"#tmart-cookie-layer-only-necessary","presence":".cookieLayer"},"cookies":{},"domains":["sparda-hessen.de"],"id":"0EAF9E99-36C6-4165-87BE-A62EF1751E1D"},{"click":{"optIn":"[data-testid=\"accept-all-cookies-button\"]","presence":"[data-testid=\"cookie-banner\"]"},"cookies":{},"domains":["elsevier.com"],"id":"0AB3A01E-10A9-4509-9350-6EF61AB223F3"},{"click":{"optIn":".cky-btn.cky-btn-accept","optOut":".cky-btn.cky-btn-reject","presence":".cky-consent-bar"},"cookies":{},"domains":["met.ie"],"id":"536f8027-111f-4798-a9ef-745b30fe65c8"},{"click":{"optIn":".sp_choice_type_11","presence":".message-container > #notice","runContext":"child","skipPresenceVisibilityCheck":true},"cookies":{},"domains":["hln.be","nu.nl","vg.no","aftonbladet.se","voetbalzone.nl","ad.nl","finn.no","sporza.be","derstandard.at","tori.fi","vrt.be","spiegel.de","aftenposten.no","vglive.no","oikotie.fi","klart.se","zeit.de","gala.de","gala.fr","volkskrant.nl","tek.no","omni.se","dpgmediagroup.com","economist.com","chefkoch.de","sport1.de","tagesspiegel.de","stern.de","sport.de","giga.de","2dehands.be","handelsblatt.com"],"id":"c58a0bac-3a5f-43af-93e9-8b5462a6bcb5"},{"click":{"optIn":"button.cb_accept","presence":"[data-module=\"cookieBanner\"]"},"cookies":{"optIn":[{"host":"ok.ru","name":"cookieChoice","value":"\"PRIVACY,1,2,3\"","unsetValue":"\"\""}],"optOut":[{"host":"ok.ru","name":"cookieChoice","value":"PRIVACY","unsetValue":"\"\""}]},"domains":["ok.ru"],"id":"384b70c3-2458-4dc9-ac6f-d9c5e90cc62a"},{"click":{"optIn":"button#didomi-notice-agree-button","presence":"div#didomi-host"},"cookies":{"optOut":[{"name":"euconsent-v2","value":"CPgejgAPgejgAAHABBENCjCgAAAAAAAAAATIAAAAAACBoAMAAQSCEQAYAAgkEKgAwABBIIZABgACCQQA.YAAAAAAAAAAA"}]},"domains":["b92.net","index.hr","abv.bg","orf.at","expressen.se","nieuwsblad.be","independent.ie","telegraaf.nl","as.com","njuskalo.hr","slobodnadalmacija.hr","dnevnik.hr","nova.bg","mundodeportivo.com","dn.se","ouest-france.fr","standaard.be","heureka.cz","bfmtv.com","filmweb.pl","expresso.pt","lavanguardia.com","idealista.com","idealista.pt","di.se","hola.com","lesoir.be","vesti.bg","gloria.hr","huffingtonpost.es","rtl.be","gong.bg","okdiario.com","dhnet.be","lecturas.com","elperiodico.com","dumpert.nl"],"id":"77885432-826b-4d03-bb3d-dfdd36015a82"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons-container"},"cookies":{},"domains":["24chasa.bg"],"id":"97ba1ec3-c8e7-45a0-845f-c732b71bd213"},{"click":{"optIn":".qxOn2zvg.e1sXLPUy","presence":".ulheJb0a"},"cookies":{},"domains":["wykop.pl"],"id":"0caa99d5-2b67-44e1-bd45-509d8e785071"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons-container"},"cookies":{},"domains":["plovdiv24.bg"],"id":"1dbf0b53-df44-472c-a126-13740e9d2e39"},{"click":{"optIn":"button#gdpr-consent-banner-accept-button","presence":"div.gdpr-consent-modal-footer"},"cookies":{},"domains":["marktplaats.nl"],"id":"2cb11bb1-1d52-45c7-a764-9d2e2be6c310"},{"click":{"optIn":".css-15sam98","optOut":".css-1tpwlwl","presence":".css-1243dq3"},"cookies":{},"domains":["figma.com"],"id":"e0dd9ba6-6514-4618-a405-3b6458c13272"},{"click":{"optIn":"[data-testid=\"cookie-wall-accept\"]","optOut":"[data-testid=\"cookie-wall-reject\"]","presence":"[data-testid=\"cookie-wall-modal\"]"},"cookies":{},"domains":["change.org"],"id":"1c3ab910-8635-4007-8ea3-8aeea0c56143"},{"click":{"optIn":".dialog-actions-accept-btn","optOut":".dialog-actions-decline-btn","presence":"[data-testid=\"cookie-dialog-root\"]"},"cookies":{"optIn":[{"name":"sq","value":"3"}],"optOut":[{"name":"sq","value":"0"}]},"domains":["nike.com"],"id":"719a0a85-a706-4393-9668-0b7123891058"},{"click":{"optIn":".agree-button.eu-cookie-compliance-default-button","optOut":".eu-cookie-compliance-default-button.eu-cookie-compliance-reject-button","presence":".eu-cookie-compliance-banner.eu-cookie-compliance-banner-info.eu-cookie-compliance-banner--categories"},"cookies":{"optIn":[{"name":"_hjFirstSeen","value":"1"}]},"domains":["nokia.com"],"id":"c18ccca7-1b7d-4022-b9ca-c725e6030c80"},{"click":{"optIn":"#accept_all_cookies_button","optOut":"#decline_cookies_button","presence":"#ccpa_consent_banner","runContext":"child"},"cookies":{},"domains":["dropbox.com"],"id":"7f82a27a-eaf8-4c16-b15e-66b5efe62fa2"},{"click":{"optIn":"div._2j0fmugLb1FgYz6KPuB91w  > button","optOut":"div._2j0fmugLb1FgYz6KPuB91w  > button + button","presence":"div#cookie-banner, #wcpConsentBannerCtrl"},"cookies":{},"domains":["microsoft.com","office.com"],"id":"f899d35e-20af-4cfb-9856-143a80b86ba9"},{"click":{"optIn":"#cookie-disclosure-accept","optOut":"#cookie-disclosure-reject","presence":"#cookie-disclosure"},"cookies":{},"domains":["netflix.com"],"id":"6037802d-9a37-4df2-bf35-9ad60c478725"},{"click":{"optIn":"#bbccookies-continue-button","presence":"#bbccookies"},"cookies":{},"domains":["bbc.com","bbc.co.uk"],"id":"e9a07bcd-28b5-4034-a663-c017e6a8208e"},{"click":{"optIn":".css-1e382ig","optOut":".css-7gbax3","presence":"#qc-cmp2-container"},"cookies":{},"domains":["nemzetisport.hu"],"id":"da1104e6-0ce0-4956-bd53-fd13c5c2c90b"},{"click":{"optIn":"button.css-1kpvtti","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["voetbalprimeur.nl"],"id":"17c60799-e59b-475f-8007-fec046609121"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons-container"},"cookies":{},"domains":["rtl.hr"],"id":"1d9f6559-cbc8-4cdb-b5f5-ca24844621d3"},{"click":{"optIn":"a.wscrOk","presence":"div.wscrBannerContent"},"cookies":{},"domains":["nordea.com"],"id":"fe09c786-b60e-455e-abd6-212c8878f06a"},{"click":{"optIn":".css-ofc9r3","optOut":".css-1jlb8eq","presence":"#qc-cmp2-container"},"cookies":{},"domains":["car.gr"],"id":"690ce1d3-e595-4181-a109-8f55c1039c81"},{"click":{"optIn":"button#minf-privacy-accept-btn-screen1-id","presence":"div.minf-privacy-rationale"},"cookies":{},"domains":["mediaset.it"],"id":"a54d7325-5847-4f20-815f-a938dacd81b4"},{"click":{"optIn":"button#accept-ufti","presence":"div.Modal__Content-sc-1sm9281-2"},"cookies":{},"domains":["blocket.se"],"id":"12b031c4-abfd-4156-a83c-5e8418f4a866"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons"},"cookies":{},"domains":["abola.pt"],"id":"8e8f6719-0350-4310-8cc1-c00bb51b72b0"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-dialog-container"},"cookies":{},"domains":["sme.sk","ripost.hu","fanatik.ro","net.hr","freemail.hu","marica.bg","dn.pt","imhd.sk"],"id":"5fd67d61-aaa7-4431-af6f-0f1c31c849fc"},{"click":{"optIn":".fc-button-label","presence":".fc-consent-root"},"cookies":{},"domains":["framar.bg"],"id":"ff5b2d52-6cc0-47e5-a515-4a31c9207b81"},{"click":{"optIn":"#pt-accept-all","optOut":".pt-k2L","presence":".pt-VnJ"},"cookies":{},"domains":["dagospia.com"],"id":"794449a7-94aa-402a-a32c-3859bec7eff8"},{"click":{"optIn":"button#button_i_accept","presence":"div#consent-info"},"cookies":{"optIn":[{"name":"cookiesconsent","value":"eyJwZXJzb25hbGFkIjp0cnVlLCJsYXN0dmlzaXRlZCI6dHJ1ZX0"}]},"domains":["alo.bg"],"id":"9dcffb37-fccc-4c6f-9127-e9d2b0db7521"},{"click":{"optIn":".css-2rlcm4","presence":"#qc-cmp2-container"},"cookies":{},"domains":["borsonline.hu"],"id":"a1d99e05-e32c-4cf1-931c-25c8baf538ae"},{"click":{"optIn":"#iubenda-cs-accept-btn iubenda-cs-btn-primary","presence":"div#iubenda-cs-banner"},"cookies":{},"domains":["3bmeteo.com"],"id":"2625ca4e-dd77-4e72-a6d0-c959f3575ad8"},{"click":{"optOut":".CookiesAlert_cookiesAlert__3qSl1 .Button_button__3Me73","presence":".CookiesAlert_cookiesAlert__3qSl1"},"domains":["traderjoes.com"],"id":"87cbcbb6-b531-4c9c-889a-aaa5678c06c5"},{"click":{"hide":"section[aria-label=\"GDPR\"]","optOut":"#cancel","presence":"#gdpr"},"cookies":{"optOut":[{"name":"cookies_ok","value":"false"}]},"domains":["project529.com"],"id":"a029bf7e-3274-4877-967e-e7517457ac18"},{"click":{"optIn":".cookielaw-banner .btn-default","presence":".cookielaw-banner"},"cookies":{"optIn":[{"name":"cookielaw","value":"1"}]},"domains":["openwrt.org"],"id":"14ea41fa-68ac-4c12-b906-7d2a259d5fb7"},{"click":{"optIn":"div[data-name=\"comp-banner\"] button[aria-label=\"Dismiss\"]","presence":"div[data-name=\"comp-banner\"]"},"cookies":{"optIn":[{"name":"cookieNotification","value":"true"}]},"domains":["vegetology.com"],"id":"f7633fd9-05a0-4c21-b9e7-acfcd5df5234"},{"click":{"optIn":"button#didomi-notice-agree-button","presence":"div#didomi-host"},"domains":[],"id":"didomi"},{"click":{"optIn":".banner-actions-container > #onetrust-accept-btn-handler, #onetrust-button-group > #onetrust-accept-btn-handler, .onetrust-banner-options > #onetrust-accept-btn-handler","optOut":".banner-actions-container > #onetrust-reject-all-handler, #onetrust-button-group > #onetrust-reject-all-handler, .onetrust-banner-options > #onetrust-reject-all-handler","presence":"#onetrust-consent-sdk"},"domains":[],"id":"onetrust"},{"click":{},"cookies":{"optOut":[{"name":"consentLevel","value":"1"},{"name":"euconsent-bypass","value":"1"}]},"domains":["web.de","gmx.net"],"id":"290db348-ced2-4f16-9954-da476d0aef01"},{"click":{"optIn":"div.duet--cta--cookie-banner button.py-12","optOut":"div.duet--cta--cookie-banner button.text-blurple","presence":"div.duet--cta--cookie-banner"},"cookies":{},"domains":["theverge.com"],"id":"323bae6b-e146-4318-b8ba-1f819c0cfc53"},{"click":{"optIn":".fc-cta-consent","optOut":".fc-cta-do-not-consent","presence":".fc-dialog-container"},"domains":["accuweather.com"],"id":"10B17126-C30B-4EE5-9CF5-A4CAFD361AEB"},{"click":{"optIn":".js-disc-cp-accept-all","optOut":".js-disc-cp-deny-all","presence":".disc-cp-modal__modal"},"cookies":{"optOut":[{"name":"obiConsent","value":"c1-1|c2-0|c3-0|c4-0|c5-0|ts-4127464398701|consent-true"},{"name":"miCookieOptOut","value":"1"}]},"domains":["obi.de"],"id":"02BB875E-D588-4C12-9BE8-FD467C050B86"},{"click":{"optIn":"#cmpwelcomebtnyes a","presence":"#cmpbox"},"domains":["mail.ru","blic.rs","hrt.hr","eventim.de"],"id":"EA3C8C1C-8B1A-46A4-8631-750ECC29425A"},{"click":{"optIn":"#cmpwelcomebtnyes a","optOut":"#cmpwelcomebtnno a","presence":"#cmpbox"},"domains":["adac.de"],"id":"E46708B7-B378-4AA5-A700-12D7221537A0"},{"cookies":{"optOut":[{"name":"cookie_consent","value":"denied"},{"name":"marketing_consent","value":"denied"},{"name":"personalization_consent","value":"denied"}]},"domains":["arbeitsagentur.de"],"id":"A04DD123-A10F-4665-9C2B-2FB5CC293F42"},{"cookies":{"optOut":[{"name":"CONSENTMGR","value":"c1:1%7Cc2:0%7Cc3:0%7Cc4:0%7Cc5:0%7Cc6:0%7Cc7:0%7Cc8:0%7Cc9:0%7Cc10:0%7Cc11:0%7Cc12:0%7Cc13:0%7Cc14:0%7Cc15:0%7Cts:111697211775123%7Cconsent:true"},{"name":"request_consent_v","value":"3"}]},"domains":["bahn.de"],"id":"D4AD5843-DDBD-4D93-BFBA-F53DD8B53111"},{"cookies":{"optIn":[{"name":"consent_status","value":"true"}],"optOut":[{"name":"consent_status","value":"false"}]},"domains":["immobilienscout24.de"],"id":"3BD1F0DA-BABB-4F75-9B56-C92A1CFD114B"},{"click":{"optIn":".cmpboxbtnyes","optOut":".cmpboxbtnsave","presence":"#cmpwrapper"},"domains":["gls-pakete.de"],"id":"1D4DDA28-C6FC-489F-B2F3-07EAAB4F5AFE"},{"click":{"optIn":"button[data-test-id=\"cookie-notice-accept\"]","optOut":"button[data-test-id=\"cookie-notice-reject\"]","presence":".cookie-notice"},"cookies":{"optOut":[{"name":"ECCC","value":"e"}]},"domains":["ecosia.org"],"id":"7BA8E4AF-438A-40FE-8941-F921AA1FEA2A"},{"click":{"optIn":"button[data-testid=\"cookie-banner-strict-accept-all\"]","optOut":"button[data-testid=\"cookie-banner-strict-accept-selected\"]","presence":"div[data-testid=\"dl-cookieBanner\"]"},"cookies":{"optOut":[{"name":"privacySettings","value":"%7B%22v%22%3A%221%22%2C%22t%22%3A4127362064%2C%22m%22%3A%22STRICT%22%2C%22consent%22%3A%5B%22NECESSARY%22%5D%7D"}]},"domains":["deepl.com"],"id":"e3968548-ebca-4d6b-b8cf-5707e90fb612"},{"cookies":{"optOut":[{"name":"c24consent","value":"f"}]},"domains":["check24.de"],"id":"d4f2492e-c801-4687-84c8-e2cd17b4f115"},{"click":{"optIn":".qc-cmp2-summary-buttons > :nth-child(3)","optOut":".qc-cmp2-summary-buttons > :nth-child(2)","presence":"#qc-cmp2-container"},"cookies":{},"domains":["ign.com"],"id":"FB43FF71-9546-43D1-8B52-D208D1347095"},{"click":{"optIn":"#gdpr-banner-accept","presence":"#gdpr-banner-container"},"cookies":{"optIn":[],"optOut":[{"name":"ekConsentTcf2","value":"{%22customVersion%22:6%2C%22encodedConsentString%22:%22CPzMR3KPzMR3KE1ABADEC4CgAAAAAAAAAAYgJNwLgAXAA4ACWAFMAPwAzYCLAIuAZ8A14B0gD7AI8ASKAlcBMgCmwFhALqAXeAvoBggDBgGfANGAaaA1UBtADggHHgOUAc6A58B2wDuQHggPJAfaA_YCCIEFAI0gR2Aj6BIiCSIJJgSbAAAASMgAwABBKEdABgACCUJCADAAEEoSUAGAAIJQlIAMAAQShCQAYAAglCGgAwABBKERABgACCUIqADAAEEoQA%22%2C%22googleConsentGiven%22:false%2C%22consentInterpretation%22:{%22googleAdvertisingFeaturesAllowed%22:false%2C%22googleAnalyticsAllowed%22:false%2C%22infonlineAllowed%22:false%2C%22theAdexAllowed%22:false%2C%22criteoAllowed%22:false%2C%22facebookAllowed%22:false%2C%22amazonAdvertisingAllowed%22:false%2C%22rtbHouseAllowed%22:false}}"}]},"domains":["kleinanzeigen.de"],"id":"dbc0dde3-600b-40ab-ab8b-b07e3e3c7af8"},{"click":{"optIn":".implicit_privacy_prompt > .close_btn_thick","presence":".implicit_privacy_prompt"},"cookies":{"optOut":[{"name":"HASSEENNOTICE","value":"TRUE"},{"name":"CONSENTMGR","value":"c1:0%7Cc3:0%7Cc5:0%7Cc6:0%7Cc7:0%7Cc8:0"}]},"domains":["ups.com"],"id":"f462b0ee-4d17-4dcb-a951-1a23249227f6"},{"click":{},"cookies":{"optOut":[{"name":"CONSENT","path":"/","value":"PENDING+742","sameSite":0},{"name":"SOCS","path":"/","value":"CAESNQgDEitib3FfaWRlbnRpdHlmcm9udGVuZHVpc2VydmVyXzIwMjMwOTEyLjA4X3AwGgJlbiACGgYIgOCTqAY","sameSite":0}]},"domains":["youtube.com"],"id":"788ed05e-cf93-41a8-b2e5-c5571d855232"},{"click":{"optIn":"#acceptAllButton","optOut":"#rejectAllButton","presence":"#cookiePrefPopup"},"cookies":{"optIn":[{"name":"cookieSettings","value":"%7B%22version%22%3A1%2C%22preference_state%22%3A1%2C%22content_customization%22%3Anull%2C%22valve_analytics%22%3Anull%2C%22third_party_analytics%22%3Anull%2C%22third_party_content%22%3Anull%2C%22utm_enabled%22%3Atrue%7D"}],"optOut":[{"name":"cookieSettings","value":"%7B%22version%22%3A1%2C%22preference_state%22%3A2%2C%22content_customization%22%3Anull%2C%22valve_analytics%22%3Anull%2C%22third_party_analytics%22%3Anull%2C%22third_party_content%22%3Anull%2C%22utm_enabled%22%3Atrue%7D"}]},"domains":["steamcommunity.com","steampowered.com"],"id":"63104024-41b5-4be5-8019-2c59eaaf612c"},{"click":{"optIn":"button.accept-all","optOut":"button.reject-all","presence":"div#consent-page"},"cookies":{},"domains":["yahoo.com"],"id":"2f9123b1-7d6b-460f-8da8-988f82238ec7"},{"click":{"optIn":"#truste-consent-button","optOut":"#truste-consent-required","presence":"#truste-consent-content, .truste-consent-content, #truste-consent-track"},"domains":[],"id":"trustarcbar"},{"click":{"optIn":".qc-cmp2-buttons-desktop button[mode=\"primary\"], .qc-cmp2-summary-buttons button[mode=\"primary\"]","presence":".qc-cmp2-container"},"domains":[],"id":"quantcast"},{"click":{"optIn":"#CookieBoxSaveButton","optOut":"._brlbs-refuse-btn a","presence":"#BorlabsCookieBox"},"domains":[],"id":"borlabs"},{"click":{"optIn":"#cmpwelcomebtnyes a","optOut":"#cmpwelcomebtnno a","presence":"#cmpbox"},"domains":[],"id":"consentmanagernet"},{"click":{"optIn":"#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"#CybotCookiebotDialogBodyButtonDecline","presence":"#CybotCookiebotDialog"},"domains":[],"id":"cookiebot"},{"click":{"optIn":".cmplz-btn.cmplz-accept","optOut":".cmplz-btn.cmplz-deny","presence":"#cmplz-cookiebanner-container"},"domains":[],"id":"complianz"},{"click":{"optIn":".sp_choice_type_11","presence":".message-container > #notice","runContext":"child","skipPresenceVisibilityCheck":true},"domains":[],"id":"sourcepoint"},{"click":{"optIn":"button#hs-eu-confirmation-button","optOut":"button#hs-eu-decline-button","presence":"div#hs-eu-cookie-confirmation"},"cookies":{},"domains":["hubspot.com"],"id":"8308357f-6a66-433d-bfc3-de401410c350"},{"click":{},"cookies":{"optIn":[{"name":"cookie-consent","value":"{%22ga%22:true%2C%22af%22:true%2C%22fbp%22:true%2C%22lip%22:true%2C%22bing%22:true%2C%22ttads%22:true%2C%22reddit%22:true%2C%22criteo%22:true%2C%22version%22:%22v9%22}"}],"optOut":[{"name":"cookie-consent","value":"{%22ga%22:false%2C%22af%22:false%2C%22fbp%22:false%2C%22lip%22:false%2C%22bing%22:false%2C%22ttads%22:false%2C%22reddit%22:false%2C%22criteo%22:false%2C%22version%22:%22v9%22}"}]},"domains":["tiktok.com"],"id":"d9166ae8-dcc7-4ca2-8b02-0884fb1d6f70"},{"click":{},"cookies":{"optOut":[{"name":"_s.cookie_consent","value":"marketing=0:analytics=0:version=2021-07-01:timestamp=1678179320141"}]},"domains":["smallpdf.com"],"id":"bb1114eb-12ef-4465-8990-b33bbb270d3f"},{"click":{"optIn":"button.cc-banner__button-accept","optOut":"button.cc-banner__button-reject","presence":"div.cc-banner__content"},"cookies":{},"domains":["biomedcentral.com"],"id":"d5220250-697b-4b60-8284-f87e8ec2565c"},{"click":{"optIn":"a.o-cookie-message__button","presence":"div.o-cookie-message"},"cookies":{},"domains":["ft.com"],"id":"b485c89f-130e-4d5a-94f8-99eacad96e5f"},{"click":{"optOut":"button.TCF2Popup__continueWithoutAccepting___1fMWW","presence":"div.TCF2Popup__container___1TN_W"},"cookies":{},"domains":["dailymotion.com"],"id":"e5d31bce-4a62-4c6d-a40f-94fda7c41c9d"},{"click":{"optIn":"button#L2AGLb","optOut":"button#W0wltc","presence":"div.spoKVd"},"cookies":{"optIn":[{"name":"CONSENT","value":"PENDING"}],"optOut":[{"name":"SOCS","value":"CAESHAgBEhJnd3NfMjAyMjA5MjktMF9SQzEaAnJvIAEaBgiAkvOZBg"}]},"domains":["google.ad","google.ae","google.al","google.am","google.as","google.at","google.az","google.ba","google.be","google.bf","google.bg","google.bi","google.bj","google.bs","google.bt","google.by","google.ca","google.cat","google.cd","google.cf","google.cg","google.ch","google.ci","google.cl","google.cm","google.cn","google.co.ao","google.co.bw","google.co.ck","google.co.cr","google.co.id","google.co.il","google.co.in","google.co.jp","google.co.ke","google.co.kr","google.co.ls","google.co.ma","google.co.mz","google.co.nz","google.co.th","google.co.tz","google.co.ug","google.co.uk","google.co.uz","google.co.ve","google.co.vi","google.co.za","google.co.zm","google.co.zw","google.com","google.com.af","google.com.ag","google.com.ai","google.com.ar","google.com.au","google.com.bd","google.com.bh","google.com.bn","google.com.bo","google.com.br","google.com.bz","google.com.co","google.com.cu","google.com.cy","google.com.do","google.com.ec","google.com.eg","google.com.et","google.com.fj","google.com.gh","google.com.gi","google.com.gt","google.com.hk","google.com.jm","google.com.kh","google.com.kw","google.com.lb","google.com.ly","google.com.mm","google.com.mt","google.com.mx","google.com.my","google.com.na","google.com.ng","google.com.ni","google.com.np","google.com.om","google.com.pa","google.com.pe","google.com.pg","google.com.ph","google.com.pk","google.com.pr","google.com.py","google.com.qa","google.com.sa","google.com.sb","google.com.sg","google.com.sl","google.com.sv","google.com.tj","google.com.tr","google.com.tw","google.com.ua","google.com.uy","google.com.vc","google.com.vn","google.cv","google.cz","google.de","google.dj","google.dk","google.dm","google.dz","google.ee","google.es","google.fi","google.fm","google.fr","google.ga","google.ge","google.gg","google.gl","google.gm","google.gr","google.gy","google.hn","google.hr","google.ht","google.hu","google.ie","google.im","google.iq","google.is","google.it","google.je","google.jo","google.kg","google.ki","google.kz","google.la","google.li","google.lk","google.lt","google.lu","google.lv","google.md","google.me","google.mg","google.mk","google.ml","google.mn","google.ms","google.mu","google.mv","google.mw","google.ne","google.nl","google.no","google.nr","google.nu","google.pl","google.pn","google.ps","google.pt","google.ro","google.rs","google.ru","google.rw","google.sc","google.se","google.sh","google.si","google.sk","google.sm","google.sn","google.so","google.sr","google.st","google.td","google.tg","google.tl","google.tm","google.tn","google.to","google.tt","google.vg","google.vu","google.ws"],"id":"4a37ab17-dbd7-45cf-83d8-42b84af9a0df"},{"click":{"optIn":"button#bnp_btn_accept","optOut":"button#bnp_btn_reject","presence":"div#bnp_cookie_banner"},"cookies":{"optOut":[{"name":"BCP","value":"AD=0&AL=0&SM=0"}]},"domains":["bing.com"],"id":"31dc6160-3495-4f4e-8c67-594527bd4051"},{"click":{"optIn":"button.css-1d0m171","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["in.gr"],"id":"77896946-2dbf-4b65-9641-9958f9e2a228"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-consent-root"},"cookies":{},"domains":["dnes.bg","dennikn.sk","jn.pt","ojogo.pt","klik.hr"],"id":"ed097835-3d75-4864-8cdf-ea8fb19b033c"},{"click":{"optIn":"button.css-7c2c0h","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["deviantart.com"],"id":"489a59fb-1054-4d7a-ae1f-c6c561d2cd81"},{"click":{"optIn":"div#gdpr_accept","presence":"div#gdpr"},"cookies":{},"domains":["wikihow.com"],"id":"90b68b2d-46eb-4500-8cfd-9ee794653aaa"},{"click":{"optIn":"button.css-1lgi3ta","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["ethnos.gr","sportdog.gr"],"id":"570920f9-6a8a-4a26-a68a-8fc773ba30a9"},{"click":{"optIn":"button.fc-cta-consent","optOut":"button.fc-cta-do-not-consent","presence":"div.fc-consent-root"},"cookies":{},"domains":["coolinarika.com","ndtv.com","hbr.org"],"id":"12552893-278a-43e6-83ba-1db5267b3d27"},{"click":{"optIn":"button.snow-ali-kit_Button-Floating__button__ph4zrl","presence":"div.SnowPrivacyPolicyBanner_SnowPrivacyPolicyBanner__privacyPolicyBanner__1jg07"},"cookies":{},"domains":["aliexpress.ru"],"id":"407fe21e-7730-47f9-b83f-51d19dddc700"},{"click":{"optIn":"a.dismiss","presence":"div#cookie-disclaimer"},"cookies":{},"domains":["arukereso.hu"],"id":"7cbce78d-ec34-4e9b-a4f5-5b401f155e36"},{"click":{"optIn":"div.cookieinfo-close","presence":"div.cookieinfo"},"cookies":{},"domains":["glasistre.hr"],"id":"266c0df8-d8bc-4824-88d8-06d3970f0c2a"},{"click":{"optIn":"button.css-wum6af","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["flash.pt"],"id":"f081b651-7065-46a9-8d71-d7531850382e"},{"click":{"optIn":"label.c-notifier-btn","presence":"div.c-notifier-container"},"cookies":{"optOut":[{"name":"gdpr","value":"[]"}]},"domains":["ria.com"],"id":"3d2936df-3ca5-42fc-924b-1144c3d5b424"},{"click":{"optIn":"button#acceptAllCookiesBtn","presence":"div#cookie-popover"},"cookies":{},"domains":["sverigesradio.se"],"id":"aa18156e-646e-4c5c-b550-6979d181f192"},{"click":{"optIn":"a.btn","presence":"div#gdpr-box"},"cookies":{"optIn":[{"name":"privacy_accepted","value":"1"}]},"domains":["naslovi.net"],"id":"87d2bcfa-8685-4289-8c0a-d0fc31c74cc5"},{"click":{"optIn":"button.orange-gradient","presence":"div.cookie-bar-wrap"},"cookies":{"optIn":[{"name":"politica_cookie","value":"1"}]},"domains":["dedeman.ro"],"id":"84a2ec9b-bf4a-4638-aa94-d1b13652aae8"},{"click":{"optIn":"button.jad_cmp_paywall_button-cookies","presence":"div#cmp-main"},"cookies":{},"domains":["allocine.fr"],"id":"7d70347b-fe27-4c60-a9f2-6e0638f0ce37"},{"click":{"optIn":"button.primary","presence":"div.cookie-consent-overlay"},"cookies":{},"domains":["komplett.no"],"id":"be728b6d-8eeb-4179-beac-c1234fc0ae9f"},{"click":{"optIn":"div.cookieButton","presence":"div#cookieConsentContainer"},"cookies":{},"domains":["chmi.cz"],"id":"d8923166-cf05-4f6c-8829-270fc9b2efe1"},{"click":{"optIn":"button.PONCHO-button--decide","presence":"div#TRCO-application"},"cookies":{"optOut":[{"name":"cookie-policy-agreement","value":"%7B%22revision%22%3A20%2C%22consentLevel%22%3A1%7D"}]},"domains":["anwb.nl"],"id":"e63a688a-7eca-49b1-9b0f-bebae773a6ec"},{"click":{"optIn":"button.shared-module_w-full_3cBSk","presence":"div#consent-modal-yr73k"},"cookies":{"optOut":[{"name":"euconsent-v2","value":"CPmmxEAPmmxEADhADBPLC1CgAAAAAAAAAB5YAAAAAAAA"}]},"domains":["se.pl"],"id":"d0b8bc2c-c633-4628-aa39-e840060efc2e"},{"click":{"optIn":"div#cookiescript_accept","optOut":"div#cookiescript_reject ","presence":"div#cookiescript_injected"},"cookies":{},"domains":["idealmedia.io"],"id":"7f8a8bfd-343c-4fa5-969b-35a0690f6f4f"},{"click":{"optIn":"a.cookieBarConsentButton","presence":"div#cookieBar"},"cookies":{},"domains":["pki.goog"],"id":"259f5d9f-b127-47c2-a42e-161cb70a0a81"},{"click":{"optIn":"button.css-11uejzu","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["huffpost.com"],"id":"e9d772f8-92fd-4e0e-b742-0bfd6555877e"},{"click":{},"cookies":{"optIn":[{"name":"cookiesAccepted","value":"essential"}]},"domains":["onlyfans.com"],"id":"647013d0-7a3f-4e80-8c26-00f3389ba551"},{"click":{"optIn":"button#cookie-accept","presence":"div.banner"},"cookies":{},"domains":["tandfonline.com"],"id":"73c5220c-3cdb-446b-b2f6-ce9e0f1d9a8b"},{"click":{"optIn":"button.banner-lgpd-consent__accept","presence":"div.banner-lgpd-consent-container"},"cookies":{},"domains":["uol.com.br"],"id":"a491dd76-8759-4c10-a4fa-2e87b1034f23"},{"click":{},"cookies":{"optIn":[{"name":"uw_marketo_opt_in","value":"true"}],"optOut":[{"name":"mkto_opt_out","value":"id:true"}]},"domains":["washington.edu"],"id":"1de8aa61-94f1-49b4-a05d-d19a57829c71"},{"click":{"optIn":"button.css-2wu0d3","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["buzzfeed.com"],"id":"a4186ce7-bb7a-4c55-aec6-34f265943367"},{"click":{"optIn":"button.cky-btn-accept","optOut":"button.cky-btn-reject","presence":"div.cky-consent-bar"},"cookies":{},"domains":["hugedomains.com"],"id":"b3b80b81-90f0-497f-b78c-53b611d4dfaf"},{"click":{},"cookies":{"optIn":[{"name":"trackingconsent","value":"{\"marketingenabled\":true}"}],"optOut":[{"name":"trackingconsent","value":"{\"marketingenabled\":false}"}]},"domains":["abc.net.au"],"id":"c213b36a-4893-46e2-bb0e-f98a03d58287"},{"click":{"optIn":"button#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","presence":"div#CookieBanner"},"cookies":{},"domains":["jotform.com"],"id":"6efa8f4a-97a3-4677-8cde-8727f270d267"},{"click":{"optIn":"button.bcpConsentButton","presence":"div.bcpNotificationBar"},"cookies":{},"domains":["inc.com"],"id":"990f03a5-c180-407b-9a0e-f6db1278330d"},{"click":{},"cookies":{"optIn":[{"name":"cookiePolicy","value":"accept"}]},"domains":["pnas.org"],"id":"a327ad8a-daa9-4d7c-abb5-0f3e3f3c59db"},{"click":{},"cookies":{"optOut":[{"name":"consent","value":"{\"Marketing\":false,\"created_time\":\"2023-02-14T12:27:52.910Z\"}"}]},"domains":["science.org"],"id":"67702151-14e2-41c7-af4b-1f22de8185a5"},{"click":{},"cookies":{"optIn":[{"name":"ks-cookie-consent","value":"allow"}],"optOut":[{"name":"ks-cookie-consent","value":"deny"}]},"domains":["roku.com"],"id":"08513283-d50d-4a85-93fc-cd0568b09976"},{"click":{"optIn":"button.gdpr-banner__accept","presence":"div.gdpr-banner"},"cookies":{},"domains":["scmp.com"],"id":"68aff357-d47c-4dc2-b7fa-27ac4b982257"},{"click":{"optIn":"a.cc-dismiss","presence":"div.cc-window"},"cookies":{},"domains":["braze.com"],"id":"28bee54e-47d3-4192-8044-0bef6870a7c1"},{"click":{"optIn":"a#cookie-allow-all","optOut":"a#cookie-necessary-only","presence":"div#cookiebanner"},"cookies":{},"domains":["adjust.com"],"id":"ca37bf31-bf4e-4172-bf7e-91baca32c9e2"},{"click":{"optIn":"button.css-hxv78t","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["rsvplive.ie"],"id":"5a256bf7-29a7-485e-8305-fcafd7a52af9"},{"click":{"optIn":"button.css-1euwp1t","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["enikos.gr"],"id":"20e1f1c3-0914-42b4-9022-3ce80b79a480"},{"click":{"optIn":"button.css-fz9f1h","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["dikaiologitika.gr"],"id":"1c742d88-b3a7-43da-b205-3ba4afd92e63"},{"click":{"optIn":"button.css-v43ltw","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["filmaffinity.com"],"id":"ef8548ec-5dd9-4201-a075-a32893f09953"},{"click":{"optIn":"button#consent_prompt_submit","presence":"div.consent_prompt_footer"},"cookies":{},"domains":["argos.co.uk"],"id":"88e79126-8072-4079-aa60-1d71d9ddb65b"},{"click":{"optIn":"button.iubenda-cs-accept-btn","presence":"div#iubenda-cs-banner"},"cookies":{},"domains":["ilmessaggero.it"],"id":"c839d2c3-ee29-4015-a990-8cfe9884a4c4"},{"click":{"optIn":"button#btn-agree-all","presence":"div#rgpd"},"cookies":{},"domains":["rtp.pt"],"id":"46e07f9b-9ce4-4fea-8be7-48a089bdb8d0"},{"click":{"optIn":"span.inline-block","presence":"div#notice-cookie-block"},"cookies":{"optIn":[{"name":"user_allowed_save_cookie","value":"true"}]},"domains":["altex.ro"],"id":"32139cbb-7e13-4cec-ba54-7bfb4f46277c"},{"click":{"optIn":"button.css-47sehv","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["timeanddate.com","livescience.com","cancan.ro","evz.ro","gandul.ro","kurir.rs","capital.ro"],"id":"5a3bf87a-62c2-40b2-bfbb-b2dcf8c23f84"},{"click":{"optIn":"button.css-tzlaik","presence":"div#qc-cmp2-ui"},"cookies":{},"domains":["nit.pt"],"id":"30542b9b-2225-4c22-bbd9-0e9d8f6273df"},{"click":{"optIn":"a#cookies-agree","presence":"div.cookies-buttons"},"cookies":{"optOut":[{"name":"cookiesPolicy","value":"10000"}]},"domains":["elcorteingles.es"],"id":"90b22cfd-00a8-4467-9334-96773066c2c1"},{"click":{"optIn":"button#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","presence":"div#CybotCookiebotDialog"},"cookies":{},"domains":["ingatlan.com"],"id":"009f2741-56cb-485e-af5c-3102f8e9cf55"},{"click":{"optIn":"button.jad_cmp_paywall_button-cookies","presence":"div#didomi-host"},"cookies":{},"domains":["purepeople.com"],"id":"b933bc7f-27b7-44a7-9127-66f98c93ea8f"},{"click":{"optIn":"button.css-1xqnplm","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["lifo.gr"],"id":"4f86f2e9-ea7f-4ee7-a4d2-b2253a5f1c1d"},{"click":{"optIn":"a.close-accept","presence":"div.woahbar"},"cookies":{},"domains":["meteomedia.com"],"id":"8e772dc2-be57-4cf6-ad51-574b2accf86c"},{"click":{"optOut":"button.accept-button","presence":"div.gdpr-content"},"cookies":{},"domains":["mozzartbet.com"],"id":"b8b2cf50-d9cf-432b-947c-894350121024"},{"click":{"optIn":"button.fc-cta-consent","optOut":"button.fc-cta-do-not-consent","presence":"div.fc-footer-buttons-container"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgbQkAPgbQkAEsABBITCjCgAAAAAH_AABCYAAAO9QD2F2K2kKEkfjSUeYAQBCujIEIBUAAAAEKBIAAAAUgQAgFIIAgABlACEAAAABAQAQCAgAQABAAAoICgACAAAAAAAAAQAAQQAABAAIAAAAAAAAEAQAAAAAQAAAAAAAhEhCAAQQAEIAAAAAAAAAAAAAAAAAABAAAAEAA%22%2C%221~%22%2C%22A83BB90B-53A8-400D-8DAA-F4EF44E9B970%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["ilmeteo.it"],"id":"71d0715b-3e8e-4077-969e-7b7722f78910"},{"click":{"optIn":"button.css-78i25x","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["mirror.co.uk"],"id":"21593dac-f469-4206-87d9-044e6d69404b"},{"click":{"optIn":"a.js-cookies-info-accept","optOut":"a.js-cookies-info-reject","presence":"div.cookies-info__buttons"},"cookies":{"optOut":[{"name":"CBARIH","value":"1"}]},"domains":["alza.cz"],"id":"c7a067c4-a365-4497-a990-c042545dfd6c"},{"click":{"optIn":"button.css-k8o10q","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["femina.hu"],"id":"d1b9f7af-26d3-4f1b-812c-9f8cf41da900"},{"click":{"optIn":"a#truste-consent-button","optOut":"a#truste-consent-required2","presence":"div#truste-consent-buttons"},"cookies":{},"domains":["poste.it"],"id":"450e91f1-22ee-4718-9e98-05f831adfeff"},{"click":{"optIn":"button#almacmp-modalConfirmBtn","presence":"div.almacmp-controls"},"cookies":{},"domains":["kauppalehti.fi"],"id":"abb44f4b-bc8a-49bf-8f8c-204fe33806e9"},{"click":{"optIn":"button.css-1j8kkja","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["news247.gr"],"id":"1b1bdbb4-089c-45dc-9d42-e87a1fa85882"},{"click":{"optIn":"a#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"a#CybotCookiebotDialogBodyLevelButtonLevelOptinDeclineAll","presence":"div#CybotCookiebotDialog"},"cookies":{"optIn":[],"optOut":[{"name":"CookieConsent","value":"{stamp:%27aQlJVTwi41tewItmxlt/w7TRvv2UDwd39lOxJC/s1TG9dFvEWjL4jQ==%27%2Cnecessary:true%2Cpreferences:false%2Cstatistics:false%2Cmarketing:false%2Cver:1%2Cutc:1665481193123%2Cregion:%27ro%27}"}]},"domains":["rip.ie"],"id":"051ccd77-b9b3-4558-9c27-5293d8d735f4"},{"click":{"optIn":"button.sfc-button--primary-white","presence":"div.sfc-col-lg-3"},"cookies":{"optOut":[{"name":"RABO_PSL","value":"1"}]},"domains":["rabobank.nl"],"id":"fe8a3adb-ce3c-4dd6-83db-772e71674da3"},{"click":{"optIn":"a.cmptxt_btn_yes","presence":"div.cmpboxbtns"},"cookies":{},"domains":["informer.rs"],"id":"27572d79-fc44-49f0-b271-bd44e76f3a3f"},{"click":{"optIn":"button.eu-cookie-compliance-default-button","presence":"div#popup-buttons"},"cookies":{"optIn":[{"name":"cookie-agreed","value":"2"}],"optOut":[]},"domains":["eluniversal.com.mx"],"id":"34e9d8ee-5e8d-462c-ab39-d25260124cf6"},{"click":{"optIn":"button.css-k8o10q","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["athensmagazine.gr"],"id":"c0e69dcc-9602-4d7a-89b8-a4a06f0432ca"},{"click":{"optIn":"button.cookie-banner-lgpd_accept-button","presence":"div#cookie-banner-lgpd"},"cookies":{},"domains":["globo.com"],"id":"90b8eda3-d964-4301-94fc-646e92d33d56"},{"click":{"optIn":"button.css-1x99van","presence":"div.qc-cmp2-summary-buttons"},"cookies":{},"domains":["express.co.uk"],"id":"edaa2c50-1fbc-4287-8d15-68af2b5dc1bf"},{"click":{"optIn":"button.css-1lgi3ta","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["pronews.gr"],"id":"9e16f526-4d46-4c2e-a3ed-d3b43d67b4fb"},{"click":{"optIn":"button#almacmp-modalConfirmBtn","presence":"div.almacmp-controls"},"cookies":{},"domains":["nettiauto.com"],"id":"7e5d072f-ea5a-4a82-9ea4-3bbf06d5cc8d"},{"click":{"optIn":"button.css-b2defl","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["ilgiornale.it"],"id":"362b64e3-c12d-4d5e-9c8e-169df9782b28"},{"click":{},"cookies":{"optOut":[{"name":"CookieConsent","value":"{stamp:%27hLskZi6GtaCNeWwvKfJCnNdwijLGPiuqz0obMpsw2C4o6inSM80MLQ==%27%2Cnecessary:true%2Cpreferences:false%2Cstatistics:false%2Cmarketing:false%2Cmethod:%27explicit%27%2Cver:1%2Cutc:1675088694646%2Ciab2:%27CPmZlUAPmZlUACGABBENC1CgAAAAAAAAAAAAAAAAAAAA.YAAAAAAAAAAA%27%2Cgacm:%271~%27%2Cregion:%27ro%27}"}]},"domains":["worten.pt"],"id":"905b5c20-000d-4b7b-a8d6-d84d2311dfdf"},{"click":{"optIn":"button.css-14ubilm","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["tradera.com"],"id":"deca4013-d55c-424b-9a46-2df8139fd415"},{"click":{"optIn":"a.cmptxt_btn_yes","presence":"div.cmpboxbtns"},"cookies":{},"domains":["alo.rs"],"id":"4dce4250-5d45-4cf8-bb0c-f485de812859"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons-container"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPg1oEAPg1oEAEsABCBGClCgAAAAAAAAAAIwAAAOhQD2F2K2kKEkfjSUWYAQBCujKEIhUAAAAECBIAAAAUgQAgFIIAgAAlACAAAAABAQAQCAgAQABAAAoACgAAAAAAAAAAAAAAQQAABAAIAAAAAAAAEAQAAIAAQAAAAAAABEhCAAQQAEAAAAAAAAAAAAAAAAAAABAAA%22%2C%221~%22%2C%22A7193324-AE65-4BF2-B769-43CD7980AA9B%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["mobile.bg"],"id":"3708e6f7-9237-4ef1-8aca-bec748cc676e"},{"click":{"optIn":"button.css-mn27n0","presence":"div.qc-cmp2-summary-buttons"},"cookies":{},"domains":["observador.pt"],"id":"c49fa28b-a67c-42b8-a4e5-4d48d34fba04"},{"click":{"optIn":"div.boton_cookies","presence":"div#popup_cookies"},"cookies":{"optIn":[{"name":"accept_cookies","value":"ok"}]},"domains":["aemet.es"],"id":"60ea2eca-10af-47d1-a240-cbdf44519e9d"},{"click":{"optIn":"button.css-k8o10q","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["napi.hu"],"id":"2b12c85e-4ec0-4a3d-9cbe-9892db3f5850"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPhCz0APhCz0AEsABCFIClCgAAAAAAAAAApAAAAOhQD2F2K2kKEkfjSUWYAQBCujIEIhUAAAAECBIAAAAUgQAgFIIAgAAlACAAAAABAQAQCAgAQABAAAoACgAAAAAAAAAAAAAAQQAABAAIAAAAAAAAEAQAAIAAQAAAAAAABEhCAAQQAEAAAAAAAAAAAAAAAAAAABAAA.YAAAAAAAAAA%22%2C%221~%22%2C%22EE7DBC34-5A3A-4088-90DB-A679D6C3A244%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["telsu.fi"],"id":"0d950828-684c-48f3-8b0c-3c9523c05fb6"},{"click":{"optIn":"button.css-k8o10q","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["gossip-tv.gr"],"id":"ba9c17cd-19aa-4fe3-ac0c-9c3055133c5b"},{"click":{"optIn":"button#pt-accept-all","optOut":"div#pt-close","presence":"div#pubtech-cmp"},"cookies":{},"domains":["liberoquotidiano.it"],"id":"531d8b09-8fce-4019-9f96-31d5add26a43"},{"click":{"optIn":"button.css-19ukivv","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["vi.nl"],"id":"5026561f-ffec-437e-bad8-820ac9d55659"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPhCz0APhCz0AEsABCBGClCgAAAAAAAAAAIwAAAQvQD-F2K2lKGkfjaUeYIQBKujOEIhUBgEAEKBIQAEA0gQAgFIIAgADlgCUAAAABARCQCAgAQABAAAoICgAAAAACAAAABAASQQAABAAIAAICAABAUBQAAIAARAAgAAMBBEhDAASSAECAAAAAACAAIAAAAAAAABAAAAAAAAAIAAAAAAAAAAAAAEAAA.YAAAAAAAAAA%22%2C%221~%22%2C%22924A9049-E66F-4E81-92F6-E6AE4366B6B6%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["news.bg"],"id":"1a473c52-96a0-4d12-a8cd-d12d1cc8edca"},{"click":{"optIn":"button.css-k8o10q","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["zougla.gr"],"id":"0587a3cf-e084-40bf-b01a-2586c2313f3b"},{"click":{"optIn":"button.css-1al1vdb","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["calciomercato.com"],"id":"68c6fe41-fb1d-41ed-a8c6-55fde975f0ab"},{"click":{"optIn":"a#consent_prompt_submit","presence":"div#__tealiumGDPRecModal"},"cookies":{"optOut":[{"name":"CONSENTMGR","value":"c1:0%7Cc6:0%7Cts:1666183304450%7Cconsent:false"}]},"domains":["telenor.no"],"id":"4ed03d1e-155c-45fa-a8c9-fbccc9ac0f33"},{"click":{"optIn":"button#accept-privacy-policies","presence":"div.emb38ba0"},"cookies":{},"domains":["walmart.ca"],"id":"0485cf43-5df0-41aa-83da-92cd3b82d6f7"},{"click":{"optIn":"button.css-1hzdrx2","presence":"div.qc-cmp2-summary-buttons"},"cookies":{},"domains":["newsbeast.gr"],"id":"b9fd5871-876d-4931-9f76-dd695e613919"},{"click":{"optIn":"button.rodo-popup-agree","presence":"div.rodo-popup-buttons"},"cookies":{},"domains":["pomponik.pl"],"id":"397fdd1a-d6b7-4bab-a105-3f1f36f755ff"},{"click":{"optIn":"button.accept-cookie-button","presence":"div.cookie-banner-content"},"cookies":{},"domains":["avanza.se"],"id":"803fbd5e-3734-4cf6-a878-5ffe24ec6809"},{"click":{"optIn":"button#didomi-notice-agree-button","presence":"div#buttons"},"cookies":{},"domains":["zerozero.pt"],"id":"1a37cced-b12a-44d9-a576-d1b259312471"},{"click":{"optIn":"input.btn-secondary","presence":"div.stampenCookieContainer"},"cookies":{},"domains":["gp.se"],"id":"e4e59ff1-b18c-453b-a4e0-6c0ec4008d81"},{"click":{"optIn":"a#wt-cli-accept-all-btn","presence":"div.cli-bar-container"},"cookies":{"optIn":[{"name":"viewed_cookie_policy","value":"yes"}]},"domains":["katalozi.net"],"id":"caddc16b-c8ad-404a-bd29-6383977695cb"},{"click":{"optIn":"button.rounded-button--tertiary","presence":"div.legal-consent"},"cookies":{"optOut":[{"name":"mal_consent_gdpr_remarketing","value":"f"},{"name":"mal_consent_gdpr_personalization","value":"f"}]},"domains":["mall.cz"],"id":"6bc9ceec-b225-4284-b924-589c3ff4f249"},{"click":{"optIn":"a.wscrOk","optOut":"a.wscrOk2","presence":"div#CookieReportsPanel"},"cookies":{},"domains":["nordea.fi"],"id":"cf282f72-5333-48a8-9097-cbc89ea26634"},{"click":{"optIn":"button#grantPermissionButton","presence":"div#cookie-bar"},"cookies":{"optOut":[{"name":"CookiePermissionInfo","value":"%7B%22LastModifiedDate%22%3A%22%5C%2FDate(1666257491849)%5C%2F%22%2C%22ExpirationDate%22%3A%22%5C%2FDate(1697793491849)%5C%2F%22%2C%22Allow%22%3Afalse%2C%22CategoryPermission%22%3A%5B%7B%22Category%22%3A%22Cat.8%22%2C%22Permission%22%3Atrue%7D%2C%7B%22Category%22%3A%22Cat.9%22%2C%22Permission%22%3Atrue%7D%2C%7B%22Category%22%3A%22Cat.10%22%2C%22Permission%22%3Afalse%7D%2C%7B%22Category%22%3A%22Cat.11%22%2C%22Permission%22%3Afalse%7D%2C%7B%22Category%22%3A%22Cat.12%22%2C%22Permission%22%3Afalse%7D%5D%7D"}]},"domains":["postnl.nl"],"id":"e4a9e084-a37e-4f10-969c-c872f578dd15"},{"click":{"optIn":"button.pr-riqlv6","optOut":"button.pr-1l8klmj","presence":"div#consent"},"cookies":{"optOut":[{"name":"data_consent","value":"1.1.0.0.0.1675177081479.Default"}]},"domains":["pricerunner.dk"],"id":"be039e17-f095-46f4-a809-c00699799db8"},{"click":{"optIn":"div.tvp-covl__ab","presence":"div#ip"},"cookies":{},"domains":["tvp.pl"],"id":"fb333123-4f00-4b45-acf9-21cb038c76ba"},{"click":{"optIn":"button.css-1g5s5vy","presence":"div#qc-cmp2-ui"},"cookies":{},"domains":["meo.pt"],"id":"992a91e5-9d29-411a-a8e6-e689fb75c2b7"},{"click":{"optIn":"span#banner-cookie--button","presence":"div#banner-cookie"},"cookies":{"optIn":[{"name":"cookie_banner","value":"1"}]},"domains":["bitly.com"],"id":"84a097a3-5cd1-448a-afcf-4be950bc5756"},{"click":{"optIn":"button.btn-success","presence":"div.vue-component"},"cookies":{},"domains":["remove.bg"],"id":"86bc6c6f-c082-466f-ac77-994a2296fbb0"},{"click":{"optIn":"button#CybotCookiebotDialogBodyButtonAccept","presence":"div#CybotCookiebotDialog"},"cookies":{},"domains":["sectigo.com"],"id":"7078621c-2701-40e0-83f1-109c8ea0f82f"},{"click":{"optOut":"button.eu-cookie-compliance-save-preferences-button","presence":"div.eu-cookie-compliance-banner"},"cookies":{},"domains":["cam.ac.uk"],"id":"f5f827d0-60c9-4fe6-af97-a901d0d96ddc"},{"click":{"optIn":"button#_evidon-accept-button","optOut":"button#_evidon-decline-button","presence":"div#_evidon-message"},"cookies":{},"domains":["playstation.com"],"id":"23df4915-5954-41ea-8d5c-e76a1d98e70b"},{"click":{"optIn":"button#truste-consent-button","presence":"div#consent_blackbar"},"cookies":{},"domains":["fortune.com"],"id":"c0908337-da46-4155-8178-43e4a67693ec"},{"click":{"optIn":"button#truste-consent-button","presence":"div#truste-consent-track"},"cookies":{},"domains":["mi.com"],"id":"30a2b81a-b5a6-4c49-818d-de34ecddafbe"},{"click":{"optIn":"button.css-1k47zha","presence":"div#qc-cmp2-ui"},"cookies":{},"domains":["9gag.com"],"id":"6c246e7d-2a12-4b13-94b4-d2908cd64aad"},{"click":{"optIn":"a.a8c-cookie-banner__accept-all-button","presence":"form.a8c-cookie-banner"},"cookies":{},"domains":["akismet.com"],"id":"9a5038c6-31da-40e5-94d8-6eea3ecfa9ec"},{"click":{"optIn":"button#truste-consent-button","optOut":"button#truste-consent-required","presence":"div#truste-consent-track"},"cookies":{},"domains":["box.com","ea.com"],"id":"b8e927a8-e0fc-4e7b-ad60-edca983accd3"},{"click":{"optIn":"button.eu-cookie-compliance-default-button","presence":"div.cookies"},"cookies":{},"domains":["unesco.org"],"id":"689fe5d6-7792-4475-98fc-71aa1715d0d9"},{"click":{"optIn":"div.zbc-cta-accept","presence":"div.zbottom-cookie-container"},"cookies":{},"domains":["zoho.com"],"id":"3656dd64-5840-4918-adc8-caa723503f20"},{"click":{"optIn":"button.css-1k3tyyb","presence":"div#qc-cmp2-ui"},"cookies":{},"domains":["theatlantic.com"],"id":"43f34378-73c3-4851-a948-e073908edddd"},{"click":{"optIn":"button#truste-consent-button","optOut":"button#truste-consent-required","presence":"div#truste-consent-content"},"cookies":{"optOut":[{"name":"notice_gdpr_prefs","value":"0:"}]},"domains":["squarespace.com"],"id":"b17a2376-ae8b-40de-9b6f-61efdf25f862"},{"click":{"optIn":"button.osano-cm-accept-all","presence":"div.osano-cm-window"},"cookies":{},"domains":["scribd.com","chicagotribune.com"],"id":"f6f48ce2-0487-4003-b1c7-dfcd37def8d7"},{"click":{"optIn":"button#cookie-accept-all-secondary","optOut":"button.CookieConsentSecondary__RejectAllButton-sc-12do1ry-2","presence":"div.ModalInner__Backdrop-sc-1ghkydj-1"},"cookies":{},"domains":["nordnet.no"],"id":"9ea83ecf-3e82-4976-80e7-86872d7e4aeb"},{"click":{"optIn":"button.primary","presence":"div#camus-cookie-disclaimer"},"cookies":{"optIn":[{"name":"accepts-cookies","value":"true"}]},"domains":["milenio.com"],"id":"befe1d72-f33a-4e63-be43-236bedc3b49a"},{"click":{"optIn":"button.css-k8o10q","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["newsit.gr","protothema.gr","newsbomb.gr","youweekly.gr","vrisko.gr","index.hu","meteo.gr","fantacalcio.it"],"id":"25dd408a-0a98-4e93-992c-abd320255cd1"},{"click":{"optIn":"button.css-47sehv","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["pik.bg","prosport.ro","sciencedaily.com"],"id":"d96f380c-c76f-47d8-a1f7-bd4063792ade"},{"click":{"optIn":"button.css-1lgi3ta","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["sdna.gr","makeleio.gr"],"id":"af566db1-982c-4837-8f0b-96a341702520"},{"click":{"optIn":"div.gdpr-trigger","presence":"div#gdpr"},"cookies":{},"domains":["digisport.ro"],"id":"91a1519c-51f4-4d9a-bea3-06a2fff7d892"},{"click":{"optIn":"button.css-1tfx6ee","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["startlap.hu","nosalty.hu","24.hu","nlc.hu"],"id":"4fc95ff9-b785-49ee-8a8c-e789665a1643"},{"click":{"optIn":"button.NT2yCg","presence":"div.e4Qmjw"},"cookies":{},"domains":["canva.com"],"id":"5a03b949-b86c-4ee5-9824-97fb59849cb8"},{"click":{"optIn":"button#privacy-cp-wall-accept","presence":"div.privacy-cp-wall"},"cookies":{},"domains":["corriere.it"],"id":"b90700d6-32a6-44e2-adf4-46acd54089c9"},{"click":{"optIn":"button#privacy-cp-wall-accept","presence":"div.privacy-cp-wall"},"cookies":{},"domains":["gazzetta.it"],"id":"32be6ed7-749d-448f-975d-10b4d1e6e482"},{"click":{"optIn":"button.css-1u05hh5","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["researchgate.net"],"id":"e060a13e-e0ae-4081-8d9f-29a0c17bec79"},{"click":{"optIn":"button.primary_2xk2l","presence":"div.container_1gQfi"},"cookies":{},"domains":["dailymail.co.uk"],"id":"4d4b2924-6e28-4d39-9a02-e31690746ab2"},{"click":{"optIn":"button.osano-cm-accept-all","presence":"div.osano-cm-dialog__buttons"},"cookies":{"optOut":[{"name":"osano_consentmanager","value":"29z_AY1nTFjK9XMxsOgqw44fXSaxiin_dEBjbDS7Xgl2GM5AONcjcMtZVKd_7n7XCTO5hym727ANlN292apKnDkgIe8dhCSSZpmDhDN7guy_H9a0nFHng1IsTphnnPGMG-iLZ6sS9OmdxmAq8K_mehLsgQWFmfhi5K07-UmLlGoVGx19IxTDiqf-aJmp5dbLV8kxLYjgbTFnTJ2JWUcwJYR57TX9iezs-BprQopNCs5CGWW9NOFrv-uhWhwTsKNLygKH7cMwdnp7RHTSX41-FCLSh10="}]},"domains":["wiley.com"],"id":"7e45fd5f-63b5-4090-9120-b467b0252358"},{"click":{"optIn":"div.gdpr-agree-btn","optOut":"div.gdpr-reject-btn","presence":"div#GDPR-cookies-notice"},"cookies":{},"domains":["alibaba.com"],"id":"c35bdda6-611d-4742-8f6e-4aebb574e675"},{"click":{"optIn":"button.kcLcLu","presence":"div.gmjWml"},"cookies":{},"domains":["turbopages.org"],"id":"6ecb9b79-3666-479c-8798-5cf46702799f"},{"click":{"optIn":"span.nrk-sr","presence":"div.nrk-masthead__info-banner--cookie"},"cookies":{"optIn":[{"name":"nrkno-cookie-information","value":"1"}]},"domains":["nrk.no"],"id":"15cdab7d-a018-4c88-9352-5eacd4c30d1d"},{"click":{"optIn":"button.css-1v69bou","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["sapo.pt"],"id":"f29b0658-24ab-40fd-92fb-11850b2aaab5"},{"click":{},"cookies":{"optOut":[{"name":"yleconsent","value":"v1|"}]},"domains":["yle.fi"],"id":"9a727363-cec6-4641-99ab-80550b89da5b"},{"click":{"optIn":"div.ok","presence":"div#checkUPcookies"},"cookies":{},"domains":["pravda.com.ua"],"id":"7498f52b-4273-4cfb-a22a-c9df9b84adc2"},{"click":{"optIn":"button.css-w0lt3s","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["iefimerida.gr"],"id":"aeff05cc-c287-4596-89b6-3559eced1133"},{"click":{"optIn":"button.css-wum6af","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["record.pt"],"id":"8b2a32a7-5a38-4ffc-abc5-d5827e16008b"},{"click":{"optIn":"div.gdpr-trigger","presence":"div#gdpr"},"cookies":{},"domains":["digi24.ro"],"id":"55ed573b-2cf3-42a3-8010-d397b161568b"},{"click":{"optIn":"button.CookieConsent__primaryButton___Th47k","presence":"div.CookieConsent__root___3GjU8"},"cookies":{},"domains":["svt.se"],"id":"87b229aa-567e-4549-895f-b6c0065dfdc5"},{"click":{"optIn":"button.css-1rx6u69","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["gazzetta.gr"],"id":"7eed4367-8f21-4359-aae9-cf9017ae5efc"},{"click":{"optIn":"button.css-k9c0va","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["foreca.fi"],"id":"f35220db-4382-446a-af55-063f309ccf5a"},{"click":{"optIn":"button.css-1tdle7a","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["iol.pt"],"id":"290d1140-dc1b-4d97-85dd-d970753ae441"},{"click":{"optIn":"button.allow-all-cookies-button","optOut":"button.mt-2","presence":"div.consent-container"},"cookies":{},"domains":["ilmatieteenlaitos.fi"],"id":"0cfab897-c0f5-4415-b5a1-bac258d1c764"},{"click":{"optIn":"button.css-kc1iqc","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["telex.hu"],"id":"24df6217-9ed9-4a67-9811-ff9c8f8faaf2"},{"click":{"optIn":"button#c-p-bn","presence":"div#cc_div"},"cookies":{},"domains":["shmu.sk"],"id":"43135a56-c361-4d88-82dd-cf17a077a6a5"},{"click":{"optIn":"button#cookieBtn","presence":"div.c-alert__box"},"cookies":{},"domains":["tsn.ua"],"id":"04608cf9-0f96-433b-bc26-6aa9f5ebdfc8"},{"click":{"optIn":"button.css-8zhqum","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["hvg.hu"],"id":"83758fdc-5bdc-4d8b-b783-840f16d30f1c"},{"click":{"optIn":"button.css-wum6af","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["cmjornal.pt"],"id":"e400d28c-7f73-4449-8749-5f96509eb688"},{"click":{"optIn":"button.css-1ruupc0","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["444.hu"],"id":"eaf913b1-b628-4a57-9a1c-65bcf27f33a9"},{"click":{"optIn":"i.fa-times","presence":"div.cookieWarning"},"cookies":{},"domains":["kukaj.io"],"id":"8f251e48-f45b-4051-bc53-0851d0d411f5"},{"click":{"optIn":"button.notificationButton","presence":"div.polopolyNotification"},"cookies":{},"domains":["smhi.se"],"id":"27d9194f-f908-4cb8-8f57-ddb899a06a4e"},{"click":{"optIn":"button.css-fxmqu","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["publico.pt"],"id":"36dc7cc5-a043-4259-a9bd-07913ff208bb"},{"click":{"optIn":"button.js_cookie-monster-agree","optOut":"a.js_cookie-monster-disagree","presence":"div#js_cookie-monster"},"cookies":{},"domains":["ceneo.pl"],"id":"35db03d9-02c9-4558-a31b-aa4a20d6dbaa"},{"click":{"optIn":"a.js-accept-cookies","presence":"div.jsGdprNoticeHolder"},"cookies":{},"domains":["polovniautomobili.com"],"id":"9a6465c6-7955-4dff-9483-70635ba5fbda"},{"click":{"optOut":"button.css-zpqvhj ","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["sorozatbarat.club"],"id":"fbff28bd-84e5-4f82-8023-2f00d772e7e8"},{"click":{"optIn":"button.RMlTST","optOut":"button.WEzN4V","presence":"div.aspXfg"},"cookies":{},"domains":["wix.com"],"id":"aa245048-507c-11ed-bdc3-0242ac120002"},{"click":{"optIn":"button.submitAll","presence":"div.submitButton"},"cookies":{"optOut":[{"name":"CookieConsent","value":"{stamp:%27D1AamT1V80siZwfIuWr5SREHguKw3sySW3+Q+Nb2mPwfRB9so2m1Sg==%27%2Cnecessary:true%2Cpreferences:false%2Cstatistics:false%2Cmarketing:false%2Cver:5%2Cutc:1664957253372%2Cregion:%27ro%27}"}]},"domains":["dr.dk"],"id":"9def1218-9201-4b49-bf69-ea203aeab2b3"},{"click":{"optIn":"button.css-1wjnr64","presence":"div.qc-cmp2-container"},"cookies":{},"domains":["idokep.hu"],"id":"1dc10ed2-800f-484c-9df1-6f99d8cd2584"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-choice-dialog"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgbQkAPgbQkAEsABCHUCjCoAP_AAH_AAA6gHQpB7D7FbSFCyP55aLsAMAhXRkCEAqQAAASFAmABQAKQIBQCkkAQFAygBCACAAAgIAJBAQIMCAgACUEBQABAAAEEAAAABAAIIAAAgAEAAAAIAAACAIAAEAAIQAAAEAAAmQhAAIIACAAABAAAAAAAAAAAAAAAAgdCgHsLsVtIUJI_GkoswAgCFdGQIQCoAAAAIUCQAAAApAgBAKQQBAADKAEIAAAACAgAgEBAAgACAABQQFAAEAAAAAAAAAAAAggAACAAQAAAAAAAAIAgAAQAAhAAAAAAACJCEAAggAIAAAAAAAAAAAAAAAAAAACAAA.cqAADVgAAAA%22%2C%221~2052.2072.70.89.93.108.122.149.2202.162.167.196.2253.241.2299.259.2331.2357.311.317.323.2373.338.358.2415.415.440.449.2506.2526.482.486.494.495.2568.2571.2575.540.574.2624.2677.2707.817.827.2898.864.981.1031.1048.1051.1067.1095.1097.1127.1171.1201.1205.1211.1276.1301.1365.1415.1449.1570.1577.1616.1651.1716.1753.1765.1870.1878.1889.1917.1958.2012%22%2C%228BB76B67-7925-4F57-BFC5-31C47ABF23A9%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["origo.hu"],"id":"f236d4c4-1f2f-4b62-a4ec-5d9388d9150e"},{"click":{"optIn":"button.rodo-popup-agree","presence":"div.rodo-popup-buttons"},"cookies":{},"domains":["interia.pl"],"id":"ef9bacb9-d248-4129-baed-354a45277750"},{"click":{"optIn":"button#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"button#CybotCookiebotDialogBodyButtonDecline","presence":"div#CybotCookiebotDialogBodyButtons"},"cookies":{"optOut":[{"name":"CookieConsent","value":"{stamp:%27QmpmezEASR/DS4/lr1mawVaNO945EW6sk0Hi0cjL1CFS1A36t8Os1Q==%27%2Cnecessary:true%2Cpreferences:false%2Cstatistics:false%2Cmarketing:false%2Cver:3%2Cutc:1665042549753%2Ciab2:%27CPgbQkAPgbQkACGABBENCjCgAAAAAE_AAAAAAAASCAJMNW4gC7EscCbQMIoEQIwrCQqgUAEFAMLRAYAODgp2VgE-sIEACAUARgRAhxBRgQCAAACAJCIAJAiwQCIAiAQAAgARCIQAEDAIKACwMAgABANAxRCgAECQgyICIpTAgIgSCAlsqEEoK5DTCAOssAKDRGxUACJAABSAAJCwcAwRICViwQJMUb5ACMEKAUSoVoAA.YAAAAAAAAAAA%27%2Cgacm:%271~%27%2Cregion:%27ro%27}"}]},"domains":["ekstrabladet.dk"],"id":"7c2c6827-7d60-49a5-b4c1-877ba7fcd2e7"},{"click":{"optIn":"button.iubenda-cs-accept-btn","presence":"div#iubenda-cs-banner"},"cookies":{},"domains":["repubblica.it"],"id":"5c862324-6a7c-43d8-ae34-47c5e7d355f6"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-choice-dialog"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgbQkAPgbQkAEsABCBGCjCgAAAAAAAAAAIwAAAPaQD2F2K2kKEkfjaUWYIQBCujKEIBUBAEAEKBIAAAAUgQAgFIIAgABlACEAAAABAQAQCAgAQABAAAoICgACAAAAAQAAAAAAQQAABAAIAAACAAAAEAQAAAAAQAAAAAAABEhCAAQSQEAAAAAAAAAAAAAAAAAAABAAAAAAAAAIAA.YAAAAAAAAAA%22%2C%221~%22%2C%226C13DA30-0357-4AD8-8594-DBD146A8DF46%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["blitz.bg"],"id":"7850dc20-f121-417b-9eb0-d91a0a8d6a8c"},{"click":{"optIn":"button.fc-primary-button","presence":"div.fc-footer-buttons"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgejgAPgejgAEsABCBGCkCgAAAAAAAAAAIwAAAOhQD2F2K2kKEkfjSUWYAQBCujKEIhUAAAAECBIAAAAUgQAgFIIAgAAlACAAAAABAQAQCAgAQABAAAoACgAAAAAAAAAAAAAAQQAABAAIAAAAAAAAEAQAAIAAQAAAAAAABEhCAAQQAEAAAAAAAAAAAAAAAAAAABAAA%22%2C%221~%22%2C%2232D9A01E-9678-40B0-BD1B-AD0CDC174758%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["fakti.bg"],"id":"abc3a8c3-6a15-48a6-83eb-4f7762df9270"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons-container"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgocUAPgocUAEsABCFICkCgAAAAAAAAAApAAAAQWQD2F2q2kKEkfjSUWYgURCurIEIhcAAAAEKBoAAAAUgQAgFIMIgABlACEAAAABAQAQCAgAQABAAAoICgAAAAAAAAAAAAAAQQACBAAIAAAAAAAAEAQAAoAAQAAAAAAABEhCAAQQAEIAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAIAAA.YAAAAAAAAAA%22%2C%221~%22%2C%22AC745442-DC8E-42A9-AAB5-970367496CBA%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["seiska.fi"],"id":"57d6c05c-44b6-4e02-91b6-ef91cca6a311"},{"click":{"optIn":"button.css-hxv78t","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["irishmirror.ie"],"id":"3cab2d97-d9eb-4254-97aa-441ad90ada69"},{"click":{"optIn":"a.cmptxt_btn_yes","presence":"div.cmpboxinner"},"cookies":{},"domains":["novosti.rs"],"id":"53f117b7-5d9d-4387-8507-95fb64a4da86"},{"click":{"optIn":"button.fc-primary-button","presence":"div.fc-footer-buttons"},"cookies":{"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgocUAPgocUAEsABCBGCkCgAAAAAAAAAAIwAAAOhQD2F2K2kKEkfjSUWYAQBCujKEIhUAAAAECBIAAAAUgQAgFIIAgAAlACAAAAABAQAQCAgAQABAAAoACgAAAAAAAAAAAAAAQQAABAAIAAAAAAAAEAQAAIAAQAAAAAAABEhCAAQQAEAAAAAAAAAAAAAAAAAAABAAA%22%2C%221~%22%2C%222259601D-A3C8-4B02-80F2-AF6ADF73E293%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["bazar.bg"],"id":"a7cbcc28-fa3f-46cc-9010-613e5031549b"},{"click":{"optIn":"button#almacmp-modalConfirmBtn","presence":"div.almacmp-controls"},"cookies":{},"domains":["etuovi.com"],"id":"a2cc4223-39e8-4e02-804b-fa9eb4a4ce65"},{"click":{"optIn":"button.css-1tydlop","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["noticiasaominuto.com"],"id":"cbd5d112-8190-40d1-ad4a-6e8f6aa17c5a"},{"click":{"optIn":"button.css-47sehv","presence":"div#qc-cmp2-container"},"cookies":{},"domains":["telegraf.rs"],"id":"6785afba-648d-46cf-8633-3d9c433c79ff"},{"click":{"optIn":"button#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"button#CybotCookiebotDialogBodyButtonDecline","presence":"div#CybotCookiebotDialog"},"cookies":{"optOut":[{"name":"CookieConsent","value":"{stamp:%27hd4jdgROnfr2iNroDX0BfGjqyNhsMI7fLXjrkfZEp9hRGFDoFPyv7w==%27%2Cnecessary:true%2Cpreferences:false%2Cstatistics:false%2Cmarketing:false%2Cmethod:%27explicit%27%2Cver:1%2Cutc:1674227765106%2Cregion:%27ro%27}"}]},"domains":["profesia.sk"],"id":"346b2412-6aef-4eea-b2d5-8b74b4917f4a"},{"click":{"optIn":"button.css-1ysvf99","presence":"div.qc-cmp2-summary-buttons"},"cookies":{},"domains":["flashback.org"],"id":"14d5418a-4df6-4dfe-9c81-fd07669e0f9c"},{"click":{"optIn":"button#almacmp-modalConfirmBtn","presence":"div#almacmp-footer--layer1"},"cookies":{},"domains":["ampparit.com"],"id":"679d7000-cd04-4c35-bbf8-21263a2ff357"},{"click":{"optIn":"button.css-k8o10q","presence":"div#qc-cmp2-ui"},"cookies":{},"domains":["videa.hu"],"id":"6fed31af-f6d2-4452-88ef-8f2ca61c6f19"},{"click":{"optOut":"button#modalConfirmBtn ","presence":"div.gravitoCMP-background-overlay"},"cookies":{},"domains":["hitta.se"],"id":"1998c717-cd3a-48a0-a9f3-67f790f98879"},{"click":{"optIn":"button.css-47sehv","presence":"div.qc-cmp2-summary-buttons"},"cookies":{},"domains":["espreso.co.rs"],"id":"ed6379a2-717a-4571-9a81-abb0c5b29098"},{"click":{"optIn":"#cmpbntyestxt","optOut":"#cmpbntnotxt","presence":"div.cmpboxbtns"},"cookies":{},"domains":["sourceforge.net"],"id":"786f7ae5-548a-43d4-97a2-7b8efb5ed7a7"},{"click":{"optIn":"div#gdpr-single-choice-overlay","presence":"button.wt-btn--filled"},"cookies":{"optOut":[{"name":"p","value":"eyJnZHByX3RwIjoxLCJnZHByX3AiOjF9"}]},"domains":["etsy.com"],"id":"e5706488-f2e9-47bd-a178-4d569ca26ce8"},{"click":{"optIn":"button.cmp-intro_acceptAll","presence":"div.cmp-popup_popup"},"cookies":{},"domains":["onet.pl","fakt.pl","plejada.pl","medonet.pl","businessinsider.com.pl"],"id":"be15b898-a203-45cb-8200-b9b36d2af17b"},{"click":{},"cookies":{"optOut":[{"name":"notice_gdpr_prefs","value":"0:"}]},"domains":["flickr.com"],"id":"22d33421-6872-41bc-9316-adba6a9af18e"},{"click":{},"cookies":{"optOut":[{"name":"OPTOUTMULTI_TYPE","value":"A"}]},"domains":["autodesk.com"],"id":"24fdb694-9d8f-4049-a2f1-583465e711a5"},{"click":{"optIn":"button#consent-accept-button","presence":"div.sc-36lcln-0"},"cookies":{},"domains":["xing.com"],"id":"f82cabad-efa5-4637-8906-9fb842cd6556"},{"click":{"optIn":"span.flex-button","presence":"section.jsx-539809080"},"cookies":{},"domains":["notion.so"],"id":"85205acd-fa99-438e-b353-2b40adfdf868"},{"click":{"optIn":"button#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"button#CybotCookiebotDialogBodyButtonDecline","presence":"div#CybotCookiebotDialog"},"cookies":{},"domains":["aruba.it"],"id":"469218de-6bea-475f-be47-734a412b4fa7"},{"click":{"optIn":"button#AcceptButton-cookie-banner","presence":"div#cookie-banner"},"cookies":{},"domains":["prisjakt.nu"],"id":"6950df9f-2529-4cdc-ab8b-9ba788b6d2f7"},{"click":{"optIn":"button.css-1k3zih6","presence":"div#qc-cmp2-container"},"cookies":{"optIn":[],"optOut":[{"name":"addtl_consent","value":"1~"}]},"domains":["capital.gr"],"id":"8e9824be-3535-4d17-8e64-ae9628a0611d"},{"click":{"optIn":"button#btnInfo","presence":"div#info-modal"},"cookies":{},"domains":["limundo.com"],"id":"5df00bf4-ecbc-4521-862b-db1453be23c9"},{"click":{"optIn":"span.sd-cmp-3cRQ2","presence":"div#sd-cmp"},"cookies":{},"domains":["forocoches.com"],"id":"a0698f6e-dd50-4773-9aad-eb23688383f3"},{"click":{"optIn":"div.accept-btn","optOut":"div.refuse-btn","presence":"div.cookie-pop"},"cookies":{},"domains":["tencent.com"],"id":"e964784f-f4f4-4e71-b973-8c68ef6f49d7"},{"click":{"optIn":"button#truste-consent-button","optOut":"button#truste-consent-required","presence":"div#truste-consent-content"},"cookies":{},"domains":["ibm.com"],"id":"97c1b39b-6573-4dbc-83a4-3af02a416f0a"},{"click":{"optIn":"button.fZYtinTR","presence":"div.CoZ9Nu8Z"},"cookies":{"optIn":[{"name":"FC2_GDPR","value":"true"}]},"domains":["fc2.com"],"id":"5669aa13-d825-45b6-9a65-14904ecd9ee9"},{"click":{"optIn":"div.cmc-cookie-policy-banner__close","presence":"div#cmc-cookie-policy-banner"},"cookies":{"optIn":[{"name":"cmc_gdpr_hide","value":"1"}]},"domains":["coinmarketcap.com"],"id":"faccc72f-fab0-4dd8-82a5-4b97774a0058"},{"click":{"optIn":"div#accept-choices","presence":"div.sn-inner"},"cookies":{},"domains":["w3schools.com"],"id":"230b6c9b-c717-4a88-9d64-9a892091d53d"},{"click":{"optIn":"button#truste-consent-button","optOut":"button#truste-consent-required","presence":"div#truste-consent-track"},"cookies":{},"domains":["nginx.com"],"id":"aaace84f-069e-4713-85f0-7a2f419c34eb"},{"click":{"optOut":"a.n-messaging-banner__button","presence":"div.consent-container"},"cookies":{"optIn":[{"name":"optout","value":"0"}],"optOut":[{"name":"optout","value":"1"}]},"domains":["indiatimes.com"],"id":"e991cb20-0597-4f14-aabc-214a2e493f90"},{"click":{"optIn":"button#_evidon-accept-button","optOut":"button#_evidon-decline-button","presence":"div#_evidon_banner"},"cookies":{"optIn":[{"name":"_tt_enable_cookie","value":"1"}],"optOut":[]},"domains":["eventbrite.com"],"id":"25d7b523-6e33-414a-a1e8-b9f27c7e8a37"},{"click":{"optIn":"a#okck","presence":"div#toast-container"},"cookies":{"optIn":[{"name":"ck","value":"4"}],"optOut":[{"name":"ck","value":"0"}]},"domains":["ilovepdf.com"],"id":"137eec59-6b48-413c-bb45-33420aabdc87"},{"click":{"optIn":"a#CybotCookiebotDialogBodyButtonAccept","presence":"div#CybotCookiebotDialog"},"cookies":{},"domains":["themeforest.net","cpanel.net","envato.com"],"id":"f9b5b6d8-50be-486e-bc59-a45733be492c"},{"click":{"optIn":"button.welcome__button--accept","optOut":"button.welcome__button--decline","presence":"div.welcome__cookie-notice"},"cookies":{},"domains":["wetransfer.com"],"id":"8b43c95f-2617-4541-a88d-ebae3b819bee"},{"click":{"optIn":"button.css-quk35p","presence":"div.css-103nllw"},"cookies":{},"domains":["healthline.com"],"id":"b62e5259-f7f5-4319-8175-e39266b8a031"},{"click":{"optIn":"a.close","presence":"div.ReadPolicy"},"cookies":{},"domains":["huawei.com"],"id":"645dca4f-49b6-456e-8aa1-40dfdb35acb7"},{"click":{"optIn":"button#_evidon-accept-button","optOut":"button#_evidon-decline-button","presence":"div#_evidon_banner"},"cookies":{},"domains":["pubmatic.com"],"id":"35142692-9d67-4f16-9512-36673e35c43d"},{"click":{"optIn":"button.CookieBanner_button__P6xCl","presence":"section.CookieBanner_notificationBar__nn49h"},"cookies":{},"domains":["kaspersky.com"],"id":"1e504f8f-4377-4de7-90e4-cbbfaa30f54d"},{"click":{"optIn":"a#tbp-consent-confirm","presence":"div.tbp-container"},"cookies":{},"domains":["taboola.com"],"id":"cade9499-6c59-4939-90e7-e5e029ce0446"},{"click":{"optIn":"a.cookiepolicycontinue","presence":"div#cookieMessage_content"},"cookies":{},"domains":["oup.com"],"id":"2e0b3da1-4072-4e1b-b561-939789c90f4d"},{"click":{"optIn":"button#cx_button_close","presence":"div#cx_bottom_banner"},"cookies":{"optIn":[{"name":"show_gdpr_consent_messaging","value":"1"}]},"domains":["nbcnews.com"],"id":"fecfb874-fff9-4d91-af27-885729a4556d"},{"click":{"optIn":"button.cta--is-1","presence":"div.cookie-banner__cta"},"cookies":{"optIn":[{"name":"and_cba_EN_US","value":"true"}]},"domains":["android.com"],"id":"35a8e0de-9308-4dfe-abc9-764a9e3833ec"},{"click":{"optIn":"a.cc-dismiss","presence":"div.cc-window"},"cookies":{},"domains":["dnsmadeeasy.com"],"id":"581b7d96-d1a4-43a8-9498-5650f9234e10"},{"click":{"optIn":"button#gdpr-modal-agree","presence":"div.modal-window"},"cookies":{"optIn":[{"name":"gdpr_agreed","value":"4"}]},"domains":["usnews.com"],"id":"d9ebe530-4e45-4315-b628-c2d8c81c48a5"},{"click":{"optIn":"span.js-dismiss-cookie-banner","presence":"div.DesignSystem"},"cookies":{},"domains":["academia.edu"],"id":"41001e78-302d-44da-bd82-a690d1968a9f"},{"click":{"optIn":"button.cu-privacy-notice-close","presence":"div#cu-privacy-notice"},"cookies":{"optIn":[{"name":"cuPivacyNotice","value":"1"}]},"domains":["columbia.edu"],"id":"2952e826-d897-431b-866d-f8ed95f4db64"},{"click":{"optIn":"button.consent-btn","presence":"div.cookie-consent"},"cookies":{},"domains":["geeksforgeeks.org"],"id":"f3d0e044-1dc7-4d6e-9477-2724c5115ba4"},{"click":{"optIn":"button.accept-consent","presence":"section#cookieconsentpopup"},"cookies":{"optIn":[{"name":"consent_cookie","value":"1"}]},"domains":["worldbank.org"],"id":"efe049ac-d21c-4fa6-b559-5c47b5ce307b"},{"click":{"optIn":"button#close_feedback_btn","presence":"div#feedback-bar"},"cookies":{},"domains":["cricbuzz.com"],"id":"22187533-0a56-4679-9244-f11b2c58083a"},{"click":{"optIn":"button.color-secondary","presence":"div.footer_footer__ZK5Q_"},"cookies":{"optIn":[{"name":"__cookie__agree","value":"Y"}]},"domains":["sberdevices.ru"],"id":"c8c58b5e-45d1-4442-ad53-b89f3603586f"},{"click":{"optIn":"button.cookie-accept-btn","presence":"div.cookie-consent-area"},"cookies":{},"domains":["typeform.com"],"id":"c0bef9bb-67e2-4038-bfe9-795085f37719"},{"click":{"optIn":"button.js-opt-in-consent-button","presence":"div.opt-in-modal__inner"},"cookies":{},"domains":["wpengine.com"],"id":"f89481a5-e087-4210-aeee-36bba9764a87"},{"click":{"optIn":"button#cookie-policy-button-accept","presence":"div#modal"},"cookies":{"optIn":[{"name":"_cookies_accepted","value":"all"}],"optOut":[{"name":"_cookies_accepted","value":"essential"}]},"domains":["ubuntu.com"],"id":"b11001c6-7a9c-40a7-8595-3c8a9c1e7416"},{"click":{"optIn":"button#privacy-consent-button","presence":"div#privacy-consent"},"cookies":{},"domains":["vox.com"],"id":"e552ade4-c254-4e8b-823f-8307e4b21fb3"},{"click":{"optIn":"button#ccc-notify-accept","optOut":"button#ccc-notify-dismiss","presence":"div#ccc"},"cookies":{"optIn":[{"name":"_hjFirstSeen","value":"1"}]},"domains":["ox.ac.uk"],"id":"982a2a33-f052-4acd-936e-d3b0f7bf7596"},{"click":{"optIn":"a.c-button","presence":"div#cookiebanner"},"cookies":{},"domains":["psychologytoday.com"],"id":"fcd83d7a-0cbc-4cc4-ac1f-609a303ea5a3"},{"click":{"optIn":"button.consent--accept","presence":"div.consent-banner-buttons"},"cookies":{},"domains":["ring.com"],"id":"081717d3-32c8-40e4-8bc1-ddd5495dbddf"},{"click":{"optIn":"a.accept-cookies","presence":"div.cookie-notice"},"cookies":{"optIn":[{"name":"_hjFirstSeen","value":"1"}]},"domains":["evernote.com"],"id":"a78db283-f6a6-4e80-83d1-65becec1df21"},{"click":{"optIn":"span.cookiePolicy-close","presence":"div.cookiePolicy"},"cookies":{},"domains":["gearbest.com"],"id":"0100a0ae-2e3a-4dcd-8761-596193f6be8d"},{"click":{"optIn":"span.b-policy-info__cross","presence":"div.b-policy-info"},"cookies":{"optIn":[{"name":"cookieAgree","value":"1"}]},"domains":["reg.ru"],"id":"783a1b6f-616d-4f9d-a84b-b0f7954e3e24"},{"click":{"optIn":"button#cookie-policy-btn","presence":"div.cookie"},"cookies":{},"domains":["ucla.edu"],"id":"955c6f08-e07d-4b05-be04-5de69f49753b"},{"click":{"optIn":"button#_evidon-banner-acceptbutton","presence":"div#_evidon-banner-content"},"cookies":{},"domains":["lenovo.com"],"id":"21e686fb-7250-4fbc-ab5c-6a6bf67775d3"},{"click":{"optIn":"a.button--default","presence":"div#cookie-notification"},"cookies":{"optIn":[{"name":"mdpi_cookies_accepted","value":"1"}]},"domains":["mdpi.com"],"id":"4f9c6403-4953-48aa-a8d7-d7acf177d437"},{"click":{"optIn":"button#_evidon-decline-button","presence":"div#_evidon-message"},"cookies":{},"domains":["crunchyroll.com"],"id":"85aec7ab-1cc2-4651-b3fc-0cbae9a241f2"},{"click":{"optIn":"button.css-ZtxlD","optOut":"a.css-jMqFMB","presence":"div.css-fPpfoE"},"cookies":{},"domains":["uber.com"],"id":"663e3527-0018-4851-912d-c75a9d610881"},{"click":{"optIn":"button#ccc-notify-accept","optOut":"button#ccc-notify-reject","presence":"div#ccc"},"cookies":{},"domains":["tapad.com"],"id":"026010ef-311b-4c3e-aa1d-cb1470591c6a"},{"click":{"optIn":"button#unic-agree","presence":"div.unic-bar"},"cookies":{},"domains":["sharethrough.com"],"id":"d448486a-ad5c-45dd-b661-c22a82869036"},{"click":{"optIn":"span#cookie-banner-close","presence":"div#cookie-banner"},"cookies":{"optIn":[{"name":"hideCookieBanner","value":"true"}]},"domains":["substack.com"],"id":"09f72241-e3be-4156-a8ac-ecf47145854f"},{"click":{"optIn":"a#et_cookie_consent_allow","presence":"div.et_cookie_consent"},"cookies":{"optIn":[{"name":"et_cookies","value":"on"}],"optOut":[{"name":"et_cookies","value":"off"}]},"domains":["elegantthemes.com"],"id":"ae4a00ba-e49c-4376-a5a7-67d9b647342d"},{"click":{"optIn":"button.cookie-consent-banner-opt-out__action","presence":"div.cookie-consent-banner-opt-out"},"cookies":{},"domains":["mercadolibre.com.ar"],"id":"b6fda273-20bf-4e49-8a2b-fe2afdcc12da"},{"click":{"optIn":"button.closeButton","presence":"div.cookieBanner"},"cookies":{},"domains":["anchor.fm"],"id":"475b40e3-18d5-457e-a084-76faa301c753"},{"click":{"optIn":"button.button-accept-cookie","presence":"div.banner-overlay"},"cookies":{"optIn":[{"name":"analytics_accepted","value":"true"},{"name":"cookie_accepted","value":"true"}],"optOut":[{"name":"cookies_denied","value":"true"}]},"domains":["aboutcookies.org"],"id":"2de3ce99-ba76-417e-851c-87e0c4035180"},{"click":{"optIn":"a.js-gdpr-cookie-acceptLink","presence":"div.widget-GdprCookieBanner"},"cookies":{"optIn":[{"name":"CookieBanner_Closed","value":"true"}]},"domains":["jamanetwork.com"],"id":"6026221f-dd61-493e-aea8-cdf38198f401"},{"click":{"optIn":"button#nhsuk-cookie-banner__link_accept_analytics","optOut":"button#nhsuk-cookie-banner__link_accept","presence":"div#nhsuk-cookie-banner"},"cookies":{},"domains":["www.nhs.uk"],"id":"e6444889-fd2f-412a-b25d-41a6b6daaf3a"},{"click":{"optIn":"button.button_b1lbbqqt","presence":"div.modalStyle_modrqv7"},"cookies":{},"domains":["nikkei.com"],"id":"546792b9-f201-4e94-97f6-d5680abfe529"},{"click":{"optIn":"button.fc-primary-button","presence":"div.fc-consent-root"},"cookies":{},"domains":["17track.net"],"id":"a620f10c-033a-47c1-ad2b-a8fd1df9e504"},{"click":{"optIn":"a.cc-dismiss","presence":"div.cc-window"},"cookies":{"optIn":[{"name":"cookieconsent_status","value":"dismiss"}]},"domains":["duke.edu"],"id":"d614e3e1-1282-4c56-801d-525263028933"},{"click":{"optIn":"a#cookie_action_close_header","presence":"div#cookie-law-info-bar"},"cookies":{"optIn":[{"name":"viewed_cookie_policy","value":"yes"}]},"domains":["usc.edu"],"id":"5cedc12d-d79c-4be8-9e45-e98905147090"},{"click":{"optIn":"button.btn-accept","presence":"div#gdpr-new-container"},"cookies":{},"domains":["aliexpress.com"],"id":"80851a39-2183-49e4-99f4-16d6189bff1e"},{"click":{"optOut":"button.cookieBarButtons","presence":"div#cookieBar"},"cookies":{},"domains":["google-analytics.com"],"id":"286028cd-7cb7-4c71-91a7-ae1a23df8a31"},{"click":{"optIn":"div.global-alert-banner button[action-type=ACCEPT]","optOut":"div.global-alert-banner button[action-type=DENY]","presence":"div.global-alert-banner"},"cookies":{},"domains":["linkedin.com"],"id":"f1ddc6f6-8927-4205-8003-1f6e84ae22b0"},{"click":{"optIn":"button[data-a-target=consent-banner-accept]","presence":"div.consent-banner"},"cookies":{},"domains":["twitch.tv"],"id":"542aafba-9f44-4321-88e5-ece333073360"},{"click":{"hide":"div#onetrust-consent-sdk","optIn":"button#onetrust-accept-btn-handler","optOut":"button.ot-pc-refuse-all-handler","presence":"div#onetrust-banner-sdk"},"cookies":{"optOut":[{"name":"OptanonAlertBoxClosed","value":"2022-08-09T16:49:23.845Z"}]},"domains":["getpocket.com"],"id":"c2f6b05e-73dc-4df4-bb54-68215bb9f176"},{"click":{},"cookies":{"optIn":[{"name":"wa_cb","value":"1_2022_08_09_"}],"optOut":[]},"domains":["whatsapp.com"],"id":"0f4b1486-7d4b-4f73-8ec9-122daca9ebf4"},{"click":{},"cookies":{"optIn":[{"name":"sensitive_pixel_option","value":"yes"}]},"domains":["wordpress.com"],"id":"709f87b8-b010-4d32-b32d-3f265963c6a5"},{"click":{},"cookies":{"optOut":[{"name":"eu_cookie","value":"{%22opted%22:true%2C%22nonessential%22:false}"}]},"domains":["reddit.com"],"id":"c5243e7c-eb86-4a9d-947c-7129e99fbd72"},{"click":{"optIn":".btn--primary","presence":"div#cookie-consent"},"cookies":{"optIn":[{"name":"cookie_consent_essential","value":"true"},{"name":"cookie_consent_marketing","value":"true"}]},"domains":["opera.com"],"id":"09884f7b-ef06-45dd-9bda-960b5c6b7232"},{"click":{"optIn":".a8c-cookie-banner-accept-all-button","presence":".a8c-cookie-banner"},"cookies":{},"domains":["gravatar.com"],"id":"4b835605-77e0-457a-8409-8d499ee1131c"},{"click":{"optIn":"a#accept-button","optOut":"a#CybotCookiebotDialogBodyButtonDecline","presence":"div#c-right"},"cookies":{},"domains":["yettel.bg"],"id":"4ec170c6-933c-4612-9907-80bc8ef6039c"},{"click":{"optIn":"button.btn-primary","presence":"div.alert-secondary"},"cookies":{"optOut":[{"name":"privacy_cookie","value":"1"}]},"domains":["bakecaincontrii.com"],"id":"a8984148-8c62-4dd5-8350-4e0da48f1829"},{"click":{"optIn":"button.mat-button-base","presence":"section#cookie-banner"},"cookies":{"optIn":[{"name":"cookie-banner-acceptance-state","value":"true"}]},"domains":["migros.ch"],"id":"cd670e2a-b764-4722-8ff2-a136350a60d8"},{"click":{"optIn":"button#didomi-notice-agree-button","presence":"div#buttons"},"cookies":{"optIn":[{"name":"euconsent-v2","value":"CPhJZsAPhJZsAAHABBENClCsAP_AAH_AAAiQJFNf_X__b2_r-_5_f_t0eY1P9_7__-0zjhfdl-8N3f_X_L8X52M7vF36tq4KuR4ku3LBIUdlHOHcTUmw6okVryPsbk2cr7NKJ7PEmnMbOydYGH9_n1_z-ZKY7___f_7z_v-v___3____7-3f3__5___-__e_V__9zfn9_____9vP___9v-_9__________3_7997BIQAkw1biALsSxwJtowigRAjCsJDqBQAUUAwtEBhA6uCnZXAT6wgQAIBQBGBECHAFGDAIAAAIAkIiAkCPBAIACIBAACABUIhAARsAgoALAwCAAUA0LFGKAIQJCDIgIilMCAiRIKCeyoQSg_0NMIQ6ywAoNH_FQgIlACFYEQkLByHBEgJeLJAsxRvkAIwQoBRKhWoAAAA.f_gAD_gAAAAA"}],"optOut":[{"name":"euconsent-v2","value":"CPhJZsAPhJZsAAHABBENClCgAAAAAH_AAAiQAAASEAJMNW4gC7EscCbaMIoEQIwrCQ6gUAFFAMLRAYQOrgp2VwE-sIEACAUARgRAhwBRgwCAAACAJCIgJAjwQCAAiAQAAgAVCIQAEbAIKACwMAgAFANCxRigCECQgyICIpTAgIkSCgnsqEEoP9DTCEOssAKDR_xUICJQAhWBEJCwchwRICXiyQLMUb5ACMEKAUSoVqAA.YAAAD_gAAAAA"}]},"domains":["trendings.es"],"id":"13dff385-bb91-414f-8fa3-88ae99621aba"},{"click":{"optIn":"button.btn-cta-lg","optOut":"button.btn-secondary-lg","presence":"div.cookie-button-container"},"cookies":{},"domains":["roblox.com"],"id":"1e55c3c3-63d2-45b2-8871-dfae1396c1a0"},{"click":{"optIn":"div._euwdl0","presence":"footer._nlniiu"},"cookies":{},"domains":["2gis.ru"],"id":"2a737c68-b3ed-4883-b02e-4cff18b538b4"},{"click":{"optOut":"button.portal-button","presence":"div.CookieWall"},"cookies":{},"domains":["mozzartsport.com"],"id":"7b299edf-ea10-472a-a3d9-cd622bde1ef9"},{"click":{"optIn":"button#acceptButton","optOut":"button#declineButton","presence":"div.coi-button-group"},"cookies":{},"domains":["yousee.dk"],"id":"31ef8068-58b4-400b-81cd-a027a16a2305"},{"click":{"optIn":"button.blue","presence":"div.cookie-popup"},"cookies":{"optIn":[{"name":"marketing","value":"1"},{"name":"analytic","value":"1"}]},"domains":["supersport.hr"],"id":"7eb3fb43-94c5-49da-80ca-1647f8398eec"},{"click":{"optIn":"buton#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"button#CybotCookiebotDialogBodyButtonDecline","presence":"div#CybotCookiebotDialogBodyButtons"},"cookies":{},"domains":["berlingske.dk"],"id":"d7c0b359-8cdb-433c-b501-6fb2fdad0dc0"},{"click":{"optOut":"a#ensCall","presence":"div.td-modal-cookie-content"},"cookies":{},"domains":["td.com"],"id":"eb274e15-29fe-4004-9e6d-27046bd0b82d"},{"click":{"optIn":"a.cc_btn_accept_all","presence":"div.cc_banner-wrapper"},"cookies":{"optIn":[{"name":"cookieconsent_dismissed","value":"yes"}],"optOut":[]},"domains":["online-filmek.me"],"id":"c200bbbd-3075-48ee-a507-e5934eb52567"},{"click":{"optIn":"a.A","optOut":"a.R","presence":"div#CkC"},"cookies":{},"domains":["sfr.fr"],"id":"dc867098-30ca-4a28-82b4-71abac243dab"},{"click":{"optIn":"a.cookies-button","presence":"div#cookies-overlay"},"cookies":{"optIn":[{"name":"approve","value":"yes"}],"optOut":[]},"domains":["linker.hr"],"id":"10b58019-5dce-4018-b83d-8eef8c7564a7"},{"click":{"optIn":"a.cookies-banner-button","presence":"div#cookies-banner"},"cookies":{"optIn":[{"name":"cookiesAgreement","value":"1"}],"optOut":[]},"domains":["dnevnik.bg"],"id":"74f56970-6ebe-4802-914e-72aeca0e13b3"},{"click":{"optIn":"button.button--primary","presence":"div.modal__body"},"cookies":{"optIn":[{"name":"CONSENTMGR","value":"c1:1%7Cc6:1%7Cc7:1%7Cc15:1%7Cconsent:true%7Cts:1665653237583"}],"optOut":[]},"domains":["swisscom.ch"],"id":"3c03e0ec-aa84-48a1-83ca-0bf07d24e20e"},{"click":{"optIn":"button#truste-consent-button","optOut":"div#truste-consent-required","presence":"div.truste-consent-content"},"cookies":{},"domains":["samsung.com"],"id":"943a1f39-57c2-430e-b91d-81a659d9b036"},{"click":{"optIn":"button.js-cookies-hide","presence":"div.cookie-label__btn-set"},"cookies":{"optIn":[{"name":"cookieApprove","value":"true"}]},"domains":["nv.ua"],"id":"e8aa7447-2f27-4b65-bbdb-dcecc30c6c1f"},{"click":{"optIn":"button.consent-accept","presence":"div#consent-accept"},"cookies":{"optIn":[{"name":"s_cc","value":"true"}]},"domains":["dnb.no"],"id":"0b8969b6-d5a1-4358-967b-524a2c998233"},{"click":{"optIn":"a#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"a#CybotCookiebotDialogBodyLevelButtonLevelOptinDeclineAll","presence":"div#CybotCookiebotDialog"},"cookies":{},"domains":["e-boks.com"],"id":"a1bb84f0-e248-4576-8cd5-722622120a7d"},{"click":{"optIn":"a#cn-accept-cookie","presence":"div#cookie-notice"},"cookies":{"optIn":[{"name":"cookie_notice_accepted","value":"true"}]},"domains":["danas.rs"],"id":"d6ee6a87-66ad-4c35-88ac-966d4fff81f7"},{"click":{"optIn":"button.kitt-cookie-warning__close","presence":"div.kitt-cookie-warning__content"},"cookies":{"optIn":[{"name":"sbrf.pers_notice","value":"1"}],"optOut":[]},"domains":["sberbank.ru"],"id":"40746884-0f10-4e12-ab0d-2a4410b1e0f9"},{"click":{"optIn":"a#kmcc-accept-all-cookies","presence":"div.kmcc-cookie-bar__footer__preferences__second"},"cookies":{"optIn":[{"name":"legal_cookie","value":"%7B%22cookies%22%3A%7B%22functional_cookie%22%3A%22true%22%2C%22analyzing_cookie%22%3A%22true%22%7D%2C%22cookie_log_id%22%3A%2225634502%22%2C%22cookie_version%22%3A20200608%7D"}],"optOut":[{"name":"legal_cookie","value":"%7B%22cookies%22%3A%7B%22functional_cookie%22%3A%22true%22%2C%22analyzing_cookie%22%3A%22false%22%2C%22marketing_cookie%22%3A%22false%22%7D%2C%22cookie_log_id%22%3A%2225634476%22%2C%22cookie_version%22%3A20200608%7D"}]},"domains":["meteo.be"],"id":"67e420b4-05e6-4c01-a999-0d48dba85362"},{"click":{"optIn":"button#didomi-notice-agree-button","presence":"div#buttons"},"cookies":{"optIn":[],"optOut":[{"name":"euconsent-v2","value":"CPgrvQAPgrvQAAHABBENCkCgAAAAAAAAAAAAAAAAAAAA.YAAAAAAAAAAA"}]},"domains":["story.hr"],"id":"735b925d-388b-4df5-b66e-2907674cd126"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons"},"cookies":{"optIn":[],"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgrvQAPgrvQAEsABCSKCkCgAAAAAAAAACRQAAAOhQD2F2K2kKEkfjSUWYAQBCujIEIhUAAAAECBIAAAAUgQAgFIIAgAAlACAAAAABAQAQCAgAQABAAAgACgAAAAAAAAAAAAAAQQAABAAIAAAAAAAAAAQAAIAAQAAAAAAABEhCAAQSAEAAAAAAAAAAAAAAAAAAABAAA.YAAAAAAAAAA%22%2C%221~%22%2C%229EBAD907-6709-4964-8B38-C2711989FD29%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["modrykonik.sk"],"id":"97909ba0-2fbd-410e-b2b9-3e165930ac61"},{"click":{"optIn":"button.as-js-optin","presence":"div.as-oil-l-wrapper-layout-max-width"},"cookies":{"optIn":[],"optOut":[{"name":"oil_data","value":"{%22opt_in%22:true%2C%22version%22:%221.2.5-RELEASE%22%2C%22localeVariantName%22:%22de_01%22%2C%22localeVariantVersion%22:1%2C%22customPurposes%22:[]%2C%22consentString%22:%22BPgtAGPPgtAGPBQABBDECKAAAABCVY_KfQrC0oWQ3LTh5AAkALqlgRiFSEAIHYRE4AIRZUACSAEggHMoyUBIA8RAAERATIJABBgQEAISkAOAAIAgIpACEAgYAJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAf____3____8A%22%2C%22configVersion%22:0}"}]},"domains":["tagesanzeiger.ch"],"id":"c9ea0470-beac-43b9-aed1-d77042592d83"},{"click":{"optIn":"button.css-k8o10q","presence":"div#qc-cmp2-container"},"cookies":{"optOut":[]},"domains":["sport-fm.gr"],"id":"d88020d5-47d0-4926-8375-d279870f1663"},{"click":{"optIn":"button.orejime-Notice-saveButton","optOut":"button.orejime-Notice-declineButton","presence":"div.orejime-Notice"},"cookies":{"optIn":[{"name":"fedconsent","value":"{\"essential\":true,\"functional\":true,\"matomo\":true}"}],"optOut":[{"name":"fedconsent","value":"{\"essential\":true,\"functional\":true,\"matomo\":false}"}]},"domains":["belgium.be"],"id":"98fcb883-013a-4858-a181-28c87e399c42"},{"click":{"optIn":"a#cookieAccept","presence":"div#cookieContent"},"cookies":{},"domains":["publi24.ro"],"id":"8d64659e-ece2-476d-a1c6-eec9e4070647"},{"click":{"optIn":"button#cmp-btn-accept","presence":"div#cmp-consent"},"cookies":{},"domains":["wetter.com"],"id":"8e274753-a1ee-4e02-b131-fa937ab10aea"},{"click":{"optIn":"a#startsiden-gdpr-disclaimer-confirm","presence":"div#startsiden-gdpr-disclaimer"},"cookies":{"optIn":[{"name":"startsiden-gdpr-disclaimer","value":"true"}]},"domains":["startsiden.no","abcnyheter.no"],"id":"00e9de62-0fc4-4266-8e8c-106da3a624c0"},{"click":{"optIn":"button#truste-consent-button","optOut":"button#truste-consent-required","presence":"div#truste-consent-buttons"},"cookies":{},"domains":["weather.com"],"id":"8ef284ed-21d1-4825-8068-34ac22e5232d"},{"click":{"optIn":"button.noticeButton","presence":"div.privacyNotification"},"cookies":{},"domains":["cbc.ca"],"id":"f69ced41-7e20-4b39-84a2-0fa62e7df3ef"},{"click":{"optIn":"a#CybotCookiebotDialogBodyButtonAccept","optOut":"a#CybotCookiebotDialogBodyButtonDecline","presence":"div#CybotCookiebotDialog"},"cookies":{},"domains":["mondo.rs"],"id":"f1502dfd-a03c-4ca1-ab5d-488b2e09b644"},{"click":{"optIn":"a.js-cookies-info-accept","optOut":"a.js-cookies-info-reject","presence":"div.cookies-info__buttons"},"cookies":{},"domains":["alza.sk"],"id":"93b1a4a4-49e2-4160-98ae-e2311123c7f9"},{"click":{"optIn":"button.coi-banner__accept","optOut":"button#declineButton","presence":"div.coi-button-group"},"cookies":{},"domains":["dmi.dk"],"id":"db64d8f2-1d35-4b57-a274-452efbcf2589"},{"click":{"optIn":"a.close-accept","presence":"div.woahbar"},"cookies":{},"domains":["theweathernetwork.com"],"id":"3cfb8e27-c0b3-46c0-bee2-f4eef9c2a548"},{"click":{"optIn":"button.cookiebtn","presence":"div.button"},"cookies":{},"domains":["watson.ch"],"id":"3f8bdfb5-b898-4c25-ad68-6e10dab38e45"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons-container"},"cookies":{"optIn":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgocUAPgocUAEsABBHRCkCoAP_AAH_AAA6IIqNd_H__bX9n-f7_6ft0eY1f9_r37uQzDhfNs-8F3L_W_LwX_2E7NF36tq4KmR4ku1LBIQNtHMnUDUmxaokVrzHsak2cpyNKJ7BkknsZe2dYGFtPm5lD-QKZ7_5_d3f52T_9_9v-39z33913v3d_3-_12Ljd_599H_v_fR_bc_Kft_5-_8v8_____3_BFNjv43bra_s7x-d9R5ujRGr6v5S_VwGYcI4tGjgE5fy35WAf6wnYAu3RpWBEyPElmpAJCAhIAk4gKk2LREipaIZBACTFEBpBDYMkgtjLywKAgkh8XEoKwBTPL3NxIzvOSW_HdN_2_uW63uut-Jl63wcuhcbP3Fto21t7wAjLBwThmpJWvFpn53_-mZwAAA.cAAAD_gAAAA%22%2C%221~2052.2056.2064.20.2068.2069.2070.2072.2074.2084.39.2088.2090.43.46.2103.55.57.2107.2109.61.2115.70.2124.2130.83.2133.2137.89.2140.93.2145.2147.2150.108.2156.117.2166.122.124.2177.131.135.2183.136.2186.143.144.147.149.2202.2205.159.162.2213.167.2216.171.2219.2220.2222.2224.2225.2234.192.196.202.2253.211.2264.218.228.230.2279.2282.239.241.2292.2299.2305.259.2309.2312.266.2315.2316.272.2322.2325.2328.2331.2334.286.2335.2336.2337.291.2343.2354.2357.2358.2359.311.317.2370.322.323.2373.326.327.2376.2377.338.2387.2392.2394.2400.2403.2405.2406.358.2407.2411.2414.2415.367.2416.2418.370.371.2425.2427.385.389.2440.394.397.2447.2453.407.2459.2461.413.2462.415.2465.2468.2472.424.2477.430.2481.2484.436.2486.2488.2493.445.2496.2497.449.2498.2499.2501.453.2506.2510.2511.2517.469.2526.2527.482.2532.2534.486.2535.491.2542.494.495.501.503.2552.505.2555.2559.2563.2564.2567.2568.2569.522.2571.523.2572.2575.2577.2583.2584.540.2589.2596.2597.550.2601.2602.2604.2605.559.2608.2609.2610.2612.2614.568.2618.2621.574.2624.576.2628.2629.584.2633.2634.587.2636.591.2642.2643.2645.2646.2647.2650.2651.2652.2656.2657.2658.2660.2661.2669.2670.624.2677.2681.2684.2686.2687.2689.2690.2695.2698.2707.2713.2714.2729.2739.2767.2768.2770.2772.733.2784.737.2787.2791.2792.2793.745.2798.2801.2805.2812.2813.2814.2816.2817.2818.2821.2822.2824.2827.2830.2831.2832.2834.787.2838.2839.2840.2844.2846.798.2847.2849.2850.802.803.2852.2854.2856.2860.2862.2863.2865.817.2867.820.2869.821.2872.2873.2874.2875.827.2876.829.2878.2880.2881.2882.2883.2884.2886.2887.839.2888.2889.2891.2893.2894.2895.2897.2898.2900.2901.2908.2909.2911.2912.864.2913.2914.867.2916.2917.2918.2919.2920.2922.874.2923.2924.2927.2929.2930.2931.2935.2939.2940.2941.2942.2947.899.2949.2950.904.2956.2961.2962.2963.2964.2965.2966.2968.2970.922.2972.2973.2974.2975.2979.931.2980.2981.2983.2985.2986.938.2987.2991.2994.2995.2997.2999.3000.3002.3003.3005.3008.3009.3010.3012.3016.3017.3018.3019.3023.3024.3025.979.3028.981.3030.985.3034.3037.3038.3043.3045.3048.1003.3052.3053.3055.3058.3059.3063.3065.3066.3068.3070.1024.3072.3073.3074.1027.3075.3076.3077.3078.1031.1033.1040.3089.3090.3093.1046.3094.3095.1048.3097.1051.3099.1053.3104.3106.3109.3112.1067.3117.3118.3119.3120.3124.3126.3127.3128.3130.1085.3133.3135.3136.3137.1092.1095.1097.3145.1099.3149.3150.3151.3153.3154.1107.3155.3162.3163.3167.3172.3173.1127.3180.3182.1135.3183.3184.3185.3187.3188.3189.3190.1143.3194.3196.1149.3197.1152.3209.1162.3210.3211.1166.3214.3215.3217.1171.3219.3222.3223.3225.3226.3227.3228.3230.3231.3232.1186.3234.3235.1188.3236.3237.3238.3240.3241.3244.3245.1201.3250.3251.1205.3253.3254.3257.1211.3260.1215.3266.1220.3268.3270.3272.1226.1227.1230.3281.3286.3288.3290.3292.3293.3295.3296.1252.3300.1268.1270.3322.1276.1284.1286.1290.1301.1307.1312.1345.1356.1364.1365.1375.1403.1415.1416.1419.1440.1442.1449.1455.1456.1465.1495.1512.1516.1525.1540.1548.1555.1558.1564.1570.1577.1579.1583.1584.1591.1603.1616.1638.1651.1653.1660.1665.1667.1677.1678.1682.1697.1699.1703.1712.1716.1720.1721.1725.1732.1745.1750.1753.1765.1769.1782.1786.1800.1808.1810.1825.1827.1832.1838.1840.1842.1843.1845.1859.1866.1870.1878.1880.1889.1898.1899.1911.1917.1929.1942.1944.1958.1962.1963.1964.1967.1968.1969.1978.2003.2007.2008.2012.2027.2035.2039.2044.2047%22%2C%221B663699-8278-41B8-9A73-C98E45F0FDDF%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}],"optOut":[{"name":"UA_ADS","value":"{\"/21617374708/novilist.hr/home_break_v2\":5,\"/21617374708/novilist.hr/content_v1\":5,\"/21617374708/novilist.hr/content_v2\":5,\"/21617374708/novilist.hr/content_v3\":5,\"/21617374708/novilist.hr/content_parallax_v1\":5,\"/21617374708/novilist.hr/home_break_v1\":5,\"/21617374708/novilist.hr/home_break_v3\":5,\"/21617374708/novilist.hr/home_sidebar_v1\":4,\"/21617374708/novilist.hr/home_sidebar_v2\":5,\"/21617374708/novilist.hr/home_sidebar_v3\":5,\"/21617374708/novilist.hr/home_wallpaper_left\":4,\"/21617374708/novilist.hr/home_wallpaper_right\":4,\"/21617374708/novilist.hr/life_content_v1\":5,\"/21617374708/novilist.hr/life_content_v2\":5,\"/21617374708/novilist.hr/life_content_v3\":5,\"/21617374708/novilist.hr/life_sidebar_v1\":5,\"/21617374708/novilist.hr/life_home_top_v1\":5,\"/21617374708/novilist.hr/life_wallpaper_left\":5,\"/21617374708/novilist.hr/life_wallpaper_right\":5,\"/21617374708/novilist.hr/gospodarstvo_billboard_v1\":5,\"/21617374708/novilist.hr/vijesti_billboard_v1\":5,\"/21617374708/novilist.hr/gallery_v1\":5,\"/21617374708/novilist.hr/gallery_v2\":5,\"/21617374708/novilist.hr/gallery_v3\":5,\"/21617374708/novilist.hr/gallery_inarticle_v1\":5,\"/21617374708/novilist.hr/gallery_inarticle_v2\":5,\"/21617374708/novilist.hr/gallery_inarticle_v3\":5,\"/21617374708/novilist.hr/ticker_desktop_v1\":4,\"/21617374708/novilist.hr/sport_content_v1\":5,\"/21617374708/novilist.hr/sport_parallax_v1\":5,\"/21617374708/novilist.hr/home_top_v1\":3,\"/21617374708/novilist.hr/teads_v1\":5}"}]},"domains":["novilist.hr"],"id":"4e504e16-4d0e-4a57-bb3c-b6349d1a5653"},{"click":{"optIn":"button.gdpr-lmd-button--main","presence":"div.gdpr-lmd-wall"},"cookies":{},"domains":["lemonde.fr"],"id":"9182a6f2-eddc-43b2-991e-8b3a204e4eac"},{"click":{"optIn":"button","presence":"div.gdprcookie"},"cookies":{"optOut":[{"name":"cookieControlPrefs","value":"[\"essential\"]"}]},"domains":["zamunda.net"],"id":"03f54762-dc2a-4cf9-bf1b-412a68dbf0db"},{"click":{"optIn":"button#save-all-action","optOut":"button#save-necessary-action","presence":"div.iOMuvDyuoMKpVRzmevldA3KUmWI2t3RJ"},"cookies":{},"domains":["veikkaus.fi"],"id":"afa1eaa5-68fa-4fe8-97f0-3176c0eb6557"},{"click":{"optIn":"button#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll","optOut":"button#CybotCookiebotDialogBodyButtonDecline","presence":"div#CybotCookiebotDialogBodyButtonsWrapper"},"cookies":{},"domains":["bt.dk"],"id":"3b604615-6d14-4ac8-b184-b9421b99a07c"},{"click":{"optIn":"button.fc-cta-consent","presence":"div.fc-footer-buttons"},"cookies":{"optIn":[],"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgejgAPgejgAEsABCHRCkCgAAAAAAAAAA6IAAAOhQD2F2K2kKEkfjSUWYAQBCujIEIhUAAAAECBIAAAAUgQAgFIIAgAAlACAAAAABAQAQCAgAQABAAAoACgAAAAAAAQAAAAAAQQAABAAIAAAAAAAAEAQAAIAAQAAAAAAABEhCAAQQQEAAAABAAAAAAAQAAAAAABAAA.YAAAAAAAAAA%22%2C%221~%22%2C%22EA05584B-4C95-44E8-A602-F0B836FF2176%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["dnevno.hr"],"id":"032bda24-ffad-4283-a36b-e1c1dd0c46d7"},{"click":{"optIn":"button#ocm-button.ocm-button--accept-all","optOut":"button.ocm-button--continue","presence":"div.ocm-footer"},"cookies":{},"domains":["op.fi"],"id":"86b4e119-8e5c-471d-bf80-c65489277135"},{"click":{"optIn":"button.eu-cookie-compliance-secondary-button","optOut":"button.eu-cookie-compliance-default-button","presence":"div#popup-buttons"},"cookies":{"optIn":[{"name":"cookie-agreed","value":"1"}],"optOut":[{"name":"cookie-agreed","value":"0"}]},"domains":["gsis.gr"],"id":"c3f6134c-061a-4828-ab89-b6f12015a1f3"},{"click":{"optIn":"button#usage_notice_button","presence":"div.button"},"cookies":{"optIn":[{"name":"_accept_usage","value":"1"}]},"domains":["censor.net"],"id":"4e5a6503-adb4-4e4d-8113-f29a93bf11a7"},{"click":{"optIn":"button.cookie-banner__button","presence":"div#cookie-banner"},"cookies":{"optIn":[{"name":"tv2samtykke","value":"1"}]},"domains":["tv2.no"],"id":"b2a31215-49cc-4edb-801d-09d6ec435848"},{"click":{"optIn":"button.css-1j8kkja","presence":"div.qc-cmp2-summary-buttons"},"cookies":{"optIn":[{"name":"cto_bundle","value":"cETUWl96SkZFS1NJQUlCR3lQZlZ1WUt3Z3BaMW9qVEU1U25BaFRXdiUyQk1FeDhIWUJkVmh1b1VqY2dTbTB4bmRsaHliT3FZcFhXNFF6bU5HeSUyQkFiSVBBZ1NtVWR0b0w3T3pVR3dUTUhKeWJtSElWJTJCVDlRREl4dSUyRmRJdDBiM2M0VUs3S3R4UXI3Sjd5NENTUHFXcll1MEFGejJLdyUzRCUzRA"}],"optOut":[{"name":"euconsent-v2","value":"CPgfy_fPgfy_fAKAnAELCkCgAAAAAH_AAAyIAAASIAJMNW4gC7MscGbQMIoEQIwrCQqgUAEFAMLRAYAODgp2VgE-sIEACAUARgRAhwBRgQCAAASAJCIAJAiwQAAAiAQAAgARCIQAMDAILACwMAgABANAxRCgAECQgyICIpTAgKgSCA1sqEEoLpDTCAOssAKCRGxUACIJARWAAICwcAwRICViwQJMUb5ACMEKAUSoVqIAAAAA.YAAAAAAAAAAA"}]},"domains":["sport24.gr"],"id":"02a059b8-09a4-488c-afa0-e208c4b8b84d"},{"click":{"optIn":"button.cookie-close","presence":"div#cookiesBar"},"cookies":{"optIn":[{"name":"cookieBarSeen","value":"true"}]},"domains":["olx.ua"],"id":"9944d588-486e-4f01-a5b9-17d1e9cc744a"},{"click":{"optIn":"button.css-pp-ok","presence":"div.css-pp-box"},"cookies":{},"domains":["dagbladet.no","sol.no"],"id":"ebbaf3a6-10bb-4cd3-8294-5b095984e21a"},{"click":{"optIn":"button","presence":"div.fucking-eu-cookies"},"cookies":{"optIn":[{"name":"fucking-eu-cookies","value":"1"}]},"domains":["bazos.sk","bazos.cz"],"id":"5cb47b97-2d77-4301-af71-0ec0b4aa0e9c"},{"click":{"optIn":"button.CookieConsent_button__FJrIc","presence":"div.CookieConsent_holder__ZsT3G"},"cookies":{"optIn":[{"name":"FCNEC","value":"%5B%5B%22AKsRol-hQ0GC8scayCxS70oIbLW375lxZBB419tjfwu1fOoWf-QLr5NOEOgKKLPu5Em82ydIwG4STH2DOpPVM65ZS_y2CCQlVsaUDCu-KZl2LrrYKqTftQDxBBuO-EmausJD4fO6ZHNWJEHTyKM8wJgrIadkxR4m9g%3D%3D%22%5D%2Cnull%2C%5B%5D%5D"}],"optOut":[{"name":"FCCDCF","value":"%5Bnull%2Cnull%2Cnull%2C%5B%22CPgX9oAPgX9oAEsABCENCjCgAAAAAAAAABpYAAAOhQD2F2K2kKEkfjSUWYAQBCujIEIBUAAAAECBIAAAAUgQAgFIIAgAAlACAAAAABAQAQCAgAQABAAAoACgACAAAAAAAAAAAAQQAABAAIAAAAAAAAEAQAAAAAQAAAAAAABEhCAAQQAEAAAAAAAAAAAAAAAAAAABAAA.YAAAAAAAAAA%22%2C%221~%22%2C%22D2A36A86-FAFB-4BB0-951A-2BA964C5C018%22%5D%2Cnull%2Cnull%2C%5B%5D%5D"}]},"domains":["kupujemprodajem.com"],"id":"944c0cf0-271b-41f8-b0ca-3fa67db7af29"},{"click":{"optIn":"button#accept-all","optOut":"button#accept-essential","presence":"div.actions"},"cookies":{"optOut":[{"name":"policy_level","value":"%7B%22essential%22%3A%22true%22%2C%22performance%22%3A%22false%22%2C%22preference%22%3A%22false%22%2C%22targeting%22%3A%22false%22%7D"}]},"domains":["skroutz.gr"],"id":"fc149ac6-5a51-49fb-bb14-2c2dce8f6628"},{"click":{"optIn":"button#almacmp-modalConfirmBtn","presence":"div.almacmp-controls"},"cookies":{},"domains":["iltalehti.fi"],"id":"23fcab4a-3b43-4d73-bb9e-57d86121141b"},{"click":{"optIn":"button.agree-btn","presence":"div.message-column main-container"},"cookies":{},"domains":["wsj.com"],"id":"edc06db8-5073-11ed-bdc3-0242ac120002"},{"click":{},"cookies":{"optOut":[{"name":"bolConsentChoices","value":"source#OFC|version#6|int-tran#false|ext-tran#false|int-beh#false|ext-beh#false"}]},"domains":["bol.com"],"id":"637c8bb9-b2f6-493e-86c2-f1954aa6a96a"},{"click":{"optIn":"button.js-cookies-hide","presence":"div.cookie-label"},"cookies":{"optIn":[{"name":"is_agree","value":"1"}]},"domains":["gordonua.com"],"id":"165aa126-a069-4c6f-b6f9-c27f607e35cd"},{"click":{"optIn":"button.css-fuqsbe","presence":"div#qc-cmp2-container"},"cookies":{"optIn":[],"optOut":[{"name":"addtl_consent","value":"1~"}]},"domains":["promotions.hu"],"id":"1991acaa-66fd-4929-8aa8-5d1d223703b9"},{"click":{"optIn":"a.cookies-agree","presence":"div.cookies-notify"},"cookies":{},"domains":["frognews.bg"],"id":"81742e04-b9e3-41e6-a255-0b326f3e28f9"},{"click":{"optIn":"a.info-link-close","presence":"div#privacy-policy-link-wrapper"},"cookies":{"optIn":[{"name":"PRIVACY_POLICY_INFO_2018_OPT_OUT","value":"yes"}]},"domains":["uio.no"],"id":"05ebb139-d68d-44fa-86a4-9b728131490f"},{"click":{"optIn":"button#AcceptCookieLawButton","optOut":"button#RejectCookieLawButton","presence":"div.cookie-banner"},"cookies":{"optIn":[{"name":"BDK_CookieLawAccepted","value":"true"}],"optOut":[{"name":"BDK_CookieLawAccepted","value":"false"}]},"domains":["borger.dk"],"id":"f28b8cb3-c0fc-493c-a8b9-6b147babaf19"},{"click":{"optIn":"a#finansavisen-gdpr-disclaimer-confirm","presence":"div#finansavisen-gdpr-disclaimer"},"cookies":{},"domains":["finansavisen.no"],"id":"1779bdc8-3544-4a2f-ba38-026f6533d665"},{"click":{"optIn":"button#modalConfirmBtn","presence":"div#gravitoCMP-modal-layer1"},"cookies":{},"domains":["verkkouutiset.fi"],"id":"de4a2156-043d-431f-976c-03c2cd94ce2b"},{"click":{"optIn":"a.cc-cookie-accept","presence":"div.cc-cookies"},"cookies":{"optIn":[{"name":"cc_cookie_accept","value":"cc_cookie_accept"}]},"domains":["petel.bg","sagepub.com"],"id":"d4117908-bde7-4950-a41b-188ebd8331ad"},{"click":{"optIn":"button.rounded-button--tertiary","presence":"div.legal-consent"},"cookies":{"optIn":[{"name":"mal_consent_gdpr_remarketing","value":"t"},{"name":"mal_consent_gdpr_personalization","value":"t"}],"optOut":[{"name":"mal_consent_gdpr_remarketing","value":"f"},{"name":"mal_consent_gdpr_personalization","value":"f"}]},"domains":["mall.sk"],"id":"16f5fdfe-81a4-435b-a3d2-5e20d697e1f0"},{"click":{"optIn":"p.cookie-policy-btn","presence":"div.cookie-policy"},"cookies":{"optIn":[{"name":"cookiePolicyConfirmation","value":"true"}]},"domains":["halooglasi.com"],"id":"a5b18ba3-6821-41c7-b9f3-c69352618b72"},{"click":{"optIn":"button#accept-cookies","optOut":"button#decline-cookies","presence":"div#cookie-popup"},"cookies":{},"domains":["ah.nl"],"id":"0793f76e-8e2c-46ec-9aac-111829c4c3ec"},{"click":{"optIn":"button.coi-banner__accept","presence":"div#coi-banner-wrapper"},"cookies":{},"domains":["telia.fi"],"id":"c7991afb-190d-4c47-8080-5e2006a13dfd"},{"click":{"optIn":"button","presence":"div.politic_confidel"},"cookies":{},"domains":["today.ua"],"id":"3c907093-136f-41e1-b0e8-b6613cab8510"},{"click":{"optIn":"button.cookie-alert-extended-button","optOut":"button.cookie-alert-decline-button","presence":"div.cookie-alert-extended-controls"},"cookies":{},"domains":["lidl.sk"],"id":"fd966b51-7e62-402c-8963-70a5bc537605"},{"click":{"optIn":"button#cookie-banner-initial-accept-all","presence":"div.cookie-initial-buttons"},"cookies":{"optIn":[{"name":"SSLB","value":"1"},{"name":"s_cc","value":"true"}],"optOut":[]},"domains":["swedbank.se"],"id":"f3afe889-1fbe-4c24-b62d-ca1bd6c5f636"},{"click":{"optIn":"button[name=accept_cookie]","optOut":"button[name=decline_cookie]","presence":".js-cookie-notification__form"},"cookies":{"optOut":[{"name":"cookie-preferences","value":"eyJmdW5jdGlvbmFsIjp0cnVlLCJhbmFseXRpY2FsIjp0cnVlLCJtYXJrZXRpbmciOmZhbHNlfQ%3D%3D"}]},"domains":["coolblue.nl"],"id":"1bf6fa4e-7882-41cf-b5e1-ef3c91485006"},{"click":{"optIn":"button.fc-button","presence":"div.fc-consent-root"},"cookies":{},"domains":["offnews.bg"],"id":"bd5a5d6d-172e-4386-8698-1c28e83e38e5"},{"click":{"optIn":"button.iubenda-cs-accept-btn","presence":"div#iubenda-cs-banner"},"cookies":{},"domains":["lastampa.it"],"id":"999c2b81-8c59-43d0-b73e-cd76b71a2b7c"}]');
pref("cookiebanners.listService.testSkipRemoteSettings", true);



/// Strip tracking parameters from URLs when shared by default
pref("privacy.query_stripping.strip_on_share.enabled", true); // [DEFAULT - non-Android/Thunderbird]

/// Trim cross-origin referers (Like Safari)
// https://wiki.mozilla.org/Security/Referrer
pref("network.http.referer.XOriginTrimmingPolicy", 2);

pref("browser.phoenix.status", "022");

/*** 023 MISC. SECURITY ***/

/// Always prompt users for a certificate when websites request one, rather than automatically selecting one...
// https://www.stigviewer.com/stig/mozilla_firefox/2023-06-05/finding/V-251547
pref("security.default_personal_cert", "Ask Every Time", locked); // [DEFAULT]

/// Always warn users before launching other apps
pref("network.protocol-handler.warn-external.file", true); // [ANDROID-ONLY]
pref("network.protocol-handler.warn-external.mailto", true); // [NO-MAIL] [DEFAULT - non-Thunderbird] [HIDDEN - THUNDERBIRD]
pref("network.protocol-handler.warn-external.sms", true); // [ANDROID-ONLY]
pref("network.protocol-handler.warn-external.tel", true); // [ANDROID-ONLY]
pref("network.protocol-handler.warn-external.vnd.youtube", true); // [ANDROID-ONLY]
pref("network.protocol-handler.warn-external-default", true); // [DEFAULT]

/// Apply CSP to internal browser.xhtml
pref("security.browser_xhtml_csp.enabled", true); // [DEFAULT]
pref("security.browser_xhtml_csp.report-only", false);


/// Disable Navigator Media Objects & getUserMedia Support in insecure contexts
// https://developer.mozilla.org/docs/Web/API/Navigator/mediaDevices
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
pref("media.devices.insecure.enabled", false); // [DEFAULT]
pref("media.getusermedia.insecure.enabled", false); // [DEFAULT]


/// Do not allow additional ports by default
// This is just to expose the preference via the `about:config`
pref("network.security.ports.banned.override", ""); // [DEFAULT] [HIDDEN]




/// Enable the Cross-Origin-Embedder Policy Header
// https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers/Cross-Origin-Embedder-Policy
pref("browser.tabs.remote.coep.credentialless", true); // [DEFAULT - non-Android stable] 'credentialless' 
pref("browser.tabs.remote.useCrossOriginEmbedderPolicy", true); // [DEFAULT]
pref("dom.origin-trials.coep-credentialless.state", 1); // 'credentialless' 

/// Enable the Cross-Origin-Opener Policy Header
// https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers/Cross-Origin-Opener-Policy
pref("browser.tabs.remote.useCrossOriginOpenerPolicy", true); // [DEFAULT]

/// Enable Element.setHTML
// https://bugzilla.mozilla.org/show_bug.cgi?id=1805632
// https://webdocs.dev/en-us/docs/web/api/element/sethtml
pref("dom.security.setHTML.enabled", true);

/// Enable GPU Sandboxing
// https://www.ghacks.net/2023/01/17/firefox-110-will-launch-with-gpu-sandboxing-on-windows/
// https://searchfox.org/mozilla-central/source/security/sandbox/win/src/sandboxbroker/sandboxBroker.cpp#1181
// https://searchfox.org/mozilla-central/source/security/sandbox/chromium/sandbox/win/src/security_level.h#38
pref("security.sandbox.gpu.level", 2); // [1 = USER_RESTRICTED_NON_ADMIN (Default - Windows), 2 = USER_LIMITED (Stricter)]

/// Enable Opaque Response Blocking
// https://github.com/annevk/orb
pref("browser.opaqueResponseBlocking", true); // [DEFAULT - non-Android]
pref("browser.opaqueResponseBlocking.javascriptValidator", true); // [DEFAULT]

/// Enable Origin-keyed agent clustering by default (Like Chromium)
// https://chromeenterprise.google/policies/#OriginAgentClusterDefaultEnabled
// https://developer.chrome.com/blog/immutable-document-domain/
pref("dom.origin_agent_cluster.default", true);
pref("dom.origin_agent_cluster.enabled", true); // [DEFAULT]

/// Enforce Per-site Process Isolation + isolate all websites
// https://wiki.mozilla.org/Project_Fission
pref("browser.sessionstore.disable_platform_collection", false); // [DEFAULT - non-Thunderbird]
pref("dom.ipc.processCount.webIsolated", 1); // [DEFAULT - Android] Use one isolated content process per origin https://searchfox.org/mozilla-central/source/dom/docs/ipc/process_model.rst
pref("fission.autostart", true); // [DEFAULT - non-Android]
pref("fission.autostart.session", true); // [DEFAULT - non-Android]
pref("fission.disableSessionHistoryInParent", false); // [DEFAULT - non-Android] SHIP, required for Fission
pref("fission.webContentIsolationStrategy", 1); // [DEFAULT - non-Android] Isolate everything https://searchfox.org/mozilla-central/source/dom/ipc/ProcessIsolation.cpp
pref("gfx.webrender.all", true);

/// Enable the Sanitizer API
// https://github.com/WICG/sanitizer-api
pref("dom.security.sanitizer.enabled", true);


/// Enable socket process sandboxing
// https://bugzilla.mozilla.org/show_bug.cgi?id=1608558
pref("security.sandbox.socket.process.level", 1); // [DEFAULT - Linux, non-Thunderbird]

/// Enable Spectre mitigations for isolated content
// Also enabled by ex. Tor Browser
pref("javascript.options.spectre.disable_for_isolated_content", false);

/// Enforce strict file:// Origin Policy
// https://stuffandnonsense.co.uk/blog/firefoxs_file_uri_origin_policy_and_web_fonts
// https://stackoverflow.com/questions/2856502/css-font-face-not-working-with-firefox-but-working-with-chrome-and-ie
pref("security.fileuri.strict_origin_policy", true); // [DEFAULT]

/// Enforce various important security-related prefs
pref("dom.block_external_protocol_in_iframes", true); // [DEFAULT]
pref("dom.block_external_protocol_navigation_from_sandbox", true); // [DEFAULT]
pref("security.all_resource_uri_content_accessible", false); // [DEFAULT]
pref("security.allow_eval_in_parent_process", false); //[DEFAULT - non-Android/Thunderbird]
pref("security.allow_eval_with_system_principal", false); // [DEFAULT - non-Android]
pref("security.allow_parent_unrestricted_js_loads", false); // [DEFAULT - non-Android/Thunderbird]
pref("security.allow_unsafe_parent_loads", false); // [DEFAULT]
pref("security.data_uri.block_toplevel_data_uri_navigations", true); // [DEFAULT]

/// Ensure we block old/obsolete libavcodec libraries
// https://searchfox.org/mozilla-central/source/testing/profiles/unittest-required/user.js
pref("media.libavcodec.allow-obsolete", false); // [DEFAULT]

/// Never expose shell access
// https://www.stigviewer.com/stig/mozilla_firefox/2019-12-12/finding/V-15771
pref("network.protocol-handler.external.shell", false, locked); // [DEFAULT]

/// Never skip the assertion that about:pages don't have content security policies (CSP)
// This is default on Standard Firefox releases, but not on ex. Thunderbird & other builds
pref("dom.security.skip_about_page_has_csp_assert", false); // [DEFAULT - non-Thunderbird]

/// Prevent marking JIT code pages as both writable and executable, only one or the other...
// Might cause issues in certain specific set-ups
// https://bugzilla.mozilla.org/show_bug.cgi?id=1876632
pref("javascript.options.content_process_write_protect_code", true); // [DEFAULT - OpenBSD?]

/// Prevent AutoConfig files (if being used) from gaining privileged browser access...
// https://www.mozilla.org/firefox/62.0/releasenotes/
// https://searchfox.org/mozilla-central/source/extensions/pref/autoconfig/src/nsReadConfig.cpp
pref("general.config.sandbox_enabled", true, locked); // [HIDDEN] [DEFAULT]

/// Prevent remoteTypes from triggering process switches they shouldn't be able to...
// https://searchfox.org/mozilla-central/source/browser/app/profile/firefox.js#1035
pref("browser.tabs.remote.enforceRemoteTypeRestrictions", true); // [DEFAULT - Nightly Desktop]

/// Protect against CSRF Attacks (Like Chromium)
// https://groups.google.com/a/mozilla.org/g/dev-platform/c/6PZtLH7c6JQ
// https://hacks.mozilla.org/2020/08/changes-to-samesite-cookie-behavior/
// https://web.dev/articles/samesite-cookies-explained
// https://help.salesforce.com/s/articleView?id=000389944&type=1
// https://portswigger.net/web-security/csrf/bypassing-samesite-restrictions
// https://web.dev/articles/schemeful-samesite
pref("network.cookie.sameSite.laxByDefault", true);
pref("network.cookie.sameSite.noneRequiresSecure", true); // [DEFAULT]
pref("network.cookie.sameSite.schemeful", true); // [DEFAULT - Nightly]

/// Protect against MIME Exploits
// https://www.pcmag.com/encyclopedia/term/mime-exploit
pref("dom.workers.importScripts.enforceStrictMimeType", true); // [DEFAULT]
pref("security.block_fileuri_script_with_wrong_mime", true);
pref("security.block_Worker_with_wrong_mime", true); // [DEFAULT]

/// Use a separate content process for `file://` URLs
pref("browser.tabs.remote.separateFileUriProcess", true); // [DEFAULT - non-Android]


/// Yes, this is a real pref... 
// https://searchfox.org/mozilla-central/source/testing/profiles/common/user.js
pref("security.turn_off_all_security_so_that_viruses_can_take_over_this_computer", false, locked); // [HIDDEN] [DEFAULT]

pref("browser.phoenix.status", "023");

/*** 024 MISC. ***/

/// Block pop-ups by default
pref("dom.disable_open_during_load", true); // [DEFAULT - non-Thunderbird]


/// Disable Captive Portal Detection & Connectivity Checks
// Privacy & security concerns, and in general best handled by the OS.
// https://support.mozilla.org/kb/how-stop-firefox-making-automatic-connections#w_network-detection
// https://www.eff.org/deeplinks/2017/08/how-captive-portals-interfere-wireless-security-and-privacy
pref("captivedetect.canonicalURL", "");
pref("network.captive-portal-service.enabled", false); // [DEFAULT - Android/Thunderbird]
pref("network.connectivity-service.DNSv4.domain", "");
pref("network.connectivity-service.DNSv6.domain", "");
pref("network.connectivity-service.enabled", false);
pref("network.connectivity-service.IPv4.url", "");
pref("network.connectivity-service.IPv6.url", "");


/// Disable network connectivity status monitoring
// (Ex. used for automatically switching between offline & online mode)
// https://bugzilla.mozilla.org/show_bug.cgi?id=620472
pref("network.manage-offline-status", false);
pref("network.offline-mirrors-connectivity", false); // [DEFAULT]


/// Disable WebVTT Testing Events
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml
pref("media.webvtt.testing.events", false); // [DEFAULT]

/// Enable Firefox's newer 'Felt privacy' design for Certificate Errors
pref("security.certerrors.felt-privacy-v1", true); // [HIDDEN - Android/Thunderbird]


/// Enable the Remote Settings Firefox Relay Allowlist Collection by default to expose via the `about:config`
// https://searchfox.org/mozilla-central/source/toolkit/components/satchel/integrations/FirefoxRelay.sys.mjs
// https://firefox.settings.services.mozilla.com/v1/buckets/main/collections/fxrelay-allowlist/changeset?_expected=0
pref("signon.firefoxRelay.allowListRemoteSettingsCollection", "fxrelay-allowlist"); // [DEFAULT] [HIDDEN]

/// Enable more detailed property error messages
pref("javascript.options.property_error_message_fix", true); // [DEFAULT - Nightly/Dev]


/// Force pop-up windows to open in new tabs instead
pref("browser.link.open_newwindow", 3); // [DEFAULT]
pref("browser.link.open_newwindow.restriction", 0); // [DEFAULT - Android/Thunderbird]

/// Limit what events can cause pop-ups
pref("dom.popup_allowed_events", "click dblclick");



/// Prevent scripts from moving, resizing, and messing with windows
pref("dom.allow_scripts_to_close_windows", false); // [DEFAULT]
pref("dom.disable_window_flip", true); // [DEFAULT - non-Android]
pref("dom.disable_window_move_resize", true); // [DEFAULT - Android]

/// Prevent websites from automatically refreshing
pref("browser.meta_refresh_when_inactive.disabled", true); // [DEFAULT - Android]



/// Show an error page/details instead of a blank page for HTTP responses with certain error codes (ex. 4xx, 5xx, & Content-Length: 0)
// ex. https://ozuma.sakura.ne.jp/httpstatus/400
pref("browser.http.blank_page_with_error_response.enabled", false); // [DEFAULT - non-Android]

pref("browser.phoenix.status", "024");

/*** 025 DEBUGGING ***/

/// Allow inspecting the browser chrome by default
pref("devtools.chrome.enabled", true); // [DEFAULT - Thunderbird]


/// Always prompt before connecting to Remote Debugging...
pref("devtools.debugger.prompt-connection", true, locked); // [DEFAULT - non-Nightly]




/// Disable Remote Debugging + only allow enabling it per-session
// https://firefox-source-docs.mozilla.org/devtools/backend/protocol.html
pref("devtools.debugger.remote-enabled", false, sticky); // [DEFAULT - non-Thunderbird]

/// Disable the Remote Debugging Web Socket
pref("devtools.debugger.remote-websocket", false, locked); // [DEFAULT]

/// Disable sending console output to logcat by default [ANDROID-ONLY]
// https://bugzilla.mozilla.org/show_bug.cgi?id=1415318 [ANDROID-ONLY]
pref("consoleservice.logcat", false); // [ANDROID-ONLY]
pref("geckoview.console.enabled", false); // [ANDROID-ONLY]


// https://searchfox.org/mozilla-central/rev/f1e32fa7/browser/app/profile/firefox.js#3057

/// Disable WebDriver BiDi experimental commands and events
// https://wiki.mozilla.org/WebDriver/RemoteProtocol/WebDriver_BiDi
pref("remote.experimental.enabled", false, locked); // [DEFAULT - non-Nightly]





/// Enforce local debugging only
pref("devtools.debugger.force-local", true, locked); // [DEFAULT]

/// Highlight syntax when viewing the source of webpages (via `view-source:`)
pref("view_source.syntax_highlight", true); // [DEFAULT - non-Thunderbird]

/// Limit GeckoView's log level to "Warn" by default [ANDROID-ONLY]
pref("geckoview.logging", "Warn"); // [ANDROID-ONLY] [DEFAULT - non-Debug]


/// Prevent adding global `dump` function to log strings to `stdout`
// https://searchfox.org/mozilla-central/source/devtools/docs/contributor/getting-started/development-profiles.md
pref("browser.dom.window.dump.enabled", false); // [DEFAULT - non-Android, desktop `MOZILLA_OFFICIAL` builds]


/// Prevent console API from writing to `stdout` when used by chrome content
pref("devtools.console.stdout.chrome", false); // [DEFAULT - non-Android, `MOZILLA_OFFICIAL` builds]

/// Prevent logging URLs in Reader errors
pref("reader.errors.includeURLs", false); // [DEFAULT - Android/Thunderbird]





/// Wrap lines when viewing the source of webpages (via `view-source:`)
pref("view_source.wrap_long_lines", true); // [DEFAULT - Android]

pref("browser.phoenix.status", "025");

/*** 026 PERFORMANCE ***/

// A lot of these taken from https://github.com/yokoffing/Betterfox/blob/main/Fastfox.js

/// Compress cached JavaScript bytecode
// https://github.com/yokoffing/Betterfox/issues/247
// https://searchfox.org/mozilla-central/rev/f1e32fa7/dom/script/ScriptCompression.cpp#100
// (Default = 0, which means it's off)
pref("browser.cache.jsbc_compression_level", 3);

/// Decrease the content notification interval
// https://bugzilla.mozilla.org/show_bug.cgi?id=72138
// https://searchfox.org/mozilla-central/rev/c1180ea13e73eb985a49b15c0d90e977a1aa919c/modules/libpref/init/StaticPrefList.yaml#1824-1834
// (Default = 120000 (.12 secs))
pref("content.notify.interval", 100000); // .10 secs


/// Disable CSS error reporting by default
// https://bugzilla.mozilla.org/show_bug.cgi?id=831123
pref("layout.css.report_errors", false); // [DEFAULT - Android]

/// Disable extra extension logging by default
// https://searchfox.org/mozilla-central/rev/f1e32fa7/browser/app/profile/firefox.js#29
pref("extensions.logging.enabled", false); // [DEFAULT]

/// Disable pacing requests
// https://codeberg.org/celenity/Phoenix/issues/84
pref("network.http.pacing.requests.enabled", false);



/// Enable Advanced Vector Extensions (AVX)
// https://wikipedia.org/wiki/Advanced_Vector_Extensions
// https://www.supportyourtech.com/articles/how-to-enable-avx-support-in-windows-11-a-step-by-step-guide/
pref("javascript.options.wasm_simd_avx", true);

/// Enable Branch Hinting
// https://github.com/WebAssembly/branch-hinting/blob/main/proposals/branch-hinting/Overview.md
pref("javascript.options.wasm_branch_hinting", true); // [DEFAULT - Nightly]

/// Enable Canvas2D acceleration (if supported)
// `gfx.canvas.accelerated.force-enabled` can be used to forcefully enable this acceleration, regardless of platform support
pref("gfx.canvas.accelerated", true); // [DEFAULT]
pref("gfx.canvas.accelerated.cache-items", 8192); // [DEFAULT]
pref("gfx.canvas.accelerated.cache-size", 512); // Increase cache size (Default = 256)

/// Enable CSS Masonry Layout
// https://www.smashingmagazine.com/native-css-masonry-layout-css-grid/ - for testing: https://codepen.io/rachelandrew/pen/wvWmZWB 
pref("layout.css.grid-template-masonry-value.enabled", true); // [DEFAULT - Nightly/Thunderbird] 

/// Enable the "fetchpriority" attribute
// https://web.dev/articles/fetch-priority
pref("network.fetchpriority.enabled", true); // [DEFAULT - non-ESR]

/// Enable JS GC Parallel Marking
pref("javascript.options.mem.gc_parallel_marking", true); // [DEFAULT - non-Android]

/// Enable SIMD
// https://stackoverflow.blog/2020/07/08/improving-performance-with-simd-intrinsics-in-three-use-cases/
pref("javascript.options.wasm_relaxed_simd", true); // [DEFAULT - Nightly]


/// Enable the WebRender native compositor (if supported)
// `gfx.webrender.compositor.force-enabled` can be used to forcefully enable this acceleration, regardless of platform support
pref("gfx.webrender.compositor", true); // [DEFAULT - macOS/Windows]


/// Increase buffering for video playback
// This doesn't apply to videos delivered via Media Source Extensions
// https://www.cloudflare.com/learning/video/what-is-buffering/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1540573
// https://searchfox.org/mozilla-central/rev/f1e32fa7/dom/media/ChannelMediaDecoder.cpp#473
pref("media.cache_readahead_limit", 7200); // (Default = 60)
pref("media.cache_readahead_limit.cellular", 7200); // (Default = 30)
pref("media.cache_resume_threshold", 3600); // (Default = 30)
pref("media.cache_resume_threshold.cellular", 3600); // (Default = 10)
pref("media.throttle-cellular-regardless-of-download-rate", false); // [HIDDEN - non-Android] [DEFAULT - non-Android]

/// Increase the chunk size for calls to image decoders
// (Default = 16384)
pref("image.mem.decode_bytes_at_a_time", 32768);

/// Increase DNS caching
pref("network.dnsCacheExpiration", 3600); // (Default = 60)
pref("network.dnsCacheExpirationGracePeriod", 240); // (Default = 60)
pref("network.dnsCacheEntries", 1000); // (Default = 800)

/// Increase the file-backed media cache size for cellular connections
// (Default = 32768)
// This is set to match the value of "media.cache_size"
pref("media.cache_size.cellular", 512000);

/// Increase the memory-backed media cache size
// (Default = 8192)
pref("media.memory_cache_max_size", 65536);

/// Increase the skia font cache size (Like Chromium)
// https://bugzilla.mozilla.org/show_bug.cgi?id=1239151#c2
// (Default = 5)
pref("gfx.content.skia-font-cache-size", 20);

/// Increase the maximum number of HTTP connections
pref("network.http.max-connections", 1800); // (Default = 128 for Android, 900 elsewhere)
pref("network.http.max-persistent-connections-per-proxy", 48); // (Default = 20 for Android, 32 elsewhere)
pref("network.http.max-persistent-connections-per-server", 10); // (Default = 6)
pref("network.http.max-urgent-start-excessive-connections-per-host", 5); // (Default = 3)

/// Increase TLS token caching
// https://codeberg.org/celenity/Phoenix/issues/84
// https://searchfox.org/mozilla-central/source/netwerk/base/SSLTokensCache.cpp
// (Default = 2048)
pref("network.ssl_tokens_cache_capacity", 10240);

/// Use higher performance pinch-zoom
// https://searchfox.org/mozilla-central/rev/20fc11f1/modules/libpref/init/StaticPrefList.yaml#7820
pref("gfx.webrender.low-quality-pinch-zoom", true); // [DEFAULT - Android Nightly]

pref("browser.phoenix.status", "026");

/*** 027 Personal Touch 💜 ***/

/// Things that are nice to have™
// Not directly privacy & security related




/// Allow Picture-in-Picture on all websites, even if they try to block it...
pref("media.videocontrols.picture-in-picture.respect-disablePictureInPicture", false);

/// Allow zoom by default...
pref("apz.allow_zooming", true); // [DEFAULT]

/// Allow zoom on all websites, even if they try to block it...
// (This is the `Zoom on all websites` UI setting for Android)
pref("browser.ui.zoom.force-user-scalable", true);

/// Allow zooming out beyond the initial scale of websites by default
// https://searchfox.org/mozilla-central/rev/3b58bde3/gfx/layers/apz/src/AsyncPanZoomController.cpp#157
pref("apz.allow_zooming_out", true);






/// Disable annoying Web Speech API errors, especially relevant on Linux
// https://searchfox.org/mozilla-central/source/browser/actors/SpeechDispatcherParent.sys.mjs#8
pref("media.webspeech.synth.dont_notify_on_error", true); // [HIDDEN]


/// Disable fullscreen delay + warning
pref("full-screen-api.transition-duration.enter", "0 0"); // [Default = 200 200]
pref("full-screen-api.transition-duration.leave", "0 0"); // [Default = 200 200]
pref("full-screen-api.warning.delay", -1); // [Default = 500, -1 = Automatic]
pref("full-screen-api.warning.timeout", 0); // [Default = 3000]




/// Enable autoscrolling by default
pref("apz.autoscroll.enabled", true); // [DEFAULT]
pref("general.autoScroll", true); // [HIDDEN - Android] [DEFAULT - non-Android/Unix (excluding macOS, where it is on by default)]



/// Enable developer options for `about:profiling`
pref("devtools.performance.aboutprofiling.has-developer-options", true);


/// Enable Firefox Translations (+ the pop-up) by default [NO-MAIL]
// Translations are done locally - very nice to have [NO-MAIL]
// https://support.mozilla.org/kb/website-translation [NO-MAIL]
// Currently broken on Thunderbird :( [NO-MAIL]
pref("browser.translations.automaticallyPopup", true); // [NO-MAIL] [DEFAULT]
pref("browser.translations.enable", true); // [NO-MAIL] [DEFAULT - non-Thunderbird]
pref("browser.translations.select.enable", true); // [NO-MAIL] [DEFAULT - non-Android/Thunderbird]

/// Enable IPv6
// Important, nice to have
pref("network.dns.disableIPv6", false); // [DEFAULT]

/// Enable overscrolling by default
// https://www.omgubuntu.co.uk/2024/09/mozilla-firefox-130-new-features
pref("apz.overscroll.enabled", true); // [DEFAULT]

/// Enable smooth scrolling by default
// This currently appears to be overriden by `ui.prefersReducedMotion` on Desktop
pref("general.smoothScroll", true); // [DEFAULT]


/// Enable support for web applications manifests [NO-MAIL]
// Ex. required for PWAs (& PWA inspection on desktop) [NO-MAIL]
// https://developer.mozilla.org/docs/Web/Progressive_web_apps/Manifest [NO-MAIL]
// https://bugzilla.mozilla.org/show_bug.cgi?id=1603673 [NO-MAIL]
// https://bugzilla.mozilla.org/show_bug.cgi?id=1647858 [NO-MAIL]
pref("dom.manifest.enabled", true); // [NO-MAIL] [DEFAULT]







/// Ensure users can always control Nimbus recipes
// https://searchfox.org/mozilla-central/rev/20fc11f1/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs#344
// https://searchfox.org/mozilla-central/rev/20fc11f1/toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs#513
pref("nimbus.debug", true); // [HIDDEN - non-Firefox Desktop]
pref("nimbus.validation.enabled", false); // [HIDDEN - non-Firefox Desktop]



/// Hide the Title Bar by default
pref("browser.tabs.inTitlebar", 1);

/// Highlight all Findbar (Ctrl + F) results by default
pref("findbar.highlightAll", true);


/// Prevent the alt key from toggling menu bar by default
pref("ui.key.menuAccessKeyFocuses", false); // [DEFAULT - non-Windows/Linux]


/// Prevent including the space next to words when double-clicking/selecting text
// https://codeberg.org/celenity/Phoenix/issues/84#issuecomment-3097957
pref("layout.word_select.eat_space_to_next_word", false); // [DEFAULT - non-Windows]


/// Set the default log level for Background Tasks
// This is the default value - this just exposes the pref via the `about:config`
// https://searchfox.org/mozilla-central/source/toolkit/components/backgroundtasks/BackgroundTasksManager.sys.mjs
pref("toolkit.backgroundtasks.loglevel", "error"); // [DEFAULT] [HIDDEN]

/// Set the default log level for Remote Settings
// This is the default value - this just exposes the pref via the `about:config`
pref("services.settings.loglevel", "warn"); // [DEFAULT] [HIDDEN]

/// Set default URL to load when navigating to `moz://a`
// Default is https://www.mozilla.org/about/manifesto/
// https://searchfox.org/mozilla-central/source/toolkit/components/mozprotocol/MozProtocolHandler.sys.mjs
pref("toolkit.mozprotocol.url", "about:mozilla"); // [HIDDEN]


pref("browser.phoenix.status", "027");

/*** 028 UPDATES ***/



/// Automatically update extensions by default
// https://searchfox.org/mozilla-central/source/toolkit/mozapps/extensions/AddonManager.sys.mjs
pref("extensions.systemAddon.update.enabled", true); // [DEFAULT]
pref("extensions.systemAddon.update.url", "https://aus5.mozilla.org/update/3/SystemAddons/%VERSION%/%BUILD_ID%/%BUILD_TARGET%/%LOCALE%/%CHANNEL%/%OS_VERSION%/%DISTRIBUTION%/%DISTRIBUTION_VERSION%/update.xml"); // [HIDDEN - Thunderbird] [DEFAULT - non-Thunderbird]
pref("extensions.update.autoUpdateDefault", true); // [HIDDEN - ANDROID] [DEFAULT]
pref("extensions.update.enabled", true); // [DEFAULT]
pref("media.gmp-manager.updateEnabled", true); // [HIDDEN] [DEFAULT]


/// Check for extension/theme updates hourly
// Default is once every 24 hours
pref("extensions.update.interval", 3600);

/// Disable insecure extension updates
// https://searchfox.org/mozilla-central/source/toolkit/mozapps/extensions/AddonManager.sys.mjs
pref("extensions.checkUpdateSecurity", true); // [HIDDEN] [DEFAULT]

/// Notify users for extension updates by default
// https://searchfox.org/mozilla-central/source/remote/shared/RecommendedPreferences.sys.mjs#253
pref("extensions.update.notifyUser", true); // [HIDDEN]

/// Sync with Remote Settings hourly, rather than the default of only once a day
// This is used for delivering lots of security-critical databases (Ex. CRLite/revocation checks, malicious add-on blocklists, etc...)
// So let's make sure our users are up to date as quick as possible
pref("services.settings.poll_interval", 3600);

pref("browser.phoenix.status", "028");









pref("browser.phoenix.status", "successfully applied :D", locked);
