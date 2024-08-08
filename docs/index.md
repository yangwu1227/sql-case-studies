## Danny's Diner

### DDL

#### Members

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.members (
  customer_id CHAR(1),
  join_date TIMESTAMP
)
COMMENT 'The members table captures the dates when each customer joined the beta version of the Dannys Diner loyalty program'
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
COMMENT 'The menu table maps the product IDs to the actual product names and prices'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/menu/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

#### Sales

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS dannys_diner.sales (
  customer_id CHAR(1),
  order_date TIMESTAMP,
  product_id INT
)
COMMENT 'The sales table captures all customer ID level purchases with order dates and product IDs'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/dannys_diner/sales/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

---

## Data Bank

### DDL

#### Region

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.regions (
  region_id INT,
  region_name VARCHAR(9)
)
COMMENT 'The region table contains the region IDs and names'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/data_bank/regions/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

#### Customer Nodes

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS data_bank.customer_nodes (
  customer_id INT,
  region_id INT,
  node_id INT,
  start_date TIMESTAMP,
  end_date TIMESTAMP
)
COMMENT 'The customer nodes table stores the customer IDs, region IDs, node IDs, and the start and end dates that the customer was assigned to the node'
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
COMMENT 'The customer transactions table stores all customer deposits, withdrawals, and purchases'
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
COMMENT 'Daily Bitcoin trading data containing the open, high, low, close, adjusted close prices, and volume'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/trading/daily_btc/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

---

## Clique Bait

### DDL

#### Users

```sql 
CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.users (
  user_id INT,
  cookie_id VARCHAR(6),
  start_date TIMESTAMP
)
COMMENT 'The users table stores customers who visit the Clique Bait website and their tagged cookie IDs'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/users/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

#### Events

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.events (
  visit_id VARCHAR(6),
  cookie_id VARCHAR(6),
  page_id INT,
  event_type INT,
  sequence_number INT,
  event_time TIMESTAMP
)
COMMENT 'The events table captures all customers vists that are logged at the cookie ID level'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/events/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

#### Event Identifier

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.event_identifier (
  event_type INT,
  event_name VARCHAR(100)
)
COMMENT 'The events identifier table stores the types of event that are captured by the system'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/event_identifier/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

#### Campaign Identifer

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.campaign_identifier (
  campaign_id INT,
  products VARCHAR(3),
  campaign_name VARCHAR(100),
  start_date TIMESTAMP,
  end_date TIMESTAMP
)
COMMENT 'The campaign identifier table stores the three campaigns run by Clique Bait so far'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/campaign_identifier/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```

#### Page Hierachy

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS clique_bait.page_hierarchy (
  page_id INT,
  page_name VARCHAR(50),
  product_category VARCHAR(50),
  product_id INT
)
COMMENT 'The page hierarchy table lists of all pages on the Clique Bait website'
STORED AS PARQUET
LOCATION 's3://sql-case-studies/clique_bait/page_hierarchy/'
TBLPROPERTIES ('classification'='parquet', 'parquet.compress'='SNAPPY');
```
