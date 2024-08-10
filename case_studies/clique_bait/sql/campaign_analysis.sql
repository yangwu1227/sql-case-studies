-- Campaign metrics table

WITH sorted_product AS (
    SELECT
        DISTINCT events.visit_id AS visit_id,
        events.sequence_number AS seq_num,
        pa.page_name AS product_name
    FROM
        clique_bait.events AS events LEFT JOIN clique_bait.page_hierarchy AS pa ON events.page_id = pa.page_id
    WHERE
        events.event_type = 2
    ORDER BY
        events.visit_id, events.sequence_number ASC
),
products_added_wide AS (
    SELECT
        visit_id,
        MAX(CASE WHEN seq_num = 1 THEN product_name END) AS product_added_1,
        MAX(CASE WHEN seq_num = 2 THEN product_name END) AS product_added_2,
        MAX(CASE WHEN seq_num = 3 THEN product_name END) AS product_added_3,
        MAX(CASE WHEN seq_num = 4 THEN product_name END) AS product_added_4,
        MAX(CASE WHEN seq_num = 5 THEN product_name END) AS product_added_5,
        MAX(CASE WHEN seq_num = 6 THEN product_name END) AS product_added_6,
        MAX(CASE WHEN seq_num = 7 THEN product_name END) AS product_added_7,
        MAX(CASE WHEN seq_num = 8 THEN product_name END) AS product_added_8,
        MAX(CASE WHEN seq_num = 9 THEN product_name END) AS product_added_9,
        MAX(CASE WHEN seq_num = 10 THEN product_name END) AS product_added_10,
        MAX(CASE WHEN seq_num = 11 THEN product_name END) AS product_added_11,
        MAX(CASE WHEN seq_num = 12 THEN product_name END) AS product_added_12,
        MAX(CASE WHEN seq_num = 13 THEN product_name END) AS product_added_13,
        MAX(CASE WHEN seq_num = 14 THEN product_name END) AS product_added_14,
        MAX(CASE WHEN seq_num = 15 THEN product_name END) AS product_added_15,
        MAX(CASE WHEN seq_num = 16 THEN product_name END) AS product_added_16,
        MAX(CASE WHEN seq_num = 17 THEN product_name END) AS product_added_17,
        MAX(CASE WHEN seq_num = 18 THEN product_name END) AS product_added_18,
        MAX(CASE WHEN seq_num = 19 THEN product_name END) AS product_added_19,
        MAX(CASE WHEN seq_num = 20 THEN product_name END) AS product_added_20,
        MAX(CASE WHEN seq_num = 21 THEN product_name END) AS product_added_21,
        MAX(CASE WHEN seq_num = 22 THEN product_name END) AS product_added_22,
        MAX(CASE WHEN seq_num = 23 THEN product_name END) AS product_added_23
    FROM 
        sorted_product
    GROUP BY
        visit_id
),
products_added AS (
    SELECT
        visit_id,
        CONCAT_WS(', ', 'product_added_1', 'product_added_2', 'product_added_3', 'product_added_4', 'product_added_5', 'product_added_6', 'product_added_7', 'product_added_8', 'product_added_9', 'product_added_10', 'product_added_11', 'product_added_12', 'product_added_13', 'product_added_14', 'product_added_15', 'product_added_16', 'product_added_17', 'product_added_18', 'product_added_19', 'product_added_20', 'product_added_21', 'product_added_22', 'product_added_23'
) AS cart_products
    FROM
        products_added_wide
)
SELECT
    users.user_id AS user_id,
    events.visit_id AS visit_id,
    camp_id.campaign_name,
    MIN(events.event_time) AS visit_start_time,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchases,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN event_type = 4 THEN 1 ELSE 0 END) AS ad_impressions,
    SUM(CASE WHEN event_type = 5 THEN 1 ELSE 0 END) AS ad_clicks,
    MAX(products_added.cart_products) AS cart_products
FROM
    clique_bait.events AS events 
        LEFT JOIN clique_bait.users AS users ON events.cookie_id = users.cookie_id
        LEFT JOIN products_added ON events.visit_id = products_added.visit_id
        LEFT JOIN clique_bait.campaign_identifier AS camp_id ON events.event_time BETWEEN camp_id.start_date AND camp_id.end_date
GROUP BY
    users.user_id,
    events.visit_id,
    camp_id.campaign_name
ORDER BY
    users.user_id,
    events.visit_id,
    visit_start_time ASC;

-- Does clicking on an impression lead to higher purchase rates?

WITH ad_metrics AS (
    SELECT 
        user_id,
        purchases,
        CASE 
            WHEN ad_impressions = 0 AND ad_clicks = 0 THEN 'no_impression_no_click' 
            WHEN ad_impressions > 0 AND ad_clicks = 0 THEN 'yes_impression_no_click' 
            WHEN ad_impressions > 0 AND ad_clicks > 0 THEN 'yes_impression_yes_click'
            ELSE 'other'
        END AS ad_groups
    FROM 
        clique_bait.campaign_metrics
)
SELECT
    ad_groups,
    SUM(purchases) AS purchases,
    COUNT(DISTINCT user_id) AS users,
    ROUND(TRY_CAST(SUM(purchases) AS double) / TRY_CAST(COUNT(DISTINCT user_id) AS double), 2) AS purchase_rate
FROM
    ad_metrics
GROUP BY
    ad_groups
ORDER BY
    purchase_rate DESC;

-- Campaign success metrics

WITH calculations AS (
    SELECT
        campaign_name,
        SUM(ad_impressions) AS total_impressions,
        SUM(ad_clicks) AS total_clicks,
        SUM(purchases) AS total_purchases,
        COUNT(visit_id) AS total_visits,
        COUNT(DISTINCT user_id) AS total_users,
        SUM(page_views) AS total_page_views,
        SUM(cart_adds) AS total_cart_adds
    FROM
        clique_bait.campaign_metrics
    GROUP BY
        campaign_name
)
SELECT
    COALESCE(campaign_name, 'No Campaign') AS campaign_name,
    COALESCE(TRY_CAST(total_clicks AS double) / TRY_CAST(total_impressions AS double), 0) * 100 AS click_through_rate,
    COALESCE(TRY_CAST(total_purchases AS double) / TRY_CAST(total_clicks AS double), 0) * 100 AS conversion_rate, 
    COALESCE(TRY_CAST(total_purchases AS double) / TRY_CAST(total_visits AS double), 0) * 100 AS purchase_rate,
    total_impressions,
    total_clicks,
    total_purchases,
    total_visits,
    total_users,
    total_page_views,
    total_cart_adds
FROM
    calculations
ORDER BY
    campaign_name;
