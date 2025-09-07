"""The 'prepare' command."""

from enum import Enum
from pathlib import Path

from common.logging import setup_logging
from steps.prepare import get_definition as prepare_step_definition
from .base import AppConfig, BaseConfig, BaseCommand


class BuildVariant(Enum):
    """Build variant definitions for the"""

    ARM64 = 0
    """Build variant for arm64-v8a devices."""

    ARM = 1
    """Build variant for armeabi-v7a devices."""

    X86_64 = 2
    """Build variant for x86_64 devices."""

    BUNDLE = 3
    """Build variant for AAB builds which includes ABI-specific
    shared libraries for all supported CPU architectures."""


class PrepareConfig:

    def __init__(
        self,
        sb_gapi_file: Path,
        build_variant: str,
        app_config: AppConfig = AppConfig(),
    ):
        self.app_config = app_config
        self.sb_gapi_file = sb_gapi_file

        build_variant = build_variant.lower()
        if build_variant == "arm64":
            self._build_variant = BuildVariant.ARM64
        elif build_variant == "arm":
            self._build_variant = BuildVariant.ARM
        elif build_variant == "x86_64":
            self._build_variant = BuildVariant.X86_64
        elif build_variant == "bundle":
            self._build_variant = BuildVariant.BUNDLE
        else:
            raise ValueError(f"Unknown build variant {build_variant}")

    @property
    def build_variant(self):
        return self._build_variant

    def __repr__(self):
        return (
            f"PrepareConfig(build_variant={self.build_variant},"
            " sb_gapi_file={self.sb_gapi_file})"
        )


class PrepareCommand(BaseCommand):
    """The 'prepare' command."""

    def __init__(
        self,
        base_config: BaseConfig,
        sb_gapi_file: Path,
        build_variant: str,
    ):
        super().__init__("PrepareCommad", base_config)
        self.prepare_cofig = PrepareConfig(
            sb_gapi_file=sb_gapi_file,
            build_variant=build_variant,
        )

        setup_logging(self.base_config.verbose)
        self.logger.debug(
            f"Initialized prepare command with config: {self.prepare_cofig}"
        )

    def get_definition(self):
        return prepare_step_definition(self.prepare_cofig, self.paths)
