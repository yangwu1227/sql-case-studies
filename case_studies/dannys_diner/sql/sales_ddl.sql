CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.sales (
  customer_id CHAR(1) COMMENT 'Unique identifier for the customer, represented as a single character',
  order_date TIMESTAMP COMMENT 'Date and time when the order was placed',
  product_id INT COMMENT 'Unique identifier for the product purchased'
)
COMMENT 'The sales table captures all customer ID level purchases with order dates and product IDs'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/sales/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
