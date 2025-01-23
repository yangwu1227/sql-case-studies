CREATE EXTERNAL TABLE IF NOT EXISTS balanced_tree.product_details (
  product_id VARCHAR(6) COMMENT 'Unique identifier for the product',
  price SMALLINT COMMENT 'Price of the product in the store',
  product_name VARCHAR(50) COMMENT 'Name of the product',
  category_id SMALLINT COMMENT 'Unique identifier for the category',
  segment_id SMALLINT COMMENT 'Unique identifier for the segment',
  style_id SMALLINT COMMENT 'Unique identifier for the style',
  category_name VARCHAR(10) COMMENT 'Name of the category',
  segment_name VARCHAR(10) COMMENT 'Name of the segment',
  style_name VARCHAR(50) COMMENT 'Name of the style'
)
COMMENT 'The product details table includes all information about the products featured in the store'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/balanced_tree/product_details/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
