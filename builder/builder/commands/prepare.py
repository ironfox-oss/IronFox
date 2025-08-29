"""The 'prepare' command."""

from enum import Enum
import logging

from ..common.logging import setup_logging
from .base import BaseConfig, BaseCommand


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


class PrepareCommand(BaseCommand):
    """The 'prepare' command."""

    def __init__(
        self,
        base_config: BaseConfig,
        build_variant: str,
    ):
        super().__init__(base_config)

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

        setup_logging(self.base_config.verbose)

        self.logger = logging.getLogger("PrepareCommand")
        self.logger.debug(
            f"Initialized prepare command for build variant {self.build_variant}"
        )

    @property
    def build_variant(self):
        """Get the build variant."""
        return self._build_variant
