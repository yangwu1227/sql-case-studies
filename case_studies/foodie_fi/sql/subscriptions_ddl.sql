CREATE EXTERNAL TABLE IF NOT EXISTS foodie_fi.subscriptions (
  customer_id SMALLINT COMMENT 'Unique identifier for the customer',
  plan_id TINYINT COMMENT 'Unique identifier for the plan associated with the subscription',
  start_date TIMESTAMP COMMENT 'Start date of the subscription'
)
COMMENT 'The subscriptions table stores information about customer subscriptions to various plans'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/foodie_fi/subscriptions/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
