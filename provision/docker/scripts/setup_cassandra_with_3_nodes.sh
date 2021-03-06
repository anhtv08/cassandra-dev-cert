#!/bin/bash
export PROVISION_DOCKER_DIR=$HOME/working/cassandra-db/work/provision/docker
# create network
source $PROVISION_DOCKER_DIR/scripts/utils.sh
source $PROVISION_DOCKER_DIR/scripts/init.sh
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

# getting all cassandra docker_id
docker_ids=
get_cassandra_node
# verification
# wait 30s to for cassandra start-up
echo "Waiting 30s for cassandra cluster warm-up"
sleep 30

# run verify scripts
verify_docker $docker_ids
