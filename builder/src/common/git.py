"""Utilities for working with Git repositories."""

from __future__ import annotations

from pathlib import Path
import shutil
import subprocess

from utils import find_prog, is_blank


class GitConfig:
    """Git configuration and wrapper around `git` binary"""

    def __init__(self):
        git_exec = find_prog("git")
        if not git_exec:
            raise RuntimeError("Unable to find 'git' executable path")

        self.git_exec = git_exec

    def clone(
        self,
        repo: str,
        destination: Path,
        depth: int | None = None,
        branch: str | None = None,
        overwrite_destination: bool = False,
    ):
        """Clone a git repository

        Args:
            repo (str): The URL of the Git repository.
            destination (Path): The destination directory for the clone.
            depth (int | None, optional): Clone depth. Can be `None` or 0 for full clone. Defaults to None.
            branch (str | None, optional): The branch or tag name to clone. Can be `None` to clone the default branch. Defaults to None.
            overwrite_destination (bool, optional): Whether to overwrite the destination directory if it already exists. Defaults to False.

        Raises:
            ValueError: When any of the parameters are invalid.
            RuntimeError: If the clone fails.
        """

        cmd = [self.git_exec.name, "clone"]

        if depth:
            if depth < 0:
                raise ValueError("Clone depth cannot be negative!")

            cmd += ["--depth", depth]

        if branch:
            if is_blank(branch):
                raise ValueError("Branch name cannot be blank!")

            cmd += ["--branch", branch]

        if destination.exists():
            if not overwrite_destination:
                raise ValueError(f"Destination already exists: {destination}")

            shutil.rmtree(destination)

        if is_blank(repo):
            raise ValueError("Repo URL cannot be blank!")

        cmd += [repo, destination.name]

        exit_code = subprocess.check_call(cmd)
        if exit_code != 0:
            raise RuntimeError(
                f"Unable to clone repo: {repo} to {destination}. Git call completed with exit code {exit_code}"
            )
