
# setup cassandra home folder.

export CASSANDRA_HOME=/Users/anhtrang/working/cassandra-db/apache-cassandra-3.11.4

# note that this is my working folder :
#  /Users/anhtrang/working/cassandra-db/work/DS201
# check cassandra cluster node.

 ./nodetool status


# open cqlsh terminal
./cqlsh
 # create new keyspace for KillrVideo in cassandra


create keyspace KillrVideo
 with replication = {
  'class' : 'SimpleStrategy',
  'replication_factor' : 1
};

 # switch to the schema
 use KillrVideo;
 # create videos tables with primary key is video_id
 create table videos(
  video_id timeuuid ,
  added_date timestamp,
  title text,
  PRIMARY KEY(video_id)
 );

 # load data from csv file.

 COPY videos(video_id, added_date, title)
 FROM '/Users/anhtrang/working/cassandra-db/work/DS201/labwork/data-files/videos.csv'
 WITH HEADER=TRUE;

 # verify data.

 select * from videos ;
 select count(1) from videos;

 # exit from cql
 quit

 ======== partitions exercise =========


# check node status

./nodetool status

# verify data file.

cat /Users/anhtrang/working/cassandra-db/work/DS201/labwork/data-files/videos-by-tag.csv

# create table videos by tags

create table videos_by_tag(
  tag text,
  video_id timeuuid ,
  added_date timestamp,
  title text,
  PRIMARY KEY( (tag), video_id)
);

# load data into videos_by_tag table.

COPY videos_by_tag(tag, video_id, added_date, title) FROM '/Users/anhtrang/working/cassandra-db/work/DS201/labwork/data-files/videos-by-tag.csv' WITH HEADER = TRUE;

# verify table after load.
SELECT * FROM videos_by_tag;

# find data by tag.

select * from videos_by_tag
where tag ='datastax';

# query table by title 'Cassandra Intro'.
# should expect error as Cassandra does not support query data no non-primary columns
# unless the allow filtering is enable

========= clustering columns========

# drop tables videos_by_tag;
drop table videos_by_tag;

# create table with the clustering key added_date desc
CREATE TABLE videos_by_tag (
     tag text,
     video_id uuid,
     added_date timestamp,
     title text,
     PRIMARY KEY (
      (tag),
      added_date,
      video_id
     ))

WITH CLUSTERING ORDER BY  (
      added_date desc
);

# Re-load data into data.

COPY videos_by_tag(tag, video_id, added_date, title) FROM '/Users/anhtrang/working/cassandra-db/work/DS201/labwork/data-files/videos-by-tag.csv' WITH HEADER = TRUE;

# select videos made in 2013 or later;

// time format in UTC format, with Z indicate UTC offset=0 (GMT)
select * from videos_by_tag  where tag ='cassandra'  and added_date >= '2013-01-01T00:00:00Z'

=========== Driver connectivity========

============= node=======

# check number of tokens on the nodes. Default is 256.
./nodetool info --tokens | grep Token | wc

# decribe cluster information.

./nodetool describecluster

# getting logging level
./nodetool getlogginglevels

# enable trace.
./nodetool setlogginglevel org.apache.cassandra TRACE

# drain to stop write on current node and flush all sstables onto disk.
# This command run before stop cassandra deamon process.

./nodetool drain

#  stop node execution process.
./nodetool stopdaemon

# re-start node.

./cassandra

# run stress test. change to CASSANDRA_HOME/tools/bin
# folder where the stress test tool reside.
./cassandra-stress write n=50000 no-warmup -rate threads=1 \
>>/Users/anhtrang/working/cassandra-db/work/DS201/labwork/logs/stress-test.log

# flush data.
./nodetool flush

# check status

./nodetool status

============== Ring===========
# create two nodes cluster.

# stop current running casandra.
 ./nodetool stopdaemon

# create two new folders ( node1, node2)
mkdir node1 node2

# extract tar file into node1 node2

tar -xvf apache-cassandra-3.11.4-bin.tar.gz -C node1
tar -xvf apache-cassandra-3.11.4-bin.tar.gz -C node2

#  create videos and videos_by_tag table
# reload data using previous step.

# run this command to specify the number of partitions.

SELECT token(tag), tag
FROM videos_by_tag;

"""
system.token(tag)    | tag
----------------------+-----------
 -1651127669401031945 |  datastax
 -1651127669401031945 |  datastax
   356242581507269238 | cassandra
   356242581507269238 | cassandra
   356242581507269238 | cassandra

"""
# solution is two partitions.


# cassandra exchange data with other nodes using gossip protocol.

./nodetool gossipinfo

# consistency level.

# if query under consistency level require
# cassandra will return `NoHostAvailable` exception.
==========Hinted Handoff==========

========== Write path==========

#install watch command on mac
brew install watch

# run this command to watch the commitlog folder
watch -n 1 -d 'ls -lh $CASSANDRA_HOME/data/commitlog/'

# run stress test.
$CASSANDRA_HOME/tools/bin/cassandra-stress write no-warmup n=250000 -rate threads=1

#run tablestats

$CASSANDRA_HOME/bin/nodetool tablestats keyspace1.standard1

# run flush to flush memtable to disk

./nodetool flush

======= read path=======
