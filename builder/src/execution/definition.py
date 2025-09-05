"""Helper classes and functions for defining and running build tasks."""

from __future__ import annotations

import itertools
import logging

from abc import abstractmethod
from pathlib import Path
from commands.base import BuildEnvironment
from rich.progress import Progress
from typing import Callable, List, TypeVar, Type

from .types import CommandType, Replacement


def _indent_lines(lines: list[str], indent: str = "    ") -> list[str]:
    return [f"{indent}{line}" for line in lines]


class TaskExecutionParams:

    def __init__(self, progress: Progress, env: BuildEnvironment):
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
        overwrite: bool = False,
    ) -> TaskDefinition:
        from .files import FileCreateTask

        return self.create_task(
            FileCreateTask,
            name,
            target=target,
            contents=contents,
            chmod=chmod,
            overwrite=overwrite,
        )

    def mkdir(
        self,
        name: str,
        target: Path,
        parents: bool = False,
        exist_ok: bool = False,
    ) -> TaskDefinition:
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
        target: Path,
        recursive: bool = False,
    ) -> TaskDefinition:
        from .files import DeleteTask

        return self.create_task(
            DeleteTask,
            name,
            target=target,
            recursive=recursive,
        )

    def sed(
        self,
        name: str,
        target_files: List[Path],
        replacement: List[Replacement],
        backup: bool = False,
        create_if_missing: bool = False,
    ) -> TaskDefinition:
        from .sed import SedTask

        return self.create_task(
            SedTask,
            name,
            target_files=target_files,
            replacement=replacement,
            backup=backup,
            create_if_missing=create_if_missing,
        )

    def overlay(
        self,
        name: str,
        source_dir: Path,
        target_dir: Path,
        preserve_permissions: bool = True,
    ) -> TaskDefinition:
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
