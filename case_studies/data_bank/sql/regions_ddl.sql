CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.regions (
  region_id INT,
  region_name VARCHAR(9)
)
COMMENT 'The region table contains the region IDs and names'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/regions/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
