#!/usr/bin/env bash

set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

. "${SCRIPT_DIR}/../config.inc.sh"

echo "***** [ANALYZE MAVEN] ... *****"

RESULT_FILE="${RESULTS_DIR}/maven_versions.csv"
MAVEN_BUILD_FILE="pom.xml"

for PROJECT in ${PROJECTS[@]}; do
  echo -e "Analyzing maven in [${PROJECT}]"
  PROJECT_ROOT_DIR=${WORK_DIR}/${PROJECT}
  pushd "${PROJECT_ROOT_DIR}" >/dev/null || exit
    if [[ -f "${MAVEN_BUILD_FILE}" ]]; then

      # only direct, not transitive
      if [ "$ANALYZERS_INCLUDE_TRANSITIVE_DEPS" = false ] ; then
        echo "[Maven] ignoring transitive dependencies"
        for dep in $(mvn dependency:tree | grep "] +- " | awk '{print $3}' | awk -F":" '{print $1":"$2";"$4}')
        do
           echo "${PROJECT};${dep}" >> "${RESULT_FILE}"
        done
      else
        # incl. transitive
        echo "[Maven] including transitive dependencies"
        for dep in $(mvn dependency:tree | egrep ".*\-.*:jar|pom:" | perl -pe 's/.*\- (.*?):(.*?):(.*?):(.*):(.*)/\1:\2;\4/' | grep -v INFO)
        do
           echo "${PROJECT};${dep}" >> "${RESULT_FILE}"
        done

      fi


    else
      echo "Skipping [MAVEN] for project [${PROJECT}] as [${MAVEN_BUILD_FILE}] is not available"
    fi
  popd >/dev/null || exit
done

# uniq the deps
if [[ -f "${RESULT_FILE}" ]]; then
  tmpfile=$(mktemp /tmp/dependency_check.XXXXXX)
  cat $RESULT_FILE | sort | uniq > $tmpfile
  mv $tmpfile $RESULT_FILE
fi
