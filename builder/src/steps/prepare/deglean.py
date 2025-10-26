import os
from pathlib import Path
import re
from typing import List
from execution.definition import BuildDefinition, TaskDefinition
from execution.find_replace import (
    comment_out,
    custom_replacement,
)
from execution.types import ReplacementAction


def deglean(d: BuildDefinition, dir: Path) -> List[TaskDefinition]:
    global _process_file

    def _process_file(
        path: str,
        replacements: List[ReplacementAction],
    ) -> List[TaskDefinition]:
        return d.find_replace(
            name=f"Process {path}",
            target_file=dir / path,
            replacements=replacements,
        )

    def _rm(
        path: str,
        recursive: bool = False,
    ) -> List[TaskDefinition]:
        return d.delete(name=f"Delete {path}", path=dir / path, recursive=recursive)

    return [
        *_process_file(
            path="**/*.gradle",
            replacements=[
                custom_replacement(wrap_ext),
                comment_out(r"^.*apply plugin:.*glean.*$"),
                comment_out(r"^.*classpath.*glean.*$"),
                comment_out(r"^.*compileOnly.*glean.*$"),
                comment_out(r"^.*implementation.*glean.*$"),
                comment_out(r"^.*testImplementation.*glean.*$"),
            ],
        ),
        *_process_file(
            path="**/*.kt",
            replacements=[
                comment_out(r"^.*import mozilla.telemetry.*$"),
                comment_out(r"^.*GleanMetrics.*$"),
            ],
        ),
        *_rm("**/metrics.yaml"),
        *_rm("**/pings.yaml"),
    ]


def wrap_ext(content: str) -> str:
    lines = content.splitlines(keepends=False)

    processed_lines = []
    in_ext_block = False
    ext_block_content = []
    brace_depth = 0
    contains_glean = False

    for line in lines:
        # Check for the start of the ext block
        if not in_ext_block and re.match(r"^\s*ext\s*\{", line):
            in_ext_block = True
            brace_depth = 1
            ext_block_content.append(line)
            continue

        if in_ext_block:
            ext_block_content.append(line)
            # Check if the line starts with "glean" (case insensitive)
            if line.strip().lower().startswith(
                "glean"
            ) and not line.strip().lower().startswith("gleanversion"):
                contains_glean = True

            brace_depth += line.count("{") - line.count("}")

            # Check for the end of the ext block
            if brace_depth == 0:
                # Wrap the ext block content in multi-line comments only if it contains "Glean"
                if contains_glean:
                    processed_lines.append("/*\n")
                    processed_lines.extend(ext_block_content)
                    processed_lines.append("*/\n")
                else:
                    processed_lines.extend(ext_block_content)

                # Reset state
                in_ext_block = False
                ext_block_content = []
                contains_glean = False
                continue

        # If not in an ext block, just append the line
        else:
            processed_lines.append(line)

    return os.linesep.join(processed_lines)
