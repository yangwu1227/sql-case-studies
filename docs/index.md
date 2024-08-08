## Danny's Diner

### DDL

#### Members

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.members (
  customer_id CHAR(1),
  join_date TIMESTAMP
)
COMMENT 'Membership details'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/members/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

#### Menu

```sql
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
```

#### Sales

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.sales (
  customer_id CHAR(1),
  order_date TIMESTAMP,
  product_id INT
)
COMMENT 'Sales line items'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/sales/'
TBLPROPERTIES ('has_encrypted_data'='false', 'classification'='parquet', 'skip.header.line.count'='1');
```

---

## Data Bank

### DDL

#### Customer Nodes

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.customer_nodes (
  customer_id INT,
  region_id INT,
  node_id INT,
  start_date TIMESTAMP,
  end_date TIMESTAMP
)
COMMENT 'Customer nodes table'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/customer_nodes/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

#### Customer Transactions

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.customer_transactions (
  customer_id INT,
  txn_date TIMESTAMP,
  txn_type VARCHAR(10),
  txn_amount DOUBLE
)
COMMENT 'Customer transactions table'
ROW FORMAT DELIMITED
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/customer_transactions/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

---

## Trading

### DDL 

#### Daily Bitcoin Price

```sql
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
```
