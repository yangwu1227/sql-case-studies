CREATE EXTERNAL TABLE IF NOT EXISTS fresh_segments.interest_map (
  id INT COMMENT 'Unique identifier for the interest',
  interest_name VARCHAR(100) COMMENT 'Name of the interest',
  interest_summary VARCHAR(500) COMMENT 'Brief summary or description of the interest',
  created_at TIMESTAMP COMMENT 'Timestamp when the record was created',
  last_modified TIMESTAMP COMMENT 'Timestamp when the record was last modified'
)
COMMENT 'The interest map table links the interest IDs with the relevant interest names and summaries'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/fresh_segments/interest_map/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
