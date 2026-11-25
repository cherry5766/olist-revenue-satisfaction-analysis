import sqlite3

con = sqlite3.connect("olist.db")
cur = con.cursor()

cur.execute("CREATE INDEX IF NOT EXISTS idx_reviews_order ON olist_order_reviews_dataset(order_id)")
cur.execute("CREATE INDEX IF NOT EXISTS idx_items_order ON olist_order_items_dataset(order_id)")
cur.execute("CREATE INDEX IF NOT EXISTS idx_items_product ON olist_order_items_dataset(product_id)")
cur.execute("CREATE INDEX IF NOT EXISTS idx_orders_customer ON olist_orders_dataset(customer_id)")
cur.execute("CREATE INDEX IF NOT EXISTS idx_customers_id ON olist_customers_dataset(customer_id)")
cur.execute("CREATE INDEX IF NOT EXISTS idx_products_id ON olist_products_dataset(product_id)")

con.commit()
con.close()
print("Indexes created.")