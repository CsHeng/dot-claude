#!/usr/bin/env python3
"""
IDE header helper utilities for project rules sync.

This module centralizes YAML parsing and header generation so that
Shell scripts can remain thin wrappers and avoid inline Python.

Usage:
    python3 -m config_sync.ide_headers generate --config ide-headers.yaml --filename rules.md --target cursor
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Optional

import yaml


@dataclass
class IdeHeaderConfig:
    config_path: Path
    data: Dict[str, Any]

    @classmethod
    def load(cls, config_path: Path) -> "IdeHeaderConfig":
        if not config_path.exists():
            raise FileNotFoundError(f"IDE headers config not found: {config_path}")

        raw = config_path.read_text(encoding="utf-8")
        data = yaml.safe_load(raw) or {}
        if not isinstance(data, dict):
            data = {}
        return cls(config_path=config_path, data=data)

    def is_file_without_header(self, filename: str) -> bool:
        files = self.data.get("files_without_headers") or []
        if not isinstance(files, list):
            return False
        return filename in files

    def get_mapping_for(self, filename: str, target: str) -> Optional[Dict[str, Any]]:
        mappings = self.data.get("file_mappings") or {}
        if not isinstance(mappings, dict):
            return None
        file_mapping = mappings.get(filename)
        if not isinstance(file_mapping, dict):
            return None
        target_cfg = file_mapping.get(target)
        if target_cfg is None:
            return None
        if not isinstance(target_cfg, dict):
            return None
        return target_cfg


def generate_cursor_header(mapping: Optional[Dict[str, Any]]) -> str:
    """Generate Cursor header text."""
    if not mapping:
        return "---\n# Cursor Rules\n---\n"

    always_apply = bool(mapping.get("alwaysApply"))
    globs = mapping.get("globs")

    parts = ["---", "# Cursor Rules"]
    if always_apply:
        parts.append("alwaysApply: true")
    if globs:
        parts.append(f"globs: {globs}")
    parts.append("---")
    return "\n".join(parts) + "\n"


def generate_copilot_header(mapping: Optional[Dict[str, Any]]) -> str:
    """Generate Copilot header text."""
    apply_pattern = "**/*"
    if mapping and isinstance(mapping.get("applyTo"), str):
        apply_pattern = mapping["applyTo"]

    return (
        "---\n"
        "# Copilot Instructions\n"
        f'applyTo: "{apply_pattern}"\n'
        "---\n"
    )


def generate_header(
    config: IdeHeaderConfig,
    filename: str,
    target: str,
) -> Optional[str]:
    """Generate IDE header text for a file/target pair, or None if no header."""
    if config.is_file_without_header(filename):
        return None

    mapping = config.get_mapping_for(filename, target)
    if mapping is None:
        return None

    if target == "cursor":
        return generate_cursor_header(mapping)
    if target == "copilot":
        return generate_copilot_header(mapping)
    return None


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Generate IDE-specific headers for project rules files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python -m config_sync.ide_headers generate --config ide-headers.yaml --filename rules.md --target cursor
        """,
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    gen_parser = subparsers.add_parser(
        "generate",
        help="Generate header for a specific file and target",
    )
    gen_parser.add_argument(
        "--config",
        required=True,
        help="Path to IDE headers YAML configuration",
    )
    gen_parser.add_argument(
        "--filename",
        required=True,
        help="File name (basename) to look up",
    )
    gen_parser.add_argument(
        "--target",
        required=True,
        help="Target identifier (e.g. cursor, copilot)",
    )

    args = parser.parse_args(argv)

    if args.command == "generate":
        try:
            cfg = IdeHeaderConfig.load(Path(args.config).expanduser())
            header = generate_header(
                cfg,
                filename=args.filename,
                target=args.target,
            )
            if header is None:
                return 1
            print(header, end="")
            return 0
        except FileNotFoundError:
            return 1
        except Exception as exc:  # noqa: BLE001
            print(f"[ERROR] Failed to generate IDE header: {exc}", file=sys.stderr)
            return 1

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

