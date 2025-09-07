import logging
import re
import shutil

from pathlib import Path
from typing import List, Optional, Union
from rich.progress import Progress

from .definition import TaskDefinition, BuildDefinition
from .types import PatternType, Replacement


class FindReplaceTask(TaskDefinition):
    """Task for performing string replacements in files."""

    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        target_file: Path,
        replacement: Replacement,
        backup: bool = False,
        create_if_missing: bool = False,
        match_lines: Optional[PatternType] = None,
    ):
        super().__init__(name, id, build_def)
        self.target_file = target_file
        self.replacement = replacement
        self.backup = backup
        self.create_if_missing = create_if_missing
        self.match_lines = match_lines

    def execute(self, params):
        return find_replace(
            target_file=self.target_file,
            replacement=self.replacement,
            progress=params.progress,
            logger=self.logger,
            backup=self.backup,
            create_if_missing=self.create_if_missing,
            match_lines=self.match_lines,
        )


def find_replace(
    target_file: Path,
    replacement: Replacement,
    progress: Progress,
    logger: logging.Logger,
    backup: bool = False,
    create_if_missing: bool = False,
    match_lines: Optional[PatternType] = None,
):
    task_id = progress.add_task(f"Processing file: {target_file.name}", total=None)

    try:
        if not target_file.exists():
            if create_if_missing:
                target_file.parent.mkdir(parents=True, exist_ok=True)
                target_file.touch()
            else:
                logger.warning(f"File {target_file} does not exist, skipping")
                return

        content: Union[List[str], str]
        modified_content: Union[List[str], str]
        with open(target_file, "r", encoding="utf-8", errors="ignore") as f:
            if match_lines:
                content = f.readlines()
            else:
                content = f.read()

        modified_content = content
        if (
            match_lines
            and isinstance(content, list)
            and isinstance(modified_content, list)
        ):
            for line in content:
                modified_line = line
                if len(re.findall(match_lines, line)) > 0:
                    modified_line = replacement(line)
                modified_content.append(modified_line)
        elif (
            not match_lines
            and isinstance(content, str)
            and isinstance(modified_content, str)
        ):
            modified_content = replacement(content)
        else:
            raise RuntimeError(
                f"Invalid state: "
                "match_lines={match_lines}, "
                "content={type(content)}, "
                "modified_content={type(modified_content)}"
            )

        # Write back if changed
        if modified_content != content:
            if backup:
                backup_path = target_file.with_suffix(target_file.suffix + ".bak")
                shutil.copy2(target_file, backup_path)

            if isinstance(modified_content, list):
                new_content = "".join(modified_content)
            else:
                new_content = modified_content

            with open(target_file, "w", encoding="utf-8") as f:
                f.write(new_content)

            logger.debug(f"Applied replacements to {target_file}")

        progress.update(task_id, advance=1)

    except Exception as e:
        logger.error(f"Failed to process {target_file}: {e}")
        raise

    progress.remove_task(task_id)
