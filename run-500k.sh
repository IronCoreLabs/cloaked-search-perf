#!/bin/bash
set -x
set -e
UUID=$(python3 -c 'import uuid; print(uuid.uuid1())')

CS_IDENT="$UUID-CS"
ES_IDENT="$UUID-ES"
TRACK_PATH="/tracks/so500k"
# PAT="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"
CURRENT_DATE=$(date +%F)
BRANCH_NAME="$CURRENT_DATE-$UUID"
ES_HOST="es:9200"
CS_HOST="cs:8675"
echo $PAT
if [ ! -v PAT ]; then
  echo "PAT must be set to a personal access token which is able to clone and pull request to cloaked-search-perf"
  exit 1
fi

OUTPUT_DIR="/rally/.rally/cloaked-search-perf/results/$UUID-results"
cd /rally/.rally

if [ ! -d cloaked-search-perf ]; then
 git clone "https://$PAT@github.com/IronCoreLabs/cloaked-search-perf.git"
fi

# Go into the git repo, make sure it's clean and create a branch
cd cloaked-search-perf
git config pull.rebase true
git config user.email "colt.frederickson@ironcorelabs.com"
git config user.name "Colt Frederickson"
git checkout main
git reset --hard
git pull origin main
git checkout -b "$BRANCH_NAME"

# Make the output and get the version info into it
mkdir -p "$OUTPUT_DIR"
curl "$CS_HOST" > "$OUTPUT_DIR/version.json"

# Run the 2 races and output them to the $OUTPUT_DIR in CSV format
esrally race "--track-path=$TRACK_PATH" --pipeline=benchmark-only "--target-hosts=$ES_HOST" --user-tags=cluster:es "--race-id=$ES_IDENT"  --report-format=csv --report-file="${OUTPUT_DIR}/${ES_IDENT}.csv"

esrally race "--track-path=$TRACK_PATH" --pipeline=benchmark-only "--target-hosts=$CS_HOST" --user-tags=cluster:cs "--race-id=$CS_IDENT" --report-format=csv --report-file="${OUTPUT_DIR}/${CS_IDENT}.csv"

# Run the compare utility
esrally compare "--baseline=$ES_IDENT" "--contender=$CS_IDENT" --report-format=csv "--report-file=$OUTPUT_DIR/compare.csv"

git add .
git commit -m "Perf test run $UUID."
git push origin "$BRANCH_NAME"

curl \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $PAT"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/IronCoreLabs/cloaked-search-perf/pulls \
  -d "{\"title\":\"$CURRENT_DATE - Performance test results\",\"body\":\"These are the results from run $UUID\",\"head\":\"$BRANCH_NAME\",\"base\":\"main\"}"

