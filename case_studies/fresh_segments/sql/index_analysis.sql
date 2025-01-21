-- Question 1: What is the top 10 interests by the average composition for each month?
WITH
    ranked_avg_comp AS (
        SELECT
            met.month_year,
            map.interest_name,
            ROUND((met.composition / met.index_value), 2) AS avg_composition,
            DENSE_RANK() OVER (
                PARTITION BY
                    met.month_year
                ORDER BY
                    (met.composition / met.index_value) DESC
            ) AS ranks
        FROM
            fresh_segments.interest_metrics AS met
            LEFT JOIN fresh_segments.interest_map AS map ON met.interest_id = map.id
    )
SELECT
    month_year,
    interest_name,
    avg_composition,
    ranks
FROM
    ranked_avg_comp
WHERE
    1 = 1
    AND ranks <= 10
ORDER BY
    month_year ASC,
    avg_composition DESC;

-- Question 2: For all of these top 10 interests - which interest appears the most often?
WITH
    ranked_avg_comp AS (
        SELECT
            met.month_year,
            map.interest_name,
            ROUND((met.composition / met.index_value), 2) AS avg_composition,
            DENSE_RANK() OVER (
                PARTITION BY
                    met.month_year
                ORDER BY
                    (met.composition / met.index_value) DESC
            ) AS ranks
        FROM
            fresh_segments.interest_metrics AS met
            LEFT JOIN fresh_segments.interest_map AS map ON met.interest_id = map.id
    )
SELECT
    interest_name,
    COUNT(*) AS count
FROM
    ranked_avg_comp
WHERE
    1 = 1
    AND ranks <= 10
GROUP BY
    interest_name
ORDER BY
    count DESC;

-- Question 3: What is the average of the average composition for the top 10 interests for each month?
WITH
    ranked_avg_comp AS (
        SELECT
            met.month_year,
            map.interest_name,
            ROUND((met.composition / met.index_value), 2) AS avg_composition,
            DENSE_RANK() OVER (
                PARTITION BY
                    met.month_year
                ORDER BY
                    (met.composition / met.index_value) DESC
            ) AS ranks
        FROM
            fresh_segments.interest_metrics AS met
            LEFT JOIN fresh_segments.interest_map AS map ON met.interest_id = map.id
    )
SELECT
    month_year,
    AVG(avg_composition) AS avg_of_avg_composition
FROM
    ranked_avg_comp
WHERE
    1 = 1
    AND ranks <= 10
GROUP BY
    month_year
ORDER BY
    month_year ASC;

-- Question 4: What is the 3 month rolling average of the max average composition value from September 2018 to August 2019? 
WITH
    ranked_avg_comp_by_month AS (
        SELECT
            met.month_year,
            map.interest_name,
            ROUND((met.composition / met.index_value), 2) AS avg_composition,
            DENSE_RANK() OVER (
                PARTITION BY
                    met.month_year
                ORDER BY
                    CAST(met.composition AS DOUBLE) / CAST(met.index_value AS DOUBLE) DESC
            ) AS ranks
        FROM
            fresh_segments.interest_metrics AS met
            LEFT JOIN fresh_segments.interest_map AS map ON met.interest_id = map.id
    ),
    window_computations AS (
        SELECT
            month_year,
            interest_name,
            avg_composition AS max_avg_composition,
            ROUND(AVG(avg_composition) OVER w_3_months, 2) AS three_month_moving_avg,
            CASE
                WHEN LAG (avg_composition, 1) OVER w IS NULL THEN NULL
                ELSE CONCAT_WS (
                    ': ',
                    LAG (interest_name, 1) OVER w,
                    CAST(LAG (avg_composition, 1) OVER w AS VARCHAR)
                )
            END AS one_month_ago,
            CASE
                WHEN LAG (avg_composition, 2) OVER w IS NULL THEN NULL
                ELSE CONCAT_WS (
                    ': ',
                    LAG (interest_name, 2) OVER w,
                    CAST(LAG (avg_composition, 2) OVER w AS VARCHAR)
                )
            END AS two_months_ago
        FROM
            ranked_avg_comp_by_month
        WHERE
            1 = 1
            AND ranks = 1
        WINDOW
            w AS (
                ORDER BY
                    month_year ASC
            ),
            w_3_months AS (
                ORDER BY
                    month_year ASC ROWS BETWEEN 2 PRECEDING
                    AND CURRENT ROW
            )
    )
SELECT
    *
FROM
    window_computations
WHERE
    1 = 1
    AND (
        one_month_ago IS NOT NULL
        AND two_months_ago IS NOT NULL
    )
ORDER BY
    month_year ASC;
