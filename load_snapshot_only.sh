#!/bin/bash

##
# loads a snapshot onto an elasticsearch cluster
# unlike `load_snapshot.sh`, this does not create the repository
##

set -euo pipefail

cluster_url="${cluster_url:-http://localhost:9200}"
es_repo_name="${es_repo_name:-}" # the name of the snapshot repository
snapshot_name="${snapshot_name:-}" # the snapshot name (first snapshot is used if empty)

if [[ "$es_repo_name" == "" ]]; then
  echo "es_repo_name is not set, no snapshot will be loaded"
  exit 1
fi

# check jq is installed
if ! [[ -x "$(command -v jq)" ]]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

## autodetect snapshot name if not specified
if [[ "$snapshot_name" == "" ]]; then
	snapshot_name=$(curl -s -XGET --fail "$cluster_url/_snapshot/$es_repo_name/_all" | jq -r .snapshots[0].snapshot)
	echo "autodetected snapshot name is $snapshot_name"
fi

## import new snapshot
## The resulting index name will include the full snapshot
curl -XPOST "$cluster_url/_snapshot/$es_repo_name/$snapshot_name/_restore" \
  -H 'Content-Type: application/json' \
  -d "{
  \"indices\": \"pelias\",
  \"rename_pattern\": \"pelias\",
  \"rename_replacement\": \"$snapshot_name\"
}"

echo "loading snapshot into index $snapshot_name"
