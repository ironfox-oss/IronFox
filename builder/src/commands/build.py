"""The 'build' command."""

import logging
from common.logging import setup_logging
from .base import BaseConfig, BaseCommand

from enum import Enum


class BuildType(Enum):
    """Build type definitions for the 'build' command."""

    APK = 0
    BUNDLE = 1


class BuildCommand(BaseCommand):
    """The 'build' command."""

    def __init__(
        self,
        base_config: BaseConfig,
        build_type: str,
    ):
        super().__init__(base_config)

        build_type = build_type.lower()
        if build_type == "apk":
            self._build_type = BuildType.APK
        elif build_type == "bundle":
            self._build_type = BuildType.BUNDLE
        else:
            raise ValueError(f"Unknown build type {build_type}")

        setup_logging(self.base_config.verbose)

        self.logger = logging.getLogger("BuildCommand")
        self.logger.debug(f"Initialized build command to build {self.build_type}")

    @property
    def build_type(self) -> BuildType:
        """The build type to build."""
        return self._build_type

    def run(self):
        print(f"Running build command to build {self.build_type}")
