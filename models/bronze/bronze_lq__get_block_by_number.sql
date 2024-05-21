{{ config (
    materialized = "incremental",
    unique_key = "block_number",
    cluster_by = "ROUND(block_number, -3)",
    full_refresh = false,
    tags = ['streamline_core_complete']
) }}

WITH blocks_to_do AS (

    SELECT
        block_number,
        block_number_hex
    FROM
        {{ ref('streamline__blocks') }}

{% if is_incremental() %}
EXCEPT
SELECT
    block_number,
    block_number_hex
FROM
    {{ this }}
{% endif %}
),
ordered_blocks AS (
    SELECT
        block_number,
        block_number_hex,
        MOD(
            block_number,
            10
        ) AS batch
    FROM
        blocks_to_do
    ORDER BY
        block_number DESC
    LIMIT
        3000
), batched AS ({% for item in range(11) %}
SELECT
    block_number, block_number_hex, ROUND(block_number, -3) :: INT AS partition_key, {{ target.database }}.live.udf_api('POST', '{service}/{Authentication}', OBJECT_CONSTRUCT('Content-Type', 'application/json'), OBJECT_CONSTRUCT('id', block_number :: STRING, 'jsonrpc', '2.0', 'method', 'eth_getBlockByNumber', 'params', ARRAY_CONSTRUCT(block_number_hex, FALSE)), 'Vault/prod/berachain/quicknode/artio') AS node_call, SYSDATE() AS _inserted_timestamp
FROM
    ordered_blocks
WHERE
    batch = {{ item }}

    {% if not loop.last %}
    UNION ALL
    {% endif %}
{% endfor %})
SELECT
    block_number,
    block_number_hex,
    partition_key,
    node_call,
    _inserted_timestamp
FROM
    batched
