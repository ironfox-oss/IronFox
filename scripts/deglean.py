#!/usr/bin/env python3
import re
import argparse

def deglean(file_path):
    """
    Wraps the 'ext { ... }' block in multi-line comments in a Gradle build file
    only if it contains lines that start with 'glean'.
    """
    with open(file_path, "r") as f:
        lines = f.readlines()

    processed_lines = []
    in_ext_block = False
    ext_block_content = []
    brace_depth = 0
    contains_glean = False

    for line in lines:
        # Check for the start of the ext block
        if not in_ext_block and re.match(r'^\s*ext\s*\{', line):
            in_ext_block = True
            brace_depth = 1
            ext_block_content.append(line)
            continue

        if in_ext_block:
            ext_block_content.append(line)
            # Check if the line starts with "glean" (case insensitive)
            if line.strip().lower().startswith("glean") and not line.strip().lower().startswith("gleanversion"):
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

    with open(file_path, "w") as f:
        f.writelines(processed_lines)

def main():
    parser = argparse.ArgumentParser(
        description="Wrap 'ext { ... }' blocks in multi-line comments in Gradle build files."
    )
    parser.add_argument("file", help="Path to the Gradle build file")
    args = parser.parse_args()

    deglean(args.file)

if __name__ == "__main__":
    main()
