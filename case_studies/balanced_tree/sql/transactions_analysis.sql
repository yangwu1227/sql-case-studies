-- Question 1: How many unique transactions were there?
SELECT
    COUNT(DISTINCT txn_id) AS transactions_count
FROM
    balanced_tree.sales;

-- Question 2: What is the average unique products purchased in each transaction?
WITH
    product_count_per_txn AS (
        SELECT
            txn_id,
            COUNT(DISTINCT prod_id) AS product_count
        FROM
            balanced_tree.sales
        GROUP BY
            txn_id
    )
SELECT
    AVG(product_count) AS avg_unique_prod_per_txn
FROM
    product_count_per_txn;

-- Question 3: What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH
    rev_per_txn AS (
        SELECT
            txn_id,
            SUM(qty * (price * (1 - (discount / 100.0)))) AS rev
        FROM
            balanced_tree.sales
        GROUP BY
            txn_id
    )
SELECT
    APPROX_PERCENTILE (rev, 0.25) AS pct_25,
    APPROX_PERCENTILE (rev, 0.50) AS pct_50,
    AVG(rev) AS avg,
    APPROX_PERCENTILE (rev, 0.75) AS pct_75
FROM
    rev_per_txn;

-- Question 4: What is the average discount value per transaction?
WITH
    discount_per_txn AS (
        SELECT
            txn_id,
            SUM(qty * (price * (discount / 100.0))) AS discount
        FROM
            balanced_tree.sales
        GROUP BY
            txn_id
    )
SELECT
    APPROX_PERCENTILE (discount, 0.25) AS pct_25,
    APPROX_PERCENTILE (discount, 0.50) AS pct_50,
    AVG(discount) AS avg,
    APPROX_PERCENTILE (discount, 0.75) AS pct_75
FROM
    discount_per_txn;

-- Question 5: What is the percentage split of all transactions for members vs non-members?
SELECT
    SUM(
        CASE
            WHEN member = 't' THEN 1.0
            ELSE 0.0
        END
    ) / COUNT(*) * 100.0 AS pct_member,
    SUM(
        CASE
            WHEN member = 'f' THEN 1.0
            ELSE 0.0
        END
    ) / COUNT(*) * 100.0 AS pct_non_member
FROM
    balanced_tree.sales;

-- Question 6: What is the average revenue for member transactions and non-member transactions?
WITH
    rev AS (
        SELECT
            member,
            txn_id,
            SUM(qty * (price * (1 - (discount / 100.0)))) AS rev
        FROM
            balanced_tree.sales
        GROUP BY
            member,
            txn_id
    )
SELECT
    member,
    AVG(rev) AS avg_rev
FROM
    rev
GROUP BY
    member;
