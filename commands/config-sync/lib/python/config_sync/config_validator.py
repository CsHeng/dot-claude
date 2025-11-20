#!/usr/bin/env python3
"""
Configuration Validator - Validate configurations and files

Usage:
    python3 -m config_sync.config_validator validate <file>
    python3 -m config_sync.config_validator validate-frontmatter <file>
    python3 -m config_sync.config_validator check-target <target>
"""

import argparse
import json
import os
import sys
import warnings
from pathlib import Path
from typing import Dict, List, Optional, Any
import yaml
import re

# Suppress runtime warnings about module already being imported
warnings.filterwarnings('ignore', category=RuntimeWarning, module='runpy')

from .path_resolver import PathResolver


class ConfigValidator:
    """Validate configurations and files"""

    def __init__(self, manifest_path: Optional[str] = None):
        self.path_resolver = PathResolver(manifest_path)

    def validate_json_file(self, file_path: str) -> bool:
        """Validate JSON file syntax and structure"""
        try:
            path_obj = Path(file_path).expanduser()
            if not path_obj.exists():
                print(f"Error: File not found: {path_obj}", file=sys.stderr)
                return False

            json.loads(path_obj.read_text(encoding='utf-8'))
            return True

        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in {file_path}: {e}", file=sys.stderr)
            return False
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            return False

    def validate_yaml_frontmatter(self, file_path: str) -> bool:
        """Validate YAML frontmatter in Markdown files"""
        try:
            path_obj = Path(file_path).expanduser()
            if not path_obj.exists():
                print(f"Error: File not found: {path_obj}", file=sys.stderr)
                return False

            content = path_obj.read_text(encoding='utf-8')

            if not content.startswith('---'):
                print(f"Warning: No frontmatter found in {file_path}", file=sys.stderr)
                return True  # Not an error, just a warning

            # Extract frontmatter
            end_marker = content.find('\n---\n', 4)
            if end_marker == -1:
                print(f"Error: Unclosed frontmatter in {file_path}", file=sys.stderr)
                return False

            frontmatter_text = content[4:end_marker]
            yaml.safe_load(frontmatter_text)
            return True

        except yaml.YAMLError as e:
            print(f"Error: Invalid YAML frontmatter in {file_path}: {e}", file=sys.stderr)
            return False
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            return False

    def check_target_configuration(self, target: str) -> Dict[str, Any]:
        """Check target configuration validity"""
        result = {
            "valid": False,
            "errors": [],
            "warnings": [],
            "info": {}
        }

        if not self.path_resolver.validate_target(target):
            result["errors"].append(f"Target '{target}' not found in manifest")
            return result

        try:
            target_info = self.path_resolver.get_target_info(target)
            result["info"] = target_info

            # Check config directory
            config_dir = Path(target_info.get("configDir", "")).expanduser()
            if not config_dir.exists():
                result["warnings"].append(f"Config directory does not exist: {config_dir}")
            else:
                result["info"]["config_dir_exists"] = True

            # Check components
            components = target_info.get("components", {})
            for comp_name, comp_path in components.items():
                if comp_path is None:
                    continue  # Unsupported component

                full_path = config_dir / comp_path
                if not full_path.exists():
                    result["warnings"].append(f"Component path does not exist: {full_path}")
                else:
                    result["info"][f"component_{comp_name}_exists"] = True

            result["valid"] = len(result["errors"]) == 0

        except Exception as e:
            result["errors"].append(f"Error checking target: {e}")

        return result

    def validate_command_files(self, commands_dir: str) -> Dict[str, Any]:
        """Validate all command files in directory"""
        result = {
            "valid": True,
            "errors": [],
            "warnings": [],
            "processed": 0,
            "invalid_files": []
        }

        commands_path = Path(commands_dir).expanduser()
        if not commands_path.exists():
            result["errors"].append(f"Commands directory not found: {commands_path}")
            result["valid"] = False
            return result

        for cmd_file in commands_path.rglob("*.md"):
            result["processed"] += 1

            if not self.validate_yaml_frontmatter(str(cmd_file)):
                result["invalid_files"].append(str(cmd_file))
                result["valid"] = False

        if result["invalid_files"]:
            result["errors"].append(f"Found {len(result['invalid_files'])} files with invalid frontmatter")

        return result

    def validate_manifest_structure(self) -> Dict[str, Any]:
        """Validate directory manifest structure"""
        result = {
            "valid": True,
            "errors": [],
            "warnings": [],
            "info": {}
        }

        try:
            # Check base paths
            base_paths = self.path_resolver.config.get("basePaths", {})
            for base_name, base_path in base_paths.items():
                expanded_path = self.path_resolver.expand_path(base_path)
                if not Path(expanded_path).expanduser().exists():
                    result["warnings"].append(f"Base path does not exist: {base_name} -> {expanded_path}")

            # Check source paths
            source_paths = self.path_resolver.config.get("sourcePaths", {})
            for source_name, source_path in source_paths.items():
                if isinstance(source_path, str):
                    expanded_path = self.path_resolver.expand_path(source_path)
                    if not Path(expanded_path).expanduser().exists():
                        result["warnings"].append(f"Source path does not exist: {source_name} -> {expanded_path}")

            result["info"]["targets_count"] = len(self.path_resolver.config.get("targets", {}))
            result["info"]["base_paths_count"] = len(base_paths)
            result["info"]["source_paths_count"] = len(source_paths)

        except Exception as e:
            result["errors"].append(f"Error validating manifest: {e}")
            result["valid"] = False

        return result

    def check_permissions_file(self, permissions_file: str) -> Dict[str, Any]:
        """Check permissions file structure"""
        result = {
            "valid": True,
            "errors": [],
            "warnings": [],
            "info": {}
        }

        try:
            path_obj = Path(permissions_file).expanduser()
            if not path_obj.exists():
                result["warnings"].append(f"Permissions file not found: {permissions_file}")
                return result

            if permissions_file.endswith('.json'):
                if not self.validate_json_file(permissions_file):
                    result["valid"] = False
                    result["errors"].append("Invalid JSON permissions file")
            else:
                result["warnings"].append(f"Unknown permissions file format: {permissions_file}")

        except Exception as e:
            result["errors"].append(f"Error checking permissions file: {e}")
            result["valid"] = False

        return result


def main():
    """CLI interface for ConfigValidator"""
    parser = argparse.ArgumentParser(
        description="Validate configurations and files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s validate manifest.json
  %(prog)s validate-frontmatter commands/example.md
  %(prog)s check-target --target droid
  %(prog)s validate-commands --dir ~/.factory/commands
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # validate command
    validate_parser = subparsers.add_parser('validate', help='Validate JSON file')
    validate_parser.add_argument('file', help='JSON file path')

    # validate-frontmatter command
    frontmatter_parser = subparsers.add_parser('validate-frontmatter', help='Validate YAML frontmatter')
    frontmatter_parser.add_argument('file', help='Markdown file path')

    # check-target command
    target_parser = subparsers.add_parser('check-target', help='Check target configuration')
    target_parser.add_argument('--target', required=True, help='Target system name')

    # validate-commands command
    commands_parser = subparsers.add_parser('validate-commands', help='Validate command files')
    commands_parser.add_argument('--dir', required=True, help='Commands directory path')

    # validate-manifest command
    manifest_parser = subparsers.add_parser('validate-manifest', help='Validate manifest structure')

    # check-permissions command
    permissions_parser = subparsers.add_parser('check-permissions', help='Check permissions file')
    permissions_parser.add_argument('file', help='Permissions file path')

    args = parser.parse_args()

    try:
        validator = ConfigValidator()
    except Exception as e:
        print(f"Error initializing validator: {e}", file=sys.stderr)
        sys.exit(1)

    if args.command == 'validate':
        if validator.validate_json_file(args.file):
            print(f"✓ Valid JSON: {args.file}")
            sys.exit(0)
        else:
            sys.exit(1)

    elif args.command == 'validate-frontmatter':
        if validator.validate_yaml_frontmatter(args.file):
            print(f"✓ Valid frontmatter: {args.file}")
            sys.exit(0)
        else:
            sys.exit(1)

    elif args.command == 'check-target':
        result = validator.check_target_configuration(args.target)
        print(f"Target: {args.target}")
        print(f"Valid: {'✓' if result['valid'] else '✗'}")

        if result['errors']:
            print("\nErrors:")
            for error in result['errors']:
                print(f"  ✗ {error}")

        if result['warnings']:
            print("\nWarnings:")
            for warning in result['warnings']:
                print(f"  ⚠ {warning}")

        if result['info']:
            print("\nInfo:")
            for key, value in result['info'].items():
                print(f"  • {key}: {value}")

        sys.exit(0 if result['valid'] else 1)

    elif args.command == 'validate-commands':
        result = validator.validate_command_files(args.dir)
        print(f"Commands directory: {args.dir}")
        print(f"Valid: {'✓' if result['valid'] else '✗'}")
        print(f"Processed: {result['processed']} files")

        if result['errors']:
            print("\nErrors:")
            for error in result['errors']:
                print(f"  ✗ {error}")

        if result['warnings']:
            print("\nWarnings:")
            for warning in result['warnings']:
                print(f"  ⚠ {warning}")

        sys.exit(0 if result['valid'] else 1)

    elif args.command == 'validate-manifest':
        result = validator.validate_manifest_structure()
        print(f"Manifest structure: {'✓' if result['valid'] else '✗'}")

        if result['errors']:
            print("\nErrors:")
            for error in result['errors']:
                print(f"  ✗ {error}")

        if result['warnings']:
            print("\nWarnings:")
            for warning in result['warnings']:
                print(f"  ⚠ {warning}")

        if result['info']:
            print("\nInfo:")
            for key, value in result['info'].items():
                print(f"  • {key}: {value}")

        sys.exit(0 if result['valid'] else 1)

    elif args.command == 'check-permissions':
        result = validator.check_permissions_file(args.file)
        print(f"Permissions file: {args.file}")
        print(f"Valid: {'✓' if result['valid'] else '✗'}")

        if result['errors']:
            print("\nErrors:")
            for error in result['errors']:
                print(f"  ✗ {error}")

        if result['warnings']:
            print("\nWarnings:")
            for warning in result['warnings']:
                print(f"  ⚠ {warning}")

        sys.exit(0 if result['valid'] else 1)

    else:
        parser.print_help()
        sys.exit(1)


if __name__ == '__main__':
    main()