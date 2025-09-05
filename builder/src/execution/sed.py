import logging
import re
import shutil

from pathlib import Path
from typing import List, Tuple, Union, Callable
from re import Pattern, Match
from rich.progress import Progress

from .definition import TaskDefinition, BuildDefinition

from .types import TargetFilesType, Replacement

logger = logging.getLogger("SedTask")


class SedTask(TaskDefinition):
    """Task for performing sed-like string replacements in files."""

    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        target_files: TargetFilesType,
        replacements: List[Replacement],
        backup: bool = False,
        create_if_missing: bool = False,
    ):
        super().__init__(name, id, build_def)
        self.target_files = [
            Path(f)
            for f in (
                target_files if isinstance(target_files, list) else [target_files]
            )
        ]
        self.replacements = replacements
        self.backup = backup
        self.create_if_missing = create_if_missing

    def execute(self, params):
        return sed_replace(
            target_files=self.target_files,
            replacements=self.replacements,
            progress=params.progress,
            backup=self.backup,
            create_if_missing=self.create_if_missing,
        )


def sed_replace(
    target_files: List[Path],
    replacements: List[Replacement],
    progress: Progress,
    backup: bool = False,
    create_if_missing: bool = False,
):
    task_id = progress.add_task(
        f"Processing {len(target_files)} files", total=len(target_files)
    )

    for file_path in target_files:
        try:
            if not file_path.exists():
                if create_if_missing:
                    file_path.parent.mkdir(parents=True, exist_ok=True)
                    file_path.touch()
                else:
                    logger.warning(f"File {file_path} does not exist, skipping")
                    continue

            # Read file content
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()

            # Apply replacements
            modified_content = content
            for replacement in replacements:
                pattern, replace_with, flags = "", "", 0
                if len(replacement) == 3:
                    pattern, replace_with, flags = replacement
                else:
                    pattern, replacement = replacement

                if pattern:
                    modified_content = re.sub(
                        pattern=pattern,
                        repl=replace_with,
                        string=modified_content,
                        flags=flags,
                    )

            # Write back if changed
            if modified_content != content:
                if backup:
                    backup_path = file_path.with_suffix(file_path.suffix + ".bak")
                    shutil.copy2(file_path, backup_path)

                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(modified_content)

                logger.debug(f"Applied {len(replacements)} replacements to {file_path}")

            progress.update(task_id, advance=1)

        except Exception as e:
            logger.error(f"Failed to process {file_path}: {e}")
            raise

    progress.remove_task(task_id)
