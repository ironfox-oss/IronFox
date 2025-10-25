from __future__ import annotations

import logging
import os

from pathlib import Path
import shutil
from rich.progress import Progress
from typing import Callable, Union

from common.utils import format_bytes
from .definition import TaskDefinition


class FileOpTask(TaskDefinition):
    def __init__(self, name, id, build_def, target: Path):
        super().__init__(name, id, build_def)
        self.target = target


class CopyTask(FileOpTask):
    def __init__(
        self, name, id, build_def, target, source: Path, recursive: bool = False
    ):
        super().__init__(name, id, build_def, target)
        self.source = source
        self.recursive = recursive

    def execute(self, params):
        progress = params.progress
        task_id = progress.add_task(f"Copy {self.source} to {self.target}")

        try:
            if not self.source.is_dir():
                shutil.copyfile(self.source, self.target)
            else:
                shutil.copytree(self.source, self.target)
        finally:
            progress.remove_task(task_id=task_id)


class WriteFileTask(FileOpTask):
    def __init__(
        self,
        name,
        id,
        build_def,
        target,
        contents: Callable[[], bytes],
        chmod: int = 0o644,
        append: bool = False,
        overwrite: bool = False,
    ):
        super().__init__(name, id, build_def, target)
        self.contents = contents
        self.chmod = chmod
        self.append = append
        self.overwrite = overwrite

    def execute(self, params):
        return write_file_with_progress(
            destination=self.target,
            contents_func=self.contents,
            progress=params.progress,
            logger=self.logger,
            chmod=self.chmod,
            append=self.append,
            overwrite=self.overwrite,
        )


class DirCreateTask(FileOpTask):
    def __init__(
        self, name, id, build_def, target, parents: bool = False, exist_ok: bool = False
    ):
        super().__init__(name, id, build_def, target)
        self.parent = parents
        self.exist_ok = exist_ok

    def execute(self, params):
        progress = params.progress
        task_id = progress.add_task(f"Create directory {self.target}")
        try:
            self.target.mkdir(parents=self.parent, exist_ok=self.exist_ok)
        finally:
            try:
                progress.remove_task(task_id)
            except:
                pass


class DeleteTask(FileOpTask):

    def __init__(self, name, id, build_def, target, recursive: bool = False):
        super().__init__(name, id, build_def, target)
        self.recursive = recursive

    def execute(self, params):
        progress = params.progress
        task_id = progress.add_task(f"Delete {self.target}")

        try:
            if not self.target.exists():
                return
            
            if self.target.is_dir():
                if not self.recursive:
                    raise RuntimeError(
                        f"Cannot delete directory {self.target} without recursive flag"
                    )

                shutil.rmtree(self.target)
            else:
                self.target.unlink()
        finally:
            try:
                progress.remove_task(task_id)
            except:
                pass


def write_file_with_progress(
    destination: Path,
    contents_func: Callable[[], bytes],
    progress: Progress,
    logger: logging.Logger,
    chmod: int = 0o644,
    append: bool = False,
    overwrite: bool = False,
):
    if destination.exists() and not (overwrite or append):
        raise RuntimeError(f"Cannot write {destination}. File already exists!")

    try:
        content_bytes = contents_func()
    except Exception as e:
        logger.error(f"Failed to generate contents for {destination}: {e}")
        raise

    new_data_size = len(content_bytes)

    # Ensure parent directories exist
    try:
        destination.parent.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        logger.error(f"Failed to create directories for {destination}: {e}")
        raise

    open_mode = "ab" if append else "wb"

    task_id = progress.add_task(
        f"{'Appending to' if append else 'Writing'} {destination.name}",
        total=new_data_size,
    )

    try:
        with open(destination, open_mode) as f:
            written = 0
            chunk_size = 16 * 1024  # 16 KB chunks

            while written < new_data_size:
                end = min(written + chunk_size, new_data_size)
                chunk = content_bytes[written:end]
                f.write(chunk)
                progress.update(task_id, advance=len(chunk))
                written += len(chunk)

        # Only set chmod if we're creating or overwriting (not just appending to an existing file)
        if not append or not destination.exists():
            os.chmod(destination, chmod)

        logger.debug(
            f"File {'appended' if append else 'written'}: {destination} ({format_bytes(new_data_size)})"
        )

    except Exception as e:
        logger.error(f"Failed to write to {destination}: {e}")
        if not append and destination.exists():
            try:
                destination.unlink()
                logger.debug("Partial file removed after error.")
            except Exception as cleanup_error:
                logger.warning(f"Failed to clean up partial file: {cleanup_error}")
        raise

    finally:
        progress.remove_task(task_id)
