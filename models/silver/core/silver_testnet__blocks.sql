-- depends_on: {{ ref('bronze_testnet__blocks') }}
{{ config(
    materialized = 'incremental',
    unique_key = "block_number",
    cluster_by = "block_timestamp::date",
    tags = ['non_realtime'],
    full_refresh = false
) }}
-- add Search Optimization to mainnet
SELECT
    DATA,
    COALESCE(
        VALUE :BLOCK_NUMBER :: INT,
        metadata :request :"data" :id :: INT,
        PARSE_JSON(
            metadata :request :"data"
        ) :id :: INT
    ) AS block_number,
    utils.udf_hex_to_int(
        DATA :result :baseFeePerGas :: STRING
    ) :: INT AS base_fee_per_gas,
    utils.udf_hex_to_int(
        DATA :result :blobGasUsed :: STRING
    ) :: INT AS blob_gas_used,
    utils.udf_hex_to_int(
        DATA :result :difficulty :: STRING
    ) :: INT AS difficulty,
    utils.udf_hex_to_int(
        DATA :result :excessBlobGas :: STRING
    ) :: INT AS excess_blob_gas,
    DATA :result :extraData :: STRING AS extra_data,
    utils.udf_hex_to_int(
        DATA :result :gasLimit :: STRING
    ) :: INT AS gas_limit,
    utils.udf_hex_to_int(
        DATA :result :gasUsed :: STRING
    ) :: INT AS gas_used,
    DATA :result :hash :: STRING AS HASH,
    DATA :result :logsBloom :: STRING AS logs_bloom,
    DATA :result :miner :: STRING AS miner,
    DATA :result :mixHash :: STRING AS mixHash,
    utils.udf_hex_to_int(
        DATA :result :nonce :: STRING
    ) :: INT AS nonce,
    utils.udf_hex_to_int(
        DATA :result :number :: STRING
    ) :: INT AS NUMBER,
    DATA :result :parentHash :: STRING AS parent_hash,
    DATA :result :parentBeaconBlockRoot :: STRING AS parent_beacon_block_root,
    DATA :result :receiptsRoot :: STRING AS receipts_root,
    DATA :result :sha3Uncles :: STRING AS sha3_uncles,
    utils.udf_hex_to_int(
        DATA :result :size :: STRING
    ) :: INT AS SIZE,
    DATA :result:stateRoot :: STRING AS state_root,
    utils.udf_hex_to_int(
        DATA :result :timestamp :: STRING
    ) :: TIMESTAMP AS block_timestamp,
    utils.udf_hex_to_int(
        DATA :result :totalDifficulty :: STRING
    ) :: INT AS total_difficulty,
    ARRAY_SIZE(
        DATA :result :transactions
    ) AS tx_count,
    DATA :result :transactionsRoot :: STRING AS transactions_root,
    DATA :result :uncles AS uncles,
    DATA :result :withdrawals AS withdrawals,
    DATA :result :withdrawalsRoot :: STRING AS withdrawals_root,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['block_number']
    ) }} AS blocks_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
{% if is_incremental() %}
{{ ref('bronze_testnet__blocks') }}
WHERE
    _inserted_timestamp >= (
        SELECT
            MAX(_inserted_timestamp) _inserted_timestamp
        FROM
            {{ this }}
    )
{% else %}
    {{ ref('bronze_testnet__FR_blocks') }}
{% endif %}

qualify(ROW_NUMBER() over (PARTITION BY block_number
ORDER BY
    _inserted_timestamp DESC)) = 1