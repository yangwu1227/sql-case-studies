-- How many users are there?

SELECT
    COUNT(DISTINCT user_id) AS user_count
FROM
    clique_bait.users;

-- How many cookies does each user have on average?

WITH cookie_counts AS (
    SELECT
        COUNT(DISTINCT cookie_id) AS cookie_count
    FROM
        clique_bait.users
    GROUP BY
        user_id  
)
SELECT
    AVG(cookie_count) AS avg_cookies_per_user
FROM
    cookie_counts;

-- What is the unique number of visits by all users per month?

SELECT
    MONTH(event_time) AS month,
    COUNT(DISTINCT visit_id) AS visit_count
FROM
    clique_bait.events
GROUP BY
    MONTH(event_time)
ORDER BY
    month;

-- What is the number of events for each event type?

SELECT
    event_id.event_name AS event_name,
    events.event_type AS event_type,
    COUNT(events.visit_id) AS visit_count_per_event_type
FROM
    clique_bait.events AS events
    LEFT JOIN clique_bait.event_identifier AS event_id 
    ON events.event_type = event_id.event_type
GROUP BY
    event_id.event_name, events.event_type
ORDER BY
    visit_count_per_event_type DESC;

-- What is the percentage of visits which have a purchase event?

WITH visit_purchase AS (
    SELECT
        visit_id,
        MAX(CASE WHEN event_type = 3 THEN 1.0 ELSE 0.0 END) AS has_purchase_event
    FROM 
        clique_bait.events
    GROUP BY 
        visit_id
)
SELECT
    ROUND((SUM(has_purchase_event) / COUNT(*)) * 100, 4) AS purchase_pct
FROM
    visit_purchase;

-- What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH visit_purchase_page_view AS (
    SELECT
        visit_id,
        MAX(CASE WHEN event_type = 1 AND page_id = 12 THEN 1.0 ELSE 0.0 END) AS has_checkout_view,
        MAX(CASE WHEN event_type = 3 THEN 1.0 ELSE 0.0 END) AS has_purchase
    FROM
        clique_bait.events
    GROUP BY
        visit_id
)
SELECT
    ROUND((SUM(CASE WHEN has_checkout_view = 1.0 AND has_purchase = 0.0 THEN 1.0 ELSE 0.0 END) / COUNT(*)) * 100, 4) AS checkout_view_no_purchase_pct
FROM
    visit_purchase_page_view
WHERE
    has_checkout_view = 1.0;

-- What are the top 3 pages by number of views?

SELECT
    events.page_id AS page_id,
    pa.page_name AS page_name,
    COUNT(DISTINCT visit_id) AS num_views
FROM
    clique_bait.events AS events
    LEFT JOIN clique_bait.page_hierarchy AS pa ON events.page_id = pa.page_id
WHERE
    events.event_type = 1
GROUP BY
    events.page_id, pa.page_name
ORDER BY
    num_views DESC
LIMIT 3;

-- What is the number of views and cart adds for each product category?

SELECT
    pa.product_category AS product_cat,
    SUM(CASE WHEN events.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN events.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds
FROM 
    clique_bait.events AS events
    LEFT JOIN clique_bait.page_hierarchy AS pa ON events.page_id = pa.page_id
WHERE
    pa.product_category IS NOT NULL
GROUP BY
    pa.product_category
ORDER BY
    pa.product_category;

-- What are the top 3 products by add to cart followed by purchase events?

WITH purchase_visit_ids AS (
    SELECT
        visit_id
    FROM
        clique_bait.events
    WHERE 
        event_type = 3
)
SELECT
    pa.product_id AS product_id,
    pa.page_name AS product_name,
    SUM(CASE WHEN events.event_type = 2 THEN 1 ELSE 0 END) AS add_count_followed_by_purchase
FROM 
    clique_bait.events AS events
    LEFT JOIN clique_bait.page_hierarchy AS pa ON events.page_id = pa.page_id
WHERE 
    EXISTS (
        SELECT 
            NULL
        FROM 
            purchase_visit_ids AS pvids
        WHERE 
            events.visit_id = pvids.visit_id
    )
AND 
    pa.product_id IS NOT NULL
GROUP BY 
    pa.product_id, 
    pa.page_name
ORDER BY 
    SUM(CASE WHEN events.event_type = 2 THEN 1 ELSE 0 END) DESC
LIMIT 3;
