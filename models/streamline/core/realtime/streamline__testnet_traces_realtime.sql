{{ config (
    materialized = "view",
    post_hook = fsc_utils.if_data_call_function_v2(
        func = 'streamline.udf_bulk_rest_api_v2',
        target = "{{this.schema}}.{{this.identifier}}",
        params ={ "external_table" :"testnet_traces",
        "sql_limit" :"3600",
        "producer_batch_size" :"3600",
        "worker_batch_size" :"3600",
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
        {{ ref("streamline__testnet_traces_complete") }}
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
        {{ ref("_missing_traces") }}
    UNION
    SELECT
        block_number
    FROM
        {{ ref("_unconfirmed_blocks") }}
)
SELECT
    block_number,
    ROUND(
        block_number,
        -3
    ) :: INT AS partition_key,
    {{ target.database }}.live.udf_api(
        'POST',
        CONCAT(
            '{Service}',
            '/',
            '{Authentication}'
        ),
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
            'debug_traceBlockByNumber',
            'params',
            ARRAY_CONSTRUCT(utils.udf_int_to_hex(block_number), OBJECT_CONSTRUCT('tracer', 'callTracer', 'timeout', '180s'))
        ),
        'Vault/prod/berachain/quicknode/bartio'
    ) AS request
FROM
    ready_blocks
ORDER BY
    block_number DESC
LIMIT
    3600
