from pathlib import Path
from commands.prepare import PrepareConfig
from common.paths import Paths
from execution.definition import BuildDefinition
from steps.common.java import setup_java

from .android_components import prepare_android_components
from .application_services import prepare_application_services
from .fenix import prepare_fenix
from .glean import prepare_glean
from .firefox import prepare_firefox


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
    ).then(
        
        # Use d.chain(...) such that each component's prepare tasks run
        # in the sequence their defined sequence
        
        # The then(...) call in combination with chain(...) will ensure
        # all components are set up in parallel while the individual preparation
        # tasks of each component are sequential
        
        # Android Components
        d.chain(*prepare_android_components(d, paths)),

        # Fenix
        d.chain(*prepare_fenix(d, paths, config)),

        # Glean
        d.chain(*prepare_glean(d, paths, config)),

        # Application services
        d.chain(*prepare_application_services(d, paths)),

        # Firefox
        d.chain(*prepare_firefox(d, paths, config)),
    )
    # fmt:on

    return d
