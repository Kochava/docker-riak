# docker-riak

This repository contains a Dockerfile that will build Riak into a Ubuntu 16.04
Xenial image, starting a Riak server.


Building
--------

To build the Docker image, run `make` (or `make docker`). The build can take
some time, as it involves building both Erlang and Riak from source.

You can alter the resulting image with the following Makefile variables:

| Variable             | Default                   | Description
| -                    | -                         | -
| `DOCKER`             | `docker`                  | The Docker executable. Can set to `img` or another CLI-compatible tool.
| `DOCKER_REGISTRY`    | `index.docker.io/kochava` | The registry to target.
| `DOCKER_IMAGE`       | `riak`                    | The image repository.
| `DOCKER_TAG`         | `latest`                  | The image tag.


Starting Riak
-------------

To start Riak, you can create a simple container with `docker run`:

```
# Create a network:
$ docker network create riak

# Start node riak-1:
$ docker run --detach --network riak --env RIAK_NODENAME=riak@riak-1. --name riak-1 kochava/riak
```

To then start a second node and join it to the cluster, you would do the
following:

```
# Start node riak-2:
$ docker run --detach --network riak --env RIAK_NODENAME=riak@riak-2. --name riak-2 kochava/riak

# Join the cluster:
$ docker exec -it riak-2 riak-admin cluster join riak@riak-1.

# Check the cluster plan:
$ docker exec -it riak-2 riak-admin cluster plan

# Commit the cluster plan:
$ docker exec -it riak-2 riak-admin cluster commit

# Check riak-1's memberships:
$ docker exec -it riak-1 riak-admin status | grep ring_members
ring_members : ['riak@riak-1.','riak@riak-2.']
```


Configuration
-------------

### riak.conf

The riak.conf can be modified in two ways:

1.  Mount a riak.conf as `/usr/local/riak/etc/riak.conf`.

2.  Set `RIAK_` environment variables, which will be appended to the riak.conf
    in the container. If you've mounted a riak.conf into the container, avoid
    using `RIAK_` variables, since this could modify the file that was mounted.

    The variables and the config key they correspond to are listed in a table
    below.

### advanced.conf

If modifying advanced.conf, you must mount it into the container or build
a derived image from it. There is currently no option to configure its options
via environment variables.

### Cluster Operations

Riak's bin dir is in the container's PATH. You can run `riak-admin`, `riak`, and
other commands using `docker exec`. Note that running `riak stop` will stop
Riak, but that runsv will start it afterward.

### Stopping the Container

Because the container uses `runsv`, if you start it in interactive mode,
a <kbd>Ctrl-C</kbd> will send an interrupt signal to runsv, which will
diligently send it to Riak.

Instead, you need to either send a terminate signal to runsv or use `docker stop
$CONTAINER` (which will send a terminate signal for you). You can also use
`docker exec $CONTAINER sv x`, which will also instruct runsv to exit.

### RIAK\_\* Environment Variables

The following environment variables, if set, will modify riak.conf by setting
the associated riak.conf field to its value. Exercise caution when using this
with bind-mounted riak.conf files, as it will append lines to the file.

| Environment Variable                                    | riak.conf Field
| -                                                       | -
| `RIAK_AF1_WORKER_POOL_SIZE`                             | `af1_worker_pool_size`
| `RIAK_AF2_WORKER_POOL_SIZE`                             | `af2_worker_pool_size`
| `RIAK_AF3_WORKER_POOL_SIZE`                             | `af3_worker_pool_size`
| `RIAK_AF4_WORKER_POOL_SIZE`                             | `af4_worker_pool_size`
| `RIAK_ANTI_ENTROPY`                                     | `anti_entropy`
| `RIAK_BACKEND_PAUSE_MS`                                 | `backend_pause_ms`
| `RIAK_BE_WORKER_POOL_SIZE`                              | `be_worker_pool_size`
| `RIAK_BITCASK_DATA_ROOT`                                | `bitcask.data_root`
| `RIAK_BITCASK_IO_MODE`                                  | `bitcask.io_mode`
| `RIAK_CLUSTER_JOB_RIAK_KV_LIST_BUCKETS`                 | `cluster.job.riak_kv.list_buckets`
| `RIAK_CLUSTER_JOB_RIAK_KV_LIST_KEYS`                    | `cluster.job.riak_kv.list_keys`
| `RIAK_CLUSTER_JOB_RIAK_KV_MAP_REDUCE`                   | `cluster.job.riak_kv.map_reduce`
| `RIAK_CLUSTER_JOB_RIAK_KV_MAP_REDUCE_JS`                | `cluster.job.riak_kv.map_reduce_js`
| `RIAK_CLUSTER_JOB_RIAK_KV_SECONDARY_INDEX`              | `cluster.job.riak_kv.secondary_index`
| `RIAK_CLUSTER_JOB_RIAK_KV_STREAM_LIST_BUCKETS`          | `cluster.job.riak_kv.stream_list_buckets`
| `RIAK_CLUSTER_JOB_RIAK_KV_STREAM_LIST_KEYS`             | `cluster.job.riak_kv.stream_list_keys`
| `RIAK_CLUSTER_JOB_RIAK_KV_STREAM_SECONDARY_INDEX`       | `cluster.job.riak_kv.stream_secondary_index`
| `RIAK_CLUSTER_JOB_YOKOZUNA_QUERY`                       | `cluster.job.yokozuna.query`
| `RIAK_CS_VERSION`                                       | `cs_version`
| `RIAK_DISTRIBUTED_COOKIE`                               | `distributed_cookie`
| `RIAK_DTRACE`                                           | `dtrace`
| `RIAK_ERLANG_ASYNC_THREADS`                             | `erlang.async_threads`
| `RIAK_ERLANG_ASYNC_THREADS_STACK_SIZE`                  | `erlang.async_threads.stack_size`
| `RIAK_ERLANG_CRASH_DUMP`                                | `erlang.crash_dump`
| `RIAK_ERLANG_DISTRIBUTION_BUFFER_SIZE`                  | `erlang.distribution_buffer_size`
| `RIAK_ERLANG_DISTRIBUTION_NET_TICKTIME`                 | `erlang.distribution.net_ticktime`
| `RIAK_ERLANG_DISTRIBUTION_PORT_RANGE_MAXIMUM`           | `erlang.distribution.port_range.maximum`
| `RIAK_ERLANG_DISTRIBUTION_PORT_RANGE_MINIMUM`           | `erlang.distribution.port_range.minimum`
| `RIAK_ERLANG_FULLSWEEP_AFTER`                           | `erlang.fullsweep_after`
| `RIAK_ERLANG_K`                                         | `erlang.K`
| `RIAK_ERLANG_MAX_ETS_TABLES`                            | `erlang.max_ets_tables`
| `RIAK_ERLANG_MAX_PORTS`                                 | `erlang.max_ports`
| `RIAK_ERLANG_PROCESS_LIMIT`                             | `erlang.process_limit`
| `RIAK_ERLANG_SCHEDULERS_COMPACTION_OF_LOAD`             | `erlang.schedulers.compaction_of_load`
| `RIAK_ERLANG_SCHEDULERS_FORCE_WAKEUP_INTERVAL`          | `erlang.schedulers.force_wakeup_interval`
| `RIAK_ERLANG_SCHEDULERS_ONLINE`                         | `erlang.schedulers.online`
| `RIAK_ERLANG_SCHEDULERS_TOTAL`                          | `erlang.schedulers.total`
| `RIAK_ERLANG_SCHEDULERS_UTILIZATION_BALANCING`          | `erlang.schedulers.utilization_balancing`
| `RIAK_ERLANG_SMP`                                       | `erlang.smp`
| `RIAK_ERLANG_W`                                         | `erlang.W`
| `RIAK_LEVELDB_COMPRESSION`                              | `leveldb.compression`
| `RIAK_LEVELDB_COMPRESSION_ALGORITHM`                    | `leveldb.compression.algorithm`
| `RIAK_LEVELDB_MAXIMUM_MEMORY_PERCENT`                   | `leveldb.maximum_memory.percent`
| `RIAK_LEVELED_COMPACTION_LOW_HOUR`                      | `leveled.compaction_low_hour`
| `RIAK_LEVELED_COMPACTION_RUNS_PERDAY`                   | `leveled.compaction_runs_perday`
| `RIAK_LEVELED_COMPACTION_TOP_HOUR`                      | `leveled.compaction_top_hour`
| `RIAK_LEVELED_COMPRESSION_METHOD`                       | `leveled.compression_method`
| `RIAK_LEVELED_COMPRESSION_POINT`                        | `leveled.compression_point`
| `RIAK_LEVELED_DATA_ROOT`                                | `leveled.data_root`
| `RIAK_LEVELED_JOURNAL_OBJECTCOUNT`                      | `leveled.journal_objectcount`
| `RIAK_LEVELED_JOURNAL_SIZE`                             | `leveled.journal_size`
| `RIAK_LEVELED_LEDGER_PAGECACHELEVEL`                    | `leveled.ledger_pagecachelevel`
| `RIAK_LEVELED_LOG_LEVEL`                                | `leveled.log_level`
| `RIAK_LEVELED_MAX_RUN_LENGTH`                           | `leveled.max_run_length`
| `RIAK_LEVELED_SYNC_STRATEGY`                            | `leveled.sync_strategy`
| `RIAK_LISTENER_HTTPS_INTERNAL`                          | `listener.https.internal`
| `RIAK_LISTENER_HTTP_INTERNAL`                           | `listener.http.internal`
| `RIAK_LISTENER_PROTOBUF_INTERNAL`                       | `listener.protobuf.internal`
| `RIAK_LOG_CONSOLE`                                      | `log.console`
| `RIAK_LOG_CONSOLE_FILE`                                 | `log.console.file`
| `RIAK_LOG_CONSOLE_LEVEL`                                | `log.console.level`
| `RIAK_LOG_CRASH`                                        | `log.crash`
| `RIAK_LOG_CRASH_FILE`                                   | `log.crash.file`
| `RIAK_LOG_CRASH_MAXIMUM_MESSAGE_SIZE`                   | `log.crash.maximum_message_size`
| `RIAK_LOG_CRASH_ROTATION`                               | `log.crash.rotation`
| `RIAK_LOG_CRASH_ROTATION_KEEP`                          | `log.crash.rotation.keep`
| `RIAK_LOG_CRASH_SIZE`                                   | `log.crash.size`
| `RIAK_LOG_ERROR_FILE`                                   | `log.error.file`
| `RIAK_LOG_SYSLOG`                                       | `log.syslog`
| `RIAK_MULTI_BACKEND_NAME_LEVELDB_COMPRESSION`           | `multi_backend.name.leveldb.compression`
| `RIAK_MULTI_BACKEND_NAME_LEVELDB_COMPRESSION_ALGORITHM` | `multi_backend.name.leveldb.compression.algorithm`
| `RIAK_MULTI_BACKEND_NAME_LEVELED_JOURNAL_OBJECTCOUNT`   | `multi_backend.name.leveled.journal_objectcount`
| `RIAK_MULTI_BACKEND_NAME_LEVELED_JOURNAL_SIZE`          | `multi_backend.name.leveled.journal_size`
| `RIAK_MULTI_BACKEND_NAME_LEVELED_LEDGER_PAGECACHELEVEL` | `multi_backend.name.leveled.ledger_pagecachelevel`
| `RIAK_NODENAME`                                         | `nodename`
| `RIAK_NODE_WORKER_POOL_SIZE`                            | `node_worker_pool_size`
| `RIAK_OBJECT_FORMAT`                                    | `object.format`
| `RIAK_OBJECT_SIBLINGS_MAXIMUM`                          | `object.siblings.maximum`
| `RIAK_OBJECT_SIBLINGS_WARNING_THRESHOLD`                | `object.siblings.warning_threshold`
| `RIAK_OBJECT_SIZE_MAXIMUM`                              | `object.size.maximum`
| `RIAK_OBJECT_SIZE_WARNING_THRESHOLD`                    | `object.size.warning_threshold`
| `RIAK_PARTICIPATE_IN_COVERAGE`                          | `participate_in_coverage`
| `RIAK_PLATFORM_BIN_DIR`                                 | `platform_bin_dir`
| `RIAK_PLATFORM_DATA_DIR`                                | `platform_data_dir`
| `RIAK_PLATFORM_ETC_DIR`                                 | `platform_etc_dir`
| `RIAK_PLATFORM_LIB_DIR`                                 | `platform_lib_dir`
| `RIAK_PLATFORM_LOG_DIR`                                 | `platform_log_dir`
| `RIAK_PROTOBUF_BACKLOG`                                 | `protobuf.backlog`
| `RIAK_RIAK_CONTROL`                                     | `riak_control`
| `RIAK_RIAK_CONTROL_AUTH_MODE`                           | `riak_control.auth.mode`
| `RIAK_RIAK_CONTROL_AUTH_USER_ADMIN_PASSWORD`            | `riak_control.auth.user.admin.password`
| `RIAK_RING_SIZE`                                        | `ring_size`
| `RIAK_SEARCH`                                           | `search`
| `RIAK_SEARCH_QUEUE_BATCH_FLUSH_INTERVAL`                | `search.queue.batch.flush_interval`
| `RIAK_SEARCH_QUEUE_BATCH_MAXIMUM`                       | `search.queue.batch.maximum`
| `RIAK_SEARCH_QUEUE_BATCH_MINIMUM`                       | `search.queue.batch.minimum`
| `RIAK_SEARCH_QUEUE_HIGH_WATERMARK`                      | `search.queue.high_watermark`
| `RIAK_SEARCH_QUEUE_HIGH_WATERMARK_PURGE_STRATEGY`       | `search.queue.high_watermark.purge_strategy`
| `RIAK_SEARCH_SOLR_JMX_PORT`                             | `search.solr.jmx_port`
| `RIAK_SEARCH_SOLR_JVM_OPTIONS`                          | `search.solr.jvm_options`
| `RIAK_SEARCH_SOLR_PORT`                                 | `search.solr.port`
| `RIAK_SEARCH_SOLR_START_TIMEOUT`                        | `search.solr.start_timeout`
| `RIAK_SSL_CACERTFILE`                                   | `ssl.cacertfile`
| `RIAK_SSL_CERTFILE`                                     | `ssl.certfile`
| `RIAK_SSL_KEYFILE`                                      | `ssl.keyfile`
| `RIAK_STORAGE_BACKEND`                                  | `storage_backend`
| `RIAK_STRONG_CONSISTENCY`                               | `strong_consistency`
| `RIAK_TICTACAAE_ACTIVE`                                 | `tictacaae_active`
| `RIAK_TICTACAAE_DATAROOT`                               | `tictacaae_dataroot`
| `RIAK_TICTACAAE_PARALLELSTORE`                          | `tictacaae_parallelstore`
| `RIAK_TICTACAAE_REBUILDDELAY`                           | `tictacaae_rebuilddelay`
| `RIAK_TICTACAAE_REBUILDWAIT`                            | `tictacaae_rebuildwait`
| `RIAK_TICTACAAE_STOREHEADS`                             | `tictacaae_storeheads`
| `RIAK_TRANSFER_LIMIT`                                   | `transfer_limit`
| `RIAK_WORKER_POOL_STRATEGY`                             | `worker_pool_strategy`


License
-------

All files under this repository are licensed under the Apache License Version
2.0.

Exceptions are made for riak.conf and advanced.config, which are under the same
license, but are copyright 2013 Basho Technologies, Inc.

```
Copyright 2019 Kochava, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```


## Default Branch

As of October 1, 2020, github.com uses the branch name ‘main’ when creating the initial default branch for all new repositories.  In order to minimize any customizations in our github usage and to support consistent naming conventions, we have made the decision to rename the ‘master’ branch to be called ‘main’ in all Kochava’s github repos.

For local copies of the repo, the following steps will update to the new default branch:

```
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```
