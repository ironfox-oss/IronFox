import logging
import os
from pathlib import Path
from rich.progress import Progress
from typing import Callable

from ..common.utils import format_bytes
from .definition import TaskDefinition

logger = logging.getLogger("Files")


class CreateFileTask(TaskDefinition):
    def __init__(
        self,
        name,
        id,
        build_def,
        file: Path,
        contents: Callable[[], bytes],
        chmod: int = 0o644,
        overwrite: bool = False,
    ):
        super().__init__(name, id, build_def)
        self.file = file
        self.contents = contents
        self.chmod = chmod
        self.overwrite = overwrite

    def execute(self, progress):
        create_file_with_progress(
            destination=self.file,
            contents_func=self.contents,
            progress=progress,
            chmod=self.chmod,
            overwrite=self.overwrite,
        )
        return super().execute(progress)


def create_file_with_progress(
    destination: Path,
    contents_func: Callable[[], bytes],
    progress: Progress,
    chmod: int = 0o644,
    overwrite: bool = False,
):
    if destination.exists() and not overwrite:
        raise RuntimeError(f"Cannot create {destination}. File already exists!")

    try:
        content_bytes = contents_func()
    except Exception as e:
        logger.error(f"Failed to generate contents for {destination}: {e}")
        raise

    total_size = len(content_bytes)

    # Ensure parent directories exist
    try:
        destination.parent.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        logger.error(f"Failed to create directories for {destination}: {e}")
        raise

    task_id = progress.add_task(f"Writing {destination.name}", total=total_size)
    written = 0

    try:
        with open(destination, "wb") as f:
            chunk_size = 16 * 1024  # Write in 16KB chunks
            while written < total_size:
                end = min(written + chunk_size, total_size)
                chunk = content_bytes[written:end]
                f.write(chunk)
                progress.update(task_id, advance=len(chunk))
                written += len(chunk)

        os.chmod(destination, chmod)
        logger.info(f"File written: {destination} ({format_bytes(total_size)})")

    except Exception as e:
        logger.error(f"Failed to write to {destination}: {e}")
        if destination.exists():
            try:
                destination.unlink()
                logger.debug("Partial file removed after error.")
            except Exception as cleanup_error:
                logger.warning(f"Failed to clean up partial file: {cleanup_error}")
        raise

    finally:
        progress.remove_task(task_id)
