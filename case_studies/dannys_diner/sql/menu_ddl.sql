CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.menu (
  product_id INT,
  product_name STRING,
  price DOUBLE
)
COMMENT 'Menu details'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/menu/'
TBLPROPERTIES ('has_encrypted_data'='false', 'classification'='parquet', 'skip.header.line.count'='1');
