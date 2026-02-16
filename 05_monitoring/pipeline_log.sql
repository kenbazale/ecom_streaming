CREATE SCHEMA monitoring;


CREATE TABLE monitoring.pipeline_runs (
    run_id UUID,
    phase VARCHAR(50),
    start_ts TIMESTAMP,
    end_ts TIMESTAMP,
    status VARCHAR(20),
    rows_processed INT,
    error_message TEXT
);

CREATE TABLE monitoring.event_volume (
    table_name VARCHAR,
    event_hour TIMESTAMP,
    row_count INT
);

INSERT INTO monitoring.event_volume
SELECT
    'payments' AS table_name,
    date_trunc('hour', ingest_ts),
    COUNT(*)
FROM raw.payments_events
GROUP BY date_trunc('hour', ingest_ts);


SELECT *
FROM monitoring.event_volume
WHERE row_count < 0.5 * (
    SELECT AVG(row_count)
    FROM monitoring.event_volume
);

CREATE TABLE monitoring.late_events (
    event_type VARCHAR,
    event_hour TIMESTAMP,
    late_count INT
);

INSERT INTO monitoring.late_events
SELECT
    'payments',
    date_trunc('hour', ingest_ts),
    COUNT(*)
FROM raw.payments_events
WHERE payment_ts < ingest_ts - INTERVAL '1 hour'
GROUP BY date_trunc('hour', ingest_ts);


SELECT payment_id, COUNT(*)
FROM raw.payments_events
GROUP BY payment_id
HAVING COUNT(*) > 1;

SELECT NOW() - MAX(ingest_ts) AS pipeline_lag
FROM raw.payments_events;
