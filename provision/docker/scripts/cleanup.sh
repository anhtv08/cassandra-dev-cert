#!/bin/bash

# remove all cassandra container.
export PROVISION_DOCKER_DIR=$HOME/working/cassandra-db/work/provision/docker
# create network
docker_ids=
source $PROVISION_DOCKER_DIR/scripts/utils.sh
get_cassandra_node

docker stop $docker_ids
docker rm $docker_ids

# remove the cassandra-network bridge.
docker network rm cassandra-network

echo "Clean up is done!"