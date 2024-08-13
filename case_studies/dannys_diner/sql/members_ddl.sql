CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.members (
  customer_id CHAR(1) COMMENT 'Unique identifier for the customer, represented as a single character',
  join_date TIMESTAMP COMMENT 'Date and time when the customer joined the loyalty program'
)
COMMENT 'The members table captures the dates when each customer joined the beta version of the Dannys Diner loyalty program'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/members/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
