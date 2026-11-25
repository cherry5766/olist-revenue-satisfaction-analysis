-- Clean monthly trend: Jan 2017 to Aug 2018, delivered orders only
WITH delivered AS (
    SELECT order_id, order_purchase_timestamp
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
      AND order_purchase_timestamp >= '2017-01-01'
      AND order_purchase_timestamp < '2018-09-01'
),
monthly AS (
    SELECT strftime('%Y-%m', o.order_purchase_timestamp) AS month,
           COUNT(DISTINCT o.order_id) AS orders,
           ROUND(SUM(i.price), 2) AS revenue
    FROM delivered o
    JOIN olist_order_items_dataset i ON o.order_id = i.order_id
    GROUP BY month
)
SELECT month,
       orders,
       revenue,
       ROUND(revenue * 1.0 / orders, 2) AS avg_order_value,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 2) AS mom_pct,
       ROUND(100.0 * (revenue - LAG(revenue, 12) OVER (ORDER BY month))
             / LAG(revenue, 12) OVER (ORDER BY month), 2) AS yoy_pct,
       ROUND(AVG(revenue) OVER (ORDER BY month
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rev_3m_avg
FROM monthly
ORDER BY month;

-- Top 5 revenue days (is Nov 2017 a Black Friday effect?)
SELECT date(o.order_purchase_timestamp) AS day,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(i.price), 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY day
ORDER BY revenue DESC
LIMIT 5