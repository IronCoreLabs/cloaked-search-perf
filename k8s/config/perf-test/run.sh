#!/bin/bash
set -e
set -x

#This came from https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export ES_HOST="elasticsearch.cs-perf-test.svc.cluster.local:9200"
export CS_HOST="cloaked-search-v2.cs-perf-test.svc.cluster.local:8675"

while ! curl -kSsf "${CS_HOST}/_cloaked_search/health" ; do
  sleep 10
done

# shellcheck source=/dev/null
source /vault/secrets/env

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/run-500k.sh"
