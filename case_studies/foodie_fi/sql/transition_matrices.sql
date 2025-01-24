-- Probabilities 

WITH transitions AS (
    SELECT
        s.customer_id,
        s.start_date,
        LEAD(s.start_date, 1) OVER(PARTITION BY s.customer_id ORDER BY s.start_date ASC) AS next_start_date,
        p.plan_name,
        LEAD(p.plan_name, 1) OVER(PARTITION BY s.customer_id ORDER BY s.start_date ASC) AS next_plan_name
    FROM
        foodie_fi.subscriptions AS s
    LEFT JOIN
        foodie_fi.plans AS p
    ON
        s.plan_id = p.plan_id
),

transition_counts AS (
    SELECT
        plan_name,
        next_plan_name,
        COUNT(DISTINCT customer_id) AS transition_count
    FROM
        transitions
    WHERE
        next_plan_name IS NOT NULL
    GROUP BY
        plan_name, next_plan_name
),

row_totals AS (
    SELECT
        plan_name,
        SUM(transition_count) AS total_transitions
    FROM
        transition_counts
    GROUP BY
        plan_name
)

SELECT
    tc.plan_name,
    ROUND(COALESCE(SUM(CASE WHEN tc.next_plan_name = 'trial' THEN CAST(tc.transition_count AS DOUBLE) / rt.total_transitions END), 0), 4) AS trial,
    ROUND(COALESCE(SUM(CASE WHEN tc.next_plan_name = 'basic monthly' THEN CAST(tc.transition_count AS DOUBLE) / rt.total_transitions END), 0), 4) AS basic_monthly,
    ROUND(COALESCE(SUM(CASE WHEN tc.next_plan_name = 'pro monthly' THEN CAST(tc.transition_count AS DOUBLE) / rt.total_transitions END), 0), 4) AS pro_monthly,
    ROUND(COALESCE(SUM(CASE WHEN tc.next_plan_name = 'pro annual' THEN CAST(tc.transition_count AS DOUBLE) / rt.total_transitions END), 0), 4) AS pro_annual,
    ROUND(COALESCE(SUM(CASE WHEN tc.next_plan_name = 'churn' THEN CAST(tc.transition_count AS DOUBLE) / rt.total_transitions END), 0), 4) AS churn
FROM
    transition_counts AS tc
JOIN
    row_totals AS rt
ON
    tc.plan_name = rt.plan_name
GROUP BY
    tc.plan_name
ORDER BY
    tc.plan_name;

-- Counts

WITH transitions AS (
    SELECT
        s.customer_id,
        s.start_date,
        LEAD(s.start_date, 1) OVER(PARTITION BY customer_id ORDER BY s.start_date ASC) AS next_start_date,
        p.plan_name,
        LEAD(p.plan_name, 1) OVER(PARTITION BY customer_id ORDER BY s.start_date ASC) AS next_plan_name 
    FROM
        foodie_fi.subscriptions AS s 
            LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
),

transition_counts AS (
    SELECT
        plan_name,
        next_plan_name,
        COUNT(DISTINCT customer_id) AS transition_count
    FROM
        transitions
    WHERE
        next_plan_name IS NOT NULL
    GROUP BY
        plan_name, next_plan_name
)

SELECT
    plan_name,
    COALESCE(SUM(CASE WHEN next_plan_name = 'trial' THEN transition_count END), 0) AS trial,
    COALESCE(SUM(CASE WHEN next_plan_name = 'basic monthly' THEN transition_count END), 0) AS basic_monthly,
    COALESCE(SUM(CASE WHEN next_plan_name = 'pro monthly' THEN transition_count END), 0) AS pro_monthly,
    COALESCE(SUM(CASE WHEN next_plan_name = 'pro annual' THEN transition_count END), 0) AS pro_annual,
    COALESCE(SUM(CASE WHEN next_plan_name = 'churn' THEN transition_count END), 0) AS churn
FROM
    transition_counts
GROUP BY
    plan_name
ORDER BY
    plan_name;
