#!/usr/bin/env python3
"""
Optimize-Prompts Command Implementation

This script implements the /optimize-prompts command with all the optimizations
including tool fallbacks, Claude Code specification validation, and dependency analysis.
"""

import sys
import argparse
import json
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime

import yaml

# Import our optimized tools
from tool_checker import ToolChecker
from claude_code_validator import ClaudeCodeValidator
from dependency_analyzer import DependencyAnalyzer


class OptimizePrompts:
    """Main optimize-prompts command implementation."""
    
    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir).resolve()
        self.tool_checker = ToolChecker()
        self.validator = ClaudeCodeValidator()
        self.dependency_analyzer = DependencyAnalyzer()
        self.candidates = {}
        self.original_files = {}
        self.stats = {
            'analyzed': 0,
            'written': 0,
            'skipped': 0,
            'errors': 0
        }
    
    def run(self, target_path: Optional[str] = None, use_all: bool = False) -> int:
        """Main entry point for optimize-prompts command."""
        print("🚀 Starting Optimize-Prompts with Enhanced Validation")
        print(f"📁 Root directory: {self.root_dir}")
        
        try:
            # Phase 0: Tool validation and setup
            if not self._validate_tools():
                print("❌ Tool validation failed")
                return 1
            
            # Phase 1: Discover and resolve targets
            targets = self._resolve_targets(target_path, use_all)
            if not targets:
                print("ℹ️  No target files found")
                return 0
            
            print(f"📋 Found {len(targets)} target files")
            
            # Phase 2: Load and analyze files
            if not self._load_and_analyze_files(targets):
                print("❌ File analysis failed")
                return 1
            
            # Phase 3: Generate candidates
            if not self._generate_candidates():
                print("❌ Candidate generation failed")
                return 1
            
            # Phase 4: Validate dependencies
            if not self._validate_dependencies():
                print("⚠️  Dependency validation found issues")
            
            # Phase 5: Review with user
            if not self._review_with_user():
                print("ℹ️  No changes approved")
                return 0
            
            # Phase 6: Apply changes
            if not self._apply_changes():
                print("❌ Failed to apply changes")
                return 1
            
            # Phase 7: Post-write validation
            if not self._post_write_validation():
                print("⚠️  Post-write validation found issues")
            
            self._print_summary()
            return 0
            
        except KeyboardInterrupt:
            print("\n⚠️  Operation cancelled by user")
            return 130
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            return 1
    
    def _validate_tools(self) -> bool:
        """Validate tool availability with fallbacks."""
        print("\n🔧 Validating tools...")
        
        # Check critical tools
        file_tool = self.tool_checker.get_tool('file_discovery')
        search_tool = self.tool_checker.get_tool('text_search')
        
        if not file_tool or not search_tool:
            print("❌ Critical tools not available")
            self.tool_checker.print_status()
            return False
        
        print(f"✅ File discovery: {file_tool}")
        print(f"✅ Text search: {search_tool}")
        
        structural_tool = self.tool_checker.get_tool('structural_analysis')
        if structural_tool:
            print(f"✅ Structural analysis: {structural_tool}")
        else:
            print("⚠️  Structural analysis tool not available, using fallback")
        
        return True
    
    def _resolve_targets(self, target_path: Optional[str], use_all: bool) -> List[Path]:
        """Resolve target files based on input arguments."""
        print("\n🎯 Resolving targets...")
        
        if use_all:
            return self._discover_all_targets()
        elif target_path:
            path = Path(target_path)
            if path.exists():
                return [path]
            else:
                print(f"❌ Target path does not exist: {target_path}")
                return []
        else:
            print("ℹ️  No target specified, showing usage")
            self._print_usage()
            return []
    
    def _discover_all_targets(self) -> List[Path]:
        """Discover all LLM-facing files using appropriate tools."""
        patterns: List[str] = []

        # Load directory classification patterns from classification-rules.yaml when available
        classification_file = self.root_dir / "commands" / "optimize-prompts" / "classification-rules.yaml"
        if classification_file.exists():
            try:
                with open(classification_file, "r", encoding="utf-8") as f:
                    rules = yaml.safe_load(f) or {}

                for key in ("skills", "commands", "agents", "rules", "core"):
                    section = rules.get(key)
                    if not section:
                        continue
                    dir_pattern = section.get("directory_pattern")
                    if isinstance(dir_pattern, str):
                        patterns.append(dir_pattern)
                    elif isinstance(dir_pattern, list):
                        patterns.extend(p for p in dir_pattern if isinstance(p, str))
            except Exception as e:
                print(f"⚠️  Failed to load classification rules from {classification_file}: {e}")

        # Fallback to hard-coded patterns when classification rules are missing or incomplete
        if not patterns:
            patterns = [
                "commands/**/*.md",
                "skills/**/SKILL.md",
                "agents/**/AGENT.md",
                "rules/**/*.md",
                "AGENTS.md",
                "CLAUDE.md",
                ".claude/settings.json",
            ]
        
        exclude_patterns = [
            "**/README.md",
            "**/README*",
            "docs/**",
            "src/**",
            "examples/**",
            "tests/**",
            "ide/**",
            "backup/**",
        ]
        
        targets = []
        tool = self.tool_checker.get_tool('file_discovery')
        
        if tool == 'fd':
            # Use fd with --exclude for efficiency
            for pattern in patterns:
                try:
                    result = subprocess.run(
                        ['fd', pattern, str(self.root_dir), '--type', 'f'],
                        capture_output=True, text=True, timeout=30
                    )
                    if result.stdout:
                        targets.extend([Path(line.strip()) for line in result.stdout.split('\n') if line.strip()])
                except subprocess.TimeoutExpired:
                    continue
        
        elif tool == 'find':
            # Fallback to find
            for pattern in patterns:
                try:
                    # Convert glob to find pattern (simplified)
                    if '**' in pattern:
                        parts = pattern.split('**')
                        if len(parts) == 2:
                            base_pattern = parts[0]
                            file_pattern = parts[1]
                            cmd = ['find', str(self.root_dir / base_pattern), '-name', file_pattern, '-type', 'f']
                        else:
                            continue
                    else:
                        cmd = ['find', str(self.root_dir), '-name', pattern, '-type', 'f']
                    
                    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
                    if result.stdout:
                        targets.extend([Path(line.strip()) for line in result.stdout.split('\n') if line.strip()])
                except subprocess.TimeoutExpired:
                    continue
        
        else:
            # Python pathlib fallback
            for pattern in patterns:
                for path in self.root_dir.glob(pattern):
                    if path.is_file():
                        targets.append(path)
        
        # Filter out excluded patterns
        filtered_targets = []
        for target in targets:
            should_exclude = False
            for exclude in exclude_patterns:
                if target.match(exclude):
                    should_exclude = True
                    break
            
            if not should_exclude:
                filtered_targets.append(target)
        
        return filtered_targets
    
    def _load_and_analyze_files(self, targets: List[Path]) -> bool:
        """Load and analyze target files."""
        print("\n📖 Loading and analyzing files...")
        
        for target in targets:
            try:
                # Skip files flagged with dont-optimize
                if self._has_dont_optimize_flag(target):
                    print(f"⏭️  Skipping {target.name} (dont-optimize flag)")
                    self.stats['skipped'] += 1
                    continue
                
                # Read file content
                with open(target, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                self.original_files[str(target)] = content
                self.stats['analyzed'] += 1
                
            except Exception as e:
                print(f"❌ Failed to read {target}: {e}")
                self.stats['errors'] += 1
                return False
        
        print(f"✅ Loaded {self.stats['analyzed']} files")
        return True
    
    def _has_dont_optimize_flag(self, file_path: Path) -> bool:
        """Check if file has dont-optimize: true flag."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check for dont-optimize in frontmatter
            if content.startswith('---'):
                fm_end = content.find('---', 3)
                if fm_end != -1:
                    frontmatter = content[3:fm_end]
                    return 'dont-optimize: true' in frontmatter.lower()
        except:
            pass
        
        return False
    
    def _generate_candidates(self) -> bool:
        """Generate optimized candidates for all files."""
        print("\n🔨 Generating optimized candidates...")
        
        # Use Claude Code validator to check and suggest improvements
        validation_results = {}
        
        for file_path, content in self.original_files.items():
            path = Path(file_path)
            
            # Validate the file
            errors = self.validator.validate_file(path)
            validation_results[file_path] = errors
            
            if errors:
                print(f"⚠️  {path.name}: {len(errors)} issues found")
                # For now, keep original as candidate
                self.candidates[file_path] = content
            else:
                print(f"✅ {path.name}: No issues found")
                self.candidates[file_path] = content
        
        print(f"✅ Generated {len(self.candidates)} candidates")
        return True
    
    def _validate_dependencies(self) -> bool:
        """Validate dependency relationships."""
        print("\n🕸️  Validating dependencies...")
        
        try:
            issues = self.dependency_analyzer.analyze_directory(self.root_dir)
            
            if issues:
                print(f"⚠️  Found {len(issues)} dependency issues")
                
                # Group by severity
                critical = [i for i in issues if i.severity == 'critical']
                warnings = [i for i in issues if i.severity == 'warning']
                
                if critical:
                    print(f"❌ {len(critical)} critical issues:")
                    for issue in critical[:5]:  # Limit output
                        print(f"   {issue}")
                    if len(critical) > 5:
                        print(f"   ... and {len(critical) - 5} more")
                
                if warnings:
                    print(f"⚠️  {len(warnings)} warnings:")
                    for issue in warnings[:5]:  # Limit output
                        print(f"   {issue}")
                    if len(warnings) > 5:
                        print(f"   ... and {len(warnings) - 5} more")
                
                # Continue despite dependency issues
                return len(critical) == 0
            else:
                print("✅ No dependency issues found")
                return True
                
        except Exception as e:
            print(f"❌ Dependency validation failed: {e}")
            return False
    
    def _review_with_user(self) -> bool:
        """Review candidates with user and request confirmation."""
        print("\n👀 Review and Confirmation")
        print("=" * 50)
        
        print(f"📊 Summary:")
        print(f"  Files analyzed: {self.stats['analyzed']}")
        print(f"  Files with issues: {len([v for v in self.candidates.values() if v != self.original_files.get(str(k))])}")
        print(f"  Files skipped: {self.stats['skipped']}")
        print(f"  Errors: {self.stats['errors']}")
        
        # Show a few examples of changes
        changes_count = 0
        for file_path, candidate in self.candidates.items():
            original = self.original_files.get(file_path)
            if original and candidate != original:
                changes_count += 1
                if changes_count <= 3:  # Show first 3 changes
                    path = Path(file_path)
                    print(f"\n📝 {path.name}:")
                    print(f"   Status: Will be optimized")
        
        if changes_count > 3:
            print(f"\n   ... and {changes_count - 3} more files")
        
        if changes_count == 0:
            print("\n✅ No changes needed - all files already compliant")
            return False
        
        print(f"\n❓ Do you want to apply these {changes_count} changes? (y/N)")
        try:
            response = input().strip().lower()
            return response in ['y', 'yes']
        except KeyboardInterrupt:
            return False
    
    def _apply_changes(self) -> bool:
        """Apply approved changes to files."""
        print("\n💾 Applying changes...")
        
        # Create backup
        backup_dir = self.root_dir / '.claude' / 'backup' / f'rollback-{datetime.now().strftime("%Y%m%d_%H%M%S")}'
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        written_count = 0
        
        for file_path, candidate in self.candidates.items():
            original = self.original_files.get(file_path)
            if original and candidate != original:
                path = Path(file_path)
                
                try:
                    # Backup original
                    backup_path = backup_dir / path.relative_to(self.root_dir)
                    backup_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(path, backup_path)
                    
                    # Write candidate
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(candidate)
                    
                    written_count += 1
                    print(f"✅ Updated {path.name}")
                    
                except Exception as e:
                    print(f"❌ Failed to update {path.name}: {e}")
                    self.stats['errors'] += 1
                    return False
        
        self.stats['written'] = written_count
        print(f"✅ Successfully applied {written_count} changes")
        print(f"📁 Backup created at: {backup_dir}")
        return True
    
    def _post_write_validation(self) -> bool:
        """Validate files after writing changes."""
        print("\n🔍 Post-write validation...")
        
        try:
            # Re-validate written files
            issues_found = 0
            for file_path in self.candidates.keys():
                path = Path(file_path)
                if path.exists():
                    errors = self.validator.validate_file(path)
                    if errors:
                        issues_found += len(errors)
            
            if issues_found == 0:
                print("✅ All written files pass validation")
                return True
            else:
                print(f"⚠️  Found {issues_found} remaining issues after optimization")
                return False
                
        except Exception as e:
            print(f"❌ Post-write validation failed: {e}")
            return False
    
    def _print_summary(self):
        """Print operation summary."""
        print("\n📊 Operation Summary")
        print("=" * 30)
        print(f"✅ Files analyzed: {self.stats['analyzed']}")
        print(f"📝 Files written: {self.stats['written']}")
        print(f"⏭️  Files skipped: {self.stats['skipped']}")
        print(f"❌ Errors: {self.stats['errors']}")
        
        total = self.stats['analyzed'] + self.stats['skipped']
        written_plus_skipped = self.stats['written'] + self.stats['skipped']
        
        if total == written_plus_skipped:
            print("✅ All files accounted for")
        else:
            print("⚠️  File count mismatch")
    
    def _print_usage(self):
        """Print usage information."""
        print("\nUsage:")
        print("  /optimize-prompts [path]     # Optimize specific file")
        print("  /optimize-prompts --all      # Optimize all LLM-facing files")
        print("\nThis command optimizes LLM-facing files for Claude Code compliance.")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Optimize LLM-facing files for Claude Code compliance')
    parser.add_argument('path', nargs='?', help='Specific file or directory to optimize')
    parser.add_argument('--all', action='store_true', help='Optimize all LLM-facing files')
    parser.add_argument('--root', default='.', help='Root directory (default: current directory)')
    
    args = parser.parse_args()
    
    if not args.path and not args.all:
        print("Error: Please specify a path or use --all")
        return 1
    
    optimizer = OptimizePrompts(args.root)
    return optimizer.run(args.path, args.all)


if __name__ == '__main__':
    sys.exit(main())
