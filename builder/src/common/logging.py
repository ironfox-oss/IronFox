import logging

from rich.logging import RichHandler


def setup_logging(verbose: bool):
    """Sets up logging for the application.

    Args:
        verbose (bool): Whether to enable verbose logging.
    """

    level = logging.DEBUG if verbose else logging.INFO
    logger = logging.getLogger()
    logger.setLevel(level)

    console_handler = RichHandler(
        show_time=False,
        show_level=True,
        show_path=True,
    )
    console_handler.setLevel(level)
    console_formatter = logging.Formatter("[%(name)s] %(message)s")
    console_handler.setFormatter(console_formatter)

    if not logger.hasHandlers():
        logger.addHandler(console_handler)

    return logger
