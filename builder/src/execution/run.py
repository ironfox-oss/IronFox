from __future__ import annotations

from dataclasses import dataclass
import logging
import os
import subprocess
import shlex

from pathlib import Path
from typing import Dict, List, Optional
from common import subproc
from rich.progress import Progress
from rich.console import Console

from .definition import BuildDefinition, TaskDefinition
from .types import CommandType, RunTaskCmd


def run_cmd(
    command: CommandType,
    cwd: Path,
    assume_yes: bool | int = False,
    env: Dict[str, str] = {},
) -> RunTaskCmd:
    return RunTaskCmd(
        command=command,
        cwd=cwd,
        assume_yes=assume_yes,
        env=env,
    )


class RunCommandsTask(TaskDefinition):
    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        cmds: List[RunTaskCmd],
    ):
        super().__init__(name, id, build_def)
        self.cmds = cmds

    async def execute(self, params):

        # Set up environment variables
        # 1. get os env vars
        # 2. get build-wide env vars (can override os env vars)
        # 3. command-specific env vars (can override os and build-wide env vars)
        env = {**os.environ.copy(), **params.env.environment_variables}

        return await run_build_commands(
            name=self.name,
            commands=self.cmds,
            progress=params.progress,
            env=env,
            logger=self.logger,
        )


async def run_build_commands(
    name: str,
    commands: List[RunTaskCmd],
    progress: Progress,
    logger: logging.Logger,
    env: dict[str, str] = {},
):
    logger.debug(f"Running {len(commands)} commands")

    if not commands:
        logger.warning("No commands provided")
        return

    def task_desc(idx: int):
        return f"{name} [{idx}/{len(commands)}]"

    task_id = progress.add_task(
        task_desc(0), total=len(commands) if len(commands) > 1 else None
    )

    try:
        # Execute each command in sequence
        for i, d in enumerate(commands, 1):
            logger.debug(f"Executing command {i}/{len(commands)}: {d}")

            if not d.cwd.exists():
                raise FileNotFoundError(f"Working directory not found: {d.cwd}")

            if not d.cwd.is_dir():
                raise NotADirectoryError(f"Cwd path is not a directory: {d.cwd}")

            cmd_name = "<unknown>"
            if isinstance(d.command, str):
                cmd_name = d.command
            else:
                cmd_name = d.command[0]

            success = await _execute_command(
                name=name,
                command=d.command,
                cwd=d.cwd,
                env={**env, **d.env},
                logger=logger,
                assume_yes=d.assume_yes,
                progress=progress,
            )

            if not success:
                raise subprocess.CalledProcessError(1, cmd_name, f"Command {i} failed")

            progress.update(task_id, description=task_desc(i), advance=1)

            logger.debug(f"Command {i}/{len(commands)} completed successfully")

        logger.debug(f"All {len(commands)} commands completed successfully")

    finally:
        progress.remove_task(task_id)


async def _execute_command(
    name: str,
    command: CommandType,
    cwd: Path,
    logger: logging.Logger,
    progress: Optional[Progress] = None,
    env: dict[str, str] = os.environ.copy(),
    assume_yes: bool | int = 0,
) -> bool:
    try:
        result_handler = None
        if isinstance(command, str):
            cmd = command
        else:
            cmd, result_handler = command

        args = shlex.split(cmd)
        logger.info(f"Running {args} in {cwd}")

        input_data = None
        if assume_yes:
            if isinstance(assume_yes, bool):
                assume_yes = 100
            input_data = "y\n" * assume_yes

        # Execute the command
        (returncode, stdout, stderr) = await subproc.run_command_with_progress(
            title=name,
            cmd=args,
            cwd=cwd,
            stdin=input_data.encode() if input_data is not None else None,
            env=env,
            console=progress.console if progress is not None else Console(),
        )

        if returncode != 0:
            raise subprocess.CalledProcessError(returncode, args, stdout, stderr)

        # Log output
        if stdout:
            logger.debug(f"Command stdout:\n{stdout}")

        if stderr:
            logger.debug(f"Command stderr:\n{stderr}")

        if result_handler:
            try:
                logger.debug("Running result handler...")
                result_handler(stdout, stderr)
            except Exception as e:
                logger.error(f"Result handler failed with exception: {e}")
                return False

        return True

    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed with return code {e.returncode}")
        logger.error(f"Command: {command}")

        if e.stdout:
            logger.error(f"Command stdout:\n{e.stdout}")

        if e.stderr:
            logger.error(f"Command stderr:\n{e.stderr}")

        return False

    except FileNotFoundError as e:
        logger.error(f"Command not found: {command}")
        logger.error(f"Error: {e}")
        logger.error(
            f"Please ensure all required build tools are installed and in PATH"
        )
        return False

    except Exception as e:
        logger.error(f"Unexpected error executing command: {command}")
        logger.error(f"Error: {e}")
        return False
