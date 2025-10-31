from pathlib import Path
from execution.definition import BuildDefinition
from collections import defaultdict


def write_mermaid_graph(
    build: BuildDefinition,
    filepath: Path,
    direction: str = "TD",
    include_missing: bool = True,
    include_metadata: bool = True,
) -> None:
    # helper: sanitize label for mermaid quoted label ["..."]
    def _escape_label(s: object) -> str:
        if s is None:
            s = ""
        s = str(s)
        # escape backslash first, then double quotes, then convert real newlines into \n
        s = (
            s.replace("\\", "\\\\")
            .replace('"', '\\"')
            .replace("\r\n", "\n")
            .replace("\r", "\n")
            .replace("\n", "\\n")
        )
        return s

    # validate direction
    _dir = (direction or "TD").upper()
    if _dir not in ("TD", "LR", "BT", "RL"):
        _dir = "TD"

    # build maps
    id_to_task = {t.id: t for t in build.tasks}
    all_ids = set(id_to_task.keys())
    children = defaultdict(list)  # dep_id -> list of tasks depending on it
    deps_of = {}

    for t in build.tasks:
        deps = list(getattr(t, "dependencies", []) or [])
        deps_of[t.id] = deps
        for d in deps:
            children[d].append(t.id)

    # prepare mermaid lines
    lines = []
    lines.append(f"flowchart {_dir}")

    # declare nodes (so missing nodes can be declared too). Use quoted labels to be safe.
    declared = set()

    def _node_id(nid: int) -> str:
        return f"t{nid}"

    def _declare_task_node(nid: int):
        if nid in declared:
            return
        declared.add(nid)
        if nid in id_to_task:
            t = id_to_task[nid]
            name = getattr(t, "name", f"#{nid}")
            if include_metadata:
                df = len(getattr(t, "do_firsts", []))
                dl = len(getattr(t, "do_lasts", []))
                meta = f" (df:{df}, dl:{dl})" if (df or dl) else ""
            else:
                meta = ""
            label = _escape_label(f"{name}{meta}")
        else:
            label = _escape_label(f"#{nid} (missing)")
        # Node definition: t<ID>["Label"]
        lines.append(f'    {_node_id(nid)}["{label}"]')

    # declare all real task nodes first (keeps readability)
    for tid in sorted(all_ids):
        _declare_task_node(tid)

    # if include_missing, declare placeholders for dependencies not in tasks
    if include_missing:
        missing_ids = set()
        for deps in deps_of.values():
            for d in deps:
                if d not in all_ids:
                    missing_ids.add(d)
        for mid in sorted(missing_ids):
            _declare_task_node(mid)

    # edges: for each task, each dependency -> task
    for tid in sorted(all_ids):
        deps = deps_of.get(tid, [])
        if not deps:
            continue
        for d in deps:
            if d not in all_ids and not include_missing:
                # skip edges from missing nodes if not including missing
                continue
            # ensure both endpoints declared
            _declare_task_node(d)
            _declare_task_node(tid)
            lines.append(f"    {_node_id(d)} --> {_node_id(tid)}")

    # Optionally include isolated nodes (no deps and no children) — declared above already
    # Ensure directory exists and write file
    filepath = filepath.absolute()
    filepath.parent.mkdir(parents=True, exist_ok=True)
    with open(filepath, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines))
