CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.page_hierarchy (
  page_id INT COMMENT 'Unique identifier for the page',
  page_name VARCHAR(50) COMMENT 'Name of the page on the website',
  product_category VARCHAR(50) COMMENT 'Category of the product featured on the page',
  product_id INT COMMENT 'Unique identifier for the product featured on the page'
)
COMMENT 'The page hierarchy table lists all pages on the Clique Bait website'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/page_hierarchy/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
