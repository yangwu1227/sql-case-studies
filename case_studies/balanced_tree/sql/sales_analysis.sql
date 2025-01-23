-- Question 1: What was the total quantity sold for all products?
SELECT
    s.prod_id,
    d.product_name,
    SUM(s.qty) AS total_qty
FROM
    balanced_tree.sales AS s
    LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
GROUP BY
    s.prod_id,
    d.product_name
ORDER BY
    total_qty DESC;

-- Question 2: What is the total generated revenue for all products before discounts?
SELECT
    FORMAT ('$%,d', SUM(qty * price)) AS total_rev_before_discount
FROM
    balanced_tree.sales;

-- Question 3: What was the total discount amount for all products?
-- By Product
SELECT
    s.prod_id,
    d.product_name,
    SUM(s.qty * s.price * (s.discount / 100.0)) AS discount_amt
FROM
    balanced_tree.sales AS s
    LEFT JOIN balanced_tree.product_details AS d ON s.prod_id = d.product_id
GROUP BY
    s.prod_id,
    d.product_name
ORDER BY
    discount_amt DESC;

-- Total Discount Amount
SELECT
    FORMAT ('$%,.2f', SUM(qty * price * (discount / 100.0))) AS total_discount_amt
FROM
    balanced_tree.sales;
