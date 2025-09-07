from pathlib import Path
from re import Match, Pattern
from typing import Callable, List, Tuple, Union

### RUN

CommandWithResultHandler = Tuple[str, Callable[[str, str], None]]
CommandType = Union[str, CommandWithResultHandler]

### FIND REPLACE

PatternType = Union[str, Pattern[str]]
Replacement = Callable[[str], str]