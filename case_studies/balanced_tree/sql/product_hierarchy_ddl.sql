CREATE EXTERNAL TABLE IF NOT EXISTS balanced_tree.product_hierarchy (
  id SMALLINT COMMENT 'Unique identifier for the entry in the hierarchy',
  parent_id SMALLINT COMMENT 'Parent identifier for the current level (NULL for top-level categories)',
  level_text VARCHAR(30) COMMENT 'Name or description of the hierarchy level (e.g., product type or style)',
  level_name VARCHAR(20) COMMENT 'Name of the hierarchy level (e.g., Category, Segment, or Style)'
)
COMMENT 'This table represents the hierarchical structure of product categories, segments, and styles for the store, and each entry defines the relationship between levels, starting from top-level categories down to individual product styles'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/balanced_tree/product_hierarchy/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');

