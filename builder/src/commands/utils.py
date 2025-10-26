from __future__ import annotations

import logging
from typing import Any, List, Tuple
from commands.base import BaseConfig, BuildEnvironment
from commands.prepare import PrepareConfig
from commands.setup import SetupConfig
from rich.table import Table
from rich.console import Console
from rich.panel import Panel
from rich.syntax import Syntax
from rich.text import Text

logger = logging.getLogger("CmdUtils")


def _dump_table(console: Console, header: str, rows: List[Tuple[str, Any]]):
    table = Table(show_header=False, box=None, pad_edge=False)
    for key, val in rows:
        table.add_row(key, str(val))

    console.print(f"\n[bold]{header}[/bold]")
    console.print(table)


def dump_config(
    base_config: BaseConfig,
    setup_config: SetupConfig | None = None,
    prepare_config: PrepareConfig | None = None,
):
    paths = base_config.paths
    console = Console()
    _dump_table(
        console,
        "Paths",
        [
            ("IronFox root", paths.root_dir),
            ("Android SDK", paths.android_home),
            ("Cargo Home", paths.cargo_home),
            ("Java Home", paths.java_home),
            ("libclang", paths.libclang_dir),
        ],
    )

    if setup_config:
        _dump_table(
            console, "Setup configuration", [("Clone depth", setup_config.clone_depth)]
        )

    if prepare_config:
        app = prepare_config.app_config
        _dump_table(
            console,
            "Prepare configuration",
            [
                ("Browser name", app.browser_name),
                ("App name", app.app_name),
                ("Vendor", app.vendor),
                ("Base App ID", app.app_id_base),
                ("App ID", app.app_id),
                ("Package name", app.package_name),
                ("Is nightly build", app.nightly),
                ("Build variant", prepare_config.build_variant),
                ("SB GAPI file", prepare_config.sb_gapi_file),
                ("uBO Assets URL", prepare_config.ubo_assets),
            ],
        )

    _dump_table(
        console,
        "Environment variables",
        [(key, val) for key, val in base_config.env.environment_variables.items()],
    )

    console.print()
    console.print("========")
    console.print()
