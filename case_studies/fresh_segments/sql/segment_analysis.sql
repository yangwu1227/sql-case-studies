-- Question 1: Using the complete dataset - which are the top 10 and bottom 10 interests that have the largest composition values in any `month_year`? Only use the **maximum composition value** for each interest but keep the corresponding `month_year`.
WITH
    compositions AS (
        SELECT
            map.interest_name,
            met.month_year,
            met.composition,
            DENSE_RANK() OVER (
                PARTITION BY
                    map.interest_name
                ORDER BY
                    met.composition DESC
            ) AS comp_ranks
        FROM
            fresh_segments.interest_metrics AS met
            LEFT JOIN fresh_segments.interest_map AS map ON met.interest_id = map.id
    ),
    top_10 AS (
        SELECT
            interest_name,
            month_year,
            composition,
            'top_10' AS rank
        FROM
            compositions
        WHERE
            comp_ranks = 1
        ORDER BY
            composition DESC
        LIMIT
            10
    ),
    bottom_10 AS (
        SELECT
            interest_name,
            month_year,
            composition,
            'bottom_10' AS rank
        FROM
            compositions
        WHERE
            comp_ranks = 1
        ORDER BY
            composition ASC
        LIMIT
            10
    ),
    row_bind AS (
        SELECT
            *
        FROM
            top_10
        UNION
        SELECT
            *
        FROM
            bottom_10
    )
SELECT
    *
FROM
    row_bind
ORDER BY
    rank DESC,
    composition DESC;

-- Question 2: Which 5 interests had the lowest average `ranking` value?
SELECT
    map.interest_name,
    AVG(met.ranking) AS avg_ranking,
    COUNT(*) AS n
FROM
    fresh_segments.interest_metrics AS met
    LEFT JOIN fresh_segments.interest_map AS map ON met.interest_id = map.id
GROUP BY
    map.interest_name
ORDER BY
    avg_ranking DESC
LIMIT
    5;

-- Question 3: Which 5 interests had the largest standard deviation in their `percentile_ranking` value?
SELECT
    met.interest_id,
    map.interest_name,
    STDDEV (met.percentile_ranking) AS pct_ranking_std,
    MIN(met.percentile_ranking) AS pct_ranking_min,
    APPROX_PERCENTILE (met.percentile_ranking, 0.25) AS pct_ranking_25,
    APPROX_PERCENTILE (met.percentile_ranking, 0.50) AS pct_ranking_50,
    APPROX_PERCENTILE (met.percentile_ranking, 0.75) AS pct_ranking_75,
    MAX(met.percentile_ranking) AS pct_ranking_max,
    COUNT(*) AS n
FROM
    fresh_segments.interest_metrics AS met
    LEFT JOIN fresh_segments.interest_map AS map ON met.interest_id = map.id
GROUP BY
    met.interest_id,
    map.interest_name
ORDER BY
    pct_ranking_std DESC
LIMIT
    5;

-- Question 4: For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest and its corresponding `year_month` value? Can you describe what is happening for these 5 interests?
WITH
    ranked_data AS (
        SELECT
            interest_id,
            month_year,
            composition,
            ranking,
            percentile_ranking,
            DENSE_RANK() OVER (
                PARTITION BY
                    interest_id
                ORDER BY
                    percentile_ranking DESC
            ) AS percentile_ranking_max,
            DENSE_RANK() OVER (
                PARTITION BY
                    interest_id
                ORDER BY
                    percentile_ranking ASC
            ) AS percentile_ranking_min
        FROM
            fresh_segments.interest_metrics
        WHERE
            1 = 1
            AND interest_id IN (
                SELECT
                    interest_id
                FROM
                    fresh_segments.interest_metrics
                GROUP BY
                    interest_id
                ORDER BY
                    STDDEV (percentile_ranking) DESC
                LIMIT
                    5
            )
    )
SELECT
    interest_id,
    month_year,
    composition,
    ranking,
    percentile_ranking
FROM
    ranked_data
WHERE
    1 = 1
    AND (
        percentile_ranking_max = 1
        OR percentile_ranking_min = 1
    );
