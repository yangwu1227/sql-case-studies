CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.sales (
  customer_id CHAR(1),
  order_date TIMESTAMP,
  product_id INT
)
COMMENT 'The sales table captures all customer ID level purchases with order dates and product IDs'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/sales/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
