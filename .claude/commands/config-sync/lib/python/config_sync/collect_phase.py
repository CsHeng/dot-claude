#!/usr/bin/env python3
"""
Collect phase helpers for config-sync.

Usage:
    python3 -m config_sync.collect_phase <output_json> <action> <targets_csv> <components_csv> <plan_file> <runtime_dir>
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import List


def _split_csv(value: str) -> List[str]:
    return [item for item in value.split(",") if item]


def write_metadata(
    output_path: Path,
    action: str,
    targets_csv: str,
    components_csv: str,
    plan_file: str,
    runtime_dir: str,
) -> None:
    """Write collect phase metadata JSON."""
    report = {
        "action": action,
        "targets": _split_csv(targets_csv),
        "components": _split_csv(components_csv),
        "plan_file": plan_file,
        "runtime_dir": runtime_dir,
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv

    if len(args) != 6:
        print(
            "Usage: python -m config_sync.collect_phase "
            "<output_json> <action> <targets_csv> <components_csv> <plan_file> <runtime_dir>",
            file=sys.stderr,
        )
        return 1

    output, action, targets_csv, components_csv, plan_file, runtime_dir = args

    try:
        write_metadata(
            output_path=Path(output),
            action=action,
            targets_csv=targets_csv,
            components_csv=components_csv,
            plan_file=plan_file,
            runtime_dir=runtime_dir,
        )
        return 0
    except Exception as exc:  # noqa: BLE001
        print(f"[ERROR] Failed to write collect metadata: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

