"""Base implementation for all 'ironfox' commands."""

import logging

from abc import abstractmethod
from pathlib import Path
from common.logging import setup_logging
from execution.definition import BuildDefinition
from execution.executor import BuildExecutor, ExecutorConfig
from rich.table import Table
from rich.console import Console

from common.paths import Paths

logger = logging.getLogger("BaseConfig")


class AppConfig:
    def __init__(
        self,
        app_name: str = "IronFox",
        vendor: str = "IronFox OSS",
        app_id: str = "org.ironfoxoss",
        app_id_suffix: str = ".ironfox",
    ):
        self.app_name = app_name
        self.vendor = vendor
        self.app_id = app_id
        self.app_id_suffix = app_id_suffix
        self.package_name = f"{app_id}{app_id_suffix}"


class BuildEnvironment:
    """Build configuration for building IronFox."""

    def __init__(self, paths: Paths):
        self.paths = paths

        _path_vars: dict[str, Path] = {
            "MACHRC": paths.machrc_file,
            "NSS_DIR": paths.application_services_nss_dir,
            "ARTIFACTS": paths.artifacts_dir,
            "APK_ARTIFACTS": paths.artifacts_apk_dir,
            "APKS_ARTIFACTS": paths.artifacts_apks_dir,
            "AAR_ARTIFACTS": paths.artifacts_aar_dir,
            "JAVA_HOME": paths.java_home,
            "ANDROID_HOME": paths.android_home,
            "CARGO_HOME": paths.cargo_home,
        }

        _flag_vars: dict[str, str] = {
            "DISABLE_TELEMETRY": "1",
            "NSS_STATIC": "1",
        }

        self._env_vars: dict[str, str] = {
            **_flag_vars,
            **{key: str(path) for key, path in _path_vars.items()},
        }

    @property
    def environment_variables(self):
        """The environment variables that should be available to the IronFox build."""
        return self._env_vars

    def __repr__(self):
        return f"BuildEnvironment({''.join(f'{key}={value}' for key, value in self.environment_variables.items())})"


class BaseConfig:
    """Base class for all configurations."""

    def __init__(
        self,
        root_dir: Path,
        android_home: Path,
        java_home: Path,
        cargo_home: Path,
        jobs: int,
        dry_run: bool,
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
        self.dry_run = dry_run
        self.paths = Paths(
            root_dir=root_dir.resolve(),
            android_home=android_home.resolve(),
            java_home=java_home.resolve(),
            cargo_home=cargo_home.resolve(),
        )

        self.env = BuildEnvironment(paths=self.paths)

        config_table = Table(show_header=False, box=None, pad_edge=False)
        config_table.add_row("IronFox root", str(self.paths.root_dir))
        config_table.add_row("Android SDK", str(self.paths.android_home))
        config_table.add_row("Cargo", str(self.paths.cargo_home))
        config_table.add_row("JDK", str(self.paths.java_home))

        env_table = Table(show_header=False, box=None, pad_edge=False)
        for key, value in self.env.environment_variables.items():
            env_table.add_row(key, value)

        # Print with spacing
        console = Console()
        console.print("\n[bold]Using configuration:[/bold]")
        console.print(config_table)
        console.print("\n[bold]Environment variables:[/bold]")
        console.print(env_table)
        console.print()
        console.print("========")
        console.print()

    @property
    def environment_variables(self):
        return self.env.environment_variables


class BaseCommand:
    """Base class for all commands."""

    def __init__(
        self,
        name: str,
        base_config: BaseConfig,
    ):
        self.name = name
        self.base_config = base_config

        setup_logging(self.base_config.verbose)
        self.logger = logging.getLogger(name)

    @abstractmethod
    def get_definition(self) -> BuildDefinition:
        pass

    @abstractmethod
    def run(self):
        self.paths.mkdirs()

        definition = self.get_definition()
        self.logger.debug(f"Starting setup with definition {definition}")
        executor = BuildExecutor(
            ExecutorConfig(
                jobs=self.base_config.jobs,
                dry_run=self.base_config.dry_run,
                env=self.base_config.env,
            )
        )

        try:
            executor.submit(definition)
        except Exception as e:
            self.logger.error(f"{self.name} failed with exception: {e}")
            raise
        finally:
            executor.shutdown()

    @property
    def paths(self) -> Paths:
        """File system paths for building IronFox."""
        return self.base_config.paths
