{{ config (
    materialized = "view",
    post_hook = fsc_utils.if_data_call_function_v2(
        func = 'streamline.udf_bulk_rest_api_v2',
        target = "{{this.schema}}.{{this.identifier}}",
        params ={ "external_table" :"testnet_receipts",
        "sql_limit" :"20000",
        "producer_batch_size" :"5000",
        "worker_batch_size" :"2000",
        "sql_source" :"{{this.identifier}}",
        "exploded_key": tojson(["result"]) }
    ),
    tags = ['streamline_testnet_realtime']
) }}

WITH to_do AS (

    SELECT
        block_number
    FROM
        {{ ref("streamline__testnet_blocks") }}
    WHERE
        block_number IS NOT NULL
    EXCEPT
    SELECT
        block_number
    FROM
        {{ ref("streamline__testnet_receipts_complete") }}
),
ready_blocks AS (
    SELECT
        block_number
    FROM
        to_do
    UNION
    SELECT
        block_number
    FROM
        {{ ref("_missing_receipts") }}
    UNION
    SELECT
        block_number
    FROM
        {{ ref("_missing_txs") }}
)
SELECT
    block_number,
    ROUND(
        block_number,
        -3
    ) :: INT AS partition_key,
    {{ target.database }}.live.udf_api(
        'POST',
        '{Service}',
        OBJECT_CONSTRUCT(
            'Content-Type',
            'application/json'
        ),
        OBJECT_CONSTRUCT(
            'id',
            block_number :: STRING,
            'jsonrpc',
            '2.0',
            'method',
            'eth_getBlockReceipts',
            'params',
            ARRAY_CONSTRUCT(utils.udf_int_to_hex(block_number))),
            'Vault/prod/berachain/internal/testnet_2'
        ) AS request
        FROM
            ready_blocks
        ORDER BY
            block_number DESC
        LIMIT
            20000
