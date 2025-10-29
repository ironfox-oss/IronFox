from typing import List
from commands.prepare import PrepareConfig
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition
from execution.find_replace import regex


def prepare_wasi_sdk(
    d: BuildDefinition,
    paths: Paths,
    config: PrepareConfig,
) -> List[TaskDefinition]:
    return [
        # fmt:off

        # Apply Wasi-SDK patches from Firefox
        d.patch(
            name="Apply Firefox patches to Wasi SDK",
            patch_file=paths.firefox_dir / "taskcluster/scripts/misc/wasi-sdk.patch",
            target_dir=paths.wasi_sdk_dir,
        ),

        # Break dependency on older CMake
        *d.find_replace(
            name="Break dependency on older CMake",
            target_files=paths.wasi_sdk_dir / "wasi-sdk.cmake",
            replacements=[
                regex(r'(cmake_minimum_required\(VERSION\s+).*(\))', r'\1' + Versions.WASI_CMAKE_VERSION + r'\2')
            ]
        ),
        # fmt:on
    ]
