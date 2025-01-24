CREATE EXTERNAL TABLE IF NOT EXISTS foodie_fi.plans (
  plan_id TINYINT COMMENT 'Unique identifier for the plan',
  plan_name VARCHAR(20) COMMENT 'Name of the subscription plan',
  price FLOAT COMMENT 'Price of the subscription plan'
)
COMMENT 'The plans table contains information about the different subscription plans available, including churn events'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/foodie_fi/plans/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
