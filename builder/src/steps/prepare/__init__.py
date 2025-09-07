import logging
import re

from pathlib import Path
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition

from execution.types import PatternType
from steps.common.java import setup_java
from commands.prepare import PrepareConfig

logger = logging.getLogger("PrepareStep")


def _require_dir_exists(dir: Path):
    if not dir.exists() or not dir.is_dir():
        raise RuntimeError(f"{dir} does not exist or is not a directory!")


def apply_literal_replacements(
    content: str,
    replacements: dict[PatternType, str],
) -> str:
    result = content
    for pattern, repl in replacements.items():
        result = re.sub(pattern=pattern, repl=repl, string=result)

    return result


def get_definition(config: PrepareConfig, paths: Paths) -> BuildDefinition:
    app_conf = config.app_config
    app_name = app_conf.app_name
    app_id = app_conf.app_id
    app_id_suffix = app_conf.app_id_suffix
    app_vendor = app_conf.vendor
    d = BuildDefinition("Prepare")

    paths.build_dir.mkdir(parents=True, exist_ok=True)

    _require_dir_exists(paths.android_home)
    _require_dir_exists(paths.ndk_home)
    _require_dir_exists(paths.ndk_toolchain_dir)
    _require_dir_exists(paths.libclang_dir)
    _require_dir_exists(paths.java_home)
    _require_dir_exists(paths.cargo_home)

    d.chain(
        # fmt:off
        # Pre-prepare checks
        # Used in chain() for ordered execution
        
        # Check appropriate Java version
        setup_java(d, paths),
        # TODO: Check patches
        # check_patches(d, paths),
        # fmt: on
    ).then(  # type: ignore
        d.find_replace(
            name="Setup manifest configuration",
            target_file=paths.fenix_dir / "app" / "build.gradle",
            replacement=lambda content: apply_literal_replacements(
                content=content,
                replacements={
                    r'applicationId "org.mozilla"': f'applicationId "{app_id}"',
                    r'applicationIdSuffix ".firefox"': f'applicationIdSuffix "{app_id_suffix}"',
                    r'"sharedUserId": "org.mozilla.firefox.sharedID"': f'"sharedUserId": "{app_id}{app_id_suffix}.sharedID"|',
                    r"Config.releaseVersionName(project)": f'"{Versions.IRONFOX_VERSION}"',
                },
            ),
        )
    ).then(
        d.find_replace(
            name="Set MOZILLA_OFFICIAL flag",
            target_file=paths.fenix_dir / "app" / "build.gradle",
            match_lines=f"MOZILLA_OFFICIAL",
            replacement=lambda line: re.sub("false", "true", line, count=1),
        )
    )

    return d
