from functools import singledispatchmethod
import logging
import re

from dataclasses import dataclass
from pathlib import Path
from typing import List
from rich.progress import Progress, TaskID

from .definition import TaskDefinition, BuildDefinition
from .types import (
    GlobalReplacement,
    LineAffixReplacement,
    LineReplacement,
    LiteralReplacement,
    PatternType,
    Replacement,
    ReplacementAction,
)


def on_lines(
    match_lines: PatternType,
    replace: Replacement,
    count: int = 0,
) -> LineReplacement:
    return on_line_text(
        match_lines=match_lines,
        on_text=match_lines,
        replace=replace,
        count=count,
    )


def on_line_text(
    match_lines: PatternType,
    on_text: PatternType,
    replace: Replacement,
    count: int = 0,
) -> LineReplacement:
    return LineReplacement(
        count=count,
        line_match_pattern=match_lines,
        text_match_pattern=on_text,
        replacement=replace,
    )


def regex(
    pattern: PatternType,
    replacement: Replacement,
    count: int = 0,
) -> GlobalReplacement:
    return GlobalReplacement(
        count=count,
        pattern=pattern,
        replacement=replacement,
    )


def line_affix(
    match_lines: PatternType,
    prefix: str = "",
    suffix: str = "",
) -> LineAffixReplacement:
    return LineAffixReplacement(
        count=0,
        line_match_pattern=match_lines,
        prefix=prefix,
        suffix=suffix,
    )


def literal(
    old_text: str,
    new_text: str,
    count: int = 0,
) -> LiteralReplacement:
    return LiteralReplacement(
        count=count,
        old_text=old_text,
        new_text=new_text,
    )


class FindReplaceTask(TaskDefinition):
    """Task for performing string replacements in files."""

    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        target_file: Path,
        replacements: List[ReplacementAction],
        backup: bool = False,
        create_if_missing: bool = False,
    ):
        super().__init__(name, id, build_def)
        self.target_file = target_file
        self.replacements = replacements
        self.backup = backup
        self.create_if_missing = create_if_missing

    def execute(self, params):
        task_id = params.progress.add_task(
            f"Processing file: {self.target_file.name}",
            total=len(self.replacements),
        )

        try:
            return find_replace(
                target_file=self.target_file,
                replacements=self.replacements,
                progress=params.progress,
                logger=self.logger,
                backup=self.backup,
                create_if_missing=self.create_if_missing,
            )
        finally:
            params.progress.remove_task(task_id=task_id)


def find_replace(
    target_file: Path,
    replacements: List[ReplacementAction],
    progress: Progress,
    logger: logging.Logger,
    backup: bool = False,
    create_if_missing: bool = False,
):
    task_id = progress.add_task(
        f"Processing file {target_file.name}", total=len(replacements)
    )
    try:
        if not target_file.exists():
            if create_if_missing:
                target_file.touch()
            else:
                raise FileNotFoundError(f"Target file {target_file} does not exist")

        with open(target_file, "r", encoding="utf-8") as f:
            original_content = f.read()

        if backup:
            backup_path = Path(str(target_file) + ".bak")
            with open(backup_path, "w", encoding="utf-8") as f:
                f.write(original_content)

        modified_content = _apply_replacements(
            content=original_content,
            replacements=replacements,
            task_id=task_id,
            progress=progress,
        )

        with open(target_file, "w", encoding="utf-8") as f:
            f.write(modified_content)

        logger.debug(f"Applied {len(replacements)} replacements to {target_file}")
    finally:
        progress.remove_task(task_id)


def _apply_replacements(
    content: str,
    replacements: List[ReplacementAction],
    task_id: TaskID,
    progress: Progress,
) -> str:
    result = content

    for replacement in replacements:
        if isinstance(replacement, LiteralReplacement):
            result = result.replace(
                replacement.old_text,
                replacement.new_text,
                replacement.count,
            )

        elif isinstance(replacement, GlobalReplacement):
            if callable(replacement.replacement):
                result = re.sub(
                    pattern=replacement.pattern,
                    repl=replacement.replacement(result),
                    string=result,
                    count=replacement.count,
                )
            else:
                result = re.sub(
                    replacement.pattern,
                    replacement.replacement,
                    result,
                )

        elif isinstance(replacement, LineReplacement):
            lines = result.splitlines(keepends=True)
            modified_lines = []

            for line in lines:
                if re.search(replacement.line_match_pattern, line):
                    if callable(replacement.replacement):
                        modified_line = replacement.replacement(line)
                    else:
                        modified_line = re.sub(
                            replacement.text_match_pattern,
                            replacement.replacement,
                            line,
                        )
                    modified_lines.append(modified_line)
                else:
                    modified_lines.append(line)

            result = "".join(modified_lines)

        elif isinstance(replacement, LineAffixReplacement):
            lines = result.splitlines(keepends=True)
            modified_lines = []
            for line in lines:
                if re.search(replacement.line_match_pattern, line):
                    modified_lines.append(
                        f"{replacement.prefix}{line.rstrip()}{replacement.suffix}\n"
                    )
                else:
                    modified_lines.append(line)
            result = "".join(modified_lines)

        progress.update(task_id, advance=1)

    return result
