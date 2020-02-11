#!/bin/bash -ex

##
# loads a snapshot onto an elasticsearch cluster
##

set -euo pipefail

cluster_url="${cluster_url:-http://localhost:9200}"
base_path=${base_path:-elasticsearch}
es_repo_name="pelias_snapshot"
s3_bucket="${s3_bucket:-}"
snapshot_name="${snapshot_name:-}"
read_only="${read_only:-true}"

# check all required variables are set
if [[ "$s3_bucket" == "" ]]; then
  echo "s3_bucket not set, no snapshot will be loaded"
  exit 1
fi

# check jq is installed
if ! [[ -x "$(command -v jq)" ]]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

# create elasticsearch snapshot repository
curl -XPOST "$cluster_url/_snapshot/$es_repo_name" \
  -H 'Content-Type: application/json' \
  -d "{
 \"type\": \"s3\",
   \"settings\": {
   \"bucket\": \"$s3_bucket\",
   \"read_only\": $read_only,
   \"base_path\" : \"$base_path\",
   \"max_snapshot_bytes_per_sec\" : \"1000mb\",
   \"max_restore_bytes_per_sec\" : \"1000mb\"
 }
}"

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
