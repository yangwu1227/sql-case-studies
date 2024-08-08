CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.customer_transactions (
  customer_id INT,
  txn_date TIMESTAMP,
  txn_type VARCHAR(10),
  txn_amount DOUBLE
)
COMMENT 'Customer transactions table'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/customer_transactions/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
