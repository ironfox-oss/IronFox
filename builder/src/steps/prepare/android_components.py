from typing import List
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition

from execution.find_replace import line_affix, literal, on_line_text, regex
from execution.types import ReplacementAction


def prepare_android_components(d: BuildDefinition, paths: Paths) -> List[TaskDefinition]:
    def _process_file(
        path: str,
        replacements: List[ReplacementAction],
    ) -> List[TaskDefinition]:
        return d.find_replace(
            name=f"Process {path}",
            target_file=paths.android_components_dir / path,
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

    def _mkdirs(
        path: str,
        parents: bool = True,
        exist_ok: bool = True,
    ) -> TaskDefinition:
        return d.mkdir(
            name=f"Create directory {path}",
            target=paths.android_components_dir / path,
            parents=parents,
            exist_ok=exist_ok,
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
        
        # Apply a-c overlay
        d.overlay(
            name="Apply a-c overlay",
            source_dir=paths.patches_dir / "a-c-overlay",
            target_dir=paths.android_components_dir,
        ),
        # fmt:on
    ]
