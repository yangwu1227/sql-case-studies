CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.users (
  user_id INT,
  cookie_id VARCHAR(6),
  start_date TIMESTAMP
)
COMMENT 'The users table stores customers who visit the Clique Bait website and their tagged cookie IDs'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/users/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
