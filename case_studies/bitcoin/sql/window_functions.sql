-- Fill null values with lagged values

CREATE OR REPLACE VIEW updated_daily_btc AS
SELECT
    market_date,
    COALESCE(
        open_price,
        LAG(open_price, 1) OVER w,
        LAG(open_price, 2) OVER w
    ) AS open_price,
    COALESCE(
        high_price,
        LAG(high_price, 1) OVER w,
        LAG(high_price, 2) OVER w
    ) AS high_price,
    COALESCE(
        low_price,
        LAG(low_price, 1) OVER w,
        LAG(low_price, 2) OVER w
    ) AS low_price,
    COALESCE(
        close_price,
        LAG(close_price, 1) OVER w,
        LAG(close_price, 2) OVER w
    ) AS close_price,
    COALESCE(
        adjusted_close_price,
        LAG(adjusted_close_price, 1) OVER w,
        LAG(adjusted_close_price, 2) OVER w
    ) AS adjusted_close_price,
    COALESCE(
        volume,
        LAG(volume, 1) OVER w,
        LAG(volume, 2) OVER w
    ) AS volume
FROM 
    trading.daily_btc
WINDOW
    w AS (ORDER BY market_date);

-- Cumulative Volume

WITH volume_data AS (
    SELECT
        market_date,
        volume
    FROM 
      trading.updated_daily_btc
    ORDER BY 
      market_date
)
SELECT
  market_date,
  volume,
  SUM(volume) OVER (ORDER BY market_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sum
FROM 
  volume_data;

-- Weekly Volume

WITH window_calc AS (
    SELECT
        market_date,
        volume,
        AVG(volume) OVER (
            ORDER BY market_date 
            RANGE BETWEEN INTERVAL '7' DAY PRECEDING AND INTERVAL '1' DAY PRECEDING
        ) AS past_week_avg_volume
    FROM
        trading.updated_daily_btc
)
SELECT
    market_date,
    volume,
    past_week_avg_volume,
    CASE
        WHEN volume > past_week_avg_volume THEN 'Above Past Week Average'
        ELSE 'Below Past Week Average'
    END AS volume_trend
FROM
    window_calc
ORDER BY
    market_date DESC;

-- Moving Statistics

SELECT
    market_date,
    close_price,
    -- Moving Average
    ROUND(AVG(close_price) OVER w_14, 2) AS avg_14,
    ROUND(AVG(close_price) OVER w_28, 2) AS avg_28,
    ROUND(AVG(close_price) OVER w_60, 2) AS avg_60,
    ROUND(AVG(close_price) OVER w_150, 2) AS avg_150,
    -- Standard Deviation
    ROUND(STDDEV(close_price) OVER w_14, 2) AS std_14,
    ROUND(STDDEV(close_price) OVER w_28, 2) AS std_28,
    ROUND(STDDEV(close_price) OVER w_60, 2) AS std_60,
    ROUND(STDDEV(close_price) OVER w_150, 2) AS std_150,
    -- Max
    ROUND(MAX(close_price) OVER w_14, 2) AS max_14,
    ROUND(MAX(close_price) OVER w_28, 2) AS max_28,
    ROUND(MAX(close_price) OVER w_60, 2) AS max_60,
    ROUND(MAX(close_price) OVER w_150, 2) AS max_150,
    -- Min
    ROUND(MIN(close_price) OVER w_14, 2) AS min_14,
    ROUND(MIN(close_price) OVER w_28, 2) AS min_28,
    ROUND(MIN(close_price) OVER w_60, 2) AS min_60,
    ROUND(MIN(close_price) OVER w_150, 2) AS min_150
FROM 
    trading.updated_daily_btc
WINDOW
    w_14 AS (ORDER BY market_date RANGE BETWEEN INTERVAL '14' DAY PRECEDING AND INTERVAL '1' DAY PRECEDING),
    w_28 AS (ORDER BY market_date RANGE BETWEEN INTERVAL '28' DAY PRECEDING AND INTERVAL '1' DAY PRECEDING),
    w_60 AS (ORDER BY market_date RANGE BETWEEN INTERVAL '60' DAY PRECEDING AND INTERVAL '1' DAY PRECEDING),
    w_150 AS (ORDER BY market_date RANGE BETWEEN INTERVAL '150' DAY PRECEDING AND INTERVAL '1' DAY PRECEDING)
ORDER BY 
    market_date ASC;

-- Weighted Moving Average

WITH window_calc AS (
    SELECT
        market_date,
        ROUND(close_price, 2) AS close_price,
        -- Moving Average
        ROUND(AVG(close_price) OVER w_1_14, 2) AS avg_1_14,
        ROUND(AVG(close_price) OVER w_15_28, 2) AS avg_15_28,
        ROUND(AVG(close_price) OVER w_29_60, 2) AS avg_29_60,
        ROUND(AVG(close_price) OVER w_61_150, 2) AS avg_61_150
    FROM
        trading.updated_daily_btc
    WINDOW
        w_1_14 AS (ORDER BY market_date RANGE BETWEEN INTERVAL '14' DAY PRECEDING AND INTERVAL '1' DAY PRECEDING),
        w_15_28 AS (ORDER BY market_date RANGE BETWEEN INTERVAL '28' DAY PRECEDING AND INTERVAL '15' DAY PRECEDING),
        w_29_60 AS (ORDER BY market_date RANGE BETWEEN INTERVAL '60' DAY PRECEDING AND INTERVAL '29' DAY PRECEDING),
        w_61_150 AS (ORDER BY market_date RANGE BETWEEN INTERVAL '150' DAY PRECEDING AND INTERVAL '61' DAY PRECEDING)
)
SELECT
    market_date,
    close_price,
    (0.5 * avg_1_14 + 0.3 * avg_15_28 + 0.15 * avg_29_60 + 0.05 * avg_61_150) AS weighted_avg
FROM
    window_calc
ORDER BY
    market_date ASC;
