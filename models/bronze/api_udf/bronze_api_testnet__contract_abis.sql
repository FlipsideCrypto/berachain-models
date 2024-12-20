{{ config(
    materialized = 'incremental',
    unique_key = "contract_address",
    full_refresh = false,
    tags = ['non_realtime']
) }}

WITH base AS (

    SELECT
        contract_address,
        total_interaction_count
    FROM
        {{ ref('silver_testnet__relevant_contracts') }}
    WHERE
        total_interaction_count >= 250

{% if is_incremental() %}
AND contract_address NOT IN (
    SELECT
        contract_address
    FROM
        {{ this }}
    WHERE
        abi_data :data :result :: STRING <> 'Max rate limit reached'
)
{% endif %}
ORDER BY
    total_interaction_count DESC
LIMIT
    400
), all_contracts AS (
    SELECT
        contract_address
    FROM
        base
),
row_nos AS (
    SELECT
        contract_address,
        ROW_NUMBER() over (
            ORDER BY
                contract_address
        ) AS row_no
    FROM
        all_contracts
),
batched AS ({% for item in range(501) %}
SELECT
    rn.contract_address, live.udf_api('GET', CONCAT('https://api.routescan.io/v2/network/testnet/evm/80084/etherscan/api?module=contract&action=getabi&address=', rn.contract_address),{},{}, '') AS abi_data, SYSDATE() AS _inserted_timestamp
FROM
    row_nos rn
WHERE
    row_no = {{ item }}

    {% if not loop.last %}
    UNION ALL
    {% endif %}
{% endfor %})
SELECT
    contract_address,
    abi_data,
    _inserted_timestamp
FROM
    batched
