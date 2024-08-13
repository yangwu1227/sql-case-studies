CREATE EXTERNAL TABLE IF NOT EXISTS trading.daily_btc (
  market_date TIMESTAMP COMMENT 'Cryptocurrency markets trade daily with no holidays',
  open_price DOUBLE COMMENT '$ USD price at the beginning of the day',
  high_price DOUBLE COMMENT 'Intra-day highest sell price in $ USD',
  low_price DOUBLE COMMENT 'Intra-day lowest sell price in $ USD',
  close_price DOUBLE COMMENT '$ USD price at the end of the day',
  adjusted_close_price DOUBLE COMMENT '$ USD price after splits and dividend distributions',
  volume DOUBLE COMMENT 'The daily amount of traded units of cryptocurrency'
)
COMMENT 'Daily Bitcoin trading data containing the open, high, low, close, adjusted close prices, and volume'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/trading/daily_btc/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
