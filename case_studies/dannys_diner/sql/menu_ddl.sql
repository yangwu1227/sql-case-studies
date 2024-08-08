CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.menu (
  product_id INT,
  product_name STRING,
  price DOUBLE
)
COMMENT 'The menu table maps the product IDs to the actual product names and prices'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/menu/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
