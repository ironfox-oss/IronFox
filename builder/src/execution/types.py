from dataclasses import dataclass
from re import Pattern
from typing import Callable, Tuple, Union

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
class GlobalReplacement(ReplacementAction):
    """Represents a replacement that applies to the entire file content."""

    pattern: PatternType
    replacement: Replacement


@dataclass
class LiteralReplacement(ReplacementAction):
    """Represents a simple literal string replacement (like sed s/old/new/g)."""

    old_text: str
    new_text: str


@dataclass
class LineAffixReplacement(ReplacementAction):
    """Represents a replacement that prefixes or suffixes text in matching lines."""

    line_match_pattern: PatternType
    prefix: str = ""
    suffix: str = ""
