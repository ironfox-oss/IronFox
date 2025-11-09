from typing import List
from commands.prepare import PrepareConfig
from common.paths import Paths
from common.utils import host_target
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition

from execution.find_replace import line_affix, on_line_text, regex
from execution.types import ReplacementAction


def prepare_glean(
    d: BuildDefinition, paths: Paths, config: PrepareConfig
) -> List[TaskDefinition]:
    def _process_file(
        path: str,
        replacements: List[ReplacementAction],
    ) -> List[TaskDefinition]:
        return d.find_replace(
            name=f"Process {path}",
            target_files=paths.glean_dir / path,
            replacements=replacements,
        )

    def _rm(
        path: str,
        recursive: bool = False,
    ) -> List[TaskDefinition]:
        return d.delete(
            name=f"Delete {path}", path=paths.glean_dir / path, recursive=recursive
        )

    rust_version = (
        regex(
            r"rust-version = .*",
            f'rust-version = "{Versions.RUST_MAJOR_VERSION}"',
        ),
    )

    metrics_disabled = regex(r"disabled: .*", "disabled: true,")

    return [
        # fmt:off
        
        d.write_file(
            name="Write local.properties",
            target=paths.glean_dir / "local.properties",
            contents=lambda: f'''
rust.targets={host_target()},{config.rusttarget}
            '''.encode(),
            append=True,
        ),
        
        # Apply patches
        d.patch(
            name="Apply Glean patches",
            patch_file=paths.patches_dir / "glean-patches.yaml",
            target_dir=paths.glean_dir,
        ),
        
        # Local maven repos
        *d.localize_maven(
            name="Localize Glean",
            target_file=f"{paths.glean_dir}/**/*.gradle",
        ),
        
        # Overwrite Gradle wrapper scripts
        *d.write_files(
            name="Overwrite gradlew scripts",
            targets=f"{paths.glean_dir}/**/gradlew",
            contents=lambda: b'#!/bin/sh\ngradle "$@"',
            overwrite=True,
            append=False,
            chmod=755,
        ),
        
        # Break dependency on older Rust
        *_process_file(
            path="glean-core/Cargo.toml",
            replacements=[*rust_version]
        ),
        *_process_file(
            path="glean-core/build/Cargo.toml",
            replacements=[*rust_version]
        ),
        *_process_file(
            path="glean-core/rlb/Cargo.toml",
            replacements=[*rust_version]
        ),

        # No-op Glean
        *_process_file(
            path="glean-core/android/build.gradle",
            replacements=[
                regex(r"allowGleanInternal = .*", r"allowGleanInternal = false"),
                line_affix(r'"\$rootDir/glean-core/android/metrics.yaml"', prefix="// "),

                # Use Tor's no-op UniFFi binding generator
                regex(r"commandLine 'cargo', 'uniffi-bindgen'", f"commandLine '{paths.uniffi_dir}/target/release/uniffi-bindgen'"),
            ],
        ),
        *_process_file(
            path="glean-core/python/glean/config.py",
            replacements=[
                regex(r'DEFAULT_TELEMETRY_ENDPOINT = ".*"', r'DEFAULT_TELEMETRY_ENDPOINT = ""'),
                on_line_text(match_lines=r"enable_internal_pings:", on_text=r"true", replace="false"),
            ],
        ),
        *_process_file(
            path="glean-core/rlb/src/configuration.rs",
            replacements=[
                regex(r"DEFAULT_GLEAN_ENDPOINT: .*", r'DEFAULT_GLEAN_ENDPOINT: \&str = \"\";'),
                on_line_text(match_lines=r"enable_internal_pings:", on_text=r"true", replace="false"),
            ],
        ),
        *_process_file(
            path="glean-core/android/src/main/java/mozilla/telemetry/glean/config/Configuration.kt",
            replacements=[
                regex(r'DEFAULT_TELEMETRY_ENDPOINT = ".*"', r'DEFAULT_TELEMETRY_ENDPOINT = ""'),
                on_line_text(match_lines=r"enableInternalPings:", on_text=r"true", replace="false"),
                on_line_text(match_lines=r"enableEventTimestamps:", on_text=r"true", replace="false"),
            ],
        ),
        *_process_file(
            path="glean-core/src/core_metrics.rs",
            replacements=[metrics_disabled],
        ),
        *_process_file(
            path="glean-core/src/glean_metrics.rs",
            replacements=[metrics_disabled],
        ),
        *_process_file(
            path="glean-core/src/internal_metrics.rs",
            replacements=[metrics_disabled],
        ),
        *_process_file(
            path="glean-core/src/lib_unit_tests.rs",
            replacements=[metrics_disabled],
        ),
        *_process_file(
            path="glean-core/pings.yaml",
            replacements=[
                regex(r"include_client_id: .*", r"include_client_id: false"),
                regex(r"send_if_empty: .*", r"send_if_empty: false"),
            ],
        ),
        *_rm(path="glean-core/android/metrics.yaml"),
        
        # Ensure we're building for release
        *_process_file(
            path="build.gradle",
            replacements=[
                regex(r"ext.cargoProfile = .*", r'ext.cargoProfile = "release"'),
            ],
        ),
        
        # Apply Glean overlay
        d.overlay(
            name="Apply Glean overlay",
            source_dir=paths.patches_dir / "glean-overlay",
            target_dir=paths.glean_dir,
        )
        # fmt:on
    ]
