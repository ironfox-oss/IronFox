from typing import List
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition

from execution.find_replace import line_affix, literal, on_line_text, regex
from execution.types import ReplacementAction

from .deglean import deglean


def prepare_android_components(
    d: BuildDefinition, paths: Paths
) -> List[TaskDefinition]:
    def _process_file(
        path: str,
        replacements: List[ReplacementAction],
    ) -> List[TaskDefinition]:
        return d.find_replace(
            name=f"Process {path}",
            target_files=paths.android_components_dir / path,
            replacements=replacements,
        )

    def _rm(
        path: str,
        recursive: bool = False,
    ) -> List[TaskDefinition]:
        return d.delete(
            name=f"Delete {path}",
            path=paths.android_components_dir / path,
            recursive=recursive,
        )

    return [
        # fmt:off
        
        # Remove default built-in search engines
        *_rm(
            path="components/feature/search/src/*/assets/searchplugins/*",
            recursive=True,
        ),
        
        # Nuke the "Mozilla Android Components - Ads Telemetry" and "Mozilla Android Components - Search Telemetry" extensions
        ## We don't install these with fenix-disable-telemetry.patch - so no need to keep the files around...
        *_rm(
            path="components/feature/search/src/*/assets/extensions/ads",
            recursive=True,
        ),
        *_rm(
            path="components/feature/search/src/*/assets/extensions/search",
            recursive=True,
        ),
        
        # We can also remove the directories/libraries themselves as well
        *_rm(path="components/feature/search/src/*/java/mozilla/components/feature/search/middleware/AdsTelemetryMiddleware.kt",),
        *_rm(
            path="components/feature/search/src/*/java/mozilla/components/feature/search/telemetry",
            recursive=True,
        ),
        
        # Remove the 'search telemetry' config
        *_rm(path="components/feature/search/src/*/assets/search/search_telemetry_v2.json",),
        
        # Since we remove the Glean Service and Web Compat Reporter dependencies, the existence of these files causes build issues
        ## We don't build or use these sample libraries at all anyways, so instead of patching these files, I don't see a reason why we shouldn't just delete them. 
        *_rm(path="samples/browser/build.gradle",),
        *_rm(path="samples/crash/build.gradle",),
        *_rm(path="samples/glean/build.gradle",),
        *_rm(path="samples/glean/samples-glean-library/build.gradle",),
        
        # Remove unnecessary crash reporting components
        *_rm("components/support/appservices/src/main/java/mozilla/components/support/rusterrors", recursive=True),
        
        # Remove unused crash reporting services/components
        *_rm("components/lib/crash/src/main/java/mozilla/components/lib/crash/MinidumpAnalyzer.kt"),
        *_rm("components/lib/crash/src/main/java/mozilla/components/lib/crash/service/MozillaSocorroService.kt"),
        
        # Prevent unsolicited favicon fetching
        *_process_file(
            path="components/browser/icons/src/main/java/mozilla/components/browser/icons/preparer/TippyTopIconPreparer.kt",
            replacements=[
                literal(
                    "request.copy(resources = request.resources + resource)",
                    "request",
                ),
            ],
        ),
        
        # Remove Nimbus
        *_rm(path="components/browser/engine-gecko/geckoview.fml.yaml",),
        *_rm(
            path="components/browser/engine-gecko/src/main/java/mozilla/components/experiment",
            recursive=True,
        ),
        *_process_file(
            path="components/service/nimbus/proguard-rules-consumer.pro",
            replacements=[
                line_affix(
                    r"^\s*-keep class mozilla\.components\.service\.nimbus",
                    prefix="#",
                ),
            ],
        ),
        
        # Pin SNAPSHOT version so that we always use locally published A-S
        *_process_file(
            path="plugins/dependencies/src/main/java/ApplicationServices.kt",
            replacements=[
                regex(r'(val\s+VERSION\s+=).*', r'\1 "0.0.1-SNAPSHOT-true"')
            ]
        ),

        # No-op AMO collections/recommendations
        *_process_file(
            path="components/feature/addons/src/*/java/mozilla/components/feature/addons/amo/AMOAddonsProvider.kt",
            replacements=[
                regex(r'DEFAULT_COLLECTION_NAME = ".*"', r'DEFAULT_COLLECTION_NAME = ""'),
                literal("7e8d6dc651b54ab385fb8791bf9dac", ""),
                regex(r'DEFAULT_COLLECTION_USER = ".*"', r'DEFAULT_COLLECTION_USER = ""'),
                regex(r'DEFAULT_SERVER_URL = ".*"', r'DEFAULT_SERVER_URL = ""'),
                literal("https://services.addons.mozilla.org", ""),
            ],
        ),
        
        # Configure CrashReporter defaults
        *_process_file(
            path="components/lib/crash/src/main/java/mozilla/components/lib/crash/CrashReporter.kt",
            replacements=[
                regex(r"enabled: Boolean = .*", r"enabled: Boolean = false,"),
                regex(r"shouldPrompt: Prompt = .*", r"shouldPrompt: Prompt = Prompt.ALWAYS,"),
                regex(r"useLegacyReporting: Boolean = .*", r"useLegacyReporting: Boolean = false,"),
                regex(r"var enabled: Boolean = false,", r"var enabled: Boolean = enabled"),
            ],
        ),

        # Disable SentryService caught exception reporting
        *_process_file(
            path="components/lib/crash-sentry/src/*/java/mozilla/components/lib/crash/sentry/SentryService.kt",
            replacements=[
                regex(r"sendCaughtExceptions: Boolean = .*", r"sendCaughtExceptions: Boolean = false,"),
            ],
        ),
        
        # No-op MARS
        *_process_file(
            path="components/service/pocket/src/*/java/mozilla/components/service/pocket/mars/api/MarsSpocsEndpointRaw.kt",
            replacements=[
                regex(r'MARS_ENDPOINT_BASE_URL = ".*"', r'MARS_ENDPOINT_BASE_URL = ""'),
                regex(r'MARS_ENDPOINT_STAGING_BASE_URL = ".*"', r'MARS_ENDPOINT_STAGING_BASE_URL = ""'),
            ],
        ),
        
        # No-op GeoIP/Region service
        ## https://searchfox.org/mozilla-release/source/toolkit/modules/docs/Region.rst
        *_process_file(
            path="components/service/location/src/*/java/mozilla/components/service/location/MozillaLocationService.kt",
            replacements=[
                regex(r'GEOIP_SERVICE_URL = ".*"', r'GEOIP_SERVICE_URL = ""'),
                regex(r'USER_AGENT = ".*', r'USER_AGENT = ""'),
            ],
        ),
        
        # No-op Pocket SPOCS endpoints
        *_process_file(
            path="components/service/pocket/src/*/java/mozilla/components/service/pocket/spocs/api/SpocsEndpointRaw.kt",
            replacements=[
                regex(r'SPOCS_ENDPOINT_DEV_BASE_URL = ".*"', r'SPOCS_ENDPOINT_DEV_BASE_URL = ""'),
                regex(r'SPOCS_ENDPOINT_PROD_BASE_URL = ".*"', r'SPOCS_ENDPOINT_PROD_BASE_URL = ""'),
            ],
        ),

        # No-op Pocket main endpoint
        *_process_file(
            path="components/service/pocket/src/*/java/mozilla/components/service/pocket/stories/api/PocketEndpointRaw.kt",
            replacements=[
                regex(r'POCKET_ENDPOINT_URL = ".*"', r'POCKET_ENDPOINT_URL = ""'),
            ],
        ),
        
        # No-op telemetry (GeckoView)
        *_process_file(
            path="components/browser/engine-gecko/build.gradle",
            replacements=[
                regex(r'allowMetricsFromAAR = .*', r'allowMetricsFromAAR = false'),
            ],
        ),
        
        # De-Glean
        *deglean(d, paths.android_components_dir),
        *_rm("components/service/glean", recursive=True),
        *_rm("samples/glean", recursive=True),
        *_rm("components/lib/crash/src/main/java/mozilla/components/lib/crash/service/GleanCrashReporterService.kt"),
        *_process_file(
            path="components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingController.kt",
            replacements=[
                literal("GleanMessaging", "// GleanMessaging"),
                literal("Microsurvey.confirmation", "// Microsurvey.confirmation"),
                literal("Microsurvey.dismiss", "// Microsurvey.dismiss"),
                literal("Microsurvey.privacy", "// Microsurvey.privacy"),
                literal("Microsurvey.shown", "// Microsurvey.shown"),
            ],
        ),
        *_process_file(
            path="components/service/nimbus/src/main/java/mozilla/components/service/nimbus/messaging/NimbusMessagingStorage.kt",
            replacements=[
                literal("GleanMessaging", "// GleanMessaging"),
            ],
        ),
        
        # Apply a-c overlay
        d.overlay(
            name="Apply a-c overlay",
            source_dir=paths.patches_dir / "a-c-overlay",
            target_dir=paths.android_components_dir,
        ),
        # fmt:on
    ]
