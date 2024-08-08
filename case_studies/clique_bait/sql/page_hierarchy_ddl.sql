CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.page_hierarchy (
  page_id INT,
  page_name VARCHAR(50),
  product_category VARCHAR(50),
  product_id INT
)
COMMENT 'The page hierarchy table lists of all pages on the Clique Bait website'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/page_hierarchy/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
