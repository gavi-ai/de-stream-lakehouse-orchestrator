-- Silver Layer: Enterprise Cleaned and Deduplicated Core Transformation
{{ config(materialized='table') }}

WITH raw_data AS (
    SELECT * FROM {{ ref('stg_kafka_events') }}
),
deduped AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id 
            ORDER BY event_timestamp DESC
        ) as row_num
    FROM raw_data
    WHERE event_id IS NOT NULL
)
SELECT 
    event_id,
    user_id,
    upper(event_type) as event_type, -- Schema enforcement standardization
    event_timestamp,
    coalesce(order_amount, 0.0) as order_amount,
    device_type,
    load_timestamp
FROM deduped
WHERE row_num = 1 -- Ruthlessly eliminating duplicate continuous network payloads
