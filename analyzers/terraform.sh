#!/usr/bin/env bash

set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

. "${SCRIPT_DIR}/../config.inc.sh"

echo "***** [ANALYZE TERRAFORM] ... *****"

RESULT_FILE="${RESULTS_DIR}/terraform_versions.csv"

# check and prepend latest tf release version
TF_LATEST_RELEASE_VERSION=`curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r ".current_version"`
# echo "LATEST;${TF_LATEST_RELEASE_VERSION}" >> "${RESULT_FILE}"

for PROJECT in ${PROJECTS[@]}; do
  echo -e "Analyzing terraform in [${PROJECT}]"
  PROJECT_ROOT_DIR=${WORK_DIR}/${PROJECT}

  pushd "${PROJECT_ROOT_DIR}" >/dev/null || exit
    # search for directories containing terraform hcl blocks
    for dir in $(find . -name "*.tf" | xargs grep -l "terraform" | grep -v "\.terraform" | xargs -r dirname | sort | uniq | grep "./terraform")
    do
      pushd $dir
        echo "analyzing $dir"
        # resolve tf version
        # Terraform v0.14.6
        # becomes
        # $PROJECT;terraform;0.14.6
        tmpfile=$(mktemp /tmp/dependency_check.XXXXXX)
        terraform -v > $tmpfile
        version=$(cat $tmpfile | grep "^Terraform" | perl -pe "s/Terraform v(.*)/$PROJECT;terraform;\1/")
        echo $version >> "${RESULT_FILE}"

        # resolve provider versions
        # + provider registry.terraform.io/hashicorp/archive v2.1.0
        # becomes
        # $PROJECT;registry.terraform.io/hashicorp/archive;2.1.0
        for line in $(cat $tmpfile | grep "+" | perl -pe "s/.*provider (.*).* v(.*)/$PROJECT;\1;\2/")
        do
          echo $line >> "${RESULT_FILE}"
        done
      popd >/dev/null || exit
    done
  popd >/dev/null || exit
done

# uniq the deps
if [[ -f "${RESULT_FILE}" ]]; then
  tmpfile=$(mktemp /tmp/dependency_check.XXXXXX)
  cat $RESULT_FILE | sort | uniq > $tmpfile
  mv $tmpfile $RESULT_FILE
else
  echo "Skipping [TERRAFORM] for project [${PROJECT}] as no terraform files found"
fi
