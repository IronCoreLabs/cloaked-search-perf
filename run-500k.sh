#!/bin/bash
set -e
UUID=$(python3 -c 'import uuid; print(uuid.uuid1())')

SECONDS_SINCE_EPOCH=$(date +%s)
CS_IDENT="CS-$SECONDS_SINCE_EPOCH"
ES_IDENT="ES-$SECONDS_SINCE_EPOCH"
TRACK_PATH="/tracks/so500k"
CURRENT_DATE=$(date +%F)
BRANCH_NAME="$CURRENT_DATE-$UUID"
ES_HOST="es:9200"
CS_HOST="cs:8675"

if [ ! -v PAT ]; then
  echo "PAT must be set in the env. It should be a personal access token which is able to clone and pull request to cloaked-search-perf."
  exit 1
fi

if [ ! -v PAT_USER_NAME ]; then
  echo "PAT_USER_NAME must be set in the env."
  exit 1
fi

if [ ! -v PAT_EMAIL ]; then
  echo "PAT_EMAIL must be set in the env."
  exit 1
fi

OUTPUT_DIR="/rally/.rally/cloaked-search-perf/results/${CURRENT_DATE}_$UUID"
cd /rally/.rally

if [ ! -d cloaked-search-perf ]; then
 git clone "https://$PAT@github.com/IronCoreLabs/cloaked-search-perf.git"
fi

# Go into the git repo, make sure it's clean and create a branch
cd cloaked-search-perf
git config pull.rebase true
git config user.email "$PAT_EMAIL"
git config user.name "$PAT_USER_NAME"
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
esrally compare "--baseline=$ES_IDENT" "--contender=$CS_IDENT" --report-format=csv "--report-file=$OUTPUT_DIR/compare-$SECONDS_SINCE_EPOCH.csv"

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

