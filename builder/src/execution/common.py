from pathlib import Path
from execution.definition import TaskDefinition


class FileOpTask(TaskDefinition):
    def __init__(self, name, id, build_def, target: Path):
        super().__init__(name, id, build_def)
        self.target = target
