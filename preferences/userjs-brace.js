//Look
pref("browser.ctrlTab.recentlyUsedOrder", false);
pref("browser.privatebrowsing.vpnpromourl", "");
pref("browser.vpn_promo.enabled", false);
pref("browser.tabs.drawInTitlebar", true);
pref("devtools.netmonitor.persistlog", true);
pref("devtools.webconsole.persistlog", true);
pref("general.smoothScroll", false);
pref("widget.allow-client-side-decoration", true);
pref("mailnews.start_page.enabled", false);
pref("browser.newtabpage.activity-stream.asrouter.providers.snippets", "{}"); //BRACE-KEEP_FOR_NOW
pref("browser.library.activity-stream.enabled", false); //BRACE-UNCOMMENTED

//Privacy
pref("privacy.globalprivacycontrol.enabled", true);
pref("browser.snippets.enabled", false);
pref("browser.snippets.firstrunHomepage.enabled", false);
pref("browser.snippets.syncPromo.enabled", false);
pref("browser.snippets.updateUrl", "");
pref("general.useragent.updates.enabled", false);
pref("network.negotiate-auth.trusted-uris", "");
pref("network.dns.native_https_query", true);
pref("network.trr.uri", "https://dns.quad9.net/dns-query");
pref("network.trr.custom_uri", "https://dns.quad9.net/dns-query");
pref("plugin.expose_full_path", false);
pref("extensions.enigmail.autoWkdLookup", 0);
pref("messenger.status.reportIdle", false);
pref("media.gmp-widevinecdm.visible", false); //BRACE-KEEP_FOR_NOW: proprietary
pref("network.manage-offline-status", false);
pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
pref("browser.urlbar.quicksuggest.dataCollection.enabled", false);
pref("mailnews.headers.sendUserAgent", false);
pref("mail.sanitize_date_header", true);
pref("dom.private-attribution.submission.enabled", false);

//Security
pref("browser.gnome-search-provider.enabled", false);
//pref("fission.autostart", true); //MULL-COMMENTED
//pref("security.webauth.u2f", true); //MULL-COMMENTED
pref("security.tls.enable_kyber", true);
pref("network.http.http3.enable_kyber", true);
pref("mail.phishing.detection.enabled", true);
pref("mailnews.message_display.disable_remote_image", true);

//Disable Pocket
pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
pref("extensions.pocket.enabled", false);

//Disable Sync
pref("identity.fxaccounts.enabled", false);
