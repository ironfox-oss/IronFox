import os
from pathlib import Path
from typing import List
from commands.prepare import PrepareConfig
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition

from execution.find_replace import comment_out, line_affix, literal, regex
from execution.types import ReplacementAction


def prepare_firefox(
    d: BuildDefinition,
    paths: Paths,
    config: PrepareConfig,
) -> List[TaskDefinition]:

    global _process_file

    def _process_file(
        path: str,
        replacements: List[ReplacementAction],
    ) -> List[TaskDefinition]:
        return d.find_replace(
            name=f"Process {path}",
            target_file=paths.firefox_dir / path,
            replacements=replacements,
        )

    def _rm(
        path: str,
        recursive: bool = False,
    ) -> List[TaskDefinition]:
        return d.delete(
            name=f"Delete {path}", path=paths.firefox_dir / path, recursive=recursive
        )

    def _mkdirs(
        path: str,
        parents: bool = True,
        exist_ok: bool = True,
    ) -> TaskDefinition:
        return d.mkdir(
            name=f"Create directory {path}",
            target=paths.firefox_dir / path,
            parents=parents,
            exist_ok=exist_ok,
        )

    rust_version = (
        regex(
            r"rust-version = .*",
            f'rust-version = "{Versions.RUST_MAJOR_VERSION}"',
        ),
    )

    return [
        # fmt:off
        
        _mkdirs(f"{paths.android_home}/emulator"),
        _mkdirs(f"{paths.user_home}/.mozbuild/android-device/avd"),
        
        _mkdirs("mobile/android/branding/ironfox/content"),
        _mkdirs("mobile/android/branding/ironfox/locales/en-US"),
        _mkdirs("mobile/locales/en-US/browser/policies"),
        
        # Remove unused telemetry assets
        *_rm("toolkit/content/aboutTelemetry.css"),
        *_rm("toolkit/content/aboutTelemetry.js"),
        *_rm("toolkit/content/aboutTelemetry.xhtml"),
        
        # Remove DoH rollout local dumps
        *_rm("services/settings/static-dumps/main/doh-config.json"),
        *_rm("services/settings/static-dumps/main/doh-providers.json"),
        
        d.write_file(
            name="Write local.properties",
            target=paths.firefox_dir / "local.properties",
            contents=lambda: f'''

mozilla-central.mozconfig={paths.firefox_dir}/mozconfig
            '''.encode(),
            append=True,
        ),
        
        *_process_file(
            path="mobile/android/moz.configure",
            replacements=[
                regex(r'("MOZ_APP_VENDOR",\s*").*(")', r'\1%s\2'.format(config.app_config.vendor)),
                regex(r'("MOZ_NORMANDY",\s*).*(\))', r'\1False\2'),
                regex(r'("MOZ_SERVICES_HEALTHREPORT",\s*).*(\))', r'\1False\2'),
                regex(r'("MOZ_APP_UA_NAME",\s*").*(")', r'\1Firefox\2'),
            ],
        ),
        
        # Append include("ironfox.configure") and a blank line to moz.configure
        d.write_file(
            name="Include ironfox.configure in moz.configure",
            target=paths.firefox_dir / "mobile/android/moz.configure",
            contents=lambda: b'\ninclude("ironfox.configure")',
            append=True,
        ),
        
        # Replace product names in build/moz.configure/init.configure
        *_process_file(
            path="build/moz.configure/init.configure",
            replacements=[
                literal("Fennec", config.app_config.app_name),
                literal("Firefox", config.app_config.app_name),
            ]
        ),
        
        # Insert about pages entries adjacent to the aboutAbout entry
        *_process_file(
            path="docshell/base/nsAboutRedirector.cpp",
            replacements=[
                regex(
                    r"(\{\"about\", \"chrome:\/\/global\/content\/aboutAbout.html\", 0\},)",
                    r"\1\n {\"ironfox\", \"chrome:\/\/global\/content\/ironfox.html\",\n nsIAboutModule::URI_SAFE_FOR_UNTRUSTED_CONTENT},",
                ),
                regex(
                    r"(\{\"about\", \"chrome:\/\/global\/content\/aboutAbout.html\", 0\},)",
                    r"\1\n {\"attribution\", \"chrome:\/\/global\/content\/attribution.html\",\n nsIAboutModule::URI_SAFE_FOR_UNTRUSTED_CONTENT},",
                ),
            ],
        ),
        *_process_file(
            path="docshell/build/components.conf",
            replacements=[
                regex(r"(about_pages.append\('inference'\))", r"\1\n about_pages.append('ironfox')"),
                regex(r"(about_pages.append\('inference'\))", r"\1\n about_pages.append('attribution')"),
                regex(r"(about_pages.append\('inference'\))", r"\1\n about_pages.append('policies')"),
            ],
        ),
        
        # about:policies
        *_process_file(
            path="browser/components/enterprisepolicies/jar.mn",
            replacements=[
                literal("browser.jar", "geckoview.jar"),
            ]
        ),
        d.copy(
            name="Copy aboutPolicies.ftl",
            source=paths.firefox_dir / "browser/locales/en-US/browser/aboutPolicies.ftl",
            target=paths.firefox_dir / "mobile/locales/en-US/browser/aboutPolicies.ftl",
        ),
        d.copy(
            name="Copy policies-descriptions.ftl",
            source=paths.firefox_dir / "browser/locales/en-US/browser/policies/policies-descriptions.ftl",
            target=paths.firefox_dir / "mobile/locales/en-US/browser/policies/policies-descriptions.ftl",
            overwrite=True,
        ),
        d.write_file(
            name="Update moz.build to include jar.mn in JAR_MANIFESTS",
            target=paths.firefox_dir / "mobile/locales/moz.build",
            contents=lambda: b'\nJAR_MANIFESTS += ["jar.mn"]',
            append=True,
        ),
        d.write_file(
            name="Update GeckoView jar.mn",
            target=paths.firefox_dir / "mobile/shared/chrome/geckoview/jar.mn",
            contents=lambda: b'\n% content browser %content/browser/',
            append=True,
        ),
        
        # Copy policy definitions/schema/etc. from Firefox for Desktop
        d.copy_dir_contents(
            name="Copy policy definitions/schema from Firefox for Desktop",
            source_dir=paths.firefox_dir / "browser/components/enterprisepolicies",
            target_dir=paths.firefox_dir / "mobile/android/components",
            recursive=True,
        ),
        
        # Ensure we're building for release
        *_process_file(
            path="mobile/android/gradle.configure",
            replacements=[
                regex(r'variant=variant(.*)', r'variant=variant("release")')
            ]
        ),
        
        *_process_file(
            path="mobile/android/geckoview/build.gradle",
            replacements=[
                # Fix v125 aar output not including native libraries
                regex(r"singleVariant('debug')", r"singleVariant('release')"),
                
                # Replace Google Play FIDO dependency with microG in geckoview build
                literal(
                    'libs.play.services.fido',
                    '"org.microg.gms:play-services-fido:v0.0.0.250932"'
                ),
            ]
        ),
        
        # Hack the timeout for
        # geckoview:generateJNIWrappersForGeneratedWithGeckoBinariesDebug
        *_process_file(
            path="mobile/android/gradle.py",
            replacements=[
                literal("max_wait_seconds=600", "max_wait_seconds=1800")
            ]
        ),
        
        # Break dependency on older Rust
        *_process_file(
            path="Cargo.toml",
            replacements=[
                *rust_version,
                regex(r'debug-assertions = .*', r'debug-assertions = false')
            ]
        ),
        
        # Break dependency on older Rust
        *_process_file("intl/icu_capi/Cargo.toml", [*rust_version]),
        *_process_file("intl/icu_segmenter_data/Cargo.toml", [*rust_version]),
        
        # Disable debug
        *_process_file(
            path="gfx/harfbuzz/src/rust/Cargo.toml",
            replacements=[
                regex(r'debug = .*', r'debug = false')
            ]
        ),
        
        # Remove the `NETWORK_ACCESS_STATE` permission (GeckoView)
        *_process_file(
            path="mobile/android/geckoview/src/main/AndroidManifest.xml",
            replacements=[
                literal('<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>', "")
            ]
        ),
        
        # Disable SSLKEYLOGGING
        ## https://bugzilla.mozilla.org/show_bug.cgi?id=1183318
        ## https://bugzilla.mozilla.org/show_bug.cgi?id=1915224
        *_process_file(
            path="security/nss/lib/ssl/Makefile",
            replacements=[
                regex(r'NSS_ALLOW_SSLKEYLOGFILE ?= .*', r'NSS_ALLOW_SSLKEYLOGFILE ?= 0'),
            ]
        ),
        d.write_file(
            name="Disable sslkeylogfile",
            target=paths.firefox_dir / "security/moz.build",
            contents=lambda: b'\ngyp_vars["enable_sslkeylogfile"] = 0',
            append=True,
        ),
        
        # Include additional Remote Settings local dumps (+ add our own...)
        *_process_file(
            path="services/settings/dumps/blocklists/moz.build",
            replacements=[
                regex(r'"mobile/"', '"0"')
            ]
        ),
        *_process_file(
            path="services/settings/dumps/security-state/moz.build",
            replacements=[
                regex(r'"mobile/"', '"0"')
            ]
        ),
        d.write_file(
            name="Include additional Remote Settings dumps",
            target=paths.firefox_dir / "services/settings/dumps/main/moz.build",
            append=True,
            contents=lambda: b"""

FINAL_TARGET_FILES.defaults.settings.main += [
    "anti-tracking-url-decoration.json",
    "cookie-banner-rules-list.json",
    "hijack-blocklists.json",
    "translations-models.json",
    "translations-wasm.json",
    "url-classifier-skip-urls.json",
    "url-parser-default-unknown-schemes-interventions.json",
]
            """
        ),
        
        # Disable remote crash collection (no-op RemoteSettings crash pull)
        *_process_file(
            path="toolkit/components/crashes/RemoteSettingsCrashPull.sys.mjs",
            replacements=[
                literal("crash-reports-ondemand", ""),
                regex(r'REMOTE_SETTINGS_CRASH_COLLECTION = ".*"', r'REMOTE_SETTINGS_CRASH_COLLECTION = ""'),
            ],
        ),
        
        # No-op Normandy (Experimentation)
        *_process_file(
            path="toolkit/components/normandy/lib/RecipeRunner.sys.mjs",
            replacements=[
                regex(r'REMOTE_SETTINGS_COLLECTION = ".*"', r'REMOTE_SETTINGS_COLLECTION = ""'),
                literal("normandy-recipes-capabilities", ""),
            ],
        ),
        *_process_file(
            path="build.gradle",
            replacements=[
                line_affix(
                    match_lines='classpath "${ApplicationServicesConfig.groupId}:tooling-nimbus-gradle"',
                    prefix="//"
                )
            ]
        ),

        # No-op Nimbus (Experimentation) — ExperimentAPI
        *_process_file(
            path="toolkit/components/nimbus/ExperimentAPI.sys.mjs",
            replacements=[
                regex(r'COLLECTION_ID_FALLBACK = ".*"', r'COLLECTION_ID_FALLBACK = ""'),
                literal("nimbus-desktop-experiments", ""),
            ],
        ),

        # No-op Nimbus (Experimentation) — RemoteSettingsExperimentLoader
        *_process_file(
            path="toolkit/components/nimbus/lib/RemoteSettingsExperimentLoader.sys.mjs",
            replacements=[
                regex(r'COLLECTION_ID_FALLBACK = ".*"', r'COLLECTION_ID_FALLBACK = ""'),
                regex(r'EXPERIMENTS_COLLECTION = ".*"', r'EXPERIMENTS_COLLECTION = ""'),
                regex(r'SECURE_EXPERIMENTS_COLLECTION_ID = ".*"', r'SECURE_EXPERIMENTS_COLLECTION_ID = ""'),
                literal("nimbus-desktop-experiments", ""),
                literal("nimbus-secure-experiments", ""),
            ],
        ),
        
        # Disable Glean internal pings and uploads
        *_process_file(
            path="toolkit/components/glean/src/init/mod.rs",
            replacements=[
                regex(r'enable_internal_pings:\s*true', r'enable_internal_pings: false'),
                regex(r'upload_enabled\s*=\s*true', r'upload_enabled = false'),
                regex(r'use_core_mps:\s*true', r'use_core_mps: false'),
            ],
        ),

        # Remove localhost references in telemetry pingsender modules
        *_process_file(
            path="toolkit/components/telemetry/pings/BackgroundTask_pingsender.sys.mjs",
            replacements=[
                literal("localhost", ""),
            ],
        ),
        *_process_file(
            path="toolkit/components/telemetry/pingsender/pingsender.cpp",
            replacements=[
                literal("localhost", ""),
            ],
        ),

        # Disable telemetry usage reporting and telemetry core flags
        *_process_file(
            path="toolkit/components/telemetry/app/UsageReporting.sys.mjs",
            replacements=[
                regex(r'usageDeletionRequest\.setEnabled\(.*\)', r'usageDeletionRequest.setEnabled(false)'),
            ],
        ),
        *_process_file(
            path="toolkit/components/telemetry/core/Telemetry.cpp",
            replacements=[
                regex(r'useTelemetry = .*', r'useTelemetry = false;'),
            ],
        ),

        # Append glean_disable_upload to gkrust-features before "# This must remain last."
        *_process_file(
            path="toolkit/library/rust/gkrust-features.mozbuild",
            replacements=[
                line_affix(r'# This must remain last\.', prefix='gkrust_features += ["glean_disable_upload"]\n'),
            ],
        ),

        # Disable client ID and send_if_empty for Glean pings
        *_process_file(
            path="toolkit/components/glean/pings.yaml",
            replacements=[
                regex(r'include_client_id:\s*.*', r'include_client_id: false'),
                regex(r'send_if_empty:\s*.*', r'send_if_empty: false'),
            ],
        ),

        # Disable client ID and send_if_empty for Nimbus pings
        *_process_file(
            path="toolkit/components/nimbus/pings.yaml",
            replacements=[
                regex(r'include_client_id:\s*.*', r'include_client_id: false'),
                regex(r'send_if_empty:\s*.*', r'send_if_empty: false'),
            ],
        ),
        
        # Prevent DoH canary requests
        *_process_file(
            path="toolkit/components/doh/DoHHeuristics.sys.mjs",
            replacements=[
                regex(r'GLOBAL_CANARY = ".*"', r'GLOBAL_CANARY = ""'),
                regex(r'ZSCALER_CANARY = ".*"', r'ZSCALER_CANARY = ""'),
            ],
        ),

        # Prevent DoH remote config/rollout — DoHConfig
        *_process_file(
            path="toolkit/components/doh/DoHConfig.sys.mjs",
            replacements=[
                regex(r'RemoteSettings\(".*"', r'RemoteSettings(""'),
                literal('"doh-config"', ""),
                literal('"doh-providers"', ""),
            ],
        ),

        # Prevent DoH remote config/rollout — DoHTestUtils
        *_process_file(
            path="toolkit/components/doh/DoHTestUtils.sys.mjs",
            replacements=[
                regex(r'kConfigCollectionKey = ".*"', r'kConfigCollectionKey = ""'),
                regex(r'kProviderCollectionKey = ".*"', r'kProviderCollectionKey = ""'),
                literal('"doh-config"', ""),
                literal('"doh-providers"', ""),
            ],
        ),
        
        # Remove example dependencies, ExoPlayer, and comment out sample projects in settings.gradle
        *_process_file(
            path="settings.gradle",
            replacements=[
                # leave include ':annotations' only, remove the trailing extra includes on the same line
                regex(r"include ':annotations', .*", r"include ':annotations'"),
                # comment out sample projects
                comment_out(r"project\(':messaging_example'",),
                comment_out(r"project\(':port_messaging_example'",),
                # comment out ExoPlayer includes/projects
                comment_out(r"include ':exoplayer2'",),
                comment_out(r"project\(':exoplayer2'",),
            ],
        ),

        # Remove proprietary/tracking libs from gradle/libs.versions.toml
        *_process_file(
            path="gradle/libs.versions.toml",
            replacements=[
                line_affix("adjust", prefix="#"),
                line_affix("firebase-messaging", prefix="#"),
                line_affix("installreferrer", prefix="#"),
                line_affix("play-review", prefix="#"),
                line_affix("play-services", prefix="#"),
                line_affix("sentry", prefix="#"),
            ],
        ),

        # Tweak mobile/shared-settings.gradle condition (remove android-components check)
        *_process_file(
            path="mobile/android/shared-settings.gradle",
            replacements=[
                regex(
                    r'if (rootDir.toString().contains("android-components") || !project.key.startsWith("samples"))',
                    r'if (!project.key.startsWith("samples"))'
                ),
            ],
        ),
        
        # Neutralize content-blocking prefs (GeckoView ContentBlocking.java)
        *_process_file(
            path="mobile/android/geckoview/src/main/java/org/mozilla/geckoview/ContentBlocking.java",
            replacements=[
                regex(r'"browser\.safebrowsing\.provider\."',
                      r'"z99.ignore.string."'),
                regex(r'"cookiebanners\.service\.detectOnly"',
                      r'"z99.ignore.boolean"'),
                regex(r'"cookiebanners\.service\.enableGlobalRules"',
                      r'"z99.ignore.boolean"'),
                regex(r'"cookiebanners\.service\.enableGlobalRules\.subFrames"',
                      r'"z99.ignore.boolean"'),
                regex(r'"cookiebanners\.service\.mode"',
                      r'"z99.ignore.integer"'),
                regex(r'"network\.cookie\.cookieBehavior"',
                      r'"z99.ignore.integer"'),
                regex(r'"network\.cookie\.cookieBehavior\.pbmode"',
                      r'"z99.ignore.integer"'),
                regex(r'"privacy\.annotate_channels\.strict_list\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.bounceTrackingProtection\.mode"',
                      r'"z99.ignore.integer"'),
                regex(r'"privacy\.purge_trackers\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.query_stripping\.allow_list"',
                      r'"z99.ignore.string"'),
                regex(r'"privacy\.query_stripping\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.query_stripping\.enabled\.pbmode"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.query_stripping\.strip_list"',
                      r'"z99.ignore.string"'),
                regex(r'"privacy\.socialtracking\.block_cookies\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.trackingprotection\.annotate_channels"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.trackingprotection\.cryptomining\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.trackingprotection\.emailtracking\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.trackingprotection\.emailtracking\.pbmode\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.trackingprotection\.fingerprinting\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"privacy\.trackingprotection\.socialtracking\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"urlclassifier\.features\.cryptomining\.blacklistTables"',
                      r'"z99.ignore.string"'),
                regex(r'"urlclassifier\.features\.emailtracking\.blocklistTables"',
                      r'"z99.ignore.string"'),
                regex(r'"urlclassifier\.features\.fingerprinting\.blacklistTables"',
                      r'"z99.ignore.string"'),
                regex(r'"urlclassifier\.features\.socialtracking\.annotate\.blacklistTables"',
                      r'"z99.ignore.string"'),
                regex(r'"urlclassifier\.malwareTable"',
                      r'"z99.ignore.string"'),
                regex(r'"urlclassifier\.phishTable"',
                      r'"z99.ignore.string"'),
                regex(r'"urlclassifier\.trackingTable"',
                      r'"z99.ignore.string"'),
            ],
        ),

        # Neutralize pref bindings (GeckoRuntimeSettings.java)
        *_process_file(
            path="mobile/android/geckoview/src/main/java/org/mozilla/geckoview/GeckoRuntimeSettings.java",
            replacements=[
                regex(r'"apz\.allow_double_tap_zooming"', r'"z99.ignore.boolean"'),
                regex(r'"browser\.crashReports\.requestedNeverShowAgain"', r'"z99.ignore.boolean"'),
                regex(r'"browser\.display\.use_document_fonts"', r'"z99.ignore.integer"'),
                regex(r'"docshell\.shistory\.sameDocumentNavigationOverridesLoadType"', r'"z99.ignore.boolean"'),
                regex(r'"docshell\.shistory\.sameDocumentNavigationOverridesLoadType\.forceDisable"', r'"z99.ignore.string"'),
                regex(r'"dom\.ipc\.processCount"', r'"z99.ignore.integer"'),
                regex(r'"dom\.manifest\.enabled"', r'"z99.ignore.boolean"'),
                regex(r'"extensions\.webapi\.enabled"', r'"z99.ignore.boolean"'),
                regex(r'"extensions\.webextensions\.crash\.threshold"', r'"z99.ignore.integer"'),
                regex(r'"extensions\.webextensions\.crash\.timeframe"', r'"z99.ignore.long"'),
                regex(r'"extensions\.webextensions\.remote"', r'"z99.ignore.boolean"'),
                regex(r'"fission\.autostart"', r'"z99.ignore.boolean"'),
                regex(r'"fission\.disableSessionHistoryInParent"', r'"z99.ignore.boolean"'),
                regex(r'"fission\.webContentIsolationStrategy"', r'"z99.ignore.integer"'),
                regex(r'"formhelper\.autozoom"', r'"z99.ignore.boolean"'),
                regex(r'"general\.aboutConfig\.enable"', r'"z99.ignore.boolean"'),
                regex(r'"javascript\.options\.mem\.gc_parallel_marking"', r'"z99.ignore.boolean"'),
                regex(r'"javascript\.options\.use_fdlibm_for_sin_cos_tan"', r'"z99.ignore.boolean"'),
                regex(r'"network\.android_doh\.autoselect_enabled"', r'"z99.ignore.boolean"'),
                regex(r'"network\.cookie\.cookieBehavior\.optInPartitioning"', r'"z99.ignore.boolean"'),
                regex(r'"network\.cookie\.cookieBehavior\.optInPartitioning\.pbmode"', r'"z99.ignore.boolean"'),
                regex(r'"network\.fetchpriority\.enabled"', r'"z99.ignore.boolean"'),
                regex(r'"network\.http\.http3\.enable_kyber"', r'"z99.ignore.boolean"'),
                regex(r'"network\.http\.largeKeepaliveFactor"', r'"z99.ignore.integer"'),
                regex(r'"network\.security\.ports\.banned"', r'"z99.ignore.string"'),
                regex(r'"privacy\.baselineFingerprintingProtection"', r'"z99.ignore.boolean"'),
                regex(r'"privacy\.baselineFingerprintingProtection\.overrides"', r'"z99.ignore.string"'),
                regex(r'"privacy\.fingerprintingProtection"', r'"z99.ignore.boolean"'),
                regex(r'"privacy\.fingerprintingProtection\.overrides"', r'"z99.ignore.string"'),
                regex(r'"privacy\.fingerprintingProtection\.pbmode"', r'"z99.ignore.boolean"'),
                regex(r'"privacy\.globalprivacycontrol\.enabled"', r'"z99.ignore.boolean"'),
                regex(r'"privacy\.globalprivacycontrol\.functionality\.enabled"', r'"z99.ignore.boolean"'),
                regex(r'"privacy\.globalprivacycontrol\.pbmode\.enabled"', r'"z99.ignore.boolean"'),
                regex(r'"security\.pki\.certificate_transparency\.mode"', r'"z99.ignore.integer"'),
                regex(r'"security\.tls\.enable_kyber"', r'"z99.ignore.boolean"'),
                regex(r'"toolkit\.telemetry\.user_characteristics_ping\.current_version"', r'"z99.ignore.integer"'),
                regex(r'"webgl\.msaa-samples"', r'"z99.ignore.integer"'),
                
                # On nightlies, allow remote debugging to be enabled persistently
                *([regex(r'"devtools\.debugger\.remote-enabled"', r'"z99.ignore.boolean"')] if config.app_config.nightly else []),
            ],
        ),
        
        # On nightlies, allow remote debugging to be enabled persistently
        *_process_file(
            path="mobile/shared/components/geckoview/GeckoViewStartup.sys.mjs",
            replacements= [
                literal('clearUserPref("devtools.debugger.remote-enabled")', 'clearUserPref("z99.ignore.boolean")')
            ] if config.app_config.nightly else []
        ),
        
        # Fail on use of prebuilt binary (use hxxps)
        *_process_file(
            path="mobile/android/gradle/plugins/nimbus-gradle-plugin/src/main/groovy/org/mozilla/appservices/tooling/nimbus/NimbusGradlePlugin.groovy",
            replacements=[
                literal("https://", "hxxps://"),
            ],
        ),

        # Fail on use of prebuilt binary in mozboot (github URL -> hxxps)
        *_process_file(
            path="python/mozboot/mozboot/android.py",
            replacements=[
                literal("https://github.com", "hxxps://github.com"),
            ],
        ),

        # Remove emulator tool check line from android-sdk.configure
        *_process_file(
            path="build/moz.configure/android-sdk.configure",
            replacements=[
                regex(r'check_android_tools\("emulator".*\)\s*', r''),
            ],
        ),

        # Do not define browser.safebrowsing.features.* prefs by default (geckoview prefs)
        *_process_file(
            path="mobile/android/app/geckoview-prefs.js",
            replacements=[
                regex(r'"browser\.safebrowsing\.features\.cryptomining\.update"', r'"z99.ignore.boolean"'),
                regex(r'"browser\.safebrowsing\.features\.fingerprinting\.update"', r'"z99.ignore.boolean"'),
                regex(r'"browser\.safebrowsing\.features\.malware\.update"', r'"z99.ignore.boolean"'),
                regex(r'"browser\.safebrowsing\.features\.phishing\.update"', r'"z99.ignore.boolean"'),
                regex(r'"browser\.safebrowsing\.features\.trackingAnnotation\.update"', r'"z99.ignore.boolean"'),
                regex(r'"browser\.safebrowsing\.features\.trackingProtection\.update"', r'"z99.ignore.boolean"'),
            ],
        ),
        
        # Apply overlay
        d.overlay(
            name="Apply Firefox overlay",
            source_dir=paths.patches_dir / "gecko-overlay",
            target_dir=paths.firefox_dir,
        ),
        
        # Copy certain assets shared between release and nightly
        d.copy_dir_contents(
            name="Create nightly branding (1/2)",
            source_dir=paths.patches_dir / "gecko-overlay/mobile/android/branding/ironfox/about",
            target_dir=paths.firefox_dir / "mobile/android/branding/ironfox-nightly",
            recursive=True,
        ),
        d.copy_dir_contents(
            name="Create nightly branding (2/2)",
            source_dir=paths.patches_dir / "gecko-overlay/mobile/android/branding/ironfox/dumps",
            target_dir=paths.firefox_dir / "mobile/android/branding/ironfox-nightly",
            recursive=True,
        ),
        
        # Write mozconfig
        d.write_file(
            name="Write mozconfig",
            target=paths.firefox_dir / "mozconfig",
            overwrite=True,
            append=False,
            contents=lambda: mozconfig(config, paths).encode()
        ),
        
        # Write geckoview-prefs.js
        d.write_file(
            name="Write geckoview-prefs.js",
            target=paths.firefox_dir / "mobile/android/app/geckoview-prefs.js",
            append=True,
            contents=lambda: prefs(config, paths).encode(),
        ),
        
        # Write PdfJsOverridePrefs.js
        d.write_file(
            name="Write PdfJsOverridePrefs.js",
            target=paths.firefox_dir / "toolkit/components/pdfjs/PdfJsOverridePrefs.js",
            append=True,
            contents=lambda: pdfjs(paths).encode(),
        ),
        # fmt:on
    ]


def prefs(config: PrepareConfig, paths: Paths) -> str:
    files = [
        "phoenix.js",
        "phoenix-extended.js",
        "ironfox.js",
    ]

    contents = read_contents(
        list(map(lambda f: paths.patches_dir / "preferences" / f, files))
    )

    if len(config.ubo_assets.strip()) != 0:
        contents += os.linesep
        contents += f'pref("browser.ironfox.uBO.assetsBootstrapLocation", "{config.ubo_assets}");'

    return contents


def pdfjs(paths: Paths) -> str:
    files = ["pdf.js"]
    return read_contents(
        list(map(lambda f: paths.patches_dir / "preferences" / f, files))
    )


def read_contents(paths: List[Path]) -> str:
    contents = ""
    for path in paths:
        contents += os.linesep
        contents += path.read_text()

    return contents


def mozconfig(config: PrepareConfig, paths: Paths) -> str:
    app = config.app_config
    branding_path = (
        "mobile/android/branding/ironfox-nightly"
        if (app.nightly)
        else "mobile/android/branding/ironfox"
    )

    wasi_install = paths.wasi_sdk_dir / "build/install/wasi"

    return f"""
ac_add_options --disable-address-sanitizer-reporter
ac_add_options --disable-android-debuggable
ac_add_options --disable-artifact-builds
ac_add_options --disable-backgroundtasks
ac_add_options --disable-callgrind
ac_add_options --disable-crashreporter
ac_add_options --disable-debug
ac_add_options --disable-debug-js-modules
ac_add_options --disable-debug-symbols
ac_add_options --disable-default-browser-agent
ac_add_options --disable-dtrace
ac_add_options --disable-dump-painting
ac_add_options --disable-execution-tracing
ac_add_options --disable-extensions-webidl-bindings
ac_add_options --disable-ffmpeg
ac_add_options --disable-gecko-profiler
ac_add_options --disable-geckodriver
ac_add_options --disable-gtest-in-build
ac_add_options --disable-instruments
ac_add_options --disable-jitdump
ac_add_options --disable-js-shell
ac_add_options --disable-layout-debugger
ac_add_options --disable-logrefcnt
ac_add_options --disable-negotiateauth
ac_add_options --disable-nodejs
ac_add_options --disable-parental-controls
ac_add_options --disable-phc
ac_add_options --disable-pref-extensions
ac_add_options --disable-profiling
ac_add_options --disable-real-time-tracing
ac_add_options --disable-reflow-perf
ac_add_options --disable-rust-debug
ac_add_options --disable-rust-tests
ac_add_options --disable-simulator
ac_add_options --disable-spidermonkey-telemetry
ac_add_options --disable-system-extension-dirs
ac_add_options --disable-system-policies
ac_add_options --disable-tests
ac_add_options --disable-uniffi-fixtures
ac_add_options --disable-unverified-updates
ac_add_options --disable-updater
ac_add_options --disable-vtune
ac_add_options --disable-wasm-codegen-debug
ac_add_options --disable-webdriver
ac_add_options --disable-webrender-debugger
ac_add_options --disable-webspeechtestbackend
ac_add_options --disable-wmf
ac_add_options --enable-android-subproject=fenix
ac_add_options --enable-application=mobile/android
ac_add_options --enable-disk-remnant-avoidance
ac_add_options --enable-geckoview-lite
ac_add_options --enable-hardening
ac_add_options --enable-install-strip
ac_add_options --enable-isolated-process
ac_add_options --enable-minify=properties
ac_add_options --enable-mobile-optimize
ac_add_options --enable-optimize
ac_add_options --enable-proxy-bypass-protection
ac_add_options --enable-release
ac_add_options --enable-replace-malloc
ac_add_options --enable-rust-simd
ac_add_options --enable-strip
ac_add_options --enable-update-channel=release

ac_add_options --with-app-basename={app.app_name}
ac_add_options --with-app-name={app.app_name.lower()}
ac_add_options --with-branding={branding_path}

ac_add_options --with-crashreporter-url="data;"
ac_add_options --with-distribution-id={app.app_id_base}
ac_add_options --with-java-bin-path="{paths.java_home}/bin"
ac_add_options --target={config.target}
ac_add_options --with-android-ndk="{paths.ndk_home}"
ac_add_options --with-android-sdk="{paths.android_home}"
ac_add_options --with-gradle={paths.gradle_exec}
ac_add_options --with-libclang-path="{paths.libclang_dir}"
ac_add_options --with-wasi-sysroot="{wasi_install}/share/wasi-sysroot"
ac_add_options --without-adjust-sdk-keyfile
ac_add_options --without-android-googlevr-sdk
ac_add_options --without-bing-api-keyfile
ac_add_options --without-google-location-service-api-keyfile
ac_add_options --without-mozilla-api-keyfile
ac_add_options --without-leanplum-sdk-keyfile
ac_add_options --without-pocket-api-keyfile

{f"ac_add_options --with-google-safebrowsing-api-keyfile={config.sb_gapi_file}" if config.sb_gapi_file.exists() else ""}

ac_add_options WASM_CC="{wasi_install}/bin/clang"
ac_add_options WASM_CXX="{wasi_install}/bin/clang++"
ac_add_options CC="{paths.ndk_toolchain_dir}/bin/clang"
ac_add_options CXX="{paths.ndk_toolchain_dir}/bin/clang++"
ac_add_options STRIP="{paths.ndk_toolchain_dir}/bin/llvm-strip"
mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj
export ANDROID_BUNDLETOOL_PATH="{paths.build_dir}/bundletool.jar"
export GRADLE_MAVEN_REPOSITORIES="file://$HOME/.m2/repository/","https://plugins.gradle.org/m2/","https://maven.google.com/"
export MOZ_ANDROID_CONTENT_SERVICE_ISOLATED_PROCESS=1

export MOZ_APP_BASENAME={app.app_name}
export MOZ_APP_NAME={app.app_name.lower()}
export MOZ_APP_REMOTINGNAME={app.app_name.lower().replace(' ', '-')}

export MOZ_ARTIFACT_BUILDS=
export MOZ_CALLGRIND=
export MOZ_CRASHREPORTER=
export MOZ_CRASHREPORTER_URL="data;"
export MOZ_DEBUG_FLAGS=
export MOZ_EXECUTION_TRACING=
export MOZ_INCLUDE_SOURCE_INFO=1
export MOZ_INSTRUMENTS=
export MOZ_LTO=1
export MOZ_PACKAGE_JSSHELL=
export MOZ_PGO=1
export MOZ_PHC=
export MOZ_PROFILING=
export MOZ_REQUIRE_SIGNING=
export MOZ_RUST_SIMD=1
export MOZ_SECURITY_HARDENING=1
export MOZ_TELEMETRY_REPORTING=
export MOZ_VTUNE=
export MOZILLA_OFFICIAL=1
export NODEJS=
export RUSTC_OPT_LEVEL=2
"""
