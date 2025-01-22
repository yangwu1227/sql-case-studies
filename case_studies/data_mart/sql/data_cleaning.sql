SELECT
    week_date,
    CAST(CEIL(DAY_OF_YEAR (week_date) / 7.0) AS INTEGER) AS week_number,
    EXTRACT(
        MONTH
        FROM
            week_date
    ) AS month_number,
    EXTRACT(
        YEAR
        FROM
            week_date
    ) AS calendar_year,
    COALESCE(segment, 'Unknown') AS segment,
    CASE
        WHEN SUBSTRING(segment, -1, 1) = '1' THEN 'Young Adults'
        WHEN SUBSTRING(segment, -1, 1) = '2' THEN 'Middle Aged'
        WHEN SUBSTRING(segment, -1, 1) IN ('3', '4') THEN 'Retirees'
        ELSE 'Unknown'
    END AS age_band,
    CASE
        WHEN SUBSTRING(segment, 1, 1) = 'C' THEN 'Couples'
        WHEN SUBSTRING(segment, 1, 1) = 'F' THEN 'Families'
        ELSE 'Unknown'
    END AS demographics,
    region,
    platform,
    customer_type,
    transactions,
    ROUND(sales / transactions, 2) AS avg_transaction,
    sales
FROM
    data_mart.weekly_sales;
