#!/bin/bash
set -euo pipefail
exec "${IRONFOX_BASH}" -c "echo $@" || exit 1
