-- Question 1: Unique count and total amount for each transaction type

SELECT
    txn_type AS transaction_type,
    COUNT(txn_type) AS total_count,
    SUM(txn_amount) AS total_amount
FROM
    data_bank.customer_transactions
GROUP BY
    txn_type
ORDER BY
    total_amount DESC;

-- Question 2: Average total historical deposit counts and amounts for all customers

WITH counts_data AS (
    SELECT
        COUNT(txn_type) AS deposit_count,
        SUM(txn_amount) AS deposit_amount
    FROM
        data_bank.customer_transactions
    WHERE
        txn_type = 'deposit'
    GROUP BY
        customer_id
)
SELECT
    ROUND(AVG(deposit_count)) AS avg_deposit_count,
    ROUND(SUM(deposit_amount) / SUM(deposit_count)) AS avg_deposit_amount
FROM
    counts_data;

-- Question 3: Monthly customer deposits and purchases/withdrawals

WITH counts_data AS (
    SELECT
        customer_id,
        MONTH(txn_date) AS txn_month,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
        SUM(CASE WHEN txn_type = 'purchase' OR txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS purchase_withdrawal_count
    FROM
        data_bank.customer_transactions
    GROUP BY
        MONTH(txn_date), customer_id
)
SELECT
    txn_month AS month,
    COUNT(DISTINCT customer_id) AS customer_count
FROM
    counts_data
WHERE
    deposit_count > 1 
    AND purchase_withdrawal_count > 0
GROUP BY
    txn_month
ORDER BY
    txn_month;

-- Question 4: Closing balance for each customer at the end of the month

WITH monthly_balances_cte AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', txn_date) AS txn_month,
        SUM(
            CASE 
                WHEN txn_type IS NULL THEN NULL
                WHEN txn_type = 'deposit' THEN txn_amount 
                ELSE -txn_amount
            END
        ) AS txn_amount_net
    FROM 
        data_bank.customer_transactions
    GROUP BY 
        customer_id, DATE_TRUNC('month', txn_date)
    ORDER BY 
        customer_id, DATE_TRUNC('month', txn_date)
),

first_second_months_cte AS (
  WITH min_txn_dates AS (
      SELECT 
          customer_id,
          DATE_TRUNC('month', MIN(txn_date)) AS min_txn_month
      FROM 
          data_bank.customer_transactions
      GROUP BY 
          customer_id
  )
  SELECT 
      customer_id, 
      DATE_ADD('month', month_offset, min_txn_month) AS txn_month, 
      month_offset + 1 AS month_number
  FROM 
      min_txn_dates,
      UNNEST(SEQUENCE(0, 1)) AS t (month_offset)
),

monthly_transactions_cte AS (
    SELECT
        first_second_months_cte.customer_id,
        first_second_months_cte.txn_month,
        first_second_months_cte.month_number,
        COALESCE(monthly_balances_cte.txn_amount_net, -999) AS second_month_txn_amount_net
    FROM 
        first_second_months_cte 
        LEFT JOIN 
            monthly_balances_cte 
        ON 
            first_second_months_cte.txn_month = monthly_balances_cte.txn_month
            AND first_second_months_cte.customer_id = monthly_balances_cte.customer_id
),

first_second_month_alignment_cte AS (
    SELECT
        customer_id,
        month_number,
        LAG(second_month_txn_amount_net) OVER (
            PARTITION BY customer_id
            ORDER BY txn_month
        ) AS first_month_txn_amount_net,
        second_month_txn_amount_net
    FROM 
        monthly_transactions_cte
),

calculations_cte AS (
    SELECT
        COUNT(DISTINCT customer_id) AS customer_count,
        SUM(CASE WHEN first_month_txn_amount_net > 0 THEN 1 ELSE 0 END) AS positive_first_month_count,
        SUM(CASE WHEN first_month_txn_amount_net < 0 THEN 1 ELSE 0 END) AS negative_first_month_count,
        SUM(CASE
                WHEN first_month_txn_amount_net > 0
                    AND second_month_txn_amount_net > 0
                    AND second_month_txn_amount_net > 1.05 * first_month_txn_amount_net
                THEN 1
                ELSE 0
            END
        ) AS second_month_5_pct_higher_count,
        SUM(
            CASE
                WHEN first_month_txn_amount_net > 0
                    AND second_month_txn_amount_net < 0
                    AND second_month_txn_amount_net < 0.95 * first_month_txn_amount_net
                THEN 1
                ELSE 0
            END
        ) AS second_month_5_pct_lower_count,
        SUM(
            CASE
            WHEN first_month_txn_amount_net > 0
                AND second_month_txn_amount_net < 0
                AND second_month_txn_amount_net < -first_month_txn_amount_net
                THEN 1
            ELSE 0 END
        ) AS positive_to_negative_count
    FROM 
        first_second_month_alignment_cte
    WHERE 
        first_month_txn_amount_net IS NOT NULL
        AND second_month_txn_amount_net <> -999
)
SELECT
  ROUND(100 * positive_first_month_count / customer_count, 2) AS positive_pct,
  ROUND(100 * negative_first_month_count / customer_count, 2) AS negative_pct,
  ROUND(100 * second_month_5_pct_higher_count / positive_first_month_count, 4) AS second_month_5_pct_higher_pct,
  ROUND(100 * second_month_5_pct_lower_count / positive_first_month_count, 4) AS second_month_5_pct_lower_pct,
  ROUND(100 * positive_to_negative_count / positive_first_month_count, 4) AS positive_to_negative_pct
FROM 
  calculations_cte;
