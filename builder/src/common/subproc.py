from __future__ import annotations

import asyncio
import os
from collections import deque
from pathlib import Path
from typing import Dict, Iterable, Optional, Tuple

from rich.console import Console
from rich.live import Live
from rich.panel import Panel
from rich.text import Text

ConsoleType = Console
EnvType = Dict[str, str]


async def _reader_coroutine(
    stream: asyncio.StreamReader, tag: str, q: asyncio.Queue[tuple[str, str]]
) -> None:
    try:
        while True:
            raw = await stream.readline()
            if not raw:
                break
            line = raw.decode(errors="replace").rstrip("\n")
            await q.put((tag, line))
    finally:
        return


async def run_command_with_progress(
    title: str,
    cmd: Iterable[str],
    *,
    n: int = 30,
    refresh_per_second: int = 20,
    env: Optional[EnvType] = None,
    cwd: Optional[Path] = None,
    console: ConsoleType = Console(),
    stdin: Optional[bytes] = None,
) -> Tuple[int, str, str]:
    final_env = os.environ.copy() if env is None else dict(env)

    proc = await asyncio.create_subprocess_exec(
        *tuple(cmd),
        stdin=asyncio.subprocess.PIPE if stdin is not None else None,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
        env=final_env,
        cwd=str(cwd) if cwd is not None else None,
    )

    q: asyncio.Queue[tuple[str, str]] = asyncio.Queue()

    assert proc.stdout is not None
    assert proc.stderr is not None

    if stdin is not None:
        assert proc.stdin is not None
        proc.stdin.write(stdin)
        await proc.stdin.drain()
        proc.stdin.close()

    task_out = asyncio.create_task(_reader_coroutine(proc.stdout, "out", q))
    task_err = asyncio.create_task(_reader_coroutine(proc.stderr, "err", q))

    combined: deque[str] = deque(maxlen=n)
    stdout_parts: list[str] = []
    stderr_parts: list[str] = []

    def render_panel() -> Panel:
        if not combined:
            return Panel(Text(""), title="")
        text = Text("\n".join(combined))
        return Panel(text, title=title)

    waiter = asyncio.create_task(proc.wait())
    with Live(
        render_panel(),
        refresh_per_second=refresh_per_second,
        console=console,
        screen=True,
    ) as live:
        while True:
            try:
                tag, line = await asyncio.wait_for(
                    q.get(), timeout=1.0 / max(1, refresh_per_second)
                )
            except asyncio.TimeoutError:
                if waiter.done() and q.empty():
                    break
                continue

            if tag == "out":
                stdout_parts.append(line + "\n")
            else:
                stderr_parts.append(line + "\n")
            combined.append(line)
            live.update(render_panel())
        await asyncio.gather(task_out, task_err, return_exceptions=True)

    stdout_str = "".join(stdout_parts)
    stderr_str = "".join(stderr_parts)

    returncode = await waiter
    return int(returncode), stdout_str, stderr_str
