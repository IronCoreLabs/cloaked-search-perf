#!/bin/bash
set -e
UUID=$(python3 -c 'import uuid; print(uuid.uuid1())')

SECONDS_SINCE_EPOCH=$(date +%s)
CS_IDENT="CS-$SECONDS_SINCE_EPOCH"
ES_IDENT="ES-$SECONDS_SINCE_EPOCH"
TRACK_PATH="tracks/so500k"
CURRENT_DATE=$(date +%F)
BRANCH_NAME="$CURRENT_DATE-$UUID"

[[ -z "${CS_HOST}" ]] && CS_HOST='cs:8675' && echo "Defaulting CS host"
[[ -z "${ES_HOST}" ]] && ES_HOST='es:9200' && echo "Defaulting ES host"

#Check to see if we have all the env variables we need
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

if [ ! -d /rally/.rally ]; then
 echo "/rally/.rally doesn't exist. This should be run inside the elastic rally container."
fi

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
git clean -f
git pull origin main

OUTPUT_DIR="/rally/.rally/cloaked-search-perf/results/${CURRENT_DATE}/$UUID"
git checkout -b "$BRANCH_NAME"

# Make the output and get the version info into it
mkdir -p "$OUTPUT_DIR"
curl "$CS_HOST" > "$OUTPUT_DIR/es_version.json"
curl "$CS_HOST/_cloaked_search/version" > "$OUTPUT_DIR/cs_version.json"

# Run test-mode to ensure that the tsp is warmed up
esrally race "--track-path=$TRACK_PATH" --test-mode --pipeline=benchmark-only "--target-hosts=$CS_HOST" --user-tags=cluster:cs "--race-id=$CS_IDENT" --report-format=csv --report-file="${OUTPUT_DIR}/${CS_IDENT}-warmup.csv"

# Run the 2 races and output them to the $OUTPUT_DIR in CSV format
esrally race "--track-path=$TRACK_PATH" --pipeline=benchmark-only "--target-hosts=$ES_HOST" --user-tags=cluster:es "--race-id=$ES_IDENT"  --report-format=csv --report-file="${OUTPUT_DIR}/${ES_IDENT}.csv"

esrally race "--track-path=$TRACK_PATH" --pipeline=benchmark-only "--target-hosts=$CS_HOST" --user-tags=cluster:cs "--race-id=$CS_IDENT" --report-format=csv --report-file="${OUTPUT_DIR}/${CS_IDENT}.csv"

# Run the compare utility
esrally compare "--baseline=$ES_IDENT" "--contender=$CS_IDENT" --report-format=csv "--report-file=$OUTPUT_DIR/compare-$SECONDS_SINCE_EPOCH.csv"

git add "$OUTPUT_DIR"
git commit -m "Perf test run $UUID."
git push origin "$BRANCH_NAME"

curl \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $PAT"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/IronCoreLabs/cloaked-search-perf/pulls \
  -d "{\"title\":\"$CURRENT_DATE - Performance test results\",\"body\":\"These are the results from run $UUID\",\"head\":\"$BRANCH_NAME\",\"base\":\"main\"}"
