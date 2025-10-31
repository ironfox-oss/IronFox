from __future__ import annotations

import asyncio
import logging
import traceback
from dataclasses import dataclass
from typing import Dict, Set, List, Optional, Callable, Any
from collections import defaultdict, deque

import commands.base
from rich.progress import Progress

from .definition import BuildDefinition, TaskDefinition, TaskExecutionParams


class ExecutorConfig:
    """Configuration for the executor."""

    def __init__(
        self,
        jobs: int,
        dry_run: bool,
        env: commands.base.BuildEnvironment,
    ):
        self.jobs = jobs
        self.dry_run = dry_run
        self.env = env


class TaskState:
    """Represents the state of a task during execution."""

    def __init__(self, task: TaskDefinition):
        self.task = task
        self.completed = False
        self.failed = False
        self.error: Exception = None  # type: ignore


@dataclass
class FailureDetail:
    """A detailed record of a task failure to be returned by submit."""

    task: TaskDefinition
    task_id: int
    task_name: str
    reason: str
    exception: Optional[BaseException]
    traceback: Optional[str]


class AsyncBuildExecutor:
    def __init__(self, config: ExecutorConfig, definition: BuildDefinition):
        self.config = config
        self.definition = definition
        self.logger = logging.getLogger("AsyncBuildExecutor")

    async def execute(self) -> List[FailureDetail]:
        """Start execution with dependency-aware scheduling.

        Returns:
            List[FailureDetail]: An empty list when all tasks succeed, otherwise a list
            of failure details describing every failed or skipped task.
        """
        definition = self.definition
        failures: List[FailureDetail] = []

        task_states = {task.id: TaskState(task) for task in definition.tasks}
        task_lookup = {task.id: task for task in definition.tasks}
        dependency_graph = self._build_dependency_graph(definition.tasks)

        pending_tasks = set(task.id for task in definition.tasks)
        completed_tasks = set()
        failed_tasks = set()

        # Find initial ready tasks
        ready_queue = asyncio.Queue()
        for task in definition.tasks:
            if not task.dependencies:
                self.logger.warning(f"Readying task: {task.name}")
                await ready_queue.put(task.id)

        # Queue for completed tasks - this is KEY to avoiding isinstance overhead
        completion_queue = asyncio.Queue()

        self._total_tasks = len(definition.tasks)

        with Progress(transient=True) as progress:

            async def worker():
                """Worker that processes tasks from the ready queue."""
                while True:
                    try:
                        # Get next ready task with timeout to allow checking for shutdown
                        task_id = await asyncio.wait_for(ready_queue.get(), timeout=0.1)
                    except asyncio.TimeoutError:
                        # Check if we're done
                        if not pending_tasks and ready_queue.empty():
                            break
                        continue

                    if task_id is None:  # Poison pill to shutdown
                        break

                    task_state = task_states[task_id]

                    try:
                        # Run the synchronous task in a thread pool
                        await self._perform_task(task_state.task, progress)

                        task_state.completed = True
                        task_state.task.debug("Completed successfully")

                        await completion_queue.put((task_id, None))

                    except Exception as e:
                        task_state.failed = True
                        task_state.error = e
                        task_state.task.error(f"Failed with exception: {e}")

                        # Signal failure
                        await completion_queue.put((task_id, e))

            # Pre-create worker tasks - reuse them instead of creating new ones
            workers = [asyncio.create_task(worker()) for _ in range(self.config.jobs)]

            try:
                while pending_tasks or not ready_queue.empty():
                    try:
                        task_id, error = await asyncio.wait_for(
                            completion_queue.get(), timeout=0.1
                        )
                    except asyncio.TimeoutError:
                        continue

                    task_state = task_states[task_id]
                    pending_tasks.discard(task_id)

                    if error is None:
                        completed_tasks.add(task_id)
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
                        # Task failed
                        failed_tasks.add(task_id)

                        tb = traceback.format_exc()
                        failure = FailureDetail(
                            task=task_state.task,
                            task_id=task_state.task.id,
                            task_name=task_state.task.name,
                            reason="Exception during execution",
                            exception=error,
                            traceback=tb,
                        )
                        failures.append(failure)

                        # Mark all dependent tasks as failed/skipped
                        dependent_tasks = self._get_all_dependents(
                            task_id,
                            dependency_graph,
                            pending_tasks,
                        )

                        for dep_task_id in dependent_tasks:
                            if dep_task_id in pending_tasks:
                                task_states[dep_task_id].failed = True
                                task_states[dep_task_id].error = Exception(
                                    "Skipped due to dependency failure"
                                )
                                failed_tasks.add(dep_task_id)
                                pending_tasks.remove(dep_task_id)

                                failure = FailureDetail(
                                    task=task_states[dep_task_id].task,
                                    task_id=task_states[dep_task_id].task.id,
                                    task_name=task_states[dep_task_id].task.name,
                                    reason="Skipped due to dependency failure",
                                    exception=task_states[dep_task_id].error,
                                    traceback=None,
                                )
                                failures.append(failure)

                # Shutdown workers gracefully
                for _ in range(len(workers)):
                    await ready_queue.put(None)  # Poison pill

                # Wait for all workers to finish
                await asyncio.gather(*workers, return_exceptions=True)

                # Record failures for any still-pending tasks
                for task_id in list(pending_tasks):
                    task_state = task_states[task_id]
                    if not self._all_dependencies_satisfied(
                        task_state.task, completed_tasks, failed_tasks
                    ):
                        task_state.failed = True
                        pending_tasks.remove(task_id)
                        failed_tasks.add(task_id)

                        failure = FailureDetail(
                            task=task_state.task,
                            task_id=task_state.task.id,
                            task_name=task_state.task.name,
                            reason="All dependencies failed or were skipped",
                            exception=task_state.error,
                            traceback=None,
                        )
                        failures.append(failure)

                # Build finished
                if failures:
                    self.logger.error(
                        "Build completed with failures. See returned failure details."
                    )
                else:
                    self.logger.debug("All tasks completed successfully")

                return failures

            except Exception as outer_exc:
                # Unexpected exception in the scheduler loop
                tb_outer = traceback.format_exc()
                self.logger.exception(
                    "Executor encountered an unexpected error during scheduling."
                )

                # Cancel all workers
                for _worker in workers:
                    _worker.cancel()

                await asyncio.gather(*workers, return_exceptions=True)

                # Record failures
                for task_id in list(pending_tasks):
                    task_states[task_id].failed = True
                    task_states[task_id].error = Exception(
                        "Cancelled due to scheduler error"
                    )
                    failed_tasks.add(task_id)

                    failure = FailureDetail(
                        task=task_states[task_id].task,
                        task_id=task_states[task_id].task.id,
                        task_name=task_states[task_id].task.name,
                        reason="Cancelled due to scheduler error",
                        exception=task_states[task_id].error,
                        traceback=None,
                    )
                    failures.append(failure)

                # Add scheduler error
                if definition.tasks:
                    failures.append(
                        FailureDetail(
                            task=definition.tasks[0],
                            task_id=definition.tasks[0].id,
                            task_name="__scheduler_error__",
                            reason=f"Scheduler error: {outer_exc}",
                            exception=outer_exc,
                            traceback=tb_outer,
                        )
                    )

                return failures

    def _build_dependency_graph(
        self, tasks: List[TaskDefinition]
    ) -> Dict[int, Set[int]]:
        """Build a reverse dependency graph (dependents of each task)."""
        dependents = defaultdict(set)

        for task in tasks:
            for dep_id in task.dependencies:
                dependents[dep_id].add(task.id)

        return dependents

    def _find_newly_ready_tasks(
        self,
        completed_task_id: int,
        dependency_graph: Dict[int, Set[int]],
        completed_tasks: Set[int],
        failed_tasks: Set[int],
        pending_tasks: Set[int],
        task_lookup: Dict[int, TaskDefinition],
    ) -> List[int]:
        """Find tasks that are now ready to run after a task completion."""
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
        self, task: TaskDefinition, completed_tasks: Set[int], failed_tasks: Set[int]
    ) -> bool:
        """Check if all dependencies of a task are satisfied."""
        for dep_id in task.dependencies:
            if dep_id not in completed_tasks:
                if dep_id in failed_tasks:
                    return False
                else:
                    return False
        return True

    def _get_all_dependents(
        self,
        failed_task_id: int,
        dependency_graph: Dict[int, Set[int]],
        remaining_tasks: Set[int],
    ) -> Set[int]:
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

    async def _perform_task(self, task: TaskDefinition, progress: Progress) -> None:
        """Perform a single task with hooks."""
        task.debug("Starting...")
        try:
            await self._run_task_with_hooks(task, progress)
        except Exception as e:
            task.error(f"Failed with exception: {e}")
            raise

    async def _run_task_with_hooks(self, task: TaskDefinition, progress: Progress):
        """Run a task with its pre and post hooks."""
        if len(task.do_firsts) > 0:
            task.debug(f"Running do_first hooks...")
            try:
                for func in task.do_firsts:
                    if not self.config.dry_run:
                        func()
            except Exception as e:
                task.error(f"do_first hook failed with exception: {e}")
                raise

        await self._run_task(task, progress)

        if len(task.do_lasts) > 0:
            task.debug(f"Running do_last hooks")
            try:
                for func in task.do_lasts:
                    if not self.config.dry_run:
                        func()
            except Exception as e:
                task.error(f"do_last hook failed with exception: {e}")
                raise

    async def _run_task(self, task: TaskDefinition, progress: Progress):
        """Execute the main action of a task based on its type."""
        try:
            task.debug(f"Executing...")
            if not self.config.dry_run:
                await task.execute(
                    TaskExecutionParams(
                        env=self.config.env,
                        progress=progress,
                    )
                )
        finally:
            task.debug(f"Completed")
