{{ config (
    materialized = "view",
    tags = ['streamline_core_complete']
) }}

SELECT
    block_number,
    VALUE :: STRING AS tx_hash
FROM
    {{ ref('bronze_lq__get_block_by_number') }},
    LATERAL FLATTEN (
        input => node_call :data :result :transactions
    )
