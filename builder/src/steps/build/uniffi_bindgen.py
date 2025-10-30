from typing import List
from commands.build import BuildConfig
from common.paths import Paths
from execution.definition import BuildDefinition, TaskDefinition


def build_uniffi(
    d: BuildDefinition,
    config: BuildConfig,
    paths: Paths,
) -> List[TaskDefinition]:
    cargo = paths.cargo_home / "bin/cargo"
    return [
        d.run_commands(
            name="Build uniffi-bindgen",
            commands=[f"{cargo} build --release"],
            cwd=paths.uniffi_dir,
        )
    ]
