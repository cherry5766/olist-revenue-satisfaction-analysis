import pandas as pd
import sqlite3
import glob
import os

con = sqlite3.connect("olist.db")

for f in glob.glob("data/*.csv"):
    name = os.path.basename(f)[:-4]
    df = pd.read_csv(f)
    df.to_sql(name, con, if_exists="replace", index=False)
    print(f"{name}: {len(df)} rows")

con.close()
print("Done!")