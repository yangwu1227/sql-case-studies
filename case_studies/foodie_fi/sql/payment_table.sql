-- Generate lead plans with next plan and next start date

WITH lead_plans AS (
    SELECT
        customer_id,
        plan_id,
        start_date,
        LEAD (plan_id) OVER (
            PARTITION BY
                customer_id
            ORDER BY
                start_date
        ) AS lead_plan_id,
        LEAD (start_date) OVER (
            PARTITION BY
                customer_id
            ORDER BY
                start_date
        ) AS lead_start_date
    FROM
        foodie_fi.subscriptions
    WHERE
        year (start_date) = 2020
        AND plan_id != 0
),

-- Case 1: Non-churn monthly customers

case_1 AS (
    SELECT
        customer_id,
        plan_id,
        start_date,
        DATE_DIFF('MONTH', start_date, DATE '2020-12-31') AS month_diff
    FROM
        lead_plans
    WHERE
        lead_plan_id IS NULL
        AND plan_id NOT IN (3, 4) -- Exclude churn and annual plans
),

-- Generate payments for case 1 customers

case_1_payments AS (
    SELECT
        customer_id,
        plan_id,
        DATE_ADD('MONTH', seq, start_date) AS payment_date
    FROM
        case_1
        CROSS JOIN UNNEST (SEQUENCE (0, month_diff)) AS t (seq)
),

-- Case 2: Churn customers

case_2 AS (
    SELECT
        customer_id,
        plan_id,
        start_date,
        DATE_DIFF(
            'MONTH',
            start_date,
            DATE_ADD('DAY', -1, lead_start_date)
        ) AS month_diff
    FROM
        lead_plans
    WHERE
        lead_plan_id = 4 -- Churn plans only
),

-- Generate payments for churn customers

case_2_payments AS (
    SELECT
        customer_id,
        plan_id,
        DATE_ADD('MONTH', seq, start_date) AS payment_date
    FROM
        case_2
        CROSS JOIN UNNEST (SEQUENCE (0, month_diff)) AS t (seq)
),

-- Case 3: Customers who move from basic to pro plans

case_3 AS (
    SELECT
        customer_id,
        plan_id,
        start_date,
        DATE_DIFF(
            'MONTH',
            start_date,
            DATE_ADD('DAY', -1, lead_start_date)
        ) AS month_diff
    FROM
        lead_plans
    WHERE
        plan_id = 1
        AND lead_plan_id IN (2, 3)
),

-- Generate payments for case 3 customers

case_3_payments AS (
    SELECT
        customer_id,
        plan_id,
        DATE_ADD('MONTH', seq, start_date) AS payment_date
    FROM
        case_3
        CROSS JOIN UNNEST (SEQUENCE (0, month_diff)) AS t (seq)
),

-- Case 4: Pro monthly customers who upgrade to annual plans

case_4 AS (
    SELECT
        customer_id,
        plan_id,
        start_date,
        DATE_DIFF(
            'MONTH',
            start_date,
            DATE_ADD('DAY', -1, lead_start_date)
        ) AS month_diff
    FROM
        lead_plans
    WHERE
        plan_id = 2
        AND lead_plan_id = 3
),

-- Generate payments for case 4 customers

case_4_payments AS (
    SELECT
        customer_id,
        plan_id,
        DATE_ADD('MONTH', seq, start_date) AS payment_date
    FROM
        case_4
        CROSS JOIN UNNEST (SEQUENCE (0, month_diff)) AS t (seq)
),

-- Case 5: Annual pro payments

case_5_payments AS (
    SELECT
        customer_id,
        plan_id,
        start_date AS payment_date
    FROM
        lead_plans
    WHERE
        plan_id = 3
),

-- Union all payment cases

union_output AS (
    SELECT
        *
    FROM
        case_1_payments
    UNION ALL
    SELECT
        *
    FROM
        case_2_payments
    UNION ALL
    SELECT
        *
    FROM
        case_3_payments
    UNION ALL
    SELECT
        *
    FROM
        case_4_payments
    UNION ALL
    SELECT
        *
    FROM
        case_5_payments
)

-- Final output with pricing adjustments and payment order

SELECT
    uo.customer_id,
    p.plan_id,
    p.plan_name,
    uo.payment_date,

    -- Apply price deductions for basic to pro upgrades
    
    CASE
        WHEN uo.plan_id IN (2, 3) AND LAG (uo.plan_id, 1) OVER w = 1 THEN p.price - 9.90
        ELSE p.price
    END AS amount,

    ROW_NUMBER() OVER w AS payment_order
FROM
    union_output AS uo
    INNER JOIN foodie_fi.plans AS p ON uo.plan_id = p.plan_id
WINDOW
    w AS (
        PARTITION BY
            uo.customer_id
        ORDER BY
            uo.payment_date
    )
ORDER BY
    uo.customer_id,
    uo.payment_date;
