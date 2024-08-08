CREATE EXTERNAL TABLE IF NOT EXISTS trading.daily_btc (
  market_date TIMESTAMP,
  open_price DOUBLE,
  high_price DOUBLE,
  low_price DOUBLE,
  close_price DOUBLE,
  adjusted_close_price DOUBLE,
  volume DOUBLE
)
COMMENT 'Daily Bitcoin trading data'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/trading/daily_btc/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
