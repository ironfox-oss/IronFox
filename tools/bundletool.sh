#!/bin/bash
set -euo pipefail
exec "${IRONFOX_JAVA}" -jar "${IRONFOX_BUNDLETOOL_JAR}" "$@" || exit 1
