import logging
from pathlib import Path
from typing import List, Tuple
from commands.base import BaseConfig
from commands.prepare import PrepareConfig
from common.paths import Paths
from execution.definition import BuildDefinition
from execution.parallel import TaskType, parallel_map
from rich.progress import Progress
from steps.common.java import setup_java

from .android_components import prepare_android_components
from .application_services import prepare_application_services
from .fenix import prepare_fenix
from .glean import prepare_glean
from .firefox import prepare_firefox
from .noop_moz_endpoints import get_moz_endpoints, noop_moz_endpoints
from .wasi_sdk import prepare_wasi_sdk

logger = logging.getLogger("prepare")


def _require_dir_exists(dir: Path):
    if not dir.exists() or not dir.is_dir():
        raise RuntimeError(f"{dir} does not exist or is not a directory!")


async def get_definition(
    base: BaseConfig, config: PrepareConfig, paths: Paths
) -> BuildDefinition:
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
        # in the sequence they are defined
        
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

        # Wasi-SDK
        d.chain(*prepare_wasi_sdk(d, paths, config)),
    )
    # fmt:on

    # No-op Mozilla endpoints
    with Progress(transient=False) as progress:
        items = get_moz_endpoints(paths)

        async def action(params: Tuple[Path, List[str]]) -> None:
            dir, endpoints = params
            root_parts = dir.relative_to(paths.root_dir).parts
            task_name = (
                f"Remove endpoints: {''.join(root_parts[:min(2, len(root_parts))])}"
            )
            task_id = progress.add_task(
                f"{task_name}: {dir.relative_to(paths.root_dir)}"
            )
            try:
                noop_moz_endpoints(
                    d=d,
                    dir=dir,
                    endpoints=endpoints,
                    task_name=task_name,
                )
            finally:
                progress.remove_task(task_id)

        await parallel_map(
            action,
            max_workers=base.jobs,
            task_type=TaskType.ASYNC,
            items=list(items.items()),
        )

    return d
