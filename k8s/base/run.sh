#!/bin/bash
set -e

#This came from https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export ES_HOST="elasticsearch.cs-perf-test.svc.cluster.local:9200"
export CS_HOST="cloaked-search-v2.cs-perf-test.svc.cluster.local:8675"

while ! curl -kSsf "http://tenant-security-proxy.tsp.svc.cluster.local:9000/health" ; do
  sleep 10
done

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/run-500k.sh"
