#!/bin/bash
set -euo pipefail
exec "${IRONFOX_BASH}" -c 'pwd' || exit 1
