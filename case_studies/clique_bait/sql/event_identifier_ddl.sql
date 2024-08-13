CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.event_identifier (
  event_type INT COMMENT 'Unique identifier for the type of event',
  event_name VARCHAR(100) COMMENT 'Name or description of the event type'
)
COMMENT 'The event identifier table stores the types of events that are captured by the system'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/event_identifier/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
