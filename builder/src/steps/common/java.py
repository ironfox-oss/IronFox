from __future__ import annotations

import re
from typing import Tuple
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition, TaskDefinition


def setup_java(d: BuildDefinition, paths: Paths) -> TaskDefinition:
    java = paths.java_home / "bin" / "java"

    def do_check_java_version(output: str) -> Tuple[bool, str] | None:
        if not output:
            return None

        match = re.search(r'version\s+"([\d._]+)"', output)
        if not match:
            return (False, f"Failed to parse Java version from: {output}")

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
        result = do_check_java_version(stderr if stderr else stdout)
        if result is None:
            raise RuntimeError("Failed to check Java version. Is 'java' installed?")

        success, message = result
        if not success:
            raise RuntimeError(message)

    return d.run_cmds(
        name="Check java version",
        # Use '-version' for backwards compatibility
        # '--version' on newer versions of the JDK do not include the 'version' string
        commands=[(f"{java} -version", check_java_version)],
    )
