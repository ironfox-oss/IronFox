from __future__ import annotations

import re
from typing import Tuple
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition


def setup_java(d: BuildDefinition, paths: Paths):
    java = paths.java_home / "bin" / "java"

    def do_check_java_version(output: str) -> Tuple[bool, str] | None:
        match = re.search(r'version\s+"([\d._]+)"', output)
        if not match:
            return None

        version_str = match.group(1)
        parts = version_str.split(".")

        # Handle versions like "1.8.0_321" (Java 8)
        if parts[0] == "1":
            major_version = int(parts[1])
        else:
            major_version = int(parts[0])

        if major_version != Versions.JAVA_VERSION:
            return (
                False,
                f"Java {Versions.JAVA_VERSION} is required to build IronFox. Current version: {version_str}",
            )

        return (True, f"Detected Java version '{version_str}'")

    def check_java_version(stdout: str, stderr: str):
        stdout, stderr = stdout.strip(), stderr.strip()

        if len(stderr) > 0 and do_check_java_version(stderr):
            return

        do_check_java_version(stdout)

    d.run_commands(
        name="Check java version",
        commands=[(f"{java} --version", check_java_version)],
    )
