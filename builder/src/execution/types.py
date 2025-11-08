from dataclasses import dataclass
from pathlib import Path
from re import Pattern
from typing import Callable, Dict, Tuple, Union

### RUN

CommandWithResultHandler = Tuple[str, Callable[[str, str], None]]
CommandType = Union[str, CommandWithResultHandler]

### FIND REPLACE

PatternType = Union[str, Pattern[str]]
Replacer = Callable[[str], str]
Replacement = Union[str, Replacer]


@dataclass
class ReplacementAction:
    count: int


@dataclass
class CustomReplacement(ReplacementAction):
    """Represents a custom replacement that processes whole file contents"""

    replacer: Replacer


@dataclass
class LineReplacement(ReplacementAction):
    """Represents a replacement that applies to specific lines matching a pattern."""

    line_match_pattern: PatternType
    text_match_pattern: PatternType
    replacement: Replacement


@dataclass
class RegexReplacement(ReplacementAction):
    """Represents a replacement that applies to the entire file content."""

    pattern: PatternType
    replacement: Replacement


@dataclass
class LineAffixReplacement(ReplacementAction):
    """Represents a replacement that prefixes or suffixes text in matching lines."""

    line_match_pattern: PatternType
    prefix: str = ""
    suffix: str = ""


@dataclass
class RunTaskCmd:
    command: CommandType
    cwd: Path
    assume_yes: Union[bool, int]
    env: Dict[str, str]
