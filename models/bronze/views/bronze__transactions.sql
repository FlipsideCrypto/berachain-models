{{ config (
    materialized = "view",
    tags = ['streamline_core_complete']
) }}

SELECT
    block_number,
    tx_hash,
    node_call :data :result AS tx_response
FROM
    {{ ref('bronze_lq__get_transactions') }}
