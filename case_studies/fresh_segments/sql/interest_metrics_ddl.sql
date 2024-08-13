CREATE EXTERNAL TABLE IF NOT EXISTS fresh_segments.interest_metrics (
  record_month INT COMMENT 'Represents the month of the record',
  record_year INT COMMENT 'Represents the year of the record',
  month_year VARCHAR(7) COMMENT 'Month and year concatenated as a string in the format MM-YYYY',
  interest_id INT COMMENT 'Unique identifier for the interest',
  composition DOUBLE COMMENT 'Represents the composition percentage of the interest',
  index_value DOUBLE COMMENT 'Index value indicating performance based on composition',
  ranking INT COMMENT 'Ranking of the interest based on index value',
  percentile_ranking DOUBLE COMMENT 'Percentile ranking of the interest'
)
COMMENT "The interest metrics table represents the performance of specific interests based on the client's customer base"
STORED AS PARQUET
LOCATION 's3://sql-case-studies/fresh_segments/interest_metrics/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
