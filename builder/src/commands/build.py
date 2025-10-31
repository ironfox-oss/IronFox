"""The 'build' command."""

import logging

from dataclasses import dataclass
from pathlib import Path
from common.logging import setup_logging
from .base import BaseConfig, BaseCommand

from enum import Enum


class BuildType(Enum):
    """Build type definitions for the 'build' command."""

    APK = 0
    BUNDLE = 1


@dataclass
class BuildConfig:
    build_type: BuildType
    exec_make: Path
    exec_sh: Path


class BuildCommand(BaseCommand):
    """The 'build' command."""

    def __init__(
        self,
        base_config: BaseConfig,
        build_type: str,
        exec_make: Path,
        exec_sh: Path,
    ):
        super().__init__("BuildCommand", base_config=base_config)

        build_type = build_type.lower()
        if build_type == "apk":
            _build_type = BuildType.APK
        elif build_type == "bundle":
            _build_type = BuildType.BUNDLE
        else:
            raise ValueError(f"Unknown build type {build_type}")

        self.build_config = BuildConfig(
            build_type=_build_type,
            exec_make=exec_make,
            exec_sh=exec_sh,
        )

        setup_logging(self.base_config.verbose)

        self.logger = logging.getLogger("BuildCommand")
        self.logger.debug(f"Initialized build command to build {_build_type}")

    async def get_definition(self):
        from steps.build import get_definition

        return await get_definition(self.base_config, self.build_config, self.paths)
