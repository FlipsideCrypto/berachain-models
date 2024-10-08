{{ config (
    materialized = 'table',
    tags = ['streamline_testnet_core_complete']
) }}

SELECT
    {{ target.database }}.live.udf_api(
        'POST',
        CONCAT(
            '{Service}',
            '/',
            '{Authentication}'
        ),
        OBJECT_CONSTRUCT(
            'Content-Type',
            'application/json',
            'fsc-quantum-state',
            'livequery'
        ),
        OBJECT_CONSTRUCT(
            'id',
            0,
            'jsonrpc',
            '2.0',
            'method',
            'eth_blockNumber',
            'params',
            []
        ),
        'Vault/prod/berachain/quicknode/bartio'
    ) AS resp,
    utils.udf_hex_to_int(
        resp :data :result :: STRING
    ) AS block_number
