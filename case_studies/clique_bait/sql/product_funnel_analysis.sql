-- Product funnel view 

CREATE OR REPLACE VIEW product_funnel AS 
WITH page_view_cart_add_cte AS (
    SELECT
        events.visit_id AS visit_id,
        pa.product_id AS product_id,
        pa.page_name AS product_name,
        pa.product_category AS product_cat,
        SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_view,
        SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_add
    FROM
        clique_bait.events AS events LEFT JOIN clique_bait.page_hierarchy AS pa ON events.page_id = pa.page_id
    WHERE
        pa.product_id IS NOT NULL
    GROUP BY
        events.visit_id, 
        pa.product_id, 
        pa.page_name, 
        pa.product_category
),
purchase_cte AS (
    SELECT
        visit_id
    FROM
        clique_bait.events
    WHERE 
        event_type = 3
),
combined_cte AS (
    SELECT  
        page_view_cart_add_cte.visit_id AS visit_id_page_view_cart_add_cte,
        purchase_cte.visit_id AS visit_id_purchase_cte,
        page_view_cart_add_cte.product_id AS product_id,
        page_view_cart_add_cte.product_name AS product_name,
        page_view_cart_add_cte.product_cat AS product_cat,
        page_view_cart_add_cte.page_view AS page_view,
        page_view_cart_add_cte.cart_add AS cart_add,
        CASE WHEN purchase_cte.visit_id IS NULL THEN 1 ELSE 0 END AS abandoned_purchase
    FROM
        page_view_cart_add_cte LEFT JOIN purchase_cte ON page_view_cart_add_cte.visit_id = purchase_cte.visit_id
)
SELECT
    product_id,
    product_name,
    product_cat,
    SUM(page_view) AS page_views,
    SUM(cart_add) AS cart_adds,
    SUM(CASE WHEN cart_add = 1 AND abandoned_purchase = 1 THEN 1 ELSE 0 END) AS abandoned,
    SUM(CASE WHEN cart_add = 1 AND abandoned_purchase = 0 THEN 1 ELSE 0 END) AS purchases
FROM
    combined_cte
GROUP BY
    product_id,
    product_cat,
    product_name
ORDER BY
    product_id;

-- Product category funnel view

CREATE OR REPLACE VIEW product_cat_funnel AS 
SELECT
    product_cat,
    SUM(page_views) AS page_views,
    SUM(cart_adds) AS cart_adds,
    SUM(abandoned) AS abandoned,
    SUM(purchases) AS purchases
FROM
    clique_bait.product_funnel
GROUP BY
    product_cat
ORDER BY
    product_cat;

-- Which product had the most views, cart adds and purchases?

WITH ranked_stats AS (
    SELECT
        product_id,
        product_name,
        page_views,
        cart_adds,
        purchases,
        RANK() OVER (ORDER BY page_views DESC NULLS LAST) AS page_views_rank,
        RANK() OVER (ORDER BY cart_adds DESC NULLS LAST) AS cart_adds_rank,
        RANK() OVER (ORDER BY purchases DESC NULLS LAST) AS purchases_rank
    FROM
        clique_bait.product_funnel
)
SELECT
    product_id,
    product_name,
    page_views,
    cart_adds,
    purchases,
    page_views_rank,
    cart_adds_rank,
    purchases_rank
FROM
    ranked_stats
WHERE
    page_views_rank = 1 
    OR cart_adds_rank = 1
    OR purchases_rank = 1;

-- Which product was most likely to be abandoned?

SELECT
    product_name,
    ROUND(TRY_CAST(abandoned AS DOUBLE) / TRY_CAST(cart_adds AS DOUBLE), 4) AS fallout_rate
FROM
    clique_bait.product_funnel
ORDER BY
    fallout_rate DESC;

-- Which product had the highest view to purchase percentage?

SELECT
    product_name,
    ROUND(TRY_CAST(purchases AS DOUBLE) / TRY_CAST(page_views AS DOUBLE), 4) AS view_to_purchase_rate
FROM
    clique_bait.product_funnel
ORDER BY
    view_to_purchase_rate DESC;

-- What is the average conversion rate from view to cart add?

SELECT
    ROUND(TRY_CAST(SUM(cart_adds) AS DOUBLE) / TRY_CAST(SUM(page_views) AS DOUBLE), 4) AS view_to_cart_add_rate
FROM
    clique_bait.product_funnel;

-- What is the average conversion rate from cart add to purchase?

SELECT
    ROUND(TRY_CAST(SUM(purchases) AS DOUBLE) / TRY_CAST(SUM(cart_adds) AS DOUBLE), 4) AS cart_add_to_purchase_rate
FROM
    clique_bait.product_funnel;
