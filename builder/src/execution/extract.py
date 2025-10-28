from __future__ import annotations

import shutil
import logging
import os
import zipfile
import tarfile
import stat

from pathlib import Path
from rich.progress import Progress

from .definition import BuildDefinition, TaskDefinition
from common.utils import format_bytes


class ExtractTask(TaskDefinition):
    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        archive_file: Path,
        extract_to: Path,
        archive_format: str,
        preserve_permissions: bool = True,
    ):
        super().__init__(name, id, build_def)
        self.archive_file = archive_file
        self.extract_to = extract_to
        self.archive_format = archive_format
        self.preserve_permissions = preserve_permissions

    async def execute(self, params):
        return extract_archive(
            archive_file=self.archive_file,
            extract_to=self.extract_to,
            archive_format=self.archive_format,
            logger=self.logger,
            preserve_permissions=self.preserve_permissions,
        )


def extract_archive(
    archive_file: Path,
    extract_to: Path,
    archive_format: str,
    logger: logging.Logger,
    preserve_permissions: bool = True,
):
    logger.info(f"Extracting {archive_file} to {extract_to}")

    if not archive_file.exists():
        raise FileNotFoundError(f"Archive file not found: {archive_file}")

    if not archive_file.is_file():
        raise ValueError(f"Archive path is not a file: {archive_file}")

    try:
        extract_to.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        logger.error(f"Failed to create extraction directory {extract_to}: {e}")
        raise

    if not os.access(extract_to, os.W_OK):
        raise PermissionError(
            f"No write permission for extraction directory: {extract_to}"
        )

    # Check available space (basic check)
    try:
        archive_size = archive_file.stat().st_size
        available_space = shutil.disk_usage(extract_to).free

        # Rough estimate: extracted size could be 2-10x compressed size
        estimated_extracted_size = archive_size * 5  # Conservative estimate

        if available_space < estimated_extracted_size:
            logger.warning(
                f"Low disk space: {format_bytes(available_space)} available, "
                f"estimated need: {format_bytes(estimated_extracted_size)}"
            )

        logger.debug(f"Archive size: {format_bytes(archive_size)}")

    except OSError as e:
        logger.debug(f"Could not check disk space: {e}")

    # Extract based on format
    try:
        if archive_format == "zip":
            _extract_zip(archive_file, extract_to, logger, preserve_permissions)
        elif archive_format in ("tar", "gztar", "bztar", "xztar"):
            _extract_tar(
                archive_file,
                extract_to,
                archive_format,
                logger,
                preserve_permissions,
            )
        else:
            raise ValueError(f"Unsupported archive format: {archive_format}")

        logger.info(f"Successfully extracted {archive_file} to {extract_to}")

    except Exception as e:
        logger.error(f"Failed to extract {archive_file}: {e}")
        # Don't clean up partial extraction - user might want to inspect it
        raise


def _extract_zip(
    archive_file: Path,
    extract_to: Path,
    logger: logging.Logger,
    preserve_permissions: bool = True,
):
    """Extract a ZIP archive with progress tracking and error handling."""
    task_id = None

    try:
        with zipfile.ZipFile(archive_file, "r") as zip_ref:
            logger.debug("Testing ZIP file integrity...")
            try:
                bad_file = zip_ref.testzip()
                if bad_file:
                    raise zipfile.BadZipFile(f"Corrupted file in archive: {bad_file}")
            except Exception as e:
                logger.warning(f"ZIP integrity test failed: {e}")
                # Continue anyway - some ZIP files have issues with testzip but extract fine

            members = zip_ref.infolist()
            total_files = len(members)

            if total_files == 0:
                logger.warning("ZIP archive appears to be empty")
                return

            logger.info(f"Extracting {total_files} files from ZIP archive")

            extracted_count = 0
            total_size = 0

            for member in members:
                try:
                    # Security check: prevent path traversal attacks
                    if _is_safe_path(extract_to, member.filename, logger):
                        zip_ref.extract(member, extract_to)
                        extracted_count += 1
                        total_size += member.file_size

                        # Preserve permissions if requested and supported
                        if preserve_permissions:
                            _set_zip_permissions(
                                extract_to / member.filename,
                                member,
                                logger,
                            )

                        # Log progress for large extractions
                        if extracted_count % 100 == 0:
                            logger.debug(
                                f"Extracted {extracted_count}/{total_files} files"
                            )

                    else:
                        logger.warning(f"Skipping unsafe path: {member.filename}")

                except Exception as e:
                    logger.error(f"Failed to extract {member.filename}: {e}")

            logger.info(
                f"Extracted {extracted_count}/{total_files} files, total size: {format_bytes(total_size)}"
            )

    except zipfile.BadZipFile as e:
        logger.error(f"Invalid or corrupted ZIP file: {e}")
        raise

    except Exception as e:
        logger.error(f"Error extracting ZIP file: {e}")
        raise


def _extract_tar(
    archive_file: Path,
    extract_to: Path,
    archive_format: str,
    logger: logging.Logger,
    preserve_permissions: bool = True,
):
    """Extract a TAR archive with progress tracking and error handling."""
    task_id = None

    # Determine the correct mode based on format
    mode_map = {"tar": "r", "gztar": "r:gz", "bztar": "r:bz2", "xztar": "r:xz"}

    mode = mode_map.get(archive_format, "r")

    try:
        with tarfile.open(archive_file, mode) as tar_ref:  # type: ignore
            members = tar_ref.getmembers()
            total_files = len(members)

            if total_files == 0:
                logger.warning("TAR archive appears to be empty")
                return

            logger.info(f"Extracting {total_files} files from TAR archive")

            extracted_count = 0
            total_size = 0

            for member in members:
                try:
                    # Security checks
                    if not _is_safe_tar_member(extract_to, member, logger):
                        logger.warning(f"Skipping unsafe tar member: {member.name}")
                        continue

                    tar_ref.extract(member, extract_to, set_attrs=preserve_permissions)
                    extracted_count += 1
                    total_size += member.size if member.size else 0

                    # Log progress for large extractions
                    if extracted_count % 100 == 0:
                        logger.debug(f"Extracted {extracted_count}/{total_files} files")

                except Exception as e:
                    logger.error(f"Failed to extract {member.name}: {e}")

            logger.info(
                f"Extracted {extracted_count}/{total_files} files, total size: {format_bytes(total_size)}"
            )

    except tarfile.TarError as e:
        logger.error(f"Invalid or corrupted TAR file: {e}")
        raise

    except Exception as e:
        logger.error(f"Error extracting TAR file: {e}")
        raise


def _set_zip_permissions(
    file_path: Path,
    zip_info: zipfile.ZipInfo,
    logger: logging.Logger,
):
    """Set file permissions for extracted ZIP files."""
    try:
        # ZIP files store Unix permissions in the external_attr field
        # The permissions are in the high 16 bits
        if hasattr(zip_info, "external_attr") and zip_info.external_attr:
            # Extract Unix permissions (high 16 bits)
            unix_permissions = zip_info.external_attr >> 16

            if unix_permissions:
                # Only set permissions if they seem valid (not zero)
                # Filter out potentially dangerous permissions
                safe_permissions = unix_permissions & 0o777  # Keep only rwx bits

                # Ensure owner has at least read permission
                if safe_permissions & 0o400 == 0:
                    safe_permissions |= 0o400

                os.chmod(file_path, safe_permissions)
                logger.debug(f"Set permissions {oct(safe_permissions)} for {file_path}")
            else:
                # Set default permissions if no valid permissions found
                _set_default_permissions(
                    file_path, logger, zip_info.filename.endswith("/")
                )
        else:
            # Set default permissions if external_attr is not available
            _set_default_permissions(file_path, logger, zip_info.filename.endswith("/"))

    except (OSError, PermissionError) as e:
        logger.debug(f"Failed to set permissions for {file_path}: {e}")
    except Exception as e:
        logger.debug(f"Unexpected error setting permissions for {file_path}: {e}")


def _set_default_permissions(
    file_path: Path, logger: logging.Logger, is_directory: bool = False
):
    """Set default permissions for extracted files."""
    try:
        if is_directory:
            # Default directory permissions: rwxr-xr-x (755)
            os.chmod(file_path, 0o755)
        else:
            # Default file permissions: rw-r--r-- (644)
            os.chmod(file_path, 0o644)
    except (OSError, PermissionError) as e:
        logger.debug(f"Failed to set default permissions for {file_path}: {e}")


def _is_safe_path(
    base_path: Path,
    filename: str,
    logger: logging.Logger,
) -> bool:
    """Check if a filename is safe to extract (prevents directory traversal)."""
    try:
        # Resolve the full path
        full_path = (base_path / filename).resolve()
        base_resolved = base_path.resolve()

        # Check if the resolved path is within the base directory
        return str(full_path).startswith(str(base_resolved))

    except Exception as e:
        logger.debug(f"Path safety check failed for {filename}: {e}")
        return False


def _is_safe_tar_member(
    base_path: Path,
    member: tarfile.TarInfo,
    logger: logging.Logger,
) -> bool:
    """Check if a tar member is safe to extract."""
    # Check for directory traversal
    if not _is_safe_path(base_path, member.name, logger):
        return False

    # Check for absolute paths
    if member.name.startswith("/"):
        logger.warning(f"Skipping absolute path: {member.name}")
        return False

    # Check for suspicious file types
    if member.isdev():
        logger.warning(f"Skipping device file: {member.name}")
        return False

    # Check for overly large files (>10GB)
    if member.size and member.size > 10 * 1024 * 1024 * 1024:
        logger.warning(
            f"Skipping very large file: {member.name} ({format_bytes(member.size)})"
        )
        return False

    # Additional security check for permissions (if preserving permissions)
    if hasattr(member, "mode") and member.mode:
        # Check for potentially dangerous permissions
        if member.mode & stat.S_ISUID:  # setuid bit
            logger.warning(f"Skipping file with setuid bit: {member.name}")
            return False
        if member.mode & stat.S_ISGID:  # setgid bit
            logger.warning(f"Skipping file with setgid bit: {member.name}")
            return False
        if (
            member.mode & stat.S_ISVTX and not member.isdir()
        ):  # sticky bit on non-directory
            logger.warning(f"Skipping non-directory with sticky bit: {member.name}")
            return False

    return True
