"""Base implementation for all 'ironfox' commands."""

from __future__ import annotations

from enum import Enum
import io
import logging
import pstats

from abc import abstractmethod
from pathlib import Path
from typing import Dict

from execution.task_graph import write_ascii_graph, write_img_graph
from rich.table import Table
from rich.console import Console
from rich.panel import Panel
from rich.syntax import Syntax
from rich.text import Text

from common.logging import setup_logging
from execution.definition import BuildDefinition
from execution.executor import (
    AsyncBuildExecutor,
    ExecutorConfig,
)

from common.paths import Paths

logger = logging.getLogger("BaseConfig")


class AppConfig:
    def __init__(
        self,
        browser_name: str = "IronFox",
        app_name: str = "IronFox",
        vendor: str = "IronFox OSS",
        app_id_base: str = "org.ironfoxoss",
        app_id: str = "ironfox",
        nightly: bool = False,
    ):
        if nightly:
            app_name += " Nightly"
            app_id += ".nightly"

        self.browser_name = browser_name
        self.app_name = app_name
        self.vendor = vendor
        self.app_id_base = app_id_base
        self.app_id = app_id
        self.package_name = f"{app_id_base}.{app_id}"
        self.nightly = nightly


DEFAULT_APP_CONFIG = AppConfig()


class BuildEnvironment:
    """Build configuration for building IronFox."""

    def __init__(self, paths: Paths):
        self.paths = paths

        _path_vars: dict[str, Path] = {
            "MACHRC": paths.machrc_file,
            "MOZCONFIG": paths.mozconfig_file,
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
    def environment_variables(self) -> Dict[str, str]:
        """The environment variables that should be available to the IronFox build."""
        return self._env_vars

    def __repr__(self):
        return f"BuildEnvironment({''.join(f'{key}={value}' for key, value in self.environment_variables.items())})"


class TaskGraphType(Enum):
    Image = 0
    Ascii = 1


class BaseConfig:
    """Base class for all configurations."""

    def __init__(
        self,
        root_dir: Path,
        android_home: Path,
        java_home: Path,
        cargo_home: Path,
        gradle_exec: Path,
        write_task_graph: Path | None,
        task_graph_type: str | None,
        jobs: int,
        dry_run: bool,
        verbose: bool,
        profile: bool,
    ):
        """Creates a new BaseConfig instance."""
        self.jobs = jobs
        self.verbose = verbose
        self.dry_run = dry_run
        self.profile = profile
        self.task_graph_path = write_task_graph
        self.task_graph_type = (
            TaskGraphType.Ascii if task_graph_type == "ascii" else TaskGraphType.Image
        )
        self.paths = Paths(
            root_dir=root_dir.resolve(),
            android_home=android_home.resolve(),
            java_home=java_home.resolve(),
            cargo_home=cargo_home.resolve(),
            gradle_exec=gradle_exec.resolve(),
        )

        self.env = BuildEnvironment(paths=self.paths)

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
    async def get_definition(self) -> BuildDefinition:
        pass

    @abstractmethod
    async def run(self):
        if not self.base_config.profile:
            return await self.do_run()

        import cProfile

        profile = cProfile.Profile()
        profile.enable()

        try:
            await self.do_run()
        finally:
            profile.disable()
            s = io.StringIO()
            ps = pstats.Stats(profile, stream=s).sort_stats("tottime")
            ps.print_stats(20)
            print(s.getvalue())

    async def do_run(self):
        self.paths.mkdirs()

        config = ExecutorConfig(
            jobs=self.base_config.jobs,
            dry_run=self.base_config.dry_run,
            env=self.base_config.env,
        )

        definition = await self.get_definition()

        if self.base_config.task_graph_path:
            if self.base_config.task_graph_type == TaskGraphType.Image:
                write_img_graph(
                    build=definition,
                    filepath=self.base_config.task_graph_path,
                )
            elif self.base_config.task_graph_type == TaskGraphType.Ascii:
                write_ascii_graph(
                    build=definition,
                    filepath=self.base_config.task_graph_path,
                )

        executor = AsyncBuildExecutor(config=config, definition=definition)

        self.logger.debug(f"Starting setup with definition {definition}")

        console = Console()
        try:
            failures = await executor.execute()

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
