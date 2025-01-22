-- Question 1: What day of the week is used for each `week_date` value?
SELECT DISTINCT
    DAY_OF_WEEK (week_date) AS day_of_week
FROM
    data_mart.sales;

-- Question 2: What range of week numbers are missing from the dataset?
SELECT DISTINCT
    week_number
FROM
    data_mart.sales
ORDER BY
    week_number DESC;

-- Question 3: How many total `transactions` were there for each year in the dataset?
SELECT
    calendar_year,
    SUM(transactions) / 1000000.0 AS total_transactions_millions
FROM
    data_mart.sales
GROUP BY
    calendar_year
ORDER BY
    total_transactions_millions DESC;

-- Question 4: What is the total sales for each region for each month?
SELECT
    region,
    DATE_TRUNC ('MONTH', week_date) AS month_year,
    SUM(sales) / 1000000.0 AS total_sales_millions
FROM
    data_mart.sales
GROUP BY
    region,
    DATE_TRUNC ('MONTH', week_date)
ORDER BY
    region ASC,
    DATE_TRUNC ('MONTH', week_date) ASC;

-- Question 5: What is the total count of transactions for each platform?
SELECT
    platform,
    SUM(transactions) / 100000.0 AS total_transactions_millions
FROM
    data_mart.sales
GROUP BY
    platform
ORDER BY
    total_transactions_millions DESC;

-- Question 6: What is the percentage of sales for Retail vs Shopify for each month?
WITH
    sales_pct_by_platform AS (
        SELECT
            DATE_TRUNC ('MONTH', week_date) AS month_year,
            platform,
            SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (
                PARTITION BY
                    DATE_TRUNC ('MONTH', week_date)
            ) AS sales_pct
        FROM
            data_mart.sales
        GROUP BY
            DATE_TRUNC ('MONTH', week_date),
            platform
        ORDER BY
            DATE_TRUNC ('MONTH', week_date),
            platform
    )
SELECT
    month_year,
    MAX(
        CASE
            WHEN platform = 'Retail' THEN sales_pct
            ELSE NULL
        END
    ) AS retail,
    MAX(
        CASE
            WHEN platform = 'Shopify' THEN sales_pct
            ELSE NULL
        END
    ) AS shopify
FROM
    sales_pct_by_platform
GROUP BY
    month_year
ORDER BY
    month_year ASC;

-- CTE Approach
WITH
    monthly_totals AS (
        SELECT
            DATE_TRUNC ('MONTH', week_date) AS month_year,
            SUM(sales) AS total_sales
        FROM
            data_mart.sales
        GROUP BY
            DATE_TRUNC ('MONTH', week_date)
    ),
    sales_pct_by_platform AS (
        SELECT
            DATE_TRUNC ('MONTH', s.week_date) AS month_year,
            s.platform,
            SUM(s.sales) * 100.0 / t.total_sales AS sales_pct
        FROM
            data_mart.sales AS s
            INNER JOIN monthly_totals AS t ON DATE_TRUNC ('MONTH', s.week_date) = t.month_year
        GROUP BY
            DATE_TRUNC ('MONTH', s.week_date),
            s.platform,
            t.total_sales
        ORDER BY
            DATE_TRUNC ('MONTH', s.week_date),
            s.platform
    )
SELECT
    month_year,
    MAX(
        CASE
            WHEN platform = 'Retail' THEN sales_pct
            ELSE NULL
        END
    ) AS retail,
    MAX(
        CASE
            WHEN platform = 'Shopify' THEN sales_pct
            ELSE NULL
        END
    ) AS shopify
FROM
    sales_pct_by_platform
GROUP BY
    month_year
ORDER BY
    month_year ASC;

-- Question 7: What is the percentage of sales by demographic for each year in the dataset?
SELECT
    calendar_year,
    demographics,
    SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (
        PARTITION BY
            calendar_year
    ) AS sales_pct
FROM
    data_mart.sales
GROUP BY
    calendar_year,
    demographics
ORDER BY
    calendar_year,
    demographics;

-- Question 8: Which `age_band` and `demographic` values contribute the most to Retail sales?
-- Group by `age_band` and `demographics`
SELECT
    age_band,
    demographics,
    SUM(SUM(sales)) OVER (
        PARTITION BY
            age_band
    ) / 1000000.0 AS total_sales_millions_by_age_band,
    SUM(SUM(sales)) OVER (
        PARTITION BY
            demographics
    ) / 1000000.0 AS total_sales_millions_by_demographics,
    SUM(sales) / 1000000.0 AS total_sales_millions_by_age_demo
FROM
    data_mart.sales
WHERE
    1 = 1
    AND platform IN ('Retail')
GROUP BY
    age_band,
    demographics
ORDER BY
    age_band,
    demographics;

-- Group by `age_band` alone 
SELECT
    age_band,
    SUM(sales) / 1000000.0 AS total_sales_millions,
    SUM(sales) * 100.0 / SUM(SUM(sales)) OVER () AS sales_pct
FROM
    data_mart.sales
WHERE
    1 = 1
    AND platform IN ('Retail')
GROUP BY
    age_band
ORDER BY
    total_sales_millions DESC;

-- Group by `demographics` alone
SELECT
    demographics,
    SUM(sales) / 1000000.0 AS total_sales_millions,
    SUM(sales) * 100.0 / SUM(SUM(sales)) OVER () AS sales_pct
FROM
    data_mart.sales
WHERE
    1 = 1
    AND platform IN ('Retail')
GROUP BY
    demographics
ORDER BY
    total_sales_millions DESC;

-- Question 9: Can we use the `avg_transaction` column to find the average transaction size for each year for Retail vs Shopify? 
SELECT
    calendar_year,
    platform,
    ROUND(SUM(sales) / SUM(transactions), 2) AS avg_transaction
FROM
    data_mart.sales
GROUP BY
    calendar_year,
    platform
ORDER BY
    calendar_year,
    platform;
