import sqlite3
import pandas as pd

con = sqlite3.connect("olist.db")
W = "o.order_purchase_timestamp >= '2017-01-01' AND o.order_purchase_timestamp < '2018-09-01'"

monthly = f"""
WITH delivered AS (
    SELECT o.order_id, o.order_purchase_timestamp
    FROM olist_orders_dataset o
    WHERE o.order_status = 'delivered' AND {W}
),
m AS (
    SELECT strftime('%Y-%m', d.order_purchase_timestamp) AS month,
           COUNT(DISTINCT d.order_id) AS orders,
           ROUND(SUM(i.price), 2) AS revenue
    FROM delivered d
    JOIN olist_order_items_dataset i ON d.order_id = i.order_id
    GROUP BY month
)
SELECT month, orders, revenue,
       ROUND(revenue * 1.0 / orders, 2) AS avg_order_value,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 2) AS mom_pct,
       ROUND(100.0 * (revenue - LAG(revenue, 12) OVER (ORDER BY month))
             / LAG(revenue, 12) OVER (ORDER BY month), 2) AS yoy_pct,
       ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rev_3m_avg
FROM m ORDER BY month
"""

delay = f"""
WITH reviews_dedup AS (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (PARTITION BY order_id
               ORDER BY review_creation_date DESC, review_answer_timestamp DESC, review_id DESC) AS rn
    FROM olist_order_reviews_dataset
),
delivered AS (
    SELECT o.order_id,
           julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) AS days_late
    FROM olist_orders_dataset o
    WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL AND {W}
),
j AS (
    SELECT d.order_id, r.review_score,
           CASE WHEN d.days_late <= 0 THEN '1. On time or early'
                WHEN d.days_late <= 3 THEN '2. 1-3 days late'
                WHEN d.days_late <= 7 THEN '3. 4-7 days late'
                ELSE '4. 8+ days late' END AS delay_bucket
    FROM delivered d JOIN reviews_dedup r ON d.order_id = r.order_id AND r.rn = 1
)
SELECT delay_bucket, COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders,
       ROUND(AVG(review_score), 2) AS avg_review,
       ROUND(100.0 * SUM(review_score <= 2) / COUNT(*), 1) AS pct_1_to_2_stars
FROM j GROUP BY delay_bucket ORDER BY delay_bucket
"""

state = f"""
WITH rev AS (
    SELECT o.order_id, SUM(i.price) AS revenue
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered' AND {W}
    GROUP BY o.order_id
),
rv AS (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (PARTITION BY order_id
               ORDER BY review_creation_date DESC, review_answer_timestamp DESC, review_id DESC) AS rn
    FROM olist_order_reviews_dataset
)
SELECT c.customer_state AS state,
       COUNT(*) AS orders,
       ROUND(SUM(rev.revenue), 2) AS revenue,
       ROUND(100.0 * SUM(CASE WHEN o.order_delivered_customer_date IS NOT NULL
                  AND julianday(o.order_delivered_customer_date) > julianday(o.order_estimated_delivery_date)
                  THEN 1 ELSE 0 END)
             / SUM(CASE WHEN o.order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END), 1) AS pct_late,
       ROUND(AVG(rv.review_score), 2) AS avg_review
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN rev ON o.order_id = rev.order_id
LEFT JOIN rv ON o.order_id = rv.order_id AND rv.rn = 1
WHERE o.order_status = 'delivered' AND {W}
GROUP BY state ORDER BY revenue DESC
"""

category = f"""
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(i.price), 2) AS revenue,
       ROUND(100.0 * SUM(i.price) / SUM(SUM(i.price)) OVER (), 1) AS pct_share
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
LEFT JOIN olist_products_dataset p ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered' AND {W}
GROUP BY category ORDER BY revenue DESC
"""

for name, q in [("monthly_trend", monthly), ("delivery_vs_reviews", delay),
                ("state_summary", state), ("category_summary", category)]:
    df = pd.read_sql_query(q, con)
    df.to_csv(f"dashboard/{name}.csv", index=False)
    print(f"{name}.csv: {len(df)} rows")

con.close()
print("Done!")