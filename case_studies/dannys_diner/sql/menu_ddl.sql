CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.menu (
  product_id INT COMMENT 'Unique identifier for the product',
  product_name STRING COMMENT 'Name of the product',
  price DOUBLE COMMENT 'Price of the product'
)
COMMENT 'The menu table maps the product IDs to the actual product names and prices'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/menu/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
