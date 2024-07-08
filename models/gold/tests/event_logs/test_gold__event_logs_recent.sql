{{ config (
    materialized = 'view',
    tags = ['recent_test']
) }}

WITH last_3_days AS (

    SELECT
        block_number
    FROM
        {{ ref("_block_lookback") }}
)
SELECT
    *
FROM
    {{ ref('testnet__fact_event_logs') }}
WHERE
    block_number >= (
        SELECT
            block_number
        FROM
            last_3_days
    )
