import re

from pathlib import Path
from execution.common import FileOpTask


class LocalizeMavenTask(FileOpTask):
    def __init__(self, name, id, build_def, target):
        super().__init__(name, id, build_def, target)

    def execute(self, params):
        task_id = params.progress.add_task(f"Localize maven: {self.target}")
        try:
            if self.target.is_dir():
                raise ValueError(
                    f"Cannot localize maven for path {self.target}: is a directory"
                )

            localize_maven(self.target)
        finally:
            params.progress.remove_task(task_id=task_id)


def localize_maven(file: Path):
    """
    Localize Maven repositories, replacing non-plugin repositories with mavenLocal().

    Handles:
    - Nested braces
    - Single and multi-line comments
    - Both Groovy and Kotlin DSL syntax
    """
    with open(file, "r") as f:
        lines = f.readlines()

    processed_lines = []
    maven_block_content = []
    in_maven_block = False
    in_comment = False
    ignore = False
    brace_depth = 0

    for line in lines:
        # Handle single-line comments
        if not in_maven_block and re.match(r"^\s*//.*$", line):
            processed_lines.append(line)
            continue

        # Handle multi-line comments
        if not in_comment and "/*" in line:
            if "*/" not in line:
                in_comment = True
            if in_maven_block:
                maven_block_content.append(line)
            else:
                processed_lines.append(line)
            continue

        if in_comment:
            if "*/" in line:
                in_comment = False
            if in_maven_block:
                maven_block_content.append(line)
            else:
                processed_lines.append(line)
            continue

        # Track maven blocks
        if not in_maven_block and len(re.findall(r"maven\s*\{", line)) > 0:
            in_maven_block = True
            brace_depth = 1
            maven_block_content = [line]
            ignore = False
            continue

        if in_maven_block:
            brace_depth += line.count("{") - line.count("}")
            maven_block_content.append(line)

            if "plugins.gradle.org" in line:
                ignore = True

            if brace_depth == 0:
                if ignore:
                    processed_lines.extend(maven_block_content)
                else:
                    processed_lines.append("        mavenLocal()\n")

                # Reset state
                in_maven_block = False
                maven_block_content = []
                ignore = False
                continue

        if not in_maven_block:
            processed_lines.append(line)

    with open(file, "w") as f:
        f.writelines(processed_lines)
