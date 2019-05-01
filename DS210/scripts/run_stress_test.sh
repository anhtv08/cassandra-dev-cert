#!/bin/bash
# run stress test command and export result as graph format in http file
source ./setup.sh
$CASSANDRA_TOOLS_BIN/cassandra-stress user profile=$CASSANDRA_DS210_DATA_CONF/cql/stress-test-profile.yaml \
 n=10000 ops\(insert=3,read1=1\) no-warmup cl=LOCAL_ONE \
 -graph file=$CASSANDRA_DS210_DATA_CONF/logs/performance_stress_test.html  \
  title='Casssandra_Performance_Test' \
  revision='Casssandra_Performance_Test'