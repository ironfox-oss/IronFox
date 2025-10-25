from typing import List
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition
from execution.find_replace import comment_out, literal, regex
from execution.types import ReplacementAction


def prepare_application_services(
    d: BuildDefinition, paths: Paths
) -> List[TaskDefinition]:
    def _process_file(
        path: str,
        replacements: List[ReplacementAction],
    ) -> List[TaskDefinition]:
        return d.find_replace(
            name=f"Process {path}",
            target_file=paths.application_services_dir / path,
            replacements=replacements,
        )

    def _rm(
        path: str,
        recursive: bool = False,
    ) -> List[TaskDefinition]:
        return d.delete(
            name=f"Delete {path}",
            path=paths.application_services_dir / path,
            recursive=recursive,
        )

    def _mkdirs(
        path: str,
        parents: bool = True,
        exist_ok: bool = True,
    ) -> TaskDefinition:
        return d.mkdir(
            name=f"Create directory {path}",
            target=paths.application_services_dir / path,
            parents=parents,
            exist_ok=exist_ok,
        )

    return [
        # fmt:off
        
        # TODO: Apply patches
        
        *_rm("components/remote_settings/dumps/*/attachments/search-config-icons/*", recursive=True),
        *_rm("components/remote_settings/dumps/*/search-telemetry-v2.json"),
        
        # Break dependency on older A-C
        *_process_file(
            path="gradle/libs.versions.toml",
            replacements=[
                regex(r"^android-components = \"", f'android-components = "{Versions.FIREFOX_VERSION}"')
            ]
        ),
        
        # Break dependency on older Rust
        *_process_file(
            path="rust-toolchain.toml",
            replacements=[
                regex(r"channel = .*", f'channel = "{Versions.RUST_VERSION}"')
            ]
        ),
        
        # Disable debug
        *_process_file(
            path="Cargo.toml",
            replacements=[
                regex(r"debug = .*", 'debug = false')
            ]
        ),
        
        # TODO: Localize maven
        
        # Remove line following mavenLocal block in Gradle config
        *_process_file(
            path="tools/nimbus-gradle-plugin/build.gradle",
            replacements=[
                regex(r'^    mavenLocal\s*\n.*\n?', r''),
            ],
        ),

        
        # Fail on use of pre-built binary
        *_process_file(
            path="Cargo.toml",
            replacements=[
                literal("https://", 'hxxps://')
            ]
        ),
        
        # No-op Nimbus (Experimentation)
        *_process_file(
            path="components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusBuilder.kt",
            replacements=[
                regex(
                    pattern=r"NimbusInterface.isLocalBuild() = .*",
                    replacement="NimbusInterface.isLocalBuild() = true"
                ),
                regex(
                    pattern=r"isFetchEnabled(): Boolean = .*",
                    replacement="isFetchEnabled(): Boolean = false"
                ),
            ]
        ),
        *_process_file(
            path="components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/NimbusInterface.kt",
            replacements=[
                regex(
                    pattern=r"isFetchEnabled(): Boolean = .*",
                    replacement="isFetchEnabled(): Boolean = false"
                ),
            ]
        ),
        *_process_file(
            path="components/nimbus/android/src/main/java/org/mozilla/experiments/nimbus/Nimbus.kt",
            replacements=[
                regex(
                    pattern=r'EXPERIMENT_COLLECTION_NAME = ".*"',
                    replacement='EXPERIMENT_COLLECTION_NAME = ""',
                ),
                literal("nimbus-mobile-experiments", ""),
            ]
        ),
        
        
        # Remove the 'search telemetry' config
        *_process_file(
            path="components/remote_settings/src/client.rs",
            replacements=[
                comment_out('("main", "search-telemetry-v2"),'),
            ]
        ),
        
        # Apply a-s overlay
        d.overlay(
            name="Apply application-services overlay",
            source_dir=paths.patches_dir / "a-s-overlay",
            target_dir=paths.application_services_dir,
        )
        # fmt:on
    ]
