CREATE EXTERNAL TABLE IF NOT EXISTS balanced_tree.sales (
  prod_id VARCHAR(6) COMMENT 'Unique identifier for the product',
  qty SMALLINT COMMENT 'Quantity of the product purchased in the transaction',
  price SMALLINT COMMENT 'Price of the product in the transaction',
  discount SMALLINT COMMENT 'Discount percentage applied to the product',
  member VARCHAR(1) COMMENT 'Membership status of the buyer (e.g., t for true, f for false)',
  txn_id VARCHAR(6) COMMENT 'Unique identifier for the transaction',
  start_txn_time TIMESTAMP COMMENT 'Timestamp of when the transaction started'
)
COMMENT 'This table contains product-level transaction data, including quantities, prices, discounts, membership status, transaction IDs, and transaction timestamps'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/balanced_tree/sales/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
