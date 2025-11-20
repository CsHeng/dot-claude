#!/usr/bin/env python3
"""
Report phase helpers for config-sync.

Usage:
    python3 -m config_sync.report_phase <output_json>

Environment:
    REPORT_LINES: newline-separated "phase|status|message" entries
    REPORT_PLAN:  plan file path
    REPORT_RUN:   run directory path
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Dict, List


def _parse_lines(lines_raw: str) -> List[Dict[str, str]]:
    phases: List[Dict[str, str]] = []
    for row in lines_raw.splitlines():
        row = row.strip()
        if not row:
            continue
        parts = row.split("|", 2)
        if len(parts) != 3:
            continue
        name, status, message = parts
        phases.append({"phase": name, "status": status, "message": message})
    return phases


def build_report(output_path: Path) -> None:
    lines_raw = os.environ.get("REPORT_LINES", "")
    plan_file = os.environ.get("REPORT_PLAN")
    run_dir = os.environ.get("REPORT_RUN")

    phases = _parse_lines(lines_raw)
    status_counts: Dict[str, int] = {
        "success": 0,
        "failed": 0,
        "skipped": 0,
        "pending": 0,
    }

    for entry in phases:
        status = entry["status"]
        status_counts.setdefault(status, 0)
        status_counts[status] += 1

    final_status = "success"
    if status_counts.get("failed"):
        final_status = "failed"
    elif status_counts.get("skipped"):
        final_status = "partial"

    report = {
        "status": final_status,
        "plan_file": plan_file,
        "run_dir": run_dir,
        "phases": phases,
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    print("=== Pipeline Report ===")
    print(f"Status : {final_status}")
    print(f"Plan   : {report['plan_file']}")
    print(f"Run dir: {report['run_dir']}")
    print("-----------------------")
    for entry in phases:
        print(
            f"{entry['phase']:>8}: {entry['status']:<7} {entry['message']}",
        )


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv
    if len(args) != 1:
        print(
            "Usage: python -m config_sync.report_phase <output_json>",
            file=sys.stderr,
        )
        return 1

    output = Path(args[0])
    try:
        build_report(output)
        return 0
    except Exception as exc:  # noqa: BLE001
        print(f"[ERROR] Failed to write report metadata: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

