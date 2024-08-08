-- Question 1: How many unique nodes are there on the Data Bank system?

SELECT
  r.region_name AS region_name,
  cn.node_id AS node_id,
  COUNT(*) AS region_node_count
FROM
  data_bank.customer_nodes AS cn
LEFT JOIN data_bank.regions AS r 
ON cn.region_id = r.region_id
GROUP BY
  r.region_name, 
  cn.node_id
ORDER BY
  region_node_count DESC;

-- Question 2: What is the number of nodes per region?

SELECT
  cn.region_id AS region_id,
  r.region_name AS region_name,
  COUNT(DISTINCT cn.node_id) AS unique_node_count
FROM
  data_bank.customer_nodes AS cn
LEFT JOIN data_bank.regions AS r 
ON cn.region_id = r.region_id
GROUP BY
  cn.region_id,
  r.region_name
ORDER BY
  unique_node_count DESC;

-- Question 3: How many customers are allocated to each region?

SELECT
  r.region_name AS region_name,
  COUNT(DISTINCT cn.customer_id) AS unique_customer_count
FROM
  data_bank.customer_nodes AS cn
LEFT JOIN data_bank.regions AS r 
ON cn.region_id = r.region_id
GROUP BY
  r.region_name
ORDER BY 
  unique_customer_count DESC;

-- Question 4: How many days on average are customers reallocated to a different node?

WITH sanitized_dates AS (
  SELECT
    node_id,
    start_date,
    CASE
      WHEN end_date > CURRENT_DATE THEN CURRENT_DATE
      ELSE end_date
    END AS end_date
  FROM
    data_bank.customer_nodes
)
SELECT
  node_id,
  AVG(DATE_DIFF('day', start_date, end_date)) AS avg_day_at_node,
  AVG(DATE_DIFF('year', start_date, end_date)) AS avg_year_at_node
FROM
  sanitized_dates
GROUP BY
  node_id
ORDER BY 
  avg_day_at_node DESC;

-- Question 5: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH sanitized_dates AS (
  SELECT
    r.region_name AS region_name,
    cn.start_date AS start_date,
    CASE
      WHEN cn.end_date > CURRENT_DATE THEN CURRENT_DATE
      ELSE cn.end_date
    END AS end_date
  FROM
    data_bank.customer_nodes AS cn
  LEFT JOIN data_bank.regions AS r 
  ON cn.region_id = r.region_id
)
SELECT
  region_name,
  APPROX_PERCENTILE(DATE_DIFF('day', start_date, end_date), 0.5) AS median_days_at_node,
  APPROX_PERCENTILE(DATE_DIFF('day', start_date, end_date), 0.8) AS pct_80_days_at_node,
  APPROX_PERCENTILE(DATE_DIFF('day', start_date, end_date), 0.95) AS pct_95_days_at_node
FROM
  sanitized_dates
GROUP BY
  region_name
ORDER BY 
  region_name;
