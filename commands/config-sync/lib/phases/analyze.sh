phase_analyze() {
  log_info "[analyze] Building capability report for targets (${FORMAT})"

  local matrix=""
  for target in "${SELECTED_TARGETS[@]}"; do
    local config_dir commands_dir rules_dir
    config_dir="$(get_target_config_dir "$target")"
    commands_dir="$(get_target_commands_dir "$target")"
    rules_dir="$(get_target_rules_dir "$target")"
    matrix+="$target|$config_dir|$commands_dir|$rules_dir"$'\n'
  done

  local report_file="$RUN_METADATA_DIR/analyze.json"
  TARGET_MATRIX="$matrix" ANALYZE_FORMAT="$FORMAT" ANALYZE_DETAILED="$DETAILED" python3 - "$report_file" <<'PY'
import json, os, sys
from pathlib import Path

def count_files(path, pattern):
    root = Path(path)
    if not root.exists():
        return 0
    try:
        return sum(1 for _ in root.rglob(pattern))
    except Exception:
        return 0

matrix = [line for line in os.environ.get("TARGET_MATRIX", "").splitlines() if line.strip()]
format_name = os.environ.get("ANALYZE_FORMAT", "markdown")
detailed = os.environ.get("ANALYZE_DETAILED") == "true"
targets = []

for row in matrix:
    parts = row.split("|", 3)
    if len(parts) != 4:
        continue
    name, config_dir, commands_dir, rules_dir = parts
    entry = {
        "name": name,
        "config_dir": config_dir,
        "config_exists": Path(config_dir).exists(),
        "commands_dir": commands_dir,
        "commands_markdown": count_files(commands_dir, "*.md"),
        "rules_dir": rules_dir,
        "rules_markdown": count_files(rules_dir, "*.md"),
    }
    targets.append(entry)

report = {"targets": targets}

with open(sys.argv[1], "w", encoding="utf-8") as fh:
    json.dump(report, fh, indent=2)

if format_name == "json":
    print(json.dumps(report, indent=2))
else:
    header = f"{'Target':10} {'Config?':8} {'Cmd(md)':8} {'Rules(md)':9}"
    divider = "-" * len(header)
    rows = [header, divider]
    for entry in targets:
        rows.append(
            f"{entry['name']:10} "
            f"{'yes' if entry['config_exists'] else 'no':8} "
            f"{entry['commands_markdown']:8} "
            f"{entry['rules_markdown']:9}"
        )
    if format_name == "markdown":
        print("| Target | Config | Cmd (.md) | Rules (.md) |")
        print("| ------ | ------ | --------- | ----------- |")
        for entry in targets:
            print(
                f"| {entry['name']} "
                f"| {'yes' if entry['config_exists'] else 'no'} "
                f"| {entry['commands_markdown']} "
                f"| {entry['rules_markdown']} |"
            )
    else:
        for row in rows:
            print(row)

if detailed and targets:
    print("\nDetailed directories:")
    for entry in targets:
        print(
            f"- {entry['name']}: "
            f"config={entry['config_dir']} "
            f"commands={entry['commands_dir']} "
            f"rules={entry['rules_dir']}"
        )
PY

  log_info "[analyze] Report written to $report_file"
}
