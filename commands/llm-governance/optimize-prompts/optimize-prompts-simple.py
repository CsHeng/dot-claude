#!/usr/bin/env python3
"""
Simplified Optimize-Prompts Command Implementation

This is a simplified version that doesn't require external dependencies.
"""

import sys
import argparse
import json
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime


class SimpleOptimizePrompts:
    """Simplified optimize-prompts command implementation."""
    
    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir).resolve()
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
        print("🚀 Starting Simplified Optimize-Prompts")
        print(f"📁 Root directory: {self.root_dir}")
        
        try:
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
            
            # Phase 4: Review with user
            if not self._review_with_user():
                print("ℹ️  No changes approved")
                return 0
            
            # Phase 5: Apply changes
            if not self._apply_changes():
                print("❌ Failed to apply changes")
                return 1
            
            self._print_summary()
            return 0
            
        except KeyboardInterrupt:
            print("\n⚠️  Operation cancelled by user")
            return 130
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            return 1
    
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
        """Discover all LLM-facing files."""
        patterns = [
            "commands/**/*.md",
            "skills/**/SKILL.md", 
            "agents/**/AGENT.md",
            "rules/**/*.md",
            "AGENTS.md",
            "CLAUDE.md"
        ]
        
        exclude_patterns = [
            "**/README.md",
            "**/README*",
            "docs/**",
            "src/**",
            "examples/**",
            "tests/**",
            "ide/**",
            "backup/**"
        ]
        
        targets = []
        
        # Use Python pathlib for broad compatibility
        for pattern in patterns:
            for path in self.root_dir.glob(pattern):
                if path.is_file():
                    # Check if should exclude
                    should_exclude = False
                    for exclude in exclude_patterns:
                        if path.match(exclude):
                            should_exclude = True
                            break
                    
                    if not should_exclude:
                        targets.append(path)
        
        return targets
    
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
                
                # Simple analysis - check for common issues
                issues = self._analyze_content(content)
                if issues:
                    print(f"⚠️  {target.name}: {len(issues)} potential issues")
                    for issue in issues[:3]:  # Show first 3
                        print(f"     - {issue}")
                else:
                    print(f"✅ {target.name}: Looks good")
                
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
    
    def _analyze_content(self, content: str) -> List[str]:
        """Simple content analysis for common issues."""
        issues = []
        
        # Check for emojis using Unicode ranges
        import re
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"  # emoticons
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map symbols
            "\U0001F1E0-\U0001F1FF"  # flags (iOS)
            "\U00002702-\U000027B0"
            "\U000024C2-\U0001F251"
            "]+", flags=re.UNICODE
        )
        
        emoji_matches = emoji_pattern.findall(content)
        if emoji_matches:
            issues.append(f"Contains {len(emoji_matches)} emoji characters")
        
        # Check for bold markers in body (excluding frontmatter)
        if content.startswith('---'):
            fm_end = content.find('---', 3)
            if fm_end != -1:
                body = content[fm_end + 3:]
                if '**' in body:
                    bold_count = body.count('**') // 2
                    issues.append(f"Contains {bold_count} bold markers in body")
        
        # Check for narrative indicators
        narrative_words = ['usually', 'typically', 'generally', 'often', 'sometimes']
        for word in narrative_words:
            if word in content.lower():
                issues.append(f"Contains narrative word: '{word}'")
                break
        
        # Check for missing frontmatter in skill files
        if 'SKILL.md' in content or 'AGENT.md' in content:
            if not content.startswith('---'):
                issues.append("Missing frontmatter")
        
        return issues
    
    def _generate_candidates(self) -> bool:
        """Generate optimized candidates for all files."""
        print("\n🔨 Generating optimized candidates...")
        
        for file_path, content in self.original_files.items():
            # Simple optimization - fix common issues
            candidate = self._fix_common_issues(content)
            self.candidates[file_path] = candidate
        
        print(f"✅ Generated {len(self.candidates)} candidates")
        return True
    
    def _fix_common_issues(self, content: str) -> str:
        """Fix common issues in content."""
        fixed = content
        
        # Remove emojis using Unicode ranges
        import re
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"  # emoticons
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map symbols
            "\U0001F1E0-\U0001F1FF"  # flags (iOS)
            "\U00002702-\U000027B0"
            "\U000024C2-\U0001F251"
            "]+", flags=re.UNICODE
        )
        fixed = emoji_pattern.sub('', fixed)
        
        # Remove bold markers from body (keep frontmatter)
        if fixed.startswith('---'):
            fm_end = fixed.find('---', 3)
            if fm_end != -1:
                frontmatter = fixed[:fm_end + 3]
                body = fixed[fm_end + 3:]
                # Replace **text** with text
                body = re.sub(r'\*\*([^*]+)\*\*', r'\1', body)
                fixed = frontmatter + body
        
        return fixed
    
    def _review_with_user(self) -> bool:
        """Review candidates with user and request confirmation."""
        print("\n👀 Review and Confirmation")
        print("=" * 50)
        
        print(f"📊 Summary:")
        print(f"  Files analyzed: {self.stats['analyzed']}")
        print(f"  Files with changes: {len([v for k, v in self.candidates.items() if v != self.original_files.get(k)])}")
        print(f"  Files skipped: {self.stats['skipped']}")
        print(f"  Errors: {self.stats['errors']}")
        
        # Show changes
        changes_count = 0
        for file_path, candidate in self.candidates.items():
            original = self.original_files.get(file_path)
            if original and candidate != original:
                changes_count += 1
                if changes_count <= 3:
                    path = Path(file_path)
                    print(f"\n📝 {path.name}:")
                    print(f"   Status: Will be optimized")
        
        if changes_count > 3:
            print(f"\n   ... and {changes_count - 3} more files")
        
        if changes_count == 0:
            print("\n✅ No changes needed")
            return False
        
        print(f"\n❓ Do you want to apply these changes? (y/N)")
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
    
    def _print_summary(self):
        """Print operation summary."""
        print("\n📊 Operation Summary")
        print("=" * 30)
        print(f"✅ Files analyzed: {self.stats['analyzed']}")
        print(f"📝 Files written: {self.stats['written']}")
        print(f"⏭️  Files skipped: {self.stats['skipped']}")
        print(f"❌ Errors: {self.stats['errors']}")
    
    def _print_usage(self):
        """Print usage information."""
        print("\nUsage:")
        print("  python3 optimize-prompts.py [path]     # Optimize specific file")
        print("  python3 optimize-prompts.py --all      # Optimize all LLM-facing files")
        print("\nThis command optimizes LLM-facing files for Claude Code compliance.")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Optimize LLM-facing files for Claude Code compliance')
    parser.add_argument('path', nargs='?', help='Specific file or directory to optimize')
    parser.add_argument('--all', action='store_true', help='Optimize all LLM-facing files')
    parser.add_argument('--root', default='.', help='Root directory (default: current directory)')
    
    args = parser.parse_args()
    
    if not args.path and not args.all:
        parser.print_help()
        return 1
    
    optimizer = SimpleOptimizePrompts(args.root)
    return optimizer.run(args.path, args.all)


if __name__ == '__main__':
    sys.exit(main())
