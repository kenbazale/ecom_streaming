CREATE TABLE stg_users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    user_type VARCHAR(20), -- INDIVIDUAL / CORPORATE
    created_at TIMESTAMP DEFAULT NOW(),
    ingest_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE stg_orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT,
    order_status VARCHAR(20), -- CREATED / CANCELLED / COMPLETED
    order_created_at TIMESTAMP,
    ingest_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE stg_order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT,
    product_code VARCHAR(20),
    quantity INT,
    unit_price NUMERIC(10,2),
    ingest_ts TIMESTAMP DEFAULT NOW()
);


CREATE TABLE stg_payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT,
    amount NUMERIC(10,2),
    payment_status VARCHAR(20), -- PENDING / COMPLETED / FAILED
    payment_ts TIMESTAMP,
    ingest_ts TIMESTAMP DEFAULT NOW()
);


-- Users
INSERT INTO stg_users (full_name, user_type, created_at)
VALUES 
('Alice Smith', 'INDIVIDUAL', NOW() - INTERVAL '2 days'),
('Bob Jones', 'INDIVIDUAL', NOW() - INTERVAL '1 day'),
('Charlie Corp', 'CORPORATE', NOW() - INTERVAL '3 days');

-- Orders
INSERT INTO stg_orders (user_id, order_status, order_created_at)
VALUES
(1, 'CREATED', NOW() - INTERVAL '1 hour'),
(2, 'CREATED', NOW() - INTERVAL '2 hours'),
(1, 'CREATED', NOW() - INTERVAL '30 minutes'); -- duplicate late order

-- Order Items
INSERT INTO stg_order_items (order_id, product_code, quantity, unit_price)
VALUES
(1, 'PROD_A', 2, 50.00),
(1, 'PROD_B', 1, 100.00),
(2, 'PROD_A', 1, 50.00);

-- Payments
INSERT INTO stg_payments (order_id, amount, payment_status, payment_ts)
VALUES
(1, 200.00, 'COMPLETED', NOW() - INTERVAL '50 minutes'),
(2, 50.00, 'COMPLETED', NOW() - INTERVAL '1 hour'),
(3, 100.00, 'COMPLETED', NOW() - INTERVAL '10 minutes'); -- late payment
