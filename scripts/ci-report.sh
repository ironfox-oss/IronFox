#!/bin/bash

## This script is expected to be executed in a CI environment (typically from a
## job's `after_script`, so that a report is ALWAYS generated - even on failure).
## DO NOT execute this manually!

set -euo pipefail

# Set-up our environment
if [[ -z "${IRONFOX_CI+x}" ]]; then
    export IRONFOX_CI=1
fi
source "$(dirname "$0")/env.sh"

# Include utilities
source "${IRONFOX_UTILS}"

readonly metrics_file="${IRONFOX_METRICS_DIR}/metrics.jsonl"
readonly openmetrics_file="${IRONFOX_METRICS_DIR}/metrics.txt"
readonly report_file="${IRONFOX_METRICS_DIR}/report.txt"

if [[ "${IRONFOX_METRICS_ENABLED}" != 1 ]]; then
    echo "Metrics collection is disabled (IRONFOX_METRICS_ENABLED=${IRONFOX_METRICS_ENABLED}); skipping report."
    exit 0
fi

if [[ ! -s "${metrics_file}" ]]; then
    echo_red_text "No metrics were recorded at ${metrics_file}; nothing to report."
    exit 0
fi

mkdir -p "${IRONFOX_METRICS_DIR}"

# Render the OpenMetrics file consumed by GitLab's `artifacts:reports:metrics`.
# This makes phase durations show up as a diff vs. the target branch in the MR widget.
# The `parent` label carries the hierarchy (empty for top-level phases).
{
    echo "# HELP ironfox_phase_seconds Wall-clock duration of an IronFox build phase, in seconds."
    echo "# TYPE ironfox_phase_seconds gauge"
    jq -rs --arg v "${IRONFOX_METRICS_VARIANT:-unknown}" '
        map(select((.name | test("^phase_.*_seconds$")) and .variant == $v))
        | .[]
        | "ironfox_phase_seconds{phase=\"\(.name | sub("^phase_"; "") | sub("_seconds$"; ""))\",parent=\"\(.parent // "")\",variant=\"\(.variant)\",status=\"\(.status // 0)\"} \(.value)"
    ' "${metrics_file}"
} >"${openmetrics_file}"

# Render the human-readable report.
#
# Top-level phases (parent == "") are listed with their share of the grand total.
# Each phase's measured sub-tasks are listed beneath it (prefixed with "- "),
# with their share of *that phase*, followed by an "(unaccounted)" remainder so
# uninstrumented time inside a phase is always visible.
{
    echo "IronFox build metrics - variant: ${IRONFOX_METRICS_VARIANT:-unknown}"
    echo "Pipeline: ${CI_PIPELINE_ID:-local}  Job: ${CI_JOB_NAME:-local}  Commit: ${CI_COMMIT_SHORT_SHA:-unknown}"
    echo
    jq -rs --arg v "${IRONFOX_METRICS_VARIANT:-unknown}" '
        ( map(select((.name | test("^phase_.*_seconds$")) and .variant == $v)
              | {task: (.name | sub("^phase_"; "") | sub("_seconds$"; "")),
                 value, parent: (.parent // ""), status: (.status // 0)}) ) as $all
        | ($all | map(select(.parent == ""))) as $roots
        | (($roots | map(.value) | add) // 0) as $grand
        | (["PHASE / sub-task", "SECONDS", "SHARE", "STATUS"]),
          ( $roots[]
            | . as $r
            | ($all | map(select(.parent == $r.task))) as $kids
            | (($kids | map(.value) | add) // 0) as $ksum
            | ( [ $r.task, ($r.value | tostring),
                  (if $grand > 0 then (($r.value * 100 / $grand) | floor | tostring) + "%" else "-" end),
                  (if $r.status == 0 then "ok" else "FAIL(" + ($r.status | tostring) + ")" end) ] ),
              ( $kids | sort_by(.value) | reverse | .[]
                | [ "- " + .task, (.value | tostring),
                    (if $r.value > 0 then ((.value * 100 / $r.value) | floor | tostring) + "%" else "-" end),
                    (if .status == 0 then "ok" else "FAIL(" + (.status | tostring) + ")" end) ] ),
              ( if ($kids | length) > 0
                then [ "- (unaccounted)", (($r.value - $ksum) | tostring),
                       (if $r.value > 0 then ((($r.value - $ksum) * 100 / $r.value) | floor | tostring) + "%" else "-" end),
                       "" ]
                else empty end )
          ),
          (["TOTAL", ($grand | tostring), "100%", ""])
        | @tsv
    ' "${metrics_file}" | { column -t -s "$(printf '\t')" 2>/dev/null || cat; }
} >"${report_file}"

# Echo the report into the job log inside a collapsible section.
readonly section="ironfox_metrics_report"
echo -e "\e[0Ksection_start:$(date +%s):${section}[collapsed=true]\r\e[0KIronFox build metrics report"
cat "${report_file}"
echo -e "\e[0Ksection_end:$(date +%s):${section}\r\e[0K"

echo_green_text "Wrote metrics report to ${report_file}"
