#!/bin/bash
# if you want to use this script please update following configuration accordingly.
export CASSANDRA_HOME="$HOME/working/cassandra-db/apache-cassandra-3.11.4"
export LAB_WORK_DIR="$HOME/working/cassandra-db/work"
export CASSANDRA_RESOURCE_CONFIG='' # todo: to be completed
declare -a  cassandra_course=(
    'DS201'
    'DS220'
    'DS210'
)

for item in "${cassandra_course[@]}"
do
    echo $item
done
