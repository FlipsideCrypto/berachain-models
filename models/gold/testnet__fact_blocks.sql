{{ config(
    materialized = 'incremental',
    unique_key = "block_number",
    incremental_strategy = 'delete+insert',
    merge_exclude_columns = ["inserted_timestamp"],
    cluster_by = "block_timestamp::date",
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(hash,parent_hash,receipts_root,sha3_uncles)",
    tags = ['non_realtime']
) }}

SELECT
    A.block_number AS block_number,
    block_timestamp,
    'bartio' AS network,
    'berachain' AS blockchain,
    tx_count,
    difficulty,
    total_difficulty,
    extra_data,
    gas_limit,
    gas_used,
    HASH,
    parent_hash,
    receipts_root,
    sha3_uncles,
    SIZE,
    uncles AS uncle_blocks,
    OBJECT_CONSTRUCT(
        'baseFeePerGas',
        base_fee_per_gas,
        'difficulty',
        difficulty,
        'extraData',
        extra_data,
        'gasLimit',
        gas_limit,
        'gasUsed',
        gas_used,
        'hash',
        HASH,
        'logsBloom',
        logs_bloom,
        'miner',
        miner,
        'nonce',
        nonce,
        'number',
        NUMBER,
        'parentHash',
        parent_hash,
        'parentBeaconBlockRoot',
        parent_beacon_block_root,
        'receiptsRoot',
        receipts_root,
        'sha3Uncles',
        sha3_uncles,
        'size',
        SIZE,
        'stateRoot',
        state_root,
        'timestamp',
        block_timestamp,
        'totalDifficulty',
        total_difficulty,
        'transactionsRoot',
        transactions_root,
        'uncles',
        uncles,
        'withdrawals',
        withdrawals,
        'withdrawalsRoot',
        withdrawals_root
    ) AS block_header_json,
    blocks_id AS fact_blocks_id,
    inserted_timestamp,
    modified_timestamp,
FROM
    {{ ref(
        'silver_testnet__blocks'
    ) }} A

{% if is_incremental() %}
WHERE
    A.modified_timestamp > (
        SELECT
            MAX(
                modified_timestamp
            )
        FROM
            {{ this }}
    )
{% endif %}

qualify(ROW_NUMBER() over (PARTITION BY A.block_number
ORDER BY
    A.modified_timestamp DESC)) = 1
