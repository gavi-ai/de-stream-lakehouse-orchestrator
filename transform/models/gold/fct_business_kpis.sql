-- Gold Layer: High-Performance Business Aggregates for Real-Time BI Visibility
{{ config(materialized='table') }}

SELECT
    date_trunc('hour', event_timestamp) as analytics_hour,
    device_type,
    count(distinct user_id) as unique_active_users,
    count(distinct event_id) as total_transaction_volume,
    sum(case when event_type = 'PURCHASE_SUCCESS' then order_amount else 0 end) as total_revenue_generated,
    round(total_revenue_generated / nullif(total_transaction_volume, 0), 2) as average_order_value
FROM {{ ref('int_cleaned_events') }}
GROUP BY 1, 2
ORDER BY analytics_hour DESC, total_revenue_generated DESC
