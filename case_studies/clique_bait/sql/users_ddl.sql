CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.users (
  user_id INT COMMENT 'Unique identifier for the user',
  cookie_id VARCHAR(6) COMMENT 'Unique identifier for the user’s browser session, represented as a cookie ID',
  start_date TIMESTAMP COMMENT 'Date and time when the user first visited the website'
)
COMMENT 'The users table stores customers who visit the Clique Bait website and their tagged cookie IDs'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/users/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
