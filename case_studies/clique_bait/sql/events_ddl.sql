CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.events (
  visit_id VARCHAR(6) COMMENT 'Unique identifier for the visit session',
  cookie_id VARCHAR(6) COMMENT "Unique identifier for the user's browser session, represented as a cookie ID",
  page_id INT COMMENT 'Unique identifier for the page viewed during the event',
  event_type INT COMMENT 'Type of event that occurred (e.g., page view, add to cart, purchase)',
  sequence_number INT COMMENT 'Order of the event in the sequence of actions during the visit',
  event_time TIMESTAMP COMMENT 'Date and time when the event occurred'
)
COMMENT 'The events table captures all customers visits that are logged at the cookie ID level'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/events/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
