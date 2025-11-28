#!/usr/bin/env python3
"""
Tool Availability Checker for LLM Governance

This script provides deterministic tool selection with fallback strategies
for file discovery, text search, and structural analysis operations.
"""

import subprocess
import sys
import os
from pathlib import Path
from typing import Dict, List, Optional, Tuple


class ToolChecker:
    """Manages tool availability and selection with fallback strategies."""
    
    def __init__(self):
        self.tools = {}
        self.fallback_chains = {
            'file_discovery': ['fd', 'find', 'python_pathlib'],
            'text_search': ['rg', 'grep', 'python_str'],
            'structural_analysis': ['ast-grep', 'pattern_rg', 'manual']
        }
        self._check_all_tools()
    
    def _run_command(self, cmd: List[str]) -> Tuple[bool, str]:
        """Run a command and return (success, output)."""
        try:
            result = subprocess.run(
                cmd, 
                capture_output=True, 
                text=True, 
                timeout=10
            )
            return result.returncode == 0, result.stdout.strip()
        except (subprocess.TimeoutExpired, FileNotFoundError, Exception):
            return False, ""
    
    def _check_tool(self, tool_name: str) -> bool:
        """Check if a specific tool is available and functional."""
        checks = {
            'fd': [self._run_command(['fd', '--version'])],
            'find': [self._run_command(['find', '--version']), 
                    self._run_command(['which', 'find'])],
            'rg': [self._run_command(['rg', '--version'])],
            'grep': [self._run_command(['grep', '--version']), 
                    self._run_command(['which', 'grep'])],
            'ast-grep': [self._run_command(['ast-grep', '--version'])]
        }
        
        if tool_name not in checks:
            return tool_name in ['python_pathlib', 'python_str', 'pattern_rg', 'manual']
        
        return any(success for success, _ in checks[tool_name])
    
    def _check_all_tools(self):
        """Check availability of all tools."""
        all_tools = set()
        for chain in self.fallback_chains.values():
            all_tools.update(chain)
        
        for tool in all_tools:
            self.tools[tool] = self._check_tool(tool)
    
    def get_tool(self, purpose: str) -> Optional[str]:
        """Get the best available tool for a specific purpose."""
        if purpose not in self.fallback_chains:
            return None
        
        for tool in self.fallback_chains[purpose]:
            if self.tools.get(tool, False):
                return tool
        
        return None
    
    def get_file_discovery_command(self, pattern: str, base_path: str = ".") -> List[str]:
        """Get the appropriate file discovery command."""
        tool = self.get_tool('file_discovery')
        
        if tool == 'fd':
            return ['fd', pattern, base_path, '--type', 'f']
        elif tool == 'find':
            return ['find', base_path, '-type', 'f', '-name', pattern]
        elif tool == 'python_pathlib':
            # Return a marker that will be handled by Python code
            return ['python_pathlib', pattern, base_path]
        
        raise RuntimeError(f"No file discovery tool available")
    
    def get_text_search_command(self, pattern: str, file_list: List[str] = None) -> List[str]:
        """Get the appropriate text search command."""
        tool = self.get_tool('text_search')
        
        if tool == 'rg':
            if file_list:
                return ['rg', pattern, '--'] + file_list
            return ['rg', pattern, '.']
        elif tool == 'grep':
            if file_list:
                return ['grep', '-R', pattern] + file_list
            return ['grep', '-R', pattern, '.']
        elif tool == 'python_str':
            return ['python_str', pattern]
        
        raise RuntimeError(f"No text search tool available")
    
    def print_status(self):
        """Print the current tool availability status."""
        print("Tool Availability Status:")
        print("=" * 50)
        
        for purpose, chain in self.fallback_chains.items():
            print(f"\n{purpose.replace('_', ' ').title()}:")
            for tool in chain:
                status = "✓ Available" if self.tools.get(tool, False) else "✗ Unavailable"
                print(f"  {tool:15} {status}")
                
            selected = self.get_tool(purpose)
            if selected:
                print(f"  → Selected: {selected}")
            else:
                print(f"  → No tool available!")
        
        print("\nSummary:")
        available_count = sum(1 for available in self.tools.values() if available)
        total_count = len(self.tools)
        print(f"  {available_count}/{total_count} tools available")


def main():
    """Main function for standalone usage."""
    checker = ToolChecker()
    checker.print_status()
    
    # Exit with error code if critical tools are missing
    critical_purposes = ['file_discovery', 'text_search']
    for purpose in critical_purposes:
        if not checker.get_tool(purpose):
            print(f"\nERROR: No tool available for {purpose}!", file=sys.stderr)
            sys.exit(1)
    
    print("\nAll critical tools available or have fallbacks.")


if __name__ == '__main__':
    main()
