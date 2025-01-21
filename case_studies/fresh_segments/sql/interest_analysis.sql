-- Question 1: Which interests have been present in all `month_year` dates in our dataset?
SELECT
    map.interest_name,
    COUNT(DISTINCT met.month_year) AS total_months
FROM
    fresh_segments.interest_metrics AS met
    LEFT JOIN fresh_segments.interest_map AS map ON met.interest_id = map.id
GROUP BY
    interest_name
HAVING
    COUNT(DISTINCT met.month_year) = (
        SELECT
            COUNT(DISTINCT month_year)
        FROM
            fresh_segments.interest_metrics
    )
ORDER BY
    interest_name ASC;

-- Question 2: Using this same `total_months` measure, calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the $90\%$ cumulative percentage value?
WITH
    count_month_year AS (
        SELECT
            interest_id,
            COUNT(DISTINCT month_year) AS total_months
        FROM
            fresh_segments.interest_metrics
        GROUP BY
            interest_id
    ),
    count_interest_by_total_months AS (
        SELECT
            total_months,
            COUNT(DISTINCT interest_id) AS interest_counts
        FROM
            count_month_year
        GROUP BY
            total_months
    )
SELECT
    total_months,
    interest_counts,
    ROUND(
        100.0 * SUM(interest_counts) OVER (
            ORDER BY
                total_months DESC ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
        ) / SUM(interest_counts) OVER (),
        2
    ) AS cumulative_percentage
FROM
    count_interest_by_total_months
ORDER BY
    total_months DESC;

-- Question 3: If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?
WITH
    interest_ids_to_remove AS (
        SELECT
            interest_id
        FROM
            fresh_segments.interest_metrics
        GROUP BY
            interest_id
        HAVING
            COUNT(DISTINCT month_year) < 6
    )
SELECT
    COUNT(met.interest_id) AS remove_row_count
FROM
    fresh_segments.interest_metrics AS met
    LEFT JOIN interest_ids_to_remove AS remove ON met.interest_id = remove.interest_id
WHERE
    1 = 1
    AND remove.interest_id IS NOT NULL;

-- Question 4: Does it make sense to remove these data points from a business perspective? Additionally, how many unique interests are represented in each month?
SELECT
    month_year,
    COUNT(DISTINCT interest_id) AS num_unique_interest
FROM
    fresh_segments.interest_metrics
GROUP BY
    month_year
ORDER BY
    num_unique_interest DESC;
