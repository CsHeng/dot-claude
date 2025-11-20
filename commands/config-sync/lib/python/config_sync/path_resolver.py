#!/usr/bin/env python3
"""
Path Resolver - Resolve paths using directory manifest configuration

Usage:
    python3 -m config_sync.path_resolver get-target-path --target <target> --component <component>
    python3 -m config_sync.path_resolver get-source-path --component <component>
    python3 -m config_sync.pathResolver list-targets
    python3 -m config_sync.path_resolver expand-variables --path <path>
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Any


class PathResolver:
    """Resolve paths using directory manifest configuration with variable expansion"""

    def __init__(self, manifest_path: Optional[str] = None):
        self.manifest_path = manifest_path or self._find_manifest()
        self.config = self._load_manifest()

    def _find_manifest(self) -> str:
        """Find directory-manifest.json file"""
        current_dir = Path(__file__).parent.parent
        manifest_paths = [
            current_dir / "directory-manifest.json",
            current_dir.parent / "directory-manifest.json",
        ]

        for path in manifest_paths:
            if path.exists():
                return str(path)

        # Fallback to environment variable
        env_manifest = os.environ.get('CONFIG_SYNC_MANIFEST')
        if env_manifest and Path(env_manifest).exists():
            return env_manifest

        raise FileNotFoundError("directory-manifest.json not found")

    def _load_manifest(self) -> Dict[str, Any]:
        """Load and expand variables in manifest"""
        try:
            with open(self.manifest_path, 'r', encoding='utf-8') as f:
                config = json.load(f)

            # First pass: load without expansion
            self._raw_config = config

            # Second pass: expand variables
            return self._expand_variables(config)
        except Exception as e:
            print(f"Error loading manifest: {e}", file=sys.stderr)
            return {}

    def _expand_variables(self, obj: Any) -> Any:
        """Recursively expand ${VARIABLE} references"""
        if isinstance(obj, str):
            return self._expand_string_variables(obj)
        elif isinstance(obj, dict):
            return {k: self._expand_variables(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [self._expand_variables(item) for item in obj]
        else:
            return obj

    def _expand_string_variables(self, text: str) -> str:
        """Expand variables in a string"""
        import re

        def replace_var(match):
            var_expr = match.group(1)

            # Handle ${basePaths.XXX} references
            if var_expr.startswith('basePaths.'):
                base_key = var_expr.split('.')[1]
                # Use raw_config to avoid circular reference
                base_paths = self._raw_config.get('basePaths', {})
                # Handle special cases with environment variables
                if base_key == 'userHome':
                    return os.environ.get('HOME', '')
                elif base_key == 'xdgConfigHome':
                    return os.environ.get('XDG_CONFIG_HOME', os.environ.get('HOME', '') + '/.config')
                elif base_key == 'claudeRoot':
                    return os.environ.get('HOME', '') + '/.claude'
                else:
                    return str(base_paths.get(base_key, ''))

            # Handle environment variables
            return os.environ.get(var_expr, '')

        return re.sub(r'\$\{([^}]+)\}', replace_var, text)

    def get_target_path(self, target: str, component: str) -> str:
        """Get target system component path"""
        target_config = self.config.get('targets', {}).get(target)
        if not target_config:
            print(f"Error: Target '{target}' not found in manifest", file=sys.stderr)
            return ""

        config_dir = target_config.get('configDir', '')
        components = target_config.get('components', {})

        component_path = components.get(component)
        if component_path is None:
            print(f"Error: Component '{component}' not supported by target '{target}'", file=sys.stderr)
            return ""

        return str(Path(config_dir) / component_path)

    def get_source_path(self, component: str, tool: Optional[str] = None) -> str:
        """Get source path for component"""
        source_paths = self.config.get('sourcePaths', {})

        # Handle simple string paths
        if component in source_paths and isinstance(source_paths[component], str):
            return source_paths[component]

        # Handle tool-specific memory paths
        if component == 'memory' and tool and isinstance(source_paths.get('memory'), dict):
            memory_paths = source_paths['memory']
            if tool in memory_paths:
                return memory_paths[tool]

        # Handle nested paths
        if '.' in component:
            parts = component.split('.')
            current = source_paths
            for part in parts:
                if isinstance(current, dict) and part in current:
                    current = current[part]
                else:
                    return ""
            return str(current) if current else ""

        print(f"Error: Source path for component '{component}' not found", file=sys.stderr)
        return ""

    def list_targets(self) -> List[str]:
        """List all available targets"""
        return list(self.config.get('targets', {}).keys())

    def get_components_for_target(self, target: str) -> List[str]:
        """Get supported components for a target"""
        target_config = self.config.get('targets', {}).get(target)
        if not target_config:
            return []

        components = target_config.get('components', {})
        # Filter out null/None values
        return [comp for comp, path in components.items() if path is not None]

    def validate_target(self, target: str) -> bool:
        """Check if target exists in manifest"""
        return target in self.config.get('targets', {})

    def expand_path(self, path: str) -> str:
        """Expand variables in a path string"""
        return self._expand_string_variables(path)

    def get_target_info(self, target: str) -> Dict[str, Any]:
        """Get complete target configuration"""
        return self.config.get('targets', {}).get(target, {})

    def get_base_path(self, base_name: str) -> str:
        """Get base path (userHome, xdgConfigHome, etc.)"""
        base_paths = self.config.get('basePaths', {})
        return base_paths.get(base_name, '')


def main():
    """CLI interface for PathResolver"""
    parser = argparse.ArgumentParser(
        description="Resolve paths using directory manifest",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s get-target-path --target droid --component commands
  %(prog)s get-source-path --component commands
  %(prog)s list-targets
  %(prog)s list-components --target droid
  %(prog)s expand-variables --path "${HOME}/.config"
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # get-target-path command
    target_parser = subparsers.add_parser('get-target-path', help='Get target component path')
    target_parser.add_argument('--target', required=True, help='Target system name')
    target_parser.add_argument('--component', required=True, help='Component name')

    # get-source-path command
    source_parser = subparsers.add_parser('get-source-path', help='Get source component path')
    source_parser.add_argument('--component', required=True, help='Component name')
    source_parser.add_argument('--tool', help='Tool name (for tool-specific paths)')

    # list-targets command
    list_targets_parser = subparsers.add_parser('list-targets', help='List all targets')

    # list-components command
    list_components_parser = subparsers.add_parser('list-components', help='List components for target')
    list_components_parser.add_argument('--target', required=True, help='Target system name')

    # validate-target command
    validate_parser = subparsers.add_parser('validate-target', help='Validate target exists')
    validate_parser.add_argument('--target', required=True, help='Target system name')

    # expand-variables command
    expand_parser = subparsers.add_parser('expand-variables', help='Expand variables in path')
    expand_parser.add_argument('--path', required=True, help='Path with variables to expand')

    # get-base-path command
    base_parser = subparsers.add_parser('get-base-path', help='Get base path')
    base_parser.add_argument('--name', required=True, help='Base path name (userHome, xdgConfigHome, etc.)')

    args = parser.parse_args()

    try:
        resolver = PathResolver()
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if args.command == 'get-target-path':
        result = resolver.get_target_path(args.target, args.component)
        if result:
            print(result)
            sys.exit(0)
        else:
            sys.exit(1)

    elif args.command == 'get-source-path':
        result = resolver.get_source_path(args.component, args.tool)
        if result:
            print(result)
            sys.exit(0)
        else:
            sys.exit(1)

    elif args.command == 'list-targets':
        targets = resolver.list_targets()
        for target in targets:
            print(target)
        sys.exit(0)

    elif args.command == 'list-components':
        components = resolver.get_components_for_target(args.target)
        for component in components:
            print(component)
        sys.exit(0)

    elif args.command == 'validate-target':
        if resolver.validate_target(args.target):
            print(f"✓ Target '{args.target}' is valid")
            sys.exit(0)
        else:
            print(f"✗ Target '{args.target}' not found")
            sys.exit(1)

    elif args.command == 'expand-variables':
        result = resolver.expand_path(args.path)
        print(result)
        sys.exit(0)

    elif args.command == 'get-base-path':
        result = resolver.get_base_path(args.name)
        if result:
            print(result)
            sys.exit(0)
        else:
            sys.exit(1)

    else:
        parser.print_help()
        sys.exit(1)


if __name__ == '__main__':
    main()