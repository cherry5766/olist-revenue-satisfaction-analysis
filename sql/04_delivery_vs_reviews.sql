-- Delivery delay vs review score (one review per order, window Jan 2017 - Aug 2018)
WITH reviews_dedup AS (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY review_creation_date DESC, review_answer_timestamp DESC, review_id DESC
           ) AS rn
    FROM olist_order_reviews_dataset
),
delivered AS (
    SELECT order_id,
           julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) AS days_late
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_purchase_timestamp >= '2017-01-01'
      AND order_purchase_timestamp < '2018-09-01'
),
joined AS (
    SELECT d.order_id, d.days_late, r.review_score,
           CASE WHEN d.days_late <= 0 THEN '1. On time or early'
                WHEN d.days_late <= 3 THEN '2. 1-3 days late'
                WHEN d.days_late <= 7 THEN '3. 4-7 days late'
                ELSE '4. 8+ days late' END AS delay_bucket
    FROM delivered d
    JOIN reviews_dedup r ON d.order_id = r.order_id AND r.rn = 1
)
SELECT delay_bucket,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders,
       ROUND(AVG(review_score), 2) AS avg_review,
       ROUND(100.0 * SUM(review_score <= 2) / COUNT(*), 1) AS pct_1_to_2_stars
FROM joined
GROUP BY delay_bucket
ORDER BY delay_bucket;

-- Check: how many delivered orders in the window have no review at all
SELECT COUNT(*) AS delivered_orders,
       SUM(EXISTS (SELECT 1 FROM olist_order_reviews_dataset r WHERE r.order_id = o.order_id)) AS with_review
FROM olist_orders_dataset o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'