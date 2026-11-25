-- 1. Are order IDs unique?
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS distinct_orders
FROM olist_orders_dataset;

-- 2. How many orders are in each status?
SELECT order_status, COUNT(*) AS orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY orders DESC;

-- 3. What date range does the data cover?
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM olist_orders_dataset;

-- 4. Missing delivery dates
SELECT SUM(order_delivered_customer_date IS NULL) AS missing_delivery_date,
       SUM(order_delivered_customer_date IS NULL AND order_status = 'delivered') AS delivered_but_no_date
FROM olist_orders_dataset;

-- 5. Do all orders have items? (LEFT vs INNER JOIN)
SELECT
  (SELECT COUNT(*) FROM olist_orders_dataset o
   LEFT JOIN olist_order_items_dataset i ON o.order_id = i.order_id) AS left_join_rows,
  (SELECT COUNT(*) FROM olist_orders_dataset o
   INNER JOIN olist_order_items_dataset i ON o.order_id = i.order_id) AS inner_join_rows;

-- 6. Reviews per order
SELECT COUNT(*) AS review_rows, COUNT(DISTINCT order_id) AS orders_with_reviews
FROM olist_order_reviews_dataset