#!/usr/bin/env python3
"""
Sync plan builder for config-sync.

Usage:
    python3 -m config_sync.sync_plan_builder <plan_path> <action> <targets_csv> <components_csv> <profile> <phases_csv> <from_phase> <until_phase> <dry_run> <force> <verify> <settings_path> <timestamp> <run_root> <adapter>
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Dict, List


def _split_csv(value: str) -> List[str]:
    return [item for item in value.split(",") if item]


def _as_bool(value: str) -> bool:
    return value.lower() == "true"


def build_plan(
    plan_path: Path,
    action: str,
    targets_csv: str,
    components_csv: str,
    profile: str,
    phases_csv: str,
    from_phase: str,
    until_phase: str,
    dry_run: str,
    force: str,
    verify: str,
    settings_path: str,
    timestamp: str,
    run_root: str,
    adapter: str | None,
) -> Dict[str, object]:
    defaults: Dict[str, object] = {}

    settings = Path(settings_path) if settings_path else None
    if settings and settings.exists():
        try:
            config = json.loads(settings.read_text(encoding="utf-8"))
            defaults = config.get("defaults", {}) or {}
        except Exception:
            defaults = {}

    plan: Dict[str, object] = {
        "version": "1.0",
        "action": action,
        "targets": _split_csv(targets_csv),
        "components": _split_csv(components_csv),
        "profile": profile,
        "phases": _split_csv(phases_csv),
        "phase_window": {
            "from": from_phase or None,
            "until": until_phase or None,
        },
        "flags": {
            "dryRun": _as_bool(dry_run),
            "force": _as_bool(force),
            "verify": _as_bool(verify),
        },
        "settings": {
            "path": settings_path,
            "defaults": defaults,
        },
        "generated_at": timestamp,
        "run_root": run_root,
        "artifacts": {
            "plan": str(plan_path),
            "logs_dir": os.path.join(run_root, "logs"),
            "metadata_dir": os.path.join(run_root, "metadata"),
            "backups_dir": os.path.join(run_root, "backups"),
        },
    }

    if adapter:
        plan["adapter"] = adapter

    plan_path.parent.mkdir(parents=True, exist_ok=True)
    plan_path.write_text(json.dumps(plan, indent=2), encoding="utf-8")

    return plan


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv
    if len(args) != 15:
        print(
            "Usage: python -m config_sync.sync_plan_builder "
            "<plan_path> <action> <targets_csv> <components_csv> <profile> "
            "<phases_csv> <from_phase> <until_phase> <dry_run> <force> "
            "<verify> <settings_path> <timestamp> <run_root> <adapter>",
            file=sys.stderr,
        )
        return 1

    (
        plan_path,
        action,
        targets_csv,
        components_csv,
        profile,
        phases_csv,
        from_phase,
        until_phase,
        dry_run,
        force,
        verify,
        settings_path,
        timestamp,
        run_root,
        adapter,
    ) = args

    try:
        build_plan(
            plan_path=Path(plan_path),
            action=action,
            targets_csv=targets_csv,
            components_csv=components_csv,
            profile=profile,
            phases_csv=phases_csv,
            from_phase=from_phase,
            until_phase=until_phase,
            dry_run=dry_run,
            force=force,
            verify=verify,
            settings_path=settings_path,
            timestamp=timestamp,
            run_root=run_root,
            adapter=adapter or None,
        )
        return 0
    except Exception as exc:  # noqa: BLE001
        print(f"[ERROR] Failed to build plan: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

