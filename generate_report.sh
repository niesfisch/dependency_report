#!/usr/bin/env bash

set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"
REPORT_GENERATOR_DIR=${SCRIPT_DIR}/report

. "${SCRIPT_DIR}/config.inc.sh"

echo "[GENERATING REPORT] ..."

source ${HOME}/.dependency_report

pushd ${REPORT_GENERATOR_DIR}
  make venv
  source venv/bin/activate
  python3 report.py ${RESULTS_DIR} ${REPORT_DIR}
popd

echo "[DONE] Please check results in ${RESULTS_DIR}"
