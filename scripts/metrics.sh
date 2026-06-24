#!/bin/bash

# Metrics collection helpers for IronFox builds.
# This file MUST NOT contain anything other than function definitions.
#
# All output is written to ${IRONFOX_METRICS_DIR} (see env_common.sh), which MUST
# live outside the source tree so that metrics collection can never affect patch
# application or build reproducibility.
#
# Collection is gated entirely by IRONFOX_METRICS_ENABLED (see env_common.sh):
# when it is not '1', these helpers are no-ops with zero side effects.

# Record a single metric as one JSON object appended to metrics.jsonl.
# Usage: ironfox_metric_event <name> <value> [unit] [extra_json_fields]
#   <extra_json_fields> is raw JSON inserted verbatim, ex: '"status":1'
function ironfox_metric_event() {
    if [[ "${IRONFOX_METRICS_ENABLED:-0}" != 1 ]]; then
        return 0
    fi

    local readonly name="$1"
    local readonly value="$2"
    local readonly unit="${3:-}"
    local readonly extra="${4:-}"

    mkdir -p "${IRONFOX_METRICS_DIR}"
    printf '{"ts":%s,"variant":"%s","name":"%s","value":%s,"unit":"%s"%s}\n' \
        "$(date +%s)" \
        "${IRONFOX_METRICS_VARIANT:-unknown}" \
        "${name}" \
        "${value}" \
        "${unit}" \
        "${extra:+,${extra}}" \
        >>"${IRONFOX_METRICS_DIR}/metrics.jsonl"
}

# Measure the wall-clock duration of a command and record it as a phase metric.
#
# The command's exit status is preserved and returned, so build failures still
# propagate exactly as they would without instrumentation. The duration is
# recorded even when the command fails, so a red pipeline still tells us which
# phase died and how long it took to get there.
#
# Calls nest: whatever phase is currently being measured becomes the recorded
# parent of any phase measured inside it. The parent context is exported, so it
# also reaches sub-tasks running in child processes spawned by the measured
# command (ex. `ironfox_metric_measure get_sources bash -x get_sources.sh`, whose
# inner steps then attribute to "get_sources" automatically).
#
# Usage: ironfox_metric_measure <phase_name> <command> [args...]
function ironfox_metric_measure() {
    local readonly name="$1"
    shift

    # Kill-switch: run the command directly, with zero overhead or side effects.
    if [[ "${IRONFOX_METRICS_ENABLED:-0}" != 1 ]]; then
        "$@"
        return $?
    fi

    # Remember the current parent, then make this phase the parent for its command.
    local readonly parent="${IRONFOX_METRICS_PARENT:-}"
    export IRONFOX_METRICS_PARENT="${name}"

    local readonly start="$(date +%s)"
    local status=0
    "$@" || status=$?
    local readonly end="$(date +%s)"

    # Restore the previous parent context.
    if [[ -n "${parent}" ]]; then
        export IRONFOX_METRICS_PARENT="${parent}"
    else
        unset IRONFOX_METRICS_PARENT
    fi

    # Never let metrics bookkeeping fail the build.
    ironfox_metric_event "phase_${name}_seconds" "$((end - start))" "seconds" \
        "\"status\":${status},\"parent\":\"${parent}\"" || true

    return "${status}"
}
