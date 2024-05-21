{{ config (
    materialized = "view",
    tags = ['streamline_core_complete']
) }}

SELECT
    _id AS block_number,
    REPLACE(
        concat_ws('', '0x', to_char(block_number, 'XXXXXXXX')),
        ' ',
        ''
    ) AS block_number_hex
FROM
    {{ source(
        'silver_crosschain',
        'number_sequence'
    ) }}
WHERE
    _id between 762066 and  2172232
