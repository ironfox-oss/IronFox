"""The 'setup' command."""

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
        super().__init__("SetupCommand", base_config)
        self.setup_config = SetupConfig()
        self.logger.debug(f"Initialized setup command with config {base_config}")

    def get_definition(self):
        from steps.setup import get_definition
        return get_definition(self.setup_config, self.paths)
