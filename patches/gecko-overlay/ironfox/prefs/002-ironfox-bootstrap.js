// IronFox bootstrap...
/// Preferences are configured at `ironfox.cfg` (located at `build/gecko/ironfox.cfg` within the IronFox source repo)

/// Set-up AutoConfig
// https://support.mozilla.org/kb/customizing-firefox-using-autoconfig
pref("general.config.sandbox_enabled", true, locked); // Ensure AutoConfig is sandboxed
pref("autoadmin.global_config_url", "", locked); // Ensure we do not allow remote configuration
pref("general.config.filename", "ironfox.cfg", locked);
pref("general.config.obscure_value", 0, locked);
pref("general.config.vendor", "ironfox", locked);

pref("browser.ironfox.applied.prefs", true, locked);
