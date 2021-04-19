#!/usr/bin/env bash

set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

. "${SCRIPT_DIR}/config.inc.sh"

echo "[CHECKOUT PROJECTS] ..."

if [ "${GITHUB_TOKEN}" == "" ]; then
  echo -e "${CR}no github token provided${CC}"
  exit 1
fi

for PROJECT in ${PROJECTS[@]}; do
  echo -e "${CG}clone [${PROJECT}]"
  git clone https://oauth2:${GITHUB_TOKEN}@github.com/${GITHUB_NAMESPACE}/${PROJECT} ${WORK_DIR}/${PROJECT}
done
