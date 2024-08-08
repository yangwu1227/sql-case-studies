-- Question 1: Earliest and latest market_date values

SELECT 
    MAX(market_date) AS max_date,
    MIN(market_date) AS min_date,
    -- DATE_DIFF('day', MIN(market_date), MAX(market_date)) AS days_difference,
    -- DATE_DIFF('month', MIN(market_date), MAX(market_date)) AS months_difference,
    -- DATE_DIFF('year', MIN(market_date), MAX(market_date)) AS years_difference
    AGE(MAX(market_date), MIN(market_date)) AS date_range
FROM
    trading.daily_btc;

-- Question 2: Historic all-time high and low values for the close_price and their dates

-- Using UNION ALL

(
  SELECT
    market_date,
    close_price 
  FROM
    trading.daily_btc
  ORDER BY
    close_price DESC NULLS LAST
  LIMIT
    1
)
UNION ALL
(
  SELECT
    market_date,
    close_price 
  FROM
    trading.daily_btc
  ORDER BY
    close_price ASC NULLS LAST
  LIMIT
    1
);

-- Using Window Function

WITH btc_data AS (
  SELECT
    market_date,
    close_price,
    RANK() OVER (ORDER BY close_price ASC NULLS LAST) AS min_close_price_rank,
    RANK() OVER (ORDER BY close_price DESC NULLS LAST) AS max_close_price_rank
  FROM
    trading.daily_btc
)
SELECT
  market_date,
  close_price
FROM
  btc_data
WHERE
  1 IN (min_close_price_rank, max_close_price_rank)
ORDER BY
  close_price DESC;

-- Question 3: Date with the most volume traded and its close_price

WITH btc_data AS (
  SELECT
    market_date,
    close_price,
    volume,
    RANK() OVER (ORDER BY volume DESC NULLS LAST) AS volume_rank
  FROM
    trading.daily_btc
)
SELECT
  market_date,
  close_price,
  volume
FROM
  btc_data
WHERE 
  volume_rank = 1
ORDER BY
  volume DESC;

-- Question 4: Number of days with a low_price that was 10% less than the open_price

WITH counts_data AS (
  SELECT
    SUM(
      CASE
        WHEN low_price < 0.9 * open_price THEN 1 ELSE 0
      END
    ) AS num_days_lower,
    COUNT(*) AS total_days
  FROM
    trading.daily_btc
  WHERE
    volume IS NOT NULL
)
SELECT
  num_days_lower,
  ROUND(100 * num_days_lower / total_days) AS pct
FROM
  counts_data;

-- Question 5: Percentage of days with a higher close_price than open_price

SELECT
  ROUND(AVG(
    CASE
      WHEN close_price IS NULL OR open_price IS NULL THEN NULL
      WHEN close_price > open_price THEN 1
      ELSE 0
    END
  ), 4) AS pct_closer_greater_open
FROM
  trading.daily_btc;

-- Question 6: Largest difference between high_price and low_price and the date it occurred

SELECT
  market_date,
  high_price,
  low_price,
  (high_price - low_price) AS diff
FROM
  trading.daily_btc
ORDER BY
  (high_price - low_price) DESC NULLS LAST
LIMIT 1;

-- Question 7: Investment worth from 1st January 2016 to 1st of February 2021

-- Step 1: Calculate start_value, end_value, and years

SELECT
  MAX(CASE WHEN market_date = DATE '2016-01-01' THEN close_price END) AS start_value,
  MAX(CASE WHEN market_date = DATE '2021-02-01' THEN close_price END) AS end_value,
  -- DATE_DIFF('day', DATE '2016-01-01', DATE '2021-02-01') / 365.25 AS years
  EXTRACT(EPOCH FROM AGE(DATE '2021-02-01', DATE '2016-01-01')) / (365.25 * 24 * 60 * 60) AS years
FROM
  trading.daily_btc;

-- Step 2: Calculate CAGR and final investment value

WITH start_end_values AS (
  SELECT
    MAX(CASE WHEN market_date = DATE '2016-01-01' THEN close_price END) AS start_value,
    MAX(CASE WHEN market_date = DATE '2021-02-01' THEN close_price END) AS end_value,
    -- DATE_DIFF('day', DATE '2016-01-01', DATE '2021-02-01') / 365.25 AS years
    EXTRACT(EPOCH FROM AGE(DATE '2021-02-01', DATE '2016-01-01')) / (365.25 * 24 * 60 * 60) AS years 
  FROM
    trading.daily_btc
)
SELECT
  ROUND(POWER((end_value / start_value), 1.0 / years) - 1, 4) AS cagr,
  ROUND(10000 * POWER((1 + (POWER((end_value / start_value), 1.0 / years) - 1)), years), 4) AS final_value
FROM
  start_end_values;
