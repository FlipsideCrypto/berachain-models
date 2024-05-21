{{ config (
    materialized = "incremental",
    unique_key = ["block_number", "tx_hash"],
    cluster_by = "ROUND(block_number, -3)",
    full_refresh = false,
    tags = ['streamline_core_complete']
) }}

WITH blocks_to_do AS (

    SELECT
        block_number,
        tx_hash,
    FROM
        {{ ref('bronze_lq__tx_hashes') }}

{% if is_incremental() %}
EXCEPT
SELECT
    block_number,
    tx_hash
FROM
    {{ this }}
{% endif %}
),
ordered_blocks AS (
    SELECT
        block_number,
        tx_hash,
        ROW_NUMBER() over (
            ORDER BY
                block_number,
                tx_hash
        ) AS row_no,
        MOD(
            row_no,
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
    block_number, tx_hash, ROUND(block_number, -3) :: INT AS partition_key, {{ target.database }}.live.udf_api('POST', '{service}/{Authentication}', OBJECT_CONSTRUCT('Content-Type', 'application/json'), OBJECT_CONSTRUCT('id', block_number :: STRING, 'jsonrpc', '2.0', 'method', 'eth_getTransactionReceipt', 'params', ARRAY_CONSTRUCT(tx_hash)), 'Vault/prod/berachain/quicknode/artio') AS node_call, SYSDATE() AS _inserted_timestamp
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
    tx_hash,
    partition_key,
    node_call,
    _inserted_timestamp
FROM
    batched
