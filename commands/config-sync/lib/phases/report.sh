phase_report() {
  local summary_lines=""
  for phase in "${ACTIVE_PHASES[@]}"; do
    local status="${PHASE_STATUS[$phase]:-pending}"
    local message="${PHASE_MESSAGE[$phase]:-not-run}"
    if [[ "$phase" == "report" ]]; then
      status="success"
      message="completed"
    fi
    summary_lines+="$phase|$status|$message"$'\n'
  done

  local report_file="$RUN_METADATA_DIR/report.json"
  REPORT_LINES="$summary_lines" REPORT_PLAN="$PLAN_FILE" REPORT_RUN="$RUN_ROOT" \
  python3 - "$report_file" <<'PY'
import json, os, sys

lines = [line for line in os.environ.get("REPORT_LINES", "").splitlines() if line.strip()]
phases = []
status_counts = {"success": 0, "failed": 0, "skipped": 0, "pending": 0}

for row in lines:
    parts = row.split("|", 2)
    if len(parts) != 3:
        continue
    name, status, message = parts
    phases.append({"phase": name, "status": status, "message": message})
    status_counts.setdefault(status, 0)
    status_counts[status] += 1

final_status = "success"
if status_counts.get("failed"):
    final_status = "failed"
elif status_counts.get("skipped"):
    final_status = "partial"

report = {
    "status": final_status,
    "plan_file": os.environ.get("REPORT_PLAN"),
    "run_dir": os.environ.get("REPORT_RUN"),
    "phases": phases,
}

with open(sys.argv[1], "w", encoding="utf-8") as fh:
    json.dump(report, fh, indent=2)

print("=== Pipeline Report ===")
print(f"Status : {final_status}")
print(f"Plan   : {report['plan_file']}")
print(f"Run dir: {report['run_dir']}")
print("-----------------------")
for entry in phases:
    print(f"{entry['phase']:>8}: {entry['status']:<7} {entry['message']}")
PY

  log_info "[report] Summary written to $report_file"
}
