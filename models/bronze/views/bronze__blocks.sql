{{ config (
    materialized = "view",
    tags = ['streamline_core_complete']
) }}

SELECT
    block_number,
    node_call :data :result AS block_response
FROM
    {{ ref('bronze_lq__get_block_by_number') }}
