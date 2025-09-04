from __future__ import annotations

import logging
import subprocess
import shlex

from pathlib import Path
from rich.progress import Progress

from .definition import BuildDefinition, TaskDefinition

logger = logging.getLogger("Compiler")


class RunCommandsTask(TaskDefinition):
    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        source_dir: Path,
        assume_yes: bool | int,
        commands: list[str],
    ):
        super().__init__(name, id, build_def)
        self.source_dir = source_dir
        self.assume_yes = assume_yes
        self.commands = commands

    def execute(self, progress):
        return run_build_commands(
            name=self.name,
            cwd=self.source_dir,
            commands=self.commands,
            progress=progress,
            assume_yes=self.assume_yes,
        )


def run_build_commands(
    name: str,
    cwd: Path,
    commands: list[str],
    progress: Progress,
    assume_yes: bool | int = False,
):
    logger.info(f"Running {len(commands)} commands in {cwd}")

    if not cwd.exists():
        raise FileNotFoundError(f"Working directory not found: {cwd}")

    if not cwd.is_dir():
        raise NotADirectoryError(f"Cwd path is not a directory: {cwd}")

    if not commands:
        logger.warning("No commands provided")
        return

    def task_desc(idx: int):
        return f"{name} [{idx}/{len(commands)}]"

    task_id = progress.add_task(task_desc(0), total=len(commands))

    try:
        # Execute each command in sequence
        for i, command in enumerate(commands, 1):
            logger.info(f"[{name}] Executing command {i}/{len(commands)}: {command}")

            success = _execute_command(name, command, cwd, assume_yes=assume_yes)

            if not success:
                raise subprocess.CalledProcessError(
                    1, command, f"[{name}] Command {i} failed"
                )

            progress.update(task_id, description=task_desc(i), advance=1)

            logger.info(f"[{name}] Command {i}/{len(commands)} completed successfully")

        logger.info(f"[{name}] All {len(commands)} commands completed successfully")

    finally:
        progress.remove_task(task_id)


def _execute_command(
    name: str,
    command: str,
    cwd: Path,
    assume_yes: bool | int = 0,
) -> bool:
    """Execute a single build command.

    Args:
        command (str): The command to execute.
        cwd (Path): The working directory for the command.

    Returns:
        bool: True if command succeeded, False otherwise.
    """
    try:
        # Parse command into arguments
        # This handles quoted arguments and shell escaping
        args = shlex.split(command)

        logger.debug(f"[{name}] Parsed command: {args}")
        logger.debug(f"[{name}] Working directory: {cwd}")

        input = None
        if assume_yes:
            if type(assume_yes) == bool:
                assume_yes = 100

            input = "y\n" * assume_yes

        # Execute the command
        result = subprocess.run(
            args, cwd=cwd, input=input, capture_output=True, text=True, check=True
        )

        # Log output
        if result.stdout:
            logger.debug(f"[{name}] Command stdout:\n{result.stdout}")

        if result.stderr:
            # Many build tools output progress/info to stderr
            logger.debug(f"[{name}] Command stderr:\n{result.stderr}")

        return True

    except subprocess.CalledProcessError as e:
        logger.error(f"[{name}] Command failed with return code {e.returncode}")
        logger.error(f"[{name}] Command: {command}")

        if e.stdout:
            logger.error(f"[{name}] Command stdout:\n{e.stdout}")

        if e.stderr:
            logger.error(f"[{name}] Command stderr:\n{e.stderr}")

        return False

    except FileNotFoundError as e:
        logger.error(f"[{name}] Command not found: {command}")
        logger.error(f"[{name}] Error: {e}")
        logger.error(
            f"[{name}] Please ensure all required build tools are installed and in PATH"
        )
        return False

    except Exception as e:
        logger.error(f"[{name}] Unexpected error executing command: {command}")
        logger.error(f"[{name}] Error: {e}")
        return False
