from pathlib import Path
from types import MethodType
from typing import List
from commands.prepare import PrepareConfig
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition
from execution.find_replace import line_affix, literal, on_line_text, regex
from execution.types import ReplacementAction
from steps.common.java import setup_java

from .android_components import prepare_android_components
from .application_services import prepare_application_services
from .fenix import prepare_fenix
from .glean import prepare_glean


def _require_dir_exists(dir: Path):
    if not dir.exists() or not dir.is_dir():
        raise RuntimeError(f"{dir} does not exist or is not a directory!")


def get_definition(config: PrepareConfig, paths: Paths) -> BuildDefinition:
    d = BuildDefinition("Prepare")

    paths.build_dir.mkdir(parents=True, exist_ok=True)

    _require_dir_exists(paths.android_home)
    _require_dir_exists(paths.ndk_home)
    _require_dir_exists(paths.ndk_toolchain_dir)
    _require_dir_exists(paths.libclang_dir)
    _require_dir_exists(paths.java_home)
    _require_dir_exists(paths.cargo_home)

    # fmt:off
    d.chain(
        setup_java(d, paths),
    ).then(  # type: ignore
           
        # Android Components
        *prepare_android_components(d, paths),
           
        # Fenix
        *prepare_fenix(d, paths, config),
        
        # Glean
        *prepare_glean(d, paths),
        
        # Application services
        *prepare_application_services(d, paths),
    )
    # fmt:on

    return d
