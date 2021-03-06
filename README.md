# Elasticsearch bash utils

This is a collection of useful scripts for working with Elasticsearch on the command line. They
aren't the prettiest tools out there, but they provide information-dense and accurate information
crucial to managing real live production Elasticsearch instances.

These scripts were originally made for use with the [Pelias Geocoder](https://pelias.io), but are _mostly_ general purpose.

## Quickstart

All scripts default to looking at a local cluster, so to quickly get started monitoring a cluster, the following can be used:

```
git clone https://github.com/geocodeearth/elasticsearch-bash-utils.git
cd elasticsearch-bash-utils
watch bash es_diagnostic.sh
```

## Other scripts

### Common config parameters

#### `cluster_url`

All scripts take a `cluster_url` variable. The default is `http://localhost:9200`. The URL should include the protocol (`http`/`https`), but should _not_ include a trailing slash.

### Load a snapshot

This script lets you set up a Snapshot Repository pointing to a location in S3 and load a snapshot in a single command.

Example usage:

```sh
s3_bucket="your-s3-bucket" \
base_path="the/path/within/your/s3/bucket/where/the/snapshot/repository/lives" \
snapshot_name="the name of the snapshot, or leave blank to use the first snapshot listed" \
cluster_url="http://the-path-to-your-cluster" \
bash load_snapshot.sh
```

### Load a snapshot (without setting up a repository)

The same as above, but skips setting up a repository.

Example usage:

```sh
es_repo_name="your-repo-name" \
snapshot_name="the name of the snapshot, or leave blank to use the first snapshot listed" \
cluster_url="http://the-path-to-your-cluster" \
bash load_snapshot_only.sh
```

### Make an alias

This script creates a `pelias` alias, which can be helpful when working with multiple snapshots. Pelias [can be configured](https://github.com/pelias/api#configuration-via-pelias-config) to use any index name you choose, but the default is `pelias`.

Example usage:

```sh
cluster_url="http://the-path-to-your-cluster" \
index_name="yourIndex" \
alias_name="pelias" \
bash make_alias.sh
```

This will make an alias at `pelias` pointing to `yourIndex`.

The `alias_name` parameter defaults to `pelias` and can be omitted.

### Add (or remove) replica shards

This script can add or remove replica shards, useful when setting up a production ready cluster that needs to be resilient against node failure.

Example usage:

```sh
cluster_url="http://the-path-to-your-cluster" \
index_name="pelias" \
replica_count="1" \
bash add_replica.sh
```

The default value for `index_name` is `pelias`, and the default `replica_count` is `1`. You can remove all replicas with `replica_count="0"`.

### Force merge an index

[Force merging indices](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-forcemerge.html)
is a best practice to optimize performance of read-only workloads.

Example usage:
```sh
cluster_url="http://the-path-to-your-cluster" \
index_name="pelias" \
num_segments="1" \
bash force_merge.sh
```

The default value for `num_segments` is `1`. Higher values will complete faster, but `1` offers optimal performance.
