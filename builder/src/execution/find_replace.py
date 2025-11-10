import asyncio
from functools import singledispatchmethod
import logging
import re

from dataclasses import dataclass
from pathlib import Path
from typing import Callable, List
from rich.progress import Progress, TaskID

import aiofiles

from .definition import TaskDefinition, BuildDefinition
from .types import (
    CustomReplacement,
    RegexReplacement,
    LineAffixReplacement,
    LineReplacement,
    PatternType,
    Replacement,
    Replacer,
    ReplacementAction,
)


def custom_replacement(
    replacer: Replacer,
) -> CustomReplacement:
    return CustomReplacement(
        count=1,
        replacer=replacer,
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
) -> RegexReplacement:
    return RegexReplacement(
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


def eol_comment_line(
    match_lines: PatternType,
    comment_token: str = "//",
) -> LineAffixReplacement:
    return line_affix(match_lines=match_lines, prefix=comment_token)


def eol_comment_text(
    match_text: PatternType,
    comment_token: str = "//",
) -> RegexReplacement:
    return regex(
        pattern=match_text,
        replacement=rf"{comment_token} \g<0>",
    )


def literal(
    old_text: str,
    new_text: str,
    count: int = 0,
) -> RegexReplacement:
    return RegexReplacement(
        count=count,
        pattern=re.escape(old_text),
        replacement=new_text,
    )


class FindReplaceTask(TaskDefinition):
    """Task for performing replacements on multiple files (batched)."""

    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        target_files: List[Path],  # Multiple files
        replacements: List[ReplacementAction],
        backup: bool = False,
        create_if_missing: bool = False,
    ):
        super().__init__(name, id, build_def)
        self.target_files = target_files
        self.replacements = replacements
        self.backup = backup
        self.create_if_missing = create_if_missing

    async def execute(self, params):
        progress = params.progress
        name = f"Process files (0/{len(self.target_files)})"
        task_id = progress.add_task(name, total=len(self.target_files))

        try:
            for index, target_file in enumerate(self.target_files):
                await find_replace(
                    target_file=target_file,
                    replacements=self.replacements,
                    logger=self.logger,
                    backup=self.backup,
                    create_if_missing=self.create_if_missing,
                )
                progress.update(task_id, completed=index + 1)
        finally:
            progress.remove_task(task_id)


async def find_replace(
    target_file: Path,
    replacements: List[ReplacementAction],
    logger: logging.Logger,
    backup: bool = False,
    create_if_missing: bool = False,
):
    try:
        if not target_file.exists():
            if create_if_missing:
                target_file.touch()
            else:
                logger.warning(
                    f"Target file {target_file} does not exist. Skipping find-replace."
                )
                return

        async with aiofiles.open(target_file, "r", encoding="utf-8") as f:
            original_content = await f.read()

        if backup:
            backup_path = Path(str(target_file) + ".bak")
            with open(backup_path, "w", encoding="utf-8") as f:
                f.write(original_content)

        loop = asyncio.get_event_loop()
        modified_content = await loop.run_in_executor(
            None,
            _apply_replacements,
            original_content,
            replacements,
        )

        async with aiofiles.open(target_file, "w", encoding="utf-8") as f:
            await f.write(modified_content)

        logger.debug(f"Applied {len(replacements)} replacements to {target_file}")
    except UnicodeDecodeError:
        # ignore non-utf files
        pass


def _apply_replacements(
    content: str,
    replacements: List[ReplacementAction],
) -> str:
    result = content

    for replacement in replacements:
        if isinstance(replacement, RegexReplacement):
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
                    string=result,
                    count=replacement.count,
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
                            pattern=replacement.text_match_pattern,
                            repl=replacement.replacement,
                            string=line,
                            count=replacement.count,
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
        elif isinstance(replacement, CustomReplacement):
            result = replacement.replacer(result)
    return result
