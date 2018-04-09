#!/bin/bash
set -euo pipefail

index_name="${index_name:-pelias-2017.11.18-001123}"

echo "setting pelias alias to $index_name on $cluster_url"

curl -XPOST "$cluster_url/_aliases" -d "{
  \"actions\": [{
    \"add\": {
	  \"index\": \"$index_name\",
	  \"alias\": \"pelias\"
	}
  }]
}"
