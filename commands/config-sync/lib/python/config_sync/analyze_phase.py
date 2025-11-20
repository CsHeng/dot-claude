#!/usr/bin/env python3
"""
Analyze phase helpers for config-sync.

Usage:
    python3 -m config_sync.analyze_phase <output_json>

Environment:
    TARGET_MATRIX: newline-separated "target|config_dir|commands_dir|rules_dir"
    ANALYZE_FORMAT: "markdown" | "table" | "json"
    ANALYZE_DETAILED: "true" | "false"
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Dict, List


def count_files(root: Path, pattern: str) -> int:
    if not root.exists():
        return 0
    try:
        return sum(1 for _ in root.rglob(pattern))
    except Exception:
        return 0


def count_command_files(root: Path) -> int:
    if not root.exists():
        return 0
    try:
        return sum(1 for _ in root.rglob("*.md")) + sum(
            1 for _ in root.rglob("*.toml")
        )
    except Exception:
        return 0


def build_report(output_path: Path) -> None:
    matrix_raw = os.environ.get("TARGET_MATRIX", "")
    format_name = os.environ.get("ANALYZE_FORMAT", "markdown")
    detailed = os.environ.get("ANALYZE_DETAILED") == "true"

    matrix = [line for line in matrix_raw.splitlines() if line.strip()]
    targets: List[Dict[str, object]] = []

    for row in matrix:
        parts = row.split("|", 3)
        if len(parts) != 4:
            continue
        name, config_dir, commands_dir, rules_dir = parts
        config_dir_path = Path(config_dir)
        commands_dir_path = Path(commands_dir)
        rules_dir_path = Path(rules_dir)
        entry = {
            "name": name,
            "config_dir": config_dir,
            "config_exists": config_dir_path.exists(),
            "commands_dir": commands_dir,
            "commands_markdown": count_command_files(commands_dir_path),
            "commands_md_only": count_files(commands_dir_path, "*.md"),
            "commands_toml_only": count_files(commands_dir_path, "*.toml"),
            "rules_dir": rules_dir,
            "rules_markdown": count_files(rules_dir_path, "*.md"),
        }
        targets.append(entry)

    report = {"targets": targets}

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    if format_name == "json":
        print(json.dumps(report, indent=2))
        return

    if format_name == "markdown":
        print("| Target | Config | Cmd (.md/.toml) | Rules (.md) |")
        print("| ------ | ------ | --------------- | ----------- |")
        for entry in targets:
            print(
                f"| {entry['name']} "
                f"| {'yes' if entry['config_exists'] else 'no'} "
                f"| {entry['commands_markdown']} "
                f"| {entry['rules_markdown']} |",
            )
    else:
        header = (
            f"{'Target':10} {'Config?':8} "
            f"{'Cmd(.md/.toml)':13} {'Rules(.md)':9}"
        )
        divider = "-" * len(header)
        print(header)
        print(divider)
        for entry in targets:
            print(
                f"{entry['name']:10} "
                f"{'yes' if entry['config_exists'] else 'no':8} "
                f"{entry['commands_markdown']:13} "
                f"{entry['rules_markdown']:9}",
            )

    if detailed and targets:
        print("\nDetailed directories:")
        for entry in targets:
            print(
                f"- {entry['name']}: "
                f"config={entry['config_dir']} "
                f"commands={entry['commands_dir']} "
                f"rules={entry['rules_dir']}",
            )


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv
    if len(args) != 1:
        print(
            "Usage: python -m config_sync.analyze_phase <output_json>",
            file=sys.stderr,
        )
        return 1
    output = Path(args[0])
    try:
        build_report(output)
        return 0
    except Exception as exc:  # noqa: BLE001
        print(f"[ERROR] Failed to write analyze report: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

