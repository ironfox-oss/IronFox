"""The 'setup' command."""

from .base import BaseConfig, BaseCommand


class SetupConfig:
    def __init__(self, clone_depth: int = 1):
        self.clone_depth = clone_depth
        pass


class SetupCommand(BaseCommand):
    """The 'setup' command"""

    def __init__(
        self,
        base_config: BaseConfig,
        clone_depth: int = 1,
    ):
        super().__init__("SetupCommand", base_config)
        self.setup_config = SetupConfig(clone_depth=clone_depth)
        self.logger.debug(f"Initialized setup command with config {base_config}")

    def get_definition(self):
        from steps.setup import get_definition
        return get_definition(self.setup_config, self.paths)
