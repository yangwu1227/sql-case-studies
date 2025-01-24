-- Question 1: How many customers has Foodie-Fi ever had?

SELECT
    COUNT(DISTINCT customer_id) AS customer_count
FROM
    foodie_fi.subscriptions;

-- Question 2: What is the monthly distribution of trial plan `start_date` values for our dataset?

SELECT
    DATE_TRUNC('MONTH', start_date) AS month_year,
    COUNT(DISTINCT customer_id) AS count
FROM
    foodie_fi.subscriptions AS s
        LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
WHERE
    1 = 1
    AND p.plan_name = 'trial'
GROUP BY
    DATE_TRUNC('MONTH', start_date)
ORDER BY
    DATE_TRUNC('MONTH', start_date) ASC;

-- Question 3: What plan `start_date` values occur after the year 2020 for the dataset? Show the breakdown by count of events for each `plan_name`.

SELECT
    p.plan_name,
    COUNT(*) AS events
FROM
    foodie_fi.subscriptions AS s 
        LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
WHERE
    EXTRACT(YEAR FROM s.start_date) > 2020
GROUP BY
    p.plan_name
ORDER BY
    events DESC;

-- Question 4: What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
    SUM(CASE WHEN p.plan_name = 'churn' THEN 1.0 ELSE 0.0 END) AS count_churned,
    ROUND((SUM(CASE WHEN p.plan_name = 'churn' THEN 1.0 ELSE 0.0 END) / COUNT(DISTINCT s.customer_id)) * 100.0, 1) AS pct_churned
FROM
    foodie_fi.subscriptions AS s
        LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id;

-- Question 5: How many customers have churned straight after their initial free trial - what percentage is this rounded to 1 decimal place?

WITH customer_journeys AS (
    SELECT
        s.customer_id,
        ARRAY_AGG(p.plan_name ORDER BY s.start_date ASC) AS plan_progression,
        ARRAY['trial', 'churn'] AS churn_pattern
    FROM
        foodie_fi.subscriptions AS s
            LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    GROUP BY
        s.customer_id
)

SELECT
    COUNT(DISTINCT customer_id) AS churn_after_trial_count,
    (CAST(COUNT(DISTINCT customer_id) AS DOUBLE) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)) * 100.0 AS churn_after_trial_pct
FROM
    customer_journeys
WHERE
    1 = 1
    AND CARDINALITY(plan_progression) = 2
    AND CARDINALITY(ARRAY_INTERSECT(churn_pattern, plan_progression)) = CARDINALITY(churn_pattern);

-- Window function approach

WITH ranked_data AS (
    SELECT
        s.customer_id,
        p.plan_name,
        RANK() OVER(PARTITION BY s.customer_id ORDER BY s.start_date ASC) AS ranks
    FROM
        foodie_fi.subscriptions AS s
            LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
)
SELECT
    SUM(CASE WHEN plan_name = 'churn' THEN 1.0 ELSE 0.0 END) AS churn_after_trial_count,
    (SUM(CASE WHEN plan_name = 'churn' THEN 1.0 ELSE 0.0 END) / COUNT(DISTINCT customer_id)) * 100.0 AS churn_after_trial_pct
FROM
    ranked_data
WHERE
    1 = 1
    AND ranks = 2;

-- Question 6: What is the number and percentage of customer plans after their initial free trial?

WITH ranked_data AS (
    SELECT
        s.customer_id,
        p.plan_name,
        RANK() OVER(PARTITION BY s.customer_id ORDER BY s.start_date ASC) AS ranks
    FROM
        foodie_fi.subscriptions AS s
            LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
)
SELECT
    plan_name,
    COUNT(DISTINCT customer_id) AS customer_count,
    CAST(COUNT(DISTINCT customer_id) AS DOUBLE) / SUM(COUNT(DISTINCT customer_id)) OVER() * 100.0 AS customer_pct
FROM
    ranked_data
WHERE
    1 = 1
    AND ranks = 2
GROUP BY
    plan_name
ORDER BY
    customer_count DESC;

-- Question 7: What is the customer count and percentage breakdown of all 5 `plan_name` values at `2020-12-31`?

WITH ranked_start_dates AS (
    SELECT
        s.customer_id,
        p.plan_name,
        RANK() OVER(PARTITION BY s.customer_id ORDER BY s.start_date DESC) AS ranks
    FROM
        foodie_fi.subscriptions AS s
            LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    WHERE
        1 = 1
        AND s.start_date <= DATE '2020-12-31'
)
SELECT
    plan_name,
    COUNT(DISTINCT customer_id) AS customer_count,
    CAST(COUNT(DISTINCT customer_id) AS DOUBLE) / SUM(COUNT(DISTINCT customer_id)) OVER() * 100.0 AS customer_pct
FROM
    ranked_start_dates
WHERE
    1 = 1
    AND ranks = 1
GROUP BY
    plan_name
ORDER BY
    customer_count DESC;

-- Question 8: How many customers have upgraded to an annual plan in 2020?

SELECT
    COUNT(DISTINCT customer_id) AS upgrades_to_annual
FROM
    foodie_fi.subscriptions AS s 
        LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
WHERE
    1 = 1
    AND EXTRACT(YEAR FROM s.start_date) = 2020
    AND p.plan_name = 'pro annual';

-- Question 9: How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH customer_journeys AS (
    SELECT
        s.customer_id,
        MIN(s.start_date) AS first_update_date
    FROM
        foodie_fi.subscriptions AS s
            LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    WHERE
        1 = 1
        AND p.plan_name = 'pro annual'
    GROUP BY
        s.customer_id
),

customer_start_dates AS (
    SELECT
        customer_id,
        MIN(start_date) AS joined_date
    FROM
        foodie_fi.subscriptions
    GROUP BY
        customer_id
)

SELECT
    AVG(DATE_DIFF('DAY', csd.joined_date, cj.first_update_date)) AS avg_days_to_upgrade
FROM
    customer_journeys AS cj
        LEFT JOIN customer_start_dates AS csd ON cj.customer_id = csd.customer_id;

-- Question 10: Further breakdown the average value computed above into 30 day periods (i.e. 0-30 days, 31-60 days etc).

WITH customer_journeys AS (
    SELECT
        s.customer_id,
        MIN(s.start_date) AS first_update_date
    FROM
        foodie_fi.subscriptions AS s
            LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
    WHERE
        1 = 1
        AND p.plan_name = 'pro annual'
    GROUP BY
        s.customer_id
),

customer_start_dates AS (
    SELECT
        customer_id,
        MIN(start_date) AS joined_date
    FROM
        foodie_fi.subscriptions
    GROUP BY
        customer_id
),

diff_bins AS (
    SELECT
        DATE_DIFF('DAY', csd.joined_date, cj.first_update_date) AS day_diff,
        FLOOR(DATE_DIFF('DAY', csd.joined_date, cj.first_update_date) / 30) AS bin_number
    FROM
        customer_journeys AS cj
            LEFT JOIN customer_start_dates AS csd ON cj.customer_id = csd.customer_id
)

SELECT
    CONCAT(CAST(bin_number * 30 AS VARCHAR), ' - ', CAST((bin_number + 1) * 30 - 1 AS VARCHAR), ' days') AS breakdown_period,
    COUNT(*) as count
FROM
    diff_bins
GROUP BY
    bin_number
ORDER BY
    bin_number;

-- Question 11: How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH ranked_data AS (
    SELECT
        s.customer_id,
        s.start_date,
        p.plan_name,
        LAG(p.plan_name, 1) OVER(PARTITION BY customer_id ORDER BY s.start_date ASC) AS previous_plan_name 
    FROM
        foodie_fi.subscriptions AS s 
            LEFT JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
)
SELECT
    COUNT(DISTINCT customer_id) AS downgrades_count
FROM
    ranked_data
WHERE
    1 = 1
    AND plan_name = 'basic monthly'
    AND previous_plan_name = 'pro monthly'
    AND EXTRACT(YEAR FROM start_date) = 2020;
