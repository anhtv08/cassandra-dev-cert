#!/bin/bash

# remove all cassandra container.
docker_ids=$(docker ps -a | grep cassandra| awk '{print $1}')
docker stop $docker_ids
docker rm $docker_ids

# remove the cassandra-network bridge.
docker network rm cassandra-network

echo "Clean up is done!"