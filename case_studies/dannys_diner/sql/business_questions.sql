-- Question 1: Total amount spent by each customer

SELECT
  s.customer_id AS customer_id,
  SUM(m.price) AS total_spent
FROM
  dannys_diner.sales AS s
  LEFT JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY
  s.customer_id
ORDER BY 
  total_spent DESC;

-- Question 2: Number of days each customer visited the restaurant

SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS num_visits
FROM
  dannys_diner.sales
GROUP BY
  customer_id
ORDER BY
  num_visits DESC;

-- Question 3: First item purchased by each customer

WITH sales_data AS (
  SELECT
    s.customer_id AS customer_id,
    RANK() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date
    ) AS rank_number,
    s.order_date AS order_date,
    m.product_name AS product_name
  FROM
    dannys_diner.sales AS s
    LEFT JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
)
SELECT
  customer_id,
  order_date,
  product_name
FROM
  sales_data
WHERE
  rank_number = 1
ORDER BY
  customer_id;

-- Question 4: Most purchased item on the menu

SELECT
  m.product_name AS product_name,
  COUNT(m.product_name) AS times_purchased
FROM
  dannys_diner.sales AS s
  LEFT JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY
  m.product_name
ORDER BY
  times_purchased DESC
LIMIT 1;

-- Question 5: Most popular item for each customer

WITH ranked_sales AS (
    SELECT
        s.customer_id AS customer_id,
        m.product_name AS product_name,
        COUNT(m.product_name) AS times_purchased,
        RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY COUNT(m.product_name) DESC
        ) AS rank_number
    FROM
        dannys_diner.sales AS s
        LEFT JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id, m.product_name
)
SELECT
    customer_id,
    product_name,
    times_purchased
FROM
    ranked_sales
WHERE
    rank_number = 1
ORDER BY
    customer_id;

-- Question 6: First item purchased after becoming a member

WITH ranked_sales AS (
  SELECT
    s.customer_id AS customer_id,
    s.order_date AS order_date,
    menu.product_name AS product_name,
    RANK() OVER (
      PARTITION BY s.customer_id
      ORDER BY order_date ASC
    ) AS rank_number
  FROM
    dannys_diner.sales AS s
    LEFT JOIN dannys_diner.members AS memb ON s.customer_id = memb.customer_id
    LEFT JOIN dannys_diner.menu AS menu ON s.product_id = menu.product_id
  WHERE
    order_date >= join_date
)
SELECT
  customer_id,
  order_date,
  product_name
FROM
  ranked_sales
WHERE
  rank_number = 1;

-- Question 7: Last item purchased before becoming a member

WITH ranked_sales AS (
  SELECT
    s.customer_id AS customer_id,
    s.order_date AS order_date,
    menu.product_name AS product_name,
    RANK() OVER (
      PARTITION BY s.customer_id
      ORDER BY order_date DESC
    ) AS rank_number
  FROM
    dannys_diner.sales AS s
    LEFT JOIN dannys_diner.members AS memb ON s.customer_id = memb.customer_id
    LEFT JOIN dannys_diner.menu AS menu ON s.product_id = menu.product_id
  WHERE
    order_date < join_date
)
SELECT
  customer_id,
  order_date,
  product_name
FROM
  ranked_sales
WHERE
  rank_number = 1;

-- Question 8: Total distinct items and amount spent before becoming a member

SELECT
  s.customer_id AS customer_id,
  COUNT(DISTINCT menu.product_name) AS item_count,
  SUM(menu.price) AS total_spending
FROM 
  dannys_diner.sales AS s 
  LEFT JOIN dannys_diner.members AS memb ON s.customer_id = memb.customer_id 
  LEFT JOIN dannys_diner.menu AS menu ON s.product_id = menu.product_id
WHERE 
  s.order_date < memb.join_date
GROUP BY
  s.customer_id
ORDER BY
  total_spending DESC;

-- Question 9: Points calculation based on spending

SELECT
  s.customer_id,
  SUM(
    CASE
      WHEN menu.product_name = 'sushi' THEN menu.price * 10 * 2
      ELSE menu.price * 10
    END
  ) AS total_points
FROM
  dannys_diner.sales AS s
  LEFT JOIN dannys_diner.members AS memb ON s.customer_id = memb.customer_id
  LEFT JOIN dannys_diner.menu AS menu ON s.product_id = menu.product_id
GROUP BY
  s.customer_id
ORDER BY
  total_points DESC;

-- Question 10: Points calculation with double points in the first week after joining

SELECT
  s.customer_id AS customer_id,
  SUM(
    CASE
      WHEN s.order_date < memb.join_date
      AND menu.product_name = 'sushi' THEN menu.price * 10 * 2
      WHEN s.order_date >= memb.join_date
      AND (s.order_date - memb.join_date) <= 6 THEN menu.price * 10 * 2
      ELSE menu.price * 10
    END
  ) AS total_points
FROM
  dannys_diner.sales AS s
  LEFT JOIN dannys_diner.members AS memb ON s.customer_id = memb.customer_id
  LEFT JOIN dannys_diner.menu AS menu ON s.product_id = menu.product_id
WHERE
  1 = 1
  AND s.customer_id IN ('A', 'B')
  AND s.order_date < DATE '2021-02-01'
GROUP BY
  s.customer_id
ORDER BY
  total_points DESC;

-- Question 11: Categorical field for membership status

SELECT
  s.customer_id AS customer_id,
  s.order_date AS order_date,
  menu.product_name AS product_name,
  menu.price AS price,
  CASE
    WHEN s.order_date >= memb.join_date THEN 'Y' ELSE 'N'
  END AS member
FROM
  dannys_diner.sales AS s
  LEFT JOIN dannys_diner.menu AS menu ON s.product_id = menu.product_id
  LEFT JOIN dannys_diner.members AS memb ON s.customer_id = memb.customer_id
ORDER BY 
  s.customer_id ASC;

-- Question 12: Ranking of customer products with nulls for non-members

WITH ranked_sales AS (
  SELECT
    s.customer_id AS customer_id,
    s.order_date AS order_date,
    menu.product_name AS product_name,
    menu.price AS price,
    CASE
      WHEN s.order_date >= memb.join_date THEN 'Y' ELSE 'N'
    END AS member
  FROM
    dannys_diner.sales AS s
    LEFT JOIN dannys_diner.menu AS menu ON s.product_id = menu.product_id
    LEFT JOIN dannys_diner.members AS memb ON s.customer_id = memb.customer_id
)
SELECT
  customer_id,
  order_date,
  product_name,
  price,
  member,
  CASE
    WHEN member = 'N' THEN NULL
    ELSE RANK() OVER (
      PARTITION BY customer_id, member
      ORDER BY order_date ASC
    )
  END AS ranking
FROM
  ranked_sales
ORDER BY 
  customer_id ASC, order_date ASC, price DESC;
