import psycopg2
from datetime import datetime, timedelta

def insert_new_data():
    try:
        conn = psycopg2.connect(
            host="localhost",
            user="postgres",
            password="password",
            dbname="stream_db",
            port="5432"
        )
        cur = conn.cursor()
        
        # Insert a new order
        print("Inserting new order...")
        cur.execute("""
            INSERT INTO stg_orders (user_id, order_status, order_created_at)
            VALUES (%s, %s, %s) RETURNING order_id;
        """, (1, 'COMPLETED', datetime.now()))
        new_order_id = cur.fetchone()[0]
        
        # Insert a new payment for that order
        print(f"Inserting new payment for order {new_order_id}...")
        cur.execute("""
            INSERT INTO stg_payments (order_id, amount, payment_status, payment_ts)
            VALUES (%s, %s, %s, %s);
        """, (new_order_id, 150.00, 'COMPLETED', datetime.now()))
        
        conn.commit()
        print("Successfully inserted new staging data.")
        
        cur.close()
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    insert_new_data()
