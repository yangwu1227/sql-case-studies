WITH RECURSIVE
    output_table (
        id,
        category_id,
        segment_id,
        style_id,
        category_name,
        segment_name,
        style_name
    ) AS (
        -- 1) BASE CASE
        SELECT
            ph.id,
            ph.id AS category_id,
            CAST(NULL AS INTEGER) AS segment_id,
            CAST(NULL AS INTEGER) AS style_id,
            ph.level_text AS category_name,
            CAST(NULL AS VARCHAR) AS segment_name,
            CAST(NULL AS VARCHAR) AS style_name
        FROM
            balanced_tree.product_hierarchy AS ph
        WHERE
            parent_id IS NULL
        UNION ALL
        -- 2) RECURSIVE STEP
        SELECT
            child.id,
            output_table.category_id,
            -- Assign segment_id if the child belongs to a category
            CASE
                WHEN child.level_name = 'Segment' THEN child.id
                ELSE output_table.segment_id
            END AS segment_id,
            -- Assign style_id if the child belongs to a segment
            CASE
                WHEN child.level_name = 'Style' THEN child.id
                ELSE output_table.style_id
            END AS style_id,
            output_table.category_name,
            -- Assign segment_name
            CASE
                WHEN child.level_name = 'Segment' THEN child.level_text
                ELSE output_table.segment_name
            END AS segment_name,
            -- Assign style_name
            CASE
                WHEN child.level_name = 'Style' THEN child.level_text
                ELSE output_table.style_name
            END AS style_name
        FROM
            output_table
            INNER JOIN balanced_tree.product_hierarchy AS child ON output_table.id = child.parent_id
    )
    -- 3) Final Select: Join with prices and generate product_name
SELECT
    pp.product_id,
    pp.price,
    CONCAT_WS (' - ', style_name, segment_name, category_name) AS product_name,
    category_id,
    segment_id,
    style_id,
    category_name,
    segment_name,
    style_name
FROM
    output_table
    INNER JOIN balanced_tree.product_prices AS pp ON output_table.id = pp.id
ORDER BY
    price DESC;
