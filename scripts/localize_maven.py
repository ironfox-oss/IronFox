#!/usr/bin/env python3
import re
import argparse

def localize_maven(file_path):
    """
    Localize Maven repositories, replacing non-plugin repositories with mavenLocal().

    Handles:
    - Nested braces
    - Single and multi-line comments
    - Both Groovy and Kotlin DSL syntax
    """
    with open(file_path, "r") as f:
        lines = f.readlines()

    processed_lines = []
    maven_block_content = []
    in_maven_block = False
    in_comment = False
    ignore = False
    brace_depth = 0

    for line in lines:
        # Handle single-line comments
        if not in_maven_block and re.match(r'^\s*//.*$', line):
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
        if not in_maven_block and len(re.findall(r'maven\s*\{', line)) > 0:
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

    with open(file_path, "w") as f:
        f.writelines(processed_lines)

    print(f"Processed file: {file_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Localize Maven repositories in Gradle build files."
    )
    parser.add_argument("file", help="Path to the Gradle build file")
    args = parser.parse_args()

    localize_maven(args.file)


if __name__ == "__main__":
    main()
