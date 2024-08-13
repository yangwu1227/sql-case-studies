CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.customer_transactions (
  customer_id INT COMMENT 'Unique identifier for the customer',
  txn_date TIMESTAMP COMMENT 'Date and time of the transaction',
  txn_type VARCHAR(10) COMMENT 'Type of transaction: deposit, withdrawal, or purchase',
  txn_amount DOUBLE COMMENT 'Amount involved in the transaction'
)
COMMENT 'The customer transactions table stores all customer deposits, withdrawals, and purchases'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/customer_transactions/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
