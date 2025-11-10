from typing import List
from commands.prepare import PrepareConfig
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition

from execution.find_replace import (
    eol_comment_line,
    eol_comment_text,
    line_affix,
    literal,
    on_line_text,
    regex,
)
from execution.types import ReplacementAction

from .deglean import deglean


def prepare_fenix(
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
            target_files=paths.fenix_dir / path,
            replacements=replacements,
        )

    def _rm(
        path: str,
        recursive: bool = False,
    ) -> List[TaskDefinition]:
        return d.delete(
            name=f"Delete {path}", path=paths.fenix_dir / path, recursive=recursive
        )

    def _mkdirs(
        path: str,
        parents: bool = True,
        exist_ok: bool = True,
    ) -> TaskDefinition:
        return d.mkdir(
            name=f"Create directory {path}",
            target=paths.fenix_dir / path,
            parents=parents,
            exist_ok=exist_ok,
        )

    return [
        # fmt:off
        
        d.write_file(
            name="Set official=true in local.properties",
            target=paths.fenix_dir / "local.properties",
            append=True,
            contents=lambda: f"""
# Make if official
official=true

# No-op Glean
glean.custom.server.url="data;"

# Enable the auto-publication workflow
autoPublish.application-services.dir={paths.application_services_dir}

# Disable FUS Service or we'll get errors like:
# Exception while loading configuration for :app: Could not load the value of field `__buildFusService__` of task `:app:compileFenixReleaseKotlin` of type `org.jetbrains.kotlin.gradle.tasks.KotlinCompile`.
kotlin.internal.collectFUSMetrics=false
""".encode(),
        ),
        
        # ---- FILE SYSTEM OPERATIONS ----
        
        # Telemetry
        *_rm("app/src/*/java/org/mozilla/fenix/bookmarks/BookmarksTelemetryMiddleware.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/ActivationPing.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/AdjustMetricsService.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/BreadcrumbsRecorder.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/Event.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/FirstSessionPing.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/GrowthDataWorker.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/InstallReferrerMetricsService.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/MarketingAttributionService.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/MetricController.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/MetricsMiddleware.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/MetricsService.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/MetricsStorage.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/MozillaProductDetector.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/toolbar/BrowserToolbarTelemetryMiddleware.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/downloads/listscreen/middleware/DownloadTelemetryMiddleware.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/home/toolbar/BrowserToolbarTelemetryMiddleware.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptTelemetryMiddleware.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/tabstray/TabsTrayTelemetryMiddleware.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/webcompat/middleware/WebCompatReporterTelemetryMiddleware.kt"),
        *_rm("app/src/*/java/org/mozilla/fenix/components/metrics/fonts", recursive=True),
        *_rm("app/src/*/java/org/mozilla/fenix/settings/datachoices", recursive=True),
        *_rm("app/src/*/java/org/mozilla/fenix/telemetry", recursive=True),
        *_rm("app/src/main/java/org/mozilla/fenix/home/TopSitesRefresher.kt"),
        
        # Remove unused media
        ## Based on Tor Browser: https://gitlab.torproject.org/tpo/applications/tor-browser/-/commit/264dc7cd915e75ba9db3a27e09253acffe3f2311
        ## This should help reduce our APK sizes...
        *_rm("app/src/debug/ic_launcher-playstore.png"),
        *_rm("app/src/debug/ic_launcher-web.webp"),
        *_rm("app/src/debug/res/drawable/ic_launcher_foreground.xml"),
        *_rm("app/src/debug/res/mipmap-anydpi-v26/ic_launcher_round.xml"),
        *_rm("app/src/debug/res/mipmap-anydpi-v26/ic_launcher.xml"),
        *_rm("app/src/debug/res/mipmap-hdpi/ic_launcher_round.webp"),
        *_rm("app/src/debug/res/mipmap-hdpi/ic_launcher.webp"),
        *_rm("app/src/debug/res/mipmap-mdpi/ic_launcher_round.webp"),
        *_rm("app/src/debug/res/mipmap-mdpi/ic_launcher.webp"),
        *_rm("app/src/debug/res/mipmap-xhdpi/ic_launcher_round.webp"),
        *_rm("app/src/debug/res/mipmap-xhdpi/ic_launcher.webp"),
        *_rm("app/src/debug/res/mipmap-xxhdpi/ic_launcher_round.webp"),
        *_rm("app/src/debug/res/mipmap-xxhdpi/ic_launcher.webp"),
        *_rm("app/src/debug/res/mipmap-xxxhdpi/ic_launcher_round.webp"),
        *_rm("app/src/debug/res/mipmap-xxxhdpi/ic_launcher.webp"),
        *_rm("app/src/main/ic_launcher_private-web.webp"),
        *_rm("app/src/main/ic_launcher-web.webp"),
        *_rm("app/src/main/res/drawable/ic_launcher_foreground.xml"),
        *_rm("app/src/main/res/drawable/ic_launcher_monochrome.xml"),
        *_rm("app/src/main/res/drawable/ic_onboarding_search_widget.xml"),
        *_rm("app/src/main/res/drawable/ic_onboarding_sync.xml"),
        *_rm("app/src/main/res/drawable/ic_wordmark_logo.webp"),
        *_rm("app/src/main/res/drawable/ic_wordmark_text_normal.webp"),
        *_rm("app/src/main/res/drawable/ic_wordmark_text_private.webp"),
        *_rm("app/src/main/res/drawable/microsurvey_success.xml"),
        *_rm("app/src/main/res/drawable/onboarding_ctd_sync.xml"),
        *_rm("app/src/main/res/drawable-hdpi/fenix_search_widget.webp"),
        *_rm("app/src/main/res/drawable-hdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/main/res/drawable-hdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/main/res/drawable-mdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/main/res/drawable-mdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/main/res/drawable-xhdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/main/res/drawable-xhdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/main/res/drawable-xxhdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/main/res/drawable-xxhdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/main/res/drawable-xxxhdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/main/res/drawable-xxxhdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/main/res/mipmap-anydpi-v26/ic_launcher_private_round.xml"),
        *_rm("app/src/main/res/mipmap-anydpi-v26/ic_launcher_private.xml"),
        *_rm("app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml"),
        *_rm("app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"),
        *_rm("app/src/main/res/mipmap-hdpi/ic_launcher_private_round.webp"),
        *_rm("app/src/main/res/mipmap-hdpi/ic_launcher_private.webp"),
        *_rm("app/src/main/res/mipmap-hdpi/ic_launcher_round.webp"),
        *_rm("app/src/main/res/mipmap-hdpi/ic_launcher.webp"),
        *_rm("app/src/main/res/mipmap-mdpi/ic_launcher_private_round.webp"),
        *_rm("app/src/main/res/mipmap-mdpi/ic_launcher_private.webp"),
        *_rm("app/src/main/res/mipmap-mdpi/ic_launcher_round.webp"),
        *_rm("app/src/main/res/mipmap-mdpi/ic_launcher.webp"),
        *_rm("app/src/main/res/mipmap-xhdpi/ic_launcher_private_round.webp"),
        *_rm("app/src/main/res/mipmap-xhdpi/ic_launcher_private.webp"),
        *_rm("app/src/main/res/mipmap-xhdpi/ic_launcher_round.webp"),
        *_rm("app/src/main/res/mipmap-xhdpi/ic_launcher.webp"),
        *_rm("app/src/main/res/mipmap-xxhdpi/ic_launcher_private_round.webp"),
        *_rm("app/src/main/res/mipmap-xxhdpi/ic_launcher_private.webp"),
        *_rm("app/src/main/res/mipmap-xxhdpi/ic_launcher_round.webp"),
        *_rm("app/src/main/res/mipmap-xxhdpi/ic_launcher.webp"),
        *_rm("app/src/main/res/mipmap-xxxhdpi/ic_launcher_private_round.webp"),
        *_rm("app/src/main/res/mipmap-xxxhdpi/ic_launcher_private.webp"),
        *_rm("app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.webp"),
        *_rm("app/src/main/res/mipmap-xxxhdpi/ic_launcher.webp"),
        *_rm("app/src/nightly/res/drawable/ic_firefox.xml"),
        *_rm("app/src/nightly/res/drawable/ic_launcher_foreground.xml"),
        *_rm("app/src/nightly/res/drawable/ic_wordmark_logo.webp"),
        *_rm("app/src/nightly/res/drawable/ic_wordmark_text_normal.webp"),
        *_rm("app/src/nightly/res/drawable/ic_wordmark_text_private.webp"),
        *_rm("app/src/nightly/res/drawable-hdpi/fenix_search_widget.webp"),
        *_rm("app/src/nightly/res/drawable-hdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/nightly/res/drawable-hdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/nightly/res/drawable-mdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/nightly/res/drawable-mdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/nightly/res/drawable-xhdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/nightly/res/drawable-xhdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/nightly/res/drawable-xxhdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/nightly/res/drawable-xxhdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/nightly/res/drawable-xxxhdpi/ic_logo_wordmark_normal.webp"),
        *_rm("app/src/nightly/res/drawable-xxxhdpi/ic_logo_wordmark_private.webp"),
        *_rm("app/src/nightly/res/ic_launcher-web.webp"),
        *_rm("app/src/nightly/res/mipmap-hdpi/ic_launcher_round.webp"),
        *_rm("app/src/nightly/res/mipmap-hdpi/ic_launcher.webp"),
        *_rm("app/src/nightly/res/mipmap-mdpi/ic_launcher_round.webp"),
        *_rm("app/src/nightly/res/mipmap-mdpi/ic_launcher.webp"),
        *_rm("app/src/nightly/res/mipmap-xhdpi/ic_launcher_round.webp"),
        *_rm("app/src/nightly/res/mipmap-xhdpi/ic_launcher.webp"),
        *_rm("app/src/nightly/res/mipmap-xxhdpi/ic_launcher_round.webp"),
        *_rm("app/src/nightly/res/mipmap-xxhdpi/ic_launcher.webp"),
        *_rm("app/src/nightly/res/mipmap-xxxhdpi/ic_launcher_round.webp"),
        *_rm("app/src/nightly/res/mipmap-xxxhdpi/ic_launcher.webp"),
        
        # Replace proprietary artwork
        *_rm("app/src/release/res/drawable/ic_launcher_foreground.xml"),
        *_rm("app/src/release/res/mipmap-*/ic_launcher.webp"),
        *_rm("app/src/release/res/values/colors.xml"),
        *_rm("app/src/main/res/values-v24/styles.xml"),
        
        # Create directories
        _mkdirs("app/src/release/res/mipmap-anydpi-v26"),
        
        # Remove default built-in search engines
        *_rm("app/src/*/assets/searchplugins/*", recursive=True),
        
        # Create wallpaper directories
        _mkdirs("app/src/main/assets/wallpapers/algae"),
        _mkdirs("app/src/main/assets/wallpapers/colorful-bubbles"),
        _mkdirs("app/src/main/assets/wallpapers/dark-dune"),
        _mkdirs("app/src/main/assets/wallpapers/dune"),
        _mkdirs("app/src/main/assets/wallpapers/firey-red"),
        
        # ---- REPLACEMENTS ----
        
        
        # app/build.gradle
        *_build_gradle_replacements(config),
        
        # app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt
        *_gecko_provider_kt_replacements(),
        
        # app/src/*/AndroidManifest.xml
        *_android_manifest_xml_replacements(),
        
        # app/src/*/java/org/mozilla/fenix/FeatureFlags.kt
        *_feature_flags_kt_replacements(),

        # app/src/main/java/org/mozilla/fenix/FenixApplication.kt
        *_fenix_application_kt_replacements(),
        
        # app/src/main/java/org/mozilla/fenix/components/Core.kt
        *_core_kt_replacements(),
        
        # app/src/main/java/org/mozilla/fenix/components/Components.kt
        *_components_kt_replacements(),
        
        # app/src/main/java/org/mozilla/fenix/ext/Context.kt
        *_context_kt_replacements(),
        
        # app/src/main/java/org/mozilla/fenix/HomeActivity.kt
        *_home_activity_kt_replacements(),
        
        # app/src/*/res/values*/*strings.xml
        *_strings_xml_replacements(config),
        
        # app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt
        *_support_utils_kt_replacements(),
        
        # Disable sync telemetry
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/settings/account/AccountSettingsFragment.kt",
            replacements=[
                eol_comment_line(r"^\s*import\s+mozilla\.appservices\.syncmanager\.SyncTelemetry"),
                eol_comment_text(r"SyncTelemetry\."),
            ]
        ),
        
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/browser/BrowserToolbarStoreBuilder.kt",
            replacements=[
                eol_comment_line(r"import\s+org\.mozilla\.fenix\.components\.toolbar\.BrowserToolbarTelemetryMiddleware"),
                eol_comment_text(r"BrowserToolbarTelemetryMiddleware\("),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/home/store/HomeToolbarStoreBuilder.kt",
            replacements=[
                eol_comment_line(r"import\s+org\.mozilla\.fenix\.home\.toolbar\.BrowserToolbarTelemetryMiddleware"),
                eol_comment_text(r"BrowserToolbarTelemetryMiddleware\(")
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/tabstray/TabsTrayFragment.kt",
            replacements=[
                eol_comment_text(r"TabsTrayTelemetryMiddleware\(")
            ]  
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/tabstray/ui/TabManagementFragment.kt",
            replacements=[
                eol_comment_line(r"import\s+org\.mozilla\.fenix\.tabstray\.TabsTrayTelemetryMiddleware"),
                eol_comment_text(r"TabsTrayTelemetryMiddleware\(")
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/webcompat/di/WebCompatReporterMiddlewareProvider.kt",
            replacements=[
                eol_comment_line(r"import\s+org\.mozilla\.fenix\.webcompat\.middleware\.WebCompatReporterTelemetryMiddleware"),
                eol_comment_text(r"private fun provideTelemetryMiddleware"),
                eol_comment_text(r"provideTelemetryMiddleware\("),
                eol_comment_text(r"WebCompatReporterTelemetryMiddleware\("),
            ],
        ),
        
        # Ensure application shortcuts, when clicked, resolve to IronFox instead of Firefox
        *_process_file(
            path="app/src/release/res/xml/shortcuts.xml",
            replacements=[
                # Change target package in shortcuts
                on_line_text(
                    match_lines=r"android:targetPackage",
                    on_text="org.mozilla.firefox",
                    replace=config.app_config.package_name,
                )
            ],
        ),
        
        # Remove SpashScreen style
        *_process_file(
            path="app/src/main/res/values-v27/styles.xml",
            replacements=[
                regex(r".*SplashScreen.*(?:\n.*){0,5}", ""),
            ]
        ),
        
        # Fenix uses reflection to create a instance of profile based on the text of
        # the label, see app/src/main/java/org/mozilla/fenix/perf/ProfilerStartDialogFragment.kt#185
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/perf/ProfilerUtils.kt",
            replacements=[
                on_line_text(match_lines=r'Firefox\(.*, .*\)', on_text=r'Firefox', replace='IronFox'),
                literal("firefox_threads", "ironfox_threads"),
                literal("firefox_features", "ironfox_features"),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/perf/ProfilerStartDialogFragment.kt",
            replacements=[
                literal(
                    old_text="ProfilerSettings.Firefox",
                    new_text="ProfilerSettings.IronFox",
                )      
            ]
        ),
        
        # No-op Glean
        *_process_file(
            path="app/pings.yaml",
            replacements=[
                regex(r"include_client_id: .*", "include_client_id: false"),
                regex(r"send_if_empty: .*", "send_if_empty: false"),
            ],
        ),
        
        # Remove proprietary/tracking libraries
        *_process_file(
            path=".buildconfig.yml",
            replacements=[
                line_affix("- components:service-mars", prefix="#"),
                line_affix("- components:service-glean", prefix="#"),
            ],
        ),
        
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/downloads/listscreen/di/DownloadUIMiddlewareProvider.kt",
            replacements=[
                line_affix(
                    r"^\s*import org\.mozilla\.fenix\.downloads\.listscreen\.middleware\.DownloadTelemetryMiddleware",
                    prefix="// ",
                ),
                line_affix(
                    r"private fun provideTelemetryMiddleware",
                    prefix="// ",
                ),
                line_affix(
                    r"provideTelemetryMiddleware\(",
                    prefix="// ",
                ),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/bookmarks/BookmarkFragment.kt",
            replacements=[
                line_affix(
                    r"^\s*import org\.mozilla\.fenix\.library\.bookmarks\.ui\.BookmarksTelemetryMiddleware",
                    prefix="// ",
                ),
                line_affix(
                    r"BookmarksTelemetryMiddleware\(",
                    prefix="// ",
                ),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/reviewprompt/CustomReviewPromptBottomSheetFragment.kt",
            replacements=[
                line_affix(
                    r"CustomReviewPromptTelemetryMiddleware\(",
                    prefix="// ",
                ),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/share/SaveToPDFMiddleware.kt",
            replacements=[
                line_affix(
                    r"^\s*import org\.mozilla\.fenix\.ext\.recordEventInNimbus",
                    prefix="// ",
                ),
                line_affix(
                    "context.recordEventInNimbus",
                    prefix="// ",
                ),
            ],
        ),
        
        # No-op Nimbus (Experimentation)
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/utils/Settings.kt",
            replacements=[
                line_affix(
                    match_lines="FxNimbus.features.junoOnboarding.recordExposure",
                    prefix="//"
                )
            ]
        ),
        
        # Fix missing icons
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/components/menu/compose/MenuItem.kt",
            replacements=[
                literal("googleg_standard_color_18", "ic_download"),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/compose/list/ListItem.kt",
            replacements=[
                literal("googleg_standard_color_18", "ic_download"),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/microsurvey/ui/MicrosurveyCompleted.kt",
            replacements=[
                literal("R.drawable.microsurvey_success", "R.drawable.fox_alert_crash_dark"),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/onboarding/redesign/view/OnboardingScreenRedesign.kt",
            replacements=[
                literal("R.drawable.ic_onboarding_sync", "R.drawable.fox_alert_crash_dark"),
            ],
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/fenix/onboarding/view/OnboardingScreen.kt",
            replacements=[
                literal("R.drawable.ic_onboarding_sync", "R.drawable.fox_alert_crash_dark"),
            ],
        ),
        *_process_file(
            path="app/onboarding.fml.yaml",
            replacements=[
                literal("ic_onboarding_search_widget", "fox_alert_crash_dark"),
                literal("ic_onboarding_sync", "fox_alert_crash_dark"),
            ],
        ),
        
        # De-Glean
        *deglean(d, paths.fenix_dir / "app/src/main/java/org/mozilla/gecko"),
        *_process_file(
            path="**/*.gradle",
            replacements=[
                eol_comment_line(r'.*implementation.*service-glean.*$'),
                eol_comment_line(r'.*testImplementation.*glean.*$'),
            ]
        ),
        *_process_file(
            path="app/src/main/java/org/mozilla/gecko/search/SearchWidgetProvider.kt",
            replacements=[
                eol_comment_text("Metrics"),
            ],
        ),
        *_rm("app/src/main/java/org/mozilla/fenix/ext/Configuration.kt"),
        *_rm("app/src/main/java/org/mozilla/fenix/components/metrics/GleanMetricsService.kt"),
        *_rm("app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReporting.kt"),
        *_rm("app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingApi.kt"),
        *_rm("app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingLifecycleObserver.kt"),
        *_rm("app/src/main/java/org/mozilla/fenix/components/metrics/GleanUsageReportingMetricsService.kt"),
        
        # Apply overlay
        d.overlay(
            name="Apply Fenix overlays",
            source_dir=paths.patches_dir / "fenix-overlay",
            target_dir=paths.fenix_dir,
        )
        # fmt:on
    ]


def _gecko_provider_kt_replacements():
    return _process_file(
        path="app/src/*/java/org/mozilla/fenix/*/GeckoProvider.kt",
        replacements=[
            # fmt:off
            
            # Disable crash handler
            line_affix(r"\.crashHandler", prefix="// "),
            line_affix(
                r"import\s*mozilla\.components\.lib\.crash",
                prefix="// ",
            ),
            line_affix(
                r"import\s*mozilla\.components\.browser\.engine\.gecko\.crash\.GeckoCrashPullDelegate",
                prefix="// ",
            ),
            
            # Ensure certain preferences are configured at GeckoProvider.kt
            ## These should be unnecessary (since we take back control of the related Gecko preferences and set them directly),
            ## but it doesn't hurt to set these here either
            regex(r"aboutConfigEnabled\(.*\)", "aboutConfigEnabled(true)"),
            regex(r"crashPullNeverShowAgain\(.*\)", "crashPullNeverShowAgain(true)"),
            regex(r"disableShip\(.*\)", "disableShip(false)"),
            regex(r"extensionsWebAPIEnabled\(.*\)", "extensionsWebAPIEnabled(false)"),
            regex(r"fissionEnabled\(.*\)", "fissionEnabled(true)"),
            
            # No-op Nimbus
            literal(".experimentDelegate", "// .experimentDelegate"),
            line_affix(
                r"import mozilla\.components\.experiment\.NimbusExperimentDelegate",
                prefix="// ",
            ),
            # fmt:on
        ],
    )


def _build_gradle_replacements(config: PrepareConfig):
    return _process_file(
        path="app/build.gradle",
        replacements=[
            # fmt:off
            
            # Change applicationId and suffix
            literal('applicationId "org.mozilla"', f'applicationId "{config.app_config.app_id_base}"'),
            literal(
                'applicationIdSuffix ".firefox"',
                f'applicationIdSuffix ".{config.app_config.app_id}"',
            ),
            
            # Update sharedUserId
            literal(
                '"sharedUserId": "org.mozilla.firefox.sharedID"',
                f'"sharedUserId": "{config.app_config.package_name}.sharedID"|',
            ),
            
            # Replace version name with IRONFOX_VERSION
            literal(
                "Config.releaseVersionName(project)",
                f'"{Versions.IRONFOX_VERSION}"',
            ),
            
            # Set MOZILLA_OFFICIAL = true (line-based replacement)
            on_line_text(r"MOZILLA_OFFICIAL", r"false", "true"),
            
            # Disable crash reporting flag: true -> false
            on_line_text(r"CRASH_REPORTING", r"true", "false"),
            
            # Disable TELEMETRY flag: true -> false
            on_line_text(r"TELEMETRY", r"true", "false"),
            
            # Comment out Adjust / installreferrer / Play dependencies in Gradle
            # (prefix the matching implementation line with // )
            line_affix(r"implementation\(libs\.adjust\)", prefix="// "),
            line_affix(r"implementation\(libs\.installreferrer\)", prefix="// "),
            line_affix(r"implementation\s+libs\.play", prefix="// "),
            
            # Remove literal occurrences of the addons services URL (exact literal)
            literal("https://services.addons.mozilla.org", ""),
            
            # Remove literal label 'Extensions-for-Android' if present
            literal("Extensions-for-Android", ""),
            
            # Blank-out AMO_* config values in gradle-like assignment forms
            # Examples handled:
            #   AMO_COLLECTION_NAME = "something"   OR   AMO_COLLECTION_NAME: "something"
            regex(r'(AMO_COLLECTION_NAME\s*[:=]\s*")[^"]*(")', r"\1\2"),
            regex(r'(AMO_COLLECTION_USER\s*[:=]\s*")[^"]*(")', r"\1\2"),
            regex(r'(AMO_SERVER_URL\s*[:=]\s*")[^"]*(")', r"\1\2"),
            
            # Comment out service-mars dependency
            line_affix(
                r"implementation project\(':components:service-mars'\)",
                prefix="// ",
            ),
            
            # Update message indicating whether telemetry is enabled or not
            regex(r'Telemetry enabled: " \+ .*\)', 'Telemetry enabled: " + false)'),
            
            # Update included CPU ABIs
            regex(r'include ".*"', f'include {config.abis}')
            # fmt:on
        ],
    )


def _feature_flags_kt_replacements():
    return _process_file(
        path="app/src/*/java/org/mozilla/fenix/FeatureFlags.kt",
        replacements=[
            # fmt:off
            
            # Disable telemetry
            regex(r"META_ATTRIBUTION_ENABLED = .*", "META_ATTRIBUTION_ENABLED = false"),
            
            # Disable Pocket "Discover More Stories"
            regex(r"DISCOVER_MORE_STORIES = .*", "DISCOVER_MORE_STORIES = false"),
            
            # Show live downloads in progress
            regex(r"showLiveDownloads = .*", "showLiveDownloads = true"),
            
            # Disable "custom review pre-prompts"
            regex(
                r"CUSTOM_REVIEW_PROMPT_ENABLED = .*",
                "CUSTOM_REVIEW_PROMPT_ENABLED = false",
            ),
            
            # Disable the ability for users to select a custom app icon
            ## We currently don't add any custom icons to choose from, so no point exposing/cluttering the UI
            regex(
                r"alternativeAppIconFeatureEnabled = .*",
                "alternativeAppIconFeatureEnabled = false",
            ),
            
            # Ensure onboarding is always enabled
            regex(r"onboardingFeatureEnabled = .*", "onboardingFeatureEnabled = true"),
            
            # No-op AMO collections/recommendations
            regex(
                r"customExtensionCollectionFeature = .*",
                "customExtensionCollectionFeature = false",
            ),
            # fmt:on
        ],
    )


def _android_manifest_xml_replacements():
    return _process_file(
        path="app/src/*/AndroidManifest.xml",
        replacements=[
            # fmt:off
            
            # Wrap the preinstall permission in an HTML comment
            line_affix(
                r'<uses-permission\s+android:name="com.adjust.preinstall.READ_PERMISSION"\s*/>',
                prefix="<!-- ",
                suffix=" -->",
            ),
            
            # Comment out application/receiver/service metadata that references Adjust or installreferrer
            line_affix(
                r'android:name="com.adjust.sdk.Adjust"', prefix="<!-- ", suffix=" -->"
            ),
            line_affix(
                r'android:name="com.android.installreferrer"',
                prefix="<!-- ",
                suffix=" -->",
            ),
            
            # Remove roundIcon attribute
            on_line_text(match_lines=r"android:roundIcon", on_text=r".*", replace=""),
            # fmt:on
        ],
    )


def _support_utils_kt_replacements():
    return _process_file(
        path="app/src/main/java/org/mozilla/fenix/settings/SupportUtils.kt",
        replacements=[
            # fmt:off
            
            # Remove URLs redirecting to Google
            regex(r'GOOGLE_URL = ".*"', r'GOOGLE_URL = ""'),
            regex(r'GOOGLE_US_URL = ".*"', r'GOOGLE_US_URL = ""'),
            regex(r'GOOGLE_XX_URL = ".*"', r'GOOGLE_XX_URL = ""'),
            
            # Change URL for "What's New" to point to IronFox changelogs
            regex(
                r'WHATS_NEW_URL = ".*"',
                r'WHATS_NEW_URL = "https://gitlab.com/ironfox-oss/IronFox/-/releases"',
            ),
            regex(
                r"https://www\.mozilla\.org/firefox/android/notes",
                r"https://gitlab.com/ironfox-oss/IronFox/-/releases",
            ),
            # fmt:on
        ],
    )


def _strings_xml_replacements(config: PrepareConfig):
    app = config.app_config
    return _process_file(
        path="app/src/*/res/values*/*strings.xml",
        replacements=[
            # fmt:off
            
            # Let it be IronFox!
            
            literal(
                "Notifications help you stay safer with Firefox", "Enable notifications"
            ),
            literal(
                "Securely send tabs between your devices and discover other privacy features in Firefox.",
                f"{app.browser_name} can remind you when private tabs are open and show you the progress of file downloads.",
            ),
            literal("Agree and continue", "Continue"),
            literal("Address bar - Firefox Suggest", "Address bar"),
            literal("Firefox Daylight", app.app_name),
            literal("Firefox Fenix", app.app_name),
            literal("Mozilla Firefox", app.app_name),
            literal("Firefox", app.app_name),
            on_line_text(
                match_lines=r"about_content", on_text=r"Mozilla", replace=app.vendor
            ),
            literal(f"{app.app_name} Suggest", "Firefox Suggest"),
            literal(
                "Learn more about Firefox Suggest",
                "Learn more about search suggestions",
            ),
            literal("Suggestions from %1$s", "Suggestions from Mozilla"),
            literal(
                "Notifications for tabs received from other IronFox devices",
                "Notifications for tabs received from other devices",
            ),
            literal(
                f"To send a tab, sign in to {app.app_name}",
                "To send a tab, sign in to a Firefox-based web browser",
            ),
            literal(
                f"On your computer open {app.app_name} and",
                "On your computer, open a Firefox-based web browser, and",
            ),
            literal(
                "Fast and secure web browsing",
                "The private, secure, user first web browser for Android.",
            ),
            literal("Sync is on", "Firefox Sync is on"),
            literal("No account?", "No Firefox account?"),
            literal(f"to sync {app.app_name}", "to sync your browsing data"),
            literal(
                "%s will stop syncing with your account",
                "%s will stop syncing with your Firefox account",
            ),
            literal(
                "%1$s decides when to use secure DNS to protect your privacy",
                f"{app.app_name} will use your system’s DNS resolver",
            ),
            literal(
                "Use your default DNS resolver if there is a problem with the secure DNS provider",
                "Use your default DNS resolver",
            ),
            literal(
                "You control when to use secure DNS and choose your provider",
                f"{app.app_name} will use secure DNS with your chosen provider by default, but might fallback to your system’s DNS resolver if secure DNS is unavailable",
            ),
            on_line_text(
                match_lines=r"preference_doh_off_summary",
                on_text=r"Use your default DNS resolver",
                replace="Never use secure DNS, even if supported by your system’s DNS resolver",
            ),
            literal("Learn more about sync", "Learn more about Firefox Sync"),
            literal(
                f"You don’t have any tabs open in {app.app_name} on your other devices",
                "You don’t have any tabs open on your other devices",
            ),
            literal("Google Search", "Google search"),
            
            # Remove client identifier
            regex(r"search\?client=firefox&amp;q=%s", r"search?q=%s"),
            # fmt:on
        ],
    )


def _home_activity_kt_replacements():
    return _process_file(
        path="app/src/main/java/org/mozilla/fenix/HomeActivity.kt",
        replacements=[
            # fmt:off
            
            # Remove telemetry
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.components\.metrics\.fonts",
                prefix="// ",
            ),
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.components\.metrics\.GrowthDataWorker",
                prefix="// ",
            ),
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.components\.metrics\.MarketingAttributionService",
                prefix="// ",
            ),
            literal("FontEnumerationWorker.", "// FontEnumerationWorker."),
            literal("GrowthDataWorker.", "// GrowthDataWorker."),
            literal("MarketingAttributionService(", "// MarketingAttributionService("),
            literal(
                "ReEngagementNotificationWorker.", "// ReEngagementNotificationWorker."
            ),
            # fmt:on
        ],
    )


def _context_kt_replacements():
    return _process_file(
        path="app/src/main/java/org/mozilla/fenix/ext/Context.kt",
        replacements=[
            # Remove telemetry
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.components\.metrics", prefix="// "
            ),
            literal("val Context.metrics", "// val Context.metrics"),
            literal(
                "get() = this.components.analytics",
                "// get() = this.components.analytics",
            ),
        ],
    )


def _components_kt_replacements():
    return _process_file(
        path="app/src/main/java/org/mozilla/fenix/components/Components.kt",
        replacements=[
            # Remove telemetry
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.components\.metrics", prefix="// "
            ),
            literal("MetricsMiddleware(", "// MetricsMiddleware("),
            literal(
                "manager = ReviewManagerFactory", "// manager = ReviewManagerFactory"
            ),
            regex(
                r"val push by lazyMonitored \{ Push\(context, analytics\.crashReporter\) \}",
                r"val push by lazyMonitored { Push(context) }",
            ),
            line_affix(
                r"^\s*import com\.google\.android\.play\.core\.review", prefix="// "
            ),
        ],
    )


def _core_kt_replacements():
    return _process_file(
        path="app/src/main/java/org/mozilla/fenix/components/Core.kt",
        replacements=[
            # Remove telemetry
            line_affix(
                r"^\s*import mozilla\.components\.feature\.search\.middleware\.AdsTelemetryMiddleware",
                prefix="// ",
            ),
            line_affix(
                r"^\s*import mozilla\.components\.feature\.search\.telemetry",
                prefix="// ",
            ),
            line_affix(r"^\s*import org\.mozilla\.fenix\.telemetry", prefix="// "),
            line_affix("AdsTelemetryMiddleware", prefix="// "),
            line_affix(r"TelemetryMiddleware\(context.*\)", prefix="// "),
            line_affix(r"TelemetryMiddleware\(context.*\)", r"// "),
            literal("search-telemetry-v2", ""),
        ],
    )


def _fenix_application_kt_replacements():
    return _process_file(
        path="app/src/main/java/org/mozilla/fenix/FenixApplication.kt",
        replacements=[
            line_affix(
                r"^\s*import androidx\.core\.app\.NotificationManagerCompat",
                prefix="// ",
            ),
            line_affix(
                r"^\s*import mozilla\.components\.support\.base\.ext\.areNotificationsEnabledSafe",
                prefix="// ",
            ),
            line_affix(
                r"^\s*import mozilla\.components\.support\.base\.ext\.isNotificationChannelEnabled",
                prefix="// ",
            ),
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.components\.metrics", prefix="// "
            ),
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.onboarding\.MARKETING_CHANNEL_ID",
                prefix="// ",
            ),
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.perf\.ApplicationExitInfoMetrics",
                prefix="// ",
            ),
            line_affix(
                r"^\s*import org\.mozilla\.fenix\.perf\.StorageStatsMetrics",
                prefix="// ",
            ),
            literal("ApplicationExitInfoMetrics.", "// ApplicationExitInfoMetrics."),
            literal("PerfStartup.", "// PerfStartup."),
            literal("StorageStatsMetrics.", "// StorageStatsMetrics."),
            literal(
                "components.analytics.metricsStorage",
                "// components.analytics.metricsStorage",
            ),
            regex(
                r"components.analytics.metricsStorage",
                r"// components.analytics.metricsStorage",
            ),
            regex(r"StorageStatsMetrics\.", r"// StorageStatsMetrics."),
            regex(r"ApplicationExitInfoMetrics\.", r"// ApplicationExitInfoMetrics."),
        ],
    )
