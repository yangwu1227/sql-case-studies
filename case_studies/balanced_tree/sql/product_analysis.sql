-- Question 1: What are the top 3 products by total revenue before discount?

SELECT
    s.prod_id,
    d.product_name,
    FORMAT('$%,d', SUM(s.qty * s.price)) AS total_rev
FROM
    balanced_tree.sales AS s
        LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
GROUP BY
    s.prod_id,
    d.product_name
ORDER BY
    SUM(s.qty * s.price) DESC
LIMIT 
    3;

-- Question 2: What is the total quantity, revenue and discount for each segment?

SELECT
    d.segment_name,
    FORMAT('$%,d', SUM(s.qty * s.price)) AS total_rev,
    FORMAT('%,d', SUM(s.qty)) AS total_qty,
    FORMAT('$%,.2f', SUM(s.qty * s.price * (s.discount / 100.0))) AS total_discount
FROM
    balanced_tree.sales AS s
        LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
GROUP BY
    d.segment_name
ORDER BY
    d.segment_name;

-- Question 3: What is the top selling product for each segment?

WITH qty_sold AS (
    SELECT
        d.segment_name,
        d.product_name,
        SUM(s.qty) AS qty_sold
    FROM
        balanced_tree.sales AS s
            LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
    GROUP BY
        d.segment_name,
        d.product_name
),

ranked_data AS (
    SELECT
        segment_name,
        product_name,
        qty_sold,
        DENSE_RANK() OVER(PARTITION BY segment_name ORDER BY qty_sold DESC) AS ranks
    FROM
        qty_sold
)
SELECT
    segment_name,
    product_name,
    qty_sold
FROM
    ranked_data
WHERE
    1 = 1
    AND ranks <= 3
ORDER BY
    segment_name,
    qty_sold DESC;

-- Question 4: What is the total quantity, revenue and discount for each category?

SELECT
    d.category_name,
    FORMAT('$%,d', SUM(s.qty * s.price)) AS total_rev,
    FORMAT('%,d', SUM(s.qty)) AS total_qty,
    FORMAT('$%,.2f', SUM(s.qty * s.price * (s.discount / 100.0))) AS total_discount
FROM
    balanced_tree.sales AS s 
        LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
GROUP BY
    d.category_name
ORDER BY
    d.category_name DESC;

-- Question 5: What is the top selling product for each category?

WITH qty_sold AS (
    SELECT
        d.category_name,
        d.product_name,
        SUM(s.qty) AS qty_sold
    FROM
        balanced_tree.sales AS s
            LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
    GROUP BY
        d.category_name,
        d.product_name
),

ranked_data AS (
    SELECT
        category_name,
        product_name,
        qty_sold,
        DENSE_RANK() OVER(PARTITION BY category_name ORDER BY qty_sold DESC) AS ranks
    FROM
        qty_sold
)
SELECT
    category_name,
    product_name,
    qty_sold
FROM
    ranked_data
WHERE
    1 = 1
    AND ranks <= 3
ORDER BY
    category_name,
    qty_sold DESC;

-- Question 6: What is the percentage split of revenue by product for each segment?

WITH rev_data AS (
    SELECT
        d.segment_name,
        d.product_name,
        SUM(s.qty * (s.price * (1 - (s.discount / 100.0)))) AS rev
    FROM
        balanced_tree.sales AS s
            LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
    GROUP BY
        d.segment_name,
        d.product_name
)
SELECT
    segment_name,
    product_name,
    FORMAT('$%,.2f', rev) AS rev,
    CONCAT(
        FORMAT('%.2f', ROUND((rev / SUM(rev) OVER(PARTITION BY segment_name)) * 100.0, 2)), 
        '%'
    ) AS rev_pct_split
FROM
    rev_data
ORDER BY
    segment_name,
    product_name;

-- Question 7: What is the percentage split of revenue by segment for each category?

WITH rev_data AS (
    SELECT
        d.category_name,
        d.segment_name,
        SUM(s.qty * (s.price * (1 - (s.discount / 100.0)))) AS rev
    FROM
        balanced_tree.sales AS s
            LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
    GROUP BY
        d.category_name,
        d.d.segment_name
)
SELECT
    category_name,
    d.segment_name,
    FORMAT('$%,.2f', rev) AS rev,
    CONCAT(
        FORMAT('%.2f', ROUND((rev / SUM(rev) OVER(PARTITION BY category_name)) * 100.0, 2)), 
        '%'
    ) AS rev_pct_split
FROM
    rev_data
ORDER BY
    category_name,
    d.segment_name;

-- Question 8: What is the percentage split of total revenue by category?

SELECT
    d.category_name,
    FORMAT('$%,.2f', SUM(
        s.qty * (s.price * (1 - (s.discount / 100.0)))
    )) AS rev,
    CONCAT(
        FORMAT(
            '%.2f',
            ROUND(SUM(s.qty * (s.price * (1 - (s.discount / 100.0)))) / SUM(SUM(s.qty * (s.price * (1 - (s.discount / 100.0))))) OVER() * 100.0, 2)
        ),
        '%'
    ) AS rev_pct_split
FROM
    balanced_tree.sales AS s
        LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
GROUP BY
    d.category_name;

-- Question 9: What is the total transaction “penetration” for each product? 

SELECT
    s.prod_id,
    d.product_name,
    CONCAT(
        FORMAT('%.2f', TRY_CAST(COUNT(DISTINCT s.txn_id) AS DOUBLE) / TRY_CAST((SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales) AS DOUBLE) * 100.0),
        '%'
    ) AS penetration
FROM
    balanced_tree.sales AS s
        LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
GROUP BY
    s.prod_id,
    d.product_name
ORDER BY
    TRY_CAST(COUNT(DISTINCT s.txn_id) AS DOUBLE) / TRY_CAST((SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales) AS DOUBLE) DESC;

-- Double Pass CTE

WITH txn_by_prod AS (
    SELECT 
        prod_id,
        COUNT(DISTINCT txn_id) AS txn_count_by_product
    FROM 
        balanced_tree.sales
    GROUP BY 
        prod_id
),

total_txn AS (
    SELECT
        COUNT(DISTINCT txn_id) AS total_txn_count
    FROM 
        balanced_tree.sales
)
SELECT
    d.product_id,
    d.product_name,
    CONCAT(
        FORMAT('%.2f', TRY_CAST(t.txn_count_by_product AS DOUBLE) / TRY_CAST(total_t.total_txn_count AS DOUBLE) * 100.0),
        '%'
    ) AS penetration
FROM 
    txn_by_prod AS t
        CROSS JOIN total_txn AS total_t
        INNER JOIN balanced_tree.product_details AS d ON t.prod_id = d.product_id
ORDER BY 
    TRY_CAST(t.txn_count_by_product AS DOUBLE) / TRY_CAST(total_t.total_txn_count AS DOUBLE) DESC;

-- Question 10: What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

WITH RECURSIVE output_table (combo, product, product_counter) AS (

    -- === 1) BASE CASE ===

    SELECT
        ARRAY[CAST(d.product_id AS VARCHAR)]  AS combo,
        CAST(d.product_id AS VARCHAR)         AS product,
        1                                     AS product_counter
    FROM 
        balanced_tree.product_details AS d

    UNION ALL

    -- === 2) RECURSIVE STEP ===

    SELECT
        output_table.combo || ARRAY[CAST(d.product_id AS VARCHAR)]  AS combo,
        CAST(d.product_id AS VARCHAR)                               AS product,
        output_table.product_counter + 1                            AS product_counter
    FROM 
        output_table 
        INNER JOIN balanced_tree.product_details AS d ON d.product_id > output_table.product
    WHERE 
        output_table.product_counter < 3
),

cte_transaction_products (txn_id, products) AS (
    SELECT
        txn_id,
        ARRAY_AGG(CAST(s.prod_id AS VARCHAR)) AS products
    FROM 
        balanced_tree.sales AS s
    GROUP BY 
        txn_id
),

cte_combo_transactions (txn_id, combo, products) AS (
    SELECT
        tp.txn_id,
        combos.combo,
        tp.products
    FROM 
        cte_transaction_products AS tp
        CROSS JOIN (
            SELECT 
                combo
            FROM 
                output_table
            WHERE 
                product_counter = 3
        ) AS combos (combo)
    WHERE 
        CARDINALITY(ARRAY_INTERSECT(combos.combo, tp.products)) = CARDINALITY(combos.combo)
),

cte_ranked_combos (combo, transaction_count, combo_rank) AS (
    SELECT
        combo,
        COUNT(DISTINCT txn_id)                                  AS transaction_count,
        RANK() OVER (ORDER BY COUNT(DISTINCT txn_id) DESC)      AS combo_rank
    FROM 
        cte_combo_transactions
    GROUP BY 
        combo
),

cte_most_common_combo_product_transactions (txn_id, prod_id) AS (
    SELECT
        cct.txn_id,
        t.prod_id
    FROM 
        cte_combo_transactions AS cct
        INNER JOIN cte_ranked_combos AS crc ON cct.combo = crc.combo
        CROSS JOIN UNNEST(crc.combo) AS t(prod_id)
    WHERE 
        crc.combo_rank = 1
)

SELECT
    d.product_id                                                                    AS product_id,
    d.product_name                                                                  AS product_name,
    COUNT(DISTINCT s.txn_id)                                                        AS combo_transaction_count,
    SUM(s.qty)                                                                      AS quantity,
    FORMAT('$%,d', ROUND(SUM(s.qty * s.price), 2))                                  AS revenue_after_discount,
    FORMAT('$%,.2f', ROUND(SUM(s.qty * s.price * (s.discount / 100.0)), 2))         AS discount,
    FORMAT('$%,.2f', ROUND(SUM(s.qty * s.price * (1 - s.discount / 100.0)), 2))     AS net_revenue
FROM 
    balanced_tree.sales AS s
    INNER JOIN cte_most_common_combo_product_transactions AS top_combo ON s.txn_id = top_combo.txn_id AND s.prod_id = top_combo.prod_id
    INNER JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
GROUP BY
    d.product_id,
    d.product_name
ORDER BY
    combo_transaction_count DESC,
    d.product_id ASC;
