#!/usr/bin/env python3
"""
Dependency Graph Analyzer for LLM Governance

Analyzes cross-file dependencies and consistency in the Claude Code 
agent/skill/command system according to RFC specifications.
"""

import re
import yaml
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional, Any
from dataclasses import dataclass
from enum import Enum


class NodeType(Enum):
    SKILL = "skill"
    AGENT = "agent"
    COMMAND = "command"
    RULE = "rule"
    MEMORY = "memory"


@dataclass
class Node:
    """Represents a node in the dependency graph."""
    path: Path
    node_type: NodeType
    name: Optional[str] = None
    references: Set[str] = None
    dependencies: Set[str] = None
    
    def __post_init__(self):
        if self.references is None:
            self.references = set()
        if self.dependencies is None:
            self.dependencies = set()


class DependencyIssue:
    """Represents a dependency-related issue."""
    
    def __init__(self, severity: str, issue_type: str, description: str, 
                 source: str, target: Optional[str] = None):
        self.severity = severity  # 'critical', 'warning', 'info'
        self.issue_type = issue_type  # 'missing_ref', 'circular_dep', 'invalid_dep', 'naming_mismatch'
        self.description = description
        self.source = source
        self.target = target
    
    def __str__(self):
        if self.target:
            return f"[{self.severity.upper()}] {self.source} -> {self.target}: {self.description}"
        return f"[{self.severity.upper()}] {self.source}: {self.description}"


class DependencyAnalyzer:
    """Analyzes dependencies in the Claude Code system."""
    
    def __init__(self):
        self.nodes = {}
        self.issues = []
    
    def analyze_directory(self, root_path: Path) -> List[DependencyIssue]:
        """Analyze all dependencies in a directory."""
        self._discover_nodes(root_path)
        self._extract_dependencies()
        self._validate_dependencies()
        
        return self.issues
    
    def _discover_nodes(self, root_path: Path):
        """Discover all nodes in the directory structure."""
        # Discover skills
        for skill_dir in root_path.glob("skills/*/"):
            skill_file = skill_dir / "SKILL.md"
            if skill_file.exists():
                node = Node(skill_file, NodeType.SKILL)
                self.nodes[str(skill_file)] = node
                self._extract_skill_metadata(skill_file, node)
        
        # Discover agents
        for agent_dir in root_path.glob("agents/*/"):
            agent_file = agent_dir / "AGENT.md"
            if agent_file.exists():
                node = Node(agent_file, NodeType.AGENT)
                self.nodes[str(agent_file)] = node
                self._extract_agent_metadata(agent_file, node)
        
        # Discover commands
        for cmd_file in root_path.glob("commands/**/*.md"):
            if cmd_file.name != "README.md":
                node = Node(cmd_file, NodeType.COMMAND)
                self.nodes[str(cmd_file)] = node
                self._extract_command_metadata(cmd_file, node)
        
        # Discover rules
        for rule_file in root_path.glob("rules/**/*.md"):
            node = Node(rule_file, NodeType.RULE)
            self.nodes[str(rule_file)] = node
            self._extract_rule_metadata(rule_file, node)
        
        # Memory files
        for memory_file in ["CLAUDE.md", "AGENTS.md"]:
            memory_path = root_path / memory_file
            if memory_path.exists():
                node = Node(memory_path, NodeType.MEMORY)
                self.nodes[str(memory_path)] = node
                self._extract_memory_metadata(memory_path, node)
    
    def _extract_skill_metadata(self, file_path: Path, node: Node):
        """Extract metadata from a SKILL.md file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract frontmatter
            if content.startswith('---'):
                fm_end = content.find('---', 3)
                if fm_end != -1:
                    frontmatter_text = content[3:fm_end]
                    frontmatter = yaml.safe_load(frontmatter_text)
                    
                    if 'name' in frontmatter:
                        node.name = frontmatter['name']
                    
                    # Extract source references
                    if 'source' in frontmatter:
                        if isinstance(frontmatter['source'], list):
                            node.references.update(frontmatter['source'])
                        else:
                            node.references.add(frontmatter['source'])
            
            # Extract skill references from content
            skill_refs = re.findall(r'skill:([a-zA-Z0-9-]+)', content)
            node.references.update(skill_refs)
            
        except Exception as e:
            self.issues.append(DependencyIssue(
                'warning', 'parse_error', f"Failed to parse skill file: {e}",
                str(file_path)
            ))
    
    def _extract_agent_metadata(self, file_path: Path, node: Node):
        """Extract metadata from an AGENT.md file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract frontmatter
            if content.startswith('---'):
                fm_end = content.find('---', 3)
                if fm_end != -1:
                    frontmatter_text = content[3:fm_end]
                    frontmatter = yaml.safe_load(frontmatter_text)
                    
                    if 'name' in frontmatter:
                        node.name = frontmatter['name']
                    
                    # Extract skill dependencies
                    for skill_field in ['default-skills', 'optional-skills']:
                        if skill_field in frontmatter:
                            skills = frontmatter[skill_field]
                            if isinstance(skills, list):
                                node.dependencies.update(skills)
                            else:
                                node.dependencies.add(skills)
            
            # Extract references from content
            refs = re.findall(r'skill:([a-zA-Z0-9-]+)', content)
            node.references.update(refs)
            
        except Exception as e:
            self.issues.append(DependencyIssue(
                'warning', 'parse_error', f"Failed to parse agent file: {e}",
                str(file_path)
            ))
    
    def _extract_command_metadata(self, file_path: Path, node: Node):
        """Extract metadata from a command file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract frontmatter
            if content.startswith('---'):
                fm_end = content.find('---', 3)
                if fm_end != -1:
                    frontmatter_text = content[3:fm_end]
                    frontmatter = yaml.safe_load(frontmatter_text)
                    
                    if 'name' in frontmatter:
                        node.name = frontmatter['name']
            
            # Extract skill and agent references from content
            refs = re.findall(r'(skill|agent):([a-zA-Z0-9-]+)', content)
            for ref_type, ref_name in refs:
                node.references.add(f"{ref_type}:{ref_name}")
            
        except Exception as e:
            self.issues.append(DependencyIssue(
                'warning', 'parse_error', f"Failed to parse command file: {e}",
                str(file_path)
            ))
    
    def _extract_rule_metadata(self, file_path: Path, node: Node):
        """Extract metadata from a rule file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Use filename as identifier
            node.name = file_path.stem
            
            # Extract skill references from content
            refs = re.findall(r'skill:([a-zA-Z0-9-]+)', content)
            node.references.update(refs)
            
        except Exception as e:
            self.issues.append(DependencyIssue(
                'warning', 'parse_error', f"Failed to parse rule file: {e}",
                str(file_path)
            ))
    
    def _extract_memory_metadata(self, file_path: Path, node: Node):
        """Extract metadata from memory files."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Use filename as identifier
            node.name = file_path.name
            
            # Extract agent and skill references
            refs = re.findall(r'(agent|skill):([a-zA-Z0-9-]+)', content)
            for ref_type, ref_name in refs:
                node.references.add(f"{ref_type}:{ref_name}")
            
        except Exception as e:
            self.issues.append(DependencyIssue(
                'warning', 'parse_error', f"Failed to parse memory file: {e}",
                str(file_path)
            ))
    
    def _extract_dependencies(self):
        """Extract dependencies between nodes."""
        for node_path, node in self.nodes.items():
            for ref in node.references:
                # Find the target node
                target_node = self._find_reference_target(ref)
                if target_node:
                    node.dependencies.add(target_node)
                else:
                    self.issues.append(DependencyIssue(
                        'warning', 'missing_ref', f"Reference not found: {ref}",
                        node_path, ref
                    ))
    
    def _find_reference_target(self, ref: str) -> Optional[str]:
        """Find the target node for a reference."""
        # Handle different reference formats
        if ref.startswith('skill:'):
            skill_name = ref[6:]  # Remove 'skill:' prefix
            for node_path, node in self.nodes.items():
                if node.node_type == NodeType.SKILL and node.name == skill_name:
                    return node_path
        elif ref.startswith('agent:'):
            agent_name = ref[6:]  # Remove 'agent:' prefix
            for node_path, node in self.nodes.items():
                if node.node_type == NodeType.AGENT and node.name == agent_name:
                    return node_path
        elif ref.startswith('rule:'):
            rule_name = ref[5:]  # Remove 'rule:' prefix
            for node_path, node in self.nodes.items():
                if node.node_type == NodeType.RULE and node.name == rule_name:
                    return node_path
        else:
            # Try to match by name across all node types
            for node_path, node in self.nodes.items():
                if node.name == ref:
                    return node_path
        
        return None
    
    def _validate_dependencies(self):
        """Validate the dependency graph."""
        # Check for circular dependencies
        self._check_circular_dependencies()
        
        # Check for invalid dependency directions
        self._check_dependency_directions()
        
        # Check for naming consistency
        self._check_naming_consistency()
        
        # Check for required dependencies
        self._check_required_dependencies()
    
    def _check_circular_dependencies(self):
        """Check for circular dependencies using DFS."""
        visited = set()
        rec_stack = set()
        
        def dfs(node_path: str, path: List[str]) -> bool:
            if node_path in rec_stack:
                # Found a cycle
                cycle_start = path.index(node_path)
                cycle_path = path[cycle_start:] + [node_path]
                self.issues.append(DependencyIssue(
                    'critical', 'circular_dep', 
                    f"Circular dependency: {' -> '.join(cycle_path)}",
                    " -> ".join(cycle_path)
                ))
                return True
            
            if node_path in visited:
                return False
            
            visited.add(node_path)
            rec_stack.add(node_path)
            path.append(node_path)
            
            node = self.nodes.get(node_path)
            if node:
                for dep in node.dependencies:
                    if dfs(dep, path.copy()):
                        return True
            
            rec_stack.remove(node_path)
            return False
        
        for node_path in self.nodes:
            if node_path not in visited:
                dfs(node_path, [])
    
    def _check_dependency_directions(self):
        """Check for invalid dependency directions according to RFC."""
        # RFC hierarchy: rules → skill → agent → command
        # memory → rules
        
        for node_path, node in self.nodes.items():
            for dep_path in node.dependencies:
                dep_node = self.nodes.get(dep_path)
                if not dep_node:
                    continue
                
                # Define valid dependency directions
                valid_directions = {
                    (NodeType.SKILL, NodeType.RULE): True,    # skill can depend on rule
                    (NodeType.AGENT, NodeType.SKILL): True,    # agent can depend on skill
                    (NodeType.AGENT, NodeType.RULE): True,     # agent can depend on rule
                    (NodeType.COMMAND, NodeType.AGENT): True,  # command can depend on agent
                    (NodeType.COMMAND, NodeType.SKILL): True,  # command can depend on skill
                    (NodeType.MEMORY, NodeType.RULE): True,    # memory can depend on rule
                    (NodeType.MEMORY, NodeType.AGENT): True,   # memory can depend on agent
                }
                
                direction = (node.node_type, dep_node.node_type)
                if not valid_directions.get(direction, False):
                    self.issues.append(DependencyIssue(
                        'warning', 'invalid_dep', 
                        f"Invalid dependency direction: {node.node_type.value} -> {dep_node.node_type.value}",
                        node_path, dep_path
                    ))
    
    def _check_naming_consistency(self):
        """Check for naming consistency across references."""
        # Build a mapping of names to paths
        name_to_paths = {}
        for node_path, node in self.nodes.items():
            if node.name:
                if node.name not in name_to_paths:
                    name_to_paths[node.name] = []
                name_to_paths[node.name].append(node_path)
        
        # Check for duplicate names
        for name, paths in name_to_paths.items():
            if len(paths) > 1:
                self.issues.append(DependencyIssue(
                    'warning', 'naming_mismatch',
                    f"Duplicate name '{name}' used by multiple files",
                    ", ".join(paths)
                ))
    
    def _check_required_dependencies(self):
        """Check for required dependencies according to RFC."""
        # Check that agents have required skills
        for node_path, node in self.nodes.items():
            if node.node_type == NodeType.AGENT:
                if not node.dependencies:
                    self.issues.append(DependencyIssue(
                        'info', 'missing_deps',
                        "Agent has no skill dependencies",
                        node_path
                    ))
            
            # Check that commands have agent or skill dependencies
            elif node.node_type == NodeType.COMMAND:
                has_agent_or_skill = any(
                    self.nodes.get(dep, Node("", None)).node_type in [NodeType.AGENT, NodeType.SKILL]
                    for dep in node.dependencies
                )
                if not has_agent_or_skill:
                    self.issues.append(DependencyIssue(
                        'info', 'missing_deps',
                        "Command has no agent or skill dependencies",
                        node_path
                    ))
    
    def print_dependency_graph(self):
        """Print the dependency graph in a readable format."""
        print("Dependency Graph:")
        print("=" * 80)
        
        for node_path, node in self.nodes.items():
            print(f"\n📁 {node.node_type.value.upper()}: {Path(node_path).name}")
            if node.name:
                print(f"   Name: {node.name}")
            if node.dependencies:
                print("   Dependencies:")
                for dep in node.dependencies:
                    dep_name = Path(dep).name
                    print(f"     -> {dep_name}")
            else:
                print("   Dependencies: None")
    
    def print_summary(self):
        """Print a summary of all issues."""
        if not self.issues:
            print("✓ No dependency issues found!")
            return
        
        print(f"\n📊 Dependency Analysis Summary:")
        print(f"  Total issues: {len(self.issues)}")
        
        by_severity = {'critical': 0, 'warning': 0, 'info': 0}
        by_type = {}
        
        for issue in self.issues:
            by_severity[issue.severity] += 1
            by_type[issue.issue_type] = by_type.get(issue.issue_type, 0) + 1
        
        print(f"  By severity:")
        for severity, count in by_severity.items():
            if count > 0:
                print(f"    {severity}: {count}")
        
        print(f"  By type:")
        for issue_type, count in by_type.items():
            if count > 0:
                print(f"    {issue_type}: {count}")
        
        print(f"\n🔍 Detailed Issues:")
        for issue in sorted(self.issues, key=lambda x: (x.severity, x.source)):
            print(f"  {issue}")


def main():
    """Main function for standalone usage."""
    import sys
    
    if len(sys.argv) != 2:
        print("Usage: python3 dependency_analyzer.py <directory>")
        sys.exit(1)
    
    directory = Path(sys.argv[1])
    if not directory.exists():
        print(f"Error: Directory {directory} does not exist")
        sys.exit(1)
    
    analyzer = DependencyAnalyzer()
    issues = analyzer.analyze_directory(directory)
    
    analyzer.print_dependency_graph()
    analyzer.print_summary()
    
    # Exit with error code if critical issues found
    critical_count = sum(1 for issue in issues if issue.severity == 'critical')
    if critical_count > 0:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == '__main__':
    main()
