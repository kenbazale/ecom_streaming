CREATE SCHEMA raw;

CREATE TABLE raw.users_events (
    user_id INT,
    full_name VARCHAR(100),
    user_type VARCHAR(20),
    created_at TIMESTAMP,
    ingest_ts TIMESTAMP,
    batch_id UUID
);

CREATE TABLE raw.orders_events (
    order_id INT,
    user_id INT,
    order_status VARCHAR(20),
    order_created_at TIMESTAMP,
    ingest_ts TIMESTAMP,
    batch_id UUID
);

CREATE TABLE raw.order_items_events (
    order_item_id INT,
    order_id INT,
    product_code VARCHAR(20),
    quantity INT,
    unit_price NUMERIC(10,2),
    ingest_ts TIMESTAMP,
    batch_id UUID
);

CREATE TABLE raw.payments_events (
    payment_id INT,
    order_id INT,
    amount NUMERIC(10,2),
    payment_status VARCHAR(20),
    payment_ts TIMESTAMP,
    ingest_ts TIMESTAMP,
    batch_id UUID
);

CREATE TABLE raw.pipeline_state (
    source_table VARCHAR PRIMARY KEY,
    last_ingest_ts TIMESTAMP
);

INSERT INTO raw.pipeline_state VALUES
('stg_users', '1900-01-01'),
('stg_orders', '1900-01-01'),
('stg_order_items', '1900-01-01'),
('stg_payments', '1900-01-01');
