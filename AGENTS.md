
# Memory Configuration

## On-Demand (via Skills)
- Language selection: invoke `language-decision-tree` skill when creating new code
- Tool selection: invoke `tool-decision-tree` skill when performing searches/refactors
- Language-specific guidance: invoke `go-guidelines`, `python-guidelines`, `shell-guidelines`, `powershell-guidelines`, `lua-guidelines` as needed

## Rule-Loading Conditions

### Default Conditions
Match response language to user input language (Chinese input -> Chinese response, English input -> English response), while file content follows existing file conventions and comment styles per rules.
Execute language-specific skills based on file extensions or declared language context.

## Compact Instructions

When compressing, preserve in priority order:

1. Architecture decisions (NEVER summarize)
2. Modified files and their key changes
3. Current verification status (pass/fail)
4. Open TODOs and rollback notes
5. Tool outputs (can delete, keep pass/fail only)

@RTK.md
