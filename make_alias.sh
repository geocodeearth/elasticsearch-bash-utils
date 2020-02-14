#!/bin/bash
set -euo pipefail

cluster_url="${cluster_url:-http://localhost:9200}"
index_name="${index_name:-}"
alias_name="${alias_name:-pelias}"

if [[ "$index_name" == "" ]]; then
  echo "$index_name not set, no alias created"
  exit 1
fi

echo "setting ${alias_name} alias to $index_name on $cluster_url"

curl -XPOST "$cluster_url/_aliases" \
  -H 'Content-Type: application/json' \
  -d "{
  \"actions\": [{
    \"add\": {
	  \"index\": \"$index_name\",
	  \"alias\": \"$alias_name\"
	}
  }]
}"
