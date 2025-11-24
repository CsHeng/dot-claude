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
    python3 -m config_sync.report_phase "$report_file"

  log_info "[report] Summary written to $report_file"
}
