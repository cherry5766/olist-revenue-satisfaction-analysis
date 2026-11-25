import sqlite3
import sys
import pandas as pd

pd.set_option("display.width", 200)
pd.set_option("display.max_columns", 20)

con = sqlite3.connect("olist.db")
sql = open(sys.argv[1], encoding="utf-8").read()

for stmt in sql.split(";"):
    if stmt.strip():
        print("-" * 60)
        print(stmt.strip()[:80])
        print(pd.read_sql_query(stmt, con).to_string(index=False))
con.close()