import logging
import os
import shutil

from pathlib import Path
from rich.progress import Progress
from .definition import TaskDefinition


class OverlayTask(TaskDefinition):

    def __init__(
        self,
        name,
        id,
        build_def,
        source_dir: Path,
        target_dir: Path,
        preserve_permissions: bool = True,
    ):
        super().__init__(name, id, build_def)
        self.source_dir = source_dir
        self.target_dir = target_dir
        self.preserve_permissions = preserve_permissions

    def execute(self, params):
        return overlay_directory(
            source_dir=self.source_dir,
            target_dir=self.target_dir,
            progress=params.progress,
            logger=self.logger,
            preserve_permissions=self.preserve_permissions,
        )


def overlay_directory(
    source_dir: Path,
    target_dir: Path,
    progress: Progress,
    logger: logging.Logger,
    preserve_permissions: bool = True,
):
    if not source_dir.exists():
        logger.warning(
            f"Source overlay directory {source_dir} does not exist, skipping"
        )
        return

    files_to_copy = list(source_dir.rglob("*"))
    files_to_copy = [f for f in files_to_copy if f.is_file()]

    if not files_to_copy:
        logger.info(f"No files found in overlay directory {source_dir}")
        return

    task_id = progress.add_task(
        f"Applying overlay from {source_dir.name}", total=len(files_to_copy)
    )

    try:
        for src_file in files_to_copy:
            rel_path = src_file.relative_to(source_dir)
            target_file = target_dir / rel_path

            target_file.parent.mkdir(parents=True, exist_ok=True)

            shutil.copy2(src_file, target_file)

            if preserve_permissions:
                src_stat = src_file.stat()
                os.chmod(target_file, src_stat.st_mode)

            logger.debug(f"Copied {rel_path} to {target_file}")
            progress.update(task_id, advance=1)

        logger.debug(
            f"Applied overlay: {len(files_to_copy)} files from {source_dir} to {target_dir}"
        )

    except Exception as e:
        logger.error(f"Failed to apply overlay: {e}")
        raise
    finally:
        progress.remove_task(task_id)
