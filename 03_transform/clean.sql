

CREATE SCHEMA clean;

CREATE TABLE clean.users_events (
    user_id INT,
    full_name VARCHAR(100),
    user_type VARCHAR(20),
    event_ts TIMESTAMP,
    ingest_ts TIMESTAMP,
    batch_id UUID
);

INSERT INTO clean.users_events
SELECT user_id,
       INITCAP(full_name),
       COALESCE(user_type, 'UNKNOWN'),
       created_at   AS event_ts,
       ingest_ts,
       batch_id
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id, created_at ORDER BY ingest_ts DESC) rn
    FROM raw.users_events
) x
WHERE rn = 1;


CREATE TABLE clean.orders_events (
    order_id INT,
    user_id INT,
    order_status VARCHAR(20),
    event_ts TIMESTAMP,
    ingest_ts TIMESTAMP,
    batch_id UUID
);

INSERT INTO clean.orders_events
SELECT order_id,
       user_id,
       UPPER(order_status),
       order_created_at AS event_ts,
       ingest_ts,
       batch_id
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY order_id, order_created_at ORDER BY ingest_ts DESC) rn
    FROM raw.orders_events
) x
WHERE rn = 1;


CREATE TABLE clean.order_items_events (
    order_item_id INT,
    order_id INT,
    product_code VARCHAR(20),
    quantity INT,
    unit_price NUMERIC(10,2),
    event_ts TIMESTAMP,
    ingest_ts TIMESTAMP,
    batch_id UUID
);

INSERT INTO clean.order_items_events
SELECT order_item_id,
       order_id,
       product_code,
       quantity,
       unit_price,
       ingest_ts AS event_ts,
       ingest_ts,
       batch_id
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY order_item_id ORDER BY ingest_ts DESC) rn
    FROM raw.order_items_events
) x
WHERE rn = 1
    AND quantity > 0
    AND unit_price > 0;;


CREATE TABLE clean.payments_events (
    payment_id INT,
    order_id INT,
    amount NUMERIC(10,2),
    payment_status VARCHAR(20),
    event_ts TIMESTAMP,
    ingest_ts TIMESTAMP,
    batch_id UUID
);

INSERT INTO clean.payments_events
SELECT payment_id,
       order_id,
       amount,
       UPPER(payment_status),
       payment_ts AS event_ts,
       ingest_ts,
       batch_id
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY ingest_ts DESC) rn
    FROM raw.payments_events
) x
WHERE rn = 1
AND amount > 0;
