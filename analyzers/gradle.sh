#!/usr/bin/env bash

set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

. "${SCRIPT_DIR}/../config.inc.sh"

echo "***** [ANALYZE GRADLE] ... *****"

RESULT_FILE="${RESULTS_DIR}/gradle_versions.csv"
GRADLE_BUILD_FILE="build.gradle"

touch "${RESULT_FILE}"

for PROJECT in ${PROJECTS[@]}; do
  echo -e "Analyzing gradle in [${PROJECT}]"
  PROJECT_ROOT_DIR=${WORK_DIR}/${PROJECT}
  pushd "${PROJECT_ROOT_DIR}" >/dev/null || exit
    if [[ -f "${GRADLE_BUILD_FILE}" ]]; then
      # only direct, not transitive
      gradle dependencies | grep "^+---.*" | grep -v "(n)" | sort | uniq | perl -pe 's/ -> /:/' | perl -pe "s/.* (.*):(.*)/${PROJECT};\1;\2/" >> "${RESULT_FILE}"
    else
      echo "Skipping [GRADLE] for project [${PROJECT}] as [${GRADLE_BUILD_FILE}] is not available"
    fi
  popd >/dev/null || exit
done

# uniq the deps
if [[ -f "${RESULT_FILE}" ]]; then
  tmpfile=$(mktemp /tmp/dependency_check.XXXXXX)
  cat $RESULT_FILE | sort | uniq > $tmpfile
  mv $tmpfile $RESULT_FILE
fi
