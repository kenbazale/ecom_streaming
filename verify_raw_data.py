import psycopg2

def verify_data():
    try:
        conn = psycopg2.connect(
            host="localhost",
            user="postgres",
            password="password",
            dbname="stream_db",
            port="5432"
        )
        cur = conn.cursor()
        
        print("Checking raw.orders_events for recent data...")
        cur.execute("SELECT count(*) FROM raw.orders_events WHERE order_created_at > NOW() - INTERVAL '5 minutes';")
        order_count = cur.fetchone()[0]
        print(f"New orders found: {order_count}")
        
        print("Checking raw.payments_events for recent data...")
        cur.execute("SELECT count(*) FROM raw.payments_events WHERE payment_ts > NOW() - INTERVAL '5 minutes';")
        payment_count = cur.fetchone()[0]
        print(f"New payments found: {payment_count}")
        
        cur.close()
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    verify_data()
