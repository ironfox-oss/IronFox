import os
from pathlib import Path
import subprocess
from typing import List
from commands.prepare import PrepareConfig
from common.paths import Paths
from common.utils import current_platform
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition

from execution.find_replace import eol_comment_line, line_affix, literal, regex
from execution.types import ReplacementAction

from .deglean import deglean


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
            target_files=paths.firefox_dir / path,
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
        
        # Apply patches
        d.patch(
            name="Apply Firefox patches",
            patch_file=paths.patches_dir / "patches.yaml",
            target_dir=paths.firefox_dir,
        ),

        _mkdirs(f"{paths.android_home}/emulator"),
        _mkdirs(f"{paths.user_home}/.mozbuild/android-device/avd"),
        
        _mkdirs("ironfox/about/browser/locales/en-US/browser/policies"),
        _mkdirs("ironfox/about/browser/robots"),
        
        # Remove unused telemetry assets
        *_rm("toolkit/content/aboutTelemetry.css"),
        *_rm("toolkit/content/aboutTelemetry.js"),
        *_rm("toolkit/content/aboutTelemetry.xhtml"),
        
        # Remove DoH rollout local dumps
        *_rm("services/settings/static-dumps/main/doh-config.json"),
        *_rm("services/settings/static-dumps/main/doh-providers.json"),
        
        *_process_file(
            path="mobile/android/moz.configure",
            replacements=[
                regex(r'("MOZ_APP_VENDOR",\s*").*(")', fr'\1{config.app_config.vendor}\2'),
                regex(r'("MOZ_NORMANDY",\s*).*(\))', r'\1False\2'),
                regex(r'("MOZ_SERVICES_HEALTHREPORT",\s*).*(\))', r'\1False\2'),
                regex(r'("MOZ_APP_UA_NAME",\s*").*(")', r'\1Firefox\2'),
            ],
        ),
        
        # Append include("ironfox.configure") and a blank line to moz.configure
        d.write_file(
            name="Include ironfox.configure in moz.configure",
            target=paths.firefox_dir / "mobile/android/moz.configure",
            contents=lambda: b'\ninclude("../../ironfox/ironfox.configure")',
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
        
        # Use `commit` instead of `rev` for source URL
        ## (ex. displayed at `about:buildconfig`)
        *_process_file(
            path="build/variables.py",
            replacements=[
                literal("/rev/", "/commit/")
            ],
        ),
        
        # about: pages
        d.copy(
            source=paths.firefox_dir / "browser/locales/en-US/browser/aboutPolicies.ftl",
            target=paths.firefox_dir / "ironfox/about/browser/locales/en-US/browser/aboutPolicies.ftl",
        ),
        d.copy(
            source=paths.firefox_dir / "browser/locales/en-US/browser/policies/policies-descriptions.ftl",
            target=paths.firefox_dir / "ironfox/about/browser/locales/en-US/browser/policies/policies-descriptions.ftl",
        ),
        d.write_file(
            name="write package-manifest.in for about: pages",
            target=paths.firefox_dir / "mobile/android/installer/package-manifest.in",
            append=True,
            contents=lambda: b"""
            
            @BINPATH@/chrome/browser@JAREXT@
            @BINPATH@/chrome/browser.manifest
            
            @BINPATH@/chrome/ironfox@JAREXT@
            @BINPATH@/chrome/ironfox.manifest
            """
        ),
        
        # about:robots
        d.copy(source=paths.firefox_dir / "browser/base/content/aboutRobots.css", target=paths.firefox_dir/ "ironfox/about/browser/robots/aboutRobots.css"),
        d.copy(source=paths.firefox_dir / "browser/base/content/aboutRobots.js", target=paths.firefox_dir/ "ironfox/about/browser/robots/aboutRobots.js"),
        d.copy(source=paths.firefox_dir / "browser/base/content/aboutRobots.xhtml", target=paths.firefox_dir/ "ironfox/about/browser/robots/aboutRobots.xhtml"),
        d.copy(source=paths.firefox_dir / "browser/base/content/aboutRobots-icon.png", target=paths.firefox_dir/ "ironfox/about/browser/robots/aboutRobots-icon.png"),
        d.copy(source=paths.firefox_dir / "browser/base/content/robot.ico", target=paths.firefox_dir / "ironfox/about/browser/robots/robot.ico"),
        d.copy(source=paths.firefox_dir / "browser/base/content/static-robot.png", target=paths.firefox_dir / "ironfox/about/browser/robots/static-robot.png"),
        d.copy(source=paths.firefox_dir / "browser/locales/en-US/browser/aboutRobots.ftl", target=paths.firefox_dir / "ironfox/about/browser/locales/en-US/browser/aboutRobots.ftl"),
        
        # Remove the Clear Key CDM
        *_process_file(
            path="mobile/android/installer/package-manifest.in",
            replacements=[
                eol_comment_line(r'@BINPATH@/@DLL_PREFIX@clearkey', comment_token=";")
            ]
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
                regex(r"singleVariant\('debug'\)", r"singleVariant('release')"),
                
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
        *_process_file(
            path="gfx/wr/Cargo.toml",
            replacements=[
                regex(r'debug = .*', r'debug = false')
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
                eol_comment_line('classpath "${ApplicationServicesConfig.groupId}:tooling-nimbus-gradle"'),
                eol_comment_line(r'classpath libs\.glean\.gradle\.plugin')
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
                regex(r'SECURE_EXPERIMENTS_COLLECTION = ".*"', r'SECURE_EXPERIMENTS_COLLECTION = ""'),
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
        
        # Remove DoH config/rollout - local dumps
        *_process_file(
            path="services/settings/static-dumps/main/moz.build",
            replacements=[
                line_affix(r'doh-config.json', prefix="#"),
                line_affix(r'doh-providers.json', prefix="#"),
            ]
        ),

        # Remove example dependencies, ExoPlayer, and comment out sample projects in settings.gradle
        *_process_file(
            path="settings.gradle",
            replacements=[
                # leave include ':annotations' only, remove the trailing extra includes on the same line
                regex(r"include ':annotations', .*", r"include ':annotations'"),
                # comment out sample projects
                eol_comment_line(r"project\(':messaging_example'",),
                eol_comment_line(r"project\(':port_messaging_example'",),
                # comment out ExoPlayer includes/projects
                eol_comment_line(r"include ':exoplayer2'",),
                eol_comment_line(r"project\(':exoplayer2'",),
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
                literal("UNIFIEDPUSH_VERSION", Versions.UNIFIEDPUSH_VERSION)
            ],
        ),

        # Tweak mobile/shared-settings.gradle condition (remove android-components check)
        *_process_file(
            path="mobile/android/shared-settings.gradle",
            replacements=[
                literal(
                    'if (rootDir.toString().contains("android-components") || !project.key.startsWith("samples"))',
                    'if (!project.key.startsWith("samples"))'
                ),
            ],
        ),
        
        # Neutralize content-blocking prefs (GeckoView ContentBlocking.java)
        *_process_file(
            path="mobile/android/geckoview/src/main/java/org/mozilla/geckoview/ContentBlocking.java",
            replacements=[
                regex(r'"browser\.safebrowsing\.malware\.enabled"',
                      r'"z99.ignore.boolean"'),
                regex(r'"browser\.safebrowsing\.phishing\.enabled"',
                      r'"z99.ignore.boolean"'),
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
                regex(r'"devtools\.debugger\.remote-enabled"', r'"z99.ignore.boolean"'),
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
                regex(r'"javascript\.enabled"', r'"z99.ignore.boolean"'),
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
                regex(r'"security\.pki\.crlite_channel"', r'"z99.ignore.string"'),
                regex(r'"security\.tls\.enable_kyber"', r'"z99.ignore.boolean"'),
                regex(r'"toolkit\.telemetry\.user_characteristics_ping\.current_version"', r'"z99.ignore.integer"'),
                regex(r'"webgl\.msaa-samples"', r'"z99.ignore.integer"'),
            ],
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
        
        # De-Glean
        *deglean(d, paths.firefox_dir / "mobile/android/geckoview"),
        *deglean(d, paths.firefox_dir / "mobile/android/gradle"),
        
        # Update IronFox and Phoenix versions
        *_process_file(
            path="mobile/android/app/geckoview-prefs.js",
            replacements=[
                literal("IRONFOX_VERSION", Versions.IRONFOX_VERSION),
                literal("PHOENIX_VERSION", Versions.PHOENIX_TAG),
            ]
        ),
        
        # Write geckoview-prefs.js
        d.write_file(
            name="Write geckoview-prefs.js",
            target=paths.firefox_dir / "mobile/android/app/geckoview-prefs.js",
            append=True,
            contents=lambda: b"""
            #include ../../../ironfox/prefs/002-ironfox.js
            """,
        ),
        
        # Write PdfJsOverridePrefs.js
        d.write_file(
            name="Write PdfJsOverridePrefs.js",
            target=paths.firefox_dir / "toolkit/components/pdfjs/PdfJsOverridePrefs.js",
            append=True,
            contents=lambda: b"""
            #include ../../../ironfox/prefs/pdf.js
            """,
        ),
        
        # Apply overlay
        d.overlay(
            name="Apply Firefox overlay",
            source_dir=paths.patches_dir / "gecko-overlay",
            target_dir=paths.firefox_dir,
        ),
        
        # Because `app.support.vendor` is locked, we need to unset it in Phoenix's pref files
        # for our value (at 002-ironfox.js) takes effect
        *_process_file(
            path="ironfox/prefs/*-phoenix*.js",
            replacements=[
                literal('"app.support.vendor"', '"z99.ignore.string"')
            ]
        ),
        
        
        # Update mozconfig to include SB GAPI config
        d.write_file(
            name="Update mozconfig",
            target=paths.firefox_dir / "mozconfig",
            append=True,
            contents=lambda: f"""
            
            {'''
            
            ## Enable Safe Browsing
            ### SB_GAPI_KEY_FILE = $SB_GAPI_KEY_FILE
            ac_add_options --with-google-safebrowsing-api-keyfile='{str(config.sb_gapi_file)}'
            
            ''' if config.sb_gapi_file.exists()
            
            else '''
            
            ## Disable Safe Browsing
            ### (SB_GAPI_KEY_FILE was undefined...)
            ac_add_options --without-google-safebrowsing-api-keyfile
            
            '''}
            
            """.encode()
        ),
        
        
        *_process_file(
            path="local.properties",
            replacements=[
                literal("{android_components}", str(paths.android_components_dir)),
                literal("{glean}", str(paths.glean_dir)),
                literal("{mozilla_release}", str(paths.firefox_dir)),
            ]
        ),
        
        *_process_file(
            path="ironfox/mozconfigs/env.mozconfig",
            replacements=[
                literal("{ANDROID_HOME}", str(paths.android_home)),
                literal("{ANDROID_NDK}", str(paths.ndk_home)),
                literal("{builddir}", str(paths.build_dir)),
                literal("{GRADLE_PATH}", str(paths.gradle_exec)),
                literal("{HOME}", str(paths.user_home)),
                literal("{JAVA_HOME}", str(paths.java_home)),
                literal("{libclang}", str(paths.libclang_dir)),
                literal("{PLATFORM}", current_platform().lower()),
                literal("{wasi_install}", str(paths.wasi_sdk_dir)),
            ]
        ),
        
        *_process_file(
            path="mozconfig",
            replacements=[
                literal("{geckotarget}", config.target),
                literal("{IRONFOX_CHANNEL}", config.app_config.channel.id),
            ]
        ),
        
        *_process_file(
            path="ironfox/prefs/002-ironfox.js",
            replacements=[
                literal("{IRONFOX_UBO_ASSETS_URL}", config.ubo_assets),
                literal("{IRONFOX_VERSION}", Versions.IRONFOX_VERSION),
                literal("{PHOENIX_VERSION}", Versions.PHOENIX_TAG),
            ]
        ),
        
        *_process_file(
            path="ironfox/mozconfigs/branding/env.mozconfig",
            replacements=[
                literal("{CURRENT_REVISION}", str(subprocess.check_output(["git", "log", "-1", "--format='%H'"], cwd=paths.root_dir)))
            ]
        )
        # fmt:on
    ]
