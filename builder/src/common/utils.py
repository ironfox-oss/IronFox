"""Utility methods for various purposes."""

from __future__ import annotations

import errno
import os
import platform
import subprocess

from glob import glob
from pathlib import Path
from typing import List, Union

CHUNK_SIZE = 16 * 1024  # 16KB


def sha256sum(file_path: Path) -> str:
    """Calculate the SHA-256 checksum of a file."""
    import hashlib

    sha256 = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(CHUNK_SIZE), b""):
            sha256.update(chunk)
    return sha256.hexdigest()


def format_bytes(bytes_count: float) -> str:
    """Format byte count in human-readable format."""
    if bytes_count == 0:
        return "0 B"

    units = ["B", "KB", "MB", "GB", "TB"]
    unit_index = 0
    size = bytes_count

    while size >= 1024.0 and unit_index < len(units) - 1:
        size /= 1024.0
        unit_index += 1

    return f"{size:.1f} {units[unit_index]}"


def is_blank(str: str) -> bool:
    """Whether the given string is blank (empty or whitespace-only)."""
    return len(str.strip()) == 0


def current_platform() -> str:
    """The current platform/system name."""
    return platform.system()


def current_machine() -> str:
    """The current machine type"""
    machine = platform.machine()
    if machine == "arm64":
        machine = "aarch64"
    return machine


def is_windows() -> bool:
    """Whether the current platform is Windows."""
    return current_platform() == "Windows"


def is_linux() -> bool:
    """Whether the current platform is Linux."""
    return current_platform() == "Linux"


def is_macos() -> bool:
    """Whether the current platform is MacOS."""
    return current_platform() == "Darwin"


def ndk_host_tag() -> str:
    if is_linux():
        return "linux-x86_64"
    elif is_macos():
        return "darwin-x86_64"
    elif is_windows():
        return "windows-x86_64"
    else:
        raise RuntimeError(f"Unsupported platform: {current_platform()}")


def __is_tool(name: str):
    try:
        devnull = open(os.devnull)
        subprocess.Popen([name], stdout=devnull, stderr=devnull).communicate()
    except OSError as e:
        if e.errno == errno.ENOENT:
            return False
    return True


def find_prog(prog: str) -> Path | None:
    """Find path to the given program."""
    if not __is_tool(prog):
        return None

    which = "where" if is_windows() else "which"
    cmd: str | None = None
    try:
        cmd = str(subprocess.check_output([which, prog]))
    except subprocess.CalledProcessError:
        cmd = None

    if not cmd:
        return None

    path = Path(cmd)
    if not path.exists():
        return None

    return path


def resolve_glob(
    target_file: Union[Path, str],
    recursive: bool = False,
) -> List[Path]:
    if isinstance(target_file, Path) and any(c in str(target_file) for c in "*?[]"):
        files = [Path(p) for p in glob(str(target_file), recursive=recursive)]
    elif isinstance(target_file, str) and any(c in target_file for c in "*?[]"):
        files = [Path(p) for p in glob(target_file, recursive=recursive)]
    else:
        files = [target_file if isinstance(target_file, Path) else Path(target_file)]

    return files
