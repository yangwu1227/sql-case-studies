CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.regions (
  region_id INT COMMENT 'Unique identifier for the region',
  region_name VARCHAR(9) COMMENT 'Name of the region, up to 9 characters'
)
COMMENT 'The region table contains the region IDs and names'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/regions/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
