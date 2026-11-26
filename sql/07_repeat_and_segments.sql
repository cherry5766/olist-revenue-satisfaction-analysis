-- 1. Repeat purchase rate (unique customers, delivered orders, Jan 2017 - Aug 2018)
WITH o AS (
    SELECT c.customer_unique_id AS cid, o.order_id
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
),
per AS (
    SELECT cid, COUNT(DISTINCT order_id) AS n FROM o GROUP BY cid
)
SELECT COUNT(*) AS customers,
       SUM(n > 1) AS repeat_customers,
       ROUND(100.0 * SUM(n > 1) / COUNT(*), 2) AS repeat_pct,
       ROUND(AVG(n), 3) AS avg_orders_per_customer
FROM per;

-- 2. Cohort view: share of each first-purchase-month cohort that buys again within 90 days
WITH o AS (
    SELECT c.customer_unique_id AS cid, o.order_id,
           date(o.order_purchase_timestamp) AS d
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
),
first_order AS (
    SELECT cid, MIN(d) AS first_d FROM o GROUP BY cid
),
x AS (
    SELECT f.cid,
           strftime('%Y-%m', f.first_d) AS cohort,
           MAX(CASE WHEN o.d > f.first_d
                     AND julianday(o.d) - julianday(f.first_d) <= 90 THEN 1 ELSE 0 END) AS repeat90
    FROM first_order f
    JOIN o ON o.cid = f.cid
    GROUP BY f.cid, cohort
)
SELECT cohort,
       COUNT(*) AS customers,
       SUM(repeat90) AS bought_again_90d,
       ROUND(100.0 * SUM(repeat90) / COUNT(*), 2) AS pct_bought_again
FROM x
WHERE cohort <= '2018-05'
GROUP BY cohort
ORDER BY cohort;

-- 3. Customer value segments
WITH rev AS (
    SELECT order_id, SUM(price) AS revenue
    FROM olist_order_items_dataset
    GROUP BY order_id
),
cust AS (
    SELECT c.customer_unique_id AS cid,
           COUNT(DISTINCT o.order_id) AS orders,
           SUM(rev.revenue) AS spend
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    JOIN rev ON o.order_id = rev.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY c.customer_unique_id
),
scored AS (
    SELECT cid, orders, spend,
           NTILE(4) OVER (ORDER BY spend) AS spend_quartile
    FROM cust
),
seg AS (
    SELECT cid, spend,
           CASE WHEN orders > 1 THEN '1. Repeat customers'
                WHEN spend_quartile = 4 THEN '2. High-value one-time'
                ELSE '3. Other one-time' END AS segment
    FROM scored
)
SELECT segment,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_customers,
       ROUND(SUM(spend), 0) AS revenue,
       ROUND(100.0 * SUM(spend) / SUM(SUM(spend)) OVER (), 1) AS pct_revenue,
       ROUND(AVG(spend), 2) AS avg_spend
FROM seg
GROUP BY segment
ORDER BY segment
