-- Bronze Layer: Raw View capturing continuous streaming ingestion telemetry
{{ config(materialized='view') }}

SELECT
    payload:event_id::VARCHAR as event_id,
    payload:user_id::VARCHAR as user_id,
    payload:event_type::VARCHAR as event_type,
    payload:timestamp::TIMESTAMP as event_timestamp,
    payload:amount::FLOAT as order_amount,
    payload:device::VARCHAR as device_type,
    metadata$filename as ingestion_source_file,
    current_timestamp() as load_timestamp
FROM {{ source('ishqa11_raw', 'raw_streaming_events') }}
