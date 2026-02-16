
CREATE SCHEMA analytics;

CREATE TABLE analytics.fact_hourly_revenue (
    hour_ts TIMESTAMP,
    total_revenue NUMERIC(12,2),
    order_count INT,
    payment_count INT,
    last_updated TIMESTAMP
);

INSERT INTO analytics.fact_hourly_revenue
SELECT
    date_trunc('hour', event_ts) AS hour_ts,
    SUM(amount) AS total_revenue,
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(*) AS payment_count,
    NOW() AS last_updated
FROM clean.payments_events
WHERE payment_status = 'COMPLETED'
GROUP BY date_trunc('hour', event_ts);


CREATE TABLE analytics.fact_daily_active_users (
    day_ts DATE,
    active_users INT,
    last_updated TIMESTAMP
);

INSERT INTO analytics.fact_daily_active_users
SELECT
    date_trunc('day', event_ts)::DATE AS day_ts,
    COUNT(DISTINCT user_id) AS active_users,
    NOW() AS last_updated
FROM clean.users_events
GROUP BY date_trunc('day', event_ts);



CREATE TABLE analytics.fact_daily_product_revenue (
    day_ts DATE,
    product_code VARCHAR(20),
    total_revenue NUMERIC(12,2),
    last_updated TIMESTAMP
);


INSERT INTO analytics.fact_daily_product_revenue
SELECT
    DATE(p.event_ts) AS day_ts,
    oi.product_code,
    SUM(p.amount) AS total_revenue,
    NOW() AS last_updated
FROM clean.payments_events p
JOIN clean.order_items_events oi
  ON p.order_id = oi.order_id
WHERE p.payment_status = 'COMPLETED'
GROUP BY DATE(p.event_ts), oi.product_code;


DELETE FROM analytics.fact_hourly_revenue
WHERE hour_ts >= NOW() - INTERVAL '2 days';



