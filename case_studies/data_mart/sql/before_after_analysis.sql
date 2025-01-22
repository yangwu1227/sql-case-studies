-- Before and After (e.g. year = 2020 | weeks = 12 | intervention = 2020-06-15)
WITH
    before_after AS (
        SELECT
            CASE
                WHEN week_date < DATE '2020-06-15' THEN '1 before'
                WHEN week_date >= DATE '2020-06-15' THEN '2 after'
            END AS intervention,
            sales
        FROM
            data_mart.sales
        WHERE
            1 = 1
            AND week_date >= DATE_ADD ('WEEK', -12, DATE '2020-06-15')
            AND week_date < DATE_ADD ('WEEK', 12, DATE '2020-06-15')
    ),
    total_sales AS (
        SELECT
            intervention,
            SUM(sales) / 1000000.0 AS total_sales_millions,
            SUM(sales) * 100.0 / SUM(SUM(sales)) OVER () AS sales_pct
        FROM
            before_after
        GROUP BY
            intervention
    ),
    sales_metrics AS (
        SELECT
            intervention,
            total_sales_millions,
            sales_pct,
            100.0 * (
                (
                    total_sales_millions / LAG (total_sales_millions, 1) OVER (
                        ORDER BY
                            intervention
                    )
                ) - 1
            ) AS sales_pct_change,
            (
                total_sales_millions - LAG (total_sales_millions, 1) OVER (
                    ORDER BY
                        intervention
                )
            ) AS sales_difference_millions
        FROM
            total_sales
    )
SELECT
    MAX(
        CASE
            WHEN intervention = '1 before' THEN total_sales_millions
            ELSE NULL
        END
    ) AS total_sales_milllions_before,
    MAX(
        CASE
            WHEN intervention = '2 after' THEN total_sales_millions
            ELSE NULL
        END
    ) AS total_sales_milllions_after,
    MAX(
        CASE
            WHEN intervention = '1 before' THEN sales_pct
            ELSE NULL
        END
    ) AS sales_pct_before,
    MAX(
        CASE
            WHEN intervention = '2 after' THEN sales_pct
            ELSE NULL
        END
    ) AS sales_pct_after,
    MAX(
        CASE
            WHEN intervention = '2 after' THEN sales_pct_change
            ELSE NULL
        END
    ) AS sales_pct_change,
    MAX(
        CASE
            WHEN intervention = '2 after' THEN sales_difference_millions
            ELSE NULL
        END
    ) AS sales_difference_millions
FROM
    sales_metrics;

-- Before & After By Group (e.g. group = platform | year = 2020 | weeks = 12 | intervention = 2020-06-15)
WITH
    before_after AS (
        SELECT
            CASE
                WHEN week_date < DATE '2020-06-15' THEN '1 before'
                WHEN week_date >= DATE '2020-06-15' THEN '2 after'
            END AS intervention,
            sales,
            platform
        FROM
            data_mart.sales
        WHERE
            1 = 1
            AND week_date >= DATE_ADD ('WEEK', -12, DATE '2020-06-15')
            AND week_date < DATE_ADD ('WEEK', 12, DATE '2020-06-15')
    ),
    total_sales AS (
        SELECT
            platform,
            intervention,
            SUM(sales) / 1000000.0 AS total_sales_millions,
            SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (
                PARTITION BY
                    platform
            ) AS sales_pct
        FROM
            before_after
        GROUP BY
            platform,
            intervention
    ),
    sales_metrics AS (
        SELECT
            platform,
            intervention,
            total_sales_millions,
            sales_pct,
            100.0 * (
                (
                    total_sales_millions / LAG (total_sales_millions, 1) OVER (
                        PARTITION BY
                            platform
                        ORDER BY
                            intervention
                    )
                ) - 1
            ) AS sales_pct_change,
            (
                total_sales_millions - LAG (total_sales_millions, 1) OVER (
                    PARTITION BY
                        platform
                    ORDER BY
                        intervention
                )
            ) AS sales_difference_millions
        FROM
            total_sales
    )
SELECT
    platform,
    MAX(
        CASE
            WHEN intervention = '1 before' THEN total_sales_millions
            ELSE NULL
        END
    ) AS total_sales_millions_before,
    MAX(
        CASE
            WHEN intervention = '2 after' THEN total_sales_millions
            ELSE NULL
        END
    ) AS total_sales_millions_after,
    MAX(
        CASE
            WHEN intervention = '2 after' THEN sales_pct_change
            ELSE NULL
        END
    ) AS sales_pct_change,
    MAX(
        CASE
            WHEN intervention = '2 after' THEN sales_difference_millions
            ELSE NULL
        END
    ) AS sales_difference_millions
FROM
    sales_metrics
GROUP BY
    platform
ORDER BY
    platform;
