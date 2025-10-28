from __future__ import annotations

import logging
import subprocess
from pathlib import Path
from rich.progress import Progress

from .definition import BuildDefinition, TaskDefinition

class CloneTask(TaskDefinition):
    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        repo_url: str,
        clone_to: Path,
        branch: str | None = None,
        depth: int | None = None,
    ):
        super().__init__(name, id, build_def)
        self.repo_url = repo_url
        self.clone_to = clone_to
        self.branch = branch
        self.depth = depth

    async def execute(self, params):
        return clone_repository(
            repo_url=self.repo_url,
            clone_to=self.clone_to,
            logger=self.logger,
            branch=self.branch,
            depth=self.depth,
        )


def clone_repository(
    repo_url: str,
    clone_to: Path,
    logger: logging.Logger,
    branch: str | None = None,
    depth: int | None = None,
):
    logger.info(f"Cloning repository {repo_url} to {clone_to}")

    if clone_to.exists() and any(clone_to.iterdir()):
        logger.info(
            f"Directory {clone_to} already exists and is not empty. Skipping clone."
        )
        return

    clone_to.parent.mkdir(parents=True, exist_ok=True)

    cmd = ["git", "clone"]

    if depth is not None:
        cmd.extend(["--depth", str(depth)])
        logger.debug(f"Using shallow clone with depth: {depth}")

    if branch is not None:
        cmd.extend(["--branch", branch])
        logger.debug(f"Cloning specific branch: {branch}")

    cmd.extend([repo_url, str(clone_to)])

    logger.debug(f"Executing command: {' '.join(cmd)}")

    try:

        result = subprocess.run(cmd, capture_output=True, text=True, check=True)

        if result.stdout:
            logger.debug(f"Git clone stdout: {result.stdout}")
        if result.stderr:
            # Git often outputs progress to stderr, so log as debug
            logger.debug(f"Git clone stderr: {result.stderr}")

        logger.info(f"Successfully cloned repository to {clone_to}")

    except subprocess.CalledProcessError as e:
        logger.error(f"Git clone failed with return code {e.returncode}")
        logger.error(f"Error output: {e.stderr}")

        # Clean up partial clone if it exists
        if clone_to.exists():
            import shutil

            try:
                shutil.rmtree(clone_to)
                logger.debug(f"Cleaned up partial clone directory: {clone_to}")
            except Exception as cleanup_error:
                logger.warning(f"Failed to clean up partial clone: {cleanup_error}")

        raise

    except FileNotFoundError:
        logger.error(
            "Git command not found. Please ensure Git is installed and in PATH."
        )
        raise subprocess.CalledProcessError(127, cmd, "Git command not found")
