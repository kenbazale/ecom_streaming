import psycopg2
from datetime import datetime
import uuid

conn = psycopg2.connect(
    host="localhost",
    user="postgres",
    password="password",
    dbname="stream_db",
    port="5432"
)

cur = conn.cursor()

tables = [
    ("stg_users","raw.users_events","created_at"),
    ("stg_orders","raw.orders_events","order_created_at"),
    ("stg_order_items","raw.order_items_events","ingest_ts"),
    ("stg_payments","raw.payments_events","payment_ts")
]

batch_id = str(uuid.uuid4())

for src,tgt,ts_col in tables:
    cur.execute("SELECT last_ingest_ts from raw.pipeline_state where source_table = %s",(src,))
    last_ts = cur.fetchone()[0]

    query = f"""
        INSERT INTO {tgt}
        SELECT *,%s
        FROM {src}
        WHERE {ts_col} > %s
    """

    cur.execute(query,(batch_id,last_ts))

    cur.execute(f"SELECT MAX({ts_col}) from {src}")
    new_ts = cur.fetchone()[0]    
    
    if new_ts:
        cur.execute("UPDATE raw.pipeline_state SET last_ingest_ts = %s where source_table = %s",(new_ts,src))

conn.commit()
print(f"{src} → {tgt} loaded")
print(f"Batch {batch_id} completed")

cur.close()
conn.close()