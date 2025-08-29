"""Base implementation for all 'ironfox' commands."""

from abc import abstractmethod
from pathlib import Path

from ..common.paths import IronFoxPaths


class BaseConfig:
    """Base class for all configurations."""

    def __init__(
        self,
        root_dir: Path,
        sdk_home: Path,
        java_home: Path,
        jobs: int,
        verbose: bool,
    ):
        """Creates a new BaseConfig instance.

        Args:
            sdk_home (Path): Path to the Android SDK directory.
            java_home (Path): Path to the JDK directory.
            jobs (int): Number of parallel jobs to run.
            verbose (bool): Whether verbose logging is enabled.
        """
        self.jobs = jobs
        self.verbose = verbose
        self.paths = IronFoxPaths(root_dir, sdk_home, java_home)


class BaseCommand:
    """Base class for all commands."""

    def __init__(
        self,
        base_config: BaseConfig,
    ):
        self.base_config = base_config

    @abstractmethod
    def run(self):
        pass

    @property
    def paths(self) -> IronFoxPaths:
        """File system paths for building IronFox."""
        return self.base_config.paths
