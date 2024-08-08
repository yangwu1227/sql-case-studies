CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.event_identifier (
  event_type INT,
  event_name VARCHAR(100)
)
COMMENT 'The events identifier table stores the types of event that are captured by the system'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/event_identifier/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
