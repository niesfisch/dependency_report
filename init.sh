#!/usr/bin/env bash

set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

. "${SCRIPT_DIR}/config.inc.sh"

echo "[INIT] ..."

# create workdir
if [ -d "${WORK_DIR}" ]; then rm -rf ${WORK_DIR}; fi
mkdir -p ${WORK_DIR}
mkdir -p ${RESULTS_DIR}
mkdir -p ${REPORT_DIR}
