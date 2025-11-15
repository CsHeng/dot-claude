#!/usr/bin/env python3
"""
Comprehensive System Test for Optimize-Prompts

This script tests the entire optimized system including:
1. Tool availability and fallback mechanisms
2. Claude Code specification compliance
3. Dependency graph consistency
4. Cross-file validation
"""

import sys
import subprocess
import json
from pathlib import Path
from typing import Dict, List, Tuple


class SystemTestResult:
    """Container for test results."""
    
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.warnings = 0
        self.results = []
    
    def add_result(self, test_name: str, passed: bool, message: str, severity: str = "info"):
        self.results.append({
            'test': test_name,
            'passed': passed,
            'message': message,
            'severity': severity
        })
        
        if passed:
            self.passed += 1
        elif severity == "critical":
            self.failed += 1
        else:
            self.warnings += 1
    
    def print_summary(self):
        print(f"\n🧪 System Test Summary")
        print("=" * 50)
        print(f"✅ Passed: {self.passed}")
        print(f"⚠️  Warnings: {self.warnings}")
        print(f"❌ Failed: {self.failed}")
        print(f"📊 Total: {len(self.results)}")
        
        if self.failed > 0:
            print(f"\n❌ CRITICAL ISSUES FOUND")
            for result in self.results:
                if not result['passed'] and result['severity'] == 'critical':
                    print(f"  - {result['test']}: {result['message']}")
        
        if self.warnings > 0:
            print(f"\n⚠️  Warnings")
            for result in self.results:
                if not result['passed'] and result['severity'] == 'warning':
                    print(f"  - {result['test']}: {result['message']}")
        
        return self.failed == 0


def run_tool_checker() -> Tuple[bool, str]:
    """Test tool availability and fallback mechanisms."""
    try:
        result = subprocess.run(
            ['python3', 'tool_checker.py'],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        success = result.returncode == 0
        message = "Tools available with fallbacks" if success else f"Tool issues: {result.stderr}"
        return success, message
        
    except Exception as e:
        return False, f"Failed to run tool checker: {e}"


def run_claude_validator(directory: str) -> Tuple[bool, str, int]:
    """Test Claude Code specification compliance."""
    try:
        result = subprocess.run(
            ['python3', 'claude_code_validator.py', directory],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        # Count issues from output
        critical_count = result.stdout.count('[CRITICAL]')
        warning_count = result.stdout.count('[WARNING]')
        
        # Consider it passed if no critical issues
        success = critical_count == 0
        severity = "critical" if critical_count > 0 else "warning" if warning_count > 0 else "info"
        message = f"Found {critical_count} critical, {warning_count} warning issues"
        
        return success, message, critical_count + warning_count
        
    except Exception as e:
        return False, f"Failed to run validator: {e}", 1


def run_dependency_analyzer(directory: str) -> Tuple[bool, str, int]:
    """Test dependency graph analysis."""
    try:
        result = subprocess.run(
            ['python3', 'dependency_analyzer.py', directory],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        # Count issues from output
        warning_count = result.stdout.count('[WARNING]')
        info_count = result.stdout.count('[INFO]')
        
        # Consider it passed if no warnings (warnings indicate dependency issues)
        success = warning_count == 0
        severity = "warning" if warning_count > 0 else "info"
        message = f"Found {warning_count} dependency warnings, {info_count} info messages"
        
        return success, message, warning_count
        
    except Exception as e:
        return False, f"Failed to run dependency analyzer: {e}", 1


def test_file_structure(directory: str) -> Tuple[bool, str]:
    """Test that required directories and files exist."""
    required_dirs = [
        "skills",
        "agents", 
        "commands",
        "rules"
    ]
    
    required_files = [
        "CLAUDE.md",
        "AGENTS.md"
    ]
    
    missing = []
    base_path = Path(directory)
    
    for dir_name in required_dirs:
        dir_path = base_path / dir_name
        if not dir_path.exists():
            missing.append(f"Directory {dir_name}")
    
    for file_name in required_files:
        file_path = base_path / file_name
        if not file_path.exists():
            missing.append(f"File {file_name}")
    
    success = len(missing) == 0
    message = "All required structure present" if success else f"Missing: {', '.join(missing)}"
    
    return success, message


def test_classification_rules() -> Tuple[bool, str]:
    """Test that classification rules file exists and is valid."""
    rules_file = Path("classification-rules.yaml")
    
    if not rules_file.exists():
        return False, "classification-rules.yaml not found"
    
    try:
        import yaml
        with open(rules_file, 'r') as f:
            rules = yaml.safe_load(f)
        
        # Check required sections
        required_sections = ['skills', 'commands', 'agents', 'rules']
        missing_sections = [s for s in required_sections if s not in rules]
        
        success = len(missing_sections) == 0
        message = "Classification rules valid" if success else f"Missing sections: {', '.join(missing_sections)}"
        
        return success, message
        
    except Exception as e:
        return False, f"Failed to parse classification rules: {e}"


def test_file_consistency(directory: str) -> Tuple[bool, str]:
    """Test basic file consistency checks."""
    base_path = Path(directory)
    issues = []
    
    # Check for SKILL.md files in skill directories
    for skill_dir in base_path.glob("skills/*/"):
        skill_file = skill_dir / "SKILL.md"
        if not skill_file.exists():
            issues.append(f"Missing SKILL.md in {skill_dir.name}")
    
    # Check for AGENT.md files in agent directories  
    for agent_dir in base_path.glob("agents/*/"):
        agent_file = agent_dir / "AGENT.md"
        if not agent_file.exists():
            issues.append(f"Missing AGENT.md in {agent_dir.name}")
    
    success = len(issues) == 0
    message = "File structure consistent" if success else f"Issues: {', '.join(issues[:5])}"  # Limit output
    
    return success, message


def main():
    """Run comprehensive system tests."""
    if len(sys.argv) != 2:
        print("Usage: python3 system_test.py <claude_directory>")
        sys.exit(1)
    
    directory = sys.argv[1]
    result = SystemTestResult()
    
    print("🚀 Starting Comprehensive System Test")
    print(f"📁 Testing directory: {directory}")
    print("=" * 50)
    
    # Test 1: File Structure
    print("📋 Testing file structure...")
    success, message = test_file_structure(directory)
    result.add_result("File Structure", success, message, "critical" if not success else "info")
    
    # Test 2: Tool Availability
    print("🔧 Testing tool availability...")
    success, message = run_tool_checker()
    result.add_result("Tool Availability", success, message, "critical" if not success else "info")
    
    # Test 3: Classification Rules
    print("📏 Testing classification rules...")
    success, message = test_classification_rules()
    result.add_result("Classification Rules", success, message, "critical" if not success else "info")
    
    # Test 4: File Consistency
    print("🔍 Testing file consistency...")
    success, message = test_file_consistency(directory)
    result.add_result("File Consistency", success, message, "warning" if not success else "info")
    
    # Test 5: Claude Code Specification Compliance
    print("📜 Testing Claude Code specification compliance...")
    success, message, issue_count = run_claude_validator(directory)
    severity = "critical" if not success else ("warning" if issue_count > 0 else "info")
    result.add_result("Claude Code Compliance", success, message, severity)
    
    # Test 6: Dependency Analysis
    print("🕸️  Testing dependency analysis...")
    success, message, warning_count = run_dependency_analyzer(directory)
    severity = "warning" if warning_count > 0 else "info"
    result.add_result("Dependency Analysis", success, message, severity)
    
    # Print detailed results
    print(f"\n📝 Detailed Test Results:")
    for test_result in result.results:
        status = "✅" if test_result['passed'] else ("⚠️" if test_result['severity'] == 'warning' else "❌")
        print(f"  {status} {test_result['test']}: {test_result['message']}")
    
    # Print summary and exit
    success = result.print_summary()
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
