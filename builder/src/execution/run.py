from __future__ import annotations

import logging
import os
import subprocess
import shlex

from pathlib import Path

from .definition import BuildDefinition, TaskDefinition
from .types import CommandType


class RunCommandsTask(TaskDefinition):
    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        cwd: Path,
        assume_yes: bool | int,
        commands: list[CommandType],
        env: dict[str, str],
    ):
        super().__init__(name, id, build_def)
        self.cwd = cwd
        self.assume_yes = assume_yes
        self.commands = commands
        self.env = env

    def execute(self, params):

        # Set up environment variables
        # 1. get os env vars
        # 2. get build-wide env vars (can override os env vars)
        # 3. command-specific env vars (can override os and build-wide env vars)
        env = {**os.environ.copy(), **params.env.environment_variables, **self.env}

        return run_build_commands(
            name=self.name,
            cwd=self.cwd,
            commands=self.commands,
            env=env,
            logger=self.logger,
            assume_yes=self.assume_yes,
        )


def run_build_commands(
    name: str,
    cwd: Path,
    commands: list[CommandType],
    logger: logging.Logger,
    env: dict[str, str] = os.environ.copy(),
    assume_yes: bool | int = False,
):
    logger.debug(f"Running {len(commands)} commands in {cwd}")

    if not cwd.exists():
        raise FileNotFoundError(f"Working directory not found: {cwd}")

    if not cwd.is_dir():
        raise NotADirectoryError(f"Cwd path is not a directory: {cwd}")

    if not commands:
        logger.warning("No commands provided")
        return

    def task_desc(idx: int):
        return f"{name} [{idx}/{len(commands)}]"

    # Execute each command in sequence
    for i, command in enumerate(commands, 1):
        logger.debug(f"Executing command {i}/{len(commands)}: {command}")

        cmd_name = "<unknown>"
        if isinstance(command, str):
            cmd_name = command
        else:
            cmd_name = command[0]

        success = _execute_command(
            command=command,
            cwd=cwd,
            env=env,
            logger=logger,
            assume_yes=assume_yes,
        )

        if not success:
            raise subprocess.CalledProcessError(1, cmd_name, f"Command {i} failed")

        logger.debug(f"Command {i}/{len(commands)} completed successfully")

    logger.debug(f"All {len(commands)} commands completed successfully")


def _execute_command(
    command: CommandType,
    cwd: Path,
    logger: logging.Logger,
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
        logger.debug(f"Parsed command: {args}")
        logger.debug(f"Working directory: {cwd}")

        input_data = None
        if assume_yes:
            if isinstance(assume_yes, bool):
                assume_yes = 100
            input_data = "y\n" * assume_yes

        # Execute the command
        result = subprocess.run(
            args,
            cwd=cwd,
            input=input_data,
            env=env,
            capture_output=True,
            text=True,
            check=True,
        )

        # Log output
        if result.stdout:
            logger.debug(f"Command stdout:\n{result.stdout}")

        if result.stderr:
            # Many build tools output progress/info to stderr
            logger.debug(f"Command stderr:\n{result.stderr}")

        if result_handler:
            try:
                logger.debug("Running result handler...")
                result_handler(result.stdout, result.stderr)
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
