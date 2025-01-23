CREATE EXTERNAL TABLE IF NOT EXISTS balanced_tree.product_prices (
  id SMALLINT COMMENT 'Unique identifier for the price record',
  product_id VARCHAR(6) COMMENT 'Unique identifier for the product',
  price SMALLINT COMMENT 'Price of the product in the store'
)
COMMENT 'This table stores the pricing information for products, including product identifiers and their corresponding prices'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/balanced_tree/product_prices/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
