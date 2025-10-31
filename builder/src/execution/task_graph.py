import networkx as _nx
import matplotlib.pyplot as _plt
import os as _os

from execution.definition import BuildDefinition
from collections import defaultdict as _defaultdict, deque as _deque


def write_img_graph(
    build: BuildDefinition,
    filepath: str,
    figsize=(12, 8),
    dpi: int = 150,
    show: bool = False,
) -> None:
    # Build directed graph: edges from dependency -> task
    G = _nx.DiGraph()
    id_to_name = {t.id: getattr(t, "name", f"#{t.id}") for t in build.tasks}
    for t in build.tasks:
        G.add_node(t.id, label=id_to_name[t.id])

    for t in build.tasks:
        for dep_id in getattr(t, "dependencies", []):
            if dep_id is None:
                continue
            if not G.has_node(dep_id):
                G.add_node(dep_id, label=f"#{dep_id} (missing)")
            G.add_edge(dep_id, t.id)

    try:
        pos = _nx.spring_layout(G, seed=42)
    except Exception:
        pos = _nx.kamada_kawai_layout(G)

    _plt.figure(figsize=figsize, dpi=dpi)
    _nx.draw_networkx_nodes(G, pos, node_size=900)
    _nx.draw_networkx_edges(G, pos, arrowsize=20, arrowstyle="-|>")

    labels = {n: G.nodes[n].get("label", str(n)) for n in G.nodes()}
    _nx.draw_networkx_labels(G, pos, labels, font_size=9)
    _plt.axis("off")

    _os.makedirs(_os.path.dirname(_os.path.abspath(filepath)) or ".", exist_ok=True)
    _plt.savefig(filepath, bbox_inches="tight")
    if show:
        _plt.show()
    _plt.close()


def write_ascii_graph(
    build: BuildDefinition,
    file_path: str,
    indent_unit: str = "    ",
) -> None:
    id_to_name = {t.id: getattr(t, "name", f"#{t.id}") for t in build.tasks}
    children = _defaultdict(list)  # dep_id -> list of task ids that depend on it
    deps_of = _defaultdict(list)  # task_id -> list of dep ids
    all_ids = set()

    for t in build.tasks:
        tid = t.id
        all_ids.add(tid)
        deps = list(getattr(t, "dependencies", []) or [])
        deps_of[tid] = deps
        for d in deps:
            children[d].append(tid)

    # Determine roots (nodes with no dependencies OR dependencies that are missing)
    has_deps = {tid for tid, deps in deps_of.items() if deps}
    root_candidates = [tid for tid in all_ids if not deps_of.get(tid)]

    # If there are no explicit roots (cycles or fully connected), choose smallest-id as start
    if not root_candidates:

        # try nodes whose deps refer to missing ids => consider them roots
        roots = []
        for tid in all_ids:
            if not any((d in all_ids) for d in deps_of.get(tid, [])):
                roots.append(tid)
        root_candidates = roots or [min(all_ids)]

    # Prepare traversal that prints dependency->task direction (dep as parent, children below)
    visited = set()
    stack = set()

    lines = []
    lines.append(f"Build: {build.name}")
    lines.append(f"Tasks: {len(build.tasks)}")
    lines.append("")

    def _print_node(nid: int, indent_level: int = 0):
        indent = indent_unit * indent_level
        name = id_to_name.get(nid, f"#{nid}")
        if nid in stack:
            lines.append(f"{indent}[{nid}] {name}  <cycle>")
            return
        if nid in visited:
            lines.append(f"{indent}[{nid}] {name}  (seen)")
            return
        visited.add(nid)
        stack.add(nid)
        lines.append(f"{indent}[{nid}] {name}")
        deps = deps_of.get(nid, [])
        if deps:
            dep_strs = []
            for d in deps:
                if d in id_to_name:
                    dep_strs.append(f"[{d}] {id_to_name[d]}")
                else:
                    dep_strs.append(f"[{d}] <missing>")
            lines.append(f"{indent}{indent_unit}depends on: " + ", ".join(dep_strs))
        ch = children.get(nid, [])
        if ch:
            for c in sorted(ch, key=lambda x: id_to_name.get(x, "")):
                _print_node(c, indent_level + 1)
        stack.remove(nid)

    for r in sorted(root_candidates):
        _print_node(r, indent_level=0)
        lines.append("")

    # If some nodes were never visited (disconnected components / cycles), print them
    unvisited = sorted([nid for nid in all_ids if nid not in visited])
    if unvisited:
        lines.append("Unvisited / disconnected / remaining nodes:")
        for nid in unvisited:
            _print_node(nid, indent_level=0)
            lines.append("")

    # Append adjacency list for precise machine-readable reference
    lines.append("Adjacency (dep -> task):")
    for dep_id in sorted(set(list(children.keys()) + list(all_ids))):
        targets = children.get(dep_id, [])
        dep_label = id_to_name.get(dep_id, f"#{dep_id}")
        if targets:
            tlabels = [f"[{tid}] {id_to_name.get(tid, f'#{tid}')}" for tid in targets]
            lines.append(f"  [{dep_id}] {dep_label} -> " + ", ".join(tlabels))
        else:
            if dep_id in all_ids:
                lines.append(f"  [{dep_id}] {dep_label} -> (no outward edges)")

    # Write out file (ensure directory exists)
    _os.makedirs(_os.path.dirname(_os.path.abspath(file_path)) or ".", exist_ok=True)
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
