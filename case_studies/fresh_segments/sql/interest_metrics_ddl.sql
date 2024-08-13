CREATE EXTERNAL TABLE IF NOT EXISTS fresh_segments.interest_metrics (
  record_month INT COMMENT 'Represents the month of the record',
  record_year INT COMMENT 'Represents the year of the record',
  month_year VARCHAR(7) COMMENT 'Month and year concatenated as a string in the format MM-YYYY',
  interest_id INT COMMENT 'Unique identifier for the interest',
  composition DOUBLE COMMENT 'Represents the composition percentage of the interest (e.g., 11.89% of the client’s customer list interacted with the interest)',
  index_value DOUBLE COMMENT 'Index value indicating how much higher the composition value is compared to the average composition value for all Fresh Segments clients’ customers for this interest in the same month (e.g., 6.19 means 6.19x the average)',
  ranking INT COMMENT 'Ranking of the interest based on the index value in the given month year (e.g., 1 for the highest index value)',
  percentile_ranking DOUBLE COMMENT 'Percentile ranking of the interest based on its index value, indicating its position relative to other interests in the same month year (e.g., 99.86 means it is in the top 0.14%)'
COMMENT "The interest metrics table represents the performance of specific interests based on the client's customer base"
STORED AS PARQUET
LOCATION 's3://sql-case-studies/fresh_segments/interest_metrics/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
