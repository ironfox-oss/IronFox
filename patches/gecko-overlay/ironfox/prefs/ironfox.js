// IronFox Gecko preferences...

/// Actual preferences are set at `ironfox.cfg` (located at `patches/build/gecko/ironfox.cfg` within the IronFox source repo)
// This is just a "bootstrap" of sorts...

/// Set constants
// (These are set as prefs for use by ironfox.cfg)
// (The values should match Gecko's IFConstants.sys.mjs)
pref("browser.ironfox.const.IRONFOX_APP_NAME",                  "@IRONFOX_APP_NAME@", locked);
pref("browser.ironfox.const.IRONFOX_APP_NAME_PRETTY",           "@IRONFOX_APP_NAME_PRETTY@", locked);
pref("browser.ironfox.const.IRONFOX_BUGS_URL",                  "@IRONFOX_BUGS_URL@", locked);
pref("browser.ironfox.const.IRONFOX_CHANNEL",                   "@IRONFOX_CHANNEL@", locked);
pref("browser.ironfox.const.IRONFOX_DEFAULT_DOH_URL",           "@IRONFOX_DEFAULT_DOH_URL@", locked);
pref("browser.ironfox.const.IRONFOX_DEFAULT_UBO_ASSETS_URL",    "@IRONFOX_DEFAULT_UBO_ASSETS_URL@", locked);
pref("browser.ironfox.const.IRONFOX_FAQ_URL",                   "@IRONFOX_FAQ_URL@", locked);
pref("browser.ironfox.const.IRONFOX_RELEASES_URL",              "@IRONFOX_RELEASES_URL@", locked);
pref("browser.ironfox.const.IRONFOX_REPO_GIT_URL",              "@IRONFOX_REPO_GIT_URL@", locked);
pref("browser.ironfox.const.IRONFOX_REPO_URL",                  "@IRONFOX_REPO_URL@", locked);
pref("browser.ironfox.const.IRONFOX_URL",                       "@IRONFOX_URL@", locked);
pref("browser.ironfox.const.IRONFOX_VERSION",                   "@IRONFOX_VERSION@", locked);

#ifdef IRONFOX_RELEASE
  pref("browser.ironfox.const.IRONFOX_RELEASE", true, locked);
#else
  pref("browser.ironfox.const.IRONFOX_RELEASE", false, locked);
#endif

#ifdef IRONFOX_NIGHTLY
  pref("browser.ironfox.const.IRONFOX_NIGHTLY", true, locked);
#else
  pref("browser.ironfox.const.IRONFOX_NIGHTLY", false, locked);
#endif

/// Set-up AutoConfig
// https://support.mozilla.org/kb/customizing-firefox-using-autoconfig
pref("general.config.sandbox_enabled", true, locked); // Ensure AutoConfig is sandboxed
pref("autoadmin.global_config_url", "", locked); // Ensure we do not allow remote configuration
pref("general.config.filename", "ironfox.cfg", locked);
pref("general.config.obscure_value", 0, locked);
pref("general.config.vendor", "ironfox", locked);

pref("browser.ironfox.applied.prefs", true, locked);
