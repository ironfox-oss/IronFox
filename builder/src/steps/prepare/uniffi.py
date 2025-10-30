from typing import List
from commands.prepare import PrepareConfig
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition
from execution.find_replace import regex


def prepare_uniffi(
    d: BuildDefinition,
    paths: Paths,
    config: PrepareConfig,
) -> List[TaskDefinition]:
    return [
        # fmt:off

        # Break the dependency on older Rust
        *d.find_replace(
            name="# Break dependency on older Rust",
            target_files=paths.uniffi_dir / "rust-toolchain.toml",
            replacements=[
                regex(r'(channel\s*=\s*).*', rf'\1"{Versions.RUST_VERSION}"')
            ]
        ),
        # fmt:on
    ]
