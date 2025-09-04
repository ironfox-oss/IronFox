"""The CLI interface for IronFox builder."""

import click
import multiprocessing

from click.core import Context
from pathlib import Path

from commands.base import BaseConfig
from commands.build import BuildCommand
from commands.prepare import PrepareCommand
from commands.setup import SetupCommand


@click.group("Python scripts to build IronFox")
@click.option(
    "--root-dir",
    help="Path to root of the IronFox source tree.",
    default=Path.cwd(),
    type=click.Path(exists=True),
)
@click.option(
    "--sdk-home",
    help="Path to the Android SDK directory.",
    type=click.Path(exists=False),
)
@click.option(
    "--java-home",
    help="Path to the JDK installation directory.",
    type=click.Path(exists=True),
)
@click.option(
    "--jobs",
    help="Number of parallel jobs to run.",
    type=int,
    default=multiprocessing.cpu_count(),
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
    sdk_home: Path,
    java_home: Path,
    jobs: int,
    verbose: bool,
):
    ctx.obj = BaseConfig(
        root_dir=Path(root_dir),
        sdk_home=Path(sdk_home),
        java_home=Path(java_home),
        jobs=jobs,
        verbose=verbose,
    )


pass_base_config = click.make_pass_decorator(BaseConfig)


@cli.command(help="Setup the build environment.")
@pass_base_config
def setup(base_config: BaseConfig):
    cmd = SetupCommand(base_config)
    return cmd.run()


@cli.command(help="Prepare source files for the build.")
@click.argument(
    "build_variant",
    type=click.Choice(["arm64", "arm", "x86_64", "bundle"]),
)
@pass_base_config
def prepare(base_config: BaseConfig, build_variant: str):
    cmd = PrepareCommand(base_config, build_variant)
    return cmd.run()


@cli.command(help="Start the build.")
@click.argument("build_type", type=click.Choice(["apk", "bundle"]))
@pass_base_config
def build(base_config: BaseConfig, build_type: str):
    cmd = BuildCommand(base_config, build_type)
    return cmd.run()


if __name__ == "__main__":
    cli()
