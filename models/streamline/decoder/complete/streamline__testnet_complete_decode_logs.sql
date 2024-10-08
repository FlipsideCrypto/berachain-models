-- depends_on: {{ ref('bronze_testnet__decoded_logs') }}
{{ config (
    materialized = "incremental",
    unique_key = "_log_id",
    cluster_by = "ROUND(block_number, -3)",
    merge_update_columns = ["_log_id"],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION on equality(_log_id)",
    tags = ['streamline_decoded_logs_complete']
) }}

SELECT
    block_number,
    id AS _log_id,
    _inserted_timestamp
FROM

{% if is_incremental() %}
{{ ref('bronze_testnet__decoded_logs') }}
WHERE
    TO_TIMESTAMP_NTZ(_inserted_timestamp) >= (
        SELECT
           COALESCE(MAX(_inserted_timestamp), '1970-01-01' :: TIMESTAMP) _inserted_timestamp
        FROM
            {{ this }}
    )
{% else %}
    {{ ref('bronze_testnet__fr_decoded_logs') }}
{% endif %}

qualify(ROW_NUMBER() over (PARTITION BY id
ORDER BY
    _inserted_timestamp DESC)) = 1
