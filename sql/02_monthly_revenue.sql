-- Monthly revenue from delivered orders, with month-over-month change
WITH delivered_orders AS (
    SELECT order_id, order_purchase_timestamp
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
),
monthly AS (
    SELECT strftime('%Y-%m', o.order_purchase_timestamp) AS month,
           COUNT(DISTINCT o.order_id) AS orders,
           ROUND(SUM(i.price), 2) AS revenue
    FROM delivered_orders o
    JOIN olist_order_items_dataset i ON o.order_id = i.order_id
    GROUP BY month
)
SELECT month,
       orders,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 2) AS mom_pct
FROM monthly
ORDER BY month