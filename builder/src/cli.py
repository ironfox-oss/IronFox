"""The CLI interface for IronFox builder."""

from __future__ import annotations

import os
import click
import multiprocessing

from click.core import Context
from pathlib import Path

from commands.base import DEFAULT_APP_CONFIG, AppConfig, BaseConfig
from commands.build import BuildCommand
from commands.prepare import PrepareCommand
from commands.setup import SetupCommand
from common.utils import find_prog


@click.group("Python scripts to build IronFox")
@click.option(
    "--root-dir",
    help="Path to root of the IronFox source tree.",
    default=Path.cwd(),
    type=click.Path(exists=True),
)
@click.option(
    "--android-home",
    help="Path to the Android SDK directory.",
    type=click.Path(exists=False),
    default=os.getenv("ANDROID_HOME", ""),
)
@click.option(
    "--java-home",
    help="Path to the JDK installation directory.",
    type=click.Path(exists=True),
    default=os.getenv("JAVA_HOME", ""),
)
@click.option(
    "--cargo-home",
    help="Path to the Cargo installation directory.",
    type=click.Path(exists=True),
    default=os.getenv("CARGO_HOME", ""),
)
@click.option(
    "--gradle-exec",
    help="Path to the Gradle executable file",
    type=click.Path(exists=True, dir_okay=False, executable=True),
    default=find_prog("gradle"),
)
@click.option(
    "--jobs",
    help="Number of parallel jobs to run.",
    type=int,
    default=multiprocessing.cpu_count(),
)
@click.option(
    "--dry-run",
    help="Disable task execution.",
    is_flag=True,
    default=False,
)
@click.option(
    "--verbose",
    help="Enable verbose logging.",
    is_flag=True,
    default=False,
)
@click.pass_context
def cli(
    ctx: Context,
    root_dir: Path,
    android_home: Path,
    java_home: Path,
    cargo_home: Path,
    gradle_exec: Path | None,
    jobs: int,
    dry_run: bool,
    verbose: bool,
):
    if not gradle_exec:
        raise RuntimeError("Unable to find 'gradle' executable")

    ctx.obj = BaseConfig(
        root_dir=Path(root_dir),
        android_home=Path(android_home),
        java_home=Path(java_home),
        cargo_home=Path(cargo_home),
        gradle_exec=gradle_exec,
        jobs=jobs,
        dry_run=dry_run,
        verbose=verbose,
    )


pass_base_config = click.make_pass_decorator(BaseConfig)


@cli.command(help="Setup the build environment.")
@click.option(
    "--clone-depth",
    help="The clone depth for cloning repositories. Defaults to 1 (shallow-clone).",
    type=int,
    default=1,
)
@pass_base_config
def setup(base_config: BaseConfig, clone_depth: int):
    cmd = SetupCommand(base_config, clone_depth)
    return cmd.run()


@cli.command(help="Prepare source files for the build.")
@click.option(
    "--sb-gapi-file",
    help="Path to a file containing the Google Safe Browsing API key",
    type=click.Path(exists=False, dir_okay=False),
    default=os.getenv("SB_GAPI_KEY_FILE", ""),
)
@click.option(
    "--app-name",
    help="Name of the application (as shown in launchers). Defaults to 'IronFox'.",
    type=str,
    default=DEFAULT_APP_CONFIG.app_name,
)
@click.option(
    "--app-vendor",
    help="Name of the vendor. Defaults to 'IronFox OSS'.",
    type=str,
    default=DEFAULT_APP_CONFIG.vendor,
)
@click.option(
    "--app-id-base",
    help="Base package ID (organization-level). Defaults to 'org.ironfoxoss'.",
    type=str,
    default=DEFAULT_APP_CONFIG.app_id_base,
)
@click.option(
    "--app-id",
    help="Application identifier (may include variant, e.g. 'ironfox.nightly'). Defaults to 'ironfox'.",
    type=str,
    default=DEFAULT_APP_CONFIG.app_id,
)
@click.option(
    "--browser-name",
    help="Name of the browser (as shown in-app). Defaults to 'IronFox'.",
    type=str,
    default=DEFAULT_APP_CONFIG.app_name,
)
@click.option(
    "--nightly",
    help="Whether to build a nightly build. Defaults to false.",
    is_flag=True,
    default=DEFAULT_APP_CONFIG.nightly,
)
@click.argument(
    "build_variant",
    type=click.Choice(["arm64", "arm", "x86_64", "bundle"]),
)
@click.option(
    "--ubo-assets",
    help="URL to the uBlock Origin assets file.",
    type=str,
    default="",
)
@pass_base_config
def prepare(
    base_config: BaseConfig,
    sb_gapi_file: Path,
    build_variant: str,
    ubo_assets: str,
    app_name: str,
    app_vendor: str,
    app_id_base: str,
    app_id: str,
    browser_name: str,
    nightly: bool,
):
    app_config = AppConfig(
        app_name=app_name,
        vendor=app_vendor,
        app_id_base=app_id_base,
        app_id=app_id,
        browser_name=browser_name,
        nightly=nightly,
    )

    cmd = PrepareCommand(
        base_config=base_config,
        app_config=app_config,
        sb_gapi_file=Path(sb_gapi_file),
        build_variant=build_variant,
        ubo_assets=ubo_assets,
    )

    return cmd.run()


@cli.command(help="Start the build.")
@click.argument("build_type", type=click.Choice(["apk", "bundle"]))
@pass_base_config
def build(base_config: BaseConfig, build_type: str):
    cmd = BuildCommand(base_config, build_type)
    return cmd.run()


if __name__ == "__main__":
    cli()
