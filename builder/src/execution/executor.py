from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor, as_completed, Future
import logging
import threading
from typing import Dict, Set, List
from collections import defaultdict, deque

from commands.base import BuildEnvironment
from rich.progress import Progress

from .definition import BuildDefinition, TaskDefinition, TaskExecutionParams


class ExecutorConfig:
    """Configuration for the executor."""

    def __init__(self, jobs: int, env: BuildEnvironment):
        self.jobs = jobs
        self.env = env


class TaskState:
    """Represents the state of a task during execution."""

    def __init__(self, task: TaskDefinition):
        self.task = task
        self.future: Future = None  # type: ignore
        self.completed = False
        self.failed = False
        self.error: Exception = None  # type: ignore


class BuildExecutor:
    """Executor for build tasks with dependency-aware scheduling."""

    def __init__(self, config: ExecutorConfig):
        self.config = config
        self.executor = ThreadPoolExecutor(max_workers=self.config.jobs)
        self.logger = logging.getLogger(f"BuildExecutor[jobs={self.config.jobs}]")
        self._lock = threading.Lock()

    def submit(self, definition: BuildDefinition):
        """Submit a build definition for execution with dependency-aware scheduling."""
        with Progress(transient=True) as progress:
            task_states = {task.id: TaskState(task) for task in definition.tasks}
            task_lookup = {task.id: task for task in definition.tasks}
            dependency_graph = self._build_dependency_graph(definition.tasks)

            ready_tasks = deque()
            pending_tasks = set(task.id for task in definition.tasks)
            running_tasks = set()
            completed_tasks = set()
            failed_tasks = set()

            for task in definition.tasks:
                if not task.dependencies:
                    ready_tasks.append(task.id)

            future_to_task = {}

            try:
                while pending_tasks or running_tasks:

                    # Schedule ready tasks up to the job limit
                    while ready_tasks and len(running_tasks) < self.config.jobs:
                        task_id = ready_tasks.popleft()
                        if task_id in pending_tasks:
                            task_state = task_states[task_id]
                            self.logger.info(f"Scheduling task: {task_state.task.name}")

                            future = self.executor.submit(
                                self._perform_task, task_state.task, progress
                            )
                            task_state.future = future
                            future_to_task[future] = task_id

                            pending_tasks.remove(task_id)
                            running_tasks.add(task_id)

                    # Wait for at least one task to complete
                    if running_tasks:
                        running_futures = [
                            task_states[task_id].future for task_id in running_tasks
                        ]

                        for future in as_completed(running_futures):
                            task_id = future_to_task[future]
                            task_state = task_states[task_id]

                            try:
                                # Get the result (this will raise if task failed)
                                future.result()

                                task_state.completed = True
                                completed_tasks.add(task_id)
                                running_tasks.remove(task_id)

                                self.logger.info(
                                    f"Task completed successfully: {task_state.task.name}"
                                )

                                # Check if any pending tasks are now ready
                                newly_ready = self._find_newly_ready_tasks(
                                    task_id,
                                    dependency_graph,
                                    completed_tasks,
                                    failed_tasks,
                                    pending_tasks,
                                    task_lookup,
                                )
                                ready_tasks.extend(newly_ready)

                            except Exception as e:
                                task_state.failed = True
                                task_state.error = e
                                failed_tasks.add(task_id)
                                running_tasks.remove(task_id)

                                self.logger.error(
                                    f"Task {task_state.task.name} failed with exception: {e}"
                                )

                                # Mark all dependent tasks as failed
                                dependent_tasks = self._get_all_dependents(
                                    task_id,
                                    dependency_graph,
                                    pending_tasks.union(running_tasks),
                                )

                                for dep_task_id in dependent_tasks:
                                    if dep_task_id in running_tasks:
                                        # Cancel running dependent tasks
                                        dep_future = task_states[dep_task_id].future
                                        if dep_future:
                                            dep_future.cancel()
                                        running_tasks.remove(dep_task_id)
                                    elif dep_task_id in pending_tasks:
                                        # Remove pending dependent tasks
                                        pending_tasks.remove(dep_task_id)

                                    task_states[dep_task_id].failed = True
                                    task_states[dep_task_id].error = Exception(
                                        f"Dependency {task_state.task.name} failed"
                                    )
                                    failed_tasks.add(dep_task_id)

                                    self.logger.error(
                                        f"Task {task_states[dep_task_id].task.name} "
                                        f"skipped due to failed dependency: {task_state.task.name}"
                                    )

                                # Remove failed tasks from ready queue
                                ready_tasks = deque(
                                    [
                                        tid
                                        for tid in ready_tasks
                                        if tid not in failed_tasks
                                    ]
                                )

                                # If this was a critical failure, we might want to stop
                                # For now, we continue with remaining independent tasks

                            # Clean up the future mapping
                            del future_to_task[future]
                            break  # Process one completion at a time

                    # If we have no running tasks and no ready tasks, but still have pending tasks,
                    # it means all remaining tasks depend on failed tasks
                    if not running_tasks and not ready_tasks and pending_tasks:
                        for task_id in list(pending_tasks):
                            task_state = task_states[task_id]
                            task_state.failed = True
                            task_state.error = Exception(
                                "All dependencies failed or were skipped"
                            )
                            failed_tasks.add(task_id)
                            pending_tasks.remove(task_id)
                            self.logger.error(
                                f"Task {task_state.task.name} skipped - no viable execution path"
                            )

                # Check if any tasks failed and raise the first error
                failed_task_states = [
                    state for state in task_states.values() if state.failed
                ]
                if failed_task_states:
                    first_failure = failed_task_states[0]
                    self.logger.error(
                        f"Build failed. First failure: {first_failure.task.name}"
                    )
                    raise first_failure.error

                self.logger.info("All tasks completed successfully")

            except Exception:
                # Cancel any remaining futures
                for task_id in running_tasks:
                    future = task_states[task_id].future
                    if future:
                        future.cancel()
                raise

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

        # Check all dependents of the completed task
        for dependent_id in dependency_graph.get(completed_task_id, set()):
            if dependent_id in pending_tasks and dependent_id not in failed_tasks:
                # Check if all dependencies of this dependent are now complete
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
                # Dependency is not completed
                if dep_id in failed_tasks:
                    # Dependency failed - task cannot run
                    return False
                else:
                    # Dependency is still pending
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

    def _perform_task(self, task: TaskDefinition, progress: Progress) -> None:
        """Perform a single task with hooks."""
        self.logger.info(f"Starting task: {task.name}")

        try:
            self._run_task_with_hooks(task, progress)
        except Exception as e:
            self.logger.error(f"Task {task.name} failed with exception: {e}")
            raise

    def _run_task_with_hooks(self, task: TaskDefinition, progress: Progress):
        """Run a task with its pre and post hooks."""
        if len(task.do_firsts) > 0:
            self.logger.debug(f"Running do_first hooks for task: {task.name}")
            task_id = progress.add_task(
                f"Running pre-tasks for {task.name}", total=len(task.do_firsts)
            )
            try:
                for func in task.do_firsts:
                    func()
                    progress.update(task_id, advance=1)
            except Exception as e:
                self.logger.error(
                    f"Task {task.name} do_first hook failed with exception: {e}"
                )
                raise
            finally:
                try:
                    progress.remove_task(task_id)
                except:
                    pass

        self._run_task(task, progress)

        if len(task.do_lasts) > 0:
            self.logger.debug(f"Running do_last hooks for task: {task.name}")
            task_id = progress.add_task(
                f"Running post-tasks for {task.name}", total=len(task.do_lasts)
            )
            try:
                for func in task.do_lasts:
                    func()
                    progress.update(task_id, advance=1)
            except Exception as e:
                self.logger.error(
                    f"Task {task.name} do_last hook failed with exception: {e}"
                )
                raise
            finally:
                try:
                    progress.remove_task(task_id)
                except:
                    pass

    def _run_task(self, task: TaskDefinition, progress: Progress):
        """Execute the main action of a task based on its type."""
        try:
            self.logger.debug(f"Executing task: {task.name}")
            task.execute(
                TaskExecutionParams(
                    progress=progress,
                    env=self.config.env,
                )
            )
        finally:
            self.logger.debug(f"Completed task: {task.name}")

    def shutdown(self):
        """Shutdown the executor and wait for all tasks to complete."""
        self.executor.shutdown(wait=True)

    def __exit__(self, exc_type, exc_value, traceback):
        """Context manager exit - ensure proper shutdown."""
        self.shutdown()
