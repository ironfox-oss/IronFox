#!/bin/bash

# IronFox environment variables

set -euo pipefail

if [[ ! -f "$(dirname $0)/env_local.sh" ]]; then
    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    ENV_LOCAL="${ROOT}/scripts/env_local.sh"

    # Write env_local.sh
    echo "Writing ${ENV_LOCAL}..."
    cat > "${ENV_LOCAL}" << EOF
export IRONFOX_ROOT="${ROOT}"

source "\${IRONFOX_ROOT}/scripts/env_common.sh"
EOF
fi

source "$(dirname $0)/env_local.sh"
source "$(dirname $0)/utilities.sh"
