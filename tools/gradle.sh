#!/bin/bash
set -euo pipefail
exec "${IRONFOX_PYTHON}" "${IRONFOX_GRADLE_PY}" "$@" || exit 1
