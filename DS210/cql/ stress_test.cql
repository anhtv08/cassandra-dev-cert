export CASSANDRA_HOME=/Users/anhtrang/working/cassandra-db/apache-cassandra-3.11.4
export CASSANDRA_DS210_DATA_CONF=/Users/anhtrang/working/cassandra-db/work/DS210
# adding cassandra executable command to the path. for current shell session
export path=$path:$CASSANDRA_HOME/bin

export CASSANDRA_TOOLS_BIN=$CASSANDRA_HOME/tools/bin
# create stress-test-profile.yaml profile

# change to cassandra tool folder.

CREATE KEYSPACE perftesting WITH replication = { 'class': 'SimpleStrategy', 'replication_factor': 1};

cd $CASSANDRA_HOME/tools/bin
# run stress test command and export result as graph format in http file
./cassandra-stress user profile=$CASSANDRA_DS210_DATA_CONF/cql/stress-test-profile.yaml \
 n=10000 ops\(insert=3,read1=1\) no-warmup cl=LOCAL_ONE \
 -graph file=$CASSANDRA_DS210_DATA_CONF/logs/test.html  \
  title='Casssandra_Performance_Test' \
  revision='Casssandra_Performance_Test'
