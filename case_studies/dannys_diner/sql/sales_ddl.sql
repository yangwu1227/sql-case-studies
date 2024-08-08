CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.sales (
  customer_id CHAR(1),
  order_date TIMESTAMP,
  product_id INT
)
COMMENT 'Sales line items'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/sales/'
TBLPROPERTIES ('has_encrypted_data'='false', 'classification'='parquet', 'skip.header.line.count'='1');
