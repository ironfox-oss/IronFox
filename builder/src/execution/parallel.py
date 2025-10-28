from __future__ import annotations

import asyncio
import logging
from dataclasses import dataclass
from typing import (
    TypeVar,
    Generic,
    Callable,
    Dict,
    Set,
    List,
    Optional,
    Union,
    Awaitable,
    Any,
)
from collections import defaultdict, deque
from enum import Enum


T = TypeVar("T")  # Input type
R = TypeVar("R")  # Result type


class TaskType(Enum):
    """Type of task execution."""

    SYNC = "sync"  # CPU-bound, runs in thread pool
    ASYNC = "async"  # I/O-bound, runs in async context


@dataclass
class Task(Generic[T, R]):
    """A task to be executed with optional dependencies."""

    id: Any  # Unique task identifier
    input: T  # Input data for the task
    func: Union[Callable[[T], R], Callable[[T], Awaitable[R]]]  # Function to execute
    dependencies: List[Any] = None  # type: ignore # List of task IDs this depends on
    task_type: TaskType = TaskType.SYNC  # Whether to run in thread pool or async

    def __post_init__(self):
        if self.dependencies is None:
            self.dependencies = []


@dataclass
class TaskResult(Generic[R]):
    """Result of a task execution."""

    task_id: Any
    success: bool
    result: Optional[R] = None
    error: Optional[Exception] = None
    error_traceback: Optional[str] = None


class ParallelExecutor(Generic[T, R]):
    def __init__(
        self,
        max_workers: int = 4,
        logger: Optional[logging.Logger] = None,
    ):
        """
        Args:
            max_workers: Maximum number of parallel tasks
            logger: Optional logger for debugging
        """
        self.max_workers = max_workers
        self.logger = logger or logging.getLogger("ParallelExecutor")

    async def execute(
        self,
        tasks: List[Task[T, R]],
        fail_fast: bool = False,
    ) -> List[TaskResult[R]]:
        # Build lookup structures
        task_lookup = {task.id: task for task in tasks}
        dependency_graph = self._build_dependency_graph(tasks)

        # Track state
        pending_tasks = set(task.id for task in tasks)
        completed_tasks = set()
        failed_tasks = set()
        results: List[TaskResult[R]] = []

        # Queues for coordination
        ready_queue = asyncio.Queue()
        completion_queue = asyncio.Queue()

        # Find initial ready tasks
        for task in tasks:
            if not task.dependencies:
                await ready_queue.put(task.id)

        async def worker():
            """Worker that processes tasks from the ready queue."""
            while True:
                try:
                    task_id = await asyncio.wait_for(ready_queue.get(), timeout=0.1)
                except asyncio.TimeoutError:
                    if not pending_tasks and ready_queue.empty():
                        break
                    continue

                if task_id is None:  # Poison pill
                    break

                task = task_lookup[task_id]

                try:
                    if task.task_type == TaskType.ASYNC:
                        result = await task.func(task.input) # type: ignore
                    else:
                        loop = asyncio.get_event_loop()
                        result = await loop.run_in_executor(None, task.func, task.input)

                    await completion_queue.put((task_id, result, None))

                except Exception as e:
                    import traceback

                    tb = traceback.format_exc()
                    await completion_queue.put((task_id, None, (e, tb)))

        workers = [asyncio.create_task(worker()) for _ in range(self.max_workers)]

        try:
            while pending_tasks or not ready_queue.empty():
                try:
                    task_id, result, error_info = await asyncio.wait_for(
                        completion_queue.get(), timeout=0.1
                    )
                except asyncio.TimeoutError:
                    continue

                pending_tasks.discard(task_id)

                if error_info is None:
                    completed_tasks.add(task_id)
                    results.append(
                        TaskResult(
                            task_id=task_id,
                            success=True,
                            result=result,
                        )
                    )

                    self.logger.debug(f"Task {task_id} completed successfully")

                    newly_ready = self._find_newly_ready_tasks(
                        task_id,
                        dependency_graph,
                        completed_tasks,
                        failed_tasks,
                        pending_tasks,
                        task_lookup,
                    )

                    for ready_id in newly_ready:
                        await ready_queue.put(ready_id)

                else:
                    error, traceback_str = error_info
                    failed_tasks.add(task_id)
                    results.append(
                        TaskResult(
                            task_id=task_id,
                            success=False,
                            error=error,
                            error_traceback=traceback_str,
                        )
                    )

                    self.logger.error(f"Task {task_id} failed: {error}")

                    if fail_fast:
                        break

                    dependent_tasks = self._get_all_dependents(
                        task_id,
                        dependency_graph,
                        pending_tasks,
                    )

                    for dep_task_id in dependent_tasks:
                        if dep_task_id in pending_tasks:
                            failed_tasks.add(dep_task_id)
                            pending_tasks.remove(dep_task_id)
                            results.append(
                                TaskResult(
                                    task_id=dep_task_id,
                                    success=False,
                                    error=Exception(
                                        f"Skipped due to dependency failure: {task_id}"
                                    ),
                                )
                            )

            for _ in range(len(workers)):
                await ready_queue.put(None)

            await asyncio.gather(*workers, return_exceptions=True)

            return results

        except Exception as e:
            for _worker in workers:
                _worker.cancel()

            await asyncio.gather(*workers, return_exceptions=True)
            raise

    def execute_sync(
        self,
        tasks: List[Task[T, R]],
        fail_fast: bool = False,
    ) -> List[TaskResult[R]]:
        """Synchronous wrapper for execute().

        Args:
            tasks: List of tasks to execute
            fail_fast: If True, stop execution on first failure

        Returns:
            List of task results
        """
        return asyncio.run(self.execute(tasks, fail_fast=fail_fast))

    def _build_dependency_graph(self, tasks: List[Task[T, R]]) -> Dict[Any, Set[Any]]:
        """Build a reverse dependency graph (dependents of each task)."""
        dependents = defaultdict(set)

        for task in tasks:
            for dep_id in task.dependencies:
                dependents[dep_id].add(task.id)

        return dependents

    def _find_newly_ready_tasks(
        self,
        completed_task_id: Any,
        dependency_graph: Dict[Any, Set[Any]],
        completed_tasks: Set[Any],
        failed_tasks: Set[Any],
        pending_tasks: Set[Any],
        task_lookup: Dict[Any, Task[T, R]],
    ) -> List[Any]:
        """Find tasks that are now ready to run."""
        newly_ready = []

        for dependent_id in dependency_graph.get(completed_task_id, set()):
            if dependent_id in pending_tasks and dependent_id not in failed_tasks:
                dependent_task = task_lookup[dependent_id]

                if self._all_dependencies_satisfied(
                    dependent_task, completed_tasks, failed_tasks
                ):
                    newly_ready.append(dependent_id)

        return newly_ready

    def _all_dependencies_satisfied(
        self,
        task: Task[T, R],
        completed_tasks: Set[Any],
        failed_tasks: Set[Any],
    ) -> bool:
        """Check if all dependencies are satisfied."""
        for dep_id in task.dependencies:
            if dep_id not in completed_tasks:
                return False
        return True

    def _get_all_dependents(
        self,
        failed_task_id: Any,
        dependency_graph: Dict[Any, Set[Any]],
        remaining_tasks: Set[Any],
    ) -> Set[Any]:
        """Get all tasks that transitively depend on the failed task."""
        all_dependents = set()
        to_process = deque([failed_task_id])

        while to_process:
            current_id = to_process.popleft()

            for dependent_id in dependency_graph.get(current_id, set()):
                if (
                    dependent_id in remaining_tasks
                    and dependent_id not in all_dependents
                ):
                    all_dependents.add(dependent_id)
                    to_process.append(dependent_id)

        return all_dependents


# Convenience functions for common patterns


async def parallel_map(
    func: Union[Callable[[T], R], Callable[[T], Awaitable[R]]],
    items: List[T],
    max_workers: int = 4,
    task_type: TaskType = TaskType.SYNC,
) -> List[R]:
    """Simple parallel map without dependencies.

    Example:
        results = await parallel_map(process_item, items, max_workers=8)
    """
    tasks = [
        Task(id=i, input=item, func=func, task_type=task_type)
        for i, item in enumerate(items)
    ]

    executor = ParallelExecutor(max_workers=max_workers)
    task_results = await executor.execute(tasks)

    # Extract successful results in order
    results = [None] * len(items)
    for tr in task_results:
        if tr.success:
            results[tr.task_id] = tr.result
        elif tr.error:
            raise tr.error
        else:
            raise ValueError("!tr.success and !tr.error")

    return results # type: ignore


def parallel_map_sync(
    func: Callable[[T], R],
    items: List[T],
    max_workers: int = 4,
) -> List[R]:
    """Synchronous parallel map without dependencies.

    Example:
        results = parallel_map_sync(process_item, items, max_workers=8)
    """
    return asyncio.run(parallel_map(func, items, max_workers, TaskType.SYNC))
