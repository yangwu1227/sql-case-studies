CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.events (
  visit_id VARCHAR(6),
  cookie_id VARCHAR(6),
  page_id INT,
  event_type INT,
  sequence_number INT,
  event_time TIMESTAMP
)
COMMENT 'The events table captures all customers vists that are logged at the cookie ID level'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/events/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
