-- 1. Revenue by customer state, with share and cumulative share (Jan 2017 - Aug 2018)
WITH base AS (
    SELECT c.customer_state AS state, o.order_id, i.price
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    JOIN olist_order_items_dataset i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
)
SELECT RANK() OVER (ORDER BY SUM(price) DESC) AS rnk,
       state,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(price), 2) AS revenue,
       ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER (), 1) AS pct_share,
       ROUND(100.0 * SUM(SUM(price)) OVER (ORDER BY SUM(price) DESC)
             / SUM(SUM(price)) OVER (), 1) AS cumulative_pct
FROM base
GROUP BY state
ORDER BY revenue DESC
LIMIT 10;

-- 2. Top 10 product categories by revenue
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(i.price), 2) AS revenue,
       ROUND(100.0 * SUM(i.price) / SUM(SUM(i.price)) OVER (), 1) AS pct_share
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
LEFT JOIN olist_products_dataset p ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- 3. States with the highest late-delivery rate (states with at least 500 orders)
WITH d AS (
    SELECT c.customer_state AS state,
           CASE WHEN julianday(o.order_delivered_customer_date)
                   > julianday(o.order_estimated_delivery_date) THEN 1 ELSE 0 END AS late
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
)
SELECT state,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(late) / COUNT(*), 1) AS pct_late
FROM d
GROUP BY state
HAVING COUNT(*) >= 500
ORDER BY pct_late DESC
LIMIT 5