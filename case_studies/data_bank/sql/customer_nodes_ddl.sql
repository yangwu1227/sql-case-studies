CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.customer_nodes (
  customer_id INT,
  region_id INT,
  node_id INT,
  start_date TIMESTAMP,
  end_date TIMESTAMP
)
COMMENT 'Customer nodes table'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/customer_nodes/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
