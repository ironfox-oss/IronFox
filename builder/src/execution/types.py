from pathlib import Path
from re import Match, Pattern
from typing import Callable, List, Tuple, Union


TargetFilesType = Union[str, Path, List[Union[str, Path]]]

PatternType = Union[str, Pattern[str]]
ReplacementType = Union[str, Callable[[Match[str]], str]]

# Two forms: with or without flags
Replacement = Union[
    Tuple[PatternType, ReplacementType], Tuple[PatternType, ReplacementType, int]
]
