export CASSANDRA_HOME=/Users/anhtrang/working/cassandra-db/apache-cassandra-3.11.4
export CASSANDRA_DATA_FILE='/Users/anhtrang/working/cassandra-db/work/DS220/labwork'

# note that this is my working folder :
#  /Users/anhtrang/working/cassandra-db/work/DS220
# check cassandra cluster node.

 ./nodetool status


# open cqlsh terminal
./cqlsh
 # create new keyspace for KillrVideo in cassandra

# get all schema from database.
SELECT * FROM system_schema.keyspaces;
#  drop existing killrvideo;
drop KEYSPACE killrvideo;

# create new schema.


create keyspace KillrVideo
 with replication = {
  'class' : 'SimpleStrategy',
  'replication_factor' : 1
};

# create  videos table.
create TABLE KillrVideo.videos(  
    video_id timeuuid , 
    added_date timestamp, 
    description text,
    title text,
    user_id UUID,
    PRIMARY KEY(video_id) 
); 


# load data from csv file.

./cqlsh -e """
COPY KillrVideo.videos (video_id,added_date,description,title,user_id) 
FROM '$CASSANDRA_DATA_FILE/cql/videos.csv' 
WITH HEADER=true
"""

# verify data.

SELECT COUNT(*)
FROM videos;

# query data by given video.

SELECT *
FROM videos WHERE video_id =6c4cffb9-0dc4-1d59-af24-c960b5fc3652;

# truncate all data.
truncate videos;


##======Partitioning And Storage Structure========

title	text
added_year	int
added_date	timestamp
description	text
user_id	uuid
video_id	uuid

# create videos_by_title_year.
create table killrvideos.videos_by_title_year (
    title text,
    added_year int,
    added_date timestamp,
    description text,
    user_id uuid,
    video_id uuid,
    PRIMARY key (
        (title, added_year),
        added_date
    )
)
WITH CLUSTERING ORDER BY  (
      added_date desc
);

# loading data into table
./cqlsh -e """
COPY KillrVideo.videos_by_title_year (title, added_year, added_date, description, user_id, video_id) 
FROM '$CASSANDRA_DATA_FILE/partitions/videos_by_title_year.csv'
WITH HEADER=true
"""

# Clustering Columns

# create this table

CREATE TABLE bad_videos_by_tag_year (
     tag text,
     added_year int,
     added_date timestamp,
     title text,description text,
     user_id uuid,
     video_id timeuuid,
     PRIMARY KEY ((video_id))
);

# load data into to:

./cqlsh -e  """
COPY KillrVideo.bad_videos_by_tag_year (tag, added_year, video_id, added_date, description, title, user_id) 
FROM '$CASSANDRA_DATA_FILE/clustering/videos_by_tag_year.csv' 
WITH HEADER=true
"""


# verify data.
SELECT COUNT(*) FROM bad_videos_by_tag_year;

# Create a 'videos_by_tag_year' table that allows range scans and ordering by year

CREATE TABLE KillrVideo.videos_by_tag_year(
tag text,
added_year int,
video_id uuid,
added_date timestamp,
description text,
title text,
user_id uuid,
primary key (
    (tag,added_year),
    added_date,
    video_id
)
)
with CLUSTERING ORDER by (
    added_date DESC
);

# load data.
./cqlsh  -e """
COPY KillrVideo.videos_by_tag_year(
    tag,
    added_year,
    video_id,
    added_date ,
    description ,
    title,
    user_id
) 
FROM '$CASSANDRA_DATA_FILE/clustering/videos_by_tag_year.csv'
 WITH HEADER=true
"""

# noted: always specify the column for importing when performing copying data.

# =======Denormalization=============

# create a custom data type:

CREATE TYPE IF NOT EXISTS killrVideo.video_encoding(
     encoding TEXT,
     height INT,
     width INT,
     bit_rates SET<text>
 );

# create video by 

CREATE TABLE killrVideo.videos_by_actor (
     actor text,
     added_date timestamp,
     video_id timeuuid,
     character_name text,
     description text,
     encoding frozen<video_encoding>, 
     tags set<text>,
     title text,
     user_id uuid,
     PRIMARY KEY ( 
         (actor),
         added_date,
         video_id
     )
) WITH CLUSTERING ORDER BY (
    added_date DESC
 );

# load data into video_by_actor

./cqlsh -e """
COPY killrVideo.videos_by_actor 
(
    actor,
    added_date, 
    video_id, 
    character_name, 
    description, 
    encoding, 
    tags, 
    title, 
    user_id
) 
FROM '$CASSANDRA_DATA_FILE/denormalization/videos_by_actor.csv' 
WITH HEADER = true
"""

# verify data.
SELECT actor, added_date 
from videos_by_actor  
where actor ='Tom Hanks' 
limit 10;
Tom Hanks
# create video genres:

CREATE TABLE if not exists killrVideo.videos_by_genre (
     genre text,
     added_date timestamp,
     video_id timeuuid,
     description text,
     encoding frozen<video_encoding>, 
     tags set<text>,
     title text,
     user_id uuid,
     PRIMARY KEY (
         (genre),
         added_date,
         video_id
      )
) WITH CLUSTERING ORDER BY ( 
    added_date DESC
);

# load data into genre table:

./cqlsh -e """
COPY killrVideo.videos_by_genre
(
    genre, 
    added_date, 
    video_id, 
    description, 
    encoding, 
    tags, 
    title, 
    user_id
)
FROM '$CASSANDRA_DATA_FILE/denormalization/videos_by_genre.csv' 
WITH HEADER = true
"""

# verify data.

SELECT * FROM videos_by_genre WHERE genre = 'Musical' LIMIT 10;

#=====Table Features===============

#=======UDTs==========


# preview data.

head $CASSANDRA_DATA_FILE/udts/videos_encoding.csv

# alter videos table.

alter table killrVideo.videos add (
     tags set<text>
)

# load data into videos table.

./cqlsh -e """
COPY killrVideo.videos
(
    video_id, 
    added_date, 
    description, 
    tags, 
    title,
    user_id
)
FROM '$CASSANDRA_DATA_FILE/udts/videos.csv' 
WITH HEADER = true
"""

# verify data.
./cqlsh -e "select count(*) from killrVideo.videos"

# adding video_encoding. 
# need to add frozen key word for nested data type

alter table killrVideo.videos add(
    encoding frozen<video_encoding>
)

# load data into videos table using copy command.

./cqlsh -e """
COPY killrVideo.videos
(
    video_id, 
    encoding
)
FROM '$CASSANDRA_DATA_FILE/udts/videos_encoding.csv' 
WITH HEADER = true
"""

# verify data - inline query approach.
./cqlsh -e "select * from killrvideo.videos limit 10";

# ============ counter ==============

head "$CASSANDRA_DATA_FILE/counters/videos_count_by_tag.cql"

create table if not exists killrVideo.videos_count_by_tag(
    tag text,
    added_year int,
    video_count COUNTER,
    PRIMARY key (
        (tag,added_year)
   )
)

# run the comment to update counter.
./cqlsh -f "$CASSANDRA_DATA_FILE/counters/videos_count_by_tag.cql"

# create killr_video data model.
./cqlsh -f "$CASSANDRA_DATA_FILE/final/killrvideo.cql"

# load data into killr_video schema.
COPY videos FROM 'videos.csv' WITH HEADER=true;
COPY latest_videos FROM 'latest_videos.csv' WITH HEADER=true;
COPY trailers_by_video FROM 'trailers_by_video.csv' WITH HEADER=true;
COPY actors_by_video FROM 'actors_by_video.csv' WITH HEADER=true;

