"""Helper classes and functions for defining and running build tasks."""

from __future__ import annotations

import itertools
import logging

import commands.base

from abc import abstractmethod
from pathlib import Path
from common.utils import resolve_glob
from rich.progress import Progress
from typing import Callable, List, TypeVar, Type, Union

from .types import CommandType, ReplacementAction


def _indent_lines(lines: list[str], indent: str = "    ") -> list[str]:
    return [f"{indent}{line}" for line in lines]


class TaskExecutionParams:
    def __init__(self, progress: Progress, env: commands.base.BuildEnvironment):
        self.progress = progress
        self.env = env


class TaskDefinition:

    def __init__(self, name: str, id: int, build_def: BuildDefinition):
        self.name = name
        self.id = id
        self.build_def = build_def
        self.do_firsts = []
        self.do_lasts = []
        self.dependencies = []
        self._visited = False  # For cycle detection in dependencies

        self.logger = logging.getLogger(name)

    @abstractmethod
    def execute(self, params: TaskExecutionParams):
        raise NotImplementedError("Task execution has not been implemented")

    def debug(self, *args, **kwargs):
        self.logger.debug(*args, *kwargs)

    def info(self, *args, **kwargs):
        self.logger.info(*args, *kwargs)

    def warning(self, *args, **kwargs):
        self.logger.warning(*args, *kwargs)

    def error(self, *args, **kwargs):
        self.logger.error(*args, *kwargs)

    def do_first(self, func) -> TaskDefinition:
        """Registers a function to be executed before the main task action.

        Args:
            func (callable): The function to execute before the main task action.

        Returns:
            TaskDefinition: Self for method chaining.
        """
        self.do_firsts.append(func)
        return self

    def do_last(self, func) -> TaskDefinition:
        """Registers a function to be executed after the main task action.

        Args:
            func (callable): The function to execute after the main task action.

        Returns:
            TaskDefinition: Self for method chaining.
        """
        self.do_lasts.append(func)
        return self

    def then(self, *next_tasks: TaskDefinition) -> TaskDefinition:
        """Specify that one or more tasks should run after this task completes.

        Args:
            *next_tasks: Tasks that should run after this task.

        Returns:
            TaskDefinition: The last task in the chain for further chaining.

        Example:
            download_task.then(extract_task).then(compile_task)
            download_task.then(extract_task, patch_task)  # Both depend on download
        """
        if not next_tasks:
            return self

        # Add this task as a dependency to all next tasks
        for next_task in next_tasks:
            self.build_def.add_dependency(next_task, self)

        # Return the last task for chaining (or self if multiple tasks)
        return next_tasks[-1] if len(next_tasks) == 1 else self

    def depends_on(self, *dependency_tasks: TaskDefinition) -> TaskDefinition:
        """Specify that this task depends on one or more other tasks.

        Args:
            *dependency_tasks: Tasks that this task depends on.

        Returns:
            TaskDefinition: Self for method chaining.

        Example:
            compile_task.depends_on(download_task, extract_task)
        """
        for dep_task in dependency_tasks:
            self.build_def.add_dependency(self, dep_task)
        return self

    def and_then(self, *next_tasks: TaskDefinition) -> TaskDefinition:
        """Alias for then() - more readable in some contexts.

        Args:
            *next_tasks: Tasks that should run after this task.

        Returns:
            TaskDefinition: The last task in the chain for further chaining.
        """
        return self.then(*next_tasks)

    def before(self, *next_tasks: TaskDefinition) -> TaskDefinition:
        """Specify that this task should run before other tasks.
        This is equivalent to calling depends_on() on the next tasks.

        Args:
            *next_tasks: Tasks that should run after this task.

        Returns:
            TaskDefinition: Self for method chaining.
        """
        for next_task in next_tasks:
            self.build_def.add_dependency(next_task, self)
        return self

    def _add_dependency(
        self, task: TaskDefinition, all_tasks: list[TaskDefinition]
    ) -> None:
        if self._check_circular_dependency(task, all_tasks):
            raise ValueError(
                f"Circular dependency detected: {task.name} cannot be a dependency of {self.name}."
            )

        if task.id not in self.dependencies:
            self.dependencies.append(task.id)

    def _check_circular_dependency(
        self, task: TaskDefinition, all_tasks: list[TaskDefinition]
    ) -> bool:
        if self == task:
            # Direct self-dependency is a cycle
            return True

        return self._dfs_detect_cycle(task, all_tasks)

    def _dfs_detect_cycle(
        self, task: TaskDefinition, all_tasks: list[TaskDefinition]
    ) -> bool:
        if task._visited:
            # If the task has already been visited, we found a cycle
            return True

        task._visited = True

        for dep_id in task.dependencies:
            dep_task = next((t for t in all_tasks if t.id == dep_id), None)
            if dep_task and dep_task._dfs_detect_cycle(self, all_tasks):
                return True

        task._visited = False
        return False


class BuildDefinition:

    def __init__(self, name: str):
        self.name = name
        self.tasks: list[TaskDefinition] = []
        self._id_counter = itertools.count(1)
        self.logger = logging.getLogger(f"BuildDefinition[{self.name}]")

    @property
    def next_task_id(self) -> int:
        return next(self._id_counter)

    def add_task(self, task: TaskDefinition) -> None:
        """Adds a task to the build definition.

        Args:
            task (TaskDefinition): The task to add.
        """
        self.tasks.append(task)

    def add_dependency(self, task: TaskDefinition, depends_on: TaskDefinition) -> None:
        """Adds a dependency between two tasks.

        Args:
            task (TaskDefinition): The task that has the dependency.
            depends_on (TaskDefinition): The task that `task` depends on.

        Raises:
            ValueError: If adding the dependency would create a circular dependency.
        """
        task._add_dependency(depends_on, self.tasks)

    def chain(self, *tasks: TaskDefinition) -> TaskDefinition | None:
        """Create a dependency chain from multiple tasks.

        Args:
            *tasks: Tasks to chain in order.

        Returns:
            TaskDefinition: The last task in the chain.

        Example:
            build.chain(download_task, extract_task, compile_task)
            # Equivalent to: download_task.then(extract_task).then(compile_task)
        """
        if len(tasks) < 2:
            return tasks[0] if tasks else None

        for i in range(len(tasks) - 1):
            tasks[i].then(tasks[i + 1])

        return tasks[-1]

    def parallel(self, *tasks: TaskDefinition) -> List[TaskDefinition]:
        """Mark tasks to run in parallel (no dependencies between them).
        This is mainly for documentation - tasks without dependencies run in parallel by default.

        Args:
            *tasks: Tasks that can run in parallel.

        Returns:
            List[TaskDefinition]: The list of parallel tasks.
        """
        return list(tasks)

    TaskType = TypeVar("TaskType", bound=TaskDefinition)

    def create_task(
        self,
        task_cls: Type[TaskType],
        name: str,
        *args,
        **kwargs,
    ) -> TaskType:
        task = task_cls(name, self.next_task_id, self, *args, **kwargs)
        self.logger.debug(f"New task created: {task}({args}, {kwargs})")
        self.add_task(task)
        return task

    def download(
        self,
        name: str,
        url: str,
        destination: Path,
        sha256: str,
    ) -> TaskDefinition:
        """Creates a task to download a file from a URL.

        Args:
            name (str): The name of the download task.
            url (str): The URL of the file to download.
            destination (Path): The local path where the file should be saved.
            sha256 (str): The expected SHA256 checksum of the downloaded file for verification.

        Returns:
            TaskDefinition: The created DownloadTask instance.
        """
        from .download import DownloadTask

        return self.create_task(
            DownloadTask,
            name,
            url=url,
            destination=destination,
            sha256=sha256,
        )

    def extract(
        self,
        name: str,
        archive_file: Path,
        extract_to: Path,
        archive_format: str,
        preserve_permissions: bool = True,
    ) -> TaskDefinition:
        """Creates a task to extract an archive file.

        Args:
            name (str): The name of the extraction task.
            archive_file (Path): The path to the archive file to extract.
            extract_to (Path): The directory where the archive contents should be extracted.
            archive_format (str): The format of the archive (e.g., "zip", "tar", "gztar").
            preserve_permissions (bool, optional): Whether to preserve file permissions during extraction.
                                                    Defaults to True.
        Returns:
            TaskDefinition: The created ExtractTask instance.
        """
        from .extract import ExtractTask

        return self.create_task(
            ExtractTask,
            name,
            archive_file=archive_file,
            extract_to=extract_to,
            archive_format=archive_format,
            preserve_permissions=preserve_permissions,
        )

    def clone(
        self,
        name: str,
        repo_url: str,
        clone_to: Path,
        branch: str | None = None,
        depth: int | None = None,
    ) -> TaskDefinition:
        """Creates a task to clone a Git repository.

        Args:
            name (str): The name of the clone task.
            repo_url (str): The URL of the Git repository.
            clone_to (Path): The local directory where the repository should be cloned.
            branch (str | None, optional): The specific branch to clone. If None, the default branch is used.
                                            Defaults to None.
            depth (int | None, optional): The depth for a shallow clone. If None, a full clone is performed.
                                            Defaults to None.
        Returns:
            TaskDefinition: The created CloneTask instance.
        """
        from .clone import CloneTask

        return self.create_task(
            CloneTask,
            name,
            repo_url=repo_url,
            clone_to=clone_to,
            branch=branch,
            depth=depth,
        )

    def patch(
        self,
        name: str,
        patch_file: Path,
        target_dir: Path,
    ) -> TaskDefinition:
        """Creates a task to apply a patch file to a target directory.

        Args:
            name (str): The name of the patch task.
            patch_file (Path): The path to the patch file (.patch, .diff).
            target_dir (Path): The directory where the patch should be applied.

        Returns:
            TaskDefinition: The created PatchTask instance.
        """
        from .patch import PatchTask

        return self.create_task(
            PatchTask,
            name,
            patch_file=patch_file,
            target_dir=target_dir,
        )

    def run_commands(
        self,
        name: str,
        commands: list[CommandType],
        cwd: Path = Path.cwd(),
        env: dict[str, str] = dict(),
        assume_yes: bool | int = False,
    ) -> TaskDefinition:
        """Creates a task to run a list of shell commands.

        Args:
            name (str): The name of the command execution task.
            commands (list[CommandType]): A list of commands to execute. Each command can be a string
                                          or a tuple of (command_string, result_handler_callable).
            cwd (Path, optional): The current working directory for the commands. Defaults to Path.cwd().
            env (dict[str, str], optional): Additional environment variables for the commands. Defaults to empty dict.
            assume_yes (bool | int, optional): If True, automatically input 'y' to prompts. If an integer,
                                                inputs 'y' that many times. Defaults to False.
        Returns:
            TaskDefinition: The created RunCommandsTask instance.
        """
        from .run import RunCommandsTask

        return self.create_task(
            RunCommandsTask,
            name,
            cwd=cwd,
            commands=commands,
            env=env,
            assume_yes=assume_yes,
        )

    def write_file(
        self,
        name: str,
        target: Path,
        contents: Callable[[], bytes],
        chmod: int = 0o644,
        append: bool = True,
        overwrite: bool = False,
    ) -> TaskDefinition:
        """Creates a task to write content to a file.

        Args:
            name (str): The name of the write file task.
            target (Path): The path to the file to write.
            contents (Callable[[], bytes]): A callable that returns the bytes content to write to the file.
            chmod (int, optional): The file permissions (octal) to set. Defaults to 0o644 (rw-r--r--).
            append (bool, optional): If True, append to the file instead of overwriting. Defaults to True.
            overwrite (bool, optional): If True, overwrite the file if it already exists. If False,
                                        raise an error if the file exists. Defaults to False.
        Returns:
            TaskDefinition: The created WriteFileTask instance.
        """
        from .files import WriteFileTask

        return self.create_task(
            WriteFileTask,
            name,
            target=target,
            contents=contents,
            chmod=chmod,
            append=append,
            overwrite=overwrite,
        )

    def mkdir(
        self,
        name: str,
        target: Path,
        parents: bool = False,
        exist_ok: bool = False,
    ) -> TaskDefinition:
        """Creates a task to create a directory.

        Args:
            name (str): The name of the directory creation task.
            target (Path): The path of the directory to create.
            parents (bool, optional): If True, create any necessary parent directories. Defaults to False.
            exist_ok (bool, optional): If True, do not raise an error if the directory already exists.
                                        Defaults to False.
        Returns:
            TaskDefinition: The created DirCreateTask instance.
        """
        from .files import DirCreateTask

        return self.create_task(
            DirCreateTask,
            name,
            target=target,
            parents=parents,
            exist_ok=exist_ok,
        )

    def delete(
        self,
        name: str,
        path: Union[Path, str],
        recursive: bool = False,
    ) -> List[TaskDefinition]:
        """Creates a task to delete a file or directory.

        Args:
            name (str): The name of the delete task.
            target (Path): The path or glob to the files or directories to delete.
            recursive (bool, optional): If True, recursively delete directories and their contents.
                                        Required for deleting non-empty directories. Defaults to False.
        Returns:
            TaskDefinition: The created DeleteTask instances for each resolved file.
        """
        from .files import DeleteTask

        files = resolve_glob(path)
        tasks = []

        tasks = []
        for idx, f in enumerate(files, start=1):
            task_name = f"{name} [{idx}] ({f})" if len(files) > 1 else name
            tasks.append(
                self.create_task(
                    DeleteTask,
                    task_name,
                    target=f,
                    recursive=recursive,
                )
            )

        return tasks

    def copy(
        self,
        name: str,
        source: Path,
        target: Path,
        recursive: bool = False,
        overwrite: bool = False,
    ) -> TaskDefinition:
        """Copy the given source file to the given target file.

        Args:
            name (str): The name of the copy task.
            source (Path): The source file path.
            target (Path): The target file path.
            recursive (bool, optional): Whether copy recursively if source is a directory. Defaults to False.
            overwrite (bool, optional): Whether to overwrite existing files. Defaults to False.

        Returns:
            TaskDefinition: The task definition of the copy task.
        """

        from execution.files import CopyTask

        return self.create_task(
            CopyTask,
            name=name,
            source=source,
            target=target,
            recursive=recursive,
            overwrite=overwrite,
        )

    def copy_dir_contents(
        self,
        name: str,
        source_dir: Path,
        target_dir: Path,
        recursive: bool = False,
    ) -> TaskDefinition:
        """Copy the contents of the given source directory into the given target directory.

        Args:
            name (str): The name of the copy task.
            source (Path): The source directory path.
            target (Path): The target directory path.
            recursive (bool, optional): Whether copy recursively if any children or sub-children of source is a directory. Defaults to False.

        Returns:
            TaskDefinition: The task definition of the copy task.
        """

        from execution.files import CopyIntoTask

        return self.create_task(
            CopyIntoTask,
            name=name,
            source_dir=source_dir,
            target=target_dir,
            recursive=recursive,
        )

    def find_replace(
        self,
        name: str,
        target_file: Union[Path, str],
        replacements: List[ReplacementAction],
        backup: bool = False,
        create_if_missing: bool = False,
    ) -> List[TaskDefinition]:
        """Creates one or more tasks to perform find and replace operations.

        Args:
            name (str): The base name of the find/replace task(s).
            target_file (Path | str): The path to the file to modify, or a glob pattern.
            replacements (List[ReplacementAction]): Replacements to perform.
            backup (bool, optional): If True, create a backup before modification. Defaults to False.
            create_if_missing (bool, optional): If True, create the target file if it does not exist. Defaults to False.

        Returns:
            List[TaskDefinition]: A list of FindReplaceTask instances.
        """
        from .find_replace import FindReplaceTask

        # Resolve targets

        files = resolve_glob(target_file)
        tasks = []
        for idx, f in enumerate(files, start=1):
            task_name = f"{name} [{idx}] ({f})" if len(files) > 1 else name
            tasks.append(
                self.create_task(
                    FindReplaceTask,
                    task_name,
                    target_file=f,
                    replacements=replacements,
                    backup=backup,
                    create_if_missing=create_if_missing,
                )
            )

        return tasks

    def overlay(
        self,
        name: str,
        source_dir: Path,
        target_dir: Path,
        preserve_permissions: bool = True,
    ) -> TaskDefinition:
        """Creates a task to overlay files from a source directory onto a target directory.
        Files in the source directory will overwrite files with the same name in the target directory.

        Args:
            name (str): The name of the overlay task.
            source_dir (Path): The directory containing files to copy.
            target_dir (Path): The destination directory where files will be copied.
            preserve_permissions (bool, optional): If True, attempt to preserve file permissions. Defaults to True.
        Returns:
            TaskDefinition: The created OverlayTask instance.
        """
        from .overlay import OverlayTask

        return self.create_task(
            OverlayTask,
            name,
            source_dir=source_dir,
            target_dir=target_dir,
            preserve_permissions=preserve_permissions,
        )

    def __repr__(self):
        lines = [f"BuildDefinition(name={self.name!r})"]
        for task in self.tasks:
            task_lines = repr(task).splitlines()
            lines.extend(_indent_lines(task_lines))
        return "\n".join(lines)
