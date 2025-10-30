from pathlib import Path
from commands.base import BaseConfig
from commands.build import BuildConfig
from common.paths import Paths
from execution.definition import BuildDefinition
from steps.build.uniffi_bindgen import build_uniffi
from steps.build.wasi_sdk import build_wasi_sdk


def _require_dir_exists(dir: Path):
    if not dir.exists() or not dir.is_dir():
        raise RuntimeError(f"{dir} does not exist or is not a directory!")


async def get_definition(
    base: BaseConfig,
    config: BuildConfig,
    paths: Paths,
) -> BuildDefinition:
    d = BuildDefinition("Build")

    paths.build_dir.mkdir(parents=True, exist_ok=True)

    _require_dir_exists(paths.android_home)
    _require_dir_exists(paths.ndk_home)
    _require_dir_exists(paths.ndk_toolchain_dir)
    _require_dir_exists(paths.libclang_dir)
    _require_dir_exists(paths.java_home)
    _require_dir_exists(paths.cargo_home)

    d.parallel(
        # fmt:off
        
        # Build UniFFI bindgen
        *build_uniffi(d, config, paths),
        
        # fmt:on
    )

    return d
