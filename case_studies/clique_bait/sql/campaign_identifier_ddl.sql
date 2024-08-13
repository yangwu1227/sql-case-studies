CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.campaign_identifier (
  campaign_id INT COMMENT 'Unique identifier for the campaign',
  products VARCHAR(3) COMMENT 'List of products associated with the campaign, represented as a short code',
  campaign_name VARCHAR(100) COMMENT 'Name of the campaign',
  start_date TIMESTAMP COMMENT 'Date and time when the campaign started',
  end_date TIMESTAMP COMMENT 'Date and time when the campaign ended'
)
COMMENT 'The campaign identifier table stores the three campaigns run by Clique Bait so far'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/campaign_identifier/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
