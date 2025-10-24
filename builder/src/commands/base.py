"""Base implementation for all 'ironfox' commands."""

import logging

from abc import abstractmethod
from pathlib import Path

from rich.table import Table
from rich.console import Console
from rich.panel import Panel
from rich.syntax import Syntax
from rich.text import Text

from common.logging import setup_logging
from execution.definition import BuildDefinition
from execution.executor import BuildExecutor, ExecutorConfig

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

        console = Console()
        try:
            failures = executor.submit(definition)

            # If there were failures, present them to the user
            if failures:
                self.print_failure_summary(console, failures)
                console.print(
                    "\n[bold red]Please inspect the failures above to diagnose and fix the build.[/bold red]\n"
                )

            else:
                console.print(
                    "\n[bold green]Build completed successfully — all tasks passed.[/bold green]\n"
                )

        except Exception as e:
            # If executor.submit itself raises (unexpected), log and re-raise to keep previous semantics
            self.logger.error(f"{self.name} failed with exception: {e}")
            raise
        finally:
            executor.shutdown()

    def print_failure_summary(self, console, failures):
        console.print("\n[bold red]Build completed with failures[/bold red]\n")

        # Summary table
        summary = Table(title="Failure Summary", show_lines=True)
        summary.add_column("Task ID", style="bold")
        summary.add_column("Task Name", style="cyan")
        summary.add_column("Reason", style="magenta")
        summary.add_column("Exception Type", style="yellow")
        summary.add_column("Message")

        for f in failures:
            exc_type = type(f.exception).__name__ if f.exception else ""
            message = str(f.exception) if f.exception else ""
            summary.add_row(str(f.task_id), f.task_name, f.reason, exc_type, message)

        console.print(summary)

        # Detailed panels for each failure (tracebacks / messages)
        for idx, f in enumerate(failures, start=1):
            console.rule(f"[bold]Detail {idx} — {f.task_name} (ID: {f.task_id})[/bold]")

            # Show a compact header
            header = Text()
            header.append(f"Reason: ", style="bold magenta")
            header.append(f"{f.reason}\n")
            if f.exception:
                header.append("Exception: ", style="bold yellow")
                header.append(f"{type(f.exception).__name__}: {str(f.exception)}\n")
            else:
                header.append("Exception: ", style="bold yellow")
                header.append("None\n")

            console.print(Panel(header, title="Overview", expand=False))

            # If a traceback exists, render it with syntax highlighting for readability
            if getattr(f, "traceback", None):
                tb = f.traceback or ""
                # Use 'pytb' lexer to make tracebacks readable; fall back to plain text if needed
                syntax = Syntax(tb, "pytb", line_numbers=False)
                console.print(Panel(syntax, title="Traceback", expand=False))
            else:
                # If no traceback, at least show the repr/message
                detail_text = Text()
                if f.exception:
                    detail_text.append(repr(f.exception))
                else:
                    detail_text.append(f.reason)

                console.print(Panel(detail_text, title="Detail", expand=False))

    @property
    def paths(self) -> Paths:
        """File system paths for building IronFox."""
        return self.base_config.paths
