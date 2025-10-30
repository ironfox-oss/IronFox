from typing import List
from commands.base import BaseConfig
from commands.build import BuildConfig
from common.paths import Paths
from execution.definition import BuildDefinition, TaskDefinition


def build_wasi_sdk(
    d: BuildDefinition,
    base: BaseConfig,
    config: BuildConfig,
    paths: Paths,
) -> List[TaskDefinition]:
    return [
        # fmt:off
        
        # Create install dir
        d.mkdir(
            name="Make build/install dir",
            target=paths.wasi_sdk_dir / "build/install/wasi",
            parents=True,
            exist_ok=True,
        ),
        
        # Let the build system think that compiler-rt is already built
        d.write_file(
            name="Touch build/compiler-rt.BUILT",
            target=paths.wasi_sdk_dir / "build/compiler-rt.BUILT",
            contents=lambda: b'',
            append=True,
            overwrite=False,
        ),
        
        # Build Wasi SDK
        d.run_commands(
            name="Build Wasi SDK",
            commands=[str(config.exec_make), 'PREFIX=/wasi', 'build/wasi-libc.BUILT', 'build/libcxx.BUILD', f'-j{base.jobs}'],
            cwd=paths.wasi_sdk_dir,
        )
        # fmt:on
    ]
