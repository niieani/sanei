#!/bin/bash

# load external modules

declare -a __IMPORT__BASE_PATH=(
    "${SCRIPT_DIR}/vendor/bash-modules/main/bash-modules/src/bash-modules"
    "${SCRIPT_DIR}/vendor/bash-modules/modules/bash-modules-tui/src/bash-modules"
)

cd ${SCRIPT_DIR}/vendor/bash-modules/main/bash-modules/src
source ${SCRIPT_DIR}/vendor/bash-modules/main/bash-modules/src/import.sh arguments log mktemp strings
