"""The 'setup' command."""

import logging
import steps.setup as setup

from execution.executor import ExecutorConfig, BuildExecutor
from common.logging import setup_logging
from .base import BaseConfig, BaseCommand


class SetupConfig:

    def __init__(self):
        pass


class SetupCommand(BaseCommand):
    """The 'setup' command"""

    def __init__(
        self,
        base_config: BaseConfig,
    ):
        super().__init__(base_config)

        setup_logging(self.base_config.verbose)

        self.logger = logging.getLogger("SetupCommand")
        self.logger.debug(f"Initialized setup command")

    def run(self):
        self.paths.mkdirs()

        definition = setup.get_definition(self.paths)
        self.logger.debug(f"Starting setup with definition {definition}")
        executor = BuildExecutor(ExecutorConfig(jobs=self.base_config.jobs))

        try:
            executor.submit(definition)
        except Exception as e:
            self.logger.error(f"Setup failed with exception: {e}")
            raise
        finally:
            executor.shutdown()
