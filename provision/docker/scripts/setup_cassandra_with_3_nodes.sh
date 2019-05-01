#!/bin/bash
export PROVISION_DOCKER_DIR=$HOME/working/cassandra-db/work/provision/docker
# create network
source $PROVISION_DOCKER_DIR/scripts/init.sh
source $PROVISION_DOCKER_DIR/scripts/utils.sh
# node1
docker run --name cassandra1 \
--network cassandra-network \
-d cassandra:3.11

# node2
docker run --name cassandra2 \
--network cassandra-network \
-e CASSANDRA_SEEDS=cassandra1 \
-d cassandra:3.11

# node3
docker run --name cassandra3 \
--network cassandra-network \
-e CASSANDRA_SEEDS=cassandra1 \
-d cassandra:3.11

# verification
# wait 30s to for cassandra start-up
sleep 30

# run verify scripts
verify_docker
