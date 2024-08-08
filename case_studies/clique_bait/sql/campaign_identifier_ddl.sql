CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.campaign_identifier (
  campaign_id INT,
  products VARCHAR(3),
  campaign_name VARCHAR(100),
  start_date TIMESTAMP,
  end_date TIMESTAMP
)
COMMENT 'The campaign identifier table stores the three campaigns run by Clique Bait so far'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/campaign_identifier/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
