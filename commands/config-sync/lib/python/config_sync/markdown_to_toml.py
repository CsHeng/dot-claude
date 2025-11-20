#!/usr/bin/env python3
"""
Markdown to TOML converter for config-sync commands.

Usage:
    python3 -m config_sync.markdown_to_toml convert <input_md> <output_toml> --target-tool <tool>
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path
from typing import Optional


def convert_markdown_to_toml(
    md_path: Path,
    toml_path: Path,
    target_tool: str = "qwen",
) -> None:
    """Convert a Markdown command with YAML frontmatter to TOML format."""
    if not md_path.exists():
        raise FileNotFoundError(f"Source file not found: {md_path}")

    content = md_path.read_text(encoding="utf-8")

    description = ""
    frontmatter_match = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)$", content, re.DOTALL)

    is_background = False

    if frontmatter_match:
        frontmatter, command_content = frontmatter_match.groups()
        desc_match = re.search(
            r'description:\s*["\']?([^"\'\n]+)["\']?',
            frontmatter,
        )
        if desc_match:
            description = desc_match.group(1).strip()

        background_match = re.search(r"is_background:\s*([^\n]+)", frontmatter)
        if background_match:
            value = background_match.group(1).strip().strip("\"'").lower()
            if value in {"true", "yes", "1"}:
                is_background = True
            elif value in {"false", "no", "0"}:
                is_background = False

        body_content = command_content.strip()
    else:
        body_content = content.strip()

    if not description:
        base_name = md_path.name
        description = f"Converted from {base_name} for {target_tool}"

    if target_tool == "qwen":
        body_content = re.sub(r"\$ARGUMENTS", "{{args}}", body_content)
        body_content = re.sub(r"\$[0-9]+", "{{args}}", body_content)
        body_content = re.sub(r"@CLAUDE\.md", "@QWEN.md", body_content)

    description_escaped = description.replace('"', r"\"")

    use_literal_prompt = "'''" not in body_content

    if use_literal_prompt:
        prompt_lines = [
            "prompt = '''",
            body_content,
            "'''",
            "",
        ]
    else:
        body_content_escaped = (
            body_content.replace("\\", r"\\").replace('"""', r"\"\"\"")
        )
        prompt_lines = [
            f'prompt = """{body_content_escaped}"""',
            "",
        ]

    toml_lines = [
        f"# Generated from {md_path} by Claude Code config-sync",
        "",
        f'description = "{description_escaped}"',
    ]

    if target_tool == "qwen":
        toml_lines.append(
            f"is_background = {'true' if is_background else 'false'}",
        )

    toml_lines.append("")
    toml_lines.extend(prompt_lines)

    toml_path.parent.mkdir(parents=True, exist_ok=True)
    toml_path.write_text("\n".join(toml_lines), encoding="utf-8")


def main(argv: Optional[list[str]] = None) -> int:
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Convert Markdown command files with YAML frontmatter to TOML format",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python -m config_sync.markdown_to_toml convert command.md command.toml
  python -m config_sync.markdown_to_toml convert command.md command.toml --target-tool qwen
        """,
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    convert_parser = subparsers.add_parser(
        "convert",
        help="Convert a Markdown file to TOML",
    )
    convert_parser.add_argument("input_md", help="Input Markdown file path")
    convert_parser.add_argument("output_toml", help="Output TOML file path")
    convert_parser.add_argument(
        "--target-tool",
        default="qwen",
        help="Target tool identifier (default: qwen)",
    )

    args = parser.parse_args(argv)

    if args.command == "convert":
        try:
            md_path = Path(args.input_md).expanduser()
            toml_path = Path(args.output_toml).expanduser()
            convert_markdown_to_toml(
                md_path=md_path,
                toml_path=toml_path,
                target_tool=args.target_tool,
            )
            print(
                f"[SUCCESS] Converted {md_path} to {toml_path}",
                file=sys.stderr,
            )
            return 0
        except Exception as exc:  # noqa: BLE001
            print(
                f"[ERROR] Failed to convert {args.input_md}: {exc}",
                file=sys.stderr,
            )
            return 1

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

