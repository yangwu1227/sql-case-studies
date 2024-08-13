CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.customer_nodes (
  customer_id INT COMMENT 'Unique identifier for the customer',
  region_id INT COMMENT 'Unique identifier for the region',
  node_id INT COMMENT 'Unique identifier for the node within the region',
  start_date TIMESTAMP COMMENT 'Date and time when the customer was assigned to the node',
  end_date TIMESTAMP COMMENT 'Date and time when the customer was removed from the node, NULL if still active'
)
COMMENT 'The customer nodes table stores the customer IDs, region IDs, node IDs, and the start and end dates that the customer was assigned to the node'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/customer_nodes/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
