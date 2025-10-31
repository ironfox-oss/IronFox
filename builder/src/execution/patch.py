import logging
import subprocess
from pathlib import Path
from common.patches import PatchConfig
from rich.progress import Progress
import yaml

from .definition import BuildDefinition, TaskDefinition


class PatchTask(TaskDefinition):
    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        patch_file: Path,
        target_dir: Path,
    ):
        super().__init__(name, id, build_def)
        self.patch_file = patch_file
        self.target_dir = target_dir

    async def execute(self, params):
        progress = params.progress
        patch_file = self.patch_file
        target_dir = self.target_dir

        if not patch_file.exists():
            raise FileNotFoundError(f"Patch file not found: {patch_file}")

        if not patch_file.is_file():
            raise RuntimeError(f"Not a file: {patch_file}")

        if not target_dir.exists():
            raise FileNotFoundError(f"Target directory not found: {target_dir}")

        if not target_dir.is_dir():
            raise NotADirectoryError(f"Target path is not a directory: {target_dir}")

        ext = patch_file.name[max(0, patch_file.name.index(".") + 1) :]
        if ext != "yaml" and ext != "yml":
            return apply_patch(
                patch_file=patch_file,
                target_dir=target_dir,
                progress=progress,
                logger=self.logger,
            )

        with open(patch_file, "r") as f:
            config = PatchConfig(**yaml.safe_load(f))

        task_name = f"Apply patches from {patch_file.name}"
        task_id = progress.add_task(
            f"{task_name} (0/{len(config.patches)})", total=len(config.patches)
        )
        try:
            for index, patch in enumerate(config.patches):
                do_apply_patch(
                    patch_file=params.env.paths.patches_dir / patch.file,
                    target_dir=target_dir,
                    logger=self.logger,
                )
                progress.update(task_id=task_id, completed=index + 1)
        finally:
            progress.remove_task(task_id=task_id)


def apply_patch(
    patch_file: Path,
    target_dir: Path,
    progress: Progress,
    logger: logging.Logger,
):
    logger.info(f"Applying patch {patch_file} to {target_dir}")
    task_id = progress.add_task(f"Applying {patch_file.name}", total=None)

    try:
        do_apply_patch(patch_file, target_dir, logger)
    finally:
        progress.remove_task(task_id)


def do_apply_patch(patch_file: Path, target_dir: Path, logger: logging.Logger):
    if _is_git_repository(target_dir):
        logger.debug("Target directory is a git repository, trying git apply")
        success = _apply_with_git(
            patch_file,
            target_dir,
            logger,
        )
        if success:
            logger.debug(f"Successfully applied patch using git apply: {patch_file}")
            return
        else:
            logger.debug("git apply failed, falling back to patch command")

        # Fall back to standard patch command
    _apply_with_patch_command(patch_file, target_dir, logger)
    logger.debug(f"Successfully applied patch using patch command: {patch_file}")


def _is_git_repository(directory: Path) -> bool:
    """Check if a directory is a git repository."""
    return (directory / ".git").exists()


def _apply_with_git(
    patch_file: Path,
    target_dir: Path,
    logger: logging.Logger,
) -> bool:
    """Try to apply patch using git apply.

    Returns:
        bool: True if successful, False if failed (but doesn't raise).
    """
    cmd = ["git", "apply", str(patch_file)]

    logger.debug(f"Executing command: {' '.join(cmd)}")

    try:
        result = subprocess.run(
            cmd, cwd=target_dir, capture_output=True, text=True, check=True
        )

        if result.stdout:
            logger.debug(f"git apply stdout: {result.stdout}")
        if result.stderr:
            logger.debug(f"git apply stderr: {result.stderr}")

        return True

    except subprocess.CalledProcessError as e:
        logger.debug(f"git apply failed with return code {e.returncode}")
        logger.debug(f"git apply error: {e.stderr}")
        return False

    except FileNotFoundError:
        logger.debug("git command not found, falling back to patch")
        return False


def _apply_with_patch_command(
    patch_file: Path,
    target_dir: Path,
    logger: logging.Logger,
):
    """Apply patch using the standard patch command.

    Raises:
        subprocess.CalledProcessError: If the patch command fails.
    """

    # Try different patch options in order of preference
    patch_options = [
        # Standard unified diff format, strip 1 path component (most common)
        ["-p1"],
        # Strip 0 path components (when patch was created from target directory)
        ["-p0"],
        # Strip 2 path components (when patch includes extra directory levels)
        ["-p2"],
    ]

    last_error = None

    for options in patch_options:
        cmd = ["patch"] + options + ["-i", str(patch_file)]
        logger.debug(f"Trying patch command: {' '.join(cmd)}")

        try:
            result = subprocess.run(
                cmd,
                cwd=target_dir,
                capture_output=True,
                text=True,
                check=True,
            )

            if result.stdout:
                logger.debug(f"patch stdout: {result.stdout}")

            if result.stderr:
                logger.debug(f"patch stderr: {result.stderr}")

            logger.debug(
                f"Patch applied successfully with options: {' '.join(options)}"
            )
            return

        except subprocess.CalledProcessError as e:
            logger.debug(f"patch failed with options {' '.join(options)}: {e.stderr}")
            last_error = e
            continue

        except FileNotFoundError:
            raise subprocess.CalledProcessError(
                127,
                cmd,
                "patch command not found. Please ensure patch utility is installed.",
            )

    # If we get here, all patch attempts failed
    logger.error(
        f"All patch attempts failed. Last error: {last_error.stderr if last_error else 'Unknown'}"
    )

    if last_error:
        raise last_error
    else:
        raise subprocess.CalledProcessError(
            1, ["patch"], "Failed to apply patch with any strip level"
        )
